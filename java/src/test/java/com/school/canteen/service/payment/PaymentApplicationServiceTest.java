package com.school.canteen.service.payment;

import com.school.canteen.entity.PaymentCallbackRecord;
import com.school.canteen.entity.Order;
import com.school.canteen.entity.OrderItem;
import com.school.canteen.entity.User;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.repository.PaymentCallbackRecordRepository;
import com.school.canteen.service.OrderService;
import com.school.canteen.service.payment.config.PaymentProperties;
import com.school.canteen.service.payment.dto.PaymentCompletionResponse;
import com.school.canteen.service.payment.dto.PaymentCreateResponse;
import com.school.canteen.service.payment.dto.PaymentQueryResponse;
import com.school.canteen.service.payment.enums.PaymentStatus;
import com.school.canteen.service.payment.provider.MockPaymentProvider;
import org.junit.jupiter.api.Test;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PaymentApplicationServiceTest {

    @Test
    void completeMockPaymentChecksAccessAndMarksOrderPaidThroughOrderService() {
        PaymentProperties properties = new PaymentProperties();
        MockPaymentProvider mockProvider = new MockPaymentProvider(properties);
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(mockProvider));
        OrderService orderService = mock(OrderService.class);
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, emptyCallbackRepository());

        User user = user(7L, User.UserRole.STUDENT);
        Order pending = order(20L, "ORD2001", user, Order.OrderStatus.PENDING);
        Order paid = order(20L, "ORD2001", user, Order.OrderStatus.PAID);
        paid.getOrderItems().get(0).setPaymentMethod("WECHAT");
        paid.getOrderItems().get(0).setPaymentTransactionId("MOCK-ORD2001-EXPLICIT");
        paid.getOrderItems().get(0).setPaymentTime(LocalDateTime.now());

        when(orderService.getOrderById(20L)).thenReturn(pending);
        when(orderService.markOrderPaid(eq(20L), eq("WECHAT"), eq("MOCK-ORD2001-EXPLICIT"), any(LocalDateTime.class)))
            .thenReturn(paid);

        PaymentCompletionResponse response = service.completeMockPayment(
            20L,
            Map.of("paymentMethod", "WECHAT", "transactionId", "MOCK-ORD2001-EXPLICIT"),
            user
        );

        assertEquals("PAID", response.getStatus());
        assertEquals("MOCK", response.getProvider());
        assertEquals("MOCK-ORD2001-EXPLICIT", response.getTransactionId());
        verify(orderService).markOrderPaid(eq(20L), eq("WECHAT"), eq("MOCK-ORD2001-EXPLICIT"), any(LocalDateTime.class));
    }

    @Test
    void createPaymentRejectsOrderOwnedByAnotherStudent() {
        PaymentProperties properties = new PaymentProperties();
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, emptyCallbackRepository());

        when(orderService.getOrderById(21L)).thenReturn(order(21L, "ORD2002", user(99L, User.UserRole.STUDENT), Order.OrderStatus.PENDING));

        BusinessException exception = assertThrows(
            BusinessException.class,
            () -> service.createPayment(21L, "WECHAT", user(7L, User.UserRole.STUDENT))
        );
        assertTrue(exception.getMessage().contains("No permission"));
    }

    @Test
    void createPaymentReturnsStableMockPaymentContractWithoutMarkingOrderPaid() {
        PaymentProperties properties = new PaymentProperties();
        properties.getMock().setQrCodeUrl("mock://pay");
        properties.getMock().setRedirectUrl("https://example.test/pay");
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, emptyCallbackRepository());

        User user = user(7L, User.UserRole.STUDENT);
        Order pending = order(22L, "ORD2003", user, Order.OrderStatus.PENDING);
        when(orderService.getOrderById(22L)).thenReturn(pending);

        PaymentCreateResponse response = service.createPayment(22L, "ALIPAY", user);

        assertEquals("mock", response.getMode());
        assertEquals("MOCK", response.getProvider());
        assertEquals(22L, response.getOrderId());
        assertEquals("ORD2003", response.getOrderNumber());
        assertEquals(new BigDecimal("25.00"), response.getAmount());
        assertEquals("ALIPAY", response.getPaymentMethod());
        assertTrue(response.getTransactionId().startsWith("MOCK-ORD2003-"));
        assertEquals(PaymentStatus.CREATED, response.getStatus());
        assertEquals("mock://pay/ORD2003", response.getQrCodeUrl());
        assertEquals("https://example.test/pay", response.getRedirectUrl());
        assertEquals("MOCK", response.getMiniProgramParams().get("provider"));
        assertEquals(true, response.getMiniProgramParams().get("mock"));
        assertEquals("ORD2003", response.getMiniProgramParams().get("orderNumber"));
        assertEquals(response.getTransactionId(), response.getMiniProgramParams().get("transactionId"));
        assertTrue(response.getExpiresAt().isAfter(response.getCreatedAt()));
        verify(orderService).getOrderById(22L);
    }

    @Test
    void createPaymentRejectsAlreadyPaidOrClosedOrders() {
        PaymentProperties properties = new PaymentProperties();
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, emptyCallbackRepository());
        User user = user(7L, User.UserRole.STUDENT);

        when(orderService.getOrderById(23L)).thenReturn(order(23L, "ORD2004", user, Order.OrderStatus.PAID));

        BusinessException exception = assertThrows(
            BusinessException.class,
            () -> service.createPayment(23L, "WECHAT", user)
        );
        assertEquals("ORDER_NOT_PAYABLE", exception.getCode());
        assertTrue(exception.getMessage().contains("PAID"));
    }

    @Test
    void createPaymentFailsClearlyWhenSandboxProviderIsNotImplemented() {
        PaymentProperties properties = new PaymentProperties();
        properties.setMode("sandbox");
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, emptyCallbackRepository());
        User user = user(7L, User.UserRole.STUDENT);

        when(orderService.getOrderById(24L)).thenReturn(order(24L, "ORD2005", user, Order.OrderStatus.PENDING));

        BusinessException exception = assertThrows(
            BusinessException.class,
            () -> service.createPayment(24L, "WECHAT", user)
        );
        assertEquals("PAYMENT_PROVIDER_NOT_IMPLEMENTED", exception.getCode());
        assertTrue(exception.getMessage().contains("WECHAT_SANDBOX"));
    }

    @Test
    void queryPaymentStatusReturnsPendingMockStatusForAccessibleOrder() {
        PaymentProperties properties = new PaymentProperties();
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, emptyCallbackRepository());
        User user = user(7L, User.UserRole.STUDENT);
        Order pending = order(25L, "ORD2006", user, Order.OrderStatus.PENDING);
        when(orderService.getOrderById(25L)).thenReturn(pending);

        PaymentQueryResponse response = service.queryPaymentStatus(25L, user);

        assertEquals("mock", response.getMode());
        assertEquals("MOCK", response.getProvider());
        assertEquals(25L, response.getOrderId());
        assertEquals("ORD2006", response.getOrderNumber());
        assertEquals("WECHAT", response.getPaymentMethod());
        assertEquals("PENDING", response.getLocalStatus());
        assertEquals(PaymentStatus.PENDING, response.getProviderStatus());
        assertTrue(response.getQueryTime() != null);
    }

    @Test
    void queryPaymentStatusReturnsPaidMockStatusWithPaymentFields() {
        PaymentProperties properties = new PaymentProperties();
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, emptyCallbackRepository());
        User user = user(7L, User.UserRole.STUDENT);
        Order paid = paidOrder("ORD2007", "ALIPAY", "MOCK-ORD2007-1");
        paid.setId(26L);
        when(orderService.getOrderById(26L)).thenReturn(paid);

        PaymentQueryResponse response = service.queryPaymentStatus(26L, user);

        assertEquals("PAID", response.getLocalStatus());
        assertEquals(PaymentStatus.PAID, response.getProviderStatus());
        assertEquals("ALIPAY", response.getPaymentMethod());
        assertEquals("MOCK-ORD2007-1", response.getTransactionId());
        assertTrue(response.getPaymentTime() != null);
    }

    @Test
    void queryPaymentStatusRejectsUnauthenticatedAndUnauthorizedUsers() {
        PaymentProperties properties = new PaymentProperties();
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, emptyCallbackRepository());
        when(orderService.getOrderById(27L)).thenReturn(order(27L, "ORD2008", user(99L, User.UserRole.STUDENT), Order.OrderStatus.PENDING));

        BusinessException unauthenticated = assertThrows(
            BusinessException.class,
            () -> service.queryPaymentStatus(27L, null)
        );
        assertEquals("UNAUTHORIZED", unauthenticated.getCode());

        BusinessException forbidden = assertThrows(
            BusinessException.class,
            () -> service.queryPaymentStatus(27L, user(7L, User.UserRole.STUDENT))
        );
        assertEquals("FORBIDDEN", forbidden.getCode());
    }

    @Test
    void queryPaymentStatusAllowsAdminAccessToOtherUsersOrder() {
        PaymentProperties properties = new PaymentProperties();
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, emptyCallbackRepository());
        when(orderService.getOrderById(28L)).thenReturn(order(28L, "ORD2009", user(99L, User.UserRole.STUDENT), Order.OrderStatus.PENDING));

        PaymentQueryResponse response = service.queryPaymentStatus(28L, user(1L, User.UserRole.ADMIN));

        assertEquals(28L, response.getOrderId());
        assertEquals("PENDING", response.getLocalStatus());
    }

    @Test
    void queryPaymentStatusFailsClearlyWhenSandboxProviderIsNotImplemented() {
        PaymentProperties properties = new PaymentProperties();
        properties.setMode("sandbox");
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, emptyCallbackRepository());
        User user = user(7L, User.UserRole.STUDENT);
        when(orderService.getOrderById(29L)).thenReturn(order(29L, "ORD2010", user, Order.OrderStatus.PENDING));

        BusinessException exception = assertThrows(
            BusinessException.class,
            () -> service.queryPaymentStatus(29L, user)
        );

        assertEquals("PAYMENT_PROVIDER_NOT_IMPLEMENTED", exception.getCode());
        assertTrue(exception.getMessage().contains("WECHAT_SANDBOX"));
    }

    @Test
    void handleCallbackVerifiesSignatureCreatesRecordAndMarksOrderPaid() throws Exception {
        PaymentProperties properties = new PaymentProperties();
        properties.setCallbackSecret("secret-for-test");
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentCallbackRecordRepository callbackRepository = emptyCallbackRepository();
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, callbackRepository);

        Order paid = paidOrder("ORD3001", "WECHAT", "MOCK-ORD3001-1");
        when(orderService.markOrderPaidByNumber(eq("ORD3001"), eq("WECHAT"), eq("MOCK-ORD3001-1"), any(LocalDateTime.class)))
            .thenReturn(paid);
        Map<String, Object> payload = callbackPayload("ORD3001", "WECHAT", "MOCK-ORD3001-1");
        long timestamp = System.currentTimeMillis() / 1000;

        PaymentCompletionResponse response = service.handleCallback(
            payload,
            String.valueOf(timestamp),
            signature("ORD3001", "WECHAT", "MOCK-ORD3001-1", timestamp, properties.getCallbackSecret())
        );

        assertEquals("PAID", response.getStatus());
        assertEquals("MOCK:ORD3001:MOCK-ORD3001-1", response.getIdempotencyKey());
        assertEquals("PROCESSED", response.getCallbackProcessStatus());
        verify(orderService).markOrderPaidByNumber(eq("ORD3001"), eq("WECHAT"), eq("MOCK-ORD3001-1"), any(LocalDateTime.class));
    }

    @Test
    void handleCallbackRejectsBadSignatureWithoutSavingRecordOrTouchingOrder() {
        PaymentProperties properties = new PaymentProperties();
        properties.setCallbackSecret("secret-for-test");
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentCallbackRecordRepository callbackRepository = emptyCallbackRepository();
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, callbackRepository);

        BusinessException exception = assertThrows(
            BusinessException.class,
            () -> service.handleCallback(callbackPayload("ORD3002", "WECHAT", "MOCK-ORD3002-1"), String.valueOf(System.currentTimeMillis() / 1000), "bad-signature")
        );

        assertEquals("PAYMENT_CALLBACK_SIGNATURE_INVALID", exception.getCode());
        verify(callbackRepository, never()).save(any());
        verify(orderService, never()).markOrderPaidByNumber(any(), any(), any(), any());
    }

    @Test
    void handleCallbackRejectsNonSuccessfulStatusWithoutTouchingOrder() throws Exception {
        PaymentProperties properties = new PaymentProperties();
        properties.setCallbackSecret("secret-for-test");
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentCallbackRecordRepository callbackRepository = emptyCallbackRepository();
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, callbackRepository);
        long timestamp = System.currentTimeMillis() / 1000;

        BusinessException exception = assertThrows(
            BusinessException.class,
            () -> service.handleCallback(
                Map.of(
                    "orderNumber", "ORD3005",
                    "paymentMethod", "WECHAT",
                    "transactionId", "MOCK-ORD3005-1",
                    "status", "FAILED"
                ),
                String.valueOf(timestamp),
                signature("ORD3005", "WECHAT", "MOCK-ORD3005-1", timestamp, properties.getCallbackSecret())
            )
        );

        assertEquals("PAYMENT_CALLBACK_NOT_SUCCESS", exception.getCode());
        verify(orderService, never()).markOrderPaidByNumber(any(), any(), any(), any());
    }

    @Test
    void handleCallbackTreatsSameIdempotencyKeyAsDuplicate() throws Exception {
        PaymentProperties properties = new PaymentProperties();
        properties.setCallbackSecret("secret-for-test");
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentCallbackRecordRepository callbackRepository = emptyCallbackRepository();
        PaymentCallbackRecord existing = callbackRecord("MOCK", "ORD3003", "WECHAT", "MOCK-ORD3003-1", PaymentCallbackRecord.ProcessStatus.PROCESSED);
        when(callbackRepository.findByIdempotencyKey("MOCK:ORD3003:MOCK-ORD3003-1")).thenReturn(Optional.of(existing));
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, callbackRepository);

        when(orderService.markOrderPaidByNumber(eq("ORD3003"), eq("WECHAT"), eq("MOCK-ORD3003-1"), any(LocalDateTime.class)))
            .thenReturn(paidOrder("ORD3003", "WECHAT", "MOCK-ORD3003-1"));
        long timestamp = System.currentTimeMillis() / 1000;

        PaymentCompletionResponse response = service.handleCallback(
            callbackPayload("ORD3003", "WECHAT", "MOCK-ORD3003-1"),
            String.valueOf(timestamp),
            signature("ORD3003", "WECHAT", "MOCK-ORD3003-1", timestamp, properties.getCallbackSecret())
        );

        assertEquals(true, response.getDuplicateCallback());
        assertEquals(2, existing.getAttemptCount());
        assertEquals("PROCESSED", response.getCallbackProcessStatus());
    }

    @Test
    void handleCallbackRejectsDifferentTransactionAfterProcessedCallback() throws Exception {
        PaymentProperties properties = new PaymentProperties();
        properties.setCallbackSecret("secret-for-test");
        PaymentProviderFactory factory = new PaymentProviderFactory(properties, List.of(new MockPaymentProvider(properties)));
        OrderService orderService = mock(OrderService.class);
        PaymentCallbackRecordRepository callbackRepository = emptyCallbackRepository();
        PaymentCallbackRecord processed = callbackRecord("MOCK", "ORD3004", "WECHAT", "MOCK-ORD3004-OLD", PaymentCallbackRecord.ProcessStatus.PROCESSED);
        when(callbackRepository.findFirstByOrderNumberAndProcessStatusOrderByProcessedAtDesc("ORD3004", PaymentCallbackRecord.ProcessStatus.PROCESSED))
            .thenReturn(Optional.of(processed));
        PaymentApplicationService service = new PaymentApplicationService(orderService, factory, properties, callbackRepository);
        long timestamp = System.currentTimeMillis() / 1000;

        BusinessException exception = assertThrows(
            BusinessException.class,
            () -> service.handleCallback(
                callbackPayload("ORD3004", "WECHAT", "MOCK-ORD3004-NEW"),
                String.valueOf(timestamp),
                signature("ORD3004", "WECHAT", "MOCK-ORD3004-NEW", timestamp, properties.getCallbackSecret())
            )
        );

        assertEquals("PAYMENT_CALLBACK_CONFLICT", exception.getCode());
        verify(orderService, never()).markOrderPaidByNumber(any(), any(), any(), any());
    }

    private User user(Long id, User.UserRole role) {
        User user = new User();
        user.setId(id);
        user.setRole(role);
        return user;
    }

    private Order order(Long id, String orderNumber, User user, Order.OrderStatus status) {
        Order order = new Order();
        order.setId(id);
        order.setOrderNumber(orderNumber);
        order.setUser(user);
        order.setStatus(status);
        order.setPayableAmount(new BigDecimal("25.00"));
        OrderItem item = new OrderItem();
        item.setOrder(order);
        order.setOrderItems(List.of(item));
        return order;
    }

    private Order paidOrder(String orderNumber, String paymentMethod, String transactionId) {
        Order order = order(30L, orderNumber, user(7L, User.UserRole.STUDENT), Order.OrderStatus.PAID);
        order.getOrderItems().get(0).setPaymentMethod(paymentMethod);
        order.getOrderItems().get(0).setPaymentTransactionId(transactionId);
        order.getOrderItems().get(0).setPaymentTime(LocalDateTime.now());
        return order;
    }

    private Map<String, Object> callbackPayload(String orderNumber, String paymentMethod, String transactionId) {
        return Map.of(
            "orderNumber", orderNumber,
            "paymentMethod", paymentMethod,
            "transactionId", transactionId,
            "status", "PAID"
        );
    }

    private PaymentCallbackRecord callbackRecord(String provider,
                                                 String orderNumber,
                                                 String paymentMethod,
                                                 String transactionId,
                                                 PaymentCallbackRecord.ProcessStatus status) {
        PaymentCallbackRecord record = new PaymentCallbackRecord();
        record.setProvider(provider);
        record.setOrderNumber(orderNumber);
        record.setPaymentMethod(paymentMethod);
        record.setTransactionId(transactionId);
        record.setIdempotencyKey(provider + ":" + orderNumber + ":" + transactionId);
        record.setProcessStatus(status);
        record.setAttemptCount(1);
        return record;
    }

    private PaymentCallbackRecordRepository emptyCallbackRepository() {
        PaymentCallbackRecordRepository repository = mock(PaymentCallbackRecordRepository.class);
        when(repository.findByIdempotencyKey(any())).thenReturn(Optional.empty());
        when(repository.findFirstByOrderNumberAndProcessStatusOrderByProcessedAtDesc(any(), any())).thenReturn(Optional.empty());
        when(repository.save(any(PaymentCallbackRecord.class))).thenAnswer(invocation -> invocation.getArgument(0));
        return repository;
    }

    private String signature(String orderNumber, String paymentMethod, String transactionId, long timestamp, String secret) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] digest = mac.doFinal((orderNumber + "|" + paymentMethod + "|" + transactionId + "|" + timestamp).getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder(digest.length * 2);
        for (byte b : digest) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}
