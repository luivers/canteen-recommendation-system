package com.school.canteen.service.impl;

import com.school.canteen.entity.Dish;
import com.school.canteen.entity.Window;
import com.school.canteen.entity.User;
import com.school.canteen.repository.DishRepository;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.repository.WindowRepository;
import com.school.canteen.repository.OrderItemRepository;
import com.school.canteen.service.DishService;
import com.school.canteen.service.NotificationService;
import com.school.canteen.service.StatisticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

import org.springframework.beans.BeanUtils;

/** 菜品管理服务实现类 */
@Service
@RequiredArgsConstructor
public class DishServiceImpl implements DishService {

    private final DishRepository dishRepository;
    private final JdbcTemplate jdbcTemplate;
    private final WindowRepository windowRepository;
    private final UserRepository userRepository;
    private final OrderItemRepository orderItemRepository;

    @Autowired
    @Lazy
    private NotificationService notificationService;

    @Autowired
    private StatisticsService statisticsService;
    
    @Override
    @Transactional
    @CacheEvict(value = {"dishes_v7", "recommendations"}, allEntries = true)
    public Dish createDish(Dish dish) {
        Objects.requireNonNull(dish, "菜品信息不能为空");
        
        // 这里的字段校验已在 Controller 层通过 @Valid 注解和 DTO 完成
        // Service 层主要负责业务逻辑处理

        Window window = null;
        if (dish.getWindowId() != null) {
            window = windowRepository.findById(dish.getWindowId())
                    .orElseThrow(() -> new RuntimeException("所属窗口不存在"));
        } else if (dish.getWindowName() != null && !dish.getWindowName().trim().isEmpty()
                && dish.getCanteenId() != null) {
            window = windowRepository.findFirstByNameAndCanteenId(dish.getWindowName().trim(), dish.getCanteenId())
                    .orElseThrow(() -> new RuntimeException("所属窗口不存在"));
            dish.setWindowId(window.getId());
        } else {
            throw new RuntimeException("所属窗口不能为空");
        }

        dish.setWindowId(window.getId());
        dish.setWindowName(window.getName());
        dish.setWindowLocation(window.getLocation());
        if (window.getCanteenId() != null) {
            dish.setCanteenId(window.getCanteenId());
        }
        if (window.getCanteenName() != null) {
            dish.setCanteenName(window.getCanteenName());
        }
        
        // 设置默认值
        if (dish.getStock() == null) {
            dish.setStock(0);
        }
        if (dish.getStatus() == null) {
            dish.setStatus(Dish.DishStatus.AVAILABLE);
        }
        if (dish.getIsPromotion() == null) {
            dish.setIsPromotion(false);
        }
        
        Dish savedDish = dishRepository.save(dish);
        if (savedDish.getStatus() == Dish.DishStatus.AVAILABLE) {
            Set<Long> userIds = getActiveStudentIds();
            for (Long userId : userIds) {
                notificationService.sendNotification(
                    userId,
                    "新菜品上线",
                    "新菜品【" + savedDish.getName() + "】上线啦，快去尝鲜吧！",
                    com.school.canteen.entity.Notification.NotificationType.DISH,
                    com.school.canteen.entity.Notification.NotificationScene.DISH_ON_SHELF,
                    com.school.canteen.entity.Notification.BizType.DISH,
                    savedDish.getId()
                );
            }
        }
        return savedDish;
    }
    
