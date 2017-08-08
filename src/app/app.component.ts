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
  admin: boolean = false;


  // mostly old stuff below here
  loggedOut: boolean = false;

  public busy: Subscription;

  constructor(
    private service: SeriesService,
    private errorS: ErrorService,
  ) { }

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

  onNavigation(where: string): void {
    console.log("onNavigation() called");
    if (where == "home") {
      this.project = undefined;
      this.mode = undefined;
      this.admin = false;
    }
    if (where == "admin") {
      this.project = undefined;
      this.mode = undefined;
      this.admin = true;
    }
  }

  onModeChosen(mode: string) {
    console.log('from app.component, mode chosen: ', mode);
    this.mode = mode;
  }

  onProjectChosen(project: Project) {
    console.log('from app.component, project chosen: ', project);

    this.project = project;
    this.service.selectedProject = project;
  }

}
