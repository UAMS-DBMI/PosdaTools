import { Component, EventEmitter, Output, OnInit } from '@angular/core';

import { SeriesService } from '../series.service';
import { EquivalenceClassMap } from '../equivalence-class-map';
import { Project } from '../project';
import { ErrorService } from '../errors';

import { Subscription } from 'rxjs';

@Component({
  selector: 'app-mode-select',
  templateUrl: './mode-select.component.html',
  styleUrls: ['./mode-select.component.css']
})
export class ModeSelectComponent implements OnInit {
  @Output() onProjectChosen = new EventEmitter<Project>();
  projectList: Object[];
  public mode: string;
  public busy: Subscription;

  constructor(
    private service: SeriesService,
    private errorS: ErrorService,
  ) { }

  ngOnInit() {
    // get the list of possible projects
  }

  public setMode(mode: string): void {
    this.mode = mode;
    console.log("Setting mode: ", mode);
    this.service.mode = mode;
    this.busy = this.service.getAvailableProjects(mode).subscribe(
        items => this.projectList = items,
        error => this.errorS.announceError("Server Error", "Logged out?", 2)
    );
  }

  choose(a: Project): void {
    console.log(a);
    this.onProjectChosen.emit(a);
  }

}
