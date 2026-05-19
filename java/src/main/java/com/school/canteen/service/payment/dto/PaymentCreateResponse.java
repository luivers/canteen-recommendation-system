package com.school.canteen.service.payment.dto;

import com.school.canteen.service.payment.enums.PaymentStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentCreateResponse {
    private String mode;
    private String provider;
    private Long orderId;
    private String orderNumber;
    private BigDecimal amount;
    private String paymentMethod;
    private String transactionId;
    private PaymentStatus status;
    private String qrCodeUrl;
    private String redirectUrl;
    private Map<String, Object> miniProgramParams;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
}
