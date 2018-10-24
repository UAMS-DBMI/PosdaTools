import { Injectable } from '@angular/core';
import { Subject } from 'rxjs/Subject';
import { Component } from '@angular/core';

export interface Error {
    title?: string;
    description?: string;
    severity?: number;
}

@Injectable()
export class ErrorService {
  private errorAnnounceSource = new Subject<Error>();

  errorAnnounced$ = this.errorAnnounceSource.asObservable();

  constructor() {
      console.log('es init');
  }

  public announceError(title: string, description: string, severity: number){
      let error = {
          title: title,
          description: description,
          severity: severity
      };
      this.errorAnnounceSource.next(error);
  }
}

@Component({
  selector: 'app-error',
  template: `<div *ngFor="let error of errors"
     [class]="getSeverityClass(error.severity)"
     role="alert">
    <strong>{{error.title}}</strong>
    <small> {{error.description}}</small>
    <button type="button"
            class="close"
            aria-label="Close"
            (click)="dismiss(error)"><span>&times;</span></button>
</div>`
})
export class ErrorComponent {
  public errors: Error[] = [];

  constructor(private _errorService: ErrorService) {
      _errorService.errorAnnounced$.subscribe(
          error => this.errors.push(error)
      );
  }

  getSeverityClass(severity: number){
      if(severity < 1){
          return "alert alert-success";
      } else if(severity === 1){
          return "alert alert-info";
      } else if(severity === 2){
          return "alert alert-warning";
      } else if(severity > 2){
          return "alert alert-danger";
      }
      return "alert alert-info";
  }

  dismiss(error: Error){
      let i = this.errors.indexOf(error)
      if(i > -1){
          this.errors.splice(i, 1);
      }
  }
}
