import { Component, OnInit } from '@angular/core';
import {FormControl, ReactiveFormsModule, FormGroupDirective, NgForm, Validators} from '@angular/forms';
import {ErrorStateMatcher} from '@angular/material/core';
import {Submission} from './submission';
import { ApiService } from '../api.service';

/** Error when invalid control is dirty, touched, or submitted. From material website */
export class MyErrorStateMatcher implements ErrorStateMatcher {
  isErrorState(control: FormControl | null, form: FormGroupDirective | NgForm | null): boolean {
    const isSubmitted = form && form.submitted;
    return !!(control && control.invalid && (control.dirty || control.touched || isSubmitted));
  }
}

@Component({
  selector: 'app-root-table-viewer',
  templateUrl: './root-table-viewer.component.html',
  styleUrls: ['./root-table-viewer.component.css']
})
export class RootTableViewerComponent implements OnInit {

  private selected1 = "collection_name"
  private selected2 = "site_name"
  private input1 = "";
  private input2 = "";
  private matcher = new MyErrorStateMatcher();
  private results:Submission[];
  private searchFormControl1 = new FormControl('', [
    //Validators.required
  ]);
  private searchFormControl2 = new FormControl('', [
    //Validators.required
  ]);

  constructor(private myService: ApiService) {
    this.results =[];
  }

  ngOnInit() {
  }



  public performSearch(){
    var param1 = this.selected1
    var param2 = this.searchFormControl1.value
    var param3 = this.selected2
    var param4 = this.searchFormControl2.value
    if (param4 == undefined || param4 == "")
      this.myService.searchRootsWithOneParam(param1,param2).subscribe(rows => this.results=rows);
    else
      this.myService.searchRootsWithTwoParams(param1,param2,param3,param4).subscribe(rows => this.results=rows);
  }

  public showAll(){
      this.myService.searchAll().subscribe(rows => this.results=rows);
  }
}
