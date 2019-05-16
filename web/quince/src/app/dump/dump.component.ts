import { Component, OnInit, Inject } from '@angular/core';
import { FileService } from '../file.service';
import { MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material';

@Component({
  selector: 'app-dump',
  templateUrl: './dump.component.html',
  styleUrls: ['./dump.component.css']
})
export class DumpComponent implements OnInit {
  public text: string;
  public busy: boolean = true;

  constructor(
    public dialogRef: MatDialogRef<DumpComponent>,
      @Inject(MAT_DIALOG_DATA) public data: number,
      private service: FileService) { }

  ngOnInit() {
    this.service.getDump(this.data).subscribe(
      res => {
        this.text = res;
        this.busy = false;
      },
      error => {
        this.text = error;
        this.busy = false;
      }
    );
  }

}
