package com.school.canteen.repository;

import com.school.canteen.entity.Order;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/** 订单数据访问层 */
@Repository
public interface OrderRepository extends JpaRepository<Order, Long>, JpaSpecificationExecutor<Order> {
    
    // 根据订单号查询
    Order findByOrderNumber(String orderNumber);
    
    // 查找用户的所有订单
    @Query("SELECT o FROM Order o WHERE o.user.id = :userId")
    List<Order> findByUserId(@Param("userId") Long userId);

    boolean existsByUser_Id(Long userId);
    
    // 查找用户的已完成订单
    @Query("SELECT o FROM Order o WHERE o.user.id = :userId AND o.status = 'COMPLETED'")
    List<Order> findCompletedOrdersByUserId(@Param("userId") Long userId);
    
    // 按状态分页查找订单
    @Query("SELECT DISTINCT o FROM Order o JOIN o.orderItems oi WHERE o.status = :status ORDER BY o.id DESC")
    Page<Order> findByStatusOrderByCreateTimeDesc(@Param("status") Order.OrderStatus status, Pageable pageable);
    
    // 查找最近的订单
    @Query("SELECT DISTINCT o FROM Order o JOIN o.orderItems oi WHERE oi.createTime >= :startDate ORDER BY o.id DESC")
    List<Order> findRecentOrders(@Param("startDate") LocalDateTime startDate);
    
    // 根据创建时间范围查询订单
    @Query("SELECT DISTINCT o FROM Order o JOIN o.orderItems oi WHERE oi.createTime BETWEEN :startDate AND :endDate ORDER BY o.id DESC")
    Page<Order> findByCreateTimeBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate, Pageable pageable);
    
    // 根据用户ID分页查询所有订单
    @Query("SELECT o FROM Order o WHERE o.user.id = :userId ORDER BY o.id DESC")
    Page<Order> findByUserIdOrderByCreateTimeDesc(@Param("userId") Long userId, Pageable pageable);
    
    // 根据用户ID和状态分页查询订单
    @Query("SELECT o FROM Order o WHERE o.user.id = :userId AND o.status = :status ORDER BY o.id DESC")
    Page<Order> findByUserIdAndStatusOrderByCreateTimeDesc(@Param("userId") Long userId, @Param("status") Order.OrderStatus status, Pageable pageable);
    
    // 根据用户ID、状态和日期范围分页查询订单
    @Query("SELECT DISTINCT o FROM Order o JOIN o.orderItems oi WHERE o.user.id = :userId AND o.status = :status AND oi.createTime BETWEEN :startDate AND :endDate ORDER BY o.id DESC")
    Page<Order> findByUserIdAndStatusAndCreateTimeBetween(@Param("userId") Long userId, @Param("status") Order.OrderStatus status, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate, Pageable pageable);

    // 根据状态和日期范围分页查询订单（管理员）
    @Query("SELECT DISTINCT o FROM Order o JOIN o.orderItems oi WHERE o.status = :status AND oi.createTime BETWEEN :startDate AND :endDate ORDER BY o.id DESC")
    Page<Order> findByStatusAndCreateTimeBetween(@Param("status") Order.OrderStatus status, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate, Pageable pageable);

    // 根据用户ID和日期范围分页查询订单
    @Query("SELECT DISTINCT o FROM Order o JOIN o.orderItems oi WHERE o.user.id = :userId AND oi.createTime BETWEEN :startDate AND :endDate ORDER BY o.id DESC")
    Page<Order> findByUserIdAndCreateTimeBetweenOrderByCreateTimeDesc(@Param("userId") Long userId, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate, Pageable pageable);
    
    // 查询在时间窗口内、预约取餐、已就绪的订单（用于预约提醒）
    @Query("SELECT DISTINCT o FROM Order o JOIN o.orderItems oi WHERE o.status = :status AND oi.pickupType = :pickupType AND oi.pickupTime BETWEEN :start AND :end")
    List<Order> findByStatusAndPickupTypeAndPickupTimeBetween(@Param("status") Order.OrderStatus status, @Param("pickupType") Order.PickupType pickupType, @Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    // 获取用户点过的所有菜品ID
    @Query("SELECT DISTINCT oi.dish.id FROM Order o JOIN o.orderItems oi WHERE o.user.id = :userId")
    List<Long> findOrderedDishIdsByUserId(@Param("userId") Long userId);

    // 统计每个用户的订单数量与总消费
    @Query("SELECT o.user.id, COUNT(o), COALESCE(SUM(o.totalAmount), 0) FROM Order o WHERE o.user.id IN :userIds AND o.status IN :statuses GROUP BY o.user.id")
    List<Object[]> aggregateByUserIds(@Param("userIds") List<Long> userIds, @Param("statuses") List<Order.OrderStatus> statuses);

    // 按促销ID统计订单数量（基于套餐关联）
    @Query("SELECT COUNT(DISTINCT o.id) FROM Order o JOIN o.orderItems oi JOIN oi.combo c WHERE c.promotion.id = :promotionId")
    long countByPromotionId(@Param("promotionId") Long promotionId);

    // 统计某菜品总销量（如果Order实体中没有createTime，我们直接统计总销量即可作为参考）
    @Query("SELECT COALESCE(SUM(oi.quantity), 0) FROM OrderItem oi JOIN oi.order o WHERE oi.dish.id = :dishId AND o.status IN ('PAID', 'PREPARING', 'READY', 'COMPLETED')")
    Integer getDishTotalSales(@Param("dishId") Long dishId);

    // 统计某菜品今日销量
    @Query("SELECT COALESCE(SUM(oi.quantity), 0) FROM OrderItem oi JOIN oi.order o WHERE oi.dish.id = :dishId AND o.status IN ('PAID', 'PREPARING', 'READY', 'COMPLETED') AND oi.createTime >= :startOfDay")
    Integer getDishTodaySales(@Param("dishId") Long dishId, @Param("startOfDay") LocalDateTime startOfDay);
}
