import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { environment } from './../../../environments/environment';

@Injectable()
export class RecordService {

  public API = environment.APIBase;

  constructor(private http: HttpClient) { }

  getAll(patientId: string): Observable<any> {
    return this.http.get(this.API + '/patients/' + patientId + '/records');
  }

  get(patientId: string, id: string) {
    return this.http.get(this.API + '/patients/' + patientId + '/records/' + id);
  }

  save(patientId: string, record: any): Observable<any> {
    let result: Observable<Object>;
    if (record['id']) {
      result = this.http.put(this.API + '/patients/' + patientId + '/records/' + record.id, record);
    } else {
      result = this.http.post(this.API + '/patients/' + patientId + '/records/', record);
    }
    return result;
  }

  remove(patientId: string, id: string) {
    return this.http.delete(this.API + '/patients/' + patientId + '/records/' + id);
  }

}
