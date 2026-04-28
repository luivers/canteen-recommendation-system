package com.school.canteen.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** 菜品每日销售统计实体 — 记录每天每道菜的销量、收入等数据 */
@Entity
@Table(name = "daily_dish_statistics")
@Data
public class DailyDishStatistic {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "dish_id", nullable = false)
    private Long dishId;

    @Column(name = "dish_name", nullable = false)
    private String dishName;

    @Column(name = "statistic_date", nullable = false)
    private LocalDate date;

    @Column(name = "daily_limit")
    private Integer dailyLimit;

    @Column(name = "total_supply")
    private Integer totalSupply;

    @Column(name = "sales")
    private Integer sales;

    @Column(name = "end_stock")
    private Integer endStock;

    @Column(name = "alert_level")
    private String alertLevel; // CRITICAL, WARNING, NORMAL

    @Column(name = "alert_message", length = 500)
    private String alertMessage;

    @Column(name = "create_time")
    private LocalDateTime createTime;

    @PrePersist
    public void prePersist() {
        if (createTime == null) {
            createTime = LocalDateTime.now();
        }
    }
}
