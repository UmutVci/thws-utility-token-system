package com.umutavci.thwscoinbackend.web.mensa.dto;

import java.time.Instant;

public record StudentTransactionRequest(
        String knummer,
        String title,
        String subtitle,
        Double amount,
        Boolean isExpense,
        String txHash,
        Instant createdAt
) {
}
