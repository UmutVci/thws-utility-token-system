package com.umutavci.thwscoinbackend.infrastructure.jpa.event;

import com.umutavci.thwscoinbackend.domain.event.EventLog;
import com.umutavci.thwscoinbackend.domain.event.EventLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class EventLogRepositoryAdapter implements EventLogRepository {

    private final EventLogJpaRepository repo;

    @Override
    public boolean exists(String eventId) {
        return repo.existsById(Long.valueOf(eventId));
    }

    @Override
    public void save(EventLog log) {
        repo.save(new EventLogEntity(
                log.getEventId(),
                log.getBlockNumber(),
                log.getTxHash(),
                log.getLogIndex()
        ));
    }
}

