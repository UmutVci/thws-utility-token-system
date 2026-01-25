package com.umutavci.thwscoinbackend.infrastructure.jpa.user;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserJpaRepository extends JpaRepository<UserEntity, Long> {
    Optional<UserEntity> findByUsername(String name);
    boolean existsByUsername(String username);
}
