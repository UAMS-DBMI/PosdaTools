import { Component, EventEmitter, Output, OnInit } from '@angular/core';

@Component({
  selector: 'app-nav',
  templateUrl: './nav.component.html',
  styleUrls: ['./nav.component.css']
})
export class NavComponent implements OnInit {
  @Output() onNavigation = new EventEmitter<String>();

  constructor() { }

  ngOnInit() {
  }

  home() {
    this.onNavigation.emit('home');
    console.log("emitting onNavigation => 'home'");
  }

}
