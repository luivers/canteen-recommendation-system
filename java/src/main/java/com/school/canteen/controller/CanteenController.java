package com.school.canteen.controller;

import com.school.canteen.entity.Canteen;
import com.school.canteen.service.CanteenService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** 食堂控制器 — 食堂信息的 CRUD */
@RestController
@RequestMapping("/api/canteens")
@RequiredArgsConstructor
public class CanteenController {
    
    private final CanteenService canteenService;
    
    // 食堂管理API
    @PostMapping
    public ResponseEntity<Canteen> createCanteen(@RequestBody Canteen canteen) {
        return ResponseEntity.ok(canteenService.createCanteen(canteen));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Canteen> updateCanteen(@PathVariable Long id, @RequestBody Canteen canteen) {
        return ResponseEntity.ok(canteenService.updateCanteen(id, canteen));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCanteen(@PathVariable Long id) {
        canteenService.deleteCanteen(id);
        return ResponseEntity.ok().build();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Canteen> getCanteenById(@PathVariable Long id) {
        return canteenService.getCanteenById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping
    public ResponseEntity<List<Canteen>> getAllCanteens() {
        return ResponseEntity.ok(canteenService.getAllCanteens());
    }
    
    @GetMapping("/name/{name}")
    public ResponseEntity<Canteen> getCanteenByName(@PathVariable String name) {
        return ResponseEntity.ok(canteenService.getCanteenByName(name));
    }
    

}