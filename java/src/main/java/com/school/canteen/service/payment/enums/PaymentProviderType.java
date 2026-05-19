package com.school.canteen.service.payment.enums;

import java.util.Locale;

public enum PaymentProviderType {
    MOCK,
    WECHAT_SANDBOX,
    ALIPAY_SANDBOX;

    public static PaymentProviderType fromPaymentMethod(String paymentMethod) {
        if (paymentMethod == null || paymentMethod.isBlank()) {
            return WECHAT_SANDBOX;
        }
        String normalized = paymentMethod.trim().replace("-", "_").toUpperCase(Locale.ROOT);
        if (normalized.contains("ALIPAY")) {
            return ALIPAY_SANDBOX;
        }
        if (normalized.contains("WECHAT") || normalized.contains("WX")) {
            return WECHAT_SANDBOX;
        }
        return WECHAT_SANDBOX;
    }
}
