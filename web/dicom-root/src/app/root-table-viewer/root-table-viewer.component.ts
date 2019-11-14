import { Component, OnInit,ViewChild } from '@angular/core';
import {FormControl, ReactiveFormsModule, FormGroupDirective, NgForm, Validators, FormGroup, FormBuilder} from '@angular/forms';
import {Submission} from './submission';
import { ApiService, Search } from '../api.service';
import {MatTableDataSource} from '@angular/material/table';
import {MatSort} from '@angular/material/sort';



@Component({
  selector: 'app-root-table-viewer',
  templateUrl: './root-table-viewer.component.html',
  styleUrls: ['./root-table-viewer.component.css']
})
export class RootTableViewerComponent implements OnInit {

  public selected1 = "site_name";
  public selected2 = "collection_name";
  private input1 = "";
  private input2 = "";
  public results;
  public addMode = false;
  public newSiteWarn = "";
  public newCollWarn = "";
  public AdditionFeedback = "";

  public searchFormControl1 = new FormControl('', [
    //Validators.required
  ]);
  public searchFormControl2 = new FormControl('', [
    //Validators.required
  ]);

  public myNewRootForms:FormGroup;
  //private columnsToDisplay:String[] = ["collection_code"];
  public columnsToDisplay:String[] = ["site_code","site_name","collection_code","collection_name","patient_id_prefix","body_part","access_type","baseline_date","date_shift"];

  @ViewChild(MatSort, {static: false}) sort: MatSort;

  constructor(private myService: ApiService, private formBuilder: FormBuilder) {
    this.myNewRootForms = formBuilder.group({
      input_site_code: new FormControl ('',[Validators.required]),
      input_site_name: new FormControl('',[Validators.required]),
      input_collection_code: new FormControl('',[Validators.required]),
      input_collection_name: new FormControl('',[Validators.required]),
      input_patient_id_prefix: '',
      input_body_part: '',
      input_access_type: '',
      input_baseline_date: '',
      input_date_shift: '',
    });
  }

  ngOnInit() {
    //this.myNewRootForms.valueChanges.subscribe(val => {
    // console.log(val);
    //});
    this.showAll();
    this.onChanges();
  }

  onChanges(): void {
    this.myNewRootForms.get('input_site_code').valueChanges.subscribe(val => {
      if(val.length == 4){
        this.myService.findSiteNameFromCode(val).subscribe(
          text => {
              this.myNewRootForms.get('input_site_name').setValue(text);
              this.newSiteWarn = "";
            },
          err =>  this.newSiteWarn = "This will create a new Site!"
        );
      }
    });

    this.myNewRootForms.get('input_collection_code').valueChanges.subscribe(val => {
      if(val.length == 4){
        this.myService.findCollectionNameFromCode(val).subscribe(
          text => {
              this.myNewRootForms.get('input_collection_name').setValue(text);
              this.newSiteWarn = "";
            },
          err => this.newCollWarn = "This will create a new Collection!",
        );
      }
    });
  }

  public performSearch(){
    var searches:Search[] = [];
    var param1 = this.selected1;
    var param2 = this.searchFormControl1.value + '%';
    searches.push(new Search(param1, param2));
    var param3 = this.selected2;
    var param4 = this.searchFormControl2.value;
    if (param4 != undefined && param4 != ""){
      param4 = param4 + '%';
      searches.push(new Search(param3, param4));
    }
    this.myService.searchRootsQ(searches).subscribe(rows => this.setDataSource(rows));
  }

  public showAll(){
    this.myService.searchRoots().subscribe(rows => this.setDataSource(rows));
  }

  private setDataSource(results:Submission[]){
    this.results = new MatTableDataSource<Submission>(results);
    this.results.sort = this.sort;
  }

  public clear(){
    this.results = [];
    this.AdditionFeedback = "";
  }

  public enterAddMode(){
    this.addMode = true;
    if (this.myNewRootForms.contains("input_" + this.selected1) && this.searchFormControl1.value != '' && this.searchFormControl1.value.indexOf('%') == -1){
      this.myNewRootForms.get("input_" + this.selected1).setValue(this.searchFormControl1.value);
    }
    if (this.myNewRootForms.contains("input_" + this.selected2)  && this.searchFormControl2.value != '' && this.searchFormControl2.value.indexOf('%') == -1){
      this.myNewRootForms.get("input_" + this.selected2).setValue(this.searchFormControl2.value);
    }
  }

  public exitAddMode(){
    this.addMode = false;
    this.newCollWarn = "";
    this.newSiteWarn = "";
    this.AdditionFeedback = "";

  }

  public add(addForm){
    if (this.myNewRootForms.valid){
      //add submission
      this.myService.addNewSubmission(this.myNewRootForms.value).subscribe(
        success =>
          {
            this.exitAddMode();
            this.AdditionFeedback = "Success! Submission Added!";
          },
        err =>
          {
            this.exitAddMode();
            this.AdditionFeedback = "**ERROR**\n" + err.error.message;
          },
      )

    }else{
      this.AdditionFeedback = "**ERROR**\n Site Code, Site Name, Collection Code, and Colleciton Name are required." ;
    }
  }

  public check(){
    console.log("checking");
  }

}
