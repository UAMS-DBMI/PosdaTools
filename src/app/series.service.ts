import { Injectable } from '@angular/core';
import { Http, Response} from '@angular/http';

import { Observable } from 'rxjs/Observable';

import { EquivalenceClassMap } from './equivalence-class-map';
import { Project } from './project';

import 'rxjs/add/operator/map';

@Injectable()
export class SeriesService {
  private url = 'api';

  public currentIec: number;
  public iecList: EquivalenceClassMap[];

  public selectedProject: Project;


  constructor(private http: Http) { }


  getSeries(iec: number): Observable<any> {
	  return this.http.get(this.url + '/details/' + iec).map(res => res.json());
  }

  getAllUnreviewed(after: number = 0): Observable<EquivalenceClassMap[]> {
	  return this.http.get(`${this.url}/set/good?project=${this.selectedProject.Project_name}`
      + `&site=${this.selectedProject.Site_name}&after=${after}`).map(res => res.json());
  }

  getAvailableProjects(type: string) {
	  return this.http.get(this.url + '/projects/' + type)
      .map(res => res.json());
  }

}
