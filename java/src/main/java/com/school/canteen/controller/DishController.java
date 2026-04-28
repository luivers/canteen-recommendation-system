package com.school.canteen.controller;

import com.school.canteen.entity.Dish;
import com.school.canteen.dto.DishDTO;
import com.school.canteen.service.DishService;
import com.school.canteen.service.StatisticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

import org.springframework.beans.BeanUtils;

import java.util.List;
import java.util.Map;

import com.alibaba.excel.EasyExcel;
import com.school.canteen.dto.export.DishExportVO;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.time.format.DateTimeFormatter;
import java.time.LocalDateTime;

/** 菜品控制器 — 菜品 CRUD、搜索筛选、库存管理、促销设置、Excel 导出 */
@RestController
@RequestMapping("/api/dishes")
@RequiredArgsConstructor
public class DishController {
    
    private final DishService dishService;
    private final StatisticsService statisticsService;
    
    /**
     * 获取菜品详情
     */
    @GetMapping("/{dishId}")
    public ResponseEntity<?> getDish(@PathVariable Long dishId) {
        try {
            Dish dish = dishService.getDishById(dishId);
            return ResponseEntity.ok(Map.of(
                    "data", dish,
                    "message", "获取菜品详情成功",
                    "code", "DISH_FETCHED"
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "message", e.getMessage(),
                    "code", "DISH_NOT_FOUND"
            ));
        }
    }