    @Override
    @Transactional
    @CacheEvict(value = {"dishes_v7", "recommendations"}, allEntries = true)
    public Dish updateDish(Long dishId, Dish dishDetails) {
        Objects.requireNonNull(dishId, "菜品ID不能为空");
        Objects.requireNonNull(dishDetails, "菜品更新信息不能为空");
        
        Dish dish = dishRepository.findById(dishId)
                .orElseThrow(() -> new RuntimeException("菜品不存在"));

        Dish.DishStatus oldStatus = dish.getStatus();
        
        // 更新字段，只更新非空字段
        if (dishDetails.getName() != null) dish.setName(dishDetails.getName());
        if (dishDetails.getDescription() != null) dish.setDescription(dishDetails.getDescription());
        if (dishDetails.getPrice() != null) dish.setPrice(dishDetails.getPrice());
        if (dishDetails.getImageUrl() != null) dish.setImageUrl(dishDetails.getImageUrl());
        if (dishDetails.getTasteTags() != null) dish.setTasteTags(dishDetails.getTasteTags());
        // 更新状态
        if (dishDetails.getDishCategory() != null) dish.setDishCategory(dishDetails.getDishCategory());
        if (dishDetails.getStatus() != null) dish.setStatus(dishDetails.getStatus());
        if (dishDetails.getStock() != null) dish.setStock(dishDetails.getStock());
        if (dishDetails.getDailyLimit() != null) dish.setDailyLimit(dishDetails.getDailyLimit());
        
        // 更新营养信息
        if (dishDetails.getCalories() != null) dish.setCalories(dishDetails.getCalories());
        if (dishDetails.getProtein() != null) dish.setProtein(dishDetails.getProtein());
        if (dishDetails.getFat() != null) dish.setFat(dishDetails.getFat());
        if (dishDetails.getCarbohydrate() != null) dish.setCarbohydrate(dishDetails.getCarbohydrate());
        
        // 更新食堂和窗口信息
        if (dishDetails.getWindowId() != null && !dishDetails.getWindowId().equals(dish.getWindowId())) {
            // 如果窗口发生变化，根据新窗口更新所有相关信息（包括食堂信息）
            Window window = windowRepository.findById(dishDetails.getWindowId())
                    .orElseThrow(() -> new RuntimeException("所属窗口不存在"));
            dish.setWindowId(window.getId());
            dish.setWindowName(window.getName());
            dish.setWindowLocation(window.getLocation());
            dish.setCanteenId(window.getCanteenId());
            dish.setCanteenName(window.getCanteenName());
        } else if (dishDetails.getWindowId() == null) {
            // 如果没有修改窗口ID，但传递了其他零散字段（通常不会发生，但为了兼容保留）
            if (dishDetails.getCanteenId() != null) dish.setCanteenId(dishDetails.getCanteenId());
            if (dishDetails.getCanteenName() != null) dish.setCanteenName(dishDetails.getCanteenName());
            if (dishDetails.getWindowName() != null) dish.setWindowName(dishDetails.getWindowName());
            if (dishDetails.getWindowLocation() != null) dish.setWindowLocation(dishDetails.getWindowLocation());
        }
        
        Dish savedDish = dishRepository.save(dish);

        if (oldStatus != Dish.DishStatus.AVAILABLE && savedDish.getStatus() == Dish.DishStatus.AVAILABLE) {
            Set<Long> userIds = getActiveStudentIds();
            for (Long userId : userIds) {
                notificationService.sendNotification(
                    userId,
                    "菜品重新上架",
                    "菜品【" + savedDish.getName() + "】已重新上架，快去看看吧！",
                    com.school.canteen.entity.Notification.NotificationType.DISH,
                    com.school.canteen.entity.Notification.NotificationScene.DISH_ON_SHELF,
                    com.school.canteen.entity.Notification.BizType.DISH,
                    savedDish.getId()
                );
            }
        }

        return savedDish;
    }
    
    @Override
    @Transactional
    @CacheEvict(value = {"dishes_v7", "recommendations", "dishes"}, allEntries = true)
    public void deleteDish(Long dishId) {
        Objects.requireNonNull(dishId, "菜品ID不能为空");
        
        Dish dish = dishRepository.findById(dishId)
                .orElseThrow(() -> new RuntimeException("菜品不存在"));
        
        // 物理删除策略：强制删除所有关联数据
        
        // 1. 删除该菜品在订单评价中的评分明细
        jdbcTemplate.update("DELETE FROM review_items WHERE dish_id = ?", dishId);
        
        // 2. 删除关联的购物车项
        jdbcTemplate.update("DELETE FROM cart_items WHERE dish_id = ?", dishId);
        
        // 4. 删除关联的订单项 (解决外键约束问题)
        // 注意：这会改变历史订单的完整性
        jdbcTemplate.update("DELETE FROM order_items WHERE dish_id = ?", dishId);
        jdbcTemplate.update("DELETE FROM combo_dishes WHERE dish_id = ?", dishId);
        
        // 5. 物理删除菜品
        try {
            dishRepository.delete(dish);
        } catch (Exception e) {
             // 如果是Data truncated错误，提示用户重启
             if (e.getMessage() != null && e.getMessage().contains("Data truncated")) {
                 throw new RuntimeException("删除失败：数据库字段需要更新。请重启后端服务以自动修复数据库结构。", e);
             }
             throw e;
        }
    }
    
