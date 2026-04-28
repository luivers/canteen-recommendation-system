package com.school.canteen.service;

import java.util.Map;

/** 天气信息服务接口，用于上下文感知推荐 */
public interface WeatherService {
    /**
     * 获取当前温度 (摄氏度)
     */
    int getCurrentTemperature();

    /**
     * 获取天气状况 (SUNNY, RAINY, CLOUDY, SNOWY)
     */
    String getWeatherCondition();

    /**
     * 获取详细天气信息 (支持经纬度查询)
     * @param lat 纬度
     * @param lon 经度
     * @return 天气信息 Map
     */
    Map<String, Object> getWeather(Double lat, Double lon);
}
