import { Component, OnInit, Inject } from '@angular/core';
import { MdDialogRef, MD_DIALOG_DATA } from '@angular/material';
import { FileService } from '../file.service';

@Component({
  selector: 'app-dump',
  templateUrl: './dump.component.html',
  styleUrls: ['./dump.component.css']
})
export class DumpComponent implements OnInit {
  public text: string;

  constructor(
    public dialogRef: MdDialogRef<DumpComponent>,
      @Inject(MD_DIALOG_DATA) public data: number,
      private service: FileService) { }

  ngOnInit() {
    this.service.getDump(this.data).subscribe(
      res => this.text = res
    );
  }

}
