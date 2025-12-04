package com.umutavci.thwscoinbackend.infrastructure.jpa;

import com.umutavci.thwscoinbackend.domain.mensa.MensaOrder;
import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;


@Entity
@Table(name = "mensa_order")
@Data
public class MensaOrderEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Instant createdAt;

    private Integer amount;

    private boolean paid;

    private String txHash;

    public static MensaOrderEntity fromDomain(MensaOrder d) {
        MensaOrderEntity e = new MensaOrderEntity();
        e.id = d.getId();
        e.createdAt = d.getCreatedAt();
        e.amount = d.getAmount();
        e.paid = d.isPaid();
        e.txHash = d.getTxHash();
        return e;
    }

    public MensaOrder toDomain() {
        return new MensaOrder(
                id,
                createdAt,
                amount,
                paid,
                txHash
        );
    }
}