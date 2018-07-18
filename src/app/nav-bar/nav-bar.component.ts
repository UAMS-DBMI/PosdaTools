import { Component, EventEmitter, Output, OnInit, Input } from '@angular/core';
import { Project } from '../project';
import { SeriesService } from '../series.service';

@Component({
  selector: 'app-nav',
  templateUrl: './nav-bar.component.html',
  styleUrls: ['./nav-bar.component.css']
})
export class NavBarComponent implements OnInit {
  mode: string;
  dicom_file_type: string;
  project: Project;
  visual_review_instance_id: string;

  @Output() onNavigation = new EventEmitter<String>();
  // @Input() mode: string;
  // @Input() project: Project;


  constructor(private service: SeriesService) { }

  ngOnInit() {
    this.mode = this.service.mode;
    this.dicom_file_type = this.service.dicom_file_type;
    this.project = this.service.selectedProject;
    this.visual_review_instance_id = this.service.visual_review_instance_id;
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
