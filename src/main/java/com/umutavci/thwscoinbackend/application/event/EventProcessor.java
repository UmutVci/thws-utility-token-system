package com.umutavci.thwscoinbackend.application.event;

import com.umutavci.thwscoinbackend.application.mensa.MensaOrderUseCases;
import com.umutavci.thwscoinbackend.application.transaction.LedgerService;
import com.umutavci.thwscoinbackend.domain.event.EventLog;
import com.umutavci.thwscoinbackend.domain.event.EventLogRepository;
import com.umutavci.thwscoinbackend.domain.event.EventStateRepository;
import com.umutavci.thwscoinbackend.domain.mensa.MensaOrder;
import com.umutavci.thwscoinbackend.infrastructure.blockchain.PaymentManager;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EventProcessor {

    private final EventLogRepository eventLogRepo;
    private final EventStateRepository eventStateRepo;
    private final MensaOrderUseCases mensaUseCases;
    private final LedgerService ledgerService;

    public void processServicePayment(PaymentManager.ServicePaymentEventResponse event) {
        String eventId = event.log.getTransactionHash() + "-" + event.log.getLogIndex();

        // Idempotency
        if (eventLogRepo.exists(eventId)) {
            return;
        }

        long orderId = event.orderId.longValue();
        String txHash = event.log.getTransactionHash();

        // Listener contextinde authenticated user bulunmaz; order direct okunur.
        MensaOrder order = mensaUseCases.getOrder(orderId, 0L);
        mensaUseCases.markOrderPaid(orderId, txHash);

        eventLogRepo.save(new EventLog(
                eventId,
                event.log.getBlockNumber().longValue(),
                txHash,
                Integer.parseInt(String.valueOf(event.log.getLogIndex()))
        ));

        eventStateRepo.updateLastProcessedBlock(
                event.log.getBlockNumber().longValue()
        );

        ledgerService.recordSpend(
                order.getStudentUserId(),
                order.getAmount() * 100L,
                order.getId(),
                txHash
        );
    }
}
