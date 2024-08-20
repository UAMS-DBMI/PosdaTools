import React, { useState, useEffect } from 'react';

function NavigationPanel({ onNext, onPrevious }) {
  return (
    <>
      <label>IEC:</label>
      <li className="pt-1 dark:bg-opacity-5 rounded-lg">
        <button onClick={onNext} className={`w-full bg-white dark:bg-slate-900`}>
          Next
        </button>
      </li>
      <li className="pb-4 pt-2 dark:bg-opacity-5 rounded-lg">
        <button onClick={onPrevious} className={`w-full bg-white dark:bg-slate-900`}>
          Previous
        </button>
      </li>
    </>
  );
}

export default NavigationPanel;
