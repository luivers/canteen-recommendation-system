package com.school.canteen.controller;

import com.school.canteen.dto.VoucherDTO;
import com.school.canteen.entity.Reward;
import com.school.canteen.entity.RewardCategory;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.repository.RewardCategoryRepository;
import com.school.canteen.repository.RewardRepository;
import com.school.canteen.service.RewardService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/** 奖品管理控制器（管理端） — 奖品分类的 CRUD */
@RestController
@RequestMapping("/api/admin/vouchers")
@RequiredArgsConstructor
public class AdminVoucherController {
    private final RewardService rewardService;
    private final RewardRepository rewardRepository;
    private final RewardCategoryRepository rewardCategoryRepository;

    @GetMapping("/categories")
    public ResponseEntity<?> listCategories() {
        List<RewardCategory> list = rewardCategoryRepository.findAll();
        return ResponseEntity.ok(Map.of("data", list, "message", "获取分类成功", "code", "VOUCHER_CATEGORIES_FETCHED"));
    }

    @PostMapping("/categories")
    public ResponseEntity<?> createCategory(@Valid @RequestBody VoucherDTO.CategoryRequest req) {
        RewardCategory category = new RewardCategory();
        category.setName(req.getName());
        if (req.getSortOrder() != null) category.setSortOrder(req.getSortOrder());
        if (req.getStatus() != null && !req.getStatus().isBlank()) {
            category.setStatus(RewardCategory.CategoryStatus.valueOf(req.getStatus().trim().toUpperCase()));
        }
        RewardCategory saved = rewardCategoryRepository.save(category);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("data", saved, "message", "创建分类成功", "code", "VOUCHER_CATEGORY_CREATED"));
    }

    @PutMapping("/categories/{id}")
    public ResponseEntity<?> updateCategory(@PathVariable Long id, @Valid @RequestBody VoucherDTO.CategoryRequest req) {
        RewardCategory category = rewardCategoryRepository.findById(id).orElseThrow(() -> new BusinessException("NOT_FOUND", "分类不存在"));
        category.setName(req.getName());
        if (req.getSortOrder() != null) category.setSortOrder(req.getSortOrder());
        if (req.getStatus() != null && !req.getStatus().isBlank()) {
            category.setStatus(RewardCategory.CategoryStatus.valueOf(req.getStatus().trim().toUpperCase()));
        }
        RewardCategory saved = rewardCategoryRepository.save(category);
        return ResponseEntity.ok(Map.of("data", saved, "message", "更新分类成功", "code", "VOUCHER_CATEGORY_UPDATED"));
    }

    @DeleteMapping("/categories/{id}")
    public ResponseEntity<?> deleteCategory(@PathVariable Long id) {
        rewardCategoryRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "删除分类成功", "code", "VOUCHER_CATEGORY_DELETED"));
    }

    @GetMapping("/page")
    public ResponseEntity<?> pageVouchers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String status) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Reward> p = rewardRepository.findAll((root, query, cb) -> {
            var predicates = cb.conjunction();
            if (categoryId != null) predicates = cb.and(predicates, cb.equal(root.get("category").get("id"), categoryId));
            if (keyword != null && !keyword.isBlank()) predicates = cb.and(predicates, cb.like(cb.lower(root.get("name")), "%" + keyword.trim().toLowerCase() + "%"));
            if (status != null && !status.isBlank()) {
                predicates = cb.and(predicates, cb.equal(root.get("status"), Reward.RewardStatus.valueOf(status.trim().toUpperCase())));
            } else {
                predicates = cb.and(predicates, cb.notEqual(root.get("status"), Reward.RewardStatus.DELETED));
            }
            return predicates;
        }, pageable);
        return ResponseEntity.ok(Map.of(
                "data", Map.of("content", p.getContent(), "total", p.getTotalElements(), "totalPages", p.getTotalPages()),
                "message", "获取奖品列表成功",
                "code", "REWARDS_PAGE_FETCHED"
        ));
    }

    @PostMapping
    public ResponseEntity<?> createVoucher(@Valid @RequestBody VoucherDTO.UpsertRequest req) {
        Reward reward = mapToReward(req, null);
        Reward saved = rewardService.createReward(reward);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("data", saved, "message", "创建奖品成功", "code", "REWARD_CREATED"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateVoucher(@PathVariable @org.springframework.lang.NonNull Long id, @Valid @RequestBody VoucherDTO.UpsertRequest req) {
        Reward update = mapToReward(req, id);
        Reward saved = rewardService.updateReward(id, update);
        return ResponseEntity.ok(Map.of("data", saved, "message", "更新奖品成功", "code", "REWARD_UPDATED"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteVoucher(@PathVariable @org.springframework.lang.NonNull Long id) {
        rewardService.deleteReward(id);
        return ResponseEntity.ok(Map.of("message", "删除奖品成功", "code", "REWARD_DELETED"));
    }

    private Reward mapToReward(VoucherDTO.UpsertRequest req, Long id) {
        Reward r = new Reward();
        if (id != null) r.setId(id);
        r.setName(req.getName());
        r.setDescription(req.getDescription());
        r.setPointsRequired(req.getPointsRequired());
        r.setStock(req.getStock());
        r.setImageUrl(req.getImageUrl());
        if (req.getType() != null && !req.getType().isBlank()) {
            try {
                r.setType(Reward.RewardType.valueOf(req.getType().trim().toUpperCase()));
            } catch (IllegalArgumentException e) {
                r.setType(Reward.RewardType.VOUCHER);
            }
        } else {
            r.setType(Reward.RewardType.VOUCHER);
        }
        r.setFaceValue(req.getFaceValue());
        r.setMinOrderAmount(req.getMinOrderAmount());
        r.setValidFrom(req.getValidFrom());
        r.setValidTo(req.getValidTo());
        r.setDailyLimit(req.getDailyLimit());
        r.setPerUserLimit(req.getPerUserLimit());
        r.setExchangeEnabled(req.getExchangeEnabled());
        r.setAttributes(req.getAttributes());
        if (req.getStatus() != null && !req.getStatus().isBlank()) {
            r.setStatus(Reward.RewardStatus.valueOf(req.getStatus().trim().toUpperCase()));
        }
        if (req.getCategoryId() != null) {
            RewardCategory category = rewardCategoryRepository.findById(req.getCategoryId())
                    .orElseThrow(() -> new BusinessException("NOT_FOUND", "分类不存在"));
            r.setCategory(category);
        }
        return r;
    }
}
