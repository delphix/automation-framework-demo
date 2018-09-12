import { Routes, RouterModule } from '@angular/router';
import { AuthGuard } from './guards/auth.guard';
import { UserListComponent } from './user-list/user-list.component';
import { UserEditComponent } from './user-edit/user-edit.component';
import { PatientListComponent } from './patient-list/patient-list.component';
import { PatientEditComponent } from './patient-edit/patient-edit.component';
import { PatientViewComponent } from './patient-view/patient-view.component';
import { RecordEditComponent } from './record-edit/record-edit.component';
import { BillingEditComponent } from './billing-edit/billing-edit.component';
import { PaymentEditComponent } from './payment-edit/payment-edit.component';
import { PaymentListComponent } from './payment-list/payment-list.component';
import { LoginComponent } from './login/login.component';

const appRoutes: Routes = [
    { path: '', redirectTo: '/patients', pathMatch: 'full' },
    { path: 'users', component: UserListComponent, canActivate: [AuthGuard]  },
    { path: 'users/add', component: UserEditComponent, canActivate: [AuthGuard]  },
    { path: 'users/edit/:id', component: UserEditComponent, canActivate: [AuthGuard]  },
    { path: 'patients', component: PatientListComponent, canActivate: [AuthGuard]  },
    { path: 'patients/add', component: PatientEditComponent, canActivate: [AuthGuard]  },
    { path: 'patients/edit/:id', component: PatientEditComponent, canActivate: [AuthGuard]  },
    { path: 'patients/:id', component: PatientViewComponent, canActivate: [AuthGuard]  },
    { path: 'patients/:patientId/records/add', component: RecordEditComponent, canActivate: [AuthGuard]  },
    { path: 'patients/:patientId/records/edit/:id', component: RecordEditComponent, canActivate: [AuthGuard]  },
    { path: 'patients/:patientId/billings/add', component: BillingEditComponent, canActivate: [AuthGuard]  },
    { path: 'patients/:patientId/billings/edit/:id', component: BillingEditComponent, canActivate: [AuthGuard]  },
    { path: 'patients/:patientId/payments/add', component: PaymentEditComponent, canActivate: [AuthGuard]  },
    { path: 'patients/:patientId/payments/edit/:id', component: PaymentEditComponent, canActivate: [AuthGuard]  },
    { path: 'payments', component: PaymentListComponent, canActivate: [AuthGuard]  },
    { path: 'login', component: LoginComponent },
    { path: '**', redirectTo: '' }
];

export const routing = RouterModule.forRoot(appRoutes);
