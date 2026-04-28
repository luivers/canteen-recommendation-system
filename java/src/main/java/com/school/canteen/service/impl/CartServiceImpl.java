package com.school.canteen.service.impl;

import com.school.canteen.entity.CartItem;
import com.school.canteen.entity.Dish;
import com.school.canteen.entity.Promotion;
import com.school.canteen.entity.User;
import com.school.canteen.repository.CartItemRepository;
import com.school.canteen.repository.DishRepository;
import com.school.canteen.repository.PromotionRepository;
import com.school.canteen.service.CartService;
import com.school.canteen.service.PriceCalculationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/** 购物车服务实现类 */
@Service
@RequiredArgsConstructor
public class CartServiceImpl implements CartService {

    private final CartItemRepository cartItemRepository;
    private final DishRepository dishRepository;
    private final PromotionRepository promotionRepository;
    private final PriceCalculationService priceCalculationService;

    private final com.school.canteen.repository.ComboRepository comboRepository;

    @Override
    public List<CartItem> getCartItems(User user) {
        List<CartItem> items = cartItemRepository.findByUser(user);
        
        // 实时更新购物车中的价格，确保反映最新的促销活动
        boolean changed = false;
        for (CartItem item : items) {
            // 如果是赠品，价格始终为0
            if (Boolean.TRUE.equals(item.getIsGift())) {
                if (item.getPrice().compareTo(BigDecimal.ZERO) != 0) {
                    item.setPrice(BigDecimal.ZERO);
                    item.setUpdateTime(LocalDateTime.now());
                    changed = true;
                }
                continue;
            }

            // 如果是套餐
            if (item.getCombo() != null) {
                BigDecimal currentPrice = BigDecimal.valueOf(item.getCombo().getPrice());
                 if (item.getPrice() == null || item.getPrice().compareTo(currentPrice) != 0) {
                    item.setPrice(currentPrice);
                    item.setUpdateTime(LocalDateTime.now());
                    changed = true;
                }
                continue;
            }

            if (item.getDish() != null) {
                BigDecimal currentPrice = priceCalculationService.calculatePrice(item.getDish());
                // 如果价格发生变化（与存储的价格不一致），则更新
                if (item.getPrice() == null || item.getPrice().compareTo(currentPrice) != 0) {
                    item.setPrice(currentPrice);
                    item.setUpdateTime(LocalDateTime.now());
                    changed = true;
                }
            }
        }
        
        // 如果有变动，批量保存更新
        if (changed) {
            cartItemRepository.saveAll(items);
        }
        
        return items;
    }

    @Override
    @Transactional
    public CartItem addToCart(User user, Long dishId, Integer quantity) {
        // 参数验证
        if (user == null) {
            throw new IllegalArgumentException("用户不能为空");
        }
        if (dishId == null) {
            throw new IllegalArgumentException("菜品ID不能为空");
        }
        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("数量必须为正整数");
        }
        
        // 查找菜品
        Dish dish = dishRepository.findById(dishId)
                .orElseThrow(() -> new RuntimeException("菜品不存在"));
        
        // 检查库存
        if (dish.getStock() != null && dish.getStock() < quantity) {
            throw new RuntimeException("库存不足");
        }
        
        // 查找是否已存在购物车项
        List<CartItem> existingItems = cartItemRepository.findByUser(user);
        CartItem existingItem = existingItems.stream()
                .filter(item -> item.getDish() != null && item.getDish().getId().equals(dishId))
                .findFirst()
                .orElse(null);
        
        // 确定使用的价格：考虑单品促销和全场促销
        BigDecimal priceToUse = priceCalculationService.calculatePrice(dish);
        
        CartItem savedItem;
        if (existingItem != null) {
            // 更新现有项的数量
            existingItem.setQuantity(existingItem.getQuantity() + quantity);
            existingItem.setPrice(priceToUse);
            existingItem.setUpdateTime(LocalDateTime.now());
            savedItem = cartItemRepository.save(existingItem);
        } else {
            // 创建新的购物车项
            CartItem newItem = new CartItem();
            newItem.setUser(user);
            newItem.setDish(dish);
            newItem.setQuantity(quantity);
            newItem.setPrice(priceToUse);
            savedItem = cartItemRepository.save(newItem);
        }

