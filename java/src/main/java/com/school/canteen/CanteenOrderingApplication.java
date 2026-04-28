package com.school.canteen;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * 学校食堂菜品推荐系统 — Spring Boot 启动类
 * <p>启用缓存、JPA仓库扫描、定时任务和异步执行</p>
 */
@SpringBootApplication
@EnableCaching
@EnableJpaRepositories
@EnableScheduling 
@org.springframework.scheduling.annotation.EnableAsync
public class CanteenOrderingApplication {

    public static void main(String[] args) {
        SpringApplication.run(CanteenOrderingApplication.class, args);
        System.out.println("高校食堂菜品推荐系统启动成功");
    }

}
