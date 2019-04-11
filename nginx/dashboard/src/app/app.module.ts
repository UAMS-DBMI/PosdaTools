import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule }    from '@angular/common/http';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { DBIFqueriesComponent } from './dbifqueries/dbifqueries.component';
import { PRBSComponent } from './prbs/prbs.component';
import { BSBUComponent } from './bsbu/bsbu.component';
import { FwtComponent } from './fwt/fwt.component';

@NgModule({
  declarations: [
    AppComponent,
    DBIFqueriesComponent,
    PRBSComponent,
    BSBUComponent,
    FwtComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
