package com.school.canteen.repository;

import com.school.canteen.entity.CartItem;
import com.school.canteen.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/** 购物车项数据访问层 */
@Repository
public interface CartItemRepository extends JpaRepository<CartItem, Long> {
    List<CartItem> findByUser(User user);
    void deleteByUser(User user);
}