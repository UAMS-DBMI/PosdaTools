import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { RouterModule, Routes } from '@angular/router';

import { AppComponent } from './app.component';
import { Component1Component } from './component1/component1.component';
import { SeriesComponentComponent } from './series-component/series-component.component';
import { SeriesService } from './series.service';
import { ErrorService, ErrorComponent } from './errors';
import { NavComponent } from './nav/nav.component';

@NgModule({
  declarations: [
    AppComponent,
    Component1Component,
    SeriesComponentComponent,
  ErrorComponent,
  NavComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
  HttpModule,
  // RouterModule.forRoot(appRoutes)
  ],
  providers: [SeriesService, ErrorService],
  bootstrap: [AppComponent]
})
export class AppModule { }
