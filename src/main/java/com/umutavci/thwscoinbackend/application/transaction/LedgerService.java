package com.umutavci.thwscoinbackend.application.transaction;

import com.umutavci.thwscoinbackend.infrastructure.jpa.transaction.LedgerTransactionEntity;
import com.umutavci.thwscoinbackend.infrastructure.jpa.transaction.LedgerTransactionRepository;
import com.umutavci.thwscoinbackend.infrastructure.jpa.transaction.LedgerTxStatus;
import com.umutavci.thwscoinbackend.infrastructure.jpa.transaction.LedgerTxType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LedgerService {

    private final LedgerTransactionRepository ledgerRepo;

    // for spend
    @Transactional
    public void recordSpend(Long studentId,
                            Long amountCents,
                            Long mensaOrderId,
                            String txHash) {

        LedgerTransactionEntity tx = new LedgerTransactionEntity();
        tx.setStudentUserId(studentId);
        tx.setType(LedgerTxType.SPEND);
        tx.setStatus(LedgerTxStatus.CONFIRMED);
        tx.setAmountCents(-Math.abs(amountCents));
        tx.setTxHash(txHash);
        tx.setMensaOrderId(mensaOrderId);

        ledgerRepo.save(tx);
    }

    // SEPA / Credit card
    @Transactional
    public void recordTopUpPending(Long studentId,
                                   Long amountCents,
                                   String externalRef) {

        LedgerTransactionEntity tx = new LedgerTransactionEntity();
        tx.setStudentUserId(studentId);
        tx.setType(LedgerTxType.TOP_UP);
        tx.setStatus(LedgerTxStatus.PENDING);
        tx.setAmountCents(Math.abs(amountCents));
        tx.setExternalRef(externalRef);

        ledgerRepo.save(tx);
    }

    @Transactional
    public void confirmTopUp(String externalRef) {
        LedgerTransactionEntity tx = ledgerRepo.findAll().stream()
                .filter(t -> externalRef.equals(t.getExternalRef()))
                .findFirst()
                .orElseThrow();

        tx.setStatus(LedgerTxStatus.CONFIRMED);
    }

    public Long getBalance(Long studentId) {
        return ledgerRepo.calculateBalance(studentId);
    }

    public List<LedgerTransactionEntity> getStudentTransactions(Long studentId) {
        return ledgerRepo.findByStudentUserIdOrderByCreatedAtDesc(studentId);
    }
}

