package com.umutavci.thwscoinbackend.application.event;

import com.umutavci.thwscoinbackend.infrastructure.jpa.event.DeadLetterEventEntity;
import com.umutavci.thwscoinbackend.infrastructure.jpa.event.DeadLetterEventJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class EventRetryService {

    private static final int MAX_RETRIES = 3;

    private final DeadLetterEventJpaRepository dlqRepo;
    private final TransactionTemplate txTemplate;


    public void executeWithRetry(String eventId, Long orderId, String txHash, Runnable action) {

        int attempt = 0;

        while (attempt < MAX_RETRIES) {
            try {
                txTemplate.execute(status -> {
                    action.run();   // business logic: mensaUseCases.markOrderPaid vs.
                    return null;
                });
                return; // başarılı
            } catch (Exception ex) {
                attempt++;
                System.err.println("⚠️ Retry " + attempt + " failed for event: " + eventId);

                if (attempt >= MAX_RETRIES) {
                    moveToDLQ(eventId, orderId, txHash, ex);
                    return;
                }

                try {
                    Thread.sleep((long) Math.pow(2, attempt) * 200L);  // 200ms, 400ms, 800ms
                } catch (InterruptedException ignored) {}
            }
        }
    }

    private void moveToDLQ(String eventId, Long orderId, String txHash, Exception ex) {
        System.err.println("🟥 EVENT DLQ’YA DÜŞTÜ: " + eventId);

        DeadLetterEventEntity dlq = new DeadLetterEventEntity();
        dlq.setEventId(eventId);
        dlq.setOrderId(orderId);
        dlq.setTxHash(txHash);
        dlq.setRetryCount(MAX_RETRIES);
        dlq.setLastRetryAt(LocalDateTime.now());
        dlq.setErrorMessage(ex.getMessage());

        dlqRepo.save(dlq);
    }
}
