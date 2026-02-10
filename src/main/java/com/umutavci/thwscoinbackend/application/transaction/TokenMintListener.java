package com.umutavci.thwscoinbackend.application.transaction;

import com.umutavci.thwscoinbackend.domain.event.EventLog;
import com.umutavci.thwscoinbackend.domain.event.EventLogRepository;
import com.umutavci.thwscoinbackend.infrastructure.jpa.user.StudentProfileJpaRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.DefaultBlockParameterNumber;
import org.web3j.protocol.core.methods.request.EthFilter;
import org.web3j.protocol.core.methods.response.Log;

import java.math.BigInteger;

@Service
@Slf4j
@ConditionalOnProperty(
        name = "blockchain.token-listener.enabled",
        havingValue = "true"
)
public class TokenMintListener {

    private static final String TRANSFER_TOPIC =
            "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a7ca3b7b7b";
    private static final String ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

    public TokenMintListener(
            Web3j web3j,
            LedgerService ledgerService,
            EventLogRepository eventLogRepo,
            StudentProfileJpaRepository studentProfileRepo,
            @Value("${blockchain.token-address}") String tokenAddress,
            @Value("${blockchain.token-decimals:2}") int tokenDecimals,
            @Value("${blockchain.token-listener.max-catchup-blocks:1}") long maxCatchupBlocks
    ) {
        long latestBlock = fetchLatestBlock(web3j);
        long safeStart = Math.max(0L, latestBlock - Math.max(1L, maxCatchupBlocks) + 1);

        EthFilter filter = new EthFilter(
                new DefaultBlockParameterNumber(safeStart),
                DefaultBlockParameterName.LATEST,
                tokenAddress
        );
        filter.addSingleTopic(TRANSFER_TOPIC);

        log.info("TokenMintListener starting: token={}, latestBlock={}, safeStart={}",
                tokenAddress, latestBlock, safeStart);

        web3j.ethLogFlowable(filter).subscribe(
                logItem -> handleTransferLog(
                        logItem,
                        tokenDecimals,
                        ledgerService,
                        eventLogRepo,
                        studentProfileRepo
                ),
                error -> log.error("Token mint stream failed", error)
        );
    }

    private void handleTransferLog(
            Log logItem,
            int tokenDecimals,
            LedgerService ledgerService,
            EventLogRepository eventLogRepo,
            StudentProfileJpaRepository studentProfileRepo
    ) {
        if (logItem.getTopics() == null || logItem.getTopics().size() < 3) return;

        String from = topicToAddress(logItem.getTopics().get(1));
        if (!ZERO_ADDRESS.equalsIgnoreCase(from)) {
            return;
        }

        String to = topicToAddress(logItem.getTopics().get(2));
        String eventId = "mint-" + logItem.getTransactionHash() + "-" + logItem.getLogIndexRaw();
        if (eventLogRepo.exists(eventId)) {
            return;
        }

        BigInteger rawAmount = decodeUint256(logItem.getData());
        long cents = toCents(rawAmount, tokenDecimals);
        if (cents <= 0) {
            eventLogRepo.save(new EventLog(
                    eventId,
                    logItem.getBlockNumber().longValue(),
                    logItem.getTransactionHash(),
                    logItem.getLogIndex().intValue()
            ));
            return;
        }

        studentProfileRepo.findByWalletAddressIgnoreCase(to).ifPresent(profile -> {
            ledgerService.recordTopUpConfirmedOnChain(
                    profile.getUserId(),
                    cents,
                    logItem.getTransactionHash(),
                    "mint:" + to
            );
        });

        eventLogRepo.save(new EventLog(
                eventId,
                logItem.getBlockNumber().longValue(),
                logItem.getTransactionHash(),
                logItem.getLogIndex().intValue()
        ));
    }

    private String topicToAddress(String topic) {
        if (topic == null) return ZERO_ADDRESS;
        String clean = topic.startsWith("0x") ? topic.substring(2) : topic;
        if (clean.length() < 40) return ZERO_ADDRESS;
        return "0x" + clean.substring(clean.length() - 40).toLowerCase();
    }

    private BigInteger decodeUint256(String data) {
        if (data == null) return BigInteger.ZERO;
        String clean = data.startsWith("0x") ? data.substring(2) : data;
        if (clean.isBlank()) return BigInteger.ZERO;
        return new BigInteger(clean, 16);
    }

    private long toCents(BigInteger rawAmount, int tokenDecimals) {
        if (rawAmount.signum() <= 0) return 0L;

        BigInteger hundred = BigInteger.valueOf(100L);
        BigInteger amountCents;
        if (tokenDecimals >= 2) {
            amountCents = rawAmount.divide(BigInteger.TEN.pow(tokenDecimals - 2));
        } else {
            amountCents = rawAmount.multiply(BigInteger.TEN.pow(2 - tokenDecimals));
        }
        return amountCents.min(BigInteger.valueOf(Long.MAX_VALUE)).longValue();
    }

    private long fetchLatestBlock(Web3j web3j) {
        try {
            return web3j.ethBlockNumber().send().getBlockNumber().longValue();
        } catch (Exception e) {
            log.warn("Could not fetch latest block for token listener, fallback to block 0", e);
            return 0L;
        }
    }
}
