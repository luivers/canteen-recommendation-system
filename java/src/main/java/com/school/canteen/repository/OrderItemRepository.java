package com.school.canteen.repository;

import com.school.canteen.entity.Order;
import com.school.canteen.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/** 订单子项数据访问层 */
@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {

    @Query("""
            SELECT oi
            FROM OrderItem oi
            JOIN FETCH oi.dish d
            JOIN oi.order o
            WHERE o.user.id = :userId
              AND o.status IN :statuses
              AND oi.createTime BETWEEN :start AND :end
            """)
    List<OrderItem> findByUserIdAndCreateTimeBetweenFetchDish(
            @Param("userId") Long userId,
            @Param("statuses") List<Order.OrderStatus> statuses,
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end
    );

    // 按套餐ID统计订单项数量
    long countByComboId(Long comboId);

    // 统计所有菜品的销量（从有效订单中）
    @Query(value = "SELECT oi.dish_id as dishId, SUM(oi.quantity) as salesCount " +
            "FROM order_items oi " +
            "JOIN orders o ON oi.order_id = o.id " +
            "WHERE o.status IN ('PAID', 'PREPARING', 'READY', 'COMPLETED') " +
            "GROUP BY oi.dish_id", nativeQuery = true)
    List<Map<String, Object>> findAllDishSalesCount();

    // 统计指定菜品的销量
    @Query(value = "SELECT COALESCE(SUM(oi.quantity), 0) " +
            "FROM order_items oi " +
            "JOIN orders o ON oi.order_id = o.id " +
            "WHERE o.status IN ('PAID', 'PREPARING', 'READY', 'COMPLETED') " +
            "AND oi.dish_id = :dishId", nativeQuery = true)
    Long findSalesCountByDishId(@Param("dishId") Long dishId);
}

