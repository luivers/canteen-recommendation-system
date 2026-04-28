package com.school.canteen.config;

import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.HeadersConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
@EnableCaching
@EnableMethodSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.csrf(AbstractHttpConfigurer::disable)
            .authorizeHttpRequests(authz -> authz
                // Public auth endpoints
                .requestMatchers("/api/users/login", "/api/users/register", "/api/users/test-connection").permitAll()

                // Public read APIs
                .requestMatchers(HttpMethod.GET,
                    "/api/dishes/**",
                    "/api/recommendations/**",
                    "/api/windows/**",
                    "/api/promotions/**",
                    "/api/combos/**",
                    "/api/notifications/public-announcements",
                    "/api/announcements",
                    "/api/canteens/**",
                    "/api/weather/**"
                ).permitAll()

                // Payment callback stays public, but must pass signature validation in controller
                .requestMatchers("/api/payments/callback").permitAll()

                // Write operations for these resources require manager/admin roles
                .requestMatchers(
                    "/api/dishes/**",
                    "/api/windows/**",
                    "/api/promotions/**",
                    "/api/canteens/**",
                    "/api/combos/**"
                ).hasAnyRole("ADMIN", "WINDOW_MANAGER")

                .requestMatchers("/api/admin/**").hasAnyRole("ADMIN", "WINDOW_MANAGER")
                .requestMatchers("/api/statistics/**").authenticated()
                .requestMatchers("/api/orders/**").authenticated()
                .requestMatchers("/api/payments/**").authenticated()
                .requestMatchers("/api/users/**").authenticated()

                .requestMatchers("/api/test/**").permitAll()
                .requestMatchers("/", "/index.html", "/static/**", "/public/**").permitAll()
                .requestMatchers("/uploads/**").permitAll()

                .requestMatchers("/api/**").authenticated()
                .anyRequest().authenticated()
            )
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .headers(headers -> headers.frameOptions(HeadersConfigurer.FrameOptionsConfig::disable))
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList(
            "http://localhost:*",
            "http://127.0.0.1:*",
            "null"
        ));
        configuration.setAllowedMethods(Arrays.asList(
            "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH", "HEAD"
        ));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        configuration.setExposedHeaders(Arrays.asList(
            "Authorization",
            "Content-Type",
            "Content-Length",
            "X-Requested-With",
            "Accept",
            "Access-Control-Allow-Origin",
            "Access-Control-Allow-Credentials"
        ));
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
