import { Component, EventEmitter, Output, OnInit } from '@angular/core';

import { SeriesService } from '../series.service';
import { EquivalenceClassMap } from '../equivalence-class-map';
import { Project } from '../project';
import { ErrorService } from '../errors';

@Component({
  selector: 'app-component1',
  templateUrl: './component1.component.html',
  styleUrls: ['./component1.component.css']
})
export class Component1Component implements OnInit {
  @Output() onProjectChosen = new EventEmitter<Project>();
  projectList: Object[];
  private mode: string;

  constructor(
    private service: SeriesService,
    private errorS: ErrorService,
  ) { }

  ngOnInit() {
    // get the list of possible projects
  }

  private setMode(mode: string): void {
    this.mode = mode;
    console.log("Setting mode: ", mode);
    this.service.mode = mode;
    this.service.getAvailableProjects(mode).subscribe(
        items => this.projectList = items,
        error => this.errorS.announceError("Server Error", "Logged out?", 2)
    );
  }

  choose(a: Project): void {
    console.log(a);
    this.onProjectChosen.emit(a);
  }

}
