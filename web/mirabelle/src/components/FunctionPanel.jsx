import React, { useState, useContext } from 'react';
import { Context } from './Context';

function FunctionPanel() {
  const { 
    maskFunction, setMaskFunction
  } = useContext(Context);

  function change(toWhat) {
    setMaskFunction(toWhat);
  }

  return (
    <>
      <label>Function:</label>
      <li className="pt-1 pb-4 dark:bg-opacity-5 rounded-lg flex space-x-2">
        <button 
            title="Mask"
            onClick={() => change("mask")}
            className={`w-full ${ maskFunction === "mask" ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
          <span className='material-symbols-outlined'>domino_mask</span>
        </button>
        <button 
            title="Blackout"
            onClick={() => change("blackout")}
            className={`w-full ${ maskFunction === "blackout" ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
          <span className='material-symbols-outlined'>imagesearch_roller</span>
        </button>
        <button 
            title="Slice Removal"
            onClick={() => change("sliceremove")}
            className={`w-full ${ maskFunction === "sliceremove" ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
          <span className='material-symbols-outlined'>content_cut</span>
        </button>
      </li>
    </>
  );
}

export default FunctionPanel;
