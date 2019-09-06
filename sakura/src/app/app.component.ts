import { Component } from '@angular/core';
import { FormBuilder } from '@angular/forms';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  loginForm;

  constructor(private formBuilder: FormBuilder){
    this.loginForm = this.formBuilder.group({
      username: '',
      password: ''
    });
  }

  title = 'Posda';
  user: string;

  login(loginData) {
    console.warn('Login attempt', loginData)
    this.user = loginData.username;
    this.loginForm.reset();
  }
}
