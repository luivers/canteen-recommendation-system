package com.school.canteen.service;

import com.school.canteen.entity.Combo;

import java.util.List;

/** 套餐管理服务接口 */
public interface ComboService {

    // 获取所有套餐
    List<Combo> getAllCombos();

    // 根据ID获取套餐
    Combo getComboById(Long id);

    // 根据促销活动ID获取套餐
    List<Combo> getCombosByPromotionId(Long promotionId);

    // 创建套餐
    Combo createCombo(Combo combo);

    // 更新套餐
    Combo updateCombo(Long id, Combo combo);

    // 删除套餐
    void deleteCombo(Long id);

    // 切换套餐状态
    Combo toggleComboStatus(Long id);

    // 获取活跃的套餐
    List<Combo> getActiveCombos();

    // 获取促销活动下的活跃套餐
    List<Combo> getActiveCombosByPromotionId(Long promotionId);
}