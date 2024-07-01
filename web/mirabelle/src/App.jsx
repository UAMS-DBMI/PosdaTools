import React from 'react';
import {useState} from 'react';

import { Context } from './components/Context.js';

import Masker from './components/Masker.jsx';
import VisualReview from './components/VisualReview.jsx';

function App({children}) {

  const [template, setLayout] = useState('Masker');

  return (
    <Context.Provider value={ template }>
      <Masker files={["22835914"]} iecs={["117"]}/>
    </Context.Provider>
  )
}

export default App

    /*// <div>
    //     {template === 'Masker' ? <Masker template={template} /> : <VisualReview template={template} />}
  // </div> */
