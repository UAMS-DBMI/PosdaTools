import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import {Prbs} from "./prbs";
import { Subscription, timer } from 'rxjs';
import { switchMap } from 'rxjs/operators';

@Component({
  selector: 'app-prbs',
  templateUrl: './prbs.component.html',
  styleUrls: ['./prbs.component.css']
})
export class PRBSComponent implements OnInit {
  private refresher: Subscription;

  public my_prbs:Prbs[];
  constructor(private myService: ApiService) { }

  ngOnInit() {
    this.refresher = timer(0, 10000).pipe(
      switchMap(() => this.myService.get_possiblyRunningBackgroundSubprocesses())
    ).subscribe(rows => this.my_prbs=rows);
  }

  ngOnDestory() {
    this.refresher.unsubscribe();
  }
}
