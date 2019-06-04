import { Component, OnInit, Input } from '@angular/core';
import { ApiService } from '../api.service';
import {Slow_dbif_queries_class} from "./slow_dbif_queries_class";
import { Subscription, timer } from 'rxjs';
import { switchMap } from 'rxjs/operators';

@Component({
  selector: 'app-dbifqueries',
  templateUrl: './dbifqueries.component.html',
  styleUrls: ['./dbifqueries.component.css']
})

export class DBIFqueriesComponent implements OnInit {
  private refresher: Subscription;
  @Input() days: string;

  public my_slow_queries:Slow_dbif_queries_class[];
  constructor(private myService: ApiService) { }

  ngOnInit() {
    this.refresher = timer(0, (1000 * 60 * 5)).pipe(
      switchMap(() => this.myService.get_slow_dbif_query(this.days))
    ).subscribe(rows => this.my_slow_queries=rows);
  }



}
