import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { environment } from './../../../environments/environment';

@Injectable()
export class PatientService {

  public PATIENT_API = environment.APIBase + '/patients';

  constructor(private http: HttpClient) {
  }

  getAll(): Observable<any> {
    return this.http.get(this.PATIENT_API + '?size=1000');
  }

  get(id: string) {
    return this.http.get(this.PATIENT_API + '/' + id);
  }

  save(patient: any): Observable<any> {
    let result: Observable<Object>;
    if (patient['id']) {
      result = this.http.put(this.PATIENT_API + '/' + patient.id, patient);
    } else {
      result = this.http.post(this.PATIENT_API, patient);
    }
    return result;
  }

  remove(id: string) {
    return this.http.delete(this.PATIENT_API + '/' + id);
  }

}
