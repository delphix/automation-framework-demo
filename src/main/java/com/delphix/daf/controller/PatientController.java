package com.delphix.daf.controller;

import java.util.Optional;
import com.delphix.daf.exception.ResourceNotFoundException;
import com.delphix.daf.model.Patient;
import com.delphix.daf.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import javax.validation.Valid;

@RestController
public class PatientController {

    @Autowired
    private PatientRepository patientRepository;

    @GetMapping("/patients")
    public Page<Patient> getPatients(Pageable pageable) {
        return patientRepository.findAll(pageable);
    }

    @GetMapping("/patients/{patientId}")
    public Optional<Patient> getPatient(@PathVariable Long patientId) {
        return patientRepository.findById(patientId);
    }

    @PostMapping("/patients")
    public Patient createPatient(@Valid @RequestBody Patient patient) {
        return patientRepository.save(patient);
    }

    @PutMapping("/patients/{patientId}")
    public Patient updatePatient(@PathVariable Long patientId, @Valid @RequestBody Patient patientRequest) {
        return patientRepository.findById(patientId)
                .map(patient -> {
                    patient.setFirstname(patientRequest.getFirstname());
                    patient.setMiddlename(patientRequest.getMiddlename());
                    patient.setLastname(patientRequest.getLastname());
                    patient.setSsn(patientRequest.getSsn());
                    patient.setDob(patientRequest.getDob());
                    patient.setAddress1(patientRequest.getAddress1());
                    patient.setAddress2(patientRequest.getAddress2());
                    patient.setCity(patientRequest.getCity());
                    patient.setState(patientRequest.getState());
                    patient.setZip(patientRequest.getZip());
                    return patientRepository.save(patient);
                }).orElseThrow(() -> new ResourceNotFoundException("Patient not found with id " + patientId));
    }


    @DeleteMapping("/patients/{patientId}")
    public ResponseEntity<?> deletePatient(@PathVariable Long patientId) {
        return patientRepository.findById(patientId)
                .map(patient -> {
                    patientRepository.delete(patient);
                    return ResponseEntity.ok().build();
                }).orElseThrow(() -> new ResourceNotFoundException("Patient not found with id " + patientId));
    }
}
