package com.school.canteen.controller;

import com.school.canteen.entity.Dish;
import com.school.canteen.entity.Order;
import com.school.canteen.entity.OrderItem;
import com.school.canteen.entity.User;
import com.school.canteen.entity.Window;
import com.school.canteen.service.DishService;
import com.school.canteen.service.OrderEventService;
import com.school.canteen.service.OrderService;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.repository.WindowRepository;
import jakarta.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

import com.alibaba.excel.EasyExcel;
import com.school.canteen.dto.export.OrderExportVO;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.net.URLEncoder;
import java.time.format.DateTimeFormatter;

/** 订单控制器 — 订单创建、查询、状态流转（取消/制作/就绪/完成）、Excel 导出、SSE 事件推送 */
@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    // 构造函数由@RequiredArgsConstructor自动生成，无需手动编写

    private static final Logger logger = LoggerFactory.getLogger(OrderController.class);
    
    private final OrderService orderService;
    private final UserRepository userRepository;
    private final DishService dishService;
    private final com.school.canteen.service.ComboService comboService;
    private final OrderEventService orderEventService;
    private final WindowRepository windowRepository;

    /**
     * 获取当前登录用户
     */
    private User getCurrentUser() {
        return com.school.canteen.util.SecurityUtils.getCurrentUser(userRepository);
    }

    private boolean isAdminOrManager(User user) {
        if (user == null || user.getRole() == null) {
            return false;
        }
        return user.getRole() == User.UserRole.ADMIN || user.getRole() == User.UserRole.WINDOW_MANAGER;
    }

    private boolean canAccessOrder(User user, Order order) {
        if (user == null || order == null) {
            return false;
        }
        if (isAdminOrManager(user)) {
            return true;
        }
        return order.getUser() != null && Objects.equals(order.getUser().getId(), user.getId());
    }
    
    /**
     * 安全地将字符串转换为LocalDateTime
     */
    private LocalDateTime parseLocalDateTime(Object dateObj) {
        if (dateObj == null) return null;

        if (dateObj instanceof Number) {
            long epochMillis = ((Number) dateObj).longValue();
            if (epochMillis <= 0) return null;
            return java.time.Instant.ofEpochMilli(epochMillis)
                    .atZone(java.time.ZoneId.systemDefault())
                    .toLocalDateTime();
        }

        String dateStr = String.valueOf(dateObj).trim();
        if (dateStr.isEmpty() || "null".equalsIgnoreCase(dateStr)) return null;

        try {
            return java.time.ZonedDateTime.parse(dateStr)
                    .withZoneSameInstant(java.time.ZoneId.systemDefault())
                    .toLocalDateTime();
        } catch (Exception ignored) {
        }

        try {
            return java.time.LocalDateTime.parse(dateStr);
        } catch (Exception ignored) {
        }

        try {
            var fmt = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            return java.time.LocalDateTime.parse(dateStr, fmt);
        } catch (Exception ignored) {
        }

        try {
            var fmt = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            return java.time.LocalDateTime.parse(dateStr, fmt);
        } catch (Exception ignored) {
        }

        return null;
    }

    /**
     * 创建订单
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createOrder(@RequestBody Map<String, Object> orderData) {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }
            
            // 创建Order对象
            Order order = new Order();

            Object voucherExchangeIdObj = orderData.get("voucherExchangeId");
            if (voucherExchangeIdObj != null) {
                try {
                    Long voucherExchangeId = voucherExchangeIdObj instanceof Number
                            ? ((Number) voucherExchangeIdObj).longValue()
                            : Long.parseLong(voucherExchangeIdObj.toString());
                    order.setVoucherExchangeId(voucherExchangeId);
                } catch (Exception ignored) {
                }
            }
            
            // 处理订单项
            List<OrderItem> orderItems = new ArrayList<>();
            List<String> itemErrors = new ArrayList<>();
            Object itemsObj = orderData.get("items");
            if (!(itemsObj instanceof List)) {
                Map<String, Object> resp = new HashMap<>();
                resp.put("status", "ERROR");
                resp.put("message", "下单失败：items格式错误");
                return ResponseEntity.badRequest().body(resp);
            }
            if (itemsObj instanceof List) {
                List<?> items = (List<?>) itemsObj;
                for (Object itemObj : items) {
                    if (itemObj instanceof Map) {
                        Map<?, ?> item = (Map<?, ?>) itemObj;
                        
                        // 获取菜品ID和数量
                        Object dishIdObj = item.get("dishId");
                        Object comboIdObj = item.get("comboId");
                        Object quantityObj = item.get("quantity");
                        
                        if ((dishIdObj == null && comboIdObj == null) || quantityObj == null) {
                            continue;
                        }
                        
                        try {
                            Integer quantity = quantityObj instanceof Number ? ((Number) quantityObj).intValue() : Integer.parseInt(quantityObj.toString());
                            
                            if (quantity <= 0) continue;

                            OrderItem orderItem = new OrderItem();
                            orderItem.setQuantity(quantity);
                            orderItem.setOrder(order);

                            if (comboIdObj != null) {
                                Long comboId = comboIdObj instanceof Number ? ((Number) comboIdObj).longValue() : Long.parseLong(comboIdObj.toString());
                                com.school.canteen.entity.Combo combo = comboService.getComboById(comboId);
                                if (combo == null) {
                                    itemErrors.add("套餐(" + comboId + ")不存在");
                                    continue;
                                }
                                // 检查套餐是否有效
                                if (!"active".equalsIgnoreCase(combo.getStatus())) {
                                    itemErrors.add("套餐【" + combo.getName() + "】已下架或不可用");
                                    continue;
                                }
                                orderItem.setCombo(combo);
                                orderItem.setUnitPrice(BigDecimal.valueOf(combo.getPrice()));
                                orderItem.setSubtotal(BigDecimal.valueOf(combo.getPrice()).multiply(new BigDecimal(quantity)));
                                // 套餐暂无单一窗口，可设为null或默认值
                            } else {
                                Long dishId = dishIdObj instanceof Number ? ((Number) dishIdObj).longValue() : Long.parseLong(dishIdObj.toString());
                                Dish dish = dishService.getDishById(dishId);
                                if (dish == null) {
                                    itemErrors.add("菜品(" + dishId + ")不存在");
                                    continue;
                                }
                                // 检查菜品是否可用
                                if (dish.getStatus() != Dish.DishStatus.AVAILABLE) {
                                    itemErrors.add("菜品【" + dish.getName() + "】已售罄或下架");
                                    continue;
                                }
                                // 检查菜品所属窗口是否营业（订单阻断：兜底防止窗口突然关闭后仍能下单）
                                if (dish.getWindowId() != null) {
                                    Window dishWindow = windowRepository.findById(dish.getWindowId()).orElse(null);
                                    if (dishWindow == null || dishWindow.getStatus() != Window.WindowStatus.OPEN) {
                                        String windowName = dish.getWindowName() != null ? dish.getWindowName() : "所属窗口";
                                        itemErrors.add("菜品【" + dish.getName() + "】的" + windowName + "当前已暂停或关闭，无法下单");
                                        continue;
                                    }
                                }
                                orderItem.setDish(dish);
                                orderItem.setWindowId(dish.getWindowId());
                                orderItem.setWindowName(dish.getWindowName());

                                if (Boolean.TRUE.equals(Boolean.parseBoolean(String.valueOf(item.get("isGift"))))) {
                                    orderItem.setIsGift(true);
                                    orderItem.setUnitPrice(BigDecimal.ZERO);
                                    orderItem.setSubtotal(BigDecimal.ZERO);
                                } else {
                                    BigDecimal unitPrice = dish.getPrice();
                                    orderItem.setUnitPrice(unitPrice);
                                    orderItem.setSubtotal(unitPrice.multiply(new BigDecimal(quantity)));
                                }
                            }

                            Object isGiftObj = item.get("isGift");
                            if (isGiftObj != null && orderItem.getIsGift() == null) {
                                orderItem.setIsGift(Boolean.parseBoolean(isGiftObj.toString()));
                            }

                            String pickupTypeStr = orderData.get("pickupType") == null ? null : String.valueOf(orderData.get("pickupType"));
                            try {
                                orderItem.setPickupType(pickupTypeStr != null ? Order.PickupType.valueOf(pickupTypeStr) : Order.PickupType.IMMEDIATE);
                            } catch (Exception e) {
                                itemErrors.add("无效取餐方式: " + pickupTypeStr);
                                continue;
                            }

                            Object reservationTimeObj = orderData.get("reservationTime");
                            LocalDateTime pickupTime = parseLocalDateTime(reservationTimeObj);
                            if (pickupTime != null) {
                                orderItem.setPickupTime(pickupTime);
                            }

                            Object remarksObj = orderData.get("remarks");
                            orderItem.setRemarks(remarksObj == null ? null : String.valueOf(remarksObj));

                            orderItems.add(orderItem);
                        } catch (Exception e) {
                            String idStr = dishIdObj != null ? dishIdObj.toString() : (comboIdObj != null ? comboIdObj.toString() : "null");
                            itemErrors.add("商品(" + idStr + ")下单失败: " + e.getMessage());
                            logger.error("创建订单项失败: {}", e.getMessage());
                        }
                    }
                }
            }

            if (orderItems.isEmpty()) {
                Map<String, Object> resp = new HashMap<>();
                resp.put("status", "ERROR");
                if (!itemErrors.isEmpty()) {
                    resp.put("message", "下单失败：" + String.join("；", itemErrors));
                } else {
                    resp.put("message", "订单商品不能为空");
                }
                return ResponseEntity.badRequest().body(resp);
            }
            
            // 设置订单项到订单
            order.setOrderItems(orderItems);
            
            // 计算总金额
            BigDecimal totalAmount = orderItems.stream()
                .map(OrderItem::getSubtotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
            order.setTotalAmount(totalAmount);
            
            // 创建订单
            Order createdOrder = orderService.createOrder(order, currentUser);
            Map<String, Object> resp = new HashMap<>();
            resp.put("status", "SUCCESS");
            resp.put("orderId", createdOrder.getId());
            resp.put("orderNumber", createdOrder.getOrderNumber());
            resp.put("totalAmount", createdOrder.getTotalAmount());
            if (createdOrder.getOrderItems() != null && !createdOrder.getOrderItems().isEmpty()) {
                resp.put("createdAt", createdOrder.getOrderItems().get(0).getCreateTime());
            } else {
                resp.put("createdAt", null);
            }
            return ResponseEntity.ok(resp);
        } catch (Exception e) {
            logger.error("创建订单失败: {}", e.getMessage(), e);
            Map<String, Object> resp = new HashMap<>();
            resp.put("status", "ERROR");
            resp.put("message", "创建订单失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(resp);
        }
    }

    /**
     * 获取订单列表（支持多条件筛选）
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getOrders(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) String orderNumber,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) Boolean adminView,
            HttpServletRequest request) {
        
        logger.debug("=== 开始处理获取订单列表请求 ===");
        logger.debug("请求参数: page={}, size={}, status={}, startDate={}, endDate={}, orderNumber={}, username={}, adminView={}", 
                page, size, status, startDate, endDate, orderNumber, username, adminView);
        
        try {
            Pageable pageable = PageRequest.of(page, size);
            Page<Order> orderPage;
            
            // 转换日期字符串为LocalDateTime
            LocalDateTime startDateTime = parseLocalDateTime(startDate);
            LocalDateTime endDateTime = parseLocalDateTime(endDate);
            logger.debug("转换后的日期范围: startDateTime={}, endDateTime={}", startDateTime, endDateTime);
            
            // 获取当前用户
            User currentUser = getCurrentUser();
            logger.debug("当前用户: {}", currentUser);
            
            // 如果用户未登录，检查是否有Authorization头
            // 如果有Authorization头但无法获取用户，说明token无效或用户不存在，返回401
            if (currentUser == null) {
                String authHeader = request.getHeader("Authorization");
                if (authHeader != null && !authHeader.isEmpty()) {
                    logger.warn("请求包含Authorization头但无法获取用户信息，返回401");
                    return ResponseEntity.status(401).build();
                }
                logger.debug("未登录用户，返回空列表");
                orderPage = Page.empty(pageable);
            } else {
                logger.debug("当前用户ID: {}, 角色: {}", currentUser.getId(), currentUser.getRole());
                
                // 根据用户角色决定查询范围
                boolean isAdminOrManager = currentUser.getRole() == User.UserRole.ADMIN || currentUser.getRole() == User.UserRole.WINDOW_MANAGER;
                boolean allowAdminView = Boolean.TRUE.equals(adminView);

                if (isAdminOrManager && allowAdminView) {
                    logger.debug("用户是管理员或窗口负责人，执行高级搜索");
                    orderPage = orderService.searchOrders(orderNumber, username, status, startDateTime, endDateTime, pageable);
                } else {
                    logger.debug("用户仅查询自己的订单");
                    if (status != null && !status.isEmpty() && startDateTime != null && endDateTime != null) {
                        logger.debug("根据用户ID、状态和日期范围查询订单: userId={}, status={}, dateRange={}-{}", currentUser.getId(), status, startDateTime, endDateTime);
                        orderPage = orderService.getOrdersByUserIdAndStatusAndDateRange(currentUser.getId(), status, startDateTime, endDateTime, pageable);
                    } else if (status != null && !status.isEmpty()) {
                        logger.debug("根据用户ID和状态查询订单: userId={}, status={}", currentUser.getId(), status);
                        orderPage = orderService.getOrdersByUserIdAndStatus(currentUser.getId(), status, pageable);
                    } else if (startDateTime != null && endDateTime != null) {
                        logger.debug("根据用户ID和日期范围查询订单: userId={}", currentUser.getId());
                        orderPage = orderService.getOrdersByUserIdAndDateRange(currentUser.getId(), startDateTime, endDateTime, pageable);
                    } else {
                        logger.debug("根据用户ID查询所有订单: userId={}", currentUser.getId());
                        orderPage = orderService.getOrdersByUserId(currentUser.getId(), pageable);
                    }
                }
            }
            
            logger.debug("查询到的订单页: {}", orderPage);
            logger.debug("订单总数: {}, 总页数: {}, 当前页: {}", 
                    orderPage.getTotalElements(), orderPage.getTotalPages(), orderPage.getNumber());
            logger.debug("当前页订单数量: {}", orderPage.getContent().size());
            
            // 转换订单列表，返回完整的订单信息，包括订单项
            List<Map<String, Object>> ordersWithDetails = orderPage.getContent().stream()
                    .map(this::convertToOrderDto)
                    .collect(java.util.stream.Collectors.toList());
            
            logger.debug("转换后的订单详情列表数量: {}", ordersWithDetails.size());
            
            Map<String, Object> response = new HashMap<>();
            response.put("content", ordersWithDetails);
            response.put("totalElements", orderPage.getTotalElements());
            response.put("totalPages", orderPage.getTotalPages());
            response.put("size", orderPage.getSize());
            response.put("number", orderPage.getNumber());
            
            logger.debug("返回响应: {}", response);
            logger.debug("响应内容大小: {}", ordersWithDetails.size());
            logger.debug("响应总元素数: {}", orderPage.getTotalElements());
            logger.debug("=== 结束处理获取订单列表请求 ===");
            
            // 直接返回订单数据，不包裹在data字段中，因为前端响应拦截器会处理
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("获取订单列表失败: {}", e.getMessage(), e);
            logger.debug("=== 结束处理获取订单列表请求（异常）===");
            return ResponseEntity.ok().body(createEmptyResponse());
        }
    }
    
    /**
     * 创建空的分页响应
     */
    private Map<String, Object> createEmptyResponse() {
        Map<String, Object> response = new HashMap<>();
        response.put("content", java.util.Collections.emptyList());
        response.put("totalElements", 0);
        response.put("totalPages", 0);
        response.put("size", 10);
        response.put("number", 0);
        return response;
    }

    /**
     * 获取订单详情
     */
    @GetMapping("/{orderId}")
    public ResponseEntity<Map<String, Object>> getOrder(@PathVariable Long orderId) {
        try {
            // 直接返回订单详情，不检查用户权限
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }
            Order order = orderService.getOrderById(orderId);
            if (!canAccessOrder(currentUser, order)) {
                return ResponseEntity.status(403).build();
            }
            return ResponseEntity.ok(convertToOrderDto(order));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            logger.error("获取订单详情失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 删除订单（仅管理员）
     */
    @DeleteMapping("/{orderId}")
    public ResponseEntity<Void> deleteOrder(@PathVariable Long orderId) {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }
            if (currentUser.getRole() != User.UserRole.ADMIN) {
                return ResponseEntity.status(403).build();
            }
            orderService.deleteOrder(orderId);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            logger.error("删除订单失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * 取消订单
     */
    @PutMapping("/{orderId}/cancel")
    public ResponseEntity<?> cancelOrder(@PathVariable Long orderId) {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }
            Order order = orderService.getOrderById(orderId);
            if (!canAccessOrder(currentUser, order)) {
                return ResponseEntity.status(403).build();
            }
            orderService.cancelOrder(orderId);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            String message = e.getMessage();
            if ("Order not found".equals(message)) {
                return ResponseEntity.notFound().build();
            } else if ("Order cannot be cancelled".equals(message)) {
                return ResponseEntity.badRequest().body(Map.of("message", message));
            }
            logger.error("Error cancelling order {}", orderId, e);
            return ResponseEntity.internalServerError().body(Map.of("message", "Internal Server Error"));
        }
    }

    /**
     * 确认取餐
     */
    @PutMapping({"/{orderId}/confirm-pickup", "/{orderId}/confirmPickup", "/{orderId}/complete"})
    public ResponseEntity<?> confirmPickup(@PathVariable Long orderId) {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }
            Order order = orderService.getOrderById(orderId);
            if (!canAccessOrder(currentUser, order)) {
                return ResponseEntity.status(403).build();
            }
            orderService.confirmPickup(orderId);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            String message = e.getMessage();
            if ("Order not found".equals(message)) {
                return ResponseEntity.notFound().build();
            } else if ("Order cannot be confirmed for pickup".equals(message)) {
                return ResponseEntity.badRequest().body(Map.of("message", message));
            }
            logger.error("Error confirming pickup for order {}", orderId, e);
            return ResponseEntity.internalServerError().body(Map.of("message", "Internal Server Error"));
        }
    }
    
    /**
     * 开始制作订单
     */
    @PutMapping("/{orderId}/prepare")
    public ResponseEntity<?> prepareOrder(@PathVariable Long orderId) {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }
            if (!isAdminOrManager(currentUser)) {
                return ResponseEntity.status(403).build();
            }
            orderService.startPreparation(orderId);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            String message = e.getMessage();
            if ("Order not found".equals(message)) {
                return ResponseEntity.notFound().build();
            } else if ("Order cannot be prepared".equals(message)) {
                return ResponseEntity.badRequest().body(Map.of("message", message));
            }
            logger.error("Error preparing order {}", orderId, e);
            return ResponseEntity.internalServerError().body(Map.of("message", "Internal Server Error"));
        }
    }
    
    /**
     * 订单制作完成
     */
    @PutMapping("/{orderId}/ready")
    public ResponseEntity<?> readyOrder(@PathVariable Long orderId) {
        try {
            User currentUser = getCurrentUser();
            if (currentUser == null) {
                return ResponseEntity.status(401).build();
            }
            if (!isAdminOrManager(currentUser)) {
                return ResponseEntity.status(403).build();
            }
            orderService.finishPreparation(orderId);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            String message = e.getMessage();
            if ("Order not found".equals(message)) {
                return ResponseEntity.notFound().build();
            } else if ("Order cannot be finished preparing".equals(message)) {
                return ResponseEntity.badRequest().body(Map.of("message", message));
            }
            logger.error("Error finishing preparation for order {}", orderId, e);
            return ResponseEntity.internalServerError().body(Map.of("message", "Internal Server Error"));
        }
    }

    /**
     * 将订单实体转换为DTO
     */
    private Map<String, Object> convertToOrderDto(Order order) {
        Map<String, Object> orderMap = new HashMap<>();
        orderMap.put("id", order.getId());
        orderMap.put("orderNumber", order.getOrderNumber());
        // 确保order.getUser()不为null
        if (order.getUser() != null) {
            orderMap.put("username", order.getUser().getUsername());
        } else {
            orderMap.put("username", "未知用户");
        }
        orderMap.put("totalAmount", order.getTotalAmount());
        orderMap.put("goodsAmount", order.getGoodsAmount());
        orderMap.put("voucherDeduction", order.getVoucherDeduction());
        orderMap.put("payableAmount", order.getPayableAmount());
        orderMap.put("voucherExchangeId", order.getVoucherExchangeId());
        orderMap.put("status", order.getStatus().name());

        // 从第一个订单项中获取物流、支付和审计信息
        if (order.getOrderItems() != null && !order.getOrderItems().isEmpty()) {
            OrderItem firstItem = order.getOrderItems().get(0);
            orderMap.put("pickupType", firstItem.getPickupType() != null ? firstItem.getPickupType().name() : null);
            orderMap.put("pickupTime", firstItem.getPickupTime());
            orderMap.put("reservationTime", firstItem.getPickupTime());
            orderMap.put("paymentMethod", firstItem.getPaymentMethod());
            orderMap.put("createdAt", firstItem.getCreateTime());
            orderMap.put("updateTime", firstItem.getUpdateTime());
            orderMap.put("completedAt", firstItem.getUpdateTime());
            orderMap.put("paymentTransactionId", firstItem.getPaymentTransactionId());
            orderMap.put("paymentTime", firstItem.getPaymentTime());

            // 优先使用 OrderItem 中的窗口信息，如果为空则尝试从 Dish 中获取
            String windowName = firstItem.getWindowName();
            Long windowId = firstItem.getWindowId();
            String canteenName = null;
            if (windowName == null || windowName.isEmpty()) {
                if (firstItem.getDish() != null) {
                    windowName = firstItem.getDish().getWindowName();
                }
            }
            if (windowId == null) {
                if (firstItem.getDish() != null) {
                    windowId = firstItem.getDish().getWindowId();
                }
            }
            // 获取食堂名称
            if (firstItem.getDish() != null) {
                canteenName = firstItem.getDish().getCanteenName();
            }
            orderMap.put("windowName", windowName != null ? windowName : "未知窗口");
            orderMap.put("windowId", windowId);
            orderMap.put("canteenName", canteenName != null ? canteenName : "");
            orderMap.put("remarks", firstItem.getRemarks());
        } else {
            orderMap.put("pickupType", null);
            orderMap.put("pickupTime", null);
            orderMap.put("reservationTime", null);
            orderMap.put("createdAt", null);
            orderMap.put("updateTime", null);
            orderMap.put("completedAt", null);
            orderMap.put("paymentMethod", null);
            orderMap.put("paymentTransactionId", null);
            orderMap.put("paymentTime", null);
            orderMap.put("windowName", "未知窗口");
            orderMap.put("canteenName", "");
            orderMap.put("remarks", null);
        }

        // 转换订单项列表
        List<Map<String, Object>> itemsList = new ArrayList<>();
        if (order.getOrderItems() != null && !order.getOrderItems().isEmpty()) {
            Map<Long, Map<String, Object>> comboAggregationMap = new HashMap<>();
            
            for (OrderItem item : order.getOrderItems()) {
                // 优先处理套餐聚合
                if (item.getCombo() != null) {
                    Long comboId = item.getCombo().getId();
                    
                    // 如果尚未处理过该套餐（在当前订单中）
                    if (!comboAggregationMap.containsKey(comboId)) {
                        Map<String, Object> itemMap = new HashMap<>();
                        itemMap.put("id", item.getId()); // 使用第一个子项的ID作为展示ID
                        
                        com.school.canteen.entity.Combo combo = item.getCombo();
                        
                        // 构造伪装的 Dish Map (与购物车接口保持一致)
                        Map<String, Object> dishMap = new HashMap<>();
                        // 伪装ID logic: comboId + 1000000
                        dishMap.put("id", combo.getId() + 1000000L); 
                        dishMap.put("name", combo.getName());
                        dishMap.put("price", combo.getPrice());
                        
                        String comboImage = combo.getImageUrl();
                        
                        dishMap.put("image", comboImage); 
                        dishMap.put("imageUrl", comboImage);
                        dishMap.put("windowName", "套餐");
                        dishMap.put("description", combo.getDescription());
                        
                        // 为了前端评价功能，需要将套餐内的真实菜品ID列表传给前端
                        // 前端可以根据这个列表展示多个菜品的评分项
                        // 我们将真实菜品信息放入一个扩展字段 'comboDishes'
                        if (combo.getDishes() != null && !combo.getDishes().isEmpty()) {
                            List<Map<String, Object>> subDishes = new ArrayList<>();
                            for (Dish d : combo.getDishes()) {
                                Map<String, Object> subDish = new HashMap<>();
                                subDish.put("id", d.getId());
                                subDish.put("name", d.getName());
                                subDish.put("image", d.getImageUrl());
                                subDishes.add(subDish);
                            }
                            dishMap.put("subDishes", subDishes);
                        }
                        
                        itemMap.put("dish", dishMap);
                        itemMap.put("dishName", combo.getName());
                        
                        // 价格使用套餐原价
                        itemMap.put("price", BigDecimal.valueOf(combo.getPrice()));
                        itemMap.put("unitPrice", BigDecimal.valueOf(combo.getPrice()));
                        
                        // 数量：每个拆分项的数量都等于套餐的购买数量，直接取其一即可
                        itemMap.put("quantity", item.getQuantity());
                        
                        // 小计：quantity * comboPrice
                        BigDecimal subtotal = BigDecimal.valueOf(combo.getPrice()).multiply(new BigDecimal(item.getQuantity()));
                        itemMap.put("subtotal", subtotal);
                        
                        comboAggregationMap.put(comboId, itemMap);
                        itemsList.add(itemMap);
                    }
                    // 之后的同个套餐的子项直接忽略，因为已经聚合展示了
                } else {
                    // 普通单品逻辑
                    Map<String, Object> itemMap = new HashMap<>();
                    itemMap.put("id", item.getId());

                    // 转换菜品信息
                    Map<String, Object> dishMap = new HashMap<>();
                    Dish dish = item.getDish();
                    if (dish != null) {
                        dishMap.put("id", dish.getId());
                        dishMap.put("name", dish.getName());
                        dishMap.put("price", dish.getPrice());
                        dishMap.put("image", dish.getImageUrl());
                        dishMap.put("imageUrl", dish.getImageUrl());
                        dishMap.put("windowName", dish.getWindowName());
                        dishMap.put("canteenName", dish.getCanteenName());
                    }

                    itemMap.put("dish", dishMap);
                    
                    String name = "未知商品";
                    if (dish != null) name = dish.getName();
                    
                    itemMap.put("dishName", name);
                    itemMap.put("price", item.getUnitPrice());
                    itemMap.put("quantity", item.getQuantity());
                    itemMap.put("unitPrice", item.getUnitPrice());
                    itemMap.put("subtotal", item.getSubtotal());

                    itemsList.add(itemMap);
                }
            }
        }
        orderMap.put("items", itemsList);

        return orderMap;
    }

    // 移除购物车相关端点，已迁移至 CartController

    /**
     * 导出订单列表到Excel
     */
    @GetMapping("/export")
    public void exportOrders(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) String orderNumber,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) Boolean adminView,
            HttpServletResponse response) throws IOException {

        User currentUser = getCurrentUser();
        if (currentUser == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        LocalDateTime startDateTime = parseLocalDateTime(startDate);
        LocalDateTime endDateTime = parseLocalDateTime(endDate);
        Pageable pageable = PageRequest.of(0, 10000); 

        Page<Order> orderPage;
        boolean isAdminOrManager = currentUser.getRole() == User.UserRole.ADMIN || currentUser.getRole() == User.UserRole.WINDOW_MANAGER;
        boolean allowAdminView = Boolean.TRUE.equals(adminView);

        if (isAdminOrManager && allowAdminView) {
            orderPage = orderService.searchOrders(orderNumber, username, status, startDateTime, endDateTime, pageable);
        } else {
             if (status != null && !status.isEmpty() && startDateTime != null && endDateTime != null) {
                orderPage = orderService.getOrdersByUserIdAndStatusAndDateRange(currentUser.getId(), status, startDateTime, endDateTime, pageable);
            } else if (status != null && !status.isEmpty()) {
                orderPage = orderService.getOrdersByUserIdAndStatus(currentUser.getId(), status, pageable);
            } else if (startDateTime != null && endDateTime != null) {
                orderPage = orderService.getOrdersByUserIdAndDateRange(currentUser.getId(), startDateTime, endDateTime, pageable);
            } else {
                orderPage = orderService.getOrdersByUserId(currentUser.getId(), pageable);
            }
        }

        List<OrderExportVO> exportList = orderPage.getContent().stream().map(this::convertToExportVO).toList();

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("订单列表_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")), "UTF-8").replaceAll("\\+", "%20");
        response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");

        EasyExcel.write(response.getOutputStream(), OrderExportVO.class).sheet("订单列表").doWrite(exportList);
    }

    /**
     * 将订单实体转换为导出VO
     */
    private OrderExportVO convertToExportVO(Order order) {
        OrderExportVO vo = new OrderExportVO();
        vo.setOrderNumber(order.getOrderNumber());
        if (order.getUser() != null) {
            vo.setUserId(order.getUser().getId());
        }
        vo.setTotalAmount(order.getTotalAmount());
        if (order.getStatus() != null) {
            vo.setStatus(order.getStatus().name());
        }
        
        if (order.getOrderItems() != null && !order.getOrderItems().isEmpty()) {
            OrderItem first = order.getOrderItems().get(0);
            vo.setCreateTime(formatDate(first.getCreateTime()));
            vo.setCompletionTime(formatDate(first.getUpdateTime()));
            vo.setPickupCode(order.getOrderNumber()); 
            
            String itemsStr = order.getOrderItems().stream()
                .map(i -> (i.getDish() != null ? i.getDish().getName() : "未知") + "x" + i.getQuantity())
                .collect(java.util.stream.Collectors.joining("; "));
            vo.setItems(itemsStr);
            
            if (first.getDish() != null) {
                vo.setCanteenName(first.getDish().getCanteenName());
            }
            vo.setWindowName(first.getWindowName());
        }
        return vo;
    }

    /**
     * 格式化日期时间
     */
    private String formatDate(LocalDateTime dt) {
        return dt == null ? "" : dt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    /**
     * 订阅SSE订单事件推送
     */
    /**
     * 订阅SSE订单事件推送
     */
    @GetMapping("/events")
    public SseEmitter subscribe() {
        return orderEventService.createEmitter();
    }
}
