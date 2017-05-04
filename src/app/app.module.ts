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

import { RouterModule, Routes } from '@angular/router';
import { WelcomeComponent } from './welcome/welcome.component';
import { FileService } from './file.service';
import { DetailsComponent } from './details/details.component';
import { DumpComponent } from './dump/dump.component';


const appRoutes: Routes = [
  { path: 'series/:uid', component: SeriesComponent },
  { path: 'iec/:iec', component: SeriesComponent },
  { path: 'file/:file_id', component: ImageComponent },
  { path: '**', component: WelcomeComponent },
];


@NgModule({
  declarations: [
    AppComponent,
    ImageComponent,
    SeriesComponent,
    WelcomeComponent,
    DetailsComponent,
    DumpComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    BrowserAnimationsModule,
    MaterialModule,
    RouterModule.forRoot(appRoutes)
  ],
  providers: [FileService],
  bootstrap: [AppComponent],
  entryComponents: [DetailsComponent, DumpComponent]
})
export class AppModule { }
