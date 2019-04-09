import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PRBSComponent } from './prbs.component';

describe('PRBSComponent', () => {
  let component: PRBSComponent;
  let fixture: ComponentFixture<PRBSComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PRBSComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PRBSComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