    /**
     * 创建菜品
     */
    @PostMapping
    public ResponseEntity<?> createDish(@Valid @RequestBody DishDTO dishDTO) {
        try {
            Dish dish = convertToEntity(dishDTO);
            Dish createdDish = dishService.createDish(dish);
            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                    "data", createdDish,
                    "message", "菜品创建成功",
                    "code", "DISH_CREATED"
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "message", e.getMessage(),
                    "code", "DISH_CREATE_FAILED"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "message", "创建菜品时发生错误",
                    "code", "INTERNAL_ERROR"
            ));
        }
    }

    /**
     * 更新菜品信息
     */
    @PutMapping("/{dishId}")
    public ResponseEntity<?> updateDish(@PathVariable Long dishId, @RequestBody DishDTO dishDTO) {
        try {
            Dish dishDetails = convertToEntity(dishDTO);
            Dish updatedDish = dishService.updateDish(dishId, dishDetails);
            return ResponseEntity.ok(Map.of(
                    "data", updatedDish,
                    "message", "菜品更新成功",
                    "code", "DISH_UPDATED"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "message", e.getMessage(),
                    "code", "DISH_UPDATE_FAILED"
            ));
        }
    }

    /**
     * 将DTO转换为实体对象
     */
    private Dish convertToEntity(DishDTO dto) {
        Dish dish = new Dish();
        // 使用 BeanUtils 复制属性，减少手动 set 代码
        // 注意：BeanUtils 只会复制同名且类型兼容的属性
        // dishCategory 和 status 是枚举类型，BeanUtils 不会处理 String 到 Enum 的自动转换，需要手动处理
        if (dto != null) {
            BeanUtils.copyProperties(dto, dish);
        }
        
        // 手动处理枚举转换
        handleDishCategory(dish, dto);
        handleDishStatus(dish, dto);
        
        return dish;
    }
        //安全地解析分类字符串。
    private void handleDishCategory(Dish dish, DishDTO dto) {
        if (dto.getDishCategory() != null) {
            String categoryStr = dto.getDishCategory().trim().toUpperCase();
            // 兼容旧值
            if ("VEGETABLE_DISH".equals(categoryStr)) {
                categoryStr = "VEGETABLE";// 修正旧的枚举值命名
            }
            try {
                Dish.DishCategory enumVal = Dish.DishCategory.valueOf(categoryStr);
                dish.setDishCategory(enumVal);
            } catch (IllegalArgumentException e) {
                throw new RuntimeException("无效的菜品分类: " + dto.getDishCategory());
            }
        } else if (dto.getCategory() != null) {
             // 尝试从 category 字段解析（兼容前端某些情况）
             String categoryStr = dto.getCategory().trim().toUpperCase();
             if ("VEGETABLE_DISH".equals(categoryStr)) {
                categoryStr = "VEGETABLE";
             }
             try {
                Dish.DishCategory enumVal = Dish.DishCategory.valueOf(categoryStr);
                dish.setDishCategory(enumVal);
            } catch (IllegalArgumentException e) {
                // Ignore
            }
        }
    }
    
    /**
     * 将枚举转换为中文名称
     */
    private String mapEnumToName(Dish.DishCategory enumVal) {
        switch (enumVal) {
            case MAIN_DISH: return "主食";
            case MEAT_DISH: return "荤菜";
            case VEGETABLE: return "素菜";
            case SOUP: return "汤类";
            case SNACK: return "小吃";
            case BEVERAGE: return "饮品";
            case SIDE_DISH: return "菜品";
            default: return null;
        }
    }

    private void handleDishStatus(Dish dish, DishDTO dto) {
        if (dto.getStatus() != null) {
            try {
                dish.setStatus(Dish.DishStatus.valueOf(dto.getStatus()));
            } catch (IllegalArgumentException e) {
                 throw new RuntimeException("无效的菜品状态: " + dto.getStatus());
            }
        }
    }
    
    // 删除菜品
    @DeleteMapping("/{dishId}")
    public ResponseEntity<?> deleteDish(@PathVariable Long dishId) {
        try {
            dishService.deleteDish(dishId);
            return ResponseEntity.ok(Map.of(
                    "message", "菜品删除成功",
                    "code", "DISH_DELETED"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "message", e.getMessage(),
                    "code", "DISH_DELETE_FAILED"
            ));
        }
    }
    
    // 获取所有分类
    @GetMapping("/categories")
    public ResponseEntity<List<String>> getAllCategories() {
        List<String> categories = dishService.getAllCategories();
        return ResponseEntity.ok(categories);
    }
    
    @GetMapping("/export")
    public void exportDishes(
            @RequestParam(required = false) Long canteenId,
            @RequestParam(required = false) Long windowId,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String cuisine,
            @RequestParam(required = false) String tag,
            @RequestParam(required = false) String keyword,
            HttpServletResponse response) throws IOException {

        List<Dish> dishes;
        if (keyword != null && !keyword.isBlank()) {
            dishes = dishService.searchDishes(keyword);
        } else {
            dishes = dishService.getAllDishes();
        }

        List<Dish> filtered = filterDishes(dishes, canteenId, windowId, category, cuisine, tag);
        
        // 补充销量信息
        Map<Long, Integer> salesMap = statisticsService.getDishSalesCount(canteenId, windowId);
        for (Dish dish : filtered) {
            if (dish.getId() == null) continue;
            dish.setSalesCount(salesMap.getOrDefault(dish.getId(), 0));
        }

        List<DishExportVO> exportList = filtered.stream().map(this::convertToExportVO).toList();

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("菜品列表_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")), "UTF-8").replaceAll("\\+", "%20");
        response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");

        EasyExcel.write(response.getOutputStream(), DishExportVO.class).sheet("菜品列表").doWrite(exportList);
    }

    private DishExportVO convertToExportVO(Dish dish) {
        DishExportVO vo = new DishExportVO();
        BeanUtils.copyProperties(dish, vo);
        if (dish.getDishCategory() != null) {
            vo.setCategory(mapEnumToName(dish.getDishCategory()));
        }
        if (dish.getCreateTime() != null) {
            vo.setCreateTime(dish.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        if (dish.getStatus() != null) {
            vo.setStatus(dish.getStatus().name());
        }
        return vo;
    }

    @GetMapping
    public ResponseEntity<?> getAllDishes(
            @RequestParam(required = false) Long canteenId,
            @RequestParam(required = false) Long windowId,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String cuisine,
            @RequestParam(required = false) String tag,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size) {
        List<Dish> dishes = dishService.getAllDishes();
        
        // 过滤逻辑
        List<Dish> filtered = filterDishes(dishes, canteenId, windowId, category, cuisine, tag);
        Map<Long, Integer> salesMap = statisticsService.getDishSalesCount(canteenId, windowId);
        for (Dish dish : filtered) {
            if (dish.getId() == null) continue;
            dish.setSalesCount(salesMap.getOrDefault(dish.getId(), 0));
        }
        if (page == null || size == null) {
            return ResponseEntity.ok(filtered);
        }

        int safeSize = size <= 0 ? 12 : size;
        int safePage = Math.max(0, page);
        int totalElements = filtered.size();
        int totalPages = totalElements == 0 ? 0 : (int) Math.ceil((double) totalElements / safeSize);
        int start = safePage * safeSize;
        int end = Math.min(start + safeSize, totalElements);
        List<Dish> content = start >= totalElements ? List.of() : filtered.subList(start, end);

        return ResponseEntity.ok(Map.of(
                "data", Map.of(
                        "content", content,
                        "totalElements", totalElements,
                        "totalPages", totalPages,
                        "size", safeSize,
                        "number", safePage
                ),
                "message", "获取菜品列表成功",
                "code", "DISHES_FETCHED"
        ));
    }
    
    @GetMapping("/category/{category}")
    public ResponseEntity<List<Dish>> getDishesByCategory(
            @PathVariable String category,
            @RequestParam(required = false) Long canteenId,
            @RequestParam(required = false) Long windowId) {
        List<Dish> dishes = dishService.getDishesByCategory(category);
        return ResponseEntity.ok(filterDishes(dishes, canteenId, windowId, category, null, null));
    }
    
    @GetMapping("/promotions")
    public ResponseEntity<List<Dish>> getPromotionDishes() {
        List<Dish> dishes = dishService.getPromotionDishes();
        return ResponseEntity.ok(dishes);
    }
    
    @GetMapping("/promotions/active")
    public ResponseEntity<List<Dish>> getActivePromotionDishes() {
        List<Dish> dishes = dishService.getActivePromotionDishes();
        return ResponseEntity.ok(dishes);
    }
    
    @GetMapping("/promotions/active/price-asc")
    public ResponseEntity<List<Dish>> getActivePromotionDishesOrderByPriceAsc() {
        List<Dish> dishes = dishService.getActivePromotionDishesOrderByPriceAsc();
        return ResponseEntity.ok(dishes);
    }
    
    @GetMapping("/promotions/active/rating-desc")
    public ResponseEntity<List<Dish>> getActivePromotionDishesOrderByRatingDesc() {
        List<Dish> dishes = dishService.getActivePromotionDishesOrderByRatingDesc();
        return ResponseEntity.ok(dishes);
    }
    
    @GetMapping("/top-rated")
    public ResponseEntity<List<Dish>> getTopRatedDishes(@RequestParam(defaultValue = "10") int limit) {
        List<Dish> dishes = dishService.getTopRatedDishes(limit);
        return ResponseEntity.ok(dishes);
    }
    
    /**
     * 获取热门菜品
     */
    @GetMapping("/popular")
    public ResponseEntity<List<Dish>> getPopularDishes(@RequestParam(defaultValue = "10") int limit) {
        List<Dish> dishes = dishService.getPopularDishes(limit);
        return ResponseEntity.ok(dishes);
    }
    
    /**
     * 获取热销菜品
     */
    @GetMapping("/hot")
    public ResponseEntity<List<Dish>> getHotDishes(@RequestParam(defaultValue = "10") int limit) {
        List<Dish> dishes = dishService.getHotDishes(limit);
        return ResponseEntity.ok(dishes);
    }
    
    @GetMapping("/search")
    public ResponseEntity<?> searchDishes(
            @RequestParam String keyword,
            @RequestParam(required = false) Long canteenId,
            @RequestParam(required = false) Long windowId,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String cuisine,
            @RequestParam(required = false) String tag,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        // 1. 获取所有匹配的菜品 (目前 Service 层只支持全量搜索)
        List<Dish> allDishes = dishService.searchDishes(keyword);
        
        // 2. 执行内存过滤
        List<Dish> filteredDishes = filterDishes(allDishes, canteenId, windowId, category, cuisine, tag);
        
        // 3. 执行内存分页
        int total = filteredDishes.size();
        int start = Math.min(page * size, total);
        int end = Math.min(start + size, total);
        List<Dish> pagedDishes = filteredDishes.subList(start, end);

        // 补充销量信息，避免搜索结果销量显示为0
        Map<Long, Integer> salesMap = statisticsService.getDishSalesCount(canteenId, windowId);
        for (Dish dish : pagedDishes) {
            if (dish.getId() == null) continue;
            dish.setSalesCount(salesMap.getOrDefault(dish.getId(), 0));
        }
        
        // 4. 构建 Page 响应结构 (保持与 getDishes 接口一致的结构)
        Map<String, Object> pageData = new java.util.HashMap<>();
        pageData.put("content", pagedDishes);
        pageData.put("totalElements", total);
        pageData.put("totalPages", (int) Math.ceil((double) total / size));
        pageData.put("number", page);
        pageData.put("size", size);
        pageData.put("empty", pagedDishes.isEmpty());
        
        // 5. 返回统一响应格式
        return ResponseEntity.ok(Map.of(
                "data", pageData,
                "message", "搜索菜品成功",
                "code", "DISHES_SEARCHED"
        ));
    }
    
    @PutMapping("/{dishId}/stock")
    public ResponseEntity<?> updateStock(@PathVariable Long dishId, @RequestParam Integer quantity, @RequestParam(required = false, defaultValue = "false") Boolean add) {
        try {
            Dish updatedDish = dishService.updateDishStock(dishId, quantity, add);
            return ResponseEntity.ok(Map.of(
                    "data", updatedDish,
                    "message", "库存更新成功",
                    "code", "STOCK_UPDATED"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "message", e.getMessage(),
                    "code", "STOCK_UPDATE_FAILED"
            ));
        }
    }
    
    // 设置菜品促销 (支持 PUT 和 PATCH)
    @RequestMapping(value = "/{dishId}/promotion", method = {RequestMethod.PUT, RequestMethod.PATCH})
    public ResponseEntity<?> setPromotion(@PathVariable Long dishId, @RequestBody Map<String, Object> promotionData) {
        try {
            Dish updatedDish = dishService.setPromotion(dishId, promotionData);
            return ResponseEntity.ok(Map.of(
                    "data", updatedDish,
                    "message", "促销设置成功",
                    "code", "PROMOTION_UPDATED"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "message", e.getMessage(),
                    "code", "PROMOTION_UPDATE_FAILED"
            ));
        }
    }
    
    // 切换菜品状态 (支持切换或指定状态)
    @PutMapping("/{dishId}/status")
    public ResponseEntity<?> toggleDishStatus(@PathVariable Long dishId, @RequestBody(required = false) Map<String, Boolean> statusData) {
        try {
            if (statusData != null && statusData.containsKey("available")) {
                // 如果前端传递了明确的状态，使用 updateDish 接口设置状态
                Boolean available = statusData.get("available");
                Dish dishDetails = new Dish();
                dishDetails.setStatus(Boolean.TRUE.equals(available) ? Dish.DishStatus.AVAILABLE : Dish.DishStatus.DISCONTINUED);
                dishService.updateDish(dishId, dishDetails);
                return ResponseEntity.ok(Map.of(
                        "message", "菜品状态更新成功",
                        "code", "DISH_STATUS_UPDATED"
                ));
            } else {
                // 否则执行原有的切换逻辑
                dishService.toggleDishStatus(dishId);
                return ResponseEntity.ok(Map.of(
                        "message", "菜品状态切换成功",
                        "code", "DISH_STATUS_TOGGLED"
                ));
            }
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "message", e.getMessage(),
                    "code", "DISH_STATUS_TOGGLE_FAILED"
            ));
        }
    }
    
    // 过滤菜品列表的私有方法
    private List<Dish> filterDishes(List<Dish> dishes, Long canteenId, Long windowId, String category, String cuisine, String tag) {
        return dishes.stream()
                // 按食堂ID过滤
                .filter(dish -> canteenId == null || 
                        (dish.getCanteenId() != null && 
                         dish.getCanteenId().equals(canteenId)))
                // 按窗口ID过滤
                .filter(dish -> windowId == null || 
                        (dish.getWindowId() != null && 
                         dish.getWindowId().equals(windowId)))
                // 按分类过滤 - 增强兼容性
                .filter(dish -> {
                    if (category == null) return true;
                    
                    boolean match = false;
                    
                    // 1. 尝试匹配 DishCategory 枚举
                    if (dish.getDishCategory() != null && 
                        dish.getDishCategory().name().equalsIgnoreCase(category)) {
                        match = true;
                    }
                    
                    return match;
                })
                // 按标签过滤
                .filter(dish -> {
                    if (tag == null || tag.isBlank()) return true;
                    if (dish.getTasteTags() == null || dish.getTasteTags().isEmpty()) return false;
                    String query = tag.trim();
                    String alias = mapTagAlias(query);
                    for (String t : dish.getTasteTags()) {
                        if (t == null) continue;
                        if (t.equalsIgnoreCase(query) || t.contains(query)) return true;
                        if (alias != null && (t.equalsIgnoreCase(alias) || t.contains(alias))) return true;
                    }
                    return false;
                })
                .toList();
    }

    private String mapTagAlias(String tag) {
        if (tag == null) return null;
        String trimmed = tag.trim();
        if (trimmed.isEmpty()) return null;
        String lower = trimmed.toLowerCase();
        if ("spicy".equals(lower)) return "辣";
        if ("sweet".equals(lower)) return "甜";
        if ("sour".equals(lower)) return "酸";
        if ("salty".equals(lower)) return "咸";
        if ("light".equals(lower)) return "清淡";
        if ("strong".equals(lower)) return "重口味";
        if ("辣".equals(trimmed)) return "spicy";
        if ("甜".equals(trimmed)) return "sweet";
        if ("酸".equals(trimmed)) return "sour";
        if ("咸".equals(trimmed)) return "salty";
        if ("清淡".equals(trimmed)) return "light";
        if ("重口味".equals(trimmed)) return "strong";
        return null;
    }
    
    /**
     * 获取菜品的详细评分信息，包括各维度评分统计
     */
    @GetMapping("/{dishId}/ratings")
    public ResponseEntity<?> getDishRatings(@PathVariable Long dishId) {
        try {
            Map<String, Object> ratingsData = dishService.getDishRatings(dishId);
            return ResponseEntity.ok(Map.of(
                    "data", ratingsData,
                    "message", "获取菜品评分信息成功",
                    "code", "RATINGS_FETCHED"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "message", e.getMessage(),
                    "code", "RATINGS_FETCH_FAILED"
            ));
        }
    }
}
