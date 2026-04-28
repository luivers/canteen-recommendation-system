package com.school.canteen.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

/**
 * JWT 认证过滤器
 * <p>拦截每个请求，从 Authorization 头中解析 JWT 令牌，
 * 验证通过后将用户身份写入 SecurityContext</p>
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    
    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);
    
    private final JwtUtils jwtUtils;
    
    public JwtAuthenticationFilter(@Value("${jwt.secret}") @NonNull String jwtSecret, @NonNull JwtUtils jwtUtils) {
        this.jwtUtils = jwtUtils;
        logger.info("JWT Filter initialized with secret key length: {}", jwtSecret.length());
    }
    
    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {
        
        try {
            // 获取请求信息
            String requestUri = request.getRequestURI() != null ? request.getRequestURI() : "";
            String fullUrl = request.getRequestURL().toString();
            String queryString = request.getQueryString();
            String method = request.getMethod();
            
            // 打印详细调试信息
            logger.debug("==== JWT FILTER DEBUG ====");
            logger.debug("[Request Info] Method: {}", method);
            logger.debug("[Request Info] URI: {}", requestUri);
            logger.debug("[Request Info] Full URL: {}", fullUrl);
            logger.debug("[Request Info] Query String: {}", (queryString != null ? queryString : "null"));
            logger.debug("[Request Info] Authorization Header: {}", request.getHeader("Authorization"));
            
            // 检查是否为公开端点
            boolean isPublicEndpoint = isPublicEndpoint(requestUri);
            logger.debug("[Endpoint Check] Is Public: {}", isPublicEndpoint);
            
            // 无论是否为公开端点，都尝试验证JWT token（如果存在）
            // 这样公开端点也可以获取用户信息（用于个性化显示）
            String authorizationHeader = request.getHeader("Authorization");
            
            if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
                String token = authorizationHeader.substring(7);
                logger.debug("[Token] Found token: {}...", token.substring(0, Math.min(10, token.length())));
                
                try {
                    // 使用JwtUtils验证token
                    boolean isValid = jwtUtils.validateToken(token);
                    logger.debug("[Token] Validation result: {}", isValid);
                    
                    if (isValid) {
                        // 从token中获取用户信息
                        Long userId = jwtUtils.getUserIdFromToken(token);
                        String role = jwtUtils.getRoleFromToken(token);
                        logger.debug("[Token] Extracted userId: {}", userId);
                        logger.debug("[Token] Extracted role: {}", role);
                        
                        // 创建认证对象，使用实际角色
                        UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                                userId.toString(), null, 
                                Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + role)));
                        
                        // 设置认证到安全上下文
                        SecurityContextHolder.getContext().setAuthentication(authToken);
                        logger.debug("[Authentication] Set in SecurityContext with role: ROLE_{}", role);
                    } else {
                        logger.debug("[Token] Token is invalid");
                    }
                } catch (Exception e) {
                    logger.error("[Token] Error during validation: {}", e.getMessage(), e);
                }
            } else {
                logger.debug("[Token] No valid Authorization header found");
            }
            
            // 对于公开端点，即使没有token也允许访问
            // 对于非公开端点，如果没有有效的认证信息，Spring Security会在后续拦截
            if (isPublicEndpoint) {
                logger.debug("[ACCESS GRANTED] Public endpoint, allowing access");
            } else {
                logger.debug("[AUTHENTICATION] Protected endpoint, authentication required");
            }
            
            // 继续过滤链
            logger.debug("[Filter] Continuing filter chain");
            filterChain.doFilter(request, response);
            
        } catch (Exception e) {
            logger.error("==== JWT FILTER ERROR ====");
            logger.error("[Error] Unexpected error: {}", e.getMessage(), e);
            // 即使发生错误，也继续过滤链
            filterChain.doFilter(request, response);
        } finally {
            logger.debug("==== END JWT FILTER DEBUG ====\n");
        }
    }
    
    /**
     * 检查是否为公开端点
     */
    private boolean isPublicEndpoint(@NonNull String requestUri) {
        // 打印所有URI的检查日志
        logger.debug("[Endpoint Check] Checking: {}", requestUri);
        
        // 公开端点列表
        // 登录、注册和测试连接端点设为公开
        if (requestUri.equals("/api/users/login") || 
                requestUri.equals("/api/users/register") || 
                requestUri.equals("/api/users/test-connection")) {
            logger.debug("[Endpoint Check] MATCH: User public endpoint");
            return true;
        }
        
        // 公开的业务API
        if (requestUri.startsWith("/api/dishes") || requestUri.startsWith("/api/recommendations") || 
            requestUri.startsWith("/api/windows") || 
            requestUri.startsWith("/api/promotions") || requestUri.startsWith("/api/combos") ||
            requestUri.startsWith("/api/notifications/public-announcements")) {
            logger.debug("[Endpoint Check] MATCH: Public business API");
            return true;
        }
        
        // 购物车API允许公开访问
        if (requestUri.startsWith("/api/orders/cart")) {
            logger.debug("[Endpoint Check] MATCH: Cart endpoint");
            return true;
        }
        
        // 订单查询API允许公开访问（GET请求，不包括修改操作）
        if (requestUri.equals("/api/orders")) {
            logger.debug("[Endpoint Check] MATCH: Orders list endpoint");
            return true;
        }
        
        // 订单详情查询允许公开访问（GET请求，格式为 /api/orders/{id}）
        if (requestUri.matches("/api/orders/\\d+$")) {
            logger.debug("[Endpoint Check] MATCH: Order detail endpoint");
            return true;
        }
        
        // 测试接口设为公开
        if (requestUri.startsWith("/api/test")) {
            logger.debug("[Endpoint Check] MATCH: Test endpoint");
            return true;
        }
        
        // 允许静态资源访问
        if (requestUri.equals("/") || 
                requestUri.equals("/index.html") || 
                requestUri.startsWith("/static/") || 
                requestUri.startsWith("/public/")) {
            logger.debug("[Endpoint Check] MATCH: Static resource");
            return true;
        }
        
        logger.debug("[Endpoint Check] NO MATCH: Protected endpoint");
        return false;
    }
}