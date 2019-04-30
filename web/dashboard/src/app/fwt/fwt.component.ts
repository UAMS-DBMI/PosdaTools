import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import {Fwt} from "./fwt";
import { Subscription, timer } from 'rxjs';
import { switchMap } from 'rxjs/operators';

@Component({
  selector: 'app-fwt',
  templateUrl: './fwt.component.html',
  styleUrls: ['./fwt.component.css']
})
export class FwtComponent implements OnInit {
private refresher: Subscription;

  public my_fwt:Fwt[];
  constructor(private myService: ApiService) { }

  ngOnInit() {
    this.refresher = timer(0, (1000 * 60 * 5)).pipe(
    switchMap(() => this.myService.getFilesWithoutType())
  ).subscribe(rows => this.my_fwt=rows);
  }

}
