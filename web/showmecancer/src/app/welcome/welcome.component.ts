import { Component, OnInit } from '@angular/core';
import gtvs from "./gtvs.json";
import { Router } from '@angular/router';

@Component({
  selector: 'app-welcome',
  templateUrl: './welcome.component.html',
  styleUrls: ['./welcome.component.css']
})
export class WelcomeComponent {
  private series_lists = {};
  public body_parts: string[] = [];

  constructor(private router: Router){
    for(let series of gtvs){
      if(this.series_lists.hasOwnProperty(series.body_part_examined) === false){
        this.series_lists[series.body_part_examined] = [];
        this.body_parts.push(series.body_part_examined);
      }
      this.series_lists[series.body_part_examined].push(series.series_instance_uid);
    }
  }

  random_int(max:number): number {
    max = Math.floor(max);
    return Math.floor(Math.random() * max);
  }

  random_series(body_part: string){
    let series = this.series_lists[body_part][this.random_int(this.series_lists[body_part].length)];
    this.router.navigate(['/series/' + series]);
  }
}
