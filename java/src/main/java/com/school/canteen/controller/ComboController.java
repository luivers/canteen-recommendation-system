package com.school.canteen.controller;

import com.school.canteen.entity.Combo;
import com.school.canteen.service.ComboService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** 套餐组合控制器 — 套餐的 CRUD 和状态切换 */
@RestController
@RequestMapping("/api/combos")
public class ComboController {

    @Autowired
    private ComboService comboService;

    // 获取所有套餐
    @GetMapping
    public ResponseEntity<List<Combo>> getAllCombos() {
        List<Combo> combos = comboService.getAllCombos();
        return new ResponseEntity<>(combos, HttpStatus.OK);
    }

    // 根据ID获取套餐
    @GetMapping("/{id}")
    public ResponseEntity<Combo> getComboById(@PathVariable Long id) {
        Combo combo = comboService.getComboById(id);
        return combo != null ? new ResponseEntity<>(combo, HttpStatus.OK) : new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    // 根据促销活动ID获取套餐
    @GetMapping("/promotion/{promotionId}")
    public ResponseEntity<List<Combo>> getCombosByPromotionId(@PathVariable Long promotionId) {
        List<Combo> combos = comboService.getCombosByPromotionId(promotionId);
        return new ResponseEntity<>(combos, HttpStatus.OK);
    }

    // 创建套餐
    @PostMapping
    public ResponseEntity<Combo> createCombo(@RequestBody Combo combo) {
        Combo createdCombo = comboService.createCombo(combo);
        return new ResponseEntity<>(createdCombo, HttpStatus.CREATED);
    }

    // 更新套餐
    @PutMapping("/{id}")
    public ResponseEntity<Combo> updateCombo(@PathVariable Long id, @RequestBody Combo combo) {
        Combo updatedCombo = comboService.updateCombo(id, combo);
        return updatedCombo != null ? new ResponseEntity<>(updatedCombo, HttpStatus.OK) : new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    // 删除套餐
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCombo(@PathVariable Long id) {
        comboService.deleteCombo(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    // 切换套餐状态
    @PatchMapping("/{id}/toggle-status")
    public ResponseEntity<Combo> toggleComboStatus(@PathVariable Long id) {
        Combo updatedCombo = comboService.toggleComboStatus(id);
        return updatedCombo != null ? new ResponseEntity<>(updatedCombo, HttpStatus.OK) : new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    // 获取活跃的套餐
    @GetMapping("/active")
    public ResponseEntity<List<Combo>> getActiveCombos() {
        List<Combo> combos = comboService.getActiveCombos();
        return new ResponseEntity<>(combos, HttpStatus.OK);
    }

    // 获取促销活动下的活跃套餐
    @GetMapping("/promotion/{promotionId}/active")
    public ResponseEntity<List<Combo>> getActiveCombosByPromotionId(@PathVariable Long promotionId) {
        List<Combo> combos = comboService.getActiveCombosByPromotionId(promotionId);
        return new ResponseEntity<>(combos, HttpStatus.OK);
    }
}