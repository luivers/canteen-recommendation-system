package com.school.canteen.controller;

import com.school.canteen.entity.Order;
import com.school.canteen.entity.User;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final OrderService orderService;
    private final UserRepository userRepository;

    @Value("${payment.callback-secret:}")
    private String callbackSecret;

    @Value("${payment.callback-timeout-seconds:300}")
    private long callbackTimeoutSeconds;

    private User getCurrentUser() {
        return com.school.canteen.util.SecurityUtils.getCurrentUser(userRepository);
    }

    private boolean isAdminOrManager(User user) {
        if (user == null || user.getRole() == null) {
            return false;
        }
        return user.getRole() == User.UserRole.ADMIN || user.getRole() == User.UserRole.WINDOW_MANAGER;
    }

    private boolean canAccessOrder(User user, Order order) {
        if (user == null || order == null) {
            return false;
        }
        if (isAdminOrManager(user)) {
            return true;
        }
        return order.getUser() != null && Objects.equals(order.getUser().getId(), user.getId());
    }

    private LocalDateTime parsePaidAt(Object paidAtObj) {
        LocalDateTime paidAt = LocalDateTime.now();
        if (!(paidAtObj instanceof String paidAtStr)) {
            return paidAt;
        }
        try {
            return java.time.ZonedDateTime.parse(paidAtStr)
                .withZoneSameInstant(java.time.ZoneId.systemDefault())
                .toLocalDateTime();
        } catch (Exception ignore) {
            try {
                return LocalDateTime.parse(paidAtStr);
            } catch (Exception ignored) {
                return paidAt;
            }
        }
    }

    private String normalizeValue(Object value) {
        if (value == null) {
            return null;
        }
        String text = String.valueOf(value).trim();
        return text.isEmpty() || "null".equalsIgnoreCase(text) ? null : text;
    }

    private boolean verifyCallbackSignature(String orderNumber,
                                            String paymentMethod,
                                            String transactionId,
                                            String timestampHeader,
                                            String signatureHeader) {
        if (callbackSecret == null || callbackSecret.isBlank()) {
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
        if (Math.abs(nowSeconds - timestampSeconds) > callbackTimeoutSeconds) {
            return false;
        }

        String payload = orderNumber + "|" + paymentMethod + "|" + transactionId + "|" + timestampSeconds;
        String expected = hmacSha256Hex(payload, callbackSecret);
        if (expected == null) {
            return false;
        }
        return MessageDigest.isEqual(
            expected.getBytes(StandardCharsets.UTF_8),
            signatureHeader.trim().toLowerCase().getBytes(StandardCharsets.UTF_8)
        );
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

    @PostMapping("/callback")
    public ResponseEntity<?> paymentCallback(@RequestBody Map<String, Object> payload,
                                             @RequestHeader(value = "X-Payment-Timestamp", required = false) String timestampHeader,
                                             @RequestHeader(value = "X-Payment-Signature", required = false) String signatureHeader) {
        try {
            String orderNumber = normalizeValue(payload.get("orderNumber"));
            String paymentMethod = normalizeValue(payload.get("paymentMethod"));
            String transactionId = normalizeValue(payload.get("transactionId"));
            if (orderNumber == null || paymentMethod == null || transactionId == null) {
                return ResponseEntity.badRequest().body(Map.of("message", "missing required payment callback fields"));
            }

            if (!verifyCallbackSignature(orderNumber, paymentMethod, transactionId, timestampHeader, signatureHeader)) {
                return ResponseEntity.status(403).body(Map.of("message", "invalid callback signature"));
            }

            LocalDateTime paidAt = parsePaidAt(payload.get("paidAt"));
            Order updated = orderService.markOrderPaidByNumber(orderNumber, paymentMethod, transactionId, paidAt);

            String updatedPaymentMethod = "UNKNOWN";
            String updatedTransactionId = "";
            LocalDateTime updatedPaymentTime = null;
            if (updated.getOrderItems() != null && !updated.getOrderItems().isEmpty()) {
                var item = updated.getOrderItems().get(0);
                if (item.getPaymentMethod() != null) {
                    updatedPaymentMethod = item.getPaymentMethod();
                }
                if (item.getPaymentTransactionId() != null) {
                    updatedTransactionId = item.getPaymentTransactionId();
                }
                updatedPaymentTime = item.getPaymentTime();
            }

            return ResponseEntity.ok(Map.of(
                "orderId", updated.getId(),
                "orderNumber", updated.getOrderNumber(),
                "status", updated.getStatus().name(),
                "paymentMethod", updatedPaymentMethod,
                "transactionId", updatedTransactionId,
                "paymentTime", updatedPaymentTime != null ? updatedPaymentTime : ""
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/orders/{orderId}/success")
    public ResponseEntity<?> markPaid(@PathVariable Long orderId, @RequestBody Map<String, Object> payload) {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }

            Order targetOrder = orderService.getOrderById(orderId);
            if (!canAccessOrder(currentUser, targetOrder)) {
                return ResponseEntity.status(403).build();
            }

            String paymentMethod = normalizeValue(payload.getOrDefault("paymentMethod", "UNKNOWN"));
            String transactionId = normalizeValue(payload.getOrDefault("transactionId", ""));
            if (paymentMethod == null) {
                paymentMethod = "UNKNOWN";
            }
            if (transactionId == null) {
                transactionId = "";
            }
            LocalDateTime paidAt = parsePaidAt(payload.get("paidAt"));

            Order updated = orderService.markOrderPaid(orderId, paymentMethod, transactionId, paidAt);

            String updatedPaymentMethod = "UNKNOWN";
            String updatedTransactionId = "";
            LocalDateTime updatedPaymentTime = null;
            if (updated.getOrderItems() != null && !updated.getOrderItems().isEmpty()) {
                var item = updated.getOrderItems().get(0);
                if (item.getPaymentMethod() != null) {
                    updatedPaymentMethod = item.getPaymentMethod();
                }
                if (item.getPaymentTransactionId() != null) {
                    updatedTransactionId = item.getPaymentTransactionId();
                }
                updatedPaymentTime = item.getPaymentTime();
            }

            return ResponseEntity.ok(Map.of(
                "orderId", updated.getId(),
                "orderNumber", updated.getOrderNumber(),
                "status", updated.getStatus().name(),
                "paymentMethod", updatedPaymentMethod,
                "transactionId", updatedTransactionId,
                "paymentTime", updatedPaymentTime != null ? updatedPaymentTime : ""
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }
}
