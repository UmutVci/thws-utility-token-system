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
        return getOrCreate().getLastProcessedBlock();
    }

    @Override
    public void updateLastProcessedBlock(long block) {
        EventStateEntity e = getOrCreate();
        e.setLastProcessedBlock(block);
        repo.save(e);
    }

    private EventStateEntity getOrCreate() {
        return repo.findById(1).orElseGet(() -> {
            EventStateEntity e = new EventStateEntity();
            e.setId(1);
            e.setLastProcessedBlock(0L);
            return repo.save(e);
        });
    }
}
