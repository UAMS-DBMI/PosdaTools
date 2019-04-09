import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { DBIFqueriesComponent } from './dbifqueries.component';

describe('DBIFqueriesComponent', () => {
  let component: DBIFqueriesComponent;
  let fixture: ComponentFixture<DBIFqueriesComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ DBIFqueriesComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(DBIFqueriesComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
