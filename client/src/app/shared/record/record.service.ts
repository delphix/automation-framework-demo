import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';

@Injectable()
export class RecordService {

  public API = '//localhost:8080';

  constructor(private http: HttpClient) { }

  getAll(patientId: string): Observable<any> {
    return this.http.get(this.API + '/patients/' + patientId + '/records');
  }
  /*
  get(id: string) {
    return this.http.get(this.RECORD_API + '/' + id);
  }

  save(record: any): Observable<any> {
    let result: Observable<Object>;
    if (record['id']) {
      result = this.http.put(this.RECORD_API + '/' + record.id, record);
    } else {
      result = this.http.post(this.RECORD_API, record);
    }
    return result;
  }

  remove(id: string) {
    return this.http.delete(this.RECORD_API + '/' + id);
  }
  */
}
