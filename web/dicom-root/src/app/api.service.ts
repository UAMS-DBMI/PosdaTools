import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { Submission} from './root-table-viewer/submission';
import { RootTableViewerComponent } from './root-table-viewer/root-table-viewer.component';

@Injectable({
  providedIn: 'root'
})
export class ApiService {

  constructor(
  private http: HttpClient,
  ) { }

  searchRootsWithOneParam(param1,param2):Observable<Submission[]>{
    var url = '/papi/v1/dicom_roots/searchRootsWithOneParam/'+ param1 + '/' + param2;
    return this.http.get<Submission[]>(url);
  }

  searchRootsWithTwoParams(param1,param2,param3,param4):Observable<Submission[]>{
    var url = '/papi/v1/dicom_roots/searchRootsWithTwoParams/'+ param1 + '/' + param2 + '/' + param3 + '/' + param4;
    return this.http.get<Submission[]>(url);
  }

  searchAll():Observable<Submission[]>{
    var url = '/papi/v1/dicom_roots/searchAll';
    return this.http.get<Submission[]>(url);
  }



}
