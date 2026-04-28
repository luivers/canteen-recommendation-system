package com.school.canteen.controller;

import com.school.canteen.entity.CartItem;
import com.school.canteen.entity.User;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.service.CartService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/** 购物车控制器 — 购物车的增删改查 */
@RestController
@RequestMapping("/api/orders/cart")
@RequiredArgsConstructor
public class CartController {

    private static final Logger logger = LoggerFactory.getLogger(CartController.class);
    
    private final CartService cartService;
    private final UserRepository userRepository;

    /**
     * 获取当前登录用户
     */
    private User getCurrentUser() {
        return com.school.canteen.util.SecurityUtils.getCurrentUser(userRepository);
    }

    /**
     * 获取购物车
     */
    @GetMapping
    public ResponseEntity<?> getCart() {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }
            List<CartItem> cartItems = cartService.getCartItems(currentUser);
            return ResponseEntity.ok(cartItems);
        } catch (Exception e) {
            logger.error("获取购物车失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 添加菜品到购物车
     */
    @PostMapping
    public ResponseEntity<?> addToCart(@RequestBody Map<String, Object> cartItem) {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }
            
            // 获取菜品ID和数量，添加空值检查
            Object dishIdObj = cartItem.get("dishId");
            Object comboIdObj = cartItem.get("comboId");
            Object quantityObj = cartItem.get("quantity");
            
            if ((dishIdObj == null && comboIdObj == null) || quantityObj == null) {
                return ResponseEntity.badRequest().body(Map.of(
                    "message", "商品ID和数量不能为空",
                    "code", "INVALID_REQUEST"
                ));
            }
            
            try {
                Integer quantity = quantityObj instanceof Number ? ((Number) quantityObj).intValue() : Integer.parseInt(quantityObj.toString());
                
                // 验证数量必须大于0
                if (quantity <= 0) {
                    return ResponseEntity.badRequest().body(Map.of(
                        "message", "数量必须大于0",
                        "code", "INVALID_QUANTITY"
                    ));
                }

                if (comboIdObj != null) {
                    Long comboId = comboIdObj instanceof Number ? ((Number) comboIdObj).longValue() : Long.parseLong(comboIdObj.toString());
                    CartItem newCartItem = cartService.addComboToCart(currentUser, comboId, quantity);
                    return ResponseEntity.ok(newCartItem);
                } else {
                    Long dishId = dishIdObj instanceof Number ? ((Number) dishIdObj).longValue() : Long.parseLong(dishIdObj.toString());
                    CartItem newCartItem = cartService.addToCart(currentUser, dishId, quantity);
                    return ResponseEntity.ok(newCartItem);
                }
            } catch (NumberFormatException e) {
                return ResponseEntity.badRequest().body(Map.of(
                    "message", "无效的数字格式",
                    "code", "INVALID_NUMBER_FORMAT"
                ));
            }
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of(
                "message", e.getMessage(),
                "code", "RUNTIME_ERROR"
            ));
        } catch (Exception e) {
            logger.error("添加到购物车失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(Map.of(
                "message", "添加到购物车失败",
                "code", "INTERNAL_ERROR"
            ));
        }
    }

    /**
     * 更新购物车项
     */
    @PutMapping("/{itemId}")
    public ResponseEntity<?> updateCartItem(@PathVariable Long itemId, @RequestBody Map<String, Object> updateData) {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }
            
            // 获取数量，添加空值检查
            Object quantityObj = updateData.get("quantity");
            if (quantityObj == null) {
                return ResponseEntity.badRequest().body(Map.of(
                    "message", "数量不能为空",
                    "code", "INVALID_REQUEST"
                ));
            }
            
            try {
                // 安全地转换为Integer
                Integer quantity = quantityObj instanceof Number ? ((Number) quantityObj).intValue() : Integer.parseInt(quantityObj.toString());
                
                // 验证数量必须大于0
                if (quantity <= 0) {
                    return ResponseEntity.badRequest().body(Map.of(
                        "message", "数量必须大于0",
                        "code", "INVALID_QUANTITY"
                    ));
                }
                
                CartItem updatedItem = cartService.updateCartItem(currentUser, itemId, quantity);
                return ResponseEntity.ok(updatedItem);
            } catch (NumberFormatException e) {
                return ResponseEntity.badRequest().body(Map.of(
                    "message", "无效的数字格式",
                    "code", "INVALID_NUMBER_FORMAT"
                ));
            }
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of(
                "message", e.getMessage(),
                "code", "RUNTIME_ERROR"
            ));
        } catch (Exception e) {
            logger.error("更新购物车失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(Map.of(
                "message", "更新购物车失败",
                "code", "INTERNAL_ERROR"
            ));
        }
    }

    /**
     * 删除购物车项
     */
    @DeleteMapping("/{itemId}")
    public ResponseEntity<Void> removeFromCart(@PathVariable Long itemId) {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }
            
            cartService.removeFromCart(currentUser, itemId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            logger.error("从购物车移除失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 清空购物车
     */
    @DeleteMapping
    public ResponseEntity<Void> clearCart() {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }
            
            cartService.clearCart(currentUser);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            logger.error("清空购物车失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }
}
