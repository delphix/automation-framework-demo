import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { BillingEditComponent } from './billing-edit.component';

describe('BillingEditComponent', () => {
  let component: BillingEditComponent;
  let fixture: ComponentFixture<BillingEditComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ BillingEditComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(BillingEditComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
