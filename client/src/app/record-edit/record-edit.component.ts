import { Component, OnDestroy, OnInit } from '@angular/core';
import { Subscription } from 'rxjs/Subscription';
import { ActivatedRoute, Router } from '@angular/router';
import { RecordService } from '../shared/record/record.service';
import { NgForm } from '@angular/forms';

@Component({
  selector: 'app-record-edit',
  templateUrl: './record-edit.component.html',
  styleUrls: ['./record-edit.component.css']
})
export class RecordEditComponent implements OnInit, OnDestroy {

  record: any = {};
  action = "Add";
  patientId: string;
  sub: Subscription;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private recordService: RecordService
  ) {
  }

  ngOnInit() {
    this.sub = this.route.params.subscribe(params => {
      this.patientId = params['patientId'];
      const id = params['id'];
      if (id) {
        this.action = "Edit";
        this.recordService.get(this.patientId, id).subscribe((record: any) => {
          if (record) {
            this.record = record;
          } else {
            console.log(`Record with id '${id}' not found, returning to list`);
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
    this.router.navigate(['/patients', this.patientId]);
  }

  save(form: NgForm) {
    this.recordService.save(this.patientId, form).subscribe(result => {
      this.gotoList();
    }, error => console.error(error));
  }

}