        // 处理买赠逻辑
        if (Boolean.TRUE.equals(dish.getIsPromotion()) && "gift".equals(dish.getPromotionType()) && dish.getGiftDishId() != null) {
             Dish giftDish = dishRepository.findById(dish.getGiftDishId()).orElse(null);
             if (giftDish != null) {
                 // 重新获取购物车列表以确保最新
                 List<CartItem> currentItems = cartItemRepository.findByUser(user);
                 CartItem existingGift = currentItems.stream()
                        .filter(item -> item.getDish() != null
                                && item.getDish().getId().equals(giftDish.getId())
                                && Boolean.TRUE.equals(item.getIsGift()))
                        .findFirst()
                        .orElse(null);
                 
                 if (existingGift != null) {
                     existingGift.setQuantity(existingGift.getQuantity() + quantity);
                     cartItemRepository.save(existingGift);
                 } else {
                     CartItem giftItem = new CartItem();
                     giftItem.setUser(user);
                     giftItem.setDish(giftDish);
                     giftItem.setQuantity(quantity);
                     giftItem.setPrice(BigDecimal.ZERO);
                     giftItem.setIsGift(true);
                     cartItemRepository.save(giftItem);
                 }
             }
        }

        return savedItem;
    }

    @Override
    @Transactional
    public CartItem addComboToCart(User user, Long comboId, Integer quantity) {
        // 参数验证
        if (user == null) {
            throw new IllegalArgumentException("用户不能为空");
        }
        if (comboId == null) {
            throw new IllegalArgumentException("套餐ID不能为空");
        }
        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("数量必须为正整数");
        }

        // 查找套餐
        com.school.canteen.entity.Combo combo = comboRepository.findById(comboId)
                .orElseThrow(() -> new RuntimeException("套餐不存在"));

        // 检查是否有效
        if (!"active".equalsIgnoreCase(combo.getStatus())) {
             throw new RuntimeException("套餐不可用");
        }

        // 查找是否已存在购物车项
        List<CartItem> existingItems = cartItemRepository.findByUser(user);
        CartItem existingItem = existingItems.stream()
                .filter(item -> item.getCombo() != null && item.getCombo().getId().equals(comboId))
                .findFirst()
                .orElse(null);

        BigDecimal priceToUse = BigDecimal.valueOf(combo.getPrice());

        CartItem savedItem;
        if (existingItem != null) {
            // 更新现有项的数量
            existingItem.setQuantity(existingItem.getQuantity() + quantity);
            existingItem.setPrice(priceToUse);
            existingItem.setUpdateTime(LocalDateTime.now());
            savedItem = cartItemRepository.save(existingItem);
        } else {
            // 创建新的购物车项
            CartItem newItem = new CartItem();
            newItem.setUser(user);
            newItem.setCombo(combo);
            newItem.setQuantity(quantity);
            newItem.setPrice(priceToUse);
            savedItem = cartItemRepository.save(newItem);
        }
        return savedItem;
    }

    @Override
    @Transactional
    public CartItem updateCartItem(User user, Long itemId, Integer quantity) {
        // 参数验证
        if (user == null) {
            throw new IllegalArgumentException("用户不能为空");
        }
        if (itemId == null) {
            throw new IllegalArgumentException("商品ID不能为空");
        }
        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("数量必须为正整数");
        }
        
        // 查找购物车项
        CartItem cartItem = cartItemRepository.findById(itemId)
                .orElseThrow(() -> new RuntimeException("购物车项不存在"));
        
        // 检查是否属于当前用户
        if (!cartItem.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("无权操作他人的购物车");
        }
        
        // 检查库存
        if (cartItem.getDish() != null) {
            Dish dish = cartItem.getDish();
            if (dish.getStock() != null && dish.getStock() < quantity) {
                throw new RuntimeException("库存不足");
            }
            // 确定使用的价格
            BigDecimal priceToUse = priceCalculationService.calculatePrice(dish);
            cartItem.setPrice(priceToUse);
        } else if (cartItem.getCombo() != null) {
            // 套餐暂无库存概念，或者需要检查包含的菜品库存（此处简化，仅更新价格）
            cartItem.setPrice(BigDecimal.valueOf(cartItem.getCombo().getPrice()));
        }
        
        // 更新数量和价格
        cartItem.setQuantity(quantity);
        cartItem.setUpdateTime(LocalDateTime.now());
        return cartItemRepository.save(cartItem);
    }

    @Override
    @Transactional
    public void removeFromCart(User user, Long itemId) {
        // 参数验证
        if (user == null) {
            throw new IllegalArgumentException("用户不能为空");
        }
        if (itemId == null) {
            throw new IllegalArgumentException("商品ID不能为空");
        }
        
        // 查找购物车项
        CartItem cartItem = cartItemRepository.findById(itemId)
                .orElseThrow(() -> new RuntimeException("购物车项不存在"));
        
        // 检查是否属于当前用户
        if (!cartItem.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("无权操作他人的购物车");
        }
        
        // 删除购物车项
        cartItemRepository.delete(cartItem);
    }

    @Override
    @Transactional
    public void clearCart(User user) {
        if (user == null) {
            throw new IllegalArgumentException("用户不能为空");
        }
        List<CartItem> items = cartItemRepository.findByUser(user);
        cartItemRepository.deleteAll(items);
    }
}
