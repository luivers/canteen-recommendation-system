package com.school.canteen.service.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentCompletionResponse {
    private String mode;
    private String provider;
    private Long orderId;
    private String orderNumber;
    private String status;
    private String paymentMethod;
    private String transactionId;
    private LocalDateTime paymentTime;
    private String idempotencyKey;
    private String callbackProcessStatus;
    private Boolean duplicateCallback;
}
