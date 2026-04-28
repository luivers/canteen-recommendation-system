package com.school.canteen.repository;

import com.school.canteen.entity.DailyDishStatistic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

/** 每日菜品统计数据访问层 */
@Repository
public interface DailyDishStatisticRepository extends JpaRepository<DailyDishStatistic, Long> {
    List<DailyDishStatistic> findByDate(LocalDate date);
    boolean existsByDate(LocalDate date);
}
