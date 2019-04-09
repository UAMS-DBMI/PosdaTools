import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { DBIFqueriesComponent } from './dbifqueries/dbifqueries.component';
import { PRBSComponent } from './prbs/prbs.component';
import { BSBUComponent } from './bsbu/bsbu.component';

const routes: Routes = [
  { path: '', redirectTo: '/dbifqueries', pathMatch: 'full' },
  { path: 'dbifqueries', component: DBIFqueriesComponent },
  { path: 'prbs', component: PRBSComponent },
  { path: 'bsbu', component: BSBUComponent },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
