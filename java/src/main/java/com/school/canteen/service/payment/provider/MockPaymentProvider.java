package com.school.canteen.service.payment.provider;

import com.school.canteen.exception.BusinessException;
import com.school.canteen.service.payment.PaymentProvider;
import com.school.canteen.service.payment.config.PaymentProperties;
import com.school.canteen.service.payment.dto.PaymentCallbackPayload;
import com.school.canteen.service.payment.dto.PaymentCreateRequest;
import com.school.canteen.service.payment.dto.PaymentCreateResponse;
import com.school.canteen.service.payment.dto.PaymentQueryResponse;
import com.school.canteen.service.payment.enums.PaymentProviderType;
import com.school.canteen.service.payment.enums.PaymentStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class MockPaymentProvider implements PaymentProvider {

    private final PaymentProperties properties;

    @Override
    public PaymentProviderType getProviderType() {
        return PaymentProviderType.MOCK;
    }

    @Override
    public PaymentCreateResponse createPayment(PaymentCreateRequest request) {
        LocalDateTime now = LocalDateTime.now();
        String transactionId = buildTransactionId(request.getOrderNumber());
        return PaymentCreateResponse.builder()
            .mode(properties.getMode())
            .provider(getProviderType().name())
            .orderId(request.getOrderId())
            .orderNumber(request.getOrderNumber())
            .amount(request.getAmount())
            .paymentMethod(normalizePaymentMethod(request.getPaymentMethod()))
            .transactionId(transactionId)
            .status(PaymentStatus.CREATED)
            .qrCodeUrl(properties.getMock().getQrCodeUrl() + "/" + request.getOrderNumber())
            .redirectUrl(properties.getMock().getRedirectUrl())
            .miniProgramParams(Map.of(
                "provider", getProviderType().name(),
                "mock", true,
                "orderNumber", request.getOrderNumber(),
                "transactionId", transactionId
            ))
            .createdAt(now)
            .expiresAt(now.plusMinutes(15))
            .build();
    }

    @Override
    public boolean verifyCallback(Map<String, Object> payload, String timestampHeader, String signatureHeader) {
        if (payload == null) {
            return false;
        }
        String secret = properties.getCallbackSecret();
        if (secret == null || secret.isBlank()) {
            return false;
        }
        if (timestampHeader == null || timestampHeader.isBlank() || signatureHeader == null || signatureHeader.isBlank()) {
            return false;
        }

        long timestampSeconds;
        try {
            timestampSeconds = Long.parseLong(timestampHeader.trim());
        } catch (NumberFormatException e) {
            return false;
        }

        long nowSeconds = System.currentTimeMillis() / 1000;
        if (Math.abs(nowSeconds - timestampSeconds) > properties.getCallbackTimeoutSeconds()) {
            return false;
        }

        String orderNumber = normalizeValue(payload.get("orderNumber"));
        String paymentMethod = normalizeValue(payload.get("paymentMethod"));
        String transactionId = normalizeValue(payload.get("transactionId"));
        if (orderNumber == null || paymentMethod == null || transactionId == null) {
            return false;
        }

        String signedPayload = orderNumber + "|" + paymentMethod + "|" + transactionId + "|" + timestampSeconds;
        String expected = hmacSha256Hex(signedPayload, secret);
        return expected != null && MessageDigest.isEqual(
            expected.getBytes(StandardCharsets.UTF_8),
            signatureHeader.trim().toLowerCase(Locale.ROOT).getBytes(StandardCharsets.UTF_8)
        );
    }

    @Override
    public PaymentCallbackPayload parseCallback(Map<String, Object> payload) {
        String orderNumber = normalizeValue(payload.get("orderNumber"));
        String paymentMethod = normalizeValue(payload.get("paymentMethod"));
        String transactionId = normalizeValue(payload.get("transactionId"));
        if (orderNumber == null || paymentMethod == null || transactionId == null) {
            throw new BusinessException("PAYMENT_CALLBACK_FIELDS_MISSING", HttpStatus.BAD_REQUEST, "missing required payment callback fields");
        }
        String paymentStatus = parsePaymentStatus(payload);
        if (paymentStatus == null) {
            throw new BusinessException("PAYMENT_CALLBACK_STATUS_MISSING", HttpStatus.BAD_REQUEST, "missing payment callback success status");
        }
        return PaymentCallbackPayload.builder()
            .provider(getProviderType().name())
            .notificationId(normalizeValue(payload.get("notificationId")))
            .orderNumber(orderNumber)
            .paymentMethod(paymentMethod)
            .transactionId(transactionId)
            .paymentStatus(paymentStatus)
            .paidAt(parsePaidAt(payload.get("paidAt")))
            .rawPayload(payload)
            .build();
    }

    @Override
    public PaymentQueryResponse queryPayment(String orderNumber) {
        return PaymentQueryResponse.builder()
            .mode(properties.getMode())
            .provider(getProviderType().name())
            .orderNumber(orderNumber)
            .providerStatus(PaymentStatus.UNKNOWN)
            .rawProviderResponse(Map.of("mock", true, "message", "Mock provider does not persist remote payment state"))
            .build();
    }

    public String buildTransactionId(String orderNumber) {
        String orderPart = orderNumber == null || orderNumber.isBlank() ? "ORDER" : orderNumber.trim();
        String uuidPart = UUID.randomUUID().toString().replace("-", "").substring(0, 10).toUpperCase(Locale.ROOT);
        return "MOCK-" + orderPart + "-" + System.currentTimeMillis() + "-" + uuidPart;
    }

    public LocalDateTime parsePaidAt(Object paidAtObj) {
        if (!(paidAtObj instanceof String paidAtStr) || paidAtStr.isBlank()) {
            return LocalDateTime.now();
        }
        try {
            return ZonedDateTime.parse(paidAtStr)
                .withZoneSameInstant(ZoneId.systemDefault())
                .toLocalDateTime();
        } catch (Exception ignore) {
            try {
                return LocalDateTime.parse(paidAtStr);
            } catch (Exception ignored) {
                return LocalDateTime.now();
            }
        }
    }

    public String normalizeValue(Object value) {
        if (value == null) {
            return null;
        }
        String text = String.valueOf(value).trim();
        return text.isEmpty() || "null".equalsIgnoreCase(text) ? null : text;
    }

    private String parsePaymentStatus(Map<String, Object> payload) {
        Object success = payload.get("success");
        if (success instanceof Boolean successValue) {
            return successValue ? PaymentStatus.PAID.name() : PaymentStatus.FAILED.name();
        }
        String rawStatus = firstValue(
            payload.get("status"),
            payload.get("paymentStatus"),
            payload.get("tradeStatus")
        );
        if (rawStatus == null) {
            return null;
        }
        String normalized = rawStatus.toUpperCase(Locale.ROOT);
        if ("SUCCESS".equals(normalized) || "TRADE_SUCCESS".equals(normalized) || "PAYMENT_SUCCESS".equals(normalized)) {
            return PaymentStatus.PAID.name();
        }
        if ("FAIL".equals(normalized) || "FAILURE".equals(normalized) || "TRADE_FAILED".equals(normalized)) {
            return PaymentStatus.FAILED.name();
        }
        if ("CANCELED".equals(normalized)) {
            return PaymentStatus.CANCELLED.name();
        }
        try {
            return PaymentStatus.valueOf(normalized).name();
        } catch (IllegalArgumentException e) {
            throw new BusinessException("PAYMENT_CALLBACK_STATUS_UNSUPPORTED", HttpStatus.BAD_REQUEST, "unsupported payment callback status: " + rawStatus);
        }
    }

    private String firstValue(Object... values) {
        for (Object value : values) {
            String normalized = normalizeValue(value);
            if (normalized != null) {
                return normalized;
            }
        }
        return null;
    }

    private String normalizePaymentMethod(String paymentMethod) {
        String normalized = normalizeValue(paymentMethod);
        return normalized != null ? normalized : "WECHAT";
    }

    private String hmacSha256Hex(String data, String secret) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] digest = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return null;
        }
    }
}
