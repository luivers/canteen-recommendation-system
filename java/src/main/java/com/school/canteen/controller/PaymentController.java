package com.school.canteen.controller;

import com.school.canteen.entity.User;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.service.payment.PaymentApplicationService;
import com.school.canteen.service.payment.dto.PaymentCompletionResponse;
import com.school.canteen.service.payment.dto.PaymentCreateResponse;
import com.school.canteen.service.payment.dto.PaymentQueryResponse;
import com.school.canteen.util.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentApplicationService paymentApplicationService;
    private final UserRepository userRepository;

    private User getCurrentUser() {
        return SecurityUtils.getCurrentUser(userRepository);
    }

    @PostMapping("/orders/{orderId}/create")
    public ResponseEntity<PaymentCreateResponse> createPayment(@PathVariable Long orderId,
                                                               @RequestBody(required = false) Map<String, Object> payload) {
        return ResponseEntity.ok(paymentApplicationService.createPayment(
            orderId,
            resolvePaymentMethod(payload),
            getCurrentUser()
        ));
    }

    @GetMapping("/orders/{orderId}/status")
    public ResponseEntity<PaymentQueryResponse> queryPaymentStatus(@PathVariable Long orderId) {
        return ResponseEntity.ok(paymentApplicationService.queryPaymentStatus(orderId, getCurrentUser()));
    }

    @PostMapping("/callback")
    public ResponseEntity<PaymentCompletionResponse> paymentCallback(@RequestBody Map<String, Object> payload,
                                                                     @RequestHeader(value = "X-Payment-Timestamp", required = false) String timestampHeader,
                                                                     @RequestHeader(value = "X-Payment-Signature", required = false) String signatureHeader) {
        return ResponseEntity.ok(paymentApplicationService.handleCallback(payload, timestampHeader, signatureHeader));
    }

    @PostMapping("/orders/{orderId}/success")
    public ResponseEntity<PaymentCompletionResponse> markPaid(@PathVariable Long orderId,
                                                              @RequestBody(required = false) Map<String, Object> payload) {
        return ResponseEntity.ok(paymentApplicationService.completeMockPayment(orderId, payload, getCurrentUser()));
    }

    private String resolvePaymentMethod(Map<String, Object> payload) {
        if (payload == null || payload.get("paymentMethod") == null) {
            return "WECHAT";
        }
        String value = String.valueOf(payload.get("paymentMethod")).trim();
        return value.isEmpty() || "null".equalsIgnoreCase(value) ? "WECHAT" : value;
    }
}
