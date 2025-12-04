package com.umutavci.thwscoinbackend.application.mensa;

import com.umutavci.thwscoinbackend.domain.mensa.MensaOrder;
import com.umutavci.thwscoinbackend.domain.mensa.MensaOrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MensaOrderUseCases {

        private final MensaOrderRepository repo;

        public MensaOrder createOrder(Integer amount) {
            MensaOrder order = new MensaOrder(amount);
            return repo.save(order);
        }

        public void markOrderPaid(Long id, String txHash) {
            MensaOrder order = repo.findById(id)
                    .orElseThrow(() -> new IllegalArgumentException("Order not found"));
            order.markPaid(txHash);
            repo.save(order);
        }
}
