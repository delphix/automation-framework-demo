import { Component, OnDestroy, OnInit } from '@angular/core';
import { Subscription } from 'rxjs/Subscription';
import { ActivatedRoute, Router } from '@angular/router';
import { PatientService } from '../shared/patient/patient.service';
import { NgForm } from '@angular/forms';

@Component({
  selector: 'app-patient-edit',
  templateUrl: './patient-edit.component.html',
  styleUrls: ['./patient-edit.component.css']
})
export class PatientEditComponent implements OnInit, OnDestroy {

  patient: any = {};
  action = "Add";
  sub: Subscription;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private patientService: PatientService
  ) {
  }

  ngOnInit() {
    this.sub = this.route.params.subscribe(params => {
      const id = params['id'];
      if (id) {
        this.action = "Edit";
        this.patientService.get(id).subscribe((patient: any) => {
          if (patient) {
            this.patient = patient;
          } else {
            console.log(`Patient with id '${id}' not found, returning to list`);
            this.gotoList();
          }
        });
      }
    });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  gotoList() {
    this.router.navigate(['/patients']);
  }

  save(form: NgForm) {
    this.patientService.save(form).subscribe(result => {
      this.gotoList();
    }, error => console.error(error));
  }

}
