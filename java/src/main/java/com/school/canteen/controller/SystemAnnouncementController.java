package com.school.canteen.controller;

import com.school.canteen.service.SystemAnnouncementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 系统公告控制器（合并公开接口与管理接口）
 *
 * 公开接口：GET /api/announcements          — 获取公开公告（无需认证）
 * 管理接口：GET /api/admin/announcements     — 管理员查询（需 ADMIN 角色）
 *          POST /api/admin/announcements     — 创建公告
 *          PUT  /api/admin/announcements/{id} — 更新公告
 *          DELETE /api/admin/announcements/{id} — 删除公告
 */
@RestController
@RequiredArgsConstructor
public class SystemAnnouncementController {

    private final SystemAnnouncementService systemAnnouncementService;

    // ==================== 公开接口 ====================

    @GetMapping("/api/announcements")
    public ResponseEntity<?> getPublicAnnouncements() {
        List<Map<String, Object>> announcements = systemAnnouncementService.getPublicAnnouncements();
        return ResponseEntity.ok(Map.of("data", announcements, "message", "获取公告成功", "code", "ANNOUNCEMENTS_FETCHED"));
    }

    // ==================== 管理接口 ====================

    @GetMapping("/api/admin/announcements")
    public ResponseEntity<?> list(@RequestParam(required = false) String keyword) {
        List<Map<String, Object>> announcements = systemAnnouncementService.getAdminAnnouncements(keyword);
        return ResponseEntity.ok(Map.of("data", announcements, "message", "获取公告成功", "code", "ANNOUNCEMENTS_FETCHED"));
    }

    @PostMapping("/api/admin/announcements")
    public ResponseEntity<?> create(@RequestBody Map<String, String> payload) {
        String title = payload.get("title");
        String content = payload.get("content");
        if (title == null || title.isBlank() || content == null || content.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "标题和内容不能为空", "code", "INVALID_REQUEST"));
        }
        systemAnnouncementService.createAnnouncement(title, content);
        return ResponseEntity.ok(Map.of("message", "公告发布成功", "code", "ANNOUNCEMENT_CREATED"));
    }

    @PutMapping("/api/admin/announcements/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Map<String, String> payload) {
        String title = payload.get("title");
        String content = payload.get("content");
        if (title == null || title.isBlank() || content == null || content.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "标题和内容不能为空", "code", "INVALID_REQUEST"));
        }
        systemAnnouncementService.updateAnnouncement(id, title, content);
        return ResponseEntity.ok(Map.of("message", "公告更新成功", "code", "ANNOUNCEMENT_UPDATED"));
    }

    @DeleteMapping("/api/admin/announcements/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        systemAnnouncementService.deleteAnnouncement(id);
        return ResponseEntity.ok(Map.of("message", "公告删除成功", "code", "ANNOUNCEMENT_DELETED"));
    }
}
