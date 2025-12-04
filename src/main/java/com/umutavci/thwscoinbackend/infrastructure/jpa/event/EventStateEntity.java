package com.umutavci.thwscoinbackend.infrastructure.jpa.event;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Entity
@Table(name = "event_state")
public class EventStateEntity {

    @Id
    private Integer id;

    @Column(name = "last_processed_block", nullable = false)
    private Long lastProcessedBlock;

}
