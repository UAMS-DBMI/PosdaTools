import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MaterialModule } from '@angular/material';

import { AppComponent } from './app.component';
import { ImageComponent } from './image/image.component';

import 'hammerjs';
import { SeriesComponent } from './series/series.component';

@NgModule({
  declarations: [
    AppComponent,
    ImageComponent,
    SeriesComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
	HttpModule,
	BrowserAnimationsModule,
	MaterialModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
