package com.school.canteen.service.impl;

import com.school.canteen.entity.Canteen;
import com.school.canteen.repository.CanteenRepository;
import com.school.canteen.repository.DishRepository;
import com.school.canteen.repository.WindowRepository;
import com.school.canteen.service.CanteenService;
import com.school.canteen.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;

import java.util.List;
import java.util.Optional;

/** 食堂管理服务实现类 */
@Service
@RequiredArgsConstructor
public class CanteenServiceImpl implements CanteenService {
    
    private final CanteenRepository canteenRepository;
    private final WindowRepository windowRepository;
    private final DishRepository dishRepository;
    
    @Override
    @Transactional
    public Canteen createCanteen(Canteen canteen) {
        return canteenRepository.save(canteen);
    }
    
    @Override
    @Transactional
    public Canteen updateCanteen(Long id, Canteen canteen) {
        Optional<Canteen> existingCanteen = canteenRepository.findById(id);
        if (existingCanteen.isPresent()) {
            canteen.setId(id);
            return canteenRepository.save(canteen);
        }
        throw new BusinessException("CANTEEN_NOT_FOUND", HttpStatus.NOT_FOUND, "食堂不存在");
    }
    
    @Override
    @Transactional
    public void deleteCanteen(Long id) {
        // 检查是否存在关联的窗口
        long windowCount = windowRepository.countByCanteenId(id);
        if (windowCount > 0) {
            throw new BusinessException("CANTEEN_HAS_WINDOWS", HttpStatus.BAD_REQUEST, "该食堂下还有 " + windowCount + " 个窗口，无法删除");
        }
        
        // 检查是否存在关联的菜品
        long dishCount = dishRepository.countByCanteenId(id);
        if (dishCount > 0) {
            throw new BusinessException("CANTEEN_HAS_DISHES", HttpStatus.BAD_REQUEST, "该食堂下还有 " + dishCount + " 个菜品，无法删除");
        }

        canteenRepository.deleteById(id);
    }
    
    @Override
    public Optional<Canteen> getCanteenById(Long id) {
        return canteenRepository.findById(id);
    }
    
    @Override
    public List<Canteen> getAllCanteens() {
        return canteenRepository.findAll();
    }
    
    @Override
    public Canteen getCanteenByName(String name) {
        return canteenRepository.findByName(name);
    }
}