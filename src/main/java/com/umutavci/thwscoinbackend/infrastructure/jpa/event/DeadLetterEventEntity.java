package com.umutavci.thwscoinbackend.infrastructure.jpa.event;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "event_dlq")
@Data
public class DeadLetterEventEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long dlqId;

    @Column(nullable = false)
    private String eventId;

    @Column(nullable = false)
    private Long orderId;

    @Column(nullable = false)
    private String txHash;

    @Lob
    @Column(nullable = false)
    private String payload;

    @Column(nullable = false)
    private int retryCount;

    @Column
    private String errorMessage;

    @Column
    private LocalDateTime lastRetryAt;

    @Column
    private LocalDateTime createdAt = LocalDateTime.now();

}

