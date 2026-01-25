package com.umutavci.thwscoinbackend.web.mensa.controller;

import com.umutavci.thwscoinbackend.application.transaction.LedgerService;
import com.umutavci.thwscoinbackend.infrastructure.config.CurrentUserProvider;
import com.umutavci.thwscoinbackend.web.mensa.dto.LedgerTxDto;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/student/ledger")
@RequiredArgsConstructor
@PreAuthorize("hasRole('STUDENT')")
public class StudentLedgerController {

    private final LedgerService ledgerService;
    private final CurrentUserProvider currentUserProvider;

    @GetMapping("/transactions")
    public List<LedgerTxDto> myTransactions() {

        Long studentId = currentUserProvider.getCurrentUserId();

        return ledgerService.getStudentTransactions(studentId)
                .stream()
                .map(LedgerTxDto::from)
                .toList();
    }

    @GetMapping("/balance")
    public Map<String, Object> myBalance() {

        Long studentId = currentUserProvider.getCurrentUserId();
        Long cents = ledgerService.getBalance(studentId);

        return Map.of(
                "balanceCents", cents,
                "currency", "EUR"
        );
    }
}

