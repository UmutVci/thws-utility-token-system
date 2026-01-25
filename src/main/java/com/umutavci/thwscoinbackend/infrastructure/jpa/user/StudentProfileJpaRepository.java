package com.umutavci.thwscoinbackend.infrastructure.jpa.user;

import org.springframework.data.jpa.repository.JpaRepository;

public interface StudentProfileJpaRepository extends JpaRepository<StudentProfileEntity, Long> {
    boolean existsByMatrikelnummer(String matrikelnummer);
    boolean existsByKnummer(String knummer);
}

