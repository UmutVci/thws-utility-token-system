package com.umutavci.thwscoinbackend.web.mensa.dto;

import java.time.Instant;

public record ErrorResponse(
        Instant timestamp,
        int status,
        String error,
        String path
) {}
