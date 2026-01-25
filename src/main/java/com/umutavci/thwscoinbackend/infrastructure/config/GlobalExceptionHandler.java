package com.umutavci.thwscoinbackend.infrastructure.config;

import com.umutavci.thwscoinbackend.domain.exceptions.MensaOrderNotFoundException;
import com.umutavci.thwscoinbackend.web.mensa.dto.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MensaOrderNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(MensaOrderNotFoundException ex,
                                                        HttpServletRequest request) {

        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(
                        Instant.now(),
                        404,
                        ex.getMessage(),
                        request.getRequestURI()
                ));
    }
}

