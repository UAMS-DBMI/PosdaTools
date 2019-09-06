import { Component, OnInit } from '@angular/core';
import { FormBuilder } from '@angular/forms';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  loginForm;
  title = 'Posda';
  user: string;

  constructor(private formBuilder: FormBuilder){
    this.loginForm = this.formBuilder.group({
      username: '',
      password: ''
    });
  }

  ngOnInit() {
    this.user = localStorage.getItem('posda_user');
  }

  login(loginData) {
    this.user = loginData.username;
    localStorage.setItem('posda_user', this.user);
    this.loginForm.reset();
  }
}
