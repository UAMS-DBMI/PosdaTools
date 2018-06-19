import { Component, OnInit, Input, EventEmitter, Output } from '@angular/core';

import { SeriesService } from '../series.service';
import { EquivalenceClassMap } from '../equivalence-class-map';
import { Project } from '../project';
import { ErrorService } from '../errors';
import {Router} from "@angular/router";

import { Subscription } from 'rxjs';

@Component({
  selector: 'app-project-select',
  templateUrl: './project-select.component.html',
  styleUrls: ['./project-select.component.css']
})
export class ProjectSelectComponent implements OnInit {
  @Input() public mode: string;
  @Output() onProjectChosen = new EventEmitter<Project>();

  projectList: Project[];
  public busy: Subscription;

  constructor(
    private service: SeriesService,
    private errorS: ErrorService,
    private router: Router
  ) { }

  ngOnInit() {
  }

  ngOnChanges() {
    this.service.mode = this.mode;
    if (this.mode !== undefined) {
      this.busy = this.service.getAvailableProjects(this.mode).subscribe(
          items => this.projectList = items,
          error => this.errorS.announceError("Server Error", "Logged out?", 2)
      );
    }
  }

  choose(a: Project): void {
    //console.log(a);
    //this.onProjectChosen.emit(a);
    this.service.selectedProject = a;
    this.router.navigate(['work']);
  }

}
