import { Component, OnInit, Input, HostListener } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Project } from '../project';
import { SeriesService } from '../series.service';
import { EquivalenceClassMap } from '../equivalence-class-map';

import { Subscription } from 'rxjs';

@Component({
  selector: 'app-nav-control',
  templateUrl: './nav-control.component.html',
  styleUrls: ['./nav-control.component.css']
})
export class NavControlComponent implements OnInit {
  @Input() project: Project;
  @Input() mode: string;

  iec: EquivalenceClassMap;
  history: EquivalenceClassMap[] = [];
  busy: Subscription;

  processing_status: string;
  review_status: string;
  dicom_file_type: string;
  visual_review_instance_id: string;

  constructor(private service: SeriesService,
              private route: ActivatedRoute,
              private router: Router) { }

  ngOnInit() {
    //TODO: get list of images to review, feed them into app-projection

    console.log('nav-control init');

    this.route.queryParams
      .subscribe(params => {

        this.processing_status = params.processing_status;
        this.review_status = params.review_status;
        this.dicom_file_type = params.dicom_file_type;
        this.visual_review_instance_id = params.visual_review_instance_id;

        console.log('Query param processing_status: ', this.processing_status);
        console.log('Query param review_status: ', this.review_status);
        console.log('Query param dicom_file_type: ', this.dicom_file_type);
        console.log('Query param visual_review_instance_id: ', this.visual_review_instance_id);

        if (this.processing_status == "ReadyToReview"){
          this.service.mode = "unreviewed";
        }

      });

    if ( this.processing_status || this.review_status || this.dicom_file_type) {
      //We probably got here from an external app calling Kaleidoscope with
      //query parameters in url
      this.fetchMoreDataFromQuery();
    }
    else {
      //We probably got here from user selecting a project
      //TODO - should possibly refactor everything to use the query parameters
      //for consistency
      this.fetchMoreData();
    }
  }

  fetchMoreDataFromQuery(){
    console.log("fetchMoreDataFromQuery");
    this.busy = this.service.getNextUnreviewedByQuery(this.processing_status, this.review_status, this.dicom_file_type).subscribe(
      data => {
        console.log('fetchMoreDataFromQuery got: ', data);
        if (this.iec !== undefined) {
          this.history.push(this.iec);
        }
        this.iec = data[0];
      },
      error => this.handleError(error)
    );

    return this.busy;
  }

  fetchMoreData() {
    console.log("fetchMoreData");
    this.busy = this.service.getNextUnreviewed(this.iec).subscribe(
      data => {
        console.log('fetchMoreData got: ', data);
        if (this.iec !== undefined) {
          this.history.push(this.iec);
        }
        this.iec = data[0];
      },
      error => this.handleError(error)
    );

    return this.busy;
  }

  onMark() {
    console.log('nav-control detected mark');
    this.moveForward();
  }


  moveForward() {
    console.log('moveForward()');
    this.fetchMoreData();
  }

  moveBackward() {
    console.log('moveBackward()');
    this.iec = this.history.pop();
  }

  @HostListener('document:keydown', ['$event'])
  handleKeyboardEvent(event: KeyboardEvent) {
    if (event.key == 'ArrowRight') {
      this.moveForward();
    }
    if (event.key == 'ArrowLeft') {
      this.moveBackward();
    }
  }

  handleError(error: any) {
    console.log(error);
  }
}
