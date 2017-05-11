import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { RouterModule, Routes } from '@angular/router';

import { AppComponent } from './app.component';
import { ModeSelectComponent } from './mode-select/mode-select.component';
import { SeriesComponent} from './series/series.component';
import { SeriesService } from './series.service';
import { ErrorService, ErrorComponent } from './errors';
import { NavComponent } from './nav/nav.component';
import { BusyModule } from 'angular2-busy';
import { ProjectSelectComponent } from './project-select/project-select.component';
import { ProjectionComponent } from './projection/projection.component';
import { NavControlComponent } from './nav-control/nav-control.component';
import { MarkControlComponent } from './mark-control/mark-control.component';

@NgModule({
  declarations: [
    AppComponent,
    ModeSelectComponent,
    SeriesComponent,
    ErrorComponent,
    NavComponent,
    ProjectSelectComponent,
    ProjectionComponent,
    NavControlComponent,
    MarkControlComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    BusyModule,
    BrowserAnimationsModule
  // RouterModule.forRoot(appRoutes)
  ],
  providers: [SeriesService, ErrorService],
  bootstrap: [AppComponent]
})
export class AppModule { }
