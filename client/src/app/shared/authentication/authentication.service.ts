import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { environment } from './../../../environments/environment';

const headers = new HttpHeaders().set('Content-Type', 'application/json');

@Injectable({
  providedIn: 'root'
})
export class AuthenticationService {

  public API = `${environment.APIBase}/auth`;

  constructor(private http: HttpClient) { }

  login(form: any): Observable<any> {
    let result: Observable<Object>;
    result = this.http.post(`${this.API}/login`, JSON.stringify(form), { headers, responseType: 'text'});
    return result;
  }

  logout() {
      localStorage.removeItem('jwt');
  }
}
