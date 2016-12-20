import { Component } from '@angular/core';

import { Router, ActivatedRoute, Params } from '@angular/router';
import { SeriesService } from './series.service';
import { EquivalenceClassMap } from './equivalence-class-map';
import { Project } from './project';

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
  projectList: Project[];
  currentIec: number;

  constructor(
    private service: SeriesService,
    // private route: ActivatedRoute,
    // private router: Router,
  ) {
    this.currentIecOffset = 0;
    this.dataLoading = false;
    this.initialized = false;
  }

  ngOnInit() {

    this.service.getAvailableProjects("good").subscribe(
      items => this.projectList = items
    );
  }

  choose(a: Project) {
    console.log(a);
    this.service.selectedProject = a;
    // load images and route to series-component
	  this.service.getAllUnreviewed()
	  	.subscribe(things => {
        this.iecList = things;
        this.initialized = true;
        this.updateDisplay(this.getCurrentIec(this.currentIecOffset));
      });
  }

  getCurrentIec(offset: number): number {
      return this.iecList[offset].Image_equivalence_class_id;
  }

  markGood() {
    this.moveForward();
  }
  markBad() {
    this.moveForward();
  }
  markUgly() {
    this.moveForward();
  }
  moveBackward() {
    if (this.currentIecOffset > 0) {
      this.currentIecOffset -= 1;
      this.updateDisplay(this.getCurrentIec(this.currentIecOffset));
    }
  }
  fetchMoreData() {
    if (this.dataLoading) {
      return;
    }

    this.dataLoading = true;

    var currentIec: number = this.getCurrentIec(this.currentIecOffset);
    var maxIec: number = this.iecList[this.iecList.length-1].Image_equivalence_class_id;

    if (this.currentIecOffset >= this.iecList.length - 3) {
      this.service.getAllUnreviewed(maxIec).subscribe(
        newList => {
          this.iecList = this.iecList.concat(newList);
          this.dataLoading = false;
        }
      )
    }

  }
  moveForward() {
    // load the next IEC into the viewer component

    this.currentIecOffset += 1;
    var currentIec: number = this.getCurrentIec(this.currentIecOffset);

    if (this.currentIecOffset >= this.iecList.length - 3) {
      this.fetchMoreData();
    }

    this.updateDisplay(currentIec);
  }

  updateDisplay(currentIec: number) {
    this.debugPrint();
    this.currentIec = currentIec;
    // this.service.getSeries(currentIec).subscribe(
    //   series => console.log(series.Image_equivalence_class_id)
    // );
    // this.router.navigate(['/iec', currentIec]);
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
    console.log("Currently loaded IECs are as follows:");
    for (let s of this.iecList) {
      console.log(s.Image_equivalence_class_id);
    }
  }

}
