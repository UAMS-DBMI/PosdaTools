import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { FileTimeChartComponent } from './file-time-chart.component';

describe('FileTimeChartComponent', () => {
  let component: FileTimeChartComponent;
  let fixture: ComponentFixture<FileTimeChartComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ FileTimeChartComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(FileTimeChartComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
