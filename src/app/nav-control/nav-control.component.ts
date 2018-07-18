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

      });


    this.setServiceVars();

    this.fetchMoreData();

  }

  setServiceVars(){
    //Only set mode here if we got here via a parameterized url

    if (this.processing_status && this.processing_status.toLowerCase() == "readytoreview")
      this.service.mode = "unreviewed";

    //If we got contradictory info (i.e "readytoreview" & "good"), favor the review_status
    if (this.review_status &&
      (this.review_status.toLowerCase() == "good"
        ||  this.review_status.toLowerCase() == "bad"
        || this.review_status.toLowerCase() == "blank"
        || this.review_status.toLowerCase() == "scout"
        || this.review_status.toLowerCase() == "other"
      ) )
      this.service.mode = this.review_status.toLowerCase();


    //If we get parameters, but don't get either processing_status or review_status.
    //May eventually want to ask the user.  For now, assume "unreviewed"
    if (this.service.mode == null){
      this.service.mode = "unreviewed";
    }


    this.service.dicom_file_type = this.dicom_file_type;
    this.service.visual_review_instance_id = this.visual_review_instance_id;
  }


  fetchMoreData() {
    console.log("fetchMoreData");
    this.busy = this.service.getNextUnreviewed(this.iec, this.dicom_file_type, this.visual_review_instance_id).subscribe(
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
