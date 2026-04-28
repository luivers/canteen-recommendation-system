package com.school.canteen.service;

import com.school.canteen.entity.Window;
import java.util.List;

/** 食堂窗口管理服务接口 */
public interface WindowService {
    
    /**
     * 获取所有窗口
     */
    List<Window> getAllWindows();
    
    /**
     * 根据ID获取窗口
     */
    Window getWindowById(Long id);
    
    /**
     * 保存窗口
     */
    Window saveWindow(Window window);
    
    /**
     * 更新窗口
     */
    Window updateWindow(Long id, Window window);
    
    /**
     * 删除窗口
     */
    void deleteWindow(Long id);
    
    /**
     * 根据食堂ID获取窗口
     */
    List<Window> getWindowsByCanteenId(Long canteenId);
    
    /**
     * 根据状态获取窗口
     */
    List<Window> getWindowsByStatus(Window.WindowStatus status);
    
    /**
     * 根据食堂ID和状态获取窗口
     */
    List<Window> getWindowsByCanteenIdAndStatus(Long canteenId, Window.WindowStatus status);
    
    /**
     * 更新窗口状态
     */
    Window updateWindowStatus(Long id, Window.WindowStatus status);
    
    /**
     * 获取仅处于 OPEN 状态的窗口列表（用户端可见性隔离）
     */
    List<Window> getOpenWindows();

    /**
     * 根据食堂ID获取仅处于 OPEN 状态的窗口列表（用户端可见性隔离）
     */
    List<Window> getOpenWindowsByCanteenId(Long canteenId);

    /**
     * 获取所有食堂列表（从dishes表中提取）
     */
    List<com.school.canteen.dto.CanteenDTO> getAllCanteens();
    
    /**
     * 从dishes表中同步窗口信息到windows表
     */
    void syncWindowsFromDishes();
}