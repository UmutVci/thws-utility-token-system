package com.umutavci.thwscoinbackend.domain.exceptions;

public class MensaOrderNotFoundException extends RuntimeException {
    public MensaOrderNotFoundException(Long id) {
        super("Mensa order not found with id=" + id);
    }
}
