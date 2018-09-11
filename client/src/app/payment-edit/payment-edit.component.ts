import { Component, OnDestroy, OnInit } from '@angular/core';
import { Subscription } from 'rxjs/Subscription';
import { ActivatedRoute, Router } from '@angular/router';
import { PaymentService } from '../shared/payment/payment.service';
import { NgForm } from '@angular/forms';

@Component({
  selector: 'app-payment-edit',
  templateUrl: './payment-edit.component.html',
  styleUrls: ['./payment-edit.component.css']
})
export class PaymentEditComponent implements OnInit, OnDestroy {

  payment: any = {};
  action = "Add";
  patientId: string;
  sub: Subscription;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private paymentService: PaymentService
  ) {
  }

  ngOnInit() {
    this.sub = this.route.params.subscribe(params => {
      this.patientId = params['patientId'];
      const id = params['id'];
      if (id) {
        this.action = "Edit";
        this.paymentService.get(this.patientId, id).subscribe((payment: any) => {
          if (payment) {
            this.payment = payment;
          } else {
            console.log(`Payment with id '${id}' not found, returning to list`);
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
    this.paymentService.save(this.patientId, form).subscribe(result => {
      this.gotoList();
    }, error => console.error(error));
  }

}
