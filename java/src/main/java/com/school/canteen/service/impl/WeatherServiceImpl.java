package com.school.canteen.service.impl;

import com.school.canteen.service.WeatherService;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.List;

/** 天气信息服务实现类，通过外部API获取实时天气数据 */
@Service
public class WeatherServiceImpl implements WeatherService {

    private static final Logger log = LoggerFactory.getLogger(WeatherServiceImpl.class);
    private final Random random = new Random();
    private final RestTemplate restTemplate;

    public WeatherServiceImpl(RestTemplateBuilder builder) {
        this.restTemplate = builder
                .setConnectTimeout(Duration.ofSeconds(2))
                .setReadTimeout(Duration.ofSeconds(2))
                .build();
    }

    @Override
    public int getCurrentTemperature() {
        // 简单策略：尝试获取一次默认位置天气，失败则使用随机
        try {
            Map<String, Object> weather = getWeather(null, null);
            if (weather.containsKey("temperature")) {
                return ((Number) weather.get("temperature")).intValue();
            }
        } catch (Exception ignored) {}
        return random.nextInt(41) - 5;
    }

    @Override
    public String getWeatherCondition() {
        try {
            Map<String, Object> weather = getWeather(null, null);
            if (weather.containsKey("condition")) {
                String cond = (String) weather.get("condition");
                // 转换中文描述为枚举字符串 (简单映射)
                if (cond.contains("晴")) return "SUNNY";
                if (cond.contains("云") || cond.contains("阴") || cond.contains("雾")) return "CLOUDY";
                if (cond.contains("雨")) return "RAINY";
                if (cond.contains("雪")) return "SNOWY";
            }
        } catch (Exception ignored) {}
        
        String[] conditions = {"SUNNY", "CLOUDY", "RAINY", "SNOWY"};
        return conditions[random.nextInt(conditions.length)];
    }

    @Override
    public Map<String, Object> getWeather(Double lat, Double lon) {
        // 默认坐标 (北京)
        if (lat == null) lat = 39.9042;
        if (lon == null) lon = 116.4074;

        Map<String, Object> result = new HashMap<>();
        try {
            String url = String.format(
                "https://api.open-meteo.com/v1/forecast?latitude=%f&longitude=%f&current_weather=true&daily=temperature_2m_max,temperature_2m_min&timezone=auto",
                lat, lon
            );
            
            Map<?, ?> response = restTemplate.getForObject(url, Map.class);
            if (response != null) {
                Map<?, ?> current = asMap(response.get("current_weather"));
                Map<?, ?> daily = asMap(response.get("daily"));

                boolean hasCurrent = false;
                if (current != null && current.get("temperature") != null && current.get("weathercode") != null) {
                    double temp = ((Number) current.get("temperature")).doubleValue();
                    int code = ((Number) current.get("weathercode")).intValue();

                    result.put("temperature", temp);
                    result.put("condition", parseWeatherCode(code));
                    result.put("icon", getWeatherIcon(code));
                    hasCurrent = true;
                }
                
                if (daily != null) {
                    List<Number> maxList = asNumberList(daily.get("temperature_2m_max"));
                    List<Number> minList = asNumberList(daily.get("temperature_2m_min"));
                    if (maxList != null && !maxList.isEmpty()) result.put("maxTemp", maxList.get(0));
                    if (minList != null && !minList.isEmpty()) result.put("minTemp", minList.get(0));
                }
                if (!result.containsKey("maxTemp")) result.put("maxTemp", null);
                if (!result.containsKey("minTemp")) result.put("minTemp", null);
                if (hasCurrent) {
                    result.put("city", "当前位置");
                    return result;
                }
            }
        } catch (Exception e) {
            log.warn("Weather API call failed: {}", e.getMessage());
        }

        // 降级：返回随机数据
        int temp = random.nextInt(41) - 5;
        result.put("temperature", temp);
        result.put("maxTemp", temp + 5);
        result.put("minTemp", temp - 5);
        
        String[] conditions = {"晴朗", "多云", "雨", "雪"};
        String cond = conditions[random.nextInt(conditions.length)];
        result.put("condition", cond);
        
        if (cond.equals("晴朗")) result.put("icon", "Sunny");
        else if (cond.equals("多云")) result.put("icon", "Cloudy");
        else if (cond.equals("雨")) result.put("icon", "Pouring");
        else result.put("icon", "Lightning");
        
        result.put("city", "未知城市");
        return result;
    }

    private String parseWeatherCode(int code) {
        if (code == 0) return "晴朗";
        if (code <= 3) return "多云";
        if (code <= 48) return "雾";
        if (code <= 67) return "雨";
        if (code <= 77) return "雪";
        if (code <= 82) return "阵雨";
        if (code <= 86) return "阵雪";
        return "雷雨";
    }

    private String getWeatherIcon(int code) {
        if (code == 0) return "Sunny";
        if (code <= 3 || code == 45 || code == 48) return "Cloudy";
        if (code >= 71 && code <= 77) return "Lightning"; // Snow
        if (code >= 85 && code <= 86) return "Lightning"; // Snow showers
        if (code >= 95) return "Lightning"; // Thunderstorm
        return "Pouring"; // Rain
    }

    private Map<?, ?> asMap(Object value) {
        if (value instanceof Map<?, ?> map) {
            return map;
        }
        return null;
    }

    private List<Number> asNumberList(Object value) {
        if (!(value instanceof List<?> list)) {
            return null;
        }
        for (Object item : list) {
            if (item != null && !(item instanceof Number)) {
                return null;
            }
        }
        return list.stream()
                .map(item -> item == null ? null : (Number) item)
                .toList();
    }
}
