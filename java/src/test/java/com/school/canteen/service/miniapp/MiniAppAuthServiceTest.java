package com.school.canteen.service.miniapp;

import com.school.canteen.config.JwtUtils;
import com.school.canteen.entity.User;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.service.miniapp.dto.MiniAppLoginResponse;
import com.school.canteen.service.miniapp.dto.MiniAppSession;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class MiniAppAuthServiceTest {

    @Test
    void createsStudentUserAndReturnsJwtForFirstLogin() {
        MiniAppCodeSessionService codeSessionService = mock(MiniAppCodeSessionService.class);
        UserRepository userRepository = mock(UserRepository.class);
        PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
        JwtUtils jwtUtils = mock(JwtUtils.class);
        MiniAppAuthService service = new MiniAppAuthService(codeSessionService, userRepository, passwordEncoder, jwtUtils);

        when(codeSessionService.exchangeCode("code-a")).thenReturn(new MiniAppSession("openid-a", "session-a"));
        when(userRepository.findByMiniappOpenid("openid-a")).thenReturn(Optional.empty());
        when(userRepository.existsByStudentId(any())).thenReturn(false);
        when(userRepository.existsByUsername(any())).thenReturn(false);
        when(passwordEncoder.encode(any())).thenReturn("encoded-password");
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User user = invocation.getArgument(0);
            user.setId(101L);
            return user;
        });
        when(jwtUtils.generateToken(eq(101L), any(), eq("STUDENT"))).thenReturn("jwt-token");

        MiniAppLoginResponse response = service.loginWithCode("code-a");

        assertEquals("jwt-token", response.getToken());
        assertTrue(response.isNewUser());
        assertEquals(101L, response.getUser().getId());
        assertEquals("STUDENT", response.getUser().getRole());
        verify(userRepository).save(any(User.class));
    }

    @Test
    void reusesExistingUserForSameOpenid() {
        MiniAppCodeSessionService codeSessionService = mock(MiniAppCodeSessionService.class);
        UserRepository userRepository = mock(UserRepository.class);
        PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
        JwtUtils jwtUtils = mock(JwtUtils.class);
        MiniAppAuthService service = new MiniAppAuthService(codeSessionService, userRepository, passwordEncoder, jwtUtils);
        User existing = user(8L, "openid-b", "active");

        when(codeSessionService.exchangeCode("code-b")).thenReturn(new MiniAppSession("openid-b", "session-b"));
        when(userRepository.findByMiniappOpenid("openid-b")).thenReturn(Optional.of(existing));
        when(jwtUtils.generateToken(8L, "微信用户", "STUDENT")).thenReturn("jwt-existing");

        MiniAppLoginResponse response = service.loginWithCode("code-b");

        assertEquals("jwt-existing", response.getToken());
        assertFalse(response.isNewUser());
        assertEquals(8L, response.getUser().getId());
    }

    @Test
    void rejectsInactiveMiniappUser() {
        MiniAppCodeSessionService codeSessionService = mock(MiniAppCodeSessionService.class);
        UserRepository userRepository = mock(UserRepository.class);
        MiniAppAuthService service = new MiniAppAuthService(
                codeSessionService,
                userRepository,
                mock(PasswordEncoder.class),
                mock(JwtUtils.class)
        );

        when(codeSessionService.exchangeCode("code-c")).thenReturn(new MiniAppSession("openid-c", "session-c"));
        when(userRepository.findByMiniappOpenid("openid-c")).thenReturn(Optional.of(user(9L, "openid-c", "inactive")));

        BusinessException exception = assertThrows(BusinessException.class, () -> service.loginWithCode("code-c"));

        assertEquals("MINIAPP_USER_DISABLED", exception.getCode());
    }

    private User user(Long id, String openid, String status) {
        User user = new User();
        user.setId(id);
        user.setMiniappOpenid(openid);
        user.setStudentId("WX_TEST");
        user.setUsername("微信用户");
        user.setRole(User.UserRole.STUDENT);
        user.setStatus(status);
        user.setPoints(0);
        return user;
    }
}
