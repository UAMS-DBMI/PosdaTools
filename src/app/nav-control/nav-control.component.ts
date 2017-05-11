import { Component, OnInit, Input, HostListener } from '@angular/core';
import { Project } from '../project';
import { SeriesService } from '../series.service';
import { EquivalenceClassMap } from '../equivalence-class-map';

import { Subscription } from 'rxjs';

@Component({
  selector: 'app-nav-control',
  templateUrl: './nav-control.component.html',
  styleUrls: ['./nav-control.component.css']
})
export class NavControlComponent implements OnInit {
  @Input() project: Project;
  @Input() mode: string;

  iec: EquivalenceClassMap;
  history: EquivalenceClassMap[] = [];
  busy: Subscription;


  constructor(private service: SeriesService) { }

  ngOnInit() {
    //TODO: get list of images to review, feed them into app-projection
    console.log('nav-control init');
    // this.iec = 4;
    this.fetchMoreData();
  }

  fetchMoreData() {
    this.busy = this.service.getNextUnreviewed(this.iec).subscribe(
      data => {
        console.log('fetchMoreData got: ', data);
        if (this.iec !== undefined) {
          this.history.push(this.iec);
        }
        this.iec = data[0];
      },
      error => this.handleError(error)
    );

    return this.busy;
  }

  onMark() {
    console.log('nav-control detected mark');
    this.moveForward();
  }


  moveForward() {
    console.log('moveForward()');
    this.fetchMoreData();
  }

  moveBackward() {
    console.log('moveBackward()');
    this.iec = this.history.pop();
  }

  @HostListener('document:keydown', ['$event'])
  handleKeyboardEvent(event: KeyboardEvent) {
    if (event.key == 'ArrowRight') {
      this.moveForward();
    }
    if (event.key == 'ArrowLeft') {
      this.moveBackward();
    }
  }

  handleError(error: any) {
    console.log(error);
  }
}
