package com.school.canteen.service.miniapp.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "miniapp")
@Data
public class MiniAppProperties {

    private String mode = "mock";
    private String appId = "";
    private String appSecret = "";
    private Mock mock = new Mock();

    public boolean isMockMode() {
        return !"wechat".equalsIgnoreCase(mode);
    }

    @Data
    public static class Mock {
        private String openidPrefix = "mock-openid-";
    }
}
