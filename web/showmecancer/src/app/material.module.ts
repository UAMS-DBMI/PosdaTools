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
  ],
})
export class MyMaterialModule { }
