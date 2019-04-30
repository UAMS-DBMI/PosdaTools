import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import {Tla} from "./Tla";
import { Subscription, timer } from 'rxjs';
import { switchMap } from 'rxjs/operators';


@Component({
  selector: 'app-table-lock-alert',
  templateUrl: './table-lock-alert.component.html',
  styleUrls: ['./table-lock-alert.component.css']
})
export class TableLockAlertComponent implements OnInit {
  private refresher: Subscription;

  public my_tla:Tla[];
  constructor(private myService: ApiService) { }

  ngOnInit() {
    this.refresher = timer(0, 10000).pipe(
      switchMap(() => this.myService.table_lock_alert())
    ).subscribe(rows => this.my_tla=rows);
  }
  
  ngOnDestory() {
    this.refresher.unsubscribe();
  }

}
