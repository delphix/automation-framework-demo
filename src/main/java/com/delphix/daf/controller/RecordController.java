package com.delphix.daf.controller;

import java.util.Optional;
import com.delphix.daf.exception.ResourceNotFoundException;
import com.delphix.daf.model.Record;
import com.delphix.daf.repository.RecordRepository;
import com.delphix.daf.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import javax.validation.Valid;

@RestController
public class RecordController {

    @Autowired
    private RecordRepository recordRepository;

    @Autowired
    private PatientRepository patientRepository;

    @GetMapping("/patients/{patientId}/records")
    public Page<Record> getAllRecordsByPatientId(@PathVariable (value = "patientId") Long patientId, Pageable pageable) {
       return recordRepository.findByPatientId(patientId, pageable);
    }

    @PostMapping("/patients/{patientId}/records")
     public Record createRecord(@PathVariable (value = "patientId") Long patientId, @Valid @RequestBody Record record) {
         return patientRepository.findById(patientId).map(patient -> {
             record.setPatient(patient);
             return recordRepository.save(record);
         }).orElseThrow(() -> new ResourceNotFoundException("PatientId " + patientId + " not found"));
     }


/*
    @GetMapping("/records/{recordId}")
    public Optional<Record> getRecord(@PathVariable Long recordId) {
        return recordRepository.findById(recordId);
    }

    @PatientMapping("/records")
    public Record createRecord(@Valid @RequestBody Record record) {
        return recordRepository.save(record);
    }

    @PutMapping("/records/{recordId}")
    public Record updateRecord(@PathVariable Long recordId, @Valid @RequestBody Record recordRequest) {
        return recordRepository.findById(recordId)
                .map(record -> {


                    record.setFirstname(recordRequest.getFirstname());


                }).orElseThrow(() -> new ResourceNotFoundException("Record not found with id " + recordId));
    }


    @DeleteMapping("/records/{recordId}")
    public ResponseEntity<?> deleteRecord(@PathVariable Long recordId) {
        return recordRepository.findById(recordId)
                .map(record -> {
                    recordRepository.delete(record);
                    return ResponseEntity.ok().build();
                }).orElseThrow(() -> new ResourceNotFoundException("Record not found with id " + recordId));
    }
    */
}
