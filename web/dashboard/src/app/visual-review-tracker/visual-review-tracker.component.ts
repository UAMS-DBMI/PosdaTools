import { Component, OnInit } from '@angular/core';
import { ChartType, ChartOptions } from 'chart.js';
import { SingleDataSet, Label, monkeyPatchChartJsLegend, monkeyPatchChartJsTooltip } from 'ng2-charts';
import { ApiService } from '../api.service';
import {Vr} from "./Vr";
import {Vrs} from "./Vrs";
import {Vrpie} from "./Vrpie";
import { Subscription, timer } from 'rxjs';
import { switchMap } from 'rxjs/operators';

@Component({
  selector: 'app-visual-review-tracker',
  templateUrl: './visual-review-tracker.component.html',
  styleUrls: ['./visual-review-tracker.component.css']
})
export class VisualReviewTrackerComponent implements OnInit {
  public ready:boolean = false;
  public pieChartData: number[];
  public pieChartLabels: Label[];
  public pieChartLegend = true;
  public pieChartType = 'pie';
  public pieChartPlugins = [];
  public pieChartOptions: ChartOptions = {
    responsive: true,
  };
  private refresher: Subscription;
  private legends:string[] = [];
  private slices:number[] = [];
  private pies:Vrpie[] = [];

  constructor(private myService: ApiService){
    monkeyPatchChartJsTooltip();
    monkeyPatchChartJsLegend();
  }

  ngOnInit() {

    this.refresher = timer(0, (1000 * 60 * 10)).pipe(
      switchMap(() => this.myService.get_visual_review_in_progress())
    ).subscribe(rows => this.getData(rows));

    //this.pieChartData = this.slices
  //  this.pieChartLabels = this.legends;
    this.ready = true;
  }
    getData(mydataset:Vr[]){
      for (let item of mydataset){
        this.refresher = timer(0, (1000 * 60 * 3)).pipe(
          switchMap(() => this.myService.get_visual_review_status(item.visual_review_instance_id))
        ).subscribe(rows => this.setData(rows));
      }
    }

  setData(mydataset:Vrs[]){
    //this.pies = mydataset;
    var x = 0;

    for (let item of mydataset){
      console.log("item is " + item );
      console.log("x is " + x );
      console.log("item.visual_review_instance_id is " + item.visual_review_instance_id );
      if (item.visual_review_instance_id == x){
        this.legends.push(item.processing_status);
        this.slices.push(item.summary);
      }else{
        this.pies.push(new Vrpie(item.visual_review_instance_id ,this.legends,this.slices));
        x = item.visual_review_instance_id;
        this.legends = [];
        this.slices = [];
        this.legends.push(item.processing_status);
        this.slices.push(item.summary);
      }
    }
  }

}
