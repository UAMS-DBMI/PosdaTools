import { Component, Input, OnInit } from '@angular/core';
import { Router, ActivatedRoute, Params } from '@angular/router';

import { SeriesService } from '../series.service';
import { EquivalenceClassMap } from '../equivalence-class-map';

@Component({
  selector: 'app-projection',
  templateUrl: './projection.component.html',
  styleUrls: ['./projection.component.css']
})
export class ProjectionComponent implements OnInit {
  @Input() public series: EquivalenceClassMap;

  constructor(
    private service: SeriesService
  ) { }

  ngOnInit() {
  }
  openPopup(): void {
  	window.open("/viewer/series/" + this.series.series_instance_uid,
                "Series Viewer", "height=600,width=600");

  }
  openPopupIec(): void {
  	window.open("/viewer/iec/" + this.series.image_equivalence_class_id,
                "Series Viewer", "height=600,width=600");
  }

}
