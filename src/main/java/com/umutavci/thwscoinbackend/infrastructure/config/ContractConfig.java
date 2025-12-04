package com.umutavci.thwscoinbackend.infrastructure.config;

import com.umutavci.thwscoinbackend.infrastructure.blockchain.PaymentManager;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.tx.gas.StaticGasProvider;

import java.math.BigInteger;

@Configuration
@ConditionalOnProperty(name = "blockchain.enabled", havingValue = "true")
public class ContractConfig {

    @Value("${blockchain.payment-manager-address}")
    private String contractAddress;

    @Bean
    public PaymentManager paymentManager(Web3j web3j, Credentials credentials) {

        return PaymentManager.load(
                contractAddress,
                web3j,
                credentials,
                new StaticGasProvider(BigInteger.ZERO, BigInteger.valueOf(3_000_000))
        );
    }
}

