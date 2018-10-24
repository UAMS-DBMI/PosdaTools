import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { MarkControlComponent } from './mark-control.component';

describe('MarkControlComponent', () => {
  let component: MarkControlComponent;
  let fixture: ComponentFixture<MarkControlComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ MarkControlComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(MarkControlComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
