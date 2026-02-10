package com.umutavci.thwscoinbackend.application.mensa;

import com.umutavci.thwscoinbackend.application.event.EventProcessor;
import com.umutavci.thwscoinbackend.application.event.EventRetryService;
import com.umutavci.thwscoinbackend.domain.event.EventStateRepository;
import com.umutavci.thwscoinbackend.infrastructure.blockchain.PaymentManager;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.DefaultBlockParameterNumber;

@Service
@Slf4j
@ConditionalOnProperty(name = "blockchain.enabled", havingValue = "true")
public class MensaPaymentListener {

    public MensaPaymentListener(
            PaymentManager contract,
            EventProcessor processor,
            EventRetryService retryService,
            EventStateRepository eventStateRepo,
            Web3j web3j,
            @Value("${blockchain.listener.max-catchup-blocks:10}") long maxCatchupBlocks
    ) {
        long latestBlock = fetchLatestBlock(web3j);
        long requestedStart = eventStateRepo.getLastProcessedBlock() + 1;

        // Free-tier RPC sağlayıcıları geniş aralıklı eth_newFilter çağrılarını reddedebilir.
        long safeStart = Math.max(requestedStart, Math.max(0L, latestBlock - Math.max(1L, maxCatchupBlocks) + 1));

        log.info("MensaPaymentListener starting: latestBlock={}, requestedStart={}, safeStart={}",
                latestBlock, requestedStart, safeStart);

        contract.servicePaymentEventFlowable(
                        new DefaultBlockParameterNumber(safeStart),
                        DefaultBlockParameterName.LATEST
                )
                .subscribe(event -> {
                    String eventId = event.log.getTransactionHash() + "-" + event.log.getLogIndex();
                    Long orderId = event.orderId.longValue();
                    String txHash = event.log.getTransactionHash();

                    retryService.executeWithRetry(
                            eventId,
                            orderId,
                            txHash,
                            () -> processor.processServicePayment(event)
                    );
                }, error -> log.error("ServicePayment event stream failed", error));
    }

    private long fetchLatestBlock(Web3j web3j) {
        try {
            return web3j.ethBlockNumber().send().getBlockNumber().longValue();
        } catch (Exception e) {
            log.warn("Could not fetch latest block, fallback to block 0", e);
            return 0L;
        }
    }
}
