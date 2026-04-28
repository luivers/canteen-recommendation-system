package com.school.canteen.service.impl;

import com.school.canteen.entity.Window;
import com.school.canteen.entity.Dish;
import com.school.canteen.repository.WindowRepository;
import com.school.canteen.repository.DishRepository;
import com.school.canteen.service.WindowService;
import com.school.canteen.dto.CanteenDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/** 食堂窗口管理服务实现类 */
@Service
@Transactional
public class WindowServiceImpl implements WindowService {

    @Autowired
    private WindowRepository windowRepository;
    
    @Autowired
    private DishRepository dishRepository;
    
    @Override
    public List<Window> getAllWindows() {
        return windowRepository.findAll();
    }
    
    @Override
    public Window getWindowById(Long id) {
        return windowRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Window not found with id: " + id));
    }
    
    @Override
    public Window saveWindow(Window window) {
        return windowRepository.save(window);
    }
    
    @Override
    public Window updateWindow(Long id, Window window) {
        Window existingWindow = getWindowById(id);
        existingWindow.setName(window.getName());
        existingWindow.setLocation(window.getLocation());
        existingWindow.setManagerId(window.getManagerId());
        existingWindow.setManagerName(window.getManagerName());
        existingWindow.setOperatingHours(window.getOperatingHours());
        Window.WindowStatus newStatus = window.getStatus();
        existingWindow.setStatus(newStatus);
        existingWindow.setCanteenId(window.getCanteenId());
        existingWindow.setCanteenName(window.getCanteenName());
        Window saved = windowRepository.save(existingWindow);
        // 窗口关闭或维护时，将该窗口下所有在售菜品同步下架
        if (newStatus == Window.WindowStatus.CLOSED || newStatus == Window.WindowStatus.MAINTENANCE) {
            dishRepository.discontinueAvailableDishesByWindowId(id, Dish.DishStatus.AVAILABLE, Dish.DishStatus.DISCONTINUED);
        }
        return saved;
    }
    
    @Override
    public void deleteWindow(Long id) {
        windowRepository.deleteById(id);
    }
    
    @Override
    public List<Window> getWindowsByCanteenId(Long canteenId) {
        return windowRepository.findByCanteenId(canteenId);
    }
    
    @Override
    public List<Window> getWindowsByStatus(Window.WindowStatus status) {
        return windowRepository.findByStatus(status);
    }
    
    @Override
    public List<Window> getWindowsByCanteenIdAndStatus(Long canteenId, Window.WindowStatus status) {
        return windowRepository.findByCanteenIdAndStatus(canteenId, status);
    }
    
    @Override
    public Window updateWindowStatus(Long id, Window.WindowStatus status) {
        Window window = getWindowById(id);
        window.setStatus(status);
        Window saved = windowRepository.save(window);
        // 窗口关闭或维护时，将该窗口下所有在售菜品同步下架
        if (status == Window.WindowStatus.CLOSED || status == Window.WindowStatus.MAINTENANCE) {
            dishRepository.discontinueAvailableDishesByWindowId(id, Dish.DishStatus.AVAILABLE, Dish.DishStatus.DISCONTINUED);
        }
        return saved;
    }
    
    @Override
    public List<Window> getOpenWindows() {
        return windowRepository.findByStatus(Window.WindowStatus.OPEN);
    }

    @Override
    public List<Window> getOpenWindowsByCanteenId(Long canteenId) {
        return windowRepository.findByCanteenIdAndStatus(canteenId, Window.WindowStatus.OPEN);
    }

    @Override
    public List<CanteenDTO> getAllCanteens() {
        // 从 windows 表中提取所有食堂信息
        List<Window> allWindows = windowRepository.findAll();
        
        // 按食堂ID分组
        Map<Long, List<Window>> canteenMap = allWindows.stream()
                .filter(w -> w.getCanteenId() != null)
                .collect(Collectors.groupingBy(Window::getCanteenId));
                
        List<CanteenDTO> canteens = new ArrayList<>();
        
        for (Map.Entry<Long, List<Window>> entry : canteenMap.entrySet()) {
            Long canteenId = entry.getKey();
            List<Window> windows = entry.getValue();
            
            // 获取食堂名称（取第一个非空的名称）
            String canteenName = windows.stream()
                    .map(Window::getCanteenName)
                    .filter(name -> name != null && !name.isEmpty())
                    .findFirst()
                    .orElse("未知食堂");
            
            CanteenDTO dto = new CanteenDTO();
            dto.setId(canteenId);
            dto.setName(canteenName);
            dto.setWindowCount(windows.size());
            canteens.add(dto);
        }
        
        // 按食堂ID排序
        canteens.sort(Comparator.comparing(CanteenDTO::getId));
        
        return canteens;
    }
    
