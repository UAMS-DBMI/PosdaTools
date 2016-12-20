import { Component, EventEmitter, Output, OnInit } from '@angular/core';

import { SeriesService } from '../series.service';
import { EquivalenceClassMap } from '../equivalence-class-map';
import { Project } from '../project';

@Component({
  selector: 'app-component1',
  templateUrl: './component1.component.html',
  styleUrls: ['./component1.component.css']
})
export class Component1Component implements OnInit {
  @Output() onProjectChosen = new EventEmitter<Project>();
  projectList: Object[];

  constructor(private service: SeriesService) { }

  ngOnInit() {
    // get the list of possible projects
    this.service.getAvailableProjects("good").subscribe(
      items => this.projectList = items
    );
  }

  choose(a: Project) {
    console.log(a);
    this.onProjectChosen.emit(a);
  }

}
