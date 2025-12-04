package com.umutavci.thwscoinbackend.infrastructure.jpa.event;

import org.springframework.data.jpa.repository.JpaRepository;

public interface DeadLetterEventJpaRepository extends JpaRepository<DeadLetterEventEntity, Long> {}

