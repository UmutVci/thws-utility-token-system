package com.umutavci.thwscoinbackend.application.user;

import com.umutavci.thwscoinbackend.infrastructure.jpa.user.*;
import com.umutavci.thwscoinbackend.web.mensa.dto.EmployeeCreateRequest;
import com.umutavci.thwscoinbackend.web.mensa.dto.EmployeeResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class EmployeeService {

    private final UserJpaRepository userRepo;
    private final EmployeeProfileJpaRepository employeeRepo;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public EmployeeResponse createEmployee(EmployeeCreateRequest req) {

        if (userRepo.existsByUsername(req.username())) {
            throw new IllegalStateException("Username already exists");
        }

        UserEntity user = new UserEntity();
        user.setUsername(req.username());
        user.setPasswordHash(passwordEncoder.encode(req.password()));
        user.setRole(Role.EMPLOYEE);
        userRepo.save(user);

        EmployeeProfileEntity profile = new EmployeeProfileEntity();
        profile.setUser(user);
        profile.setUsername(req.username());
        employeeRepo.save(profile);

        return new EmployeeResponse(user.getId(), user.getUsername());
    }
}

