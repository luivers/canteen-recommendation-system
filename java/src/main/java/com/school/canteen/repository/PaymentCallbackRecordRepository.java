package com.school.canteen.repository;

import com.school.canteen.entity.PaymentCallbackRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PaymentCallbackRecordRepository extends JpaRepository<PaymentCallbackRecord, Long> {

    Optional<PaymentCallbackRecord> findByIdempotencyKey(String idempotencyKey);

    Optional<PaymentCallbackRecord> findFirstByOrderNumberAndProcessStatusOrderByProcessedAtDesc(
        String orderNumber,
        PaymentCallbackRecord.ProcessStatus processStatus
    );
}
