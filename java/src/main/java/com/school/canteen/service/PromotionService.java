package com.school.canteen.service;

import com.school.canteen.entity.Promotion;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;

/** 促销活动管理服务接口 */
public interface PromotionService {

    // 获取所有促销活动
    List<Promotion> getAllPromotions();

    // 分页获取促销活动
    Page<Promotion> getPromotionsPage(Pageable pageable);

    // 根据条件分页查询促销活动
    Page<Promotion> searchPromotions(Map<String, Object> params, Pageable pageable);

    // 根据ID获取促销活动
    Promotion getPromotionById(Long id);

    // 创建促销活动
    Promotion createPromotion(Promotion promotion);

    // 更新促销活动
    Promotion updatePromotion(Long id, Promotion promotion);

    // 删除促销活动
    void deletePromotion(Long id);

    // 切换促销活动状态
    Promotion togglePromotionStatus(Long id);

    // 获取活跃的促销活动
    List<Promotion> getActivePromotions();

    // 获取热门促销活动
    List<Promotion> getHotPromotions();

    // 根据类型获取促销活动
    List<Promotion> getPromotionsByType(String type);

    // 获取促销统计数据
    Map<String, Object> getPromotionStats();
}