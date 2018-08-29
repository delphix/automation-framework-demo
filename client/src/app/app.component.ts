import { MediaMatcher } from '@angular/cdk/layout';
import { ChangeDetectorRef, Component, ViewChild } from '@angular/core';
import { MatSidenav } from '@angular/material';
import { Router } from '@angular/router';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  @ViewChild('snav') public sidenav: MatSidenav;
  mobileQuery: MediaQueryList;
  private _mobileQueryListener: () => void;
  title = 'client';

  constructor(
    changeDetectorRef: ChangeDetectorRef,
    private router: Router,
    media: MediaMatcher
  ) {
    this.mobileQuery = media.matchMedia('(max-width: 600px)');
    this._mobileQueryListener = () => changeDetectorRef.detectChanges();
    this.mobileQuery.addListener(this._mobileQueryListener);
  }

  isLoginPage() {
    return this.router.url.indexOf('/login');
  }

  sendToRoute(sRoute: string, isMobile: boolean) {
    if (isMobile) {
      this.sidenav.close();
      this.router.navigate([sRoute]);
    }
  }
}
