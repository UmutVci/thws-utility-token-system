package com.umutavci.thwscoinbackend.web.mensa.dto;

import java.time.LocalDate;

public record StudentRegisterRequest(
        String knummer,
        String password,
        String firstName,
        String lastName,
        String matrikelnummer,
        String department,
        Integer semester,
        String email,
        String phoneNumber,
        String campus,
        LocalDate validUntil
) {}

