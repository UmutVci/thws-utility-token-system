package com.umutavci.thwscoinbackend.web.mensa.controller;

import com.umutavci.thwscoinbackend.application.mensa.MensaOrderUseCases;
import com.umutavci.thwscoinbackend.infrastructure.jpa.event.DeadLetterEventEntity;
import com.umutavci.thwscoinbackend.infrastructure.jpa.event.DeadLetterEventJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/dlq")
public class DeadLetterController {

    private final DeadLetterEventJpaRepository repo;
    private final MensaOrderUseCases mensaUseCases;

    @PostMapping("/{id}/reprocess")
    public ResponseEntity<?> reprocess(@PathVariable Long id) {

        DeadLetterEventEntity dlq = repo.findById(id).orElseThrow();

        mensaUseCases.markOrderPaid(dlq.getOrderId(), dlq.getTxHash());

        repo.delete(dlq);

        return ResponseEntity.ok("Event reprocessed for order " + dlq.getOrderId());
    }
}
