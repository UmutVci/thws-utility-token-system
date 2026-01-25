package com.umutavci.thwscoinbackend.application.blockchain;

import com.umutavci.thwscoinbackend.application.event.EventProcessor;
import com.umutavci.thwscoinbackend.infrastructure.blockchain.PaymentManager;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.web3j.abi.EventEncoder;
import org.web3j.abi.EventValues;
import org.web3j.abi.TypeReference;
import org.web3j.abi.datatypes.Address;
import org.web3j.abi.datatypes.Event;
import org.web3j.abi.datatypes.generated.Uint256;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.methods.request.EthFilter;
import org.web3j.protocol.core.methods.response.Log;
import org.web3j.tx.Contract;

import java.math.BigInteger;
import java.util.List;

// TODO : AFTER CONNECTION WITH BLOCKCHAIN
/*
@Service
@RequiredArgsConstructor
public class BlockchainListener {

    private final Web3j web3j;
    private final EventProcessor eventProcessor;

    @Value("${blockchain.contract.payment-manager}")
    private String paymentManagerAddress;

    @PostConstruct
    public void start() {
        subscribeToServicePaymentEvents();
    }

    private void subscribeToServicePaymentEvents() {

        Event event = new Event("ServicePayment",
                List.of(
                        new TypeReference<Uint256>(true) {},   // orderId (indexed)
                        new TypeReference<Address>(true) {},   // payer
                        new TypeReference<Uint256>() {}         // amount
                )
        );

        EthFilter filter = new EthFilter(
                DefaultBlockParameterName.LATEST,
                DefaultBlockParameterName.LATEST,
                paymentManagerAddress
        );

        filter.addSingleTopic(EventEncoder.encode(event));

        web3j.ethLogFlowable(filter).subscribe(
                log -> {
                    try {
                        handleLog(event, log);
                    } catch (Exception e) {
                        System.err.println(" Event parse error: " + e.getMessage());
                    }
                },
                error -> System.err.println(" Blockchain subscription error: " + error.getMessage())
        );

        System.out.println(" BlockchainListener started for " + paymentManagerAddress);
    }

    private void handleLog(Event event, Log log) {

        EventValues values = Contract.staticExtractEventParameters(event, log);

        BigInteger orderId = (BigInteger) values.getIndexedValues().get(0).getValue();
        String payer = (String) values.getIndexedValues().get(1).getValue();
        BigInteger amount = (BigInteger) values.getNonIndexedValues().get(0).getValue();

        String txHash = log.getTransactionHash();

        PaymentManager.ServicePaymentEventResponse response =
                new PaymentManager.ServicePaymentEventResponse();

        // Web3j standard
        response.log = log;

        response.orderId = orderId;
        response.payer = payer;
        response.amount = amount;

        // response.transactionHash = txHash;

        eventProcessor.processServicePayment(response);

        System.out.println("Payment event received | orderId=" + orderId + " payer=" + payer + " amount=" + amount + " tx=" + txHash);
    }

}
 */

