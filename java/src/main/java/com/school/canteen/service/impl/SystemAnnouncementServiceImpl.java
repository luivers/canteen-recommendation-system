package com.school.canteen.service.impl;

import com.school.canteen.entity.SystemAnnouncement;
import com.school.canteen.repository.SystemAnnouncementRepository;
import com.school.canteen.service.SystemAnnouncementService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/** 系统公告管理服务实现类 */
@Service
public class SystemAnnouncementServiceImpl implements SystemAnnouncementService {

    @Autowired
    private SystemAnnouncementRepository systemAnnouncementRepository;

    @Override
    public List<Map<String, Object>> getPublicAnnouncements() {
        LocalDateTime now = LocalDateTime.now();
        List<SystemAnnouncement> announcements = systemAnnouncementRepository.findEffectiveAnnouncements(
                SystemAnnouncement.AnnouncementStatus.PUBLISHED, now);
        return announcements.stream()
                .limit(5)
                .map(this::toSimpleMap)
                .collect(Collectors.toList());
    }

    @Override
    public List<Map<String, Object>> getAdminAnnouncements(String keyword) {
        List<SystemAnnouncement> announcements;
        if (keyword == null || keyword.isBlank()) {
            announcements = systemAnnouncementRepository.findAll(
                    PageRequest.of(0, 200, org.springframework.data.domain.Sort.by("updatedAt").descending())
            ).getContent();
        } else {
            announcements = systemAnnouncementRepository.searchForAdmin(keyword.trim(), PageRequest.of(0, 200));
        }
        return announcements.stream()
                .map(this::toSimpleMap)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void createAnnouncement(String title, String content) {
        SystemAnnouncement announcement = new SystemAnnouncement();
        announcement.setTitle(title);
        announcement.setContent(content);
        announcement.setStatus(SystemAnnouncement.AnnouncementStatus.PUBLISHED);
        announcement.setStartTime(LocalDateTime.now());
        systemAnnouncementRepository.save(announcement);
    }

    @Override
    @Transactional
    public void updateAnnouncement(Long id, String title, String content) {
        SystemAnnouncement announcement = systemAnnouncementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("公告不存在"));
        announcement.setTitle(title);
        announcement.setContent(content);
        systemAnnouncementRepository.save(announcement);
    }

    @Override
    @Transactional
    public void deleteAnnouncement(Long id) {
        SystemAnnouncement announcement = systemAnnouncementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("公告不存在"));
        systemAnnouncementRepository.delete(announcement);
    }

    private Map<String, Object> toSimpleMap(SystemAnnouncement announcement) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", announcement.getId());
        map.put("title", announcement.getTitle());
        map.put("content", announcement.getContent());
        map.put("createTime", announcement.getCreatedAt());
        return map;
    }
}
