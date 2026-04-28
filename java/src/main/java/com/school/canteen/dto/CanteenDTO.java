package com.school.canteen.dto;

import lombok.Data;

/**
 * 食堂DTO类，用于封装食堂信息
 */
@Data
public class CanteenDTO {
    private Long id;
    private String name;
    private int windowCount;
}