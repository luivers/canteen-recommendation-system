package com.school.canteen.repository;

import com.school.canteen.entity.Window;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/** 食堂窗口数据访问层 */
@Repository
public interface WindowRepository extends JpaRepository<Window, Long> {
    
    /**
     * 根据食堂ID查询窗口列表
     */
    List<Window> findByCanteenId(Long canteenId);
    
    /**
     * 根据状态查询窗口列表
     */
    List<Window> findByStatus(Window.WindowStatus status);
    
    /**
     * 根据食堂ID和状态查询窗口列表
     */
    List<Window> findByCanteenIdAndStatus(Long canteenId, Window.WindowStatus status);
    
    /**
     * 根据管理员ID查询窗口
     */
    List<Window> findByManagerId(Long managerId);
    
    /**
     * 根据窗口名称和食堂ID查询窗口
     */
    java.util.Optional<Window> findFirstByNameAndCanteenId(String name, Long canteenId);

    /**
     * 统计指定食堂下的窗口数量
     */
    long countByCanteenId(Long canteenId);
}
