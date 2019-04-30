import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import {Bsbu} from "./bsbu";
import { Subscription, timer } from 'rxjs';
import { switchMap } from 'rxjs/operators';

@Component({
  selector: 'app-bsbu',
  templateUrl: './bsbu.component.html',
  styleUrls: ['./bsbu.component.css']
})
export class BSBUComponent implements OnInit {
  private refresher: Subscription;
  public my_bsbu:Bsbu[];
  constructor(private myService: ApiService) { }

  ngOnInit() {
    this.refresher = timer(0, (1000 * 60 * 5)).pipe(
      switchMap(() => this.myService.get_background_subprocess_stats_by_user_this_week())
    ).subscribe(rows => this.my_bsbu=rows);
  }


}
