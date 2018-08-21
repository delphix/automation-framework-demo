import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';
import { MatButtonModule, MatCardModule, MatInputModule, MatListModule, MatToolbarModule } from '@angular/material';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { FormsModule } from '@angular/forms';
import { RouterModule, Routes } from '@angular/router';

import { AppComponent } from './app.component';
import { UserService } from './shared/user/user.service';
import { UserListComponent } from './user-list/user-list.component';
import { UserEditComponent } from './user-edit/user-edit.component'

const appRoutes: Routes = [
  { path: '', redirectTo: '/user-list', pathMatch: 'full' },
  {
    path: 'user-list',
    component: UserListComponent
  },
  {
    path: 'user-add',
    component: UserEditComponent
  },
  {
    path: 'user-edit/:id',
    component: UserEditComponent
  }
];

@NgModule({
  declarations: [
    AppComponent,
    UserListComponent,
    UserEditComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    BrowserAnimationsModule,
    MatButtonModule,
    MatCardModule,
    MatInputModule,
    MatListModule,
    MatToolbarModule,
    FormsModule,
    RouterModule.forRoot(appRoutes)
  ],
  providers: [UserService],
  bootstrap: [AppComponent]
})
export class AppModule { }
