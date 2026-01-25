package com.umutavci.thwscoinbackend.web.mensa.dto;

import jakarta.validation.constraints.NotNull;

public record CreateMensaOrderRequest(@NotNull Integer amount) {}

