package com.umutavci.thwscoinbackend.infrastructure.jpa.event;

import com.umutavci.thwscoinbackend.domain.event.EventStateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class EventStateRepositoryAdapter implements EventStateRepository {

    private final EventStateJpaRepository repo;

    @Override
    public long getLastProcessedBlock() {
        return repo.findById(1L).orElseThrow().getLastProcessedBlock();
    }

    @Override
    public void updateLastProcessedBlock(long block) {
        EventStateEntity e = repo.findById(1L).orElseThrow();
        e.setLastProcessedBlock(block);
        repo.save(e);
    }
}

