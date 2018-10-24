import { Component, OnInit, Input, HostListener } from '@angular/core';
import { SeriesService } from '../series.service';
import { ErrorService } from '../errors';
import { Project } from '../project';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-hidebox',
  templateUrl: './hidebox.component.html',
  styleUrls: ['./hidebox.component.css']
})
export class HideboxComponent implements OnInit {
  @Input() project: Project;
  @Input() mode: string = "Hide";
  public open: boolean = false;
  public hidden: boolean = false;
  public patients: string[];
  public busy: Subscription;

  constructor(
    private service: SeriesService,
    private errorS: ErrorService,
  ) { }

  ngOnInit() {
  }

  onClick() {
    let what: string;
    if (this.mode == 'Hide') {
      what = "unhidden";
    } else {
      what = "hidden";
    }
    this.open = true;
    this.busy = this.service.getPatients(what, this.project).subscribe(
      data => this.patients = data
    );
  }

  // Triggered when the user clicks Yes or No to Hide All Records confirmation
  // dialog.
  onConfirm(what: string) {
    console.log(what);
    if (this.mode == 'Hide') {
      this.busy = this.service.hideProject(this.project).subscribe(
        resp => this.onHideAll(resp)
      );
    } else {
      this.busy = this.service.unhideProject(this.project).subscribe(
        resp => this.onHideAll(resp)
      );
    }
  }

  onHideAll(resp: any) {
    console.log(resp);
    this.open = false;
    this.hidden = true;
  }
  onHidePatient(resp: any, patient: string) {
    console.log(resp, patient);
    // this.open = false;
    this.onClick();
  }

  onConfirmPatient(patient: string) {
    console.log(patient);
    if (this.mode == 'Hide') {
      this.busy = this.service.hidePatient(this.project, patient).subscribe(
        resp => this.onHidePatient(resp, patient)
      );
    } else {
      this.busy = this.service.unhidePatient(this.project, patient).subscribe(
        resp => this.onHidePatient(resp, patient)
      );
    }
    this.open = false;
  }
}
