package com.umutavci.thwscoinbackend.application.mensa;

import com.umutavci.thwscoinbackend.application.event.EventProcessor;
import com.umutavci.thwscoinbackend.application.event.EventRetryService;
import com.umutavci.thwscoinbackend.domain.event.EventStateRepository;
import com.umutavci.thwscoinbackend.infrastructure.blockchain.PaymentManager;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.DefaultBlockParameterNumber;

@Service
@ConditionalOnProperty(name = "blockchain.enabled", havingValue = "true")
public class MensaPaymentListener {

    public MensaPaymentListener(
            PaymentManager contract,
            EventProcessor processor,
            EventRetryService retryService,
            EventStateRepository eventStateRepo
    ) {
        long startBlock = eventStateRepo.getLastProcessedBlock() + 1;

        contract.servicePaymentEventFlowable(
                new DefaultBlockParameterNumber(startBlock),
                DefaultBlockParameterName.LATEST
        ).subscribe(event -> {

            String eventId = event.log.getTransactionHash() + "-" + event.log.getLogIndex();
            Long orderId = event.orderId.longValue();           // wrapper'dan geliyor
            String txHash = event.log.getTransactionHash();

            retryService.executeWithRetry(
                    eventId,
                    orderId,
                    txHash,
                    () -> processor.processServicePayment(event)   // burada asıl iş
            );
        });
    }
}
