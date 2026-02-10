package com.umutavci.thwscoinbackend.web.mensa.controller;

import com.umutavci.thwscoinbackend.infrastructure.config.JwtService;
import com.umutavci.thwscoinbackend.infrastructure.jpa.user.UserEntity;
import com.umutavci.thwscoinbackend.infrastructure.jpa.user.UserJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping({"/auth", "/api/auth"})
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authManager;
    private final JwtService jwtService;
    private final UserJpaRepository userRepo;

    @PostMapping("/login")
    public AuthResponse login(@RequestBody LoginRequest request) {
        String principal = resolvePrincipal(request);

        Authentication authentication = authManager.authenticate(
                new UsernamePasswordAuthenticationToken(principal, request.password())
        );

        UserEntity user = userRepo.findByUsername(principal)
                .orElseThrow();

        return new AuthResponse(
                jwtService.generateAccessToken(user),
                jwtService.generateRefreshToken(user)
        );
    }

    @PostMapping("/refresh")
    public AuthResponse refresh(@RequestBody RefreshRequest request) {
        String username = jwtService.extractUsername(request.refreshToken());

        UserEntity user = userRepo.findByUsername(username)
                .orElseThrow();

        return new AuthResponse(
                jwtService.generateAccessToken(user),
                jwtService.generateRefreshToken(user)
        );
    }

    private String resolvePrincipal(LoginRequest request) {
        if (request.username() != null && !request.username().isBlank()) {
            return request.username().trim();
        }
        if (request.knummer() != null && !request.knummer().isBlank()) {
            return request.knummer().trim();
        }
        throw new IllegalArgumentException("username or knummer is required");
    }

    public record LoginRequest(String username, String knummer, String password) {
    }

    public record AuthResponse(String accessToken, String refreshToken) {
    }

    public record RefreshRequest(String refreshToken) {
    }
}
