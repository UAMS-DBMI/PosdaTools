import { Component, Input, OnInit } from '@angular/core';
import { Router, ActivatedRoute, Params } from '@angular/router';

import { SeriesService } from '../series.service';
import { EquivalenceClassMap } from '../equivalence-class-map';


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
  }
  loadIEC(iec: number) {
    this.service.getSeries(iec)
  	  .subscribe(
      series => { 
        this.series = series;
        console.log(this.series);
      });
  }
  openPopup(): void {
  	window.open("/viewer/series/" + this.series.series_instance_uid,
                "Series Viewer", "height=600,width=600");

  }
}
