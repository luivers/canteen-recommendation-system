package com.school.canteen.service;

import com.school.canteen.entity.Dish;

import java.util.List;
import java.util.Map;

/** 菜品管理服务接口 */
public interface DishService {
    // 基本CRUD操作
    Dish createDish(Dish dish);
    Dish updateDish(Long dishId, Dish dishDetails);
    void deleteDish(Long dishId);
    Dish getDishById(Long dishId);
    List<Dish> getAllDishes();
    
    // 库存管理
    Dish updateDishStock(Long dishId, Integer quantity, Boolean add);
    
    // 查询相关
    List<Dish> getDishesByCategory(String category);
    List<Dish> searchDishes(String keyword);
    List<Dish> getDishesByStatus(String status);
    List<Dish> getPromotionDishes();
    List<Dish> getActivePromotionDishes();
    List<Dish> getActivePromotionDishesOrderByPriceAsc();
    List<Dish> getActivePromotionDishesOrderByRatingDesc();
    List<Dish> getTopRatedDishes(int limit);
    List<Dish> getPopularDishes(int limit);
    List<Dish> getHotDishes(int limit);
    
    // 状态管理
    void toggleDishStatus(Long dishId);
    
    // 分类管理
    List<String> getAllCategories();

    // 促销管理
    Dish setPromotion(Long dishId, Map<String, Object> promotionData);
    
    // 评分相关
    Map<String, Object> getDishRatings(Long dishId);

    // 每日库存重置
    void resetDailyInventory();
    
    // 检查并执行每日库存重置（用于登录触发等场景）
    void checkAndResetDailyInventory();
}