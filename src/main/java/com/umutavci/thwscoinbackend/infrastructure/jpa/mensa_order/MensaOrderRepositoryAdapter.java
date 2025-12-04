package com.umutavci.thwscoinbackend.infrastructure.jpa.mensa_order;

import com.umutavci.thwscoinbackend.domain.mensa.MensaOrder;
import com.umutavci.thwscoinbackend.domain.mensa.MensaOrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class MensaOrderRepositoryAdapter implements MensaOrderRepository {
    private final MensaOrderJpaRepository jpaRepo;
    private final MensaOrderMapper mapper;

    @Override
    public MensaOrder save(MensaOrder order) {
        return MensaOrderMapper.toDomain(jpaRepo.save(MensaOrderMapper.toEntity(order)));
    }

    @Override
    public Optional<MensaOrder> findById(Long id) {
        return Optional.of(MensaOrderMapper.toDomain(MensaOrderEntity.fromDomain(findById(id).orElseThrow())));
    }

    @Override
    public List<MensaOrder> findUnpaidOrders() {
        return jpaRepo.findByPaidFalse().stream()
                .map(MensaOrderEntity::toDomain)
                .toList();
    }
}
