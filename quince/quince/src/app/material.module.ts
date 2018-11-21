import { NgModule } from '@angular/core';
import {
  MatSliderModule,
  MatMenuModule,
  MatButtonModule,
  MatDialogModule,
  MatToolbarModule,
  MatIconModule,
  MatCardModule,
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
  ],
})
export class MyMaterialModule { }
