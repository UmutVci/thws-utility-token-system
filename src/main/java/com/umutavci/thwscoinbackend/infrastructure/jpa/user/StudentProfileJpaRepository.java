package com.umutavci.thwscoinbackend.infrastructure.jpa.user;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface StudentProfileJpaRepository extends JpaRepository<StudentProfileEntity, Long> {
    boolean existsByMatrikelnummer(String matrikelnummer);
    boolean existsByKnummer(String knummer);
    Optional<StudentProfileEntity> findByKnummer(String knummer);

    @Query("select s from StudentProfileEntity s where lower(s.walletAddress) = lower(:walletAddress)")
    Optional<StudentProfileEntity> findByWalletAddressIgnoreCase(String walletAddress);
}
