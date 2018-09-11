import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { environment } from './../../../environments/environment';

@Injectable()
export class BillingService {

  public API = environment.APIBase;

  constructor(private http: HttpClient) { }

  getAll(patientId: string): Observable<any> {
    return this.http.get(this.API + '/patients/' + patientId + '/billings');
  }

  get(patientId: string, id: string) {
    return this.http.get(this.API + '/patients/' + patientId + '/billings/' + id);
  }

  save(patientId: string, billing: any): Observable<any> {
    let result: Observable<Object>;
    if (billing['id']) {
      result = this.http.put(this.API + '/patients/' + patientId + '/billings/' + billing.id, billing);
    } else {
      result = this.http.post(this.API + '/patients/' + patientId + '/billings/', billing);
    }
    return result;
  }

  remove(patientId: string, id: string) {
    return this.http.delete(this.API + '/patients/' + patientId + '/billings/' + id);
  }

}
