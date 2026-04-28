package com.school.canteen.service.impl;

import com.school.canteen.entity.Combo;
import com.school.canteen.entity.Promotion;
import com.school.canteen.entity.User;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.repository.OrderRepository;
import com.school.canteen.repository.PromotionRepository;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.service.NotificationService;
import com.school.canteen.service.PromotionService;
import jakarta.persistence.criteria.Predicate;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 促销活动服务实现 */
@Service
public class PromotionServiceImpl implements PromotionService {

    private static final String ORDER_DATA_DELETE_TIP = "有对应的订单数据，请先删除订单数据。";

    @Autowired
    private PromotionRepository promotionRepository;

    @Autowired
    @Lazy
    private NotificationService notificationService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Override
    public List<Promotion> getAllPromotions() {
        return promotionRepository.findAll();
    }

    @Override
    public Page<Promotion> getPromotionsPage(Pageable pageable) {
        if (pageable == null) {
            return Page.empty();
        }
        return promotionRepository.findAll(pageable);
    }

    @Override
    public Page<Promotion> searchPromotions(Map<String, Object> params, Pageable pageable) {
        if (pageable == null) {
            return Page.empty();
        }

        Specification<Promotion> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (params == null) {
                return cb.and(predicates.toArray(new Predicate[0]));
            }

            // 按名称模糊查询
            if (params.containsKey("name") && params.get("name") != null) {
                String name = params.get("name").toString();
                predicates.add(cb.like(root.get("name"), "%" + name + "%"));
            }

            // 按类型精确查询
            if (params.containsKey("type") && params.get("type") != null) {
                String type = params.get("type").toString();
                predicates.add(cb.equal(root.get("type"), type));
            }

            // 按状态精确查询
            if (params.containsKey("status") && params.get("status") != null) {
                String status = params.get("status").toString();
                predicates.add(cb.equal(root.get("status"), status));
            }

            // 时间区间重叠：p.end >= q.start && p.start <= q.end
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            if (params.containsKey("startTime") && params.get("startTime") != null) {
                LocalDateTime startTime = LocalDateTime.parse(params.get("startTime").toString(), formatter);
                predicates.add(cb.greaterThanOrEqualTo(root.get("endTime"), startTime));
            }
            if (params.containsKey("endTime") && params.get("endTime") != null) {
                LocalDateTime endTime = LocalDateTime.parse(params.get("endTime").toString(), formatter);
                predicates.add(cb.lessThanOrEqualTo(root.get("startTime"), endTime));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        return promotionRepository.findAll(spec, pageable);
    }

    @Override
    public Promotion getPromotionById(Long id) {
        if (id == null) {
            return null;
        }
        return promotionRepository.findById(id).orElse(null);
    }

    @Transactional
    @Override
    public Promotion createPromotion(Promotion promotion) {
        if (promotion.getStatus() == null) {
            promotion.setStatus("pending");
        }
        if (promotion.getIsHot() == null) {
            promotion.setIsHot(false);
        }
        if (promotion.getOrderCount() == null) {
            promotion.setOrderCount(0);
        }
        if (promotion.getTotalDiscount() == null) {
            promotion.setTotalDiscount(0.0);
        }

        // 维护套餐反向关系
        if (promotion.getCombos() != null) {
            promotion.getCombos().forEach(combo -> {
                combo.setPromotion(promotion);
                if (combo.getStatus() == null) {
                    combo.setStatus("active");
                }
            });
        }

        // 根据时间自动计算状态
        LocalDateTime now = LocalDateTime.now();
        if (promotion.getStartTime() != null && promotion.getEndTime() != null) {
            if (now.isBefore(promotion.getStartTime())) {
                promotion.setStatus("pending");
            } else if (now.isAfter(promotion.getEndTime())) {
                promotion.setStatus("ended");
            } else {
                promotion.setStatus("active");
            }
        }

        Promotion savedPromotion = promotionRepository.save(promotion);
        if ("active".equalsIgnoreCase(savedPromotion.getStatus())) {
            notifyPromotionActive(savedPromotion);
        }
        return savedPromotion;
    }

    @Transactional
    @Override
    public Promotion updatePromotion(Long id, Promotion promotion) {
        Promotion existingPromotion = promotionRepository.findById(id).orElse(null);
        if (existingPromotion == null) {
            return null;
        }

        String oldStatus = existingPromotion.getStatus();

        // 忽略 id 和集合字段，避免被覆盖
        BeanUtils.copyProperties(promotion, existingPromotion, "id", "dishes", "targetDishCategories", "combos");

        if (promotion.getDishes() != null) {
            existingPromotion.setDishes(promotion.getDishes());
        }

        if (promotion.getTargetDishCategories() != null) {
            existingPromotion.setTargetDishCategories(promotion.getTargetDishCategories());
        }

        if (promotion.getCombos() != null) {
            if (existingPromotion.getCombos() == null) {
                existingPromotion.setCombos(new ArrayList<>());
            } else {
                existingPromotion.getCombos().clear();
            }

            for (Combo combo : promotion.getCombos()) {
                combo.setPromotion(existingPromotion);
                if (combo.getStatus() == null) {
                    combo.setStatus("active");
                }
                existingPromotion.getCombos().add(combo);
            }
        }

        // 根据时间自动刷新状态
        LocalDateTime now = LocalDateTime.now();
        if (existingPromotion.getStartTime() != null && existingPromotion.getEndTime() != null) {
            if (now.isBefore(existingPromotion.getStartTime())) {
                existingPromotion.setStatus("pending");
            } else if (now.isAfter(existingPromotion.getEndTime())) {
                existingPromotion.setStatus("ended");
            } else {
                existingPromotion.setStatus("active");
            }
        }

        Promotion savedPromotion = promotionRepository.save(existingPromotion);
        boolean wasActive = "active".equalsIgnoreCase(oldStatus);
        boolean isActive = "active".equalsIgnoreCase(savedPromotion.getStatus());
        if (!wasActive && isActive) {
            notifyPromotionActive(savedPromotion);
        }
        return savedPromotion;
    }

    @Transactional
    @Override
    public void deletePromotion(Long id) {
        if (id == null) {
            return;
        }

        long orderCount = orderRepository.countByPromotionId(id);
        if (orderCount > 0) {
            throw new BusinessException("PROMOTION_HAS_ORDER_DATA", ORDER_DATA_DELETE_TIP);
        }

        try {
            promotionRepository.deleteById(id);
        } catch (DataIntegrityViolationException ex) {
            throw new BusinessException("PROMOTION_HAS_ORDER_DATA", ORDER_DATA_DELETE_TIP);
        }
    }

    @Transactional
    @Override
    public Promotion togglePromotionStatus(Long id) {
        if (id == null) {
            return null;
        }

        Promotion promotion = promotionRepository.findById(id).orElse(null);
        if (promotion == null) {
            return null;
        }

        String oldStatus = promotion.getStatus();

        if ("active".equalsIgnoreCase(promotion.getStatus())) {
            promotion.setStatus("disabled");
        } else {
            // 非 active 时按时间恢复到 pending / active / ended
            LocalDateTime now = LocalDateTime.now();
            if (now.isBefore(promotion.getStartTime())) {
                promotion.setStatus("pending");
            } else if (now.isAfter(promotion.getEndTime())) {
                promotion.setStatus("ended");
            } else {
                promotion.setStatus("active");
            }
        }

        Promotion savedPromotion = promotionRepository.save(promotion);
        boolean wasActive = "active".equalsIgnoreCase(oldStatus);
        boolean isActive = "active".equalsIgnoreCase(savedPromotion.getStatus());
        if (!wasActive && isActive) {
            notifyPromotionActive(savedPromotion);
        }
        return savedPromotion;
    }

    @Override
    public List<Promotion> getActivePromotions() {
        List<Promotion> promotions = promotionRepository.findActivePromotions();

        // 刷新每个活动的订单统计
        for (Promotion p : promotions) {
            if (p != null && p.getId() != null) {
                try {
                    long count = orderRepository.countByPromotionId(p.getId());
                    p.setOrderCount((int) count);
                } catch (Exception ignored) {
                    // 统计失败不影响主流程
                }
            }
        }

        return promotions;
    }

    @Override
    public List<Promotion> getHotPromotions() {
        return promotionRepository.findByIsHotTrueAndStatus("active");
    }

    @Override
    public List<Promotion> getPromotionsByType(String type) {
        return promotionRepository.findByType(type);
    }

    @Override
    public Map<String, Object> getPromotionStats() {
        Map<String, Object> stats = new HashMap<>();

        long activeCount = promotionRepository.findByStatus("active").size();
        stats.put("activePromotions", activeCount);

        List<Promotion> allPromotions = promotionRepository.findAll();
        int totalOrders = allPromotions.stream().mapToInt(Promotion::getOrderCount).sum();
        double totalDiscount = allPromotions.stream().mapToDouble(Promotion::getTotalDiscount).sum();
        stats.put("totalOrders", totalOrders);
        stats.put("totalDiscount", totalDiscount);

        // 按 10000 单作为参考口径，计算参与率
        double participationRate = totalOrders > 0 ? (totalOrders / 10000.0) * 100 : 0;
        stats.put("participationRate", Math.round(participationRate * 10) / 10.0);
        return stats;
    }

    @Scheduled(fixedDelay = 60000)
    @Transactional
    public void autoActivatePromotions() {
        LocalDateTime now = LocalDateTime.now();

        List<Promotion> pending = promotionRepository.findByStatus("pending");
        for (Promotion p : pending) {
            if (p == null || p.getStartTime() == null || p.getEndTime() == null) {
                continue;
            }
            if (now.isBefore(p.getStartTime())) {
                continue;
            }
            if (now.isAfter(p.getEndTime())) {
                p.setStatus("ended");
                promotionRepository.save(p);
                continue;
            }

            p.setStatus("active");
            Promotion saved = promotionRepository.save(p);
            notifyPromotionActive(saved);
        }

        List<Promotion> active = promotionRepository.findByStatus("active");
        for (Promotion p : active) {
            if (p == null || p.getEndTime() == null) {
                continue;
            }
            if (now.isAfter(p.getEndTime())) {
                p.setStatus("ended");
                promotionRepository.save(p);
            }
        }
    }

    private void notifyPromotionActive(Promotion promotion) {
        if (promotion == null || promotion.getId() == null) {
            return;
        }

        List<User> users = userRepository.findAll();
        if (users == null || users.isEmpty()) {
            return;
        }

        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        String start = promotion.getStartTime() == null ? "" : promotion.getStartTime().format(fmt);
        String end = promotion.getEndTime() == null ? "" : promotion.getEndTime().format(fmt);
        String timeRange = (start.isEmpty() && end.isEmpty()) ? "" : "（" + start + " - " + end + "）";

        String title = "促销活动开始提醒";
        String content = "促销活动「" + promotion.getName() + "」已开始" + timeRange + "，快去下单吧！";

        for (User user : users) {
            if (user == null || user.getId() == null) {
                continue;
            }

            String status = user.getStatus();
            if (status != null && "inactive".equalsIgnoreCase(status)) {
                continue;
            }

            notificationService.sendNotification(
                user.getId(),
                title,
                content,
                com.school.canteen.entity.Notification.NotificationType.PROMOTION,
                com.school.canteen.entity.Notification.NotificationScene.PROMOTION_START,
                com.school.canteen.entity.Notification.BizType.PROMOTION,
                promotion.getId()
            );
        }
    }
}
