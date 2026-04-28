package com.school.canteen.service.impl;

import com.school.canteen.entity.Notification;
import com.school.canteen.repository.NotificationRepository;
import com.school.canteen.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/** 消息通知服务实现类 */
@Service
public class NotificationServiceImpl implements NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    private static final String ADMIN_WARNING_TITLE = "评价预警";

    @Override
    @Transactional
    public Notification sendNotification(Long userId,
                                         String title,
                                         String content,
                                         Notification.NotificationType type,
                                         Notification.NotificationScene scene,
                                         Notification.BizType bizType,
                                         Long bizId) {
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setTitle(title);
        notification.setContent(content);
        notification.setType(type);
        notification.setScene(scene);
        notification.setBizType(bizType);
        notification.setBizId(bizId);
        return notificationRepository.save(notification);
    }

    @Override
    public Page<Notification> getUserNotifications(Long userId, Pageable pageable) {
        return notificationRepository.findByUserIdAndDeletedFalseOrderByCreateTimeDesc(userId, pageable);
    }

    @Override
    public Page<Notification> getUserNotificationsByType(Long userId, Notification.NotificationType type, Pageable pageable) {
        return notificationRepository.findByUserIdAndDeletedFalseAndTypeOrderByCreateTimeDesc(userId, type, pageable);
    }

    @Override
    public Page<Notification> getAdminWarningNotifications(Long userId, Pageable pageable) {
        // 查询所有类型为WARNING的通知（包括销量异常、库存预警、评价预警等）
        return notificationRepository.findByUserIdAndDeletedFalseAndTypeOrderByCreateTimeDesc(
                userId,
                Notification.NotificationType.WARNING,
                pageable
        );
    }

    @Override
    public Page<Notification> getUserNotificationsExcludingWarnings(Long userId, Pageable pageable) {
        return notificationRepository.findByUserIdAndDeletedFalseAndExcludeBizTypeAndTitle(
                userId,
                Notification.BizType.REVIEW,
                ADMIN_WARNING_TITLE,
                pageable
        );
    }

    @Override
    public Page<Notification> getUserNotificationsByTypeExcludingWarnings(Long userId, Notification.NotificationType type, Pageable pageable) {
        return notificationRepository.findByUserIdAndDeletedFalseAndTypeAndExcludeBizTypeAndTitle(
                userId,
                type,
                Notification.BizType.REVIEW,
                ADMIN_WARNING_TITLE,
                pageable
        );
    }

    @Override
    public long getUnreadCount(Long userId) {
        return notificationRepository.countByUserIdAndDeletedFalseAndIsReadFalse(userId);
    }

    @Override
    public long getAdminWarningUnreadCount(Long userId) {
        // 查询所有类型为WARNING的未读通知数量
        return notificationRepository.countByUserIdAndDeletedFalseAndIsReadFalseAndType(
                userId,
                Notification.NotificationType.WARNING
        );
    }

    @Override
    public long getUnreadCountExcludingWarnings(Long userId) {
        return notificationRepository.countByUserIdAndDeletedFalseAndIsReadFalseAndExcludeBizTypeAndTitle(
                userId,
                Notification.BizType.REVIEW,
                ADMIN_WARNING_TITLE
        );
    }

    @Override
    @Transactional
    public void markAsRead(Long userId, Long notificationId) {
        Notification notification = notificationRepository.findByIdAndUserIdAndDeletedFalse(notificationId, userId)
                .orElseThrow(() -> new RuntimeException("通知不存在或无权操作"));
        notification.setIsRead(true);
        notification.setReadTime(java.time.LocalDateTime.now());
        notificationRepository.save(notification);
    }

    @Override
    @Transactional
    public void markAllAsRead(Long userId) {
        List<Notification> unreadNotifications = notificationRepository.findByUserIdAndDeletedFalseAndIsReadFalse(userId);
        for (Notification notification : unreadNotifications) {
            notification.setIsRead(true);
            notification.setReadTime(java.time.LocalDateTime.now());
        }
        notificationRepository.saveAll(unreadNotifications);
    }

    @Override
    @Transactional
    public void deleteReadNotifications(Long userId) {
        notificationRepository.markReadAsDeleted(userId);
    }

    @Override
    @Transactional
    public void markAllAsReadExcludingWarnings(Long userId) {
        List<Notification> unreadNotifications = notificationRepository.findByUserIdAndDeletedFalseAndIsReadFalseAndExcludeBizTypeAndTitle(
                userId,
                Notification.BizType.REVIEW,
                ADMIN_WARNING_TITLE
        );
        for (Notification notification : unreadNotifications) {
            notification.setIsRead(true);
            notification.setReadTime(java.time.LocalDateTime.now());
        }
        notificationRepository.saveAll(unreadNotifications);
    }

    @Override
    @Transactional
    public void markAdminWarningAllRead(Long userId) {
        // 标记所有类型为WARNING的未读通知为已读
        List<Notification> unreadNotifications = notificationRepository.findByUserIdAndDeletedFalseAndIsReadFalseAndType(
                userId,
                Notification.NotificationType.WARNING
        );
        for (Notification notification : unreadNotifications) {
            notification.setIsRead(true);
            notification.setReadTime(java.time.LocalDateTime.now());
        }
        notificationRepository.saveAll(unreadNotifications);
    }

    @Override
    public boolean hasNotification(Long userId, String title, Long bizId) {
        return notificationRepository.existsByUserIdAndTitleAndBizIdAndDeletedFalse(userId, title, bizId);
    }
}
