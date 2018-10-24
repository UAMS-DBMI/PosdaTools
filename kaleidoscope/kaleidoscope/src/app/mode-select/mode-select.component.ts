import { Component, EventEmitter, Output, OnInit } from '@angular/core';

import { EquivalenceClassMap } from '../equivalence-class-map';
import { Project } from '../project';
import { ErrorService } from '../errors';


@Component({
  selector: 'app-mode-select',
  templateUrl: './mode-select.component.html',
  styleUrls: ['./mode-select.component.css']
})
export class ModeSelectComponent implements OnInit {
  @Output() onProjectChosen = new EventEmitter<Project>();
  @Output() onModeChosen = new EventEmitter<string>();
  public mode: string;

  constructor(
    private errorS: ErrorService,
  ) { }

  ngOnInit() { }

  public setMode(mode: string): void {
    this.mode = mode;
    this.onModeChosen.emit(mode);
  }
}
