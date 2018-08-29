import { Injectable } from '@angular/core';
import { HttpRequest, HttpHandler, HttpEvent, HttpInterceptor } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable()
export class JwtInterceptor implements HttpInterceptor {
    intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
        let token = localStorage.getItem('jwt');
        if (token) {
            request = request.clone({
                setHeaders: {
                    'Content-Type':  'application/json',
                    'Authorization': `Bearer ${token}`
                }
            });
        }

        return next.handle(request);
    }
}
