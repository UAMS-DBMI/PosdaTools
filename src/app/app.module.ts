import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { RouterModule, Routes } from '@angular/router';

import { AppComponent } from './app.component';
import { Component1Component } from './component1/component1.component';
import { SeriesComponentComponent } from './series-component/series-component.component';
import { PageNotFoundComponentComponent } from './page-not-found-component/page-not-found-component.component';

import { SeriesService } from './series.service';


// const appRoutes: Routes = [
// 	{ path: 'iec/:id', component: SeriesComponentComponent },
// 	{ path: '', component: Component1Component },
// 	{ path: '**', component: PageNotFoundComponentComponent },
// ];


@NgModule({
  declarations: [
    AppComponent,
    Component1Component,
    SeriesComponentComponent,
    PageNotFoundComponentComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
	HttpModule,
	// RouterModule.forRoot(appRoutes)
  ],
  providers: [SeriesService],
  bootstrap: [AppComponent]
})
export class AppModule { }
