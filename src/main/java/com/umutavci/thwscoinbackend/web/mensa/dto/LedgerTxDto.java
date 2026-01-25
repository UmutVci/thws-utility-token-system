package com.umutavci.thwscoinbackend.web.mensa.dto;

import com.umutavci.thwscoinbackend.infrastructure.jpa.transaction.LedgerTransactionEntity;
import com.umutavci.thwscoinbackend.infrastructure.jpa.transaction.LedgerTxStatus;
import com.umutavci.thwscoinbackend.infrastructure.jpa.transaction.LedgerTxType;

import java.time.Instant;

public record LedgerTxDto(
        Long id,
        LedgerTxType type,
        LedgerTxStatus status,
        Long amountCents,
        String txHash,
        String externalRef,
        Long mensaOrderId,
        Instant createdAt
) {
    public static LedgerTxDto from(LedgerTransactionEntity e) {
        return new LedgerTxDto(
                e.getId(),
                e.getType(),
                e.getStatus(),
                e.getAmountCents(),
                e.getTxHash(),
                e.getExternalRef(),
                e.getMensaOrderId(),
                e.getCreatedAt()
        );
    }
}

