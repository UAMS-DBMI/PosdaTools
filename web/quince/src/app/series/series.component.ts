import { Component, OnInit } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Router, ActivatedRoute, Params } from '@angular/router';
import { FileService } from '../file.service';
import { timer } from 'rxjs';
import { CookieService } from 'ngx-cookie-service';

@Component({
  selector: 'app-series',
  templateUrl: './series.component.html',
  styleUrls: ['./series.component.css']
})
export class SeriesComponent implements OnInit {
  private series_instance_uid: string = '1.3.6.1.4.1.14519.5.2.1.7009.2401.339279835610748520609872183315';
  private iec_id: string;
  public show_download: boolean = false;
  private file_ids: number[];
  public current_offset: number;
  public current_file_id: number;
  public length: number = 500;

  private timerSub: any = undefined;
  private headers = new HttpHeaders({});
  private requestOptions = { headers: this.headers };

  constructor(private http: HttpClient,
              private route: ActivatedRoute,
              private router: Router,
              private cookieService: CookieService,
              private fileService: FileService
              ) { }

  ngOnInit() {
    let uid = this.route.snapshot.params['uid'];
    let activity_id = this.route.snapshot.queryParams['activity_id'];
    this.series_instance_uid = uid;

    if (uid === undefined) {
      let iec = this.route.snapshot.params['iec'];
      this.iec_id = iec;
      this.show_download = true;
      this.http.get(
        "/papi/v1/iecs/" + iec + "/files",
        this.requestOptions
      ).subscribe(
        res => this.handleResponse(res)
      );
    } else {
      console.log(activity_id);
      let url = "/papi/v1/series/" + this.series_instance_uid + "/files";

      if (activity_id !== undefined) {
        url = url + "?activity_id=" + activity_id;
      }
      this.show_download = true;

      this.fileService.getUrl(url).subscribe(
        res => this.handleResponse(res)
      );
    }
  }

  jumpTo(file_id: number): void {
    this.current_offset = this.file_ids.indexOf(file_id);
    this.current_file_id = file_id;
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
    if (this.timerSub == undefined) {
      let t = timer(1, 100);
      this.timerSub = t.subscribe(t => {
        this.moveNext();
      });
    }
  }

  stop(): void {
    if (this.timerSub != undefined) {
      this.timerSub.unsubscribe();
      this.timerSub = undefined;
    }
  }

  download_link(): string {
    if(this.iec_id !== undefined){
      return '/papi/v1/files/iec/' + this.iec_id;
    } else if(this.series_instance_uid !== undefined) {
      return '/papi/v1/files/series/' + this.series_instance_uid;
    }
  }
}
