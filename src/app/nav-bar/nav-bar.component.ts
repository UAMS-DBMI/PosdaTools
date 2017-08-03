import { Component, EventEmitter, Output, OnInit, Input } from '@angular/core';
import { Project } from '../project';

@Component({
  selector: 'app-nav',
  templateUrl: './nav-bar.component.html',
  styleUrls: ['./nav-bar.component.css']
})
export class NavBarComponent implements OnInit {
  @Output() onNavigation = new EventEmitter<String>();
  @Input() mode: string;
  @Input() project: Project;

  constructor() { }

  ngOnInit() {
  }

  home() {
    this.onNavigation.emit('home');
    console.log("emitting onNavigation => 'home'");
  }
  admin() {
    this.onNavigation.emit('admin');
    console.log("emitting onNavigation => 'admin'");
  }

}