    @Override
    public void syncWindowsFromDishes() {
        List<Dish> allDishes = dishRepository.findAll();
        
        // 1. Group dishes by (canteenId, windowName) to ensure consistency
        Map<String, List<Dish>> groupedDishes = new HashMap<>();
        
        for (Dish dish : allDishes) {
            Long canteenId = dish.getCanteenId();
            String windowName = dish.getWindowName();
            
            // Skip dishes without window name as we can't identify the window reliably
            if (windowName == null || windowName.trim().isEmpty()) {
                continue; 
            }
            
            if (canteenId == null) canteenId = 1L; // Default canteen ID
            
            String key = canteenId + "###" + windowName.trim();
            groupedDishes.computeIfAbsent(key, k -> new ArrayList<>()).add(dish);
        }
        
        // Sort keys to ensure Canteen order (1, 2, 3...) and then Window Name order
        List<String> sortedKeys = new ArrayList<>(groupedDishes.keySet());
        sortedKeys.sort((k1, k2) -> {
            String[] parts1 = k1.split("###");
            String[] parts2 = k2.split("###");
            Long cid1 = Long.parseLong(parts1[0]);
            Long cid2 = Long.parseLong(parts2[0]);
            
            int cComp = cid1.compareTo(cid2);
            if (cComp != 0) return cComp;
            
            return parts1[1].compareTo(parts2[1]);
        });
        
        // 2. Process each group in sorted order
        for (String key : sortedKeys) {
            List<Dish> dishes = groupedDishes.get(key);
            String[] parts = key.split("###");
            Long canteenId = Long.parseLong(parts[0]);
            String windowName = parts[1];
            
            // Find existing window by name and canteen
            Optional<Window> existingWindowOpt = windowRepository.findFirstByNameAndCanteenId(windowName, canteenId);
            Window window;
            
            if (existingWindowOpt.isPresent()) {
                window = existingWindowOpt.get();
                // Update existing window info if needed (optional, using first dish's info)
                Dish first = dishes.get(0);
                boolean changed = false;
                if (first.getWindowLocation() != null && !first.getWindowLocation().isEmpty() && 
                    (window.getLocation() == null || window.getLocation().isEmpty())) {
                    window.setLocation(first.getWindowLocation());
                    changed = true;
                }
                if (changed) {
                    window = windowRepository.save(window);
                }
            } else {
                // Create new window
                window = new Window();
                window.setName(windowName);
                window.setCanteenId(canteenId);
                
                Dish first = dishes.get(0);
                window.setCanteenName(first.getCanteenName() != null ? first.getCanteenName() : "未知食堂");
                window.setLocation(first.getWindowLocation() != null ? first.getWindowLocation() : "");
                window.setStatus(Window.WindowStatus.OPEN);
                
                String hours = "08:00-18:00";
                if (windowName.contains("早餐")) hours = "06:30-10:30";
                else if (windowName.contains("夜宵")) hours = "18:00-22:00";
                window.setOperatingHours(hours);
                
                window = windowRepository.save(window);
            }
            
            // 3. Update dishes to point to this window
            List<Dish> toUpdate = new ArrayList<>();
            for (Dish dish : dishes) {
                if (dish.getWindowId() == null || !dish.getWindowId().equals(window.getId())) {
                    dish.setWindowId(window.getId());
                    toUpdate.add(dish);
                }
            }
            
            if (!toUpdate.isEmpty()) {
                dishRepository.saveAll(toUpdate);
            }
        }
        cleanOrphanedWindows(allDishes);
    }
    
    /**
     * 清理windows表中不在dishes表中的窗口
     */
    private void cleanOrphanedWindows(List<Dish> allDishes) {
        // 收集所有存在于dishes表中的windowId
        Set<Long> activeWindowIds = allDishes.stream()
                .map(Dish::getWindowId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        
        // 获取windows表中所有窗口
        List<Window> allWindows = windowRepository.findAll();
        
        // 删除不在dishes表中的窗口
        for (Window window : allWindows) {
            if (!activeWindowIds.contains(window.getId())) {
                windowRepository.delete(window);
            }
        }
    }
}
