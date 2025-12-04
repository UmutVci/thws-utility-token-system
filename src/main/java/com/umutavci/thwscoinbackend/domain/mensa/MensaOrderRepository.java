package com.umutavci.thwscoinbackend.domain.mensa;

import java.util.List;
import java.util.Optional;

public interface MensaOrderRepository {

    MensaOrder save(MensaOrder order);

    Optional<MensaOrder> findById(Long id);

    List<MensaOrder> findUnpaidOrders();
}
