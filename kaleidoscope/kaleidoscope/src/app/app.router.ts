import { ModuleWithProviders } from '@angular/core';
import { Routes, RouterModule } from "@angular/router";

import { AppComponent } from "./app.component";
import { ModeSelectComponent } from "./mode-select/mode-select.component";
import { AdminComponent } from "./admin/admin.component";
import { NavControlComponent} from "./nav-control/nav-control.component";

export  const router: Routes =[
  { path: 'home', component: ModeSelectComponent},
  { path: 'admin', component: AdminComponent},
  { path: 'work', component: NavControlComponent},
  { path: '**', component: ModeSelectComponent }
];

export const routes: ModuleWithProviders = RouterModule.forRoot(router);
