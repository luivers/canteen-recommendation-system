package com.school.canteen.service.miniapp;

import com.school.canteen.config.JwtUtils;
import com.school.canteen.entity.User;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.service.miniapp.dto.MiniAppLoginResponse;
import com.school.canteen.service.miniapp.dto.MiniAppSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MiniAppAuthService {

    private final MiniAppCodeSessionService codeSessionService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;

    @Transactional
    public MiniAppLoginResponse loginWithCode(String code) {
        MiniAppSession session = codeSessionService.exchangeCode(code);
        String openid = session.getOpenid();

        User user = userRepository.findByMiniappOpenid(openid).orElse(null);
        boolean isNewUser = false;
        if (user == null) {
            user = createMiniAppStudent(openid);
            isNewUser = true;
        }

        if ("inactive".equalsIgnoreCase(user.getStatus())) {
            throw new BusinessException("MINIAPP_USER_DISABLED", HttpStatus.FORBIDDEN, "账户已被禁用，请联系管理员");
        }

        String token = jwtUtils.generateToken(user.getId(), user.getUsername(), user.getRole().name());
        return MiniAppLoginResponse.of(token, user, isNewUser);
    }

    private User createMiniAppStudent(String openid) {
        String suffix = shortHash(openid);
        User user = new User();
        user.setMiniappOpenid(openid);
        user.setStudentId(nextUniqueValue("WX_" + suffix, userRepository::existsByStudentId));
        user.setUsername(nextUniqueValue("微信用户" + suffix.substring(0, 6), userRepository::existsByUsername));
        user.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));
        user.setRole(User.UserRole.STUDENT);
        user.setStatus("active");
        user.setPoints(0);
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        return userRepository.save(user);
    }

    private String nextUniqueValue(String base, java.util.function.Predicate<String> exists) {
        String value = base;
        int index = 1;
        while (exists.test(value)) {
            value = base + "_" + index;
            index++;
        }
        return value;
    }

    private String shortHash(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(value.getBytes(StandardCharsets.UTF_8))).substring(0, 12);
        } catch (Exception e) {
            throw new BusinessException("MINIAPP_HASH_FAILED", HttpStatus.INTERNAL_SERVER_ERROR, "生成小程序用户标识失败");
        }
    }
}
