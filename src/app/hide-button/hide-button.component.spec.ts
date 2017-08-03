import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { HideButtonComponent } from './hide-button.component';

describe('HideButtonComponent', () => {
  let component: HideButtonComponent;
  let fixture: ComponentFixture<HideButtonComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ HideButtonComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(HideButtonComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
