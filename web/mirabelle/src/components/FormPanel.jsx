import React, { useState, useContext } from 'react';
import { Context } from './Context';

function FormPanel() {
  const { 
    maskForm, setMaskForm
  } = useContext(Context);

  function change(toWhat) {
    setMaskForm(toWhat);
  }

  return (
    <>
      <label>Form:</label>
      <li className="pt-1 pb-4 dark:bg-opacity-5 rounded-lg flex space-x-2">
        <button 
            title="Cuboid"
            onClick={() => change("cuboid")}
            className={`w-full ${ maskForm === "cuboid" ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
          <span className='material-symbols-outlined'>square</span>
        </button>
        <button 
            title="Cylinder"
            onClick={() => change("cylinder")}
            className={`w-full ${ maskForm === "cylinder" ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
          <span className='material-symbols-outlined'>circle</span>
        </button>
      </li>
    </>
  );
}

export default FormPanel;
