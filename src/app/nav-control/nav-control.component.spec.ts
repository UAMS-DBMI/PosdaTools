import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { NavControlComponent } from './nav-control.component';

describe('NavControlComponent', () => {
  let component: NavControlComponent;
  let fixture: ComponentFixture<NavControlComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ NavControlComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(NavControlComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
