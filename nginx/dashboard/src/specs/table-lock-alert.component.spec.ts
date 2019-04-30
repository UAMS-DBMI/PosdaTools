import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { TableLockAlertComponent } from './table-lock-alert.component';

describe('TableLockAlertComponent', () => {
  let component: TableLockAlertComponent;
  let fixture: ComponentFixture<TableLockAlertComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ TableLockAlertComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(TableLockAlertComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
