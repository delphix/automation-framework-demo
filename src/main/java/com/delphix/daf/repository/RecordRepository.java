package com.delphix.daf.repository;

import com.delphix.daf.model.Record;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RecordRepository extends JpaRepository<Record, Long> {
  Page<Record> findByPatientId(Long patientId, Pageable pageable);
}
