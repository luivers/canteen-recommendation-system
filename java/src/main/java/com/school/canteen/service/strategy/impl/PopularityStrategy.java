package com.school.canteen.service.strategy.impl;

import com.school.canteen.entity.Dish;
import com.school.canteen.repository.DishRepository;
import com.school.canteen.repository.OrderRepository;
import com.school.canteen.service.strategy.RecommendationStrategy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Component;

import java.util.List;

/** 热门推荐策略，基于菜品实际销量和评分进行排序推荐 */
@Component
public class PopularityStrategy implements RecommendationStrategy {

    @Autowired
    private DishRepository dishRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Override
    public List<Dish> recommend(Long userId, int limit) {
        int safeLimit = Math.max(1, limit);
        List<Dish> dishes = dishRepository.findPopularDishesBySales(PageRequest.of(0, safeLimit));
        for (Dish dish : dishes) {
            if (dish == null || dish.getId() == null) {
                continue;
            }
            Integer sales = orderRepository.getDishTotalSales(dish.getId());
            dish.setSalesCount(sales == null ? 0 : sales);
        }
        return dishes;
    }

    @Override
    public String getStrategyType() {
        return "popular";
    }
}
