package com.umutavci.thwscoinbackend.infrastructure.jpa.mensa_order;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MensaOrderJpaRepository extends JpaRepository<MensaOrderEntity, Long> {
    List<MensaOrderEntity> findByPaidFalse();
}
