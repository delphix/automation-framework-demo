import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';

@Injectable()
export class PatientService {

  public API = '//localhost:8080';
  public PATIENT_API = this.API + '/patients';

  constructor(private http: HttpClient) {
  }

  getAll(): Observable<any> {
    return this.http.get(this.PATIENT_API);
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
