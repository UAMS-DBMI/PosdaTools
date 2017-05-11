import { Injectable } from '@angular/core';
import { Http, Response, RequestOptions, URLSearchParams } from '@angular/http';

import { Observable } from 'rxjs/Observable';

import { EquivalenceClassMap } from './equivalence-class-map';
import { Project } from './project';

import 'rxjs/add/operator/map';

@Injectable()
export class SeriesService {
  private url = '/api';

  public currentIec: number;
  public iecList: EquivalenceClassMap[];

  public selectedProject: Project;
  public token: string;
  public mode: string;

  private options = new RequestOptions();


  constructor(private http: Http) { 
    this.loadToken();
  }

  loadToken() {
    this.token = localStorage.getItem('token');
  }

  setToken(token: string) {
    this.token = token;
    localStorage.setItem('token', token);
  }

  getSeries(iec: number): Observable<EquivalenceClassMap> {
      let params: URLSearchParams = new URLSearchParams();
      params.set("token", this.token);
      this.options.search = params;

      let url = this.url + '/details/' + iec;
      return this.http.get(url, this.options).map(res => res.json());
  }

  getAllUnreviewed(offset: number = 0): Observable<EquivalenceClassMap[]> {
      let params: URLSearchParams = new URLSearchParams();
      params.set("project", this.selectedProject.project_name);
      params.set("site", this.selectedProject.site_name);
      params.set("offset", String(offset));
      params.set("token", this.token);
      this.options.search = params;

      let url = this.url + '/set/' + this.mode;

      return this.http.get(url, this.options).map(res => res.json());
  }

  getNextUnreviewed(after: EquivalenceClassMap): Observable<EquivalenceClassMap> {
      let offset: number = 0;
      if (after !== undefined) {
        offset = after.image_equivalence_class_id;
      }

      let params: URLSearchParams = new URLSearchParams();
      params.set("project", this.selectedProject.project_name);
      params.set("site", this.selectedProject.site_name);
      params.set("offset", String(offset));
      params.set("token", this.token);
      this.options.search = params;

      let url = this.url + '/set/' + this.mode;

      return this.http.get(url, this.options).map(res => res.json());
  }



  getAvailableProjects(type: string): Observable<any> {
      let params: URLSearchParams = new URLSearchParams();
      params.set("token", this.token);
      this.options.search = params;

      let url = this.url + '/projects/' + type;
      return this.http.get(url, this.options)
      .map(res => res.json());
  }

  private mark(iec: number, state: string): Observable<any> {
    console.log("SeriesService.mark()");
    let url = this.url + '/save';
    return this.http.post(url, { iec, state, 'token': this.token })
      .map(res => res.json());
  }

  public markGood(iec: number): Observable<any> {
    return this.mark(iec, "good");
  }

  public markBad(iec: number): Observable<any> {
    return this.mark(iec, "bad");
  }

  public markUgly(iec: number): Observable<any> {
    return this.mark(iec, "broken");
  }

}
