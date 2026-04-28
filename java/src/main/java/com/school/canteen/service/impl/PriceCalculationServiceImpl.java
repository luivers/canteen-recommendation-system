package com.school.canteen.service.impl;

import com.school.canteen.entity.Dish;
import com.school.canteen.entity.Promotion;
import com.school.canteen.repository.PromotionRepository;
import com.school.canteen.service.PriceCalculationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/** 菜品价格计算服务实现类 */
@Service
@RequiredArgsConstructor
public class PriceCalculationServiceImpl implements PriceCalculationService {

    private final PromotionRepository promotionRepository;

    @Override
    public BigDecimal calculatePrice(Dish dish) {
        LocalDateTime now = LocalDateTime.now();
        BigDecimal currentPrice = dish.getPrice();

        // 1. Single Item Promotion
        // If the dish has a specific promotion configured directly on the Dish entity
        // 修改逻辑：如果设置了促销且有促销价，检查时间有效性
        if (Boolean.TRUE.equals(dish.getIsPromotion()) && dish.getPromotionPrice() != null) {
            // 如果没有设置促销时间范围，或者当前时间在促销范围内，则应用促销价
            if (dish.getPromotionStart() == null || dish.getPromotionEnd() == null ||
                ((now.isAfter(dish.getPromotionStart()) || now.isEqual(dish.getPromotionStart())) &&
                 (now.isBefore(dish.getPromotionEnd()) || now.isEqual(dish.getPromotionEnd())))) {
                currentPrice = dish.getPromotionPrice();
            }
        }

        // 2. Check Global, Category, or Specific Promotions (Promotion Entity)
        List<Promotion> applicablePromotions = getApplicablePromotions(dish);
        
        // Apply discounts sequentially (double discount logic)
        for (Promotion p : applicablePromotions) {
            if (p.getDiscountValue() != null) {
                // Apply discount on the current price
                currentPrice = currentPrice.multiply(BigDecimal.valueOf(p.getDiscountValue()));
            }
        }
        
        return currentPrice;
    }

    @Override
    public List<Promotion> getApplicablePromotions(Dish dish) {
        List<Promotion> activePromotions = promotionRepository.findActivePromotions();
        List<Promotion> result = new ArrayList<>();

        for (Promotion p : activePromotions) {
            // Currently only supporting "discount" type for price calculation
            if (!"discount".equalsIgnoreCase(p.getType())) {
                continue; 
            }
            
            boolean isApplicable = false;
            
            if ("all".equalsIgnoreCase(p.getTargetType())) {
                isApplicable = true;
            } else if ("category".equalsIgnoreCase(p.getTargetType())) {
                // Check if dish belongs to the promotion category (DishCategory)
                if (dish.getDishCategory() != null && p.getTargetDishCategories() != null) {
                    if (p.getTargetDishCategories().contains(dish.getDishCategory().name())) {
                        isApplicable = true;
                    }
                }
            } else if ("specific".equalsIgnoreCase(p.getTargetType())) {
                // Check if dish is in the promotion's specific dish list
                if (p.getDishes() != null &&
                    p.getDishes().stream().anyMatch(d -> d.getId().equals(dish.getId()))) {
                    isApplicable = true;
                }
            }
            
            if (isApplicable) {
                result.add(p);
            }
        }
        return result;
    }
}
