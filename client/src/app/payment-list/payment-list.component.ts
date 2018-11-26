import { Component, OnInit, ViewChild, AfterViewInit } from '@angular/core';
import { PaymentService } from '../shared/payment/payment.service';
import { PatientService } from '../shared/patient/patient.service';
import { MatPaginator, MatTableDataSource, MatSort } from '@angular/material';

export interface Patient {
  id: number;
  firstname: string;
  lastname: string;
}

export interface Payment{
  id: number;
  patient_id: string;
  patient: Patient;
  amount: number;
  authcode: string;
  currency: string;
  captured: boolean;
  type: string;
  createdAt: string;
  updatedAt: string;
}

@Component({
  selector: 'app-payment-list',
  templateUrl: './payment-list.component.html',
  styleUrls: ['./payment-list.component.css']
})

export class PaymentListComponent implements OnInit {

  paymentColumns: string[] = ['id', 'patient', 'amount', 'currency', 'type', 'createdAt'];
  payments = new MatTableDataSource([]);
  @ViewChild(MatSort) sort: MatSort;

  constructor(
    private paymentService: PaymentService,
    private patientService: PatientService
  ) { }

  @ViewChild(MatPaginator) paginator: MatPaginator;

  ngOnInit() {
    this.paymentService.getAll().subscribe(data => {
      var paymentData: Payment[] = data.content;

      paymentData.forEach((payment, index) => {
        this.patientService.get(payment.patient_id).subscribe((patient: any) => {
          var patientData: Patient = patient;
          paymentData[index].patient = patientData
        });
      });

      this.payments = new MatTableDataSource(paymentData);
      this.payments.sort = this.sort;
      this.payments.paginator = this.paginator;
    });
  }
}
