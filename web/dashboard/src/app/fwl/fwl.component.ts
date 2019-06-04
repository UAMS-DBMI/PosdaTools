import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import {Fwl} from "./fwl";
import { Subscription, timer } from 'rxjs';
import { switchMap } from 'rxjs/operators';

@Component({
  selector: 'app-fwl',
  templateUrl: './fwl.component.html',
  styleUrls: ['./fwl.component.css']
})
export class FwlComponent implements OnInit {
private refresher: Subscription;

  public my_fwl:Fwl[];
  constructor(private myService: ApiService) { }

  ngOnInit() {
    this.refresher = timer(0, (1000 * 60 * 5)).pipe(
    switchMap(() => this.myService.getFilesWithoutLocation())
  ).subscribe(rows => this.my_fwl=rows);
  }

}
