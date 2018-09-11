package com.delphix.daf.repository;

import com.delphix.daf.model.Payment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
  Page<Payment> findByPatientId(Long patientId, Pageable pageable);
}
