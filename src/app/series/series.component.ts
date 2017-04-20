import { Component, OnInit } from '@angular/core';
import { Http } from '@angular/http';
import { Router, ActivatedRoute, Params } from '@angular/router';
import { Observable } from 'rxjs/Rx';

@Component({
  selector: 'app-series',
  templateUrl: './series.component.html',
  styleUrls: ['./series.component.css']
})
export class SeriesComponent implements OnInit {
  private series_instance_uid: string = '1.3.6.1.4.1.14519.5.2.1.7009.2401.339279835610748520609872183315';
  private file_ids: number[];
  public current_offset: number;
  public current_file_id: number;
  public length: number = 500;

  private timerSub: any;

  constructor(private http: Http, 
              private route: ActivatedRoute,
              private router: Router
              ) { }

  ngOnInit() {
    let uid = this.route.snapshot.params['uid'];
    this.series_instance_uid = uid;

    this.http.get("/vapi/series_info/" + this.series_instance_uid).subscribe(
      res => this.handleResponse(res.json())
    );
  }

  handleResponse(data: any): void {
    this.file_ids = data.file_ids;
    this.length = this.file_ids.length - 1;

    this.current_offset = 0;
    this.current_file_id = this.file_ids[this.current_offset];
  }

  onChange(event: any): void {
    let val = event.value;
    this.current_offset = val;
    this.current_file_id = this.file_ids[this.current_offset];
    // console.log(this.current_file_id);
  }

  moveNext(): void {
    this.current_offset += 1;
    if (this.current_offset > this.length) {
      this.current_offset = 0;
    }
    this.current_file_id = this.file_ids[this.current_offset];
  }

  movePrevious(): void {
    this.current_offset -= 1;
    if (this.current_offset < 0) {
      this.current_offset = this.length;
    }
    this.current_file_id = this.file_ids[this.current_offset];
  }

  play(): void {
    let timer = Observable.timer(1, 100);
    this.timerSub = timer.subscribe(t => {
      this.moveNext();
    });
  }

  stop(): void {
    this.timerSub.unsubscribe();
  }
}
