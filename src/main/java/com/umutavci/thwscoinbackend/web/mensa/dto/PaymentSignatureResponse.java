package com.umutavci.thwscoinbackend.web.mensa.dto;

public record PaymentSignatureResponse(
        Integer amount,
        Long orderId,
        Long expiry,
        Integer v,
        String r,
        String s,
        Long nonce
) {}
