import React, { useState, useEffect } from 'react';

function NavigationPanel({ onNext, onPrevious }) {
  return (
    <>
      <label>IEC:</label>
      <li className="pt-1 dark:bg-opacity-5 rounded-lg">
        <button onClick={onNext} className={`w-full bg-white dark:bg-slate-900`}
        title='Next'>
          <span className="material-symbols-rounded">
            chevron_right
          </span>
        </button>
      </li>
      <li className="pb-4 pt-2 dark:bg-opacity-5 rounded-lg">
        <button onClick={onPrevious} className={`w-full bg-white dark:bg-slate-900`}
        title='Previous'>
          <span className="material-symbols-rounded">
            chevron_left
          </span>
        </button>
      </li>
    </>
  );
}

export default NavigationPanel;
