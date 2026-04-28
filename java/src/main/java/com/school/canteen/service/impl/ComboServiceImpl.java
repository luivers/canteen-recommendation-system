package com.school.canteen.service.impl;

import com.school.canteen.entity.Combo;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.repository.ComboRepository;
import com.school.canteen.repository.OrderItemRepository;
import com.school.canteen.service.ComboService;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/** 套餐管理服务实现类 */
@Service
public class ComboServiceImpl implements ComboService {
    private static final String ORDER_DATA_DELETE_TIP = "\u6709\u5bf9\u5e94\u7684\u8ba2\u5355\u6570\u636e\uff0c\u8bf7\u5148\u5220\u9664\u8ba2\u5355\u6570\u636e\u3002";

    @Autowired
    private ComboRepository comboRepository;

    @Autowired
    private OrderItemRepository orderItemRepository;

    @Override
    public List<Combo> getAllCombos() {
        return comboRepository.findAll();
    }

    @Override
    public Combo getComboById(Long id) {
        return comboRepository.findById(id).orElse(null);
    }

    @Override
    public List<Combo> getCombosByPromotionId(Long promotionId) {
        return comboRepository.findByPromotionId(promotionId);
    }

    @Transactional
    @Override
    public Combo createCombo(Combo combo) {
        if (combo.getStatus() == null) {
            combo.setStatus("active");
        }
        return comboRepository.save(combo);
    }

    @Transactional
    @Override
    public Combo updateCombo(Long id, Combo combo) {
        Combo existingCombo = comboRepository.findById(id).orElse(null);
        if (existingCombo == null) {
            return null;
        }

        BeanUtils.copyProperties(combo, existingCombo, "id", "promotion", "dishes");
        return comboRepository.save(existingCombo);
    }

    @Transactional
    @Override
    public void deleteCombo(Long id) {
        if (id == null) {
            throw new BusinessException("COMBO_ID_EMPTY", "套餐ID不能为空");
        }

        Combo combo = comboRepository.findById(id).orElse(null);
        if (combo == null) {
            throw new BusinessException("COMBO_NOT_FOUND", "套餐不存在");
        }

        long orderCount = orderItemRepository.countByComboId(id);
        if (orderCount > 0) {
            combo.setStatus("deleted");
            comboRepository.save(combo);
            throw new BusinessException("COMBO_HAS_ORDER_DATA", ORDER_DATA_DELETE_TIP);
        }

        try {
            comboRepository.deleteById(id);
        } catch (DataIntegrityViolationException ex) {
            throw new BusinessException("COMBO_HAS_ORDER_DATA", ORDER_DATA_DELETE_TIP);
        }
    }

    @Transactional
    @Override
    public Combo toggleComboStatus(Long id) {
        Combo combo = comboRepository.findById(id).orElse(null);
        if (combo == null) {
            return null;
        }

        if (combo.getStatus().equals("active")) {
            combo.setStatus("disabled");
        } else {
            combo.setStatus("active");
        }

        return comboRepository.save(combo);
    }

    @Override
    public List<Combo> getActiveCombos() {
        return comboRepository.findByStatus("active");
    }

    @Override
    public List<Combo> getActiveCombosByPromotionId(Long promotionId) {
        return comboRepository.findByPromotionIdAndStatus(promotionId, "active");
    }
}
