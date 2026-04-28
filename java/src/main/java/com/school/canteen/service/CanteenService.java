package com.school.canteen.service;

import com.school.canteen.entity.Canteen;

import java.util.List;
import java.util.Optional;

/** 食堂管理服务接口 */
public interface CanteenService {
    // 食堂管理
    Canteen createCanteen(Canteen canteen);
    Canteen updateCanteen(Long id, Canteen canteen);
    void deleteCanteen(Long id);
    Optional<Canteen> getCanteenById(Long id);
    List<Canteen> getAllCanteens();
    Canteen getCanteenByName(String name);
    

}