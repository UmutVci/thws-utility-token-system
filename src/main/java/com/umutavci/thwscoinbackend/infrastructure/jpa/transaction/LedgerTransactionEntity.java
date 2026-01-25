package com.umutavci.thwscoinbackend.infrastructure.jpa.transaction;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "ledger_transactions", indexes = {
        @Index(name = "idx_ledger_student", columnList = "student_user_id"),
        @Index(name = "idx_ledger_external_ref", columnList = "external_ref"),
        @Index(name = "idx_ledger_tx_hash", columnList = "tx_hash")
})
@Getter
@Setter
@NoArgsConstructor
public class LedgerTransactionEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "student_user_id", nullable = false)
    private Long studentUserId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private LedgerTxType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private LedgerTxStatus status;

    @Column(nullable = false)
    private Long amountCents;

    @Column(nullable = false, length = 3)
    private String currency = "EUR";

    @Column(name = "tx_hash", length = 120)
    private String txHash; // blockchain spend

    @Column(name = "external_ref", length = 120)
    private String externalRef; // sepa, card payment id

    @Column(name = "mensa_order_id")
    private Long mensaOrderId;

    @Column(nullable = false)
    private Instant createdAt = Instant.now();
}
