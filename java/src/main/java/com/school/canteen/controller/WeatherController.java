package com.school.canteen.controller;

import com.school.canteen.service.WeatherService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/** 天气控制器 — 获取当前天气信息（用于上下文感知推荐） */
@RestController
@RequestMapping("/api/weather")
public class WeatherController {

    @Autowired
    private WeatherService weatherService;

    @GetMapping("/current")
    public ResponseEntity<Map<String, Object>> getCurrentWeather(
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lon) {
        return ResponseEntity.ok(weatherService.getWeather(lat, lon));
    }
}
