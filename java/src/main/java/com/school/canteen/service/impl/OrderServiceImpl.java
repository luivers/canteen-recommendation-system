package com.school.canteen.service.impl;

import com.school.canteen.entity.Dish;
import com.school.canteen.entity.Order;
import com.school.canteen.entity.OrderItem;
import com.school.canteen.entity.Promotion;
import com.school.canteen.entity.Reward;
import com.school.canteen.entity.RewardExchange;
import com.school.canteen.entity.User;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.util.SecurityUtils;
import com.school.canteen.repository.OrderRepository;
import com.school.canteen.repository.OrderStatusHistoryRepository;
import com.school.canteen.repository.PromotionRepository;
import com.school.canteen.repository.RewardExchangeRepository;
import com.school.canteen.service.DishService;
import com.school.canteen.service.HealthGoalRecommendationService;
import com.school.canteen.service.OrderService;
import com.school.canteen.service.NotificationService;
import com.school.canteen.service.PriceCalculationService;
import com.school.canteen.service.ReviewService;
import com.school.canteen.entity.OrderStatusHistory;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.Map;
import java.util.HashSet;
import java.util.HashMap;
import java.util.stream.Collectors;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;
import com.school.canteen.repository.UserRepository;

/** 订单管理服务实现类 */
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final com.school.canteen.repository.NotificationRepository notificationRepository;
    private final OrderStatusHistoryRepository orderStatusHistoryRepository;
    private final com.school.canteen.service.OrderEventService orderEventService;
    private final ReviewService reviewService;
    private final RewardExchangeRepository rewardExchangeRepository;
    private final DishService dishService;
    private final PromotionRepository promotionRepository;
    private final HealthGoalRecommendationService healthGoalRecommendationService;
    private final PriceCalculationService priceCalculationService;
    private final UserRepository userRepository;

    @Autowired
    @Lazy
    private NotificationService notificationService;

    private void sendWarningToAdmins(List<Map<String, Object>> warnings, String title) {
        if (warnings == null || warnings.isEmpty()) return;
        List<com.school.canteen.entity.User> admins = userRepository.findByRole(com.school.canteen.entity.User.UserRole.ADMIN);
        if (admins == null || admins.isEmpty()) return;
        
        for (Map<String, Object> warning : warnings) {
            String dishName = (String) warning.get("dishName");
            String alertMessage = (String) warning.get("alertMessage");
            Long dishId = warning.get("dishId") != null ? ((Number) warning.get("dishId")).longValue() : null;
            
            for (com.school.canteen.entity.User admin : admins) {
                if (admin == null || admin.getId() == null) continue;
                
                // 检查当天是否已经发过相同级别的预警
                // 为了简单起见，如果已经有未删除的同标题预警，我们就跳过（除非业务要求升级预警必须发）
                boolean alreadySent = notificationService.hasNotification(admin.getId(), title, dishId);
                if (alreadySent) {
                    // 对于红警（80%或库存0），我们希望确保管理员能看到。但如果不想改动太多无关代码，暂时保持原逻辑：
                    continue;
                }
                
                notificationService.sendNotification(
                    admin.getId(),
                    title,
                    "【" + dishName + "】" + alertMessage,
                    com.school.canteen.entity.Notification.NotificationType.WARNING,
                    com.school.canteen.entity.Notification.NotificationScene.INVENTORY_WARNING,
                    com.school.canteen.entity.Notification.BizType.DISH,
                    dishId
                );
            }
        }
    }

    private boolean isAdminOrManager(User user) {
        return user != null && (user.getRole() == User.UserRole.ADMIN || user.getRole() == User.UserRole.WINDOW_MANAGER);
    }

    private void ensureCurrentUserCanOperateOrder(Order order) {
        User currentUser = SecurityUtils.requireCurrentUser(userRepository);
        if (isAdminOrManager(currentUser)) {
            return;
        }
        if (order == null || order.getUser() == null || !Objects.equals(order.getUser().getId(), currentUser.getId())) {
            throw new BusinessException("FORBIDDEN", HttpStatus.FORBIDDEN, "No permission to operate this order");
        }
    }

    @Override
    @Transactional
    public Order createOrder(Order orderData, User currentUser) {
        Objects.requireNonNull(orderData, "订单数据不能为空");
        Objects.requireNonNull(currentUser, "用户不能为空");
        if (orderData.getOrderItems() == null || orderData.getOrderItems().isEmpty()) {
            throw new BusinessException("EMPTY_ORDER_ITEMS", "订单商品不能为空");
        }
        
        orderData.setUser(currentUser);
        
        // 如果没有设置订单号，生成一个
        if (orderData.getOrderNumber() == null || orderData.getOrderNumber().isEmpty()) {
            orderData.setOrderNumber("ORD" + System.currentTimeMillis());
        }
        
        // 计算订单项价格和订单总金额，考虑促销价格
        LocalDateTime now = LocalDateTime.now();
        BigDecimal goodsAmount = BigDecimal.ZERO;

        // 记录本订单使用的促销活动及其折扣金额
        Set<Long> promotionsUsedInThisOrder = new HashSet<>();
        Map<Long, Double> promotionDiscountMap = new HashMap<>();

        // 预处理：将套餐项拆分为具体的菜品项
        List<OrderItem> processedItems = new ArrayList<>();
        for (OrderItem item : orderData.getOrderItems()) {
            if (item.getCombo() != null && item.getDish() == null) {
                com.school.canteen.entity.Combo combo = item.getCombo();
                List<Dish> dishes = combo.getDishes();
                if (dishes != null && !dishes.isEmpty()) {
                    // 计算所有菜品的原价总和，用于分摊价格
                    BigDecimal totalOriginalPrice = BigDecimal.ZERO;
                    for (Dish d : dishes) {
                        totalOriginalPrice = totalOriginalPrice.add(d.getPrice());
                    }

                    BigDecimal comboPrice = BigDecimal.valueOf(combo.getPrice());
                    BigDecimal accumulatedPrice = BigDecimal.ZERO;

                    for (int i = 0; i < dishes.size(); i++) {
                        Dish dish = dishes.get(i);
                        OrderItem newItem = new OrderItem();
                        newItem.setOrder(orderData);
                        newItem.setCombo(combo);
                        newItem.setDish(dish);
                        newItem.setQuantity(item.getQuantity());
                        newItem.setIsGift(false);

                        // 分摊价格逻辑
                        BigDecimal unitPrice;
                        if (totalOriginalPrice.compareTo(BigDecimal.ZERO) == 0) {
                            unitPrice = BigDecimal.ZERO;
                        } else if (i == dishes.size() - 1) {
                            // 最后一项承担剩余金额，消除舍入误差
                            unitPrice = comboPrice.subtract(accumulatedPrice);
                        } else {
                            // 按原价比例分摊：comboPrice * (dishPrice / totalOriginalPrice)
                            unitPrice = comboPrice.multiply(dish.getPrice())
                                    .divide(totalOriginalPrice, 2, java.math.RoundingMode.HALF_UP);
                            accumulatedPrice = accumulatedPrice.add(unitPrice);
                        }
                        
                        // 防止价格为负（理论上不会，但安全起见）
                        if (unitPrice.compareTo(BigDecimal.ZERO) < 0) {
                            unitPrice = BigDecimal.ZERO;
                        }

                        newItem.setUnitPrice(unitPrice);
                        newItem.setSubtotal(unitPrice.multiply(new BigDecimal(item.getQuantity())));

                        processedItems.add(newItem);
                    }
                } else {
                    // 套餐内无菜品（异常情况），保持原样
                    processedItems.add(item);
                }
            } else {
                processedItems.add(item);
            }
        }
        orderData.setOrderItems(processedItems);
        
        for (OrderItem orderItem : orderData.getOrderItems()) {
            // 同步审计字段到 OrderItem
            orderItem.setCreateTime(LocalDateTime.now());
            orderItem.setUpdateTime(LocalDateTime.now());

            if (orderItem.getCombo() != null && orderItem.getDish() == null) {
                // 处理纯套餐逻辑（未拆分的异常情况或旧数据）
                com.school.canteen.entity.Combo combo = orderItem.getCombo();
                BigDecimal price = BigDecimal.valueOf(combo.getPrice());
                orderItem.setUnitPrice(price);
                orderItem.setSubtotal(price.multiply(new BigDecimal(orderItem.getQuantity())));
                // 套餐不参与单品促销计算，也不累加promotionsUsedInThisOrder
            } else if (orderItem.getDish() != null) {
                Dish dish = orderItem.getDish();
                
                // 如果是赠品，直接设置为0，不进行价格计算
                if (Boolean.TRUE.equals(orderItem.getIsGift())) {
                    orderItem.setUnitPrice(BigDecimal.ZERO);
                    orderItem.setSubtotal(BigDecimal.ZERO);
                } else if (orderItem.getCombo() != null) {
                    // 套餐拆分项：价格已在拆分时计算好，不再重新计算，也不参与单品促销
                    // 仅需确保subtotal正确（拆分时已设置）
                } else {
                    // 确定使用的价格：考虑单品促销和全场促销
                    BigDecimal priceToUse = priceCalculationService.calculatePrice(dish);
    
                    // --- 统计促销数据开始 ---
                    // 获取适用于该菜品的所有促销活动
                    List<Promotion> applicablePromos = priceCalculationService.getApplicablePromotions(dish);
                    
                    // 模拟计算每个促销活动的折扣金额，用于统计
                    BigDecimal tempPrice = dish.getPrice();
                    // 1. 处理单品促销逻辑 (与calculatePrice保持一致)
                    if (Boolean.TRUE.equals(dish.getIsPromotion()) &&
                        dish.getPromotionStart() != null && dish.getPromotionEnd() != null &&
                        (now.isAfter(dish.getPromotionStart()) || now.isEqual(dish.getPromotionStart())) && 
                        (now.isBefore(dish.getPromotionEnd()) || now.isEqual(dish.getPromotionEnd()))) {
                        tempPrice = dish.getPromotionPrice() != null ? dish.getPromotionPrice() : dish.getPrice();
                    }
    
                    for (Promotion p : applicablePromos) {
                        if (p.getDiscountValue() != null) {
                            // 计算当前促销带来的折扣额：当前价格 * (1 - 折扣率)
                            BigDecimal discountRate = BigDecimal.valueOf(p.getDiscountValue());
                            BigDecimal discountAmount = tempPrice.multiply(BigDecimal.ONE.subtract(discountRate));
                            
                            // 总折扣 = 单品折扣 * 数量
                            double totalDiscountForQty = discountAmount.multiply(new BigDecimal(orderItem.getQuantity())).doubleValue();
                            
                            promotionsUsedInThisOrder.add(p.getId());
                            promotionDiscountMap.merge(p.getId(), totalDiscountForQty, Double::sum);
                            
                            // 更新当前价格，继续下一个折扣计算
                            tempPrice = tempPrice.multiply(discountRate);
                        }
                    }
                    // --- 统计促销数据结束 ---
                    
                    // 设置订单项价格和小计
                    orderItem.setUnitPrice(priceToUse);
                    orderItem.setSubtotal(priceToUse.multiply(new BigDecimal(orderItem.getQuantity())));
                }
                
                // 同步窗口信息（从菜品信息中获取）
                if (dish.getWindowName() != null) {
                    orderItem.setWindowId(dish.getWindowId());
                    orderItem.setWindowName(dish.getWindowName());
                    orderItem.setWindowLocation(dish.getWindowLocation());
                }
            }
            
            // 累加总金额
            goodsAmount = goodsAmount.add(orderItem.getSubtotal());
            
            // 设置订单项所属订单
            orderItem.setOrder(orderData);
        }

        // --- 处理满减促销 (Full Reduction) ---
        // 只有当满减活动处于active状态且在有效期内，且订单金额满足条件时才应用
        List<Promotion> activePromotions = promotionRepository.findByStatus("active");
        List<Promotion> fullReductionPromos = activePromotions.stream()
            .filter(p -> "full_reduction".equalsIgnoreCase(p.getType()))
            .filter(p -> (now.isAfter(p.getStartTime()) || now.isEqual(p.getStartTime())) && 
                         (now.isBefore(p.getEndTime()) || now.isEqual(p.getEndTime())))
            .sorted((p1, p2) -> Double.compare(p2.getFullAmount(), p1.getFullAmount())) // 优先匹配门槛最高的
            .collect(Collectors.toList());

        for (Promotion p : fullReductionPromos) {
            if (p.getFullAmount() != null && p.getReduceAmount() != null) {
                BigDecimal fullAmount = BigDecimal.valueOf(p.getFullAmount());
                
                // 计算该满减促销适用的商品总额
                BigDecimal applicableAmount = BigDecimal.ZERO;
                for (OrderItem item : orderData.getOrderItems()) {
                    if (Boolean.TRUE.equals(item.getIsGift())) {
                        continue;
                    }
                    
                    boolean isApplicable = false;
                    if ("all".equalsIgnoreCase(p.getTargetType()) || p.getTargetType() == null) {
                        isApplicable = true;
                    } else if (item.getDish() != null) {
                        Dish dish = item.getDish();
                        if ("category".equalsIgnoreCase(p.getTargetType())) {
                            if (p.getTargetDishCategories() != null && dish.getDishCategory() != null) {
                                if (p.getTargetDishCategories().contains(dish.getDishCategory().name())) {
                                    isApplicable = true;
                                }
                            }
                        } else if ("specific".equalsIgnoreCase(p.getTargetType())) {
                            if (p.getDishes() != null && p.getDishes().stream().anyMatch(d -> d.getId().equals(dish.getId()))) {
                                isApplicable = true;
                            }
                        }
                    }
                    
                    if (isApplicable) {
                        applicableAmount = applicableAmount.add(item.getSubtotal());
                    }
                }
                
                if (applicableAmount.compareTo(fullAmount) >= 0) {
                    BigDecimal reduceAmount = BigDecimal.valueOf(p.getReduceAmount());
                    // 扣减金额（不能超过适用商品总额，防止负数，虽然通常满减门槛大于减免金额）
                    if (reduceAmount.compareTo(applicableAmount) > 0) {
                        reduceAmount = applicableAmount;
                    }
                    goodsAmount = goodsAmount.subtract(reduceAmount);
                    // 记录促销使用
                    promotionsUsedInThisOrder.add(p.getId());
                    promotionDiscountMap.merge(p.getId(), reduceAmount.doubleValue(), Double::sum);
                    // 只应用一个最优的满减优惠
                    break;
                }
            }
        }

        // 更新促销活动统计数据
        for (Long promoId : promotionsUsedInThisOrder) {
            Promotion p = promotionRepository.findById(promoId).orElse(null);
            if (p != null) {
                // 订单数+1 (每个订单只记一次)
                p.setOrderCount((p.getOrderCount() == null ? 0 : p.getOrderCount()) + 1);
                // 总优惠金额累加
                p.setTotalDiscount((p.getTotalDiscount() == null ? 0.0 : p.getTotalDiscount()) + promotionDiscountMap.getOrDefault(promoId, 0.0));
                promotionRepository.save(p);
            }
        }
        
        orderData.setGoodsAmount(goodsAmount);
        orderData.setVoucherDeduction(BigDecimal.ZERO);
        orderData.setPayableAmount(goodsAmount);
        orderData.setTotalAmount(goodsAmount);

        Long voucherExchangeId = orderData.getVoucherExchangeId();
        RewardExchange voucher = null;
        BigDecimal deduction = BigDecimal.ZERO;
        if (voucherExchangeId != null) {
            voucher = rewardExchangeRepository.findById(voucherExchangeId)
                    .orElseThrow(() -> new BusinessException("VOUCHER_NOT_FOUND", "代金券不存在"));
            if (voucher.getUser() == null || voucher.getUser().getId() == null || !voucher.getUser().getId().equals(currentUser.getId())) {
                throw new BusinessException("FORBIDDEN", "代金券不属于当前用户");
            }
            if (!RewardExchange.ExchangeStatus.COMPLETED.equals(voucher.getStatus())) {
                throw new BusinessException("VOUCHER_UNAVAILABLE", "代金券不可用");
            }
            if (Boolean.TRUE.equals(voucher.getUsed())) {
                throw new BusinessException("VOUCHER_USED", "代金券已使用");
            }
            Reward reward = voucher.getReward();
            if (reward == null || !Reward.RewardType.VOUCHER.equals(reward.getType())) {
                throw new BusinessException("VOUCHER_UNAVAILABLE", "所选奖励不是代金券");
            }
            if (reward.getValidFrom() != null && now.isBefore(reward.getValidFrom())) {
                throw new BusinessException("VOUCHER_UNAVAILABLE", "代金券未到可用时间");
            }
            if (reward.getValidTo() != null && now.isAfter(reward.getValidTo())) {
                throw new BusinessException("VOUCHER_UNAVAILABLE", "代金券已过期");
            }
            if (reward.getMinOrderAmount() != null && goodsAmount.compareTo(reward.getMinOrderAmount()) < 0) {
                throw new BusinessException("VOUCHER_UNAVAILABLE", "未满足代金券使用门槛");
            }

            BigDecimal faceValue = voucher.getFaceValueSnapshot() != null ? voucher.getFaceValueSnapshot() : reward.getFaceValue();
            if (faceValue == null || faceValue.compareTo(BigDecimal.ZERO) <= 0) {
                throw new BusinessException("VOUCHER_UNAVAILABLE", "代金券面值无效");
            }
            deduction = faceValue.min(goodsAmount);
            if (deduction.compareTo(BigDecimal.ZERO) < 0) deduction = BigDecimal.ZERO;

            orderData.setVoucherDeduction(deduction);
            orderData.setPayableAmount(goodsAmount.subtract(deduction));
            orderData.setTotalAmount(orderData.getPayableAmount());
        }
        
        // 保存订单
        Order saved = orderRepository.save(orderData);
        
        // --- 下单时直接检查库存并预警（新增逻辑） ---
        try {
            java.time.LocalDate today = java.time.LocalDate.now();
            for (OrderItem item : saved.getOrderItems()) {
                if (item.getDish() != null) {
                    Long dishId = item.getDish().getId();
                    String dishName = item.getDish().getName();
                    Integer currentStock = item.getDish().getStock();
                    
                    // 当天开始时间
                    LocalDateTime startOfDay = java.time.LocalDate.now().atStartOfDay();
                    
                    // 获取今日销量
                    Integer todaySales = orderRepository.getDishTodaySales(dishId, startOfDay);
                    if (todaySales == null) todaySales = 0;
                    
                    // 计算当天总库存（今日已售 + 当前剩余库存）
                    int totalSupply = todaySales + (currentStock != null ? currentStock : 0);
                    
                    // 下单如果把库存买空了
                    if (currentStock != null && currentStock <= 0) {
                        List<Map<String, Object>> warnings = new ArrayList<>();
                        Map<String, Object> warning = new HashMap<>();
                        warning.put("dishId", dishId);
                        warning.put("dishName", dishName);
                        warning.put("alertLevel", "CRITICAL");
                        warning.put("alertMessage", "库存已耗尽（剩余 0 份），需要立即补货");
                        warning.put("anomalyKind", "STOCK_OUT");
                        warnings.add(warning);
                        
                        // 发送库存耗尽预警通知
                        sendWarningToAdmins(warnings, "库存预警");
                    } 
                    // 按照销量占比进行预警（占当天剩余库存的百分比）
                    else if (currentStock != null && currentStock > 0) {
                        double salesRatio = (double) todaySales / currentStock;
                        if (salesRatio >= 0.8) {
                            List<Map<String, Object>> warnings = new ArrayList<>();
                            Map<String, Object> warning = new HashMap<>();
                            warning.put("dishId", dishId);
                            warning.put("dishName", dishName);
                            warning.put("alertLevel", "CRITICAL");
                            warning.put("alertMessage", "库存极低（剩余 " + currentStock + " 份，销量已达剩余库存的80%），请立即补货");
                            warning.put("anomalyKind", "STOCK_LOW_80");
                            warnings.add(warning);
                            
                            // 发送库存预警通知
                            sendWarningToAdmins(warnings, "库存预警");
                        } else if (salesRatio >= 0.5) {
                            List<Map<String, Object>> warnings = new ArrayList<>();
                            Map<String, Object> warning = new HashMap<>();
                            warning.put("dishId", dishId);
                            warning.put("dishName", dishName);
                            warning.put("alertLevel", "WARNING");
                            warning.put("alertMessage", "库存紧张（剩余 " + currentStock + " 份，销量已达剩余库存的50%），请注意补货");
                            warning.put("anomalyKind", "STOCK_LOW_50");
                            warnings.add(warning);
                            
                            // 发送库存预警通知
                            sendWarningToAdmins(warnings, "库存预警");
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("下单预警检测失败: " + e.getMessage());
        }
        
        if (voucherExchangeId != null) {
            int updated = rewardExchangeRepository.consumeVoucher(
                    voucherExchangeId,
                    currentUser.getId(),
                    saved.getId(),
                    now,
                    deduction,
                    RewardExchange.ExchangeStatus.COMPLETED
            );
            if (updated <= 0) {
                throw new BusinessException("VOUCHER_CONSUME_FAILED", "代金券核销失败，请重试");
            }
        }
        return saved;
    }

    @Override
    public Page<Order> getAllOrders(Pageable pageable) {
        Objects.requireNonNull(pageable, "分页参数不能为空");
        // 使用新添加的查询所有订单方法
        return orderRepository.findAll(pageable);
    }

    @Override
    public Page<Order> getOrdersByStatus(String status, Pageable pageable) {
        Objects.requireNonNull(pageable, "分页参数不能为空");
        try {
            if (status == null || status.trim().isEmpty()) {
                // 如果没有提供状态参数，查询所有订单
                return orderRepository.findAll(pageable);
            }
            
            System.out.println("Status parameter: " + status);
            Order.OrderStatus orderStatus = Order.OrderStatus.valueOf(status.toUpperCase());
            // 调用使用新添加的根据状态查询所有订单方法
            return orderRepository.findByStatusOrderByCreateTimeDesc(orderStatus, pageable);
        } catch (IllegalArgumentException e) {
            System.err.println("无效的订单状态: " + status);
            // 对于无效状态参数，返回空页并记录错误
            return Page.empty(pageable);
        } catch (Exception e) {
            System.err.println("查询订单状态时出错:");
            e.printStackTrace();
            // 对于其他异常，返回空页并记录错误
            return Page.empty(pageable);
        }
    }

    @Override
    public Page<Order> getOrdersByDateRange(LocalDateTime startDate, LocalDateTime endDate, Pageable pageable) {
        Objects.requireNonNull(pageable, "分页参数不能为空");
        // 添加日期参数的null检查
        if (startDate == null || endDate == null) {
            return Page.empty(pageable);
        }
        // 确保startDate不晚于endDate
        if (startDate.isAfter(endDate)) {
            LocalDateTime temp = startDate;
            startDate = endDate;
            endDate = temp;
        }
        // 执行日期范围查询，使用新添加的方法
        // 使用Spring Data JPA标准命名规则的方法名
        return orderRepository.findByCreateTimeBetween(startDate, endDate, pageable);
    }

    @Override
    public Order getOrderById(Long orderId) {
        Objects.requireNonNull(orderId, "订单ID不能为空");
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
    }

    @Override
    @Transactional
    public void cancelOrder(Long orderId) {
        Order order = getOrderById(orderId);
        ensureCurrentUserCanOperateOrder(order);
        // 检查订单是否可以取消（只有未完成或未取消的订单才能取消）
        if (order.getStatus() != Order.OrderStatus.COMPLETED && 
            order.getStatus() != Order.OrderStatus.CANCELLED) {
            order.setStatus(Order.OrderStatus.CANCELLED);
            orderRepository.save(order);

            Long voucherExchangeId = order.getVoucherExchangeId();
            if (voucherExchangeId != null) {
                rewardExchangeRepository.releaseVoucher(voucherExchangeId, order.getId());
            }
            
            notificationService.sendNotification(
                order.getUser().getId(),
                "订单已取消",
                "您的订单【" + order.getOrderNumber() + "】已成功取消。",
                com.school.canteen.entity.Notification.NotificationType.RESERVATION,
                com.school.canteen.entity.Notification.NotificationScene.ORDER_STATUS_CHANGE,
                com.school.canteen.entity.Notification.BizType.ORDER,
                order.getId()
            );
        } else {
            throw new RuntimeException("Order cannot be cancelled");
        }
    }

    @Override
    @Transactional
    public void deleteOrder(Long orderId) {
        Objects.requireNonNull(orderId, "订单ID不能为空");
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        reviewService.getReviewByOrderId(orderId)
                .ifPresent(review -> reviewService.deleteReview(review.getId()));
        List<OrderStatusHistory> histories = orderStatusHistoryRepository.findByOrderIdOrderByChangeTimeDesc(orderId);
        if (!histories.isEmpty()) {
            orderStatusHistoryRepository.deleteAll(histories);
        }
        notificationRepository.deleteByBizTypeAndBizId(
                com.school.canteen.entity.Notification.BizType.ORDER,
                orderId
        );
        orderRepository.delete(order);
    }

    @Override
    @Transactional
    public void confirmPickup(Long orderId) {
        Order order = getOrderById(orderId);
        ensureCurrentUserCanOperateOrder(order);
        // 检查订单是否可以确认取餐（只有READY状态的订单才能确认取餐）
        if (order.getStatus() == Order.OrderStatus.READY) {
            if (order.getOrderItems() != null && !order.getOrderItems().isEmpty()) {
                java.util.Map<Long, Integer> deductions = new java.util.HashMap<>();
                for (OrderItem item : order.getOrderItems()) {
                    if (item == null || item.getDish() == null || item.getQuantity() == null) continue;
                    Long dishId = item.getDish().getId();
                    if (dishId == null) continue;
                    int qty = Math.max(0, item.getQuantity());
                    if (qty == 0) continue;
                    deductions.merge(dishId, qty, Integer::sum);
                }
                for (java.util.Map.Entry<Long, Integer> entry : deductions.entrySet()) {
                    Dish dish = dishService.getDishById(entry.getKey());
                    if (dish != null && dish.getStock() != null) {
                        dishService.updateDishStock(entry.getKey(), entry.getValue(), false);
                    }
                }
            }
            order.setStatus(Order.OrderStatus.COMPLETED);
            Order saved = orderRepository.save(order);
            
            if (order.getUser() != null && order.getUser().getId() != null) {
                notificationService.sendNotification(
                    order.getUser().getId(),
                    "订单已完成",
                    "您的订单【" + order.getOrderNumber() + "】已完成，感谢您的光临！",
                    com.school.canteen.entity.Notification.NotificationType.RESERVATION,
                    com.school.canteen.entity.Notification.NotificationScene.ORDER_STATUS_CHANGE,
                    com.school.canteen.entity.Notification.BizType.ORDER,
                    order.getId()
                );
            }
            if (saved.getUser() != null && saved.getUser().getId() != null) {
                healthGoalRecommendationService.markDirty(saved.getUser().getId());
            }
            orderEventService.publishOrderUpdate(saved);
        } else {
            throw new RuntimeException("Order cannot be confirmed for pickup");
        }
    }

    @Override
    public void startPreparation(Long orderId) {
        Order order = getOrderById(orderId);
        // 检查订单是否可以开始制作（只有PAID状态的订单才能开始制作）
        if (order.getStatus() == Order.OrderStatus.PAID) {
            order.setStatus(Order.OrderStatus.PREPARING);
            if (order.getOrderItems() != null) {
                for (com.school.canteen.entity.OrderItem item : order.getOrderItems()) {
                    item.setUpdateTime(LocalDateTime.now());
                }
            }
            orderRepository.save(order);
            
            notificationService.sendNotification(
                order.getUser().getId(),
                "订单开始制作",
                "您的订单【" + order.getOrderNumber() + "】商家已接单，正在为您制作中。",
                com.school.canteen.entity.Notification.NotificationType.RESERVATION,
                com.school.canteen.entity.Notification.NotificationScene.ORDER_STATUS_CHANGE,
                com.school.canteen.entity.Notification.BizType.ORDER,
                order.getId()
            );
        } else {
            throw new RuntimeException("Order cannot be prepared");
        }
    }

    @Override
    public void finishPreparation(Long orderId) {
        Order order = getOrderById(orderId);
        // 检查订单是否可以完成制作（只有PREPARING状态的订单才能完成制作）
        if (order.getStatus() == Order.OrderStatus.PREPARING) {
            order.setStatus(Order.OrderStatus.READY);
            if (order.getOrderItems() != null) {
                for (com.school.canteen.entity.OrderItem item : order.getOrderItems()) {
                    item.setUpdateTime(LocalDateTime.now());
                }
            }
            orderRepository.save(order);
            
            String content = "您的订单【" + order.getOrderNumber() + "】已制作完成，请前往取餐口取餐。";
            
            // 尝试从第一个订单项获取取餐信息
            if (order.getOrderItems() != null && !order.getOrderItems().isEmpty()) {
                OrderItem firstItem = order.getOrderItems().get(0);
                if (firstItem.getPickupType() == Order.PickupType.RESERVATION && firstItem.getPickupTime() != null) {
                    java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("HH:mm");
                    content = "您的预约订单【" + order.getOrderNumber() + "】已制作完成，预约取餐时间 " + firstItem.getPickupTime().format(fmt) + "，请准时到达取餐口。";
                }
            }
            
            notificationService.sendNotification(
                order.getUser().getId(),
                "取餐提醒",
                content,
                com.school.canteen.entity.Notification.NotificationType.RESERVATION,
                com.school.canteen.entity.Notification.NotificationScene.ORDER_STATUS_CHANGE,
                com.school.canteen.entity.Notification.BizType.ORDER,
                order.getId()
            );
        } else {
            throw new RuntimeException("Order cannot be finished preparing");
        }
    }
    
    @Override
    public Order markOrderPaid(Long orderId, String paymentMethod, String transactionId, LocalDateTime paidAt) {
        return markOrderPaidInternal(orderId, paymentMethod, transactionId, paidAt, false);
    }

    private Order markOrderPaidInternal(Long orderId, String paymentMethod, String transactionId, LocalDateTime paidAt, boolean trustedSource) {
        Order order = getOrderById(orderId);
        if (!trustedSource) {
            ensureCurrentUserCanOperateOrder(order);
        }
        Order.OrderStatus from = order.getStatus();
        if (order.getStatus() == Order.OrderStatus.PAID || order.getStatus() == Order.OrderStatus.PREPARING
                || order.getStatus() == Order.OrderStatus.READY || order.getStatus() == Order.OrderStatus.COMPLETED) {
            // 已支付或后续状态，直接返回（幂等）
            return order;
        }
        order.setStatus(Order.OrderStatus.PAID);
        
        // 同步支付信息到所有订单项
        LocalDateTime paymentTime = paidAt != null ? paidAt : LocalDateTime.now();
        if (order.getOrderItems() != null) {
            for (OrderItem item : order.getOrderItems()) {
                item.setPaymentMethod(paymentMethod);
                item.setPaymentTransactionId(transactionId);
                item.setPaymentTime(paymentTime);
                item.setUpdateTime(LocalDateTime.now());
            }
        }
        
        Order saved = orderRepository.save(order);
        if (saved.getUser() != null && saved.getUser().getId() != null) {
            healthGoalRecommendationService.markDirty(saved.getUser().getId());
        }
        
        // 记录历史
        OrderStatusHistory hist = new OrderStatusHistory();
        hist.setOrder(saved);
        hist.setFromStatus(from);
        hist.setToStatus(Order.OrderStatus.PAID);
        hist.setNote("支付成功，交易号: " + (transactionId != null ? transactionId : ""));
        orderStatusHistoryRepository.save(hist);
        
        if (saved.getUser() != null) {
            notificationService.sendNotification(
                saved.getUser().getId(),
                "支付成功",
                "订单【" + saved.getOrderNumber() + "】支付成功，已为您安排制作。",
                com.school.canteen.entity.Notification.NotificationType.RESERVATION,
                com.school.canteen.entity.Notification.NotificationScene.ORDER_STATUS_CHANGE,
                com.school.canteen.entity.Notification.BizType.ORDER,
                saved.getId()
            );
        }
        
        // 推送实时事件
        orderEventService.publishOrderUpdate(saved);
        return saved;
    }
    
    @Override
    public Order markOrderPaidByNumber(String orderNumber, String paymentMethod, String transactionId, LocalDateTime paidAt) {
        Order order = orderRepository.findByOrderNumber(orderNumber);
        if (order == null) {
            throw new RuntimeException("Order not found by number: " + orderNumber);
        }
        return markOrderPaidInternal(order.getId(), paymentMethod, transactionId, paidAt, true);
    }
    
    @org.springframework.scheduling.annotation.Scheduled(fixedDelay = 60000)
    public void sendReservationPickupReminders() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime windowEnd = now.plusMinutes(10);
        List<Order> upcoming = orderRepository.findByStatusAndPickupTypeAndPickupTimeBetween(
            Order.OrderStatus.READY, Order.PickupType.RESERVATION, now, windowEnd
        );
        for (Order order : upcoming) {
            if (order.getUser() == null) continue;
            // 检查是否已经发送过提醒（通过通知记录判断）
            boolean alreadySent = notificationService.hasNotification(
                order.getUser().getId(),
                "预约取餐提醒",
                order.getId()
            );
            if (alreadySent) continue;
            java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("HH:mm");
            String pickupTimeStr = "未知时间";
            if (order.getOrderItems() != null && !order.getOrderItems().isEmpty()) {
                LocalDateTime pt = order.getOrderItems().get(0).getPickupTime();
                if (pt != null) {
                    pickupTimeStr = pt.format(fmt);
                }
            }
            String content = "您的预约订单【" + order.getOrderNumber() + "】将在 " + pickupTimeStr + " 取餐，请提前到达取餐口。";
            notificationService.sendNotification(
                order.getUser().getId(),
                "预约取餐提醒",
                content,
                com.school.canteen.entity.Notification.NotificationType.RESERVATION,
                com.school.canteen.entity.Notification.NotificationScene.ORDER_STATUS_CHANGE,
                com.school.canteen.entity.Notification.BizType.ORDER,
                order.getId()
            );
        }
    }

    @Override
    public Page<Order> getOrdersByUserId(Long userId, Pageable pageable) {
        Objects.requireNonNull(pageable, "分页参数不能为空");
        // 添加用户ID的null检查
        if (userId == null) {
            return Page.empty(pageable);
        }
        // 调用Repository方法查询用户订单
        return orderRepository.findByUserIdOrderByCreateTimeDesc(userId, pageable);
    }

    @Override
    public Page<Order> getOrdersByUserIdAndStatus(Long userId, String status, Pageable pageable) {
        Objects.requireNonNull(pageable, "分页参数不能为空");
        Objects.requireNonNull(userId, "用户ID不能为空");
        try {
            if (status == null || status.trim().isEmpty()) {
                return orderRepository.findByUserIdOrderByCreateTimeDesc(userId, pageable);
            }
            
            Order.OrderStatus orderStatus = Order.OrderStatus.valueOf(status.toUpperCase());
            return orderRepository.findByUserIdAndStatusOrderByCreateTimeDesc(userId, orderStatus, pageable);
        } catch (IllegalArgumentException e) {
            System.err.println("无效的订单状态: " + status);
            return Page.empty(pageable);
        } catch (Exception e) {
            System.err.println("查询订单状态时出错:");
            e.printStackTrace();
            return Page.empty(pageable);
        }
    }

    @Override
    public Page<Order> getOrdersByUserIdAndDateRange(Long userId, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable) {
        Objects.requireNonNull(pageable, "分页参数不能为空");
        Objects.requireNonNull(userId, "用户ID不能为空");
        if (startDate == null || endDate == null) {
            return Page.empty(pageable);
        }
        if (startDate.isAfter(endDate)) {
            LocalDateTime temp = startDate;
            startDate = endDate;
            endDate = temp;
        }
        return orderRepository.findByUserIdAndCreateTimeBetweenOrderByCreateTimeDesc(userId, startDate, endDate, pageable);
    }

    @Override
    public Page<Order> getOrdersByUserIdAndStatusAndDateRange(Long userId, String status, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable) {
        Objects.requireNonNull(pageable, "分页参数不能为空");
        Objects.requireNonNull(userId, "用户ID不能为空");
        
        if (startDate == null || endDate == null) {
            return getOrdersByUserIdAndStatus(userId, status, pageable);
        }
        if (status == null || status.trim().isEmpty()) {
            return getOrdersByUserIdAndDateRange(userId, startDate, endDate, pageable);
        }
        
        if (startDate.isAfter(endDate)) {
            LocalDateTime temp = startDate;
            startDate = endDate;
            endDate = temp;
        }
        
        try {
            Order.OrderStatus orderStatus = Order.OrderStatus.valueOf(status.toUpperCase());
            return orderRepository.findByUserIdAndStatusAndCreateTimeBetween(userId, orderStatus, startDate, endDate, pageable);
        } catch (IllegalArgumentException e) {
            System.err.println("无效的订单状态: " + status);
            return Page.empty(pageable);
        }
    }

    @Override
    public Page<Order> getOrdersByStatusAndDateRange(String status, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable) {
        Objects.requireNonNull(pageable, "分页参数不能为空");
        
        if (startDate == null || endDate == null) {
            return getOrdersByStatus(status, pageable);
        }
        if (status == null || status.trim().isEmpty()) {
            return getOrdersByDateRange(startDate, endDate, pageable);
        }
        
        if (startDate.isAfter(endDate)) {
            LocalDateTime temp = startDate;
            startDate = endDate;
            endDate = temp;
        }
        
        try {
            Order.OrderStatus orderStatus = Order.OrderStatus.valueOf(status.toUpperCase());
            return orderRepository.findByStatusAndCreateTimeBetween(orderStatus, startDate, endDate, pageable);
        } catch (IllegalArgumentException e) {
            System.err.println("无效的订单状态: " + status);
            return Page.empty(pageable);
        }
    }

    @Override
    public Page<Order> searchOrders(String orderNumber, String username, String status, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable) {
        Objects.requireNonNull(pageable, "分页参数不能为空");
        
        // 日期范围修正
        if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
            LocalDateTime temp = startDate;
            startDate = endDate;
            endDate = temp;
        }
        
        final LocalDateTime finalStartDate = startDate;
        final LocalDateTime finalEndDate = endDate;

        return orderRepository.findAll((Specification<Order>) (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            
            // 订单号查询 (模糊匹配)
            if (orderNumber != null && !orderNumber.trim().isEmpty()) {
                predicates.add(cb.like(root.get("orderNumber"), "%" + orderNumber.trim() + "%"));
            }
            
            // 用户名查询 (关联查询)
            if (username != null && !username.trim().isEmpty()) {
                Join<Order, User> userJoin = root.join("user", JoinType.LEFT);
                predicates.add(cb.like(userJoin.get("username"), "%" + username.trim() + "%"));
            }
            
            // 状态查询
            if (status != null && !status.trim().isEmpty()) {
                try {
                    Order.OrderStatus orderStatus = Order.OrderStatus.valueOf(status.toUpperCase());
                    predicates.add(cb.equal(root.get("status"), orderStatus));
                } catch (IllegalArgumentException e) {
                    // 忽略无效状态
                }
            }
            
            // 日期范围查询 (关联 orderItems 查询 createTime)
            if (finalStartDate != null && finalEndDate != null) {
                Join<Order, OrderItem> itemJoin = root.join("orderItems", JoinType.LEFT);
                predicates.add(cb.between(itemJoin.get("createTime"), finalStartDate, finalEndDate));
                if (query != null) {
                    query.distinct(true);
                }
            }
            
            return cb.and(predicates.toArray(new Predicate[0]));
        }, pageable);
    }
}
