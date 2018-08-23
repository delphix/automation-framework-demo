import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';
import {
  MatAutocompleteModule,
  MatButtonModule,
  MatButtonToggleModule,
  MatCardModule,
  MatCheckboxModule,
  MatChipsModule,
  MatDatepickerModule,
  MatDialogModule,
  MatExpansionModule,
  MatGridListModule,
  MatIconModule,
  MatInputModule,
  MatListModule,
  MatMenuModule,
  MatNativeDateModule,
  MatPaginatorModule,
  MatProgressBarModule,
  MatProgressSpinnerModule,
  MatRadioModule,
  MatRippleModule,
  MatSelectModule,
  MatSidenavModule,
  MatSliderModule,
  MatSlideToggleModule,
  MatSnackBarModule,
  MatSortModule,
  MatTableModule,
  MatTabsModule,
  MatToolbarModule,
  MatTooltipModule,
  MatStepperModule
} from '@angular/material';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { FormsModule } from '@angular/forms';
import { RouterModule, Routes } from '@angular/router';

import { AppComponent } from './app.component';
import { UserService } from './shared/user/user.service';
import { PatientService } from './shared/patient/patient.service';
import { RecordService } from './shared/record/record.service';
import { UserListComponent } from './user-list/user-list.component';
import { UserEditComponent } from './user-edit/user-edit.component';
import { PatientListComponent } from './patient-list/patient-list.component';
import { PatientEditComponent } from './patient-edit/patient-edit.component';
import { PatientViewComponent } from './patient-view/patient-view.component';
import { RecordEditComponent } from './record-edit/record-edit.component'

const appRoutes: Routes = [
  { path: '', redirectTo: '/patients', pathMatch: 'full' },
  {
    path: 'users',
    component: UserListComponent
  },
  {
    path: 'users/add',
    component: UserEditComponent
  },
  {
    path: 'users/edit/:id',
    component: UserEditComponent
  },
  {
    path: 'patients',
    component: PatientListComponent
  },
  {
    path: 'patients/add',
    component: PatientEditComponent
  },
  {
    path: 'patients/edit/:id',
    component: PatientEditComponent
  },
  {
    path: 'patients/:id',
    component: PatientViewComponent
  },
  {
    path: 'patients/:patientId/records/add',
    component: RecordEditComponent
  },
  {
    path: 'patients/:patientId/records/edit/:id',
    component: RecordEditComponent
  }
];

@NgModule({
  declarations: [
    AppComponent,
    UserListComponent,
    UserEditComponent,
    PatientListComponent,
    PatientEditComponent,
    PatientViewComponent,
    RecordEditComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    BrowserAnimationsModule,
    MatAutocompleteModule,
    MatButtonModule,
    MatButtonToggleModule,
    MatCardModule,
    MatCheckboxModule,
    MatChipsModule,
    MatDatepickerModule,
    MatDialogModule,
    MatExpansionModule,
    MatGridListModule,
    MatIconModule,
    MatInputModule,
    MatListModule,
    MatMenuModule,
    MatNativeDateModule,
    MatPaginatorModule,
    MatProgressBarModule,
    MatProgressSpinnerModule,
    MatRadioModule,
    MatRippleModule,
    MatSelectModule,
    MatSidenavModule,
    MatSliderModule,
    MatSlideToggleModule,
    MatSnackBarModule,
    MatSortModule,
    MatTableModule,
    MatTabsModule,
    MatToolbarModule,
    MatTooltipModule,
    MatStepperModule,
    FormsModule,
    RouterModule.forRoot(appRoutes)
  ],
  providers: [UserService, PatientService, RecordService],
  bootstrap: [AppComponent]
})
export class AppModule { }
