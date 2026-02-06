package com.umutavci.thwscoinbackend.web.mensa.controller;

import com.umutavci.thwscoinbackend.application.mensa.MensaOrderUseCases;
import com.umutavci.thwscoinbackend.infrastructure.config.CurrentUserProvider;
import com.umutavci.thwscoinbackend.application.mensa.MensaPaymentSignatureService;
import com.umutavci.thwscoinbackend.web.mensa.dto.CreateMensaOrderRequest;
import com.umutavci.thwscoinbackend.web.mensa.dto.MensaOrderDto;
import com.umutavci.thwscoinbackend.web.mensa.dto.PaymentSignatureRequest;
import com.umutavci.thwscoinbackend.web.mensa.dto.PaymentSignatureResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/mensa")
public class MensaOrderController {

    private final MensaOrderUseCases useCases;
    private final CurrentUserProvider currentUserProvider;
    private final MensaPaymentSignatureService signatureService;


    @PostMapping("/order")
    public ResponseEntity<MensaOrderDto> createOrder(
            @RequestBody CreateMensaOrderRequest req) {

        var order = useCases.createOrder(req.amount(), currentUserProvider.getCurrentUserId());
        var dto = MensaOrderDto.fromDomain(order);

        URI location = URI.create("/api/mensa/order/" + order.getId());

        return ResponseEntity
                .created(location)   // 201 Created + Location header
                .body(dto);
    }

    @GetMapping("/order/{id}")
    public ResponseEntity<MensaOrderDto> getOrder(@PathVariable Long id) {
        var order = useCases.getOrder(id, currentUserProvider.getCurrentUserId());
        return ResponseEntity.ok(MensaOrderDto.fromDomain(order));
    }

    @PostMapping("/payment-signature")
    public ResponseEntity<PaymentSignatureResponse> createPaymentSignature(
            @RequestBody PaymentSignatureRequest req
    ) throws Exception {
        // For now: sign what backend receives. You can tie this to real order checks later.
        var sig = signatureService.signMensaPayment(req);
        return ResponseEntity.ok(sig);
    }

    // TODO : @Profile("internal") / @PreAuthorize("ADMIN")
    @PostMapping("/order/{id}/paid")
    public ResponseEntity<Void> markPaid(
            @PathVariable Long id,
            @RequestParam(required = false) String txHash
            // TODO : it have to be required just for testing it should stay like that
    ) {
        /*
        TODO : if (txHash == null || txHash.isBlank()) { throw new InvalidPaymentException("txHash is mandatory when marking order as paid");}
         */
        useCases.markOrderPaid(id, txHash);
        return ResponseEntity.noContent().build(); // 204
    }
}
