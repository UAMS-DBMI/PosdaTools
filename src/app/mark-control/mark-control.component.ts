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
  @Input() mode: string;

  constructor(
    private service: SeriesService,

  ) { }

  ngOnInit() {
  }

  mark(state: string) {
    this.service.mark(this.iec, state).subscribe(
      resp => console.log("marked " + state + " confirmed"),
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
      this.mark('good');
    }
    if (event.key == '2' || event.key == 'b') {
      this.mark('bad');
    }
    if (event.key == '3' || event.key == 'l') {
      this.mark('blank');
    }
    if (event.key == '4' || event.key == 's') {
      this.mark('scout');
    }
    if (event.key == '3' || event.key == 'o') {
      this.mark('other');
    }
  }
}
