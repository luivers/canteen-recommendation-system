package com.school.canteen.controller;

import com.school.canteen.entity.Dish;
import com.school.canteen.service.RecommendationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/** 智能推荐控制器 — 个性化推荐、策略推荐、健康目标推荐、新菜发现、综合推荐 */
@RestController
@RequestMapping("/api/recommendations")
public class RecommendationController {

    private static final Logger log = LoggerFactory.getLogger(RecommendationController.class);

    @Autowired
    private RecommendationService recommendationService;

    @Autowired
    private com.school.canteen.service.HealthGoalRecommendationService healthGoalRecommendationService;

    @Autowired
    private com.school.canteen.repository.UserRepository userRepository;

    private Long getUserId() {
        return com.school.canteen.util.SecurityUtils.getCurrentUserId();
    }

    @GetMapping("/personalized")
    public ResponseEntity<List<Dish>> getPersonalizedRecommendations(@RequestParam(defaultValue = "10") int limit) {
        Long userId = getUserId();
        if (userId == null) {
            // Fallback to popular items for anonymous users
            return ResponseEntity.ok(recommendationService.getRecommendationsByStrategy("popular", null, limit));
        }
        try {
            return ResponseEntity.ok(recommendationService.getPersonalizedRecommendations(userId, limit));
        } catch (RuntimeException e) {
            return ResponseEntity.ok(recommendationService.getRecommendationsByStrategy("popular", userId, limit));
        }
    }
    
    @GetMapping("/personalized/reasons")
    public ResponseEntity<List<Map<String, Object>>> getPersonalizedRecommendationsWithReason(@RequestParam(defaultValue = "10") int limit) {
        Long userId = getUserId();
        if (userId == null) {
            return ResponseEntity.ok(List.of());
        }
        try {
            return ResponseEntity.ok(recommendationService.getPersonalizedRecommendationsWithReason(userId, limit));
        } catch (RuntimeException e) {
            return ResponseEntity.ok(List.of());
        }
    }

    @GetMapping("/strategy/{type}")
    public ResponseEntity<List<Dish>> getRecommendationsByStrategy(
            @PathVariable String type,
            @RequestParam(defaultValue = "10") int limit) {
        Long userId = getUserId();
        try {
            return ResponseEntity.ok(recommendationService.getRecommendationsByStrategy(type, userId, limit));
        } catch (RuntimeException e) {
            return ResponseEntity.ok(List.of());
        }
    }

    @GetMapping("/health")
    public ResponseEntity<List<Dish>> getHealthRecommendations(
            @RequestParam String goal, // weight_loss, muscle_gain
            @RequestParam(defaultValue = "10") int limit) {
        Long userId = getUserId();
        return ResponseEntity.ok(recommendationService.getHealthRecommendations(userId, goal, limit));
    }

    @GetMapping("/health-goals")
    public ResponseEntity<com.school.canteen.dto.HealthGoalRecommendationResponse> getHealthGoalRecommendations(
            @RequestParam(defaultValue = "6") int limit,
            @RequestParam(required = false) String refreshToken,
            @RequestParam(required = false) List<Long> excludeIds
    ) {
        Long userId = getUserId();
        return ResponseEntity.ok(healthGoalRecommendationService.getRecommendations(userId, limit, refreshToken, excludeIds));
    }

    @GetMapping("/discovery")
    public ResponseEntity<List<Dish>> getDiscoveryRecommendations(@RequestParam(defaultValue = "10") int limit) {
        Long userId = getUserId();
        log.debug("GET /api/recommendations/discovery limit={} userId={}", limit, userId);
        if (userId == null) {
            // For anonymous users, treat everything as discovery (or return popular)
            return ResponseEntity.ok(recommendationService.getRecommendationsByStrategy("popular", null, limit));
        }
        try {
            return ResponseEntity.ok(recommendationService.getDiscoveryRecommendations(userId, limit));
        } catch (RuntimeException e) {
            log.warn("discovery推荐异常, userId={}, limit={}, err={}", userId, limit, e.toString());
            return ResponseEntity.ok(recommendationService.getRecommendationsByStrategy("popular", userId, limit));
        }
    }

    @GetMapping("/comprehensive")
    public ResponseEntity<Map<String, List<Dish>>> getComprehensiveRecommendations() {
        Long userId = getUserId();
        try {
            return ResponseEntity.ok(recommendationService.getComprehensiveRecommendations(userId));
        } catch (RuntimeException e) {
            return ResponseEntity.ok(Map.of(
                    "personalized", recommendationService.getRecommendationsByStrategy("popular", userId, 5),
                    "popular", recommendationService.getRecommendationsByStrategy("popular", userId, 5),
                    "discovery", recommendationService.getRecommendationsByStrategy("popular", userId, 5)
            ));
        }
    }
    
    @GetMapping("/today-new")
    public ResponseEntity<List<Dish>> getTodayNewDishes(@RequestParam(defaultValue = "10") int limit) {
        try {
            return ResponseEntity.ok(recommendationService.getTodayNewDishes(limit));
        } catch (RuntimeException e) {
            return ResponseEntity.ok(List.of());
        }
    }

    @GetMapping("/today-personalized-hot")
    public ResponseEntity<List<Dish>> getTodayPersonalizedHotDishes(@RequestParam(defaultValue = "10") int limit) {
        Long userId = getUserId();
        try {
            return ResponseEntity.ok(recommendationService.getTodayPersonalizedHotDishes(userId, limit));
        } catch (RuntimeException e) {
            return ResponseEntity.ok(recommendationService.getRecommendationsByStrategy("popular", userId, limit));
        }
    }
}
