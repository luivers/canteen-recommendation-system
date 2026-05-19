package com.school.canteen.service.payment.config;

import com.school.canteen.service.payment.enums.PaymentMode;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "payment")
@Data
public class PaymentProperties {

    private String mode = "mock";
    private String callbackSecret = "";
    private long callbackTimeoutSeconds = 300;
    private Mock mock = new Mock();

    public PaymentMode resolvedMode() {
        return PaymentMode.from(mode);
    }

    @Data
    public static class Mock {
        private boolean enabled = true;
        private String qrCodeUrl = "mock://canteen-payment";
        private String redirectUrl = "";
    }
}
