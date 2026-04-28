package com.school.canteen.service;

import com.school.canteen.entity.CartItem;
import com.school.canteen.entity.User;

import java.util.List;

/** 购物车服务接口 */
public interface CartService {
    
    /**
     * 获取购物车项
     */
    List<CartItem> getCartItems(User user);
    
    /**
     * 添加到购物车
     */
    CartItem addToCart(User user, Long dishId, Integer quantity);
    
    /**
     * 添加套餐到购物车
     */
    CartItem addComboToCart(User user, Long comboId, Integer quantity);

    /**
     * 更新购物车项
     */
    CartItem updateCartItem(User user, Long itemId, Integer quantity);
    
    /**
     * 从购物车移除
     */
    void removeFromCart(User user, Long itemId);
    
    /**
     * 清空购物车
     */
    void clearCart(User user);
}
