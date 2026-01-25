package com.umutavci.thwscoinbackend.application.user;

import com.umutavci.thwscoinbackend.infrastructure.jpa.user.*;
import com.umutavci.thwscoinbackend.web.mensa.dto.StudentRegisterRequest;
import com.umutavci.thwscoinbackend.web.mensa.dto.StudentResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class StudentService {

    private final UserJpaRepository userRepo;
    private final StudentProfileJpaRepository studentRepo;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public StudentResponse createStudent(StudentRegisterRequest req) {

        if (userRepo.existsByUsername(req.knummer())) {
            throw new IllegalStateException("Username already exists");
        }
        if (studentRepo.existsByMatrikelnummer(req.matrikelnummer())) {
            throw new IllegalStateException("Matrikelnummer already exists");
        }

        UserEntity user = new UserEntity();
        user.setUsername(req.knummer());
        user.setPasswordHash(passwordEncoder.encode(req.password()));
        user.setRole(Role.STUDENT);
        userRepo.save(user);

        StudentProfileEntity profile = new StudentProfileEntity();
        profile.setUser(user);
        profile.setKnummer(req.knummer());
        profile.setFirstName(req.firstName());
        profile.setLastName(req.lastName());
        profile.setMatrikelnummer(req.matrikelnummer());
        profile.setDepartment(req.department());
        profile.setSemester(req.semester());
        profile.setEmail(req.email());
        profile.setPhoneNumber(req.phoneNumber());
        profile.setCampus(req.campus());
        profile.setValidUntil(req.validUntil());

        studentRepo.save(profile);

        return new StudentResponse(
                user.getId(),
                profile.getKnummer(),
                profile.getFirstName(),
                profile.getLastName(),
                profile.getMatrikelnummer(),
                profile.getDepartment(),
                profile.getSemester(),
                profile.getEmail(),
                profile.getCampus(),
                profile.getValidUntil()
        );
    }
}