    @Override
    @Cacheable(value = "dishes_v7", key = "#dishId")
    @Transactional(readOnly = true)
    public Dish getDishById(Long dishId) {
        Objects.requireNonNull(dishId, "菜品ID不能为空");
        
        Dish dish = dishRepository.findById(dishId)
                .orElseThrow(() -> new RuntimeException("菜品不存在"));
        
        // 创建一个完全脱管的新对象，避免序列化问题
        Dish safeDish = new Dish();
        // 排除可能引起序列化问题的关联字段
        BeanUtils.copyProperties(dish, safeDish, "tasteTags");
        
        // 手动处理 tasteTags，将其转换为普通 ArrayList
        if (dish.getTasteTags() != null) {
            safeDish.setTasteTags(new ArrayList<>(dish.getTasteTags()));
        }
        
        return safeDish;
    }
    
    @Override
    // 暂时移除缓存，解决初始数据加载问题
    public List<Dish> getAllDishes() {
        return dishRepository.findAllDishes();
    }
    
    @Override
    @Transactional
    @CacheEvict(value = "dishes_v7", key = "#dishId")
    public Dish updateDishStock(Long dishId, Integer quantity, Boolean add) {
        Objects.requireNonNull(dishId, "菜品ID不能为空");
        Objects.requireNonNull(quantity, "数量不能为空");
        
        if (quantity <= 0) {
            throw new IllegalArgumentException("数量必须为正整数");
        }
        
        Dish dish = dishRepository.findById(dishId)
                .orElseThrow(() -> new RuntimeException("菜品不存在"));
        
        Dish.DishStatus oldStatus = dish.getStatus();

        Integer currentStock = dish.getStock() != null ? dish.getStock() : 0;
        int newStock;
        
        if (Boolean.TRUE.equals(add)) {
            // 增加库存
            newStock = currentStock + quantity;
        } else {
            // 减少库存
            newStock = currentStock - quantity;
            // 即使库存变成负数也允许扣减（特别是针对确认取餐场景，允许超卖记录）
        }
        
        dish.setStock(newStock);
        
        // 根据库存状态更新菜品状态
        if (newStock <= 0) {
            dish.setStatus(Dish.DishStatus.SOLD_OUT);
        } else if (dish.getStatus() == Dish.DishStatus.SOLD_OUT) {
            dish.setStatus(Dish.DishStatus.AVAILABLE);
        }
        
        Dish savedDish = dishRepository.save(dish);

        if (oldStatus != Dish.DishStatus.AVAILABLE && savedDish.getStatus() == Dish.DishStatus.AVAILABLE) {
            Set<Long> userIds = getActiveStudentIds();
            for (Long userId : userIds) {
                notificationService.sendNotification(
                    userId,
                    "菜品补货上架",
                    "菜品【" + savedDish.getName() + "】已补货上架，快来看看吧！",
                    com.school.canteen.entity.Notification.NotificationType.DISH,
                    com.school.canteen.entity.Notification.NotificationScene.DISH_ON_SHELF,
                    com.school.canteen.entity.Notification.BizType.DISH,
                    savedDish.getId()
                );
            }
        }

        return savedDish;
    }
    
