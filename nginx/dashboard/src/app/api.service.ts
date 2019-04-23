import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import {Slow_dbif_queries_class} from './dbifqueries/slow_dbif_queries_class';
import {Prbs} from './prbs/prbs';
import {Bsbu} from './bsbu/bsbu';
import {Fwt} from './fwt/fwt';
import {Ftc} from './file-time-chart/ftc';

@Injectable({
  providedIn: 'root'
})
export class ApiService {

  constructor(
  private http: HttpClient,
  ) { }

  get_slow_dbif_query(days):Observable<Slow_dbif_queries_class[]>{
    var url = '/papi/v1/dashboard/slow_dbif_queries/'+ days;
    return this.http.get<Slow_dbif_queries_class[]>(url);
  }

  get_possiblyRunningBackgroundSubprocesses():Observable<Prbs[]>{
    var url = '/papi/v1/dashboard/prbs';
    return this.http.get<Prbs[]>(url);
  }

  get_background_subprocess_stats_by_user_this_week():Observable<Bsbu[]>{
    var url = '/papi/v1/dashboard/bsbu';
    return this.http.get<Bsbu[]>(url);
  }

  getFilesWithoutType():Observable<Fwt[]>{
    var url = '/papi/v1/dashboard/fwt';
    return this.http.get<Fwt[]>(url);
  }

  get_file_time_chart():Observable<Ftc[]>{
    var url = '/papi/v1/dashboard/ftc';
    return this.http.get<Ftc[]>(url);
  }


}
