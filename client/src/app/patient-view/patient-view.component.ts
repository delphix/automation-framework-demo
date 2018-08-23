import { Component, OnDestroy, OnInit } from '@angular/core';
import { Subscription } from 'rxjs/Subscription';
import { ActivatedRoute, Router } from '@angular/router';
import { PatientService } from '../shared/patient/patient.service';
import { NgForm } from '@angular/forms';

@Component({
  selector: 'app-patient-view',
  templateUrl: './patient-view.component.html',
  styleUrls: ['./patient-view.component.css']
})

export class PatientViewComponent implements OnInit {

  patient: any = {};
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
        this.patientService.get(id).subscribe((patient: any) => {
          if (patient) {
            this.patient = patient;
          } else {
            console.log(`Patient with id '${id}' not found, returning to list`);
            this.router.navigate(['/patients']);
          }
        });
      }
    });
  }

}
