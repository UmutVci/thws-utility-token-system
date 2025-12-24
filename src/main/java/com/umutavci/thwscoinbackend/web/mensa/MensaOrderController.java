package com.umutavci.thwscoinbackend.web.mensa;

import com.umutavci.thwscoinbackend.application.mensa.MensaOrderUseCases;
import com.umutavci.thwscoinbackend.domain.mensa.MensaOrder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/mensa")
public class MensaOrderController {

    private final MensaOrderUseCases useCases;

    public MensaOrderController(MensaOrderUseCases useCases) {
        this.useCases = useCases;
    }

    @PostMapping("/order")
    public MensaOrderDto createOrder(@RequestBody CreateMensaOrderRequest req) {
        var order = useCases.createOrder(req.amount());
        return MensaOrderDto.fromDomain(order);
    }

    @GetMapping("/order/{id}")
    public MensaOrderDto getOrder(@PathVariable Long id) {
        return MensaOrderDto.fromDomain(
                useCases.getOrder(id)
        );
    }

    // @Profile("internal") / @PreAuthorize("ADMIN")
    @PostMapping("/order/{id}/paid")
    public void markPaid(
            @PathVariable Long id,
            @RequestParam String txHash
    ) {
        useCases.markOrderPaid(id, txHash);
    }
}
