package com.school.canteen.controller;

import com.school.canteen.entity.Promotion;
import com.school.canteen.service.PromotionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page; 
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/** 促销活动控制器 — 促销活动的 CRUD、搜索、状态切换 */
@RestController
@RequestMapping("/api/promotions")
public class PromotionController {

    @Autowired
    private PromotionService promotionService;

    // 获取所有促销活动
    @GetMapping
    public ResponseEntity<List<Promotion>> getAllPromotions() {
        List<Promotion> promotions = promotionService.getAllPromotions();
        return new ResponseEntity<>(promotions, HttpStatus.OK);
    }

    // 分页获取促销活动
    @GetMapping("/page")
    public ResponseEntity<Page<Promotion>> getPromotionsPage(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "desc") String direction) {
        
        Sort sort = direction.equalsIgnoreCase("desc") ? Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page - 1, size, sort);
        Page<Promotion> promotions = promotionService.getPromotionsPage(pageable);
        
        return new ResponseEntity<>(promotions, HttpStatus.OK);
    }

    // 根据条件搜索促销活动
    @PostMapping("/search")
    public ResponseEntity<Page<Promotion>> searchPromotions(
            @RequestBody Map<String, Object> params,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "desc") String direction) {
        
        Sort sort = direction.equalsIgnoreCase("desc") ? Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page - 1, size, sort);
        Page<Promotion> promotions = promotionService.searchPromotions(params, pageable);
        
        return new ResponseEntity<>(promotions, HttpStatus.OK);
    }

    // 根据ID获取促销活动
    @GetMapping("/{id}")
    public ResponseEntity<Promotion> getPromotionById(@PathVariable Long id) {
        Promotion promotion = promotionService.getPromotionById(id);
        return promotion != null ? new ResponseEntity<>(promotion, HttpStatus.OK) : new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    // 创建促销活动
    @PostMapping
    public ResponseEntity<Promotion> createPromotion(@RequestBody Promotion promotion) {
        Promotion createdPromotion = promotionService.createPromotion(promotion);
        return new ResponseEntity<>(createdPromotion, HttpStatus.CREATED);
    }

    // 更新促销活动
    @PutMapping("/{id}")
    public ResponseEntity<Promotion> updatePromotion(@PathVariable Long id, @RequestBody Promotion promotion) {
        Promotion updatedPromotion = promotionService.updatePromotion(id, promotion);
        return updatedPromotion != null ? new ResponseEntity<>(updatedPromotion, HttpStatus.OK) : new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    // 删除促销活动
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePromotion(@PathVariable Long id) {
        promotionService.deletePromotion(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    // 切换促销活动状态
    @PatchMapping("/{id}/toggle-status")
    public ResponseEntity<Promotion> togglePromotionStatus(@PathVariable Long id) {
        Promotion updatedPromotion = promotionService.togglePromotionStatus(id);
        return updatedPromotion != null ? new ResponseEntity<>(updatedPromotion, HttpStatus.OK) : new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    // 获取活跃的促销活动
    @GetMapping("/active")
    public ResponseEntity<List<Promotion>> getActivePromotions() {
        List<Promotion> promotions = promotionService.getActivePromotions();
        return new ResponseEntity<>(promotions, HttpStatus.OK);
    }

    // 获取热门促销活动
    @GetMapping("/hot")
    public ResponseEntity<List<Promotion>> getHotPromotions() {
        List<Promotion> promotions = promotionService.getHotPromotions();
        return new ResponseEntity<>(promotions, HttpStatus.OK);
    }

    // 根据类型获取促销活动
    @GetMapping("/type/{type}")
    public ResponseEntity<List<Promotion>> getPromotionsByType(@PathVariable String type) {
        List<Promotion> promotions = promotionService.getPromotionsByType(type);
        return new ResponseEntity<>(promotions, HttpStatus.OK);
    }

    // 获取促销统计数据
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getPromotionStats() {
        Map<String, Object> stats = promotionService.getPromotionStats();
        return new ResponseEntity<>(stats, HttpStatus.OK);
    }
}