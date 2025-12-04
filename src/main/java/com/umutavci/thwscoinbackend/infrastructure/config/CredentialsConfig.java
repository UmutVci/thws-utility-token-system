package com.umutavci.thwscoinbackend.infrastructure.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.web3j.crypto.Credentials;

@Configuration
@ConditionalOnProperty(name = "blockchain.enabled", havingValue = "true")
public class CredentialsConfig {

    @Value("${blockchain.private-key}")
    private String privateKey;

    @Bean
    public Credentials credentials() {
        return Credentials.create(privateKey);
    }
}

