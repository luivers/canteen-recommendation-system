package com.school.canteen.service.payment.enums;

import java.util.Locale;

public enum PaymentMode {
    MOCK,
    SANDBOX;

    public static PaymentMode from(String value) {
        if (value == null || value.isBlank()) {
            return MOCK;
        }
        String normalized = value.trim().replace("-", "_").toUpperCase(Locale.ROOT);
        if ("MOCK".equals(normalized)) {
            return MOCK;
        }
        if ("SANDBOX".equals(normalized)
                || "WECHAT_SANDBOX".equals(normalized)
                || "ALIPAY_SANDBOX".equals(normalized)) {
            return SANDBOX;
        }
        throw new IllegalArgumentException("Unsupported payment mode: " + value);
    }
}