    @Override
    @Cacheable(value = "dishes", key = "'category_' + #category")
    public List<Dish> getDishesByCategory(String category) {
        Objects.requireNonNull(category, "分类不能为空");
        
        try {
            // 将中文分类转换为DishCategory枚举
            Dish.DishCategory dishCategory = null;
            switch (category) {
                case "主食":
                    dishCategory = Dish.DishCategory.MAIN_DISH;
                    break;
                case "荤菜":
                    dishCategory = Dish.DishCategory.MEAT_DISH;
                    break;
                case "素菜":
                    dishCategory = Dish.DishCategory.VEGETABLE;
                    break;
                case "汤类":
                    dishCategory = Dish.DishCategory.SOUP;
                    break;
                case "小吃":
                    dishCategory = Dish.DishCategory.SNACK;
                    break;
                case "饮品":
                    dishCategory = Dish.DishCategory.BEVERAGE;
                    break;
            }
            
            if (dishCategory != null) {
                // 根据菜品类型查询菜品
                return dishRepository.findByDishCategory(dishCategory);
            }
        } catch (Exception e) {
            // 如果转换失败，返回空列表
            return List.of();
        }
        return List.of();
    }

    private Set<Long> getActiveStudentIds() {
        // 使用数据库查询代替内存过滤
        // 这里为了兼容性，使用 SQL 查询获取 ID 列表
        List<Long> ids = jdbcTemplate.queryForList("SELECT id FROM users WHERE status = 'active'", Long.class);
        return new HashSet<>(ids);
    }
    
    @Override
    // 暂时移除缓存，解决类型转换错误
    public List<Dish> searchDishes(String keyword) {
        String safeKeyword = keyword != null ? keyword.trim() : "";
        return dishRepository.searchByKeyword(safeKeyword);
    }
    
    @Override
    @Cacheable(value = "dishes", key = "'status_' + #status")
    public List<Dish> getDishesByStatus(String status) {
        Objects.requireNonNull(status, "状态不能为空");
        
        try {
            Dish.DishStatus dishStatus = Dish.DishStatus.valueOf(status.toUpperCase());
            return dishRepository.findByStatus(dishStatus);
        } catch (IllegalArgumentException e) {
            // 如果状态枚举不存在，返回空列表
            return List.of();
        }
    }
    
    @Override
    public List<Dish> getPromotionDishes() {
        List<Dish> dishes = dishRepository.findByIsPromotionTrue();
        fillSalesCount(dishes);
        return dishes;
    }

    @Override
    public List<Dish> getActivePromotionDishes() {
        List<Dish> dishes = dishRepository.findActivePromotionDishes();
        fillSalesCount(dishes);
        return dishes;
    }

    @Override
    public List<Dish> getActivePromotionDishesOrderByPriceAsc() {
        List<Dish> dishes = dishRepository.findActivePromotionDishesOrderByPriceAsc();
        fillSalesCount(dishes);
        return dishes;
    }

    @Override
    public List<Dish> getActivePromotionDishesOrderByRatingDesc() {
        List<Dish> dishes = dishRepository.findActivePromotionDishesOrderByRatingDesc();
        fillSalesCount(dishes);
        return dishes;
    }

    /**
     * 填充菜品销量数据
     */
    private void fillSalesCount(List<Dish> dishes) {
        if (dishes == null || dishes.isEmpty()) return;

        // 批量查询所有菜品的销量
        List<Map<String, Object>> salesData = orderItemRepository.findAllDishSalesCount();
        Map<Long, Long> salesMap = new HashMap<>();
        for (Map<String, Object> row : salesData) {
            Object dishIdObj = row.get("dishId");
            Object salesCountObj = row.get("salesCount");
            if (dishIdObj != null && salesCountObj != null) {
                Long dishId = ((Number) dishIdObj).longValue();
                Long salesCount = ((Number) salesCountObj).longValue();
                salesMap.put(dishId, salesCount);
            }
        }

        // 填充销量数据
        for (Dish dish : dishes) {
            Long salesCount = salesMap.get(dish.getId());
            dish.setSalesCount(salesCount != null ? salesCount.intValue() : 0);
        }
    }
    
