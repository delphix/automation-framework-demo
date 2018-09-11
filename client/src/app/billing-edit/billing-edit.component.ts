import { Component, OnDestroy, OnInit } from '@angular/core';
import { Subscription } from 'rxjs/Subscription';
import { ActivatedRoute, Router } from '@angular/router';
import { BillingService } from '../shared/billing/billing.service';
import { NgForm } from '@angular/forms';

@Component({
  selector: 'app-billing-edit',
  templateUrl: './billing-edit.component.html',
  styleUrls: ['./billing-edit.component.css']
})
export class BillingEditComponent implements OnInit, OnDestroy {

  billing: any = {};
  action = "Add";
  patientId: string;
  sub: Subscription;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private billingService: BillingService
  ) {
  }

  ngOnInit() {
    this.sub = this.route.params.subscribe(params => {
      this.patientId = params['patientId'];
      const id = params['id'];
      if (id) {
        this.action = "Edit";
        this.billingService.get(this.patientId, id).subscribe((billing: any) => {
          if (billing) {
            this.billing = billing;
          } else {
            console.log(`Billing with id '${id}' not found, returning to list`);
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
    this.billingService.save(this.patientId, form).subscribe(result => {
      this.gotoList();
    }, error => console.error(error));
  }

}
