package com.school.canteen.service.miniapp;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.service.miniapp.config.MiniAppProperties;
import com.school.canteen.service.miniapp.dto.MiniAppSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Duration;
import java.util.HexFormat;

@Service
@RequiredArgsConstructor
public class MiniAppCodeSessionService {

    private static final String CODE_SESSION_URL = "https://api.weixin.qq.com/sns/jscode2session";

    private final MiniAppProperties properties;
    private final ObjectMapper objectMapper;

    public MiniAppSession exchangeCode(String code) {
        String normalizedCode = normalizeCode(code);
        if (properties.isMockMode()) {
            return createMockSession(normalizedCode);
        }
        return exchangeWithWechat(normalizedCode);
    }

    private String normalizeCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            throw new BusinessException("MINIAPP_CODE_EMPTY", HttpStatus.BAD_REQUEST, "小程序登录 code 不能为空");
        }
        return code.trim();
    }

    private MiniAppSession createMockSession(String code) {
        String hash = sha256(code).substring(0, 16);
        return new MiniAppSession(properties.getMock().getOpenidPrefix() + hash, "mock-session-" + hash);
    }

    private MiniAppSession exchangeWithWechat(String code) {
        if (isBlank(properties.getAppId()) || isBlank(properties.getAppSecret())) {
            throw new BusinessException(
                    "MINIAPP_WECHAT_CONFIG_MISSING",
                    HttpStatus.BAD_REQUEST,
                    "微信小程序 AppID 或 AppSecret 未配置"
            );
        }

        URI uri = UriComponentsBuilder.fromHttpUrl(CODE_SESSION_URL)
                .queryParam("appid", properties.getAppId())
                .queryParam("secret", properties.getAppSecret())
                .queryParam("js_code", code)
                .queryParam("grant_type", "authorization_code")
                .build()
                .toUri();

        try {
            HttpRequest request = HttpRequest.newBuilder(uri)
                    .timeout(Duration.ofSeconds(8))
                    .GET()
                    .build();
            HttpResponse<String> response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new BusinessException("MINIAPP_CODE_SESSION_FAILED", HttpStatus.BAD_GATEWAY, "微信登录凭证换取失败");
            }
            return parseWechatSession(response.body());
        } catch (IOException e) {
            throw new BusinessException("MINIAPP_CODE_SESSION_FAILED", HttpStatus.BAD_GATEWAY, "微信登录凭证换取失败");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new BusinessException("MINIAPP_CODE_SESSION_FAILED", HttpStatus.BAD_GATEWAY, "微信登录凭证换取被中断");
        }
    }

    private MiniAppSession parseWechatSession(String body) throws IOException {
        JsonNode root = objectMapper.readTree(body);
        if (root.has("errcode") && root.path("errcode").asInt() != 0) {
            String message = root.path("errmsg").asText("微信登录凭证无效");
            throw new BusinessException("MINIAPP_CODE_SESSION_FAILED", HttpStatus.BAD_REQUEST, message);
        }
        String openid = root.path("openid").asText("");
        if (openid.isBlank()) {
            throw new BusinessException("MINIAPP_OPENID_EMPTY", HttpStatus.BAD_GATEWAY, "微信登录响应缺少 openid");
        }
        return new MiniAppSession(openid, root.path("session_key").asText(""));
    }

    private String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new BusinessException("MINIAPP_HASH_FAILED", HttpStatus.INTERNAL_SERVER_ERROR, "生成小程序用户标识失败");
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
