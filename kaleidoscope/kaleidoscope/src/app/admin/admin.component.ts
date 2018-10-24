import { Component, OnInit } from '@angular/core';
import { Project } from '../project';
import { SeriesService } from '../series.service';
import { ErrorService } from '../errors';

@Component({
  selector: 'app-admin',
  templateUrl: './admin.component.html',
  styleUrls: ['./admin.component.css']
})
export class AdminComponent implements OnInit {
  public projectList: Project[];
  public mode: string = "hide";

  constructor(
    private service: SeriesService,
    private errorS: ErrorService,
  ) { }

  ngOnInit() {
    this.ngOnChanges();
  }
  ngOnChanges() {
    let mode: string;
    if (this.mode == "hide") {
      mode = "unhidden";
    } else {
      mode = "hidden";
    }

    this.service.getAvailableProjects(mode).subscribe(
        items => this.projectList = items,
        error => this.errorS.announceError("Server Error", "Logged out?", 2)
    );

  }

  onClickHide() {
    this.mode = "hide";
    this.ngOnChanges();
  }

  onClickUnhide() {
    this.mode = "unhide";
    this.ngOnChanges();
  }

}
