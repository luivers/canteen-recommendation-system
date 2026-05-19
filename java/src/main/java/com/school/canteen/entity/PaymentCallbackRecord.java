package com.school.canteen.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(
    name = "payment_callback_records",
    uniqueConstraints = @UniqueConstraint(name = "uk_payment_callback_idempotency_key", columnNames = "idempotency_key")
)
@Data
public class PaymentCallbackRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 32)
    private String provider;

    @Column(name = "order_number", nullable = false, length = 64)
    private String orderNumber;

    @Column(name = "payment_method", nullable = false, length = 32)
    private String paymentMethod;

    @Column(name = "transaction_id", nullable = false, length = 128)
    private String transactionId;

    @Column(name = "idempotency_key", nullable = false, length = 255)
    private String idempotencyKey;

    @Enumerated(EnumType.STRING)
    @Column(name = "process_status", nullable = false, length = 32)
    private ProcessStatus processStatus = ProcessStatus.PROCESSING;

    @Column(name = "raw_payload_hash", length = 64)
    private String rawPayloadHash;

    @Column(name = "attempt_count", nullable = false)
    private Integer attemptCount = 1;

    @Column(name = "first_received_at", nullable = false, updatable = false)
    private LocalDateTime firstReceivedAt;

    @Column(name = "last_received_at", nullable = false)
    private LocalDateTime lastReceivedAt;

    @Column(name = "processed_at")
    private LocalDateTime processedAt;

    @Column(name = "error_message", length = 500)
    private String errorMessage;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        if (firstReceivedAt == null) {
            firstReceivedAt = now;
        }
        if (lastReceivedAt == null) {
            lastReceivedAt = now;
        }
        if (attemptCount == null || attemptCount < 1) {
            attemptCount = 1;
        }
    }

    public void markAttempt(LocalDateTime receivedAt) {
        attemptCount = attemptCount == null ? 1 : attemptCount + 1;
        lastReceivedAt = receivedAt != null ? receivedAt : LocalDateTime.now();
    }

    public enum ProcessStatus {
        PROCESSING,
        PROCESSED,
        DUPLICATE,
        CONFLICT,
        FAILED
    }
}
