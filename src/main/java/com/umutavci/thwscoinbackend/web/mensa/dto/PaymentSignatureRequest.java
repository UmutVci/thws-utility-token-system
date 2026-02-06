package com.umutavci.thwscoinbackend.web.mensa.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record PaymentSignatureRequest(
        @NotNull Integer amount,
        @NotNull Long orderId,
        @NotBlank String payer,
        Integer expirySeconds
) {}
