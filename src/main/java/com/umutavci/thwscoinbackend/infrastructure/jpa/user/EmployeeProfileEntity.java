package com.umutavci.thwscoinbackend.infrastructure.jpa.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "employee_profile", indexes = {
        @Index(name = "idx_employee_username", columnList = "username", unique = true)
})
@Getter
@Setter
@NoArgsConstructor
public class EmployeeProfileEntity {

    @Id
    private Long userId;

    @OneToOne(optional = false)
    @MapsId
    @JoinColumn(name = "user_id")
    private UserEntity user;

    @Column(nullable = false, unique = true, length = 120)
    private String username;
}

