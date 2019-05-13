import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule }    from '@angular/common/http';
import { ChartsModule } from 'ng2-charts';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { DBIFqueriesComponent } from './dbifqueries/dbifqueries.component';
import { PRBSComponent } from './prbs/prbs.component';
import { BSBUComponent } from './bsbu/bsbu.component';
import { FwtComponent } from './fwt/fwt.component';
import { FileTimeChartComponent } from './file-time-chart/file-time-chart.component';
import { TableLockAlertComponent } from './table-lock-alert/table-lock-alert.component';
import { QrviComponent } from './qrvi/qrvi.component';

@NgModule({
  declarations: [
    AppComponent,
    DBIFqueriesComponent,
    PRBSComponent,
    BSBUComponent,
    FwtComponent,
    FileTimeChartComponent,
    TableLockAlertComponent,
    QrviComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    ChartsModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
