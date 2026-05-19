package com.school.canteen.service.impl;

import com.school.canteen.entity.Order;
import com.school.canteen.entity.OrderItem;
import com.school.canteen.entity.User;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.repository.NotificationRepository;
import com.school.canteen.repository.OrderRepository;
import com.school.canteen.repository.OrderStatusHistoryRepository;
import com.school.canteen.repository.PromotionRepository;
import com.school.canteen.repository.RewardExchangeRepository;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.service.DishService;
import com.school.canteen.service.HealthGoalRecommendationService;
import com.school.canteen.service.NotificationService;
import com.school.canteen.service.OrderEventService;
import com.school.canteen.service.PriceCalculationService;
import com.school.canteen.service.ReviewService;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class OrderServiceImplPaymentTest {

    @Test
    void markOrderPaidByNumberReturnsAlreadyPaidOrderForSameTransactionWithoutSideEffects() {
        OrderRepository orderRepository = mock(OrderRepository.class);
        OrderStatusHistoryRepository historyRepository = mock(OrderStatusHistoryRepository.class);
        OrderEventService orderEventService = mock(OrderEventService.class);
        OrderServiceImpl service = service(orderRepository, historyRepository, orderEventService);
        Order paid = paidOrder("ORD4001", "WECHAT", "MOCK-ORD4001-1");
        when(orderRepository.findByOrderNumber("ORD4001")).thenReturn(paid);
        when(orderRepository.findById(40L)).thenReturn(Optional.of(paid));

        Order result = service.markOrderPaidByNumber("ORD4001", "WECHAT", "MOCK-ORD4001-1", LocalDateTime.now());

        assertSame(paid, result);
        verify(orderRepository, never()).save(any());
        verify(historyRepository, never()).save(any());
        verify(orderEventService, never()).publishOrderUpdate(any());
    }

    @Test
    void markOrderPaidByNumberRejectsAlreadyPaidOrderWithDifferentTransaction() {
        OrderRepository orderRepository = mock(OrderRepository.class);
        OrderStatusHistoryRepository historyRepository = mock(OrderStatusHistoryRepository.class);
        OrderEventService orderEventService = mock(OrderEventService.class);
        OrderServiceImpl service = service(orderRepository, historyRepository, orderEventService);
        Order paid = paidOrder("ORD4002", "WECHAT", "MOCK-ORD4002-OLD");
        when(orderRepository.findByOrderNumber("ORD4002")).thenReturn(paid);
        when(orderRepository.findById(40L)).thenReturn(Optional.of(paid));

        BusinessException exception = assertThrows(
            BusinessException.class,
            () -> service.markOrderPaidByNumber("ORD4002", "WECHAT", "MOCK-ORD4002-NEW", LocalDateTime.now())
        );

        assertEquals("PAYMENT_CONFLICT", exception.getCode());
        verify(orderRepository, never()).save(any());
        verify(historyRepository, never()).save(any());
        verify(orderEventService, never()).publishOrderUpdate(any());
    }

    private OrderServiceImpl service(OrderRepository orderRepository,
                                     OrderStatusHistoryRepository historyRepository,
                                     OrderEventService orderEventService) {
        OrderServiceImpl service = new OrderServiceImpl(
            orderRepository,
            mock(NotificationRepository.class),
            historyRepository,
            orderEventService,
            mock(ReviewService.class),
            mock(RewardExchangeRepository.class),
            mock(DishService.class),
            mock(PromotionRepository.class),
            mock(HealthGoalRecommendationService.class),
            mock(PriceCalculationService.class),
            mock(UserRepository.class)
        );
        ReflectionTestUtils.setField(service, "notificationService", mock(NotificationService.class));
        return service;
    }

    private Order paidOrder(String orderNumber, String paymentMethod, String transactionId) {
        Order order = new Order();
        order.setId(40L);
        order.setOrderNumber(orderNumber);
        order.setStatus(Order.OrderStatus.PAID);
        User user = new User();
        user.setId(8L);
        order.setUser(user);
        OrderItem item = new OrderItem();
        item.setOrder(order);
        item.setPaymentMethod(paymentMethod);
        item.setPaymentTransactionId(transactionId);
        item.setPaymentTime(LocalDateTime.now());
        order.setOrderItems(List.of(item));
        return order;
    }
}
