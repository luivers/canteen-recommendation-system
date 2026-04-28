package com.school.canteen.service;

import com.school.canteen.entity.Dish;
import java.util.List;
import java.util.Map;

/** 菜品推荐服务接口，提供个性化、策略化推荐能力 */
public interface RecommendationService {
    
    /**
     * Get personalized recommendations for a user
     * @param userId User ID
     * @param limit Maximum number of items
     * @return List of recommended dishes
     */
    List<Dish> getPersonalizedRecommendations(Long userId, int limit);
    
    /**
     * Get recommendations based on a specific strategy
     * @param strategyType Strategy type (e.g., "collaborative", "content", "popular")
     * @param userId User ID
     * @param limit Maximum number of items
     * @return List of recommended dishes
     */
    List<Dish> getRecommendationsByStrategy(String strategyType, Long userId, int limit);
    
    /**
     * Get recommendations for a specific goal (e.g., "weight_loss", "muscle_gain")
     * @param userId User ID
     * @param goal Health goal
     * @param limit Maximum number of items
     * @return List of recommended dishes
     */
    List<Dish> getHealthRecommendations(Long userId, String goal, int limit);
    
    /**
     * Get new dishes discovery for a user
     * @param userId User ID
     * @param limit Maximum number of items
     * @return List of dishes the user hasn't tried
     */
    List<Dish> getDiscoveryRecommendations(Long userId, int limit);
    
    /**
     * Get today new dishes, ordered by create time desc
     * @param limit Maximum number of items
     * @return List of today new dishes
     */
    List<Dish> getTodayNewDishes(int limit);

    /**
     * Get today's personalized hot dishes.
     * Prefer hot dishes matching user preferences, then fill with general hot dishes.
     * @param userId User ID
     * @param limit Maximum number of items
     * @return List of dishes
     */
    List<Dish> getTodayPersonalizedHotDishes(Long userId, int limit);

    /**
     * Get personalized recommendations with reason label
     * @param userId User ID
     * @param limit Maximum number of items
     * @return List of map with dish fields and reason
     */
    List<Map<String, Object>> getPersonalizedRecommendationsWithReason(Long userId, int limit);

    /**
     * Get comprehensive recommendations (mix of strategies)
     * @param userId User ID
     * @return Map of recommendation categories and lists of dishes
     */
    Map<String, List<Dish>> getComprehensiveRecommendations(Long userId);
}
