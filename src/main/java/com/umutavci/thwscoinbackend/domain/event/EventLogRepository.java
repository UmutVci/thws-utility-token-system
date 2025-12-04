package com.umutavci.thwscoinbackend.domain.event;

public interface EventLogRepository {
    boolean exists(String eventId);
    void save(EventLog log);
}
