package com.school.canteen.controller;

import com.school.canteen.entity.Window;
import com.school.canteen.service.WindowService;
import com.school.canteen.dto.CanteenDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** 窗口控制器 — 食堂窗口的 CRUD */
@RestController
@RequestMapping("/api/windows")
public class WindowController {
    
    @Autowired
    private WindowService windowService;
    
    /**
     * 获取所有窗口
     * @param activeOnly 若为 true，仅返回 OPEN 状态的窗口（用户端可见性隔离）
     */
    @GetMapping
    public ResponseEntity<List<Window>> getAllWindows(
            @RequestParam(required = false, defaultValue = "false") boolean activeOnly) {
        List<Window> windows = activeOnly
                ? windowService.getOpenWindows()
                : windowService.getAllWindows();
        return ResponseEntity.ok(windows);
    }
    
    /**
     * 根据ID获取窗口
     */
    @GetMapping("/{id}")
    public ResponseEntity<Window> getWindowById(@PathVariable Long id) {
        Window window = windowService.getWindowById(id);
        return ResponseEntity.ok(window);
    }
    
    /**
     * 创建窗口
     */
    @PostMapping
    public ResponseEntity<Window> createWindow(@RequestBody Window window) {
        Window savedWindow = windowService.saveWindow(window);
        return ResponseEntity.ok(savedWindow);
    }
    
    /**
     * 更新窗口
     */
    @PutMapping("/{id}")
    public ResponseEntity<Window> updateWindow(@PathVariable Long id, @RequestBody Window window) {
        Window updatedWindow = windowService.updateWindow(id, window);
        return ResponseEntity.ok(updatedWindow);
    }
    
    /**
     * 删除窗口
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteWindow(@PathVariable Long id) {
        windowService.deleteWindow(id);
        return ResponseEntity.noContent().build();
    }
    
    /**
     * 根据食堂ID获取窗口
     * @param activeOnly 若为 true，仅返回 OPEN 状态的窗口（用户端可见性隔离）
     */
    @GetMapping("/canteen/{canteenId}")
    public ResponseEntity<List<Window>> getWindowsByCanteenId(
            @PathVariable Long canteenId,
            @RequestParam(required = false, defaultValue = "false") boolean activeOnly) {
        List<Window> windows = activeOnly
                ? windowService.getOpenWindowsByCanteenId(canteenId)
                : windowService.getWindowsByCanteenId(canteenId);
        return ResponseEntity.ok(windows);
    }
    
    /**
     * 根据状态获取窗口
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<List<Window>> getWindowsByStatus(@PathVariable Window.WindowStatus status) {
        List<Window> windows = windowService.getWindowsByStatus(status);
        return ResponseEntity.ok(windows);
    }
    
    /**
     * 更新窗口状态
     */
    @PatchMapping("/{id}/status")
    public ResponseEntity<Window> updateWindowStatus(@PathVariable Long id, @RequestBody WindowStatusUpdateRequest statusUpdateRequest) {
        Window window = windowService.updateWindowStatus(id, statusUpdateRequest.getStatus());
        return ResponseEntity.ok(window);
    }
    
    /**
     * 获取所有食堂列表
     */
    @GetMapping("/canteens")
    public ResponseEntity<List<CanteenDTO>> getAllCanteens() {
        List<CanteenDTO> canteens = windowService.getAllCanteens();
        return ResponseEntity.ok(canteens);
    }
    
    /**
     * 从dishes表同步窗口信息
     */
    @PostMapping("/sync")
    public ResponseEntity<Void> syncWindowsFromDishes() {
        windowService.syncWindowsFromDishes();
        return ResponseEntity.noContent().build();
    }
    
    /**
     * 内部类：窗口状态更新请求
     */
    static class WindowStatusUpdateRequest {
        private Window.WindowStatus status;
        
        public Window.WindowStatus getStatus() {
            return status;
        }
        
        public void setStatus(Window.WindowStatus status) {
            this.status = status;
        }
    }
}