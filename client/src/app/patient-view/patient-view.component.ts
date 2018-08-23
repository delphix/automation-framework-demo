import { Component, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { Subscription } from 'rxjs/Subscription';
import { ActivatedRoute, Router } from '@angular/router';
import { PatientService } from '../shared/patient/patient.service';
import { RecordService } from '../shared/record/record.service';
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
  displayedColumns: string[] = ['id', 'type', 'createdAt', 'updatedAt', 'actions'];
  dataSource = new MatTableDataSource([]);
  @ViewChild(MatSort) sort: MatSort;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private patientService: PatientService,
    private recordService: RecordService
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
              this.dataSource = new MatTableDataSource(recordData);
              this.dataSource.sort = this.sort;
            });
          } else {
            console.log(`Patient with id '${this.id}' not found, returning to list`);
            this.router.navigate(['/patients']);
          }
        });
      }
    });
  }

  removeRecord(recordId) {
    this.recordService.remove(this.id, recordId).subscribe(result => {
      this.recordService.getAll(this.id).subscribe(data => {
        var recordData: Record[] = data.content;
        this.dataSource = new MatTableDataSource(recordData);
        this.dataSource.sort = this.sort;
      });
    }, error => console.error(error));
  }

}
