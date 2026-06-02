package com.school.canteen.service.miniapp;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.service.miniapp.config.MiniAppProperties;
import com.school.canteen.service.miniapp.dto.MiniAppSession;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class MiniAppCodeSessionServiceTest {

    @Test
    void mockModeReturnsStableOpenidForSameCode() {
        MiniAppProperties properties = new MiniAppProperties();
        properties.getMock().setOpenidPrefix("mock-");
        MiniAppCodeSessionService service = new MiniAppCodeSessionService(properties, new ObjectMapper());

        MiniAppSession first = service.exchangeCode("wx-code-001");
        MiniAppSession second = service.exchangeCode("wx-code-001");

        assertEquals(first.getOpenid(), second.getOpenid());
        assertTrue(first.getOpenid().startsWith("mock-"));
        assertTrue(first.getSessionKey().startsWith("mock-session-"));
    }

    @Test
    void rejectsBlankCode() {
        MiniAppCodeSessionService service = new MiniAppCodeSessionService(new MiniAppProperties(), new ObjectMapper());

        BusinessException exception = assertThrows(BusinessException.class, () -> service.exchangeCode(" "));

        assertEquals("MINIAPP_CODE_EMPTY", exception.getCode());
    }

    @Test
    void wechatModeRequiresAppCredentials() {
        MiniAppProperties properties = new MiniAppProperties();
        properties.setMode("wechat");
        MiniAppCodeSessionService service = new MiniAppCodeSessionService(properties, new ObjectMapper());

        BusinessException exception = assertThrows(BusinessException.class, () -> service.exchangeCode("real-code"));

        assertEquals("MINIAPP_WECHAT_CONFIG_MISSING", exception.getCode());
    }
}
