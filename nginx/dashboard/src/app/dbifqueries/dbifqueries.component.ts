import { Component, OnInit, Input } from '@angular/core';
import { ApiService } from '../api.service';
import {Slow_dbif_queries_class} from "./slow_dbif_queries_class";

@Component({
  selector: 'app-dbifqueries',
  templateUrl: './dbifqueries.component.html',
  styleUrls: ['./dbifqueries.component.css']
})

export class DBIFqueriesComponent implements OnInit {

  @Input() days: string;

  public my_slow_queries:Slow_dbif_queries_class[];
  constructor(private myService: ApiService) { }

  ngOnInit() {
    console.log("dbifqueries init");
    this.myService.get_slow_dbif_query(this.days)
     .subscribe(rows => this.my_slow_queries=rows);
  }



}
