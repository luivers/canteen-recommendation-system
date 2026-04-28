package com.school.canteen.service;

import com.school.canteen.entity.Order;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/** 订单状态变更SSE推送服务 */
@Service
public class OrderEventService {
    private final Set<SseEmitter> emitters = ConcurrentHashMap.newKeySet();
    
    public SseEmitter createEmitter() {
        // 设置一个较长的超时时间（如1小时），避免无限等待导致的资源泄漏，但依赖前端重连和后端心跳
        SseEmitter emitter = new SseEmitter(3600000L); 
        emitters.add(emitter);
        emitter.onCompletion(() -> emitters.remove(emitter));
        emitter.onTimeout(() -> emitters.remove(emitter));
        emitter.onError(e -> emitters.remove(emitter));
        return emitter;
    }

    // 添加定时心跳机制，防止代理服务器(如Vite, Nginx)因为长时间无数据而断开连接
    @Scheduled(fixedRate = 30000) // 每30秒发送一次心跳
    public void sendHeartbeat() {
        emitters.forEach(emitter -> {
            try {
                emitter.send(SseEmitter.event()
                    .name("ping")
                    .data("heartbeat"));
            } catch (Exception e) {
                emitter.complete();
                emitters.remove(emitter);
            }
        });
    }
    
    public void publishOrderUpdate(Order order) {
        emitters.forEach(emitter -> {
            try {
                emitter.send(SseEmitter.event()
                    .name("order-update")
                    .data(new OrderUpdatePayload(order)));
            } catch (IOException e) {
                emitter.complete();
                emitters.remove(emitter);
            }
        });
    }
    
    public static class OrderUpdatePayload {
        public Long id;
        public String orderNumber;
        public String status;
        public String paymentMethod;
        public String transactionId;
        public String paymentTime;
        
        public OrderUpdatePayload(Order o) {
            this.id = o.getId();
            this.orderNumber = o.getOrderNumber();
            this.status = o.getStatus() != null ? o.getStatus().name() : null;
            if (o.getOrderItems() != null && !o.getOrderItems().isEmpty()) {
                com.school.canteen.entity.OrderItem item = o.getOrderItems().get(0);
                this.paymentMethod = item.getPaymentMethod();
                this.transactionId = item.getPaymentTransactionId();
                this.paymentTime = item.getPaymentTime() != null ? item.getPaymentTime().toString() : null;
            }
        }
    }
}
