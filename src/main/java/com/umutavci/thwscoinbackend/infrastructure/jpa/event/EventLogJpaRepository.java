package com.umutavci.thwscoinbackend.infrastructure.jpa.event;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EventLogJpaRepository extends JpaRepository<EventLogEntity, String> {
}
