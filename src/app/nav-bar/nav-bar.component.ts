import { Component, EventEmitter, Output, OnInit, OnDestroy, Input } from '@angular/core';
import { Project } from '../project';
import { SeriesService } from '../series.service';
import { Subscription } from 'rxjs/Subscription';

@Component({
  selector: 'app-nav',
  templateUrl: './nav-bar.component.html',
  styleUrls: ['./nav-bar.component.css']
})
export class NavBarComponent implements OnInit, OnDestroy {
  mode: string;
  modeSubscription: Subscription;
  dicom_file_type: string;
  dicomFileTypeSubscription: Subscription;
  project: string;
  projectSubscription: Subscription;

  visual_review_instance_id: string;
  vriiSubscription: Subscription;

  //@Output() onNavigation = new EventEmitter<String>();
  // @Input() mode: string;
  // @Input() project: Project;


  constructor(private service: SeriesService) { }

  ngOnInit() {

    this.dicomFileTypeSubscription = this.service.dicom_file_type.subscribe(
      (dicom_file_type) => {
        this.dicom_file_type = dicom_file_type;
      }
    );

    this.modeSubscription = this.service.mode.subscribe(
      (mode) => {
        this.mode = mode;
      }
    );

    this.vriiSubscription = this.service.visual_review_instance_id.subscribe(
      (visual_review_instance_id) => {
        this.visual_review_instance_id = visual_review_instance_id;
      }
    );

    this.projectSubscription = this.service.projectDescription.subscribe(
      (project) => {
        this.project = project;
      }
    );

  }

  ngOnDestroy() {
    this.dicomFileTypeSubscription.unsubscribe();
    this.modeSubscription.unsubscribe();
    this.vriiSubscription.unsubscribe();
    this.projectSubscription.unsubscribe();
  }

  // home() {
  //   this.onNavigation.emit('home');
  //   console.log("emitting onNavigation => 'home'");
  // }
  // admin() {
  //   this.onNavigation.emit('admin');
  //   console.log("emitting onNavigation => 'admin'");
  // }

}
