import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { environment } from './../../../environments/environment';

@Injectable()
export class PaymentService {

  public API = environment.APIBase;

  constructor(private http: HttpClient) { }

  getAll(): Observable<any> {
    return this.http.get(this.API + '/payments' + '?size=1000');
  }

  getAllByPatient(patientId: string): Observable<any> {
    return this.http.get(this.API + '/patients/' + patientId + '/payments');
  }

  get(patientId: string, id: string) {
    return this.http.get(this.API + '/patients/' + patientId + '/payments/' + id);
  }

  save(patientId: string, payment: any): Observable<any> {
    let result: Observable<Object>;
    if (payment['id']) {
      result = this.http.put(this.API + '/patients/' + patientId + '/payments/' + payment.id, payment);
    } else {
      result = this.http.post(this.API + '/patients/' + patientId + '/payments/', payment);
    }
    return result;
  }

  remove(patientId: string, id: string) {
    return this.http.delete(this.API + '/patients/' + patientId + '/payments/' + id);
  }

}
