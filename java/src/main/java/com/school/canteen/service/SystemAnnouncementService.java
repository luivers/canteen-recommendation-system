package com.school.canteen.service;

import java.util.List;
import java.util.Map;

/** 系统公告管理服务接口 */
public interface SystemAnnouncementService {

    List<Map<String, Object>> getPublicAnnouncements();

    List<Map<String, Object>> getAdminAnnouncements(String keyword);

    void createAnnouncement(String title, String content);

    void updateAnnouncement(Long id, String title, String content);

    void deleteAnnouncement(Long id);
}
