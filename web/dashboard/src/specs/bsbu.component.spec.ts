import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { BsbuComponent } from './bsbu.component';

describe('BsbuComponent', () => {
  let component: BsbuComponent;
  let fixture: ComponentFixture<BsbuComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ BsbuComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(BsbuComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
