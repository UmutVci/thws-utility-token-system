package com.umutavci.thwscoinbackend.domain.event;

public interface EventStateRepository {
    long getLastProcessedBlock();
    void updateLastProcessedBlock(long block);
}
