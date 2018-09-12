import { Component, OnInit, ViewChild, AfterViewInit } from '@angular/core';
import { PatientService } from '../shared/patient/patient.service';
import { MatTableDataSource, MatSort } from '@angular/material';

export interface Patient{
  id: number;
  firstname: string;
  middlename: string;
  lastname: string;
  ssn: string;
  dobyear: number;
  dobmonth: number;
  dobday: number;
  address1: string;
  address2: string;
  city: string;
  state: string;
  zip: string;
}

@Component({
  selector: 'app-patient-list',
  templateUrl: './patient-list.component.html',
  styleUrls: ['./patient-list.component.css']
})

export class PatientListComponent implements OnInit {

  displayedColumns: string[] = ['firstname', 'middlename', 'lastname', 'city', 'state', 'actions'];
  dataSource = new MatTableDataSource([]);
  @ViewChild(MatSort) sort: MatSort;

  constructor(private patientService: PatientService) { }

  ngOnInit() {
    this.patientService.getAll().subscribe(data => {
      var patientData: Patient[] = data.content;
      this.dataSource = new MatTableDataSource(patientData);
      this.dataSource.sort = this.sort;
    });
  }

  remove(id) {
    if(confirm(`Are you sure you want to delete this patient?`)) {
      this.patientService.remove(id).subscribe(result => {
        this.patientService.getAll().subscribe(data => {
          var patientData: Patient[] = data.content;
          this.dataSource = new MatTableDataSource(patientData);
          this.dataSource.sort = this.sort;
        });
      }, error => console.error(error));
    }
  }

}
