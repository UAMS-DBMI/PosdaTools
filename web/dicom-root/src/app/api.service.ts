import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { Submission} from './root-table-viewer/submission';
import { RootTableViewerComponent } from './root-table-viewer/root-table-viewer.component';


class CodeName {
  code: string;
  name: string;
}

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

  httpOptions = {
     headers: new HttpHeaders({
       'Content-Type':  'application/json',
     }
   )};

  constructor(private http: HttpClient) {

  }


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

  findSiteNameFromCode(sc: string){
    var url = '/papi/v1/dicom_roots/findSiteNameFromCode/' + sc;
    return this.http.get(url,{responseType: 'text'});
  }

  findCollectionNameFromCode(cc: string){
    var url = '/papi/v1/dicom_roots/findCollectionNameFromCode/' + cc;
    return this.http.get(url,{responseType: 'text'});
  }

  addNewSite(code:string, name:string){
    var url = '/papi/v1/dicom_roots/addNewSite';
    let c = {code: code, name: name};
    return this.http.post(url,c,this.httpOptions);
  }

  addNewCollection(code:string, name:string){
    var url = '/papi/v1/dicom_roots/addNewCollection';
    let c = {code: code, name: name};
    return this.http.post(url,c,this.httpOptions);
  }

  addNewSubmission(form:any){
    //var url = '/papi/v1/dicom_roots/addNewSubmission/' + sc + '/' + cc + '/' + pip + '/' + bp + '/' + at + '/' + bd + '/' + ds;
    var url = '/papi/v1/dicom_roots/addNewSubmission'
    return this.http.post(url,form,this.httpOptions);
  }
}
