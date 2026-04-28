package com.school.canteen.repository;

import com.school.canteen.entity.Canteen;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/** 食堂数据访问层 */
@Repository
public interface CanteenRepository extends JpaRepository<Canteen, Long> {
    // 根据名称查询食堂
    Canteen findByName(String name);
}