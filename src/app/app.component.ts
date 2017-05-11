import { Component, HostListener } from '@angular/core';

import { Router, ActivatedRoute, Params } from '@angular/router';
import { SeriesService } from './series.service';
import { EquivalenceClassMap } from './equivalence-class-map';
import { Project } from './project';
import { ErrorService } from './errors';

import { Subscription } from 'rxjs';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  mode: string;
  project: Project;


  // mostly old stuff below here
  iecList: EquivalenceClassMap[];
  currentIecOffset: number;
  loggedOut: boolean = false;
  currentIec: number;
  public endOfData: boolean = false;

  public busy: Subscription;

  constructor(
    private service: SeriesService,
    private errorS: ErrorService,
  ) {
    this.currentIecOffset = 0;
  }

  ngOnInit() {
    this.attemptLogin(window.location.search);
  }

  private handleError(error) {
      console.log("Error follows");
	  console.log(error);
      this.errorS.announceError("Server Error", 
          "Error communicating with server. Maybe you have been logged out?", 2);  
      this.loggedOut = true;
  }

  private attemptLogin(search: string) {
    var token: string;
    var parts: string[];
    parts = search.split('=');
    if (parts[0] == '?token') {
      token = parts[1];
      console.log(token);
      this.service.setToken(token);
    }
  }


  getCurrentIec(offset: number = 0): number {
    if (this.currentIecOffset > this.iecList.length - 1) {
      return -1;
    }
    return this.iecList[this.currentIecOffset].image_equivalence_class_id;
  }

  moveBackward() {
    if (this.currentIecOffset > 0) {
      this.currentIecOffset -= 1;
      // this.updateDisplay(this.getCurrentIec());
    }
  }
  fetchMoreData() {
    var currentIec: number = this.getCurrentIec();

    this.busy = this.service.getAllUnreviewed(this.iecList.length).subscribe(
      newList => {
        this.iecList = this.iecList.concat(newList);
        if (newList.length == 0) {
          this.endOfData = true;
        }
      },
      error => this.handleError(error)
    );

  }
  moveForward() {
    // load the next IEC into the viewer component

    this.currentIecOffset += 1;
    var currentIec: number = this.getCurrentIec();

    if (currentIec == -1) {
      this.endOfData = true;
      return;
    }

    if (this.currentIecOffset >= this.iecList.length - 1) {
      this.fetchMoreData();
    }

    // this.updateDisplay(currentIec);
  }


  // --------------------- new / keep -----------------
  
  // TODO: rename this to onNavigation?
  navigate(where: string): void {
    console.log("navigate() called");
    if (where == "home") {
      this.project = undefined;
      this.mode = undefined;
    }
  }

  onModeChosen(mode: string) {
    console.log('from app.component, mode chosen: ', mode);
    this.mode = mode;
    // TODO: update nav-bar's known mode; actually just make nav-bar take mode as an input
  }

  onProjectChosen(project: Project) {
    // TODO: update nav-bar's known project, make nav-bar take project as an input

    console.log('from app.component, project chosen: ', project);

    this.project = project;
    this.service.selectedProject = project;
  }

}
