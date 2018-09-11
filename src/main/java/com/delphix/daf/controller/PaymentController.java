package com.delphix.daf.controller;

import java.util.Optional;
import com.delphix.daf.exception.ResourceNotFoundException;
import com.delphix.daf.model.Payment;
import com.delphix.daf.repository.PaymentRepository;
import com.delphix.daf.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import javax.validation.Valid;

@RestController
public class PaymentController {

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private PatientRepository patientRepository;

    @GetMapping("/payments")
    public Page<Payment> getPatients(Pageable pageable) {
        return paymentRepository.findAll(pageable);
    }

    @GetMapping("/patients/{patientId}/payments")
    public Page<Payment> getAllPaymentsByPatientId(@PathVariable (value = "patientId") Long patientId, Pageable pageable) {
       return paymentRepository.findByPatientId(patientId, pageable);
    }

    @GetMapping("/patients/{patientId}/payments/{paymentId}")
    public Optional<Payment> getPayment(@PathVariable (value = "patientId") Long patientId, @PathVariable (value = "paymentId") Long paymentId) {
        if(!patientRepository.existsById(patientId)) {
            throw new ResourceNotFoundException("PatientId " + patientId + " not found");
        }
        return paymentRepository.findById(paymentId);
    }

    @PostMapping("/patients/{patientId}/payments")
    public Payment createPayment(@PathVariable (value = "patientId") Long patientId, @Valid @RequestBody Payment payment) {
        return patientRepository.findById(patientId).map(patient -> {
            payment.setPatient(patient);
            return paymentRepository.save(payment);
        }).orElseThrow(() -> new ResourceNotFoundException("PatientId " + patientId + " not found"));
    }

    @PutMapping("/patients/{patientId}/payments/{paymentId}")
    public Payment updatePayment(@PathVariable (value = "patientId") Long patientId, @PathVariable (value = "paymentId") Long paymentId, @Valid @RequestBody Payment paymentRequest) {
        if(!patientRepository.existsById(patientId)) {
            throw new ResourceNotFoundException("PatientId " + patientId + " not found");
        }
        return paymentRepository.findById(paymentId).map(payment -> {
            payment.setAmount(paymentRequest.getAmount());
            payment.setAuthcode(paymentRequest.getAuthcode());
            payment.setCurrency(paymentRequest.getCurrency());
            payment.setCaptured(paymentRequest.getCaptured());
            payment.setType(paymentRequest.getType());
            return paymentRepository.save(payment);
        }).orElseThrow(() -> new ResourceNotFoundException("PaymentId " + paymentId + "not found"));
    }

    @DeleteMapping("/patients/{patientId}/payments/{paymentId}")
    public ResponseEntity<?> deletePayment(@PathVariable (value = "patientId") Long patientId, @PathVariable (value = "paymentId") Long paymentId) {
        if(!patientRepository.existsById(patientId)) {
            throw new ResourceNotFoundException("PatientId " + patientId + " not found");
        }

        return paymentRepository.findById(paymentId).map(payment -> {
             paymentRepository.delete(payment);
             return ResponseEntity.ok().build();
        }).orElseThrow(() -> new ResourceNotFoundException("PaymentId " + paymentId + " not found"));
    }

}
