package com.school.canteen.service;

import com.school.canteen.entity.Order;
import com.school.canteen.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;


/** 订单管理服务接口 */
public interface OrderService {
    
    /**
     * 创建订单
     */
    Order createOrder(Order orderData, User currentUser);
    
    /**
     * 获取所有订单（分页）
     */
    Page<Order> getAllOrders(Pageable pageable);
    
    /**
     * 根据状态获取订单
     */
    Page<Order> getOrdersByStatus(String status, Pageable pageable);
    
    /**
     * 根据日期范围获取订单
     */
    Page<Order> getOrdersByDateRange(LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);
    
    /**
     * 根据ID获取订单详情
     */
    Order getOrderById(Long orderId);
    
    /**
     * 取消订单
     */
    void cancelOrder(Long orderId);

    void deleteOrder(Long orderId);
    
    /**
     * 确认取餐
     */
    void confirmPickup(Long orderId);
    
    /**
     * 开始制作
     */
    void startPreparation(Long orderId);
    
    /**
     * 制作完成
     */
    void finishPreparation(Long orderId);
    
    /**
     * 根据用户ID获取所有订单（分页）
     */
    Page<Order> getOrdersByUserId(Long userId, Pageable pageable);
    
    /**
     * 根据用户ID和状态获取订单
     */
    Page<Order> getOrdersByUserIdAndStatus(Long userId, String status, Pageable pageable);
    
    /**
     * 根据用户ID和日期范围获取订单
     */
    Page<Order> getOrdersByUserIdAndDateRange(Long userId, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);
    
    /**
     * 根据用户ID、状态和日期范围获取订单
     */
    Page<Order> getOrdersByUserIdAndStatusAndDateRange(Long userId, String status, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);
    
    /**
     * 根据状态和日期范围获取订单（管理员）
     */
    Page<Order> getOrdersByStatusAndDateRange(String status, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);

    /**
     * 高级搜索订单（支持订单号、用户名、状态、时间范围组合查询）
     */
    Page<Order> searchOrders(String orderNumber, String username, String status, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);
    
    /**
     * 根据ID获取订单详情
     */
    Order markOrderPaid(Long orderId, String paymentMethod, String transactionId, LocalDateTime paidAt);
    
    /**
     * 标记订单已支付（按订单号）
     */
    Order markOrderPaidByNumber(String orderNumber, String paymentMethod, String transactionId, LocalDateTime paidAt);
}
