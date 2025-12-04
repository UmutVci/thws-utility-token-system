package com.umutavci.thwscoinbackend.domain.mensa;

import lombok.Data;

import java.time.Instant;

@Data
public class MensaOrder {

    private Long id;
    private Instant createdAt;
    private Integer amount;
    private boolean paid;
    private String txHash;

    public MensaOrder(Long id, Instant createdAt, Integer amount, boolean paid, String txHash) {
        this.id = id;
        this.createdAt = createdAt;
        this.amount = amount;
        this.paid = paid;
        this.txHash = txHash;
    }

    public MensaOrder(Integer amount) {
        this(null, Instant.now(), amount, false, null);
    }

    public void markPaid(String txHash) {
        this.paid = true;
        this.txHash = txHash;
    }

    // getters
}
