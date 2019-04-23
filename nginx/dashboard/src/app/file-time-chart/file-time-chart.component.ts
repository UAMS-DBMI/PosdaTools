import { Component, OnInit, ViewChild } from '@angular/core';
import { ChartDataSets, ChartOptions } from 'chart.js';
import { Color, Label } from 'ng2-charts';
import { ApiService } from '../api.service';
import {Ftc} from "./ftc";

@Component({
  selector: 'app-file-time-chart',
  templateUrl: './file-time-chart.component.html',
  styleUrls: ['./file-time-chart.component.css']
})
export class FileTimeChartComponent implements OnInit {
  public ready:boolean = false;
  private dataset:Ftc[];
  public lineChartData: ChartDataSets[];
  public lineChartLabels: Label[];
  public lineChartColors: Color[] = [
    {
      borderColor: 'black',
      backgroundColor: 'rgba(200,50,5,0.3)',
    },
  ];
  public lineChartLegend = true;
  public lineChartType = 'line';
  public lineChartPlugins = [];
  public lineChartOptions: (ChartOptions & { responsive: any }) = {
    responsive: true,
  };

  constructor(private myService: ApiService){ }

  ngOnInit() {

    console.log("ftc init");
    this.myService.get_file_time_chart()
     .subscribe(rows => this.setData(rows));
  }

  setData(mydataset:Ftc[]){
    var files:number[] = [];
    var dates:string[] = [];
    var fileCount = 0;
    for (let item of mydataset){
      fileCount += item.count;
      files.push(fileCount);
      dates.push(item.importmonth+"/"+item.importyear);
    }
    this.dataset = mydataset;
    this.lineChartData = [{data: files,label: 'Files'}];
    this.lineChartLabels = dates;
    this.ready = true;
  }

}