    @Override
    @Cacheable(value = "dishes", key = "'top_rated_' + #limit")
    public List<Dish> getTopRatedDishes(int limit) {
        // 确保limit在合理范围内
        int safeLimit = Math.max(1, Math.min(50, limit));
        Pageable pageable = PageRequest.of(0, safeLimit);
        return dishRepository.findTopRatedDishes(4.0, pageable);
    }
    
    @Override
    @Cacheable(value = "dishes", key = "'popular_' + #limit")
    public List<Dish> getPopularDishes(int limit) {
        // 确保limit在合理范围内
        int safeLimit = Math.max(1, Math.min(50, limit));
        Pageable pageable = PageRequest.of(0, safeLimit);
        // 使用ratingCount和createTime排序，符合"Popular"的语义 (Popular通常指销量或关注度，这里用评分数近似)
        return dishRepository.findPopularDishes(pageable);
    }
    
    @Override
    @Cacheable(value = "dishes", key = "'hot_' + #limit")
    public List<Dish> getHotDishes(int limit) {
        // 确保limit在合理范围内
        int safeLimit = Math.max(1, Math.min(50, limit));
        // 调用Repository中的热门菜品查询方法
        return dishRepository.findPopularDishes(PageRequest.of(0, safeLimit));
    }
    
    @Override
    @Transactional
    @CacheEvict(value = "dishes_v7", key = "#dishId")
    public void toggleDishStatus(Long dishId) {
        Objects.requireNonNull(dishId, "菜品ID不能为空");
        
        Dish dish = dishRepository.findById(dishId)
                .orElseThrow(() -> new RuntimeException("菜品不存在"));
        Dish.DishStatus oldStatus = dish.getStatus();
        
        // 切换状态：AVAILABLE <-> DISCONTINUED
        if (dish.getStatus() == Dish.DishStatus.AVAILABLE) {
            dish.setStatus(Dish.DishStatus.DISCONTINUED);
        } else if (dish.getStatus() == Dish.DishStatus.DISCONTINUED) {
            dish.setStatus(Dish.DishStatus.AVAILABLE);
        }
        
        Dish savedDish = dishRepository.save(dish);
        if (oldStatus != Dish.DishStatus.AVAILABLE && savedDish.getStatus() == Dish.DishStatus.AVAILABLE) {
            Set<Long> userIds = getActiveStudentIds();
            for (Long userId : userIds) {
                notificationService.sendNotification(
                    userId,
                    "菜品上架",
                    "菜品【" + savedDish.getName() + "】已上架，快去看看吧！",
                    com.school.canteen.entity.Notification.NotificationType.DISH,
                    com.school.canteen.entity.Notification.NotificationScene.DISH_ON_SHELF,
                    com.school.canteen.entity.Notification.BizType.DISH,
                    savedDish.getId()
                );
            }
        }
    }
    
    @Override
    @Cacheable(value = "dishes", key = "'categories'")
    public List<String> getAllCategories() {
        // 返回菜品类型枚举的中文名称，而不是数据库中的菜系分类
        return List.of("主食", "菜品", "汤类", "小吃", "饮品");
    }
    
