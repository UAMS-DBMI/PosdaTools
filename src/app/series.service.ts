import { Injectable } from '@angular/core';
import { Http, Response, RequestOptions, URLSearchParams } from '@angular/http';

import { Observable } from 'rxjs/Observable';

import { EquivalenceClassMap } from './equivalence-class-map';
import { Project } from './project';
import { Subject} from "rxjs/Rx";

import 'rxjs/add/operator/map';

@Injectable()
export class SeriesService {
  private url = '/api';

  public currentIec: number;
  public iecList: EquivalenceClassMap[];

  public selectedProject: Project;
  public token: string;
  public mode: string;
  public dicom_file_type = new Subject<string>();
  public visual_review_instance_id: string;

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

  setDicom_File_Type(value: string){
    //publish this value to all the subscribers that have already subscribed to this
    console.log("series.service.ts: setDicom_File_Type");
    console.log("value: " + value);
    this.dicom_file_type.next(value);
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

  getNextUnreviewed(after: EquivalenceClassMap, dicom_file_type: string, visual_review_instance_id: string): Observable<EquivalenceClassMap> {
      let offset: number = 0;
      if (after !== undefined) {
        offset = after.image_equivalence_class_id;
      }

      let params: URLSearchParams = new URLSearchParams();
      if (this.selectedProject) {
        params.set("project", this.selectedProject.project_name);
        params.set("site", this.selectedProject.site_name);
      }
      params.set("dicom_file_type", dicom_file_type);
      params.set("visual_review_instance_id", visual_review_instance_id);
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

  getPatients(state: string, project: Project) {
      let params: URLSearchParams = new URLSearchParams();
      params.set("token", this.token);
      this.options.search = params;

    let url = this.url + '/patients/' + project.project_name + '/' + project.site_name + '/' + state;;
      return this.http.get(url, this.options)
      .map(res => res.json());
  }

  mark(iec: number, state: string): Observable<any> {
    console.log("SeriesService.mark()");
    let url = this.url + '/save';
    return this.http.post(url, { iec, state, 'token': this.token })
      .map(res => res.json());
  }

  hideProject(project: Project) {
    let params: URLSearchParams = new URLSearchParams();
    params.set("token", this.token);
    this.options.search = params;

    let url = this.url + '/hide/collection/' + project.project_name + '/' + project.site_name;
      return this.http.get(url, this.options)
      .map(res => res.json());
  }
  hidePatient(project: Project, patient: string) {
    let params: URLSearchParams = new URLSearchParams();
    params.set("token", this.token);
    this.options.search = params;

    let url = this.url + '/hide/patient/' + project.project_name + '/' + project.site_name + '/' + patient;
      return this.http.get(url, this.options)
      .map(res => res.json());
  }
  unhideProject(project: Project) {
    let params: URLSearchParams = new URLSearchParams();
    params.set("token", this.token);
    this.options.search = params;

    let url = this.url + '/unhide/collection/' + project.project_name + '/' + project.site_name;
      return this.http.get(url, this.options)
      .map(res => res.json());
  }
  unhidePatient(project: Project, patient: string) {
    let params: URLSearchParams = new URLSearchParams();
    params.set("token", this.token);
    this.options.search = params;

    let url = this.url + '/unhide/patient/' + project.project_name + '/' + project.site_name + '/' + patient;
      return this.http.get(url, this.options)
      .map(res => res.json());
  }
}
