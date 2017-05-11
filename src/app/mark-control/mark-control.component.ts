import { Component, OnInit, Input, Output, EventEmitter, HostListener } from '@angular/core';

import { SeriesService } from '../series.service';
import { EquivalenceClassMap } from '../equivalence-class-map';
import { Project } from '../project';

@Component({
  selector: 'app-mark-control',
  templateUrl: './mark-control.component.html',
  styleUrls: ['./mark-control.component.css']
})
export class MarkControlComponent implements OnInit {
  @Output() onMark = new EventEmitter<string>();
  @Input() iec: number;

  constructor(
    private service: SeriesService,

  ) { }

  ngOnInit() {
  }

  markGood() {
    this.service.markGood(this.iec).subscribe(
      resp => console.log("marked good confirmed"),
      error => this.handleError(error)
    );
    this.onMark.emit();
  }

  markBad() {
    this.service.markBad(this.iec).subscribe(
      resp => console.log("marked bad confirmed"),
      error => this.handleError(error)
    );
    this.onMark.emit();
  }
  markUgly() {
    this.service.markUgly(this.iec).subscribe(
      resp => console.log("marked ugly confirmed"),
      error => this.handleError(error)
    );
    this.onMark.emit();
  }

  handleError(error: any) {
    console.log(error);
  }

  @HostListener('document:keydown', ['$event'])
  handleKeyboardEvent(event: KeyboardEvent) {
    if (event.key == '1' || event.key == 'g') {
      this.markGood();
    }
    if (event.key == '2' || event.key == 'b') {
      this.markBad();
    }
    if (event.key == '3' || event.key == 'u') {
      this.markUgly();
    }
  }
}
