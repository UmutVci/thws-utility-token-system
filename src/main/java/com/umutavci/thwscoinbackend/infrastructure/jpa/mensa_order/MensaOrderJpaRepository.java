package com.umutavci.thwscoinbackend.infrastructure.jpa;

import com.umutavci.thwscoinbackend.domain.mensa.MensaOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MensaOrderJpaRepository extends JpaRepository<MensaOrderEntity, Long> {
    List<MensaOrderEntity> findByPaidFalse();
}
