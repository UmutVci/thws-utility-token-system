package com.umutavci.thwscoinbackend.application.event;

import com.umutavci.thwscoinbackend.application.mensa.MensaOrderUseCases;
import com.umutavci.thwscoinbackend.domain.event.EventLog;
import com.umutavci.thwscoinbackend.domain.event.EventLogRepository;
import com.umutavci.thwscoinbackend.domain.event.EventStateRepository;
import com.umutavci.thwscoinbackend.infrastructure.blockchain.PaymentManager;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EventProcessor {

    private final EventLogRepository eventLogRepo;
    private final EventStateRepository eventStateRepo;
    private final MensaOrderUseCases mensaUseCases;


    public void processServicePayment(PaymentManager.ServicePaymentEventResponse event) {

        String eventId = event.log.getTransactionHash() + "-" + event.log.getLogIndex();

        // 1️⃣ Idempotency
        if (eventLogRepo.exists(eventId)) {
            return;
        }
        // 2️⃣ Business logic
        long orderId = event.orderId.longValue();
        String txHash = event.log.getTransactionHash();

        mensaUseCases.markOrderPaid(orderId, txHash);

        // 3️⃣ Event log kaydet
        eventLogRepo.save(new EventLog(
                eventId,
                event.log.getBlockNumber().longValue(),
                txHash,
                Integer.parseInt(String.valueOf(event.log.getLogIndex()))
        ));

        // 4️⃣ lastProcessedBlock güncelle
        eventStateRepo.updateLastProcessedBlock(
                event.log.getBlockNumber().longValue()
        );
    }
}

