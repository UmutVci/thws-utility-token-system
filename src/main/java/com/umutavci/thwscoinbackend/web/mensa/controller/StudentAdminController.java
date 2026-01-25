package com.umutavci.thwscoinbackend.web.mensa.controller;

import com.umutavci.thwscoinbackend.application.user.StudentService;
import com.umutavci.thwscoinbackend.web.mensa.dto.StudentRegisterRequest;
import com.umutavci.thwscoinbackend.web.mensa.dto.StudentResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/admin/students")
@RequiredArgsConstructor
public class StudentAdminController {

    private final StudentService studentService;

    @PostMapping
    public ResponseEntity<StudentResponse> createStudent(
            @RequestBody StudentRegisterRequest request) {

        StudentResponse res = studentService.createStudent(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(res);
    }
}