    @Override
    @Transactional
    @CacheEvict(value = "dishes_v7", key = "#dishId")
    public Dish setPromotion(Long dishId, Map<String, Object> promotionData) {
        Objects.requireNonNull(dishId, "菜品ID不能为空");
        Objects.requireNonNull(promotionData, "促销数据不能为空");
        
        Dish dish = dishRepository.findById(dishId)
                .orElseThrow(() -> new RuntimeException("菜品不存在"));
        
        // 设置促销状态
        Boolean isPromotion = (Boolean) promotionData.get("isPromotion");
        if (isPromotion != null) {
            dish.setIsPromotion(isPromotion);
        }

        // 设置促销类型
        if (promotionData.containsKey("promotionType")) {
            dish.setPromotionType((String) promotionData.get("promotionType"));
        }

        // 设置赠品ID
        if (promotionData.containsKey("giftDishId")) {
            Object giftIdObj = promotionData.get("giftDishId");
            if (giftIdObj instanceof Number) {
                dish.setGiftDishId(((Number) giftIdObj).longValue());
            } else if (giftIdObj instanceof String && !((String) giftIdObj).isEmpty()) {
                dish.setGiftDishId(Long.parseLong((String) giftIdObj));
            } else {
                dish.setGiftDishId(null);
            }
        }
        
        // 设置促销价格
        if (promotionData.containsKey("promotionPrice")) {
            try {
                Object priceObj = promotionData.get("promotionPrice");
                if (priceObj != null) {
                    BigDecimal promotionPrice;
                    // 更安全的类型转换方式
                    if (priceObj instanceof BigDecimal) {
                        promotionPrice = (BigDecimal) priceObj;
                    } else if (priceObj instanceof Number) {
                        promotionPrice = BigDecimal.valueOf(((Number) priceObj).doubleValue());
                    } else {
                        // 尝试将字符串直接转换为BigDecimal
                        String priceStr = priceObj.toString().trim();
                        if (!priceStr.isEmpty()) {
                            promotionPrice = new BigDecimal(priceStr);
                        } else {
                            throw new NumberFormatException("价格字符串为空");
                        }
                    }
                    
                    // 验证价格是否有效
                    if (promotionPrice != null && promotionPrice.compareTo(BigDecimal.ZERO) >= 0) {
                        dish.setPromotionPrice(promotionPrice);
                    } else {
                        throw new RuntimeException("促销价格必须大于等于0");
                    }
                }
            } catch (NumberFormatException e) {
                throw new RuntimeException("促销价格格式不正确，请输入有效的数字");
            } catch (Exception e) {
                throw new RuntimeException("设置促销价格时发生错误: " + e.getMessage());
            }
        }

        // 设置开始时间
        if (promotionData.containsKey("promotionStart")) {
            Object startObj = promotionData.get("promotionStart");
            if (startObj != null && !startObj.toString().isEmpty()) {
                try {
                    String startTimeStr = startObj.toString();
                    // 处理可能的时间格式
                    if (startTimeStr.length() == 10) { // yyyy-MM-dd
                        startTimeStr += " 00:00:00";
                    }
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                    dish.setPromotionStart(LocalDateTime.parse(startTimeStr, formatter));
                } catch (Exception e) {
                    throw new RuntimeException("开始时间格式错误，应为 yyyy-MM-dd HH:mm:ss");
                }
            } else {
                dish.setPromotionStart(null);
            }
        }

        // 设置结束时间
        if (promotionData.containsKey("promotionEnd")) {
            Object endObj = promotionData.get("promotionEnd");
            if (endObj != null && !endObj.toString().isEmpty()) {
                try {
                    String endTimeStr = endObj.toString();
                    // 处理可能的时间格式
                    if (endTimeStr.length() == 10) { // yyyy-MM-dd
                        endTimeStr += " 23:59:59";
                    }
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                    dish.setPromotionEnd(LocalDateTime.parse(endTimeStr, formatter));
                } catch (Exception e) {
                    throw new RuntimeException("结束时间格式错误，应为 yyyy-MM-dd HH:mm:ss");
                }
            } else {
                dish.setPromotionEnd(null);
            }
        }
    
        
        return dishRepository.save(dish);
    }
    
