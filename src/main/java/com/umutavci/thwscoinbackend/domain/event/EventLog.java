package com.umutavci.thwscoinbackend.domain.event;

import lombok.Data;

@Data
public class EventLog {

    private final String eventId;
    private final long blockNumber;
    private final String txHash;
    private final int logIndex;

}
