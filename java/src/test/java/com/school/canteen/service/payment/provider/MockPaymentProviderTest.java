package com.school.canteen.service.payment.provider;

import com.school.canteen.service.payment.config.PaymentProperties;
import com.school.canteen.service.payment.dto.PaymentCallbackPayload;
import com.school.canteen.service.payment.dto.PaymentCreateRequest;
import com.school.canteen.service.payment.dto.PaymentCreateResponse;
import com.school.canteen.service.payment.enums.PaymentStatus;
import org.junit.jupiter.api.Test;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class MockPaymentProviderTest {

    @Test
    void createPaymentBuildsTraceableMockPayload() {
        PaymentProperties properties = new PaymentProperties();
        properties.getMock().setQrCodeUrl("mock://pay");
        MockPaymentProvider provider = new MockPaymentProvider(properties);

        PaymentCreateResponse response = provider.createPayment(PaymentCreateRequest.builder()
            .orderId(10L)
            .orderNumber("ORD1001")
            .amount(new BigDecimal("18.50"))
            .paymentMethod("WECHAT")
            .userId(3L)
            .build());

        assertEquals("MOCK", response.getProvider());
        assertEquals(PaymentStatus.CREATED, response.getStatus());
        assertTrue(response.getTransactionId().startsWith("MOCK-ORD1001-"));
        assertEquals("mock://pay/ORD1001", response.getQrCodeUrl());
        assertEquals(true, response.getMiniProgramParams().get("mock"));
        assertTrue(response.getExpiresAt().isAfter(response.getCreatedAt()));
    }

    @Test
    void verifyCallbackRejectsInvalidSignatureAndParsesValidPayload() throws Exception {
        PaymentProperties properties = new PaymentProperties();
        properties.setCallbackSecret("secret-for-test");
        MockPaymentProvider provider = new MockPaymentProvider(properties);
        long timestamp = System.currentTimeMillis() / 1000;
        Map<String, Object> payload = Map.of(
            "orderNumber", "ORD1002",
            "paymentMethod", "WECHAT",
            "transactionId", "MOCK-ORD1002-1",
            "status", "PAID"
        );
        String signature = hmacSha256Hex("ORD1002|WECHAT|MOCK-ORD1002-1|" + timestamp, properties.getCallbackSecret());

        assertFalse(provider.verifyCallback(payload, String.valueOf(timestamp), "bad-signature"));
        assertTrue(provider.verifyCallback(payload, String.valueOf(timestamp), signature));

        PaymentCallbackPayload callback = provider.parseCallback(payload);
        assertEquals("ORD1002", callback.getOrderNumber());
        assertEquals("WECHAT", callback.getPaymentMethod());
        assertEquals("MOCK-ORD1002-1", callback.getTransactionId());
        assertEquals("PAID", callback.getPaymentStatus());
    }

    @Test
    void parseCallbackMapsFailedSuccessSignal() {
        PaymentProperties properties = new PaymentProperties();
        MockPaymentProvider provider = new MockPaymentProvider(properties);

        PaymentCallbackPayload callback = provider.parseCallback(Map.of(
            "orderNumber", "ORD1003",
            "paymentMethod", "WECHAT",
            "transactionId", "MOCK-ORD1003-1",
            "success", false
        ));

        assertEquals("FAILED", callback.getPaymentStatus());
    }

    private String hmacSha256Hex(String data, String secret) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] digest = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder(digest.length * 2);
        for (byte b : digest) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}
