package com.school.canteen.service.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentCallbackPayload {
    private String provider;
    private String notificationId;
    private String orderNumber;
    private String paymentMethod;
    private String transactionId;
    private String paymentStatus;
    private LocalDateTime paidAt;
    private Map<String, Object> rawPayload;
}
