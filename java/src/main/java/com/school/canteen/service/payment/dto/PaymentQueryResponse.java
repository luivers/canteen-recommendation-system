package com.school.canteen.service.payment.dto;

import com.school.canteen.service.payment.enums.PaymentStatus;
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
public class PaymentQueryResponse {
    private String mode;
    private String provider;
    private Long orderId;
    private String orderNumber;
    private String paymentMethod;
    private String transactionId;
    private PaymentStatus providerStatus;
    private String localStatus;
    private LocalDateTime paymentTime;
    private LocalDateTime queryTime;
    private Map<String, Object> rawProviderResponse;
}
