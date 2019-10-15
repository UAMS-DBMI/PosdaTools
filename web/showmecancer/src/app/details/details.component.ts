import { Component, OnInit, Inject } from '@angular/core';
import { FileService } from '../file.service';
import { MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material';
import { ImageDetails } from '../image-details';

@Component({
  selector: 'app-details',
  templateUrl: './details.component.html',
  styleUrls: ['./details.component.css']
})
export class DetailsComponent implements OnInit {
  public error: string;
  public details: ImageDetails;

  constructor(
    public dialogRef: MatDialogRef<DetailsComponent>,
      @Inject(MAT_DIALOG_DATA) public data: number,
      private service: FileService) { }

  ngOnInit() {
    this.service.getDetails(this.data).subscribe(
      data => this.details = data,
      error => console.log(error)
    );
  }

  handleError() {
    this.error = "Error retreiving details :(";
    this.details = undefined;
  }
}
