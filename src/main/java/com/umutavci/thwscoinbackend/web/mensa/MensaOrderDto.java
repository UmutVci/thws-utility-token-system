package com.umutavci.thwscoinbackend.web.mensa;

import com.umutavci.thwscoinbackend.domain.mensa.MensaOrder;

public record MensaOrderDto(Long id, Integer amount, boolean paid, String txHash) {
    public static MensaOrderDto fromDomain(MensaOrder o) {
        return new MensaOrderDto(o.getId(), o.getAmount(), o.isPaid(), o.getTxHash());
    }
}
