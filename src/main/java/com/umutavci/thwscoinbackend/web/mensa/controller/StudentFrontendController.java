package com.umutavci.thwscoinbackend.web.mensa.controller;

import com.umutavci.thwscoinbackend.infrastructure.jpa.transaction.LedgerTransactionEntity;
import com.umutavci.thwscoinbackend.infrastructure.jpa.transaction.LedgerTransactionRepository;
import com.umutavci.thwscoinbackend.infrastructure.jpa.transaction.LedgerTxStatus;
import com.umutavci.thwscoinbackend.infrastructure.jpa.transaction.LedgerTxType;
import com.umutavci.thwscoinbackend.infrastructure.jpa.user.StudentProfileEntity;
import com.umutavci.thwscoinbackend.infrastructure.jpa.user.StudentProfileJpaRepository;
import com.umutavci.thwscoinbackend.web.mensa.dto.StudentResponse;
import com.umutavci.thwscoinbackend.web.mensa.dto.StudentTransactionRequest;
import com.umutavci.thwscoinbackend.web.mensa.dto.StudentTransactionResponse;
import com.umutavci.thwscoinbackend.web.mensa.dto.StudentWalletBindRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;

@RestController
@RequestMapping("/api/students")
@RequiredArgsConstructor
public class StudentFrontendController {

    private final StudentProfileJpaRepository studentProfileRepo;
    private final LedgerTransactionRepository ledgerRepo;

    @GetMapping("/profile")
    public StudentResponse profile(@RequestParam String knummer) {
        StudentProfileEntity profile = studentProfileRepo.findByKnummer(knummer)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found"));

        return new StudentResponse(
                profile.getUserId(),
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

    @GetMapping("/transactions")
    public List<StudentTransactionResponse> transactions(@RequestParam String knummer) {
        StudentProfileEntity profile = studentProfileRepo.findByKnummer(knummer)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found"));

        return ledgerRepo.findByStudentUserIdOrderByCreatedAtDesc(profile.getUserId())
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @PostMapping("/transactions")
    @ResponseStatus(HttpStatus.CREATED)
    public void createTransaction(@RequestBody StudentTransactionRequest req) {
        if (req.knummer() == null || req.knummer().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "knummer is required");
        }
        if (req.title() == null || req.title().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "title is required");
        }
        if (req.amount() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "amount is required");
        }

        StudentProfileEntity profile = studentProfileRepo.findByKnummer(req.knummer())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found"));

        boolean isExpense = Boolean.TRUE.equals(req.isExpense());
        long amountCents = Math.round(Math.abs(req.amount()) * 100.0d);
        if (isExpense) amountCents = -amountCents;

        LedgerTransactionEntity tx = new LedgerTransactionEntity();
        tx.setStudentUserId(profile.getUserId());
        tx.setType(isExpense ? LedgerTxType.SPEND : LedgerTxType.TOP_UP);
        tx.setStatus(LedgerTxStatus.CONFIRMED);
        tx.setAmountCents(amountCents);
        tx.setTxHash(req.txHash());
        tx.setCreatedAt(req.createdAt() != null ? req.createdAt() : Instant.now());

        String subtitle = req.subtitle();
        if (subtitle != null && !subtitle.isBlank()) {
            tx.setExternalRef(subtitle);
        }

        ledgerRepo.save(tx);
    }

    @PostMapping("/wallet")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void bindWallet(@RequestBody StudentWalletBindRequest req) {
        if (req.knummer() == null || req.knummer().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "knummer is required");
        }
        if (req.walletAddress() == null || req.walletAddress().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "walletAddress is required");
        }

        final String normalizedWallet = req.walletAddress().trim().toLowerCase();
        if (!normalizedWallet.matches("^0x[a-f0-9]{40}$")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "walletAddress is invalid");
        }

        StudentProfileEntity owner = studentProfileRepo.findByWalletAddressIgnoreCase(normalizedWallet)
                .orElse(null);
        if (owner != null && !owner.getKnummer().equalsIgnoreCase(req.knummer().trim())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "walletAddress already linked");
        }

        StudentProfileEntity profile = studentProfileRepo.findByKnummer(req.knummer().trim())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found"));

        profile.setWalletAddress(normalizedWallet);
        studentProfileRepo.save(profile);
    }

    private StudentTransactionResponse toResponse(LedgerTransactionEntity e) {
        boolean isExpense = e.getAmountCents() < 0;
        double majorAmount = Math.abs(e.getAmountCents()) / 100.0d;

        String subtitle = e.getExternalRef();
        if ((subtitle == null || subtitle.isBlank()) && e.getTxHash() != null && !e.getTxHash().isBlank()) {
            subtitle = e.getTxHash();
        }

        String title = switch (e.getType()) {
            case TOP_UP -> "Einzahlung";
            case SPEND -> "Ausgabe";
            case ADJUSTMENT -> "Anpassung";
        };

        return new StudentTransactionResponse(
                title,
                subtitle,
                majorAmount,
                isExpense,
                e.getTxHash(),
                e.getCreatedAt()
        );
    }
}
