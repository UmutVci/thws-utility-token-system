package com.umutavci.thwscoinbackend.application.mensa;

import com.umutavci.thwscoinbackend.domain.exceptions.MensaOrderNotFoundException;
import com.umutavci.thwscoinbackend.domain.mensa.MensaOrder;
import com.umutavci.thwscoinbackend.domain.mensa.MensaOrderRepository;
import com.umutavci.thwscoinbackend.infrastructure.config.CurrentUserProvider;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MensaOrderUseCases {

        private final MensaOrderRepository repo;

        public MensaOrder createOrder(Integer amount, Long userId) {
            MensaOrder order = new MensaOrder(amount, userId);
            return repo.save(order);
        }

        public MensaOrder getOrder(Long id, Long userId){
            return repo.findById(id)
                    .orElseThrow(() -> new MensaOrderNotFoundException(id));
        }

        public void markOrderPaid(Long id, String txHash) {
            MensaOrder order = repo.findById(id)
                    .orElseThrow(() -> new MensaOrderNotFoundException(id));
            order.markPaid(txHash);
            repo.save(order);
        }
}
