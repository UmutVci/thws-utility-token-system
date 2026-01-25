package com.umutavci.thwscoinbackend.web.mensa.dto;

import java.time.LocalDate;

public record StudentResponse(
        Long userId,
        String knummer,
        String firstName,
        String lastName,
        String matrikelnummer,
        String department,
        Integer semester,
        String email,
        String campus,
        LocalDate validUntil
) {}

