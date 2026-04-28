package com.school.canteen.service;

import com.school.canteen.entity.Dish;
import java.math.BigDecimal;

/** 菜品价格计算服务接口，综合促销活动计算最终价格 */
public interface PriceCalculationService {
    /**
     * Calculate the final price of a dish considering all active promotions.
     * Priority:
     * 1. Single Item Promotion (Dish field)
     * 2. Promotion Entity (Global > Category > Specific) - Lowest price wins
     * 
     * @param dish The dish to calculate price for
     * @return The final calculated price
     */
    BigDecimal calculatePrice(Dish dish);

    /**
     * Get all applicable promotions for a dish.
     * @param dish The dish to check
     * @return List of applicable promotions
     */
    java.util.List<com.school.canteen.entity.Promotion> getApplicablePromotions(Dish dish);
}
