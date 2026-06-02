package com.school.canteen.controller;

import com.school.canteen.service.miniapp.MiniAppAuthService;
import com.school.canteen.service.miniapp.dto.MiniAppLoginRequest;
import com.school.canteen.service.miniapp.dto.MiniAppLoginResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/miniapp")
@RequiredArgsConstructor
public class MiniAppAuthController {

    private final MiniAppAuthService miniAppAuthService;

    @PostMapping("/login")
    public ResponseEntity<Map<String, MiniAppLoginResponse>> login(@RequestBody MiniAppLoginRequest request) {
        MiniAppLoginResponse response = miniAppAuthService.loginWithCode(request == null ? null : request.getCode());
        return ResponseEntity.ok(Map.of("data", response));
    }
}
