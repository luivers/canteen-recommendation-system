package com.school.canteen.service.strategy.impl;

import com.school.canteen.entity.Dish;
import com.school.canteen.repository.DishRepository;
import com.school.canteen.service.WeatherService;
import com.school.canteen.service.strategy.RecommendationStrategy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.Month;
import java.util.*;
import java.util.stream.Collectors;

/** 上下文感知推荐策略，结合天气、时段、季节等环境因素推荐菜品 */
@Component
public class ContextAwareStrategy implements RecommendationStrategy {

    @Autowired
    private DishRepository dishRepository;

    @Autowired
    private WeatherService weatherService;

    @Override
    public List<Dish> recommend(Long userId, int limit) {
        // 1. 获取上下文信息
        LocalTime nowTime = LocalTime.now();
        LocalDate nowDate = LocalDate.now();
        Month month = nowDate.getMonth();
        
        int temperature = weatherService.getCurrentTemperature();
        String weather = weatherService.getWeatherCondition();
        
        // 2. 获取所有可用菜品 (实际场景应先根据基础规则过滤，这里为演示全量打分)
        List<Dish> allDishes = dishRepository.findAll();
        
        // 3. 计算每个菜品的得分
        Map<Dish, Integer> dishScores = new HashMap<>();
        
        for (Dish dish : allDishes) {
            if (dish.getStatus() != Dish.DishStatus.AVAILABLE) continue;
            
            int score = 0;
            
            // --- 时间维度打分 ---
            score += scoreByTime(dish, nowTime);
            
            // --- 季节维度打分 ---
            score += scoreBySeason(dish, month);
            
            // --- 天气维度打分 ---
            score += scoreByWeather(dish, temperature, weather);
            
            dishScores.put(dish, score);
        }
        
        // 4. 排序并返回前 N 个
        return dishScores.entrySet().stream()
                .sorted(Map.Entry.<Dish, Integer>comparingByValue().reversed())
                .limit(limit)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }
// 1. 时间维度 (Time)
    private int scoreByTime(Dish dish, LocalTime time) {
        int score = 0;
        int hour = time.getHour();
        
        // 早餐 (06:00 - 10:00)
        if (hour >= 6 && hour < 10) {
            if (dish.getDishCategory() == Dish.DishCategory.SNACK || 
                dish.getDishCategory() == Dish.DishCategory.BEVERAGE) {
                score += 50;
            } else if (dish.getDishCategory() == Dish.DishCategory.MAIN_DISH) {
                // 某些清淡主食也可以
                if (isLight(dish)) score += 20;
            }
        } 
        // 午餐 (11:00 - 14:00) & 晚餐 (17:00 - 20:00)
        else if ((hour >= 11 && hour < 14) || (hour >= 17 && hour < 20)) {
            if (dish.getDishCategory() == Dish.DishCategory.MAIN_DISH || 
                dish.getDishCategory() == Dish.DishCategory.MEAT_DISH ||
                dish.getDishCategory() == Dish.DishCategory.VEGETABLE) {
                score += 50;
            }
            if (dish.getDishCategory() == Dish.DishCategory.SOUP) {
                score += 30;
            }
        }
        // 下午茶 (14:00 - 17:00)
        else if (hour >= 14 && hour < 17) {
            if (dish.getDishCategory() == Dish.DishCategory.SNACK || 
                dish.getDishCategory() == Dish.DishCategory.BEVERAGE) {
                score += 60;
            }
        }
        // 夜宵 (21:00+)
        else if (hour >= 21 || hour < 5) {
            if (dish.getDishCategory() == Dish.DishCategory.SNACK) {
                score += 50; // 烧烤、小吃
            }
        }
        
        return score;
    }
// 2. 季节维度 (Season)
    private int scoreBySeason(Dish dish, Month month) {
        int score = 0;
        // 夏季 (6,7,8月)
        if (month == Month.JUNE || month == Month.JULY || month == Month.AUGUST) {
            // 推荐清淡、饮品
            if (isLight(dish)) score += 20;
            if (dish.getDishCategory() == Dish.DishCategory.BEVERAGE) score += 20;
            // 减分: 高热量
            if (dish.getCalories() != null && dish.getCalories() > 800) score -= 20;
        }
        // 冬季 (12,1,2月)
        else if (month == Month.DECEMBER || month == Month.JANUARY || month == Month.FEBRUARY) {
            // 推荐高热量、汤品、肉类
            if (dish.getDishCategory() == Dish.DishCategory.SOUP) score += 30;
            if (dish.getDishCategory() == Dish.DishCategory.MEAT_DISH) score += 20;
            if (dish.getCalories() != null && dish.getCalories() > 500) score += 10;
        }
        return score;
    }
// 3. 天气维度 (Weather)
    private int scoreByWeather(Dish dish, int temp, String weather) {
        int score = 0;
        
        // 寒冷 (<10度)
        if (temp < 10) {
            if (dish.getDishCategory() == Dish.DishCategory.SOUP) score += 20; // 暖身
            if (hasTag(dish, "辣")) score += 30; // 辣味驱寒
        }
        // 炎热 (>30度)
        else if (temp > 30) {
            if (dish.getDishCategory() == Dish.DishCategory.BEVERAGE) score += 30;
            if (hasTag(dish, "凉")) score += 30;
            if (isLight(dish)) score += 15;
            if (hasTag(dish, "辣")) score -= 10; // 太热不吃辣(假设)
        }
        
        // 雨雪天
        if ("RAINY".equals(weather) || "SNOWY".equals(weather)) {
            // 推荐方便食用的或者暖食
            if (dish.getDishCategory() == Dish.DishCategory.SOUP) score += 15;
        }
        
        return score;
    }

    private boolean isLight(Dish dish) {
        // 简单判断清淡: 蔬菜，或者卡路里低
        if (dish.getDishCategory() == Dish.DishCategory.VEGETABLE) return true;
        if (dish.getCalories() != null && dish.getCalories() < 400) return true;
        return hasTag(dish, "清淡");
    }

    private boolean hasTag(Dish dish, String tag) {
        if (dish.getTasteTags() == null) return false;
        for (String t : dish.getTasteTags()) {
            if (t.contains(tag)) return true;
        }
        return false;
    }

    @Override
    public String getStrategyType() {
        return "context";
    }
}
