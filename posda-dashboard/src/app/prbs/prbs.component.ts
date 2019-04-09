import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import {Prbs} from "./prbs";

@Component({
  selector: 'app-prbs',
  templateUrl: './prbs.component.html',
  styleUrls: ['./prbs.component.css']
})
export class PRBSComponent implements OnInit {

  public my_prbs:Prbs[];
  constructor(private myService: ApiService) { }

  ngOnInit() {
    console.log("prbs init");
    this.myService.get_possiblyRunningBackgroundSubprocesses()
     .subscribe(rows => this.my_prbs=rows);
  }

}
