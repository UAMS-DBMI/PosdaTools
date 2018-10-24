import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { HideboxComponent } from './hidebox.component';

describe('HideboxComponent', () => {
  let component: HideboxComponent;
  let fixture: ComponentFixture<HideboxComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ HideboxComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(HideboxComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
