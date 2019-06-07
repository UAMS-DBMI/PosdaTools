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
  ],
})
export class MyMaterialModule { }
