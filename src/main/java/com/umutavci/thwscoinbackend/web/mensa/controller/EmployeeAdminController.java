package com.umutavci.thwscoinbackend.web.mensa.controller;

import com.umutavci.thwscoinbackend.application.user.EmployeeService;
import com.umutavci.thwscoinbackend.web.mensa.dto.EmployeeCreateRequest;
import com.umutavci.thwscoinbackend.web.mensa.dto.EmployeeResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/admin/employees")
@RequiredArgsConstructor
@PreAuthorize("hasRole('EMPLOYEE')")
public class EmployeeAdminController {

    private final EmployeeService employeeService;

    @PostMapping
    public ResponseEntity<EmployeeResponse> createEmployee(
            @RequestBody EmployeeCreateRequest request) {

        EmployeeResponse res = employeeService.createEmployee(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(res);
    }
}

