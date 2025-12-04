package com.umutavci.thwscoinbackend.infrastructure.jpa.event;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "event_logs")
@Data
@NoArgsConstructor
public class EventLogEntity {

    @Id
    @Column(name = "event_id", nullable = false, length = 100)
    private String eventId;

    @Column(name = "block_number", nullable = false)
    private Long blockNumber;

    @Column(name = "tx_hash", nullable = false, length = 100)
    private String txHash;

    @Column(name = "log_index", nullable = false)
    private Integer logIndex;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public EventLogEntity(String eventId, long blockNumber, String txHash, int logIndex) {
        this.eventId = eventId;
        this.blockNumber = blockNumber;
        this.txHash = txHash;
        this.logIndex = logIndex;
    }
}