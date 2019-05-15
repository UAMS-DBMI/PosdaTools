import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { FwtComponent } from './fwt.component';

describe('FwtComponent', () => {
  let component: FwtComponent;
  let fixture: ComponentFixture<FwtComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ FwtComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(FwtComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
