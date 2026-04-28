package com.school.canteen.service.strategy;

import com.school.canteen.entity.Dish;
import java.util.List;

/** 推荐策略接口，定义菜品推荐算法的统一规范 */
public interface RecommendationStrategy {
    /**
     * Generate recommendations for a user
     * @param userId The user ID (can be null for anonymous/general recommendations)
     * @param limit The maximum number of recommendations
     * @return List of recommended dishes
     */
    List<Dish> recommend(Long userId, int limit);

    /**
     * Get the type of this strategy
     * @return Strategy type identifier
     */
    String getStrategyType();
}
