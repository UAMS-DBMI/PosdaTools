import { NgModule } from '@angular/core';
import {
  MatSliderModule,
  MatMenuModule,
  MatButtonModule,
  MatDialogModule,
  MatToolbarModule,
  MatIconModule,
  MatCardModule,
  MatProgressSpinnerModule,
  MatCheckboxModule,
  MatDividerModule,
  MatChipsModule,
  MatListModule,
  } from '@angular/material';

import {ScrollingModule} from '@angular/cdk/scrolling';

@NgModule({
  exports: [
    MatSliderModule,
    MatMenuModule,
    MatButtonModule,
    MatDialogModule,
    MatToolbarModule,
    MatIconModule,
    MatCardModule,
    MatProgressSpinnerModule,
    MatCheckboxModule,
    MatDividerModule,
    MatChipsModule,
    MatListModule,
    ScrollingModule,
  ],
})
export class MyMaterialModule { }
