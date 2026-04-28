package com.school.canteen.controller;

import com.school.canteen.entity.ReviewRewardRule;
import com.school.canteen.service.ReviewRewardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/** 评价奖励规则控制器（管理端） — 奖励规则的查询、更新和初始化 */
@RestController
@RequestMapping("/api/admin/rewards")
@RequiredArgsConstructor
public class ReviewRewardController {

    private final ReviewRewardService rewardService;

    @GetMapping("/rules")
    public ResponseEntity<List<ReviewRewardRule>> getAllRules() {
        return ResponseEntity.ok(rewardService.getAllRules());
    }

    @PostMapping("/rules")
    public ResponseEntity<?> updateRule(@RequestBody ReviewRewardRule rule) {
        try {
            ReviewRewardRule saved = rewardService.saveRule(rule);
            return ResponseEntity.ok(Map.of("message", "规则保存成功", "data", saved));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("message", "规则保存失败: " + e.getMessage()));
        }
    }
    
    // 初始化默认规则 (手动触发)
    @PostMapping("/rules/init")
    public ResponseEntity<?> initRules() {
        rewardService.initDefaultRules();
        return ResponseEntity.ok(Map.of("message", "默认规则初始化成功"));
    }
}
