import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import {Fwt} from "./fwt";

@Component({
  selector: 'app-fwt',
  templateUrl: './fwt.component.html',
  styleUrls: ['./fwt.component.css']
})
export class FwtComponent implements OnInit {

  public my_fwt:Fwt[];
  constructor(private myService: ApiService) { }

  ngOnInit() {
    console.log("fwt init");
    this.myService.getFilesWithoutType()
     .subscribe(rows => this.my_fwt=rows);
  }

}
