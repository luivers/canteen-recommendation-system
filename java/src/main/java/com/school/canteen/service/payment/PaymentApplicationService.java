package com.school.canteen.service.payment;

import com.school.canteen.entity.PaymentCallbackRecord;
import com.school.canteen.entity.Order;
import com.school.canteen.entity.OrderItem;
import com.school.canteen.entity.User;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.repository.PaymentCallbackRecordRepository;
import com.school.canteen.service.OrderService;
import com.school.canteen.service.payment.config.PaymentProperties;
import com.school.canteen.service.payment.dto.PaymentCallbackPayload;
import com.school.canteen.service.payment.dto.PaymentCompletionResponse;
import com.school.canteen.service.payment.dto.PaymentCreateRequest;
import com.school.canteen.service.payment.dto.PaymentCreateResponse;
import com.school.canteen.service.payment.dto.PaymentQueryResponse;
import com.school.canteen.service.payment.enums.PaymentStatus;
import com.school.canteen.service.payment.provider.MockPaymentProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.TreeMap;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentApplicationService {

    private final OrderService orderService;
    private final PaymentProviderFactory providerFactory;
    private final PaymentProperties properties;
    private final PaymentCallbackRecordRepository callbackRecordRepository;

    public PaymentCreateResponse createPayment(Long orderId, String paymentMethod, User currentUser) {
        Order order = loadAccessibleOrder(orderId, currentUser);
        ensurePayable(order);
        PaymentProvider provider = providerFactory.getProvider(paymentMethod);
        return provider.createPayment(buildCreateRequest(order, paymentMethod, currentUser));
    }

    public PaymentCompletionResponse completeMockPayment(Long orderId, Map<String, Object> payload, User currentUser) {
        Order order = loadAccessibleOrder(orderId, currentUser);
        ensurePayable(order);
        PaymentProvider provider = providerFactory.getMockProvider();
        String paymentMethod = normalizeValue(payload != null ? payload.get("paymentMethod") : null);
        if (paymentMethod == null) {
            paymentMethod = "WECHAT";
        }
        String transactionId = normalizeValue(payload != null ? payload.get("transactionId") : null);
        if (transactionId == null) {
            if (provider instanceof MockPaymentProvider mockProvider) {
                transactionId = mockProvider.buildTransactionId(order.getOrderNumber());
            } else {
                transactionId = provider.createPayment(buildCreateRequest(order, paymentMethod, currentUser)).getTransactionId();
            }
        }
        LocalDateTime paidAt = parsePaidAt(payload != null ? payload.get("paidAt") : null);
        Order updated = orderService.markOrderPaid(orderId, paymentMethod, transactionId, paidAt);
        return buildCompletionResponse(updated, provider.getProviderType().name());
    }

    @Transactional
    public PaymentCompletionResponse handleCallback(Map<String, Object> payload,
                                                    String timestampHeader,
                                                    String signatureHeader) {
        String orderNumber = requirePayloadValue(payload, "orderNumber");
        String paymentMethod = requirePayloadValue(payload, "paymentMethod");
        requirePayloadValue(payload, "transactionId");
        PaymentProvider provider = providerFactory.getProvider(paymentMethod);
        if (!provider.verifyCallback(payload, timestampHeader, signatureHeader)) {
            throw new BusinessException("PAYMENT_CALLBACK_SIGNATURE_INVALID", HttpStatus.FORBIDDEN, "invalid callback signature");
        }
        PaymentCallbackPayload callback = provider.parseCallback(payload);
        if (!PaymentStatus.PAID.name().equals(callback.getPaymentStatus())) {
            PaymentCallbackRecord failedRecord = beginCallbackRecord(callback, PaymentCallbackRecord.ProcessStatus.FAILED);
            failedRecord.setErrorMessage("payment status is not successful: " + callback.getPaymentStatus());
            callbackRecordRepository.save(failedRecord);
            throw new BusinessException("PAYMENT_CALLBACK_NOT_SUCCESS", HttpStatus.BAD_REQUEST, "payment callback is not successful: " + callback.getPaymentStatus());
        }

        PaymentCallbackRecord record = beginCallbackRecord(callback, PaymentCallbackRecord.ProcessStatus.PROCESSING);
        if (record.getProcessStatus() == PaymentCallbackRecord.ProcessStatus.PROCESSED) {
            Order updated = orderService.markOrderPaidByNumber(
                callback.getOrderNumber(),
                callback.getPaymentMethod(),
                callback.getTransactionId(),
                callback.getPaidAt()
            );
            log.info("Payment callback duplicate hit provider={} orderNumber={} transactionId={} idempotencyKey={}",
                callback.getProvider(), callback.getOrderNumber(), callback.getTransactionId(), record.getIdempotencyKey());
            return buildCompletionResponse(updated, callback.getProvider(), record, true);
        }
        rejectProcessedPaymentConflict(callback, record);

        try {
            Order updated = orderService.markOrderPaidByNumber(
                callback.getOrderNumber(),
                callback.getPaymentMethod(),
                callback.getTransactionId(),
                callback.getPaidAt()
            );
            record.setProcessStatus(PaymentCallbackRecord.ProcessStatus.PROCESSED);
            record.setProcessedAt(LocalDateTime.now());
            callbackRecordRepository.save(record);
            log.info("Payment callback processed provider={} orderNumber={} transactionId={} idempotencyKey={}",
                callback.getProvider(), callback.getOrderNumber(), callback.getTransactionId(), record.getIdempotencyKey());
            return buildCompletionResponse(updated, callback.getProvider(), record, false);
        } catch (BusinessException e) {
            record.setProcessStatus(isConflict(e) ? PaymentCallbackRecord.ProcessStatus.CONFLICT : PaymentCallbackRecord.ProcessStatus.FAILED);
            record.setErrorMessage(trimError(e.getMessage()));
            callbackRecordRepository.save(record);
            throw e;
        } catch (RuntimeException e) {
            record.setProcessStatus(PaymentCallbackRecord.ProcessStatus.FAILED);
            record.setErrorMessage(trimError(e.getMessage()));
            callbackRecordRepository.save(record);
            throw e;
        }
    }

    private PaymentCallbackRecord beginCallbackRecord(PaymentCallbackPayload callback, PaymentCallbackRecord.ProcessStatus initialStatus) {
        String idempotencyKey = buildIdempotencyKey(callback);
        Optional<PaymentCallbackRecord> existing = callbackRecordRepository.findByIdempotencyKey(idempotencyKey);
        if (existing.isPresent()) {
            PaymentCallbackRecord record = existing.get();
            record.markAttempt(LocalDateTime.now());
            return callbackRecordRepository.save(record);
        }

        PaymentCallbackRecord record = new PaymentCallbackRecord();
        record.setProvider(callback.getProvider());
        record.setOrderNumber(callback.getOrderNumber());
        record.setPaymentMethod(callback.getPaymentMethod());
        record.setTransactionId(callback.getTransactionId());
        record.setIdempotencyKey(idempotencyKey);
        record.setProcessStatus(initialStatus);
        record.setRawPayloadHash(hashPayload(callback.getRawPayload()));
        try {
            return callbackRecordRepository.save(record);
        } catch (DataIntegrityViolationException e) {
            PaymentCallbackRecord duplicate = callbackRecordRepository.findByIdempotencyKey(idempotencyKey)
                .orElseThrow(() -> e);
            duplicate.markAttempt(LocalDateTime.now());
            return callbackRecordRepository.save(duplicate);
        }
    }

    private void rejectProcessedPaymentConflict(PaymentCallbackPayload callback, PaymentCallbackRecord currentRecord) {
        callbackRecordRepository.findFirstByOrderNumberAndProcessStatusOrderByProcessedAtDesc(
            callback.getOrderNumber(),
            PaymentCallbackRecord.ProcessStatus.PROCESSED
        ).filter(processed -> !Objects.equals(processed.getIdempotencyKey(), currentRecord.getIdempotencyKey()))
            .filter(processed -> !sameProcessedPayment(processed, callback))
            .ifPresent(processed -> {
                currentRecord.setProcessStatus(PaymentCallbackRecord.ProcessStatus.CONFLICT);
                currentRecord.setErrorMessage("processed payment already exists: " + processed.getTransactionId());
                callbackRecordRepository.save(currentRecord);
                throw new BusinessException(
                    "PAYMENT_CALLBACK_CONFLICT",
                    HttpStatus.CONFLICT,
                    "Order already has a processed payment callback with another provider or transaction"
                );
            });
    }

    public PaymentQueryResponse queryPaymentStatus(Long orderId, User currentUser) {
        Order order = loadAccessibleOrder(orderId, currentUser);
        String paymentMethod = resolvePaymentMethod(order, "WECHAT");
        PaymentProvider provider = providerFactory.getProvider(paymentMethod);
        PaymentQueryResponse providerResponse = provider.queryPayment(order.getOrderNumber());
        OrderItem firstItem = firstOrderItem(order);
        providerResponse.setMode(properties.getMode());
        providerResponse.setProvider(provider.getProviderType().name());
        providerResponse.setOrderId(order.getId());
        providerResponse.setOrderNumber(order.getOrderNumber());
        providerResponse.setPaymentMethod(resolvePaymentMethod(order, paymentMethod));
        providerResponse.setTransactionId(firstItem != null ? firstItem.getPaymentTransactionId() : null);
        providerResponse.setLocalStatus(order.getStatus() != null ? order.getStatus().name() : null);
        providerResponse.setPaymentTime(firstItem != null ? firstItem.getPaymentTime() : null);
        if (providerResponse.getProviderStatus() == null) {
            providerResponse.setProviderStatus(PaymentStatus.UNKNOWN);
        }
        return providerResponse;
    }

    private Order loadAccessibleOrder(Long orderId, User currentUser) {
        if (currentUser == null) {
            throw new BusinessException("UNAUTHORIZED", HttpStatus.UNAUTHORIZED, "请先登录");
        }
        Order order = orderService.getOrderById(orderId);
        if (!canAccessOrder(currentUser, order)) {
            throw new BusinessException("FORBIDDEN", HttpStatus.FORBIDDEN, "No permission to access this order");
        }
        return order;
    }

    private boolean canAccessOrder(User user, Order order) {
        if (user == null || order == null) {
            return false;
        }
        if (user.getRole() == User.UserRole.ADMIN || user.getRole() == User.UserRole.WINDOW_MANAGER) {
            return true;
        }
        return order.getUser() != null && Objects.equals(order.getUser().getId(), user.getId());
    }

    private void ensurePayable(Order order) {
        if (order.getStatus() != Order.OrderStatus.PENDING) {
            throw new BusinessException("ORDER_NOT_PAYABLE", HttpStatus.BAD_REQUEST, "Order cannot be paid in status: " + order.getStatus());
        }
    }

    private PaymentCreateRequest buildCreateRequest(Order order, String paymentMethod, User currentUser) {
        return PaymentCreateRequest.builder()
            .orderId(order.getId())
            .orderNumber(order.getOrderNumber())
            .amount(resolvePayableAmount(order))
            .paymentMethod(paymentMethod != null && !paymentMethod.isBlank() ? paymentMethod : "WECHAT")
            .userId(currentUser.getId())
            .build();
    }

    private BigDecimal resolvePayableAmount(Order order) {
        if (order.getPayableAmount() != null) {
            return order.getPayableAmount();
        }
        return order.getTotalAmount() != null ? order.getTotalAmount() : BigDecimal.ZERO;
    }

    private PaymentCompletionResponse buildCompletionResponse(Order order, String provider) {
        return buildCompletionResponse(order, provider, null, false);
    }

    private PaymentCompletionResponse buildCompletionResponse(Order order,
                                                              String provider,
                                                              PaymentCallbackRecord record,
                                                              boolean duplicateCallback) {
        OrderItem firstItem = firstOrderItem(order);
        return PaymentCompletionResponse.builder()
            .mode(properties.getMode())
            .provider(provider)
            .orderId(order.getId())
            .orderNumber(order.getOrderNumber())
            .status(order.getStatus() != null ? order.getStatus().name() : null)
            .paymentMethod(firstItem != null ? firstItem.getPaymentMethod() : null)
            .transactionId(firstItem != null ? firstItem.getPaymentTransactionId() : null)
            .paymentTime(firstItem != null ? firstItem.getPaymentTime() : null)
            .idempotencyKey(record != null ? record.getIdempotencyKey() : null)
            .callbackProcessStatus(record != null && record.getProcessStatus() != null ? record.getProcessStatus().name() : null)
            .duplicateCallback(duplicateCallback)
            .build();
    }

    private OrderItem firstOrderItem(Order order) {
        if (order.getOrderItems() == null || order.getOrderItems().isEmpty()) {
            return null;
        }
        return order.getOrderItems().get(0);
    }

    private String resolvePaymentMethod(Order order, String fallback) {
        OrderItem firstItem = firstOrderItem(order);
        String paymentMethod = firstItem != null ? normalizeValue(firstItem.getPaymentMethod()) : null;
        return paymentMethod != null ? paymentMethod : fallback;
    }

    private String normalizeValue(Object value) {
        if (value == null) {
            return null;
        }
        String text = String.valueOf(value).trim();
        return text.isEmpty() || "null".equalsIgnoreCase(text) ? null : text;
    }

    private String requirePayloadValue(Map<String, Object> payload, String key) {
        String value = normalizeValue(payload != null ? payload.get(key) : null);
        if (value == null) {
            throw new BusinessException("PAYMENT_CALLBACK_FIELDS_MISSING", HttpStatus.BAD_REQUEST, "missing required payment callback field: " + key);
        }
        return value;
    }

    private String buildIdempotencyKey(PaymentCallbackPayload callback) {
        String notificationId = normalizeValue(callback.getNotificationId());
        if (notificationId != null) {
            return callback.getProvider() + ":notification:" + notificationId;
        }
        return callback.getProvider() + ":" + callback.getOrderNumber() + ":" + callback.getTransactionId();
    }

    private boolean sameProcessedPayment(PaymentCallbackRecord processed, PaymentCallbackPayload callback) {
        return Objects.equals(processed.getProvider(), callback.getProvider())
            && Objects.equals(processed.getOrderNumber(), callback.getOrderNumber())
            && Objects.equals(processed.getTransactionId(), callback.getTransactionId());
    }

    private boolean isConflict(BusinessException e) {
        return e.getHttpStatus() == HttpStatus.CONFLICT || "PAYMENT_CONFLICT".equals(e.getCode());
    }

    private String trimError(String message) {
        if (message == null) {
            return null;
        }
        return message.length() > 500 ? message.substring(0, 500) : message;
    }

    private String hashPayload(Map<String, Object> payload) {
        if (payload == null) {
            return null;
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(new TreeMap<>(payload).toString().getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(hash.length * 2);
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return null;
        }
    }

    private LocalDateTime parsePaidAt(Object paidAtObj) {
        if (providerFactory.getMockProvider() instanceof MockPaymentProvider mockProvider) {
            return mockProvider.parsePaidAt(paidAtObj);
        }
        return LocalDateTime.now();
    }
}
