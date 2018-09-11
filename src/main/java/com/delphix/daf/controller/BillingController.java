package com.delphix.daf.controller;

import java.util.Optional;
import com.delphix.daf.exception.ResourceNotFoundException;
import com.delphix.daf.model.Billing;
import com.delphix.daf.repository.BillingRepository;
import com.delphix.daf.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import javax.validation.Valid;

@RestController
public class BillingController {

    @Autowired
    private BillingRepository billingRepository;

    @Autowired
    private PatientRepository patientRepository;

    @GetMapping("/patients/{patientId}/billings")
    public Page<Billing> getAllBillingsByPatientId(@PathVariable (value = "patientId") Long patientId, Pageable pageable) {
       return billingRepository.findByPatientId(patientId, pageable);
    }

    @GetMapping("/patients/{patientId}/billings/{billingId}")
    public Optional<Billing> getBilling(@PathVariable (value = "patientId") Long patientId, @PathVariable (value = "billingId") Long billingId) {
        if(!patientRepository.existsById(patientId)) {
            throw new ResourceNotFoundException("PatientId " + patientId + " not found");
        }
        return billingRepository.findById(billingId);
    }

    @PostMapping("/patients/{patientId}/billings")
    public Billing createBilling(@PathVariable (value = "patientId") Long patientId, @Valid @RequestBody Billing billing) {
        return patientRepository.findById(patientId).map(patient -> {
            billing.setPatient(patient);
            return billingRepository.save(billing);
        }).orElseThrow(() -> new ResourceNotFoundException("PatientId " + patientId + " not found"));
    }

    @PutMapping("/patients/{patientId}/billings/{billingId}")
    public Billing updateBilling(@PathVariable (value = "patientId") Long patientId, @PathVariable (value = "billingId") Long billingId, @Valid @RequestBody Billing billingRequest) {
        if(!patientRepository.existsById(patientId)) {
            throw new ResourceNotFoundException("PatientId " + patientId + " not found");
        }
        return billingRepository.findById(billingId).map(billing -> {
            billing.setCcnum(billingRequest.getCcnum());
            billing.setCctype(billingRequest.getCctype());
            billing.setCcexpmonth(billingRequest.getCcexpmonth());
            billing.setCcexpyear(billingRequest.getCcexpyear());
            billing.setAddress1(billingRequest.getAddress1());
            billing.setAddress2(billingRequest.getAddress2());
            billing.setCity(billingRequest.getCity());
            billing.setState(billingRequest.getState());
            billing.setZip(billingRequest.getZip());
            return billingRepository.save(billing);
        }).orElseThrow(() -> new ResourceNotFoundException("BillingId " + billingId + "not found"));
    }

    @DeleteMapping("/patients/{patientId}/billings/{billingId}")
    public ResponseEntity<?> deleteBilling(@PathVariable (value = "patientId") Long patientId, @PathVariable (value = "billingId") Long billingId) {
        if(!patientRepository.existsById(patientId)) {
            throw new ResourceNotFoundException("PatientId " + patientId + " not found");
        }

        return billingRepository.findById(billingId).map(billing -> {
             billingRepository.delete(billing);
             return ResponseEntity.ok().build();
        }).orElseThrow(() -> new ResourceNotFoundException("BillingId " + billingId + " not found"));
    }

}
