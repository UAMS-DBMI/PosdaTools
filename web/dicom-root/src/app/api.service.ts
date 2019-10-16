import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { Submission} from './root-table-viewer/submission';
import { RootTableViewerComponent } from './root-table-viewer/root-table-viewer.component';

export class Search {

  term: string;
  value: string;

  constructor(term, value){
    this.term = term;
    this.value = value;
  }
}

@Injectable({
  providedIn: 'root'
})
export class ApiService {

  constructor(
  private http: HttpClient,
  ) { }


  searchRootsQ(params: Search[]):Observable<Submission[]>{
    var http_params = new HttpParams();
    for (let p of params){
      http_params = http_params.set(p.term, p.value);
    }
    const options = { params: http_params };
    var url = '/papi/v1/dicom_roots/searchRoots';
    return this.http.get<Submission[]>(url, options);
  }


  searchRoots():Observable<Submission[]>{
    var url = '/papi/v1/dicom_roots/searchRoots';
    return this.http.get<Submission[]>(url);
  }

}
