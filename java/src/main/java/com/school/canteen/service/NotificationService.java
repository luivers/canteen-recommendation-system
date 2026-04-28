package com.school.canteen.service;

import com.school.canteen.entity.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/** 消息通知服务接口 */
public interface NotificationService {
    Notification sendNotification(Long userId,
                                  String title,
                                  String content,
                                  Notification.NotificationType type,
                                  Notification.NotificationScene scene,
                                  Notification.BizType bizType,
                                  Long bizId);

    Page<Notification> getUserNotifications(Long userId, Pageable pageable);
    Page<Notification> getUserNotificationsByType(Long userId, Notification.NotificationType type, Pageable pageable);
    Page<Notification> getAdminWarningNotifications(Long userId, Pageable pageable);
    Page<Notification> getUserNotificationsExcludingWarnings(Long userId, Pageable pageable);
    Page<Notification> getUserNotificationsByTypeExcludingWarnings(Long userId, Notification.NotificationType type, Pageable pageable);

    long getUnreadCount(Long userId);
    long getAdminWarningUnreadCount(Long userId);
    long getUnreadCountExcludingWarnings(Long userId);
    void markAsRead(Long userId, Long notificationId);
    void markAllAsRead(Long userId);
    void deleteReadNotifications(Long userId);
    void markAllAsReadExcludingWarnings(Long userId);
    void markAdminWarningAllRead(Long userId);

    boolean hasNotification(Long userId, String title, Long bizId);
}
