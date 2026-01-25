package com.umutavci.thwscoinbackend.infrastructure.jpa.transaction;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface LedgerTransactionRepository extends JpaRepository<LedgerTransactionEntity, Long> {

    List<LedgerTransactionEntity> findByStudentUserIdOrderByCreatedAtDesc(Long studentUserId);

    @Query("""
        select coalesce(sum(l.amountCents),0)
        from LedgerTransactionEntity l
        where l.studentUserId = :studentId
          and l.status = 'CONFIRMED'
    """)
    Long calculateBalance(@Param("studentId") Long studentId);
}

