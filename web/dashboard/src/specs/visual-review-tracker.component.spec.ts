import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { VisualReviewTrackerComponent } from './visual-review-tracker.component';

describe('VisualReviewTrackerComponent', () => {
  let component: VisualReviewTrackerComponent;
  let fixture: ComponentFixture<VisualReviewTrackerComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ VisualReviewTrackerComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(VisualReviewTrackerComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
