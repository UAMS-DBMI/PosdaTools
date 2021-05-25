import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import 'bootstrap/dist/css/bootstrap.css';

let match = window.location.pathname.match(/\/(\d+)/);
let id = null;
if(match){
  id = match[1];
}

ReactDOM.render(
  <React.StrictMode>
    <App VRindex={id} />
  </React.StrictMode>,
  document.getElementById('root')
);
