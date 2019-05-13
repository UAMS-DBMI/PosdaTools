import { Component, OnInit, Input } from '@angular/core';
import { ApiService } from '../api.service';
import {Qrvi} from "./Qrvi";
import { Subscription, timer } from 'rxjs';
import { switchMap } from 'rxjs/operators';
import { ChartDataSets, ChartOptions, ChartType } from 'chart.js';
import { Color, Label } from 'ng2-charts';

@Component({
  selector: 'app-qrvi',
  templateUrl: './qrvi.component.html',
  styleUrls: ['./qrvi.component.css']
})

export class QrviComponent implements OnInit {
  public ready:boolean = false;
  private dataset:Qrvi[];
  private refresher: Subscription;
  public scatterChartOptions: ChartOptions = {
    responsive: true,
    tooltips: {
     callbacks: {
       label: function(tooltipItem, data) {
                   var this_dot = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                   return this_dot.label + "\n  avg time:" + this_dot.x + "s called " + this_dot.y + " times."
                 },
     }
   }
  };
  public scatterChartData: ChartDataSets[] = [
    {
      data: [{x:0,y:0}],
      label: 'Series A',
      pointRadius: 10,
    },
  ];
  public scatterChartType: ChartType = 'scatter';

  constructor(private myService: ApiService) { }

  ngOnInit() {
    this.refresher = timer(0, (1000 * 60 * 5)).pipe(
      switchMap(() => this.myService.get_query_runtime_versus_invocations())
    ).subscribe(rows => this.setData(rows));
  }

  setData(mydataset:Qrvi[]){
    var dots = [];
    for (let item of mydataset){

      dots.push({x:item.avg_query_time, y:item.num_invocations,label:item.query_name});
    }
    this.dataset = mydataset;
    this.scatterChartData = [{data: dots, label: 'Query', pointRadius: 10}];
    this.ready = true;
  }

}
