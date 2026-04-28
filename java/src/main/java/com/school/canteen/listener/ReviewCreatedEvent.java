package com.school.canteen.listener;

/** 评价创建事件，用于触发异步奖励发放 */
public record ReviewCreatedEvent(Long reviewId) {}
