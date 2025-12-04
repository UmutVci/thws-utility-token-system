package com.umutavci.thwscoinbackend.infrastructure.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.http.HttpService;

@Configuration
@ConditionalOnProperty(name = "blockchain.enabled", havingValue = "true", matchIfMissing = true)
public class Web3jConfig {

    @Bean
    public Web3j web3j() {
        return Web3j.build(new HttpService("http://localhost:8545"));
    }
}