    @Override
    public Map<String, Object> getDishRatings(Long dishId) {
        Objects.requireNonNull(dishId, "菜品ID不能为空");
        
        // 验证菜品是否存在
        Dish dish = dishRepository.findById(dishId)
                .orElseThrow(() -> new RuntimeException("菜品不存在"));
        
        Map<String, Object> ratingsData = new HashMap<>();
        
        // 基本评分信息
        ratingsData.put("dishId", dishId);
        ratingsData.put("dishName", dish.getName());
        ratingsData.put("averageRating", dish.getAverageRating());
        ratingsData.put("ratingCount", dish.getRatingCount());
        
        String sql = "SELECT " +
                "AVG(r.taste_rating) as avgTasteRating, " +
                "AVG(r.portion_rating) as avgPortionRating, " +
                "AVG(r.price_rating) as avgPriceRating, " +
                "AVG(r.hygiene_rating) as avgHygieneRating, " +
                "AVG(ri.rating) as avgOverallRating, " +
                "COUNT(*) as totalReviews, " +
                "MAX(ri.rating) as maxRating, " +
                "MIN(ri.rating) as minRating " +
                "FROM review_items ri " +
                "JOIN reviews r ON r.id = ri.review_id " +
                "WHERE ri.dish_id = ? AND r.status = 'NORMAL'";
        
        Map<String, Object> stats = jdbcTemplate.queryForMap(sql, dishId);
        
        // 各维度评分统计
        ratingsData.put("dimensionRatings", Map.of(
                "taste", stats.get("avgTasteRating") != null ? stats.get("avgTasteRating") : 0.0,
                "portion", stats.get("avgPortionRating") != null ? stats.get("avgPortionRating") : 0.0,
                "price", stats.get("avgPriceRating") != null ? stats.get("avgPriceRating") : 0.0,
                "hygiene", stats.get("avgHygieneRating") != null ? stats.get("avgHygieneRating") : 0.0,
                "overall", stats.get("avgOverallRating") != null ? stats.get("avgOverallRating") : 0.0
        ));
        
        // 评分分布（1-5星的数量）
        Map<Integer, Integer> ratingDistribution = new HashMap<>();
        for (int i = 1; i <= 5; i++) {
            final int star = i;
            String countSql = "SELECT COUNT(*) FROM review_items ri " +
                    "JOIN reviews r ON r.id = ri.review_id " +
                    "WHERE ri.dish_id = ? AND ri.rating = ? AND r.status = 'NORMAL'";
            Integer count = jdbcTemplate.queryForObject(countSql, Integer.class, dishId, star);
            ratingDistribution.put(star, count);
        }
        ratingsData.put("ratingDistribution", ratingDistribution);
        
        // 最近评价（获取最新的5条评价）
        String recentReviewsSql = "SELECT r.comment as review_text, ri.rating as overall_rating, r.create_time " +
                "FROM review_items ri " +
                "JOIN reviews r ON r.id = ri.review_id " +
                "WHERE ri.dish_id = ? AND r.comment IS NOT NULL AND r.comment != '' AND r.status = 'NORMAL' " +
                "ORDER BY r.create_time DESC LIMIT 5";
        List<Map<String, Object>> recentReviews = jdbcTemplate.queryForList(recentReviewsSql, dishId);
        ratingsData.put("recentReviews", recentReviews);
        
        return ratingsData;
    }

    private final org.springframework.data.redis.core.StringRedisTemplate stringRedisTemplate;
    
    @Override
    @Transactional
    @org.springframework.scheduling.annotation.Scheduled(cron = "0 0 8 * * ?") // 每天早上8点执行
    public void resetDailyInventory() {
        checkAndResetDailyInventory();
    }

    @Override
    @Transactional
    public void checkAndResetDailyInventory() {
        // 获取今天的日期，格式 yyyy-MM-dd
        String today = java.time.LocalDate.now().toString();
        String redisKey = "daily_inventory_reset:" + today;
        
        // 尝试设置 Key，如果 Key 不存在则设置成功并返回 true（表示今天还没重置过）
        // 设置过期时间为 24 小时
        Boolean isFirstRun = stringRedisTemplate.opsForValue().setIfAbsent(
            redisKey, 
            "true", 
            java.time.Duration.ofHours(24)
        );
        
        if (Boolean.TRUE.equals(isFirstRun)) {
            // 生成昨日快照 (在重置库存前执行)
            try {
                statisticsService.generateDailySnapshot(java.time.LocalDate.now().minusDays(1));
            } catch (Exception e) {
                e.printStackTrace();
            }

            // 如果是第一次运行，执行库存重置（包含前一天售罄的菜品）
            dishRepository.resetDailyInventory(
                    List.of(Dish.DishStatus.AVAILABLE, Dish.DishStatus.SOLD_OUT),
                    Dish.DishStatus.AVAILABLE
            );
        }
    }
}
