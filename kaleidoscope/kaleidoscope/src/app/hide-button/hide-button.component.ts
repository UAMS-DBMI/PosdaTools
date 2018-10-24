import { Component, OnInit, Input, EventEmitter, Output } from '@angular/core';

@Component({
  selector: 'app-hide-button',
  templateUrl: './hide-button.component.html',
  styleUrls: ['./hide-button.component.css']
})
export class HideButtonComponent implements OnInit {
  @Input() what: string;
  @Input() type: string = "btn-primary";
  @Input() message: string = "Hide all records for ";
  @Output() onConfirm = new EventEmitter<string>();
  public clicked: boolean = false;

  constructor() { }

  ngOnInit() {
  }

  onClick() {
    this.clicked = true;
  }

  onClickYes() {
    this.clicked = false;
    this.onConfirm.emit(this.what);
  }

  onClickNo() {
    this.clicked = false;
  }


}
