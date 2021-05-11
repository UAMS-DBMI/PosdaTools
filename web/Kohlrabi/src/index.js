import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import 'bootstrap/dist/css/bootstrap.css';


const id = window.location.pathname.substring(1);

ReactDOM.render(
  <React.StrictMode>
    <App VRindex={id} />
  </React.StrictMode>,
  document.getElementById('root')
);
