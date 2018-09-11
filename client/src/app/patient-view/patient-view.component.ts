import { Component, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { Subscription } from 'rxjs/Subscription';
import { ActivatedRoute, Router } from '@angular/router';
import { PatientService } from '../shared/patient/patient.service';
import { RecordService } from '../shared/record/record.service';
import { BillingService } from '../shared/billing/billing.service';
import { MatTableDataSource, MatSort } from '@angular/material';

export interface Record{
  id: number;
  type: string;
  createdAt: string;
  updatedAt: string;
}

@Component({
  selector: 'app-patient-view',
  templateUrl: './patient-view.component.html',
  styleUrls: ['./patient-view.component.css']
})

export class PatientViewComponent implements OnInit {

  patient: any = {};
  id: string;
  sub: Subscription;
  recordColumns: string[] = ['id', 'type', 'createdAt', 'updatedAt', 'actions'];
  billingColumns: string[] = ['id', 'ccnum', 'createdAt', 'updatedAt', 'actions'];
  records = new MatTableDataSource([]);
  billings = new MatTableDataSource([]);
  @ViewChild(MatSort) sort: MatSort;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private patientService: PatientService,
    private recordService: RecordService,
    private billingService: BillingService
  ) {
  }

  ngOnInit() {
    this.sub = this.route.params.subscribe(params => {
      this.id = params['id'];
      if (this.id) {
        this.patientService.get(this.id).subscribe((patient: any) => {
          if (patient) {
            this.patient = patient;

            this.recordService.getAll(this.id).subscribe(data => {
              var recordData: Record[] = data.content;
              this.records = new MatTableDataSource(recordData);
              this.records.sort = this.sort;
            });

            this.billingService.getAll(this.id).subscribe(data => {
              var billingData: Record[] = data.content;
              this.billings = new MatTableDataSource(billingData);
              this.billings.sort = this.sort;
            });

          } else {
            console.log(`Patient with id '${this.id}' not found, returning to list`);
            this.router.navigate(['/patients']);
          }
        });
      }
    });
  }

  remove(id) {
    if(confirm(`Are you sure you want to delete this patient?`)) {
      this.patientService.remove(id).subscribe(result => {
        this.router.navigate(['/patients']);
      }, error => console.error(error));
    }
  }

  removeRecord(recordId) {
    if(confirm(`Are you sure you want to delete this record?`)) {
      this.recordService.remove(this.id, recordId).subscribe(result => {
        this.recordService.getAll(this.id).subscribe(data => {
          var recordData: Record[] = data.content;
          this.records = new MatTableDataSource(recordData);
          this.records.sort = this.sort;
        });
      }, error => console.error(error));
    }
  }

}
