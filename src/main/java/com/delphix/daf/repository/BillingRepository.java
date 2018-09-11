package com.delphix.daf.repository;

import com.delphix.daf.model.Billing;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BillingRepository extends JpaRepository<Billing, Long> {
  Page<Billing> findByPatientId(Long patientId, Pageable pageable);
}
