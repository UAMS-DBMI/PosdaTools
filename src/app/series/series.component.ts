import { Component, Input, OnInit } from '@angular/core';
import { Router, ActivatedRoute, Params } from '@angular/router';

import { SeriesService } from '../series.service';
import { EquivalenceClassMap } from '../equivalence-class-map';

import 'rxjs/add/operator/switchMap';

@Component({
  selector: 'app-series',
  templateUrl: './series.component.html',
  styleUrls: ['./series.component.css']
})
export class SeriesComponent implements OnInit {
  @Input()
  set iec(iec: number) {
    console.log("was given IEC: ", iec);
    this.loadIEC(iec);  
  }

  public series: EquivalenceClassMap;

  constructor(
    private service: SeriesService
  ) { }

  ngOnInit() {
    // this.route.params
    //   .switchMap((params: Params) => this.service.getSeries(+params['id']))
	  // .subscribe(series => {
		//   this.series = series;
	  // });
  }
  loadIEC(iec: number) {
    this.service.getSeries(iec)
  	  .subscribe(
        series => this.series = series
      );
  }
}
