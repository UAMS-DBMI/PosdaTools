import { Component } from '@angular/core';

import { Router, ActivatedRoute, Params } from '@angular/router';
import { SeriesService } from './series.service';
import { EquivalenceClassMap } from './equivalence-class-map';
import { Project } from './project';
import { ErrorService } from './errors';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  testSeries: EquivalenceClassMap[];
  iecList: EquivalenceClassMap[];
  currentIecOffset: number;
  dataLoading: boolean;
  initialized: boolean;
  loggedOut: boolean = false;
  projectList: Project[];
  currentIec: number;

  constructor(
    private service: SeriesService,
    private errorS: ErrorService,
    // private route: ActivatedRoute,
    // private router: Router,
  ) {
    this.currentIecOffset = 0;
    this.dataLoading = false;
    this.initialized = false;
  }

  ngOnInit() {
    this.attemptLogin(window.location.search);

    this.service.getAvailableProjects("good").subscribe(
        items => this.projectList = items,
        error => this.handleError(error)
    );
  }

  private handleError(error) {
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

  choose(a: Project) {
    // console.log(a);
    this.service.selectedProject = a;
    // load images and route to series-component
    this.service.getAllUnreviewed().subscribe(
        things => {
            this.iecList = things;
            this.initialized = true;
            this.updateDisplay(this.getCurrentIec());
        }, error => this.handleError(error));
  }

  reset() {
    console.log("resetting");
    this.initialized = false;
    this.iecList = null;
    this.currentIecOffset = 0;
  }

  getCurrentIec(offset: number = 0): number {
      return this.iecList[this.currentIecOffset].image_equivalence_class_id;
  }

  markGood() {
    this.service.markGood(this.getCurrentIec()).subscribe(
      resp => console.log("marked good confirmed"),
      error => this.handleError(error)
    );
    this.moveForward();
  }
  markBad() {
    this.service.markBad(this.getCurrentIec()).subscribe(
      resp => console.log("marked bad confirmed"),
      error => this.handleError(error)
    );
    this.moveForward();
  }
  markUgly() {
    this.service.markUgly(this.getCurrentIec()).subscribe(
      resp => console.log("marked ugly confirmed"),
      error => this.handleError(error)
    );
    this.moveForward();
  }
  moveBackward() {
    if (this.currentIecOffset > 0) {
      this.currentIecOffset -= 1;
      this.updateDisplay(this.getCurrentIec());
    }
  }
  fetchMoreData() {
    if (this.dataLoading) {
      return;
    }

    this.dataLoading = true;

    var currentIec: number = this.getCurrentIec();

    if (this.currentIecOffset >= this.iecList.length - 3) {
      this.service.getAllUnreviewed(this.iecList.length).subscribe(
        newList => {
          this.iecList = this.iecList.concat(newList);
          this.dataLoading = false;
        },
        error => this.handleError(error)
      );
    }

  }
  moveForward() {
    // load the next IEC into the viewer component

    this.currentIecOffset += 1;
    var currentIec: number = this.getCurrentIec();

    if (this.currentIecOffset >= this.iecList.length - 3) {
      this.fetchMoreData();
    }

    this.updateDisplay(currentIec);
  }

  updateDisplay(currentIec: number) {
    this.debugPrint();
    this.currentIec = currentIec;
  }

  debugPrint() {
    console.log("Current iecList Length: ", this.iecList.length);
    console.log("Current offset: ", this.currentIecOffset);
  }

  disableButtons(): boolean {
    if (this.iecList && this.currentIecOffset < this.iecList.length-1) {
      return false
    } else {
      return true;
    }
  }
  printAll() {
    this.errorS.announceError("Test error", "There is an error", 2);  
    this.errorS.announceError("Test error", "This is another error", 1);  
    console.log("Currently loaded IECs are as follows:");
    for (let s of this.iecList) {
      console.log(s.image_equivalence_class_id);
    }
  }

  navigate(where: String): void {
    console.log("navigate() called");
    if (where == "home") {
      this.reset();
    }
  }

}
