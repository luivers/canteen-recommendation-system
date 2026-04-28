package com.school.canteen.repository;

import com.school.canteen.entity.Dish;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/** 菜品数据访问层 */
@Repository
public interface DishRepository extends JpaRepository<Dish, Long> {
    
    @Query("SELECT d FROM Dish d WHERE d.status = :status")
    List<Dish> findByStatus(@Param("status") Dish.DishStatus status);
    
    @Query("SELECT d FROM Dish d LEFT JOIN FETCH d.tasteTags WHERE d.isPromotion = true")
    List<Dish> findByIsPromotionTrue();
    
    @Query("SELECT d FROM Dish d LEFT JOIN FETCH d.tasteTags WHERE d.isPromotion = true AND d.promotionStart <= CURRENT_TIMESTAMP AND d.promotionEnd >= CURRENT_TIMESTAMP")
    List<Dish> findActivePromotionDishes();
    
    @Query("SELECT d FROM Dish d LEFT JOIN FETCH d.tasteTags WHERE d.isPromotion = true AND d.promotionStart <= CURRENT_TIMESTAMP AND d.promotionEnd >= CURRENT_TIMESTAMP ORDER BY d.promotionPrice ASC")
    List<Dish> findActivePromotionDishesOrderByPriceAsc();
    
    @Query("SELECT d FROM Dish d LEFT JOIN FETCH d.tasteTags WHERE d.isPromotion = true AND d.promotionStart <= CURRENT_TIMESTAMP AND d.promotionEnd >= CURRENT_TIMESTAMP ORDER BY d.averageRating DESC")
    List<Dish> findActivePromotionDishesOrderByRatingDesc();
    
    @Query("SELECT d FROM Dish d LEFT JOIN FETCH d.tasteTags WHERE d.averageRating >= :minRating ORDER BY d.averageRating DESC")
    List<Dish> findTopRatedDishes(@Param("minRating") Double minRating, Pageable pageable);
    
    @Query("SELECT d FROM Dish d LEFT JOIN FETCH d.tasteTags WHERE (d.name LIKE %:keyword% OR d.description LIKE %:keyword%) AND d.status != 'DELETED'")
    List<Dish> searchByKeyword(@Param("keyword") String keyword);
    
    @Query("SELECT d FROM Dish d ORDER BY d.ratingCount DESC, d.createTime DESC")
    List<Dish> findPopularDishes(Pageable pageable);

    // 按实际销量排序获取热门菜品（基于订单项统计）
    @Query("SELECT d FROM Dish d " +
           "LEFT JOIN OrderItem oi ON oi.dish.id = d.id " +
           "LEFT JOIN oi.order o ON o.status IN ('PAID', 'PREPARING', 'READY', 'COMPLETED') " +
           "WHERE d.status = com.school.canteen.entity.Dish$DishStatus.AVAILABLE " +
           "GROUP BY d " +
           "ORDER BY COALESCE(SUM(oi.quantity), 0) DESC, d.averageRating DESC, d.ratingCount DESC")
    List<Dish> findPopularDishesBySales(Pageable pageable);
    
    // 获取所有菜品，用于测试
    @Query("SELECT d FROM Dish d LEFT JOIN FETCH d.tasteTags WHERE d.status != 'DELETED'")
    List<Dish> findAllDishes();
    
    @Query("SELECT d FROM Dish d LEFT JOIN FETCH d.tasteTags WHERE d.tasteTags LIKE %:tag% AND d.status != 'DELETED'")
    List<Dish> findByTasteTag(@Param("tag") String tag);
    
    // 根据菜品类型查询菜品
    @Query("SELECT d FROM Dish d LEFT JOIN FETCH d.tasteTags WHERE d.dishCategory = :dishCategory AND d.status != 'DELETED'")
    List<Dish> findByDishCategory(@Param("dishCategory") Dish.DishCategory dishCategory);
    
    // 今日上新：按当天创建时间范围筛选，并按创建时间倒序
    @Query("SELECT d FROM Dish d LEFT JOIN FETCH d.tasteTags WHERE d.createTime >= :start AND d.createTime < :end AND d.status = :status ORDER BY d.createTime DESC")
    List<Dish> findTodayNewDishes(@Param("start") java.time.LocalDateTime start,
                                  @Param("end") java.time.LocalDateTime end,
                                  @Param("status") Dish.DishStatus status,
                                  Pageable pageable);
    
    // 根据窗口ID获取菜品
    @Query("SELECT d FROM Dish d WHERE d.windowId = :windowId AND d.status != 'DELETED'")
    List<Dish> findByWindowId(@Param("windowId") Long windowId);

    // 重写findAll方法，确保即使没有分类也能返回菜品
    // 根据ID列表排除菜品 (用于发现新菜品)
    @Query("SELECT d FROM Dish d WHERE d.id NOT IN :ids")
    List<Dish> findByIdNotIn(@Param("ids") List<Long> ids, Pageable pageable);

    // 根据卡路里筛选 (用于减肥目标)
    @Query("SELECT d FROM Dish d WHERE d.calories <= :maxCalories")
    List<Dish> findByCaloriesLessThan(@Param("maxCalories") Integer maxCalories, Pageable pageable);

    // 根据蛋白质筛选 (用于增肌目标)
    @Query("SELECT d FROM Dish d WHERE d.protein >= :minProtein")
    List<Dish> findByProteinGreaterThan(@Param("minProtein") java.math.BigDecimal minProtein, Pageable pageable);

    // 根据标签模糊查询 (用于口味匹配)
    @Query("SELECT d FROM Dish d JOIN d.tasteTags t WHERE t LIKE %:tag%")
    List<Dish> findByTasteTagContaining(@Param("tag") String tag);
    
    // 综合多标签查询 (用于综合口味偏好、菜系等匹配)
    @Query("SELECT DISTINCT d FROM Dish d JOIN d.tasteTags t WHERE t IN :tags AND d.status = 'AVAILABLE'")
    List<Dish> findByTasteTagsIn(@Param("tags") java.util.Collection<String> tags);

    @Override
    @org.springframework.lang.NonNull
    @Query("SELECT d FROM Dish d WHERE d.status != 'DELETED'")
    List<Dish> findAll();

    // 每日库存重置：将可售状态(AVAILABLE/SOLD_OUT)且dailyLimit>0的菜品重置库存并恢复为AVAILABLE
    @org.springframework.data.jpa.repository.Modifying
    @Query("UPDATE Dish d SET d.stock = d.dailyLimit, d.status = :resetStatus " +
           "WHERE d.dailyLimit IS NOT NULL AND d.dailyLimit > 0 AND d.status IN :sourceStatuses")
    void resetDailyInventory(@Param("sourceStatuses") java.util.Collection<Dish.DishStatus> sourceStatuses,
                             @Param("resetStatus") Dish.DishStatus resetStatus);

    /**
     * 统计指定食堂下的菜品数量
     */
    long countByCanteenId(Long canteenId);

    /**
     * 批量将指定窗口下所有 AVAILABLE 菜品改为 DISCONTINUED（窗口关闭/维护时级联调用）
     */
    @org.springframework.data.jpa.repository.Modifying
    @Query("UPDATE Dish d SET d.status = :targetStatus WHERE d.windowId = :windowId AND d.status = :sourceStatus")
    int discontinueAvailableDishesByWindowId(@Param("windowId") Long windowId,
                                             @Param("sourceStatus") Dish.DishStatus sourceStatus,
                                             @Param("targetStatus") Dish.DishStatus targetStatus);
}
