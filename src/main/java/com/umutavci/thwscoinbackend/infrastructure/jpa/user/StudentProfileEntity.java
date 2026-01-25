package com.umutavci.thwscoinbackend.infrastructure.jpa.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Entity
@Table(name = "student_profile", indexes = {
        @Index(name = "idx_student_matrikel", columnList = "matrikelnummer", unique = true),
        @Index(name = "idx_student_knr", columnList = "knummer", unique = true)
})
@Getter
@Setter
@NoArgsConstructor
public class StudentProfileEntity {

    @Id
    private Long userId;

    @OneToOne(optional = false)
    @MapsId
    @JoinColumn(name = "user_id")
    private UserEntity user;

    @Column(nullable = false, unique = true, length = 40)
    private String knummer;

    @Column(nullable = false, length = 80)
    private String firstName;

    @Column(nullable = false, length = 80)
    private String lastName;

    @Column(nullable = false, unique = true, length = 40)
    private String matrikelnummer;

    @Column(nullable = false, length = 120)
    private String department;

    @Column(nullable = false)
    private Integer semester;

    @Column(nullable = false, length = 120)
    private String email;

    @Column(length = 40)
    private String phoneNumber;

    @Column(length = 80)
    private String campus;

    @Column(name = "valid_until")
    private LocalDate validUntil;
}

