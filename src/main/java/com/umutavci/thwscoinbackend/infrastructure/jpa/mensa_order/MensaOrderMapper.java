package com.umutavci.thwscoinbackend.infrastructure.jpa.mensa_order;

import com.umutavci.thwscoinbackend.domain.mensa.MensaOrder;
import org.springframework.stereotype.Component;

@Component
public class MensaOrderMapper {

    public static MensaOrderEntity toEntity(MensaOrder domain) {
        MensaOrderEntity e = new MensaOrderEntity();
        e.setId(domain.getId());
        e.setCreatedAt(domain.getCreatedAt());
        e.setAmount(domain.getAmount());
        e.setPaid(domain.isPaid());
        e.setTxHash(domain.getTxHash());
        e.setStudentUserId(domain.getStudentUserId());
        return e;
    }

    public static MensaOrder toDomain(MensaOrderEntity entity) {
        return new MensaOrder(
                entity.getId(),
                entity.getCreatedAt(),
                entity.getAmount(),
                entity.isPaid(),
                entity.getTxHash(),
                entity.getStudentUserId()
        );
    }
}
