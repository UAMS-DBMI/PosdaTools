import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import {Bsbu} from "./bsbu";

@Component({
  selector: 'app-bsbu',
  templateUrl: './bsbu.component.html',
  styleUrls: ['./bsbu.component.css']
})
export class BSBUComponent implements OnInit {

  public my_bsbu:Bsbu[];
  constructor(private myService: ApiService) { }

  ngOnInit() {
    console.log("bsbu init");
    this.myService.get_background_subprocess_stats_by_user_this_week()
     .subscribe(rows => this.my_bsbu=rows);
  }

}
