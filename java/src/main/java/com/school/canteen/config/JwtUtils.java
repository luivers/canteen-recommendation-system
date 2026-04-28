package com.school.canteen.config;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

@Component
public class JwtUtils {

    private final Key secretKey;
    private final long expirationTime;

    public JwtUtils(@Value("${jwt.secret}") String jwtSecret,
                    @Value("${jwt.expiration:86400000}") long expirationTime) {
        this.secretKey = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
        this.expirationTime = expirationTime;
    }

    public String generateToken(Long userId, String username, String role) {
        return Jwts.builder()
            .setSubject(userId.toString())
            .claim("username", username)
            .claim("role", role)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + expirationTime))
            .signWith(secretKey)
            .compact();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(secretKey).build().parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public Long getUserIdFromToken(String token) {
        String userId = Jwts.parserBuilder().setSigningKey(secretKey).build()
            .parseClaimsJws(token).getBody().getSubject();
        return Long.parseLong(userId);
    }

    public String getRoleFromToken(String token) {
        return Jwts.parserBuilder().setSigningKey(secretKey).build()
            .parseClaimsJws(token).getBody().get("role", String.class);
    }
}
