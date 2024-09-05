
import React, { useContext } from 'react';

import { Context } from './Context.js';

function Arrows() {

  const {leftPanelVisibility, setLeftPanelVisibility, rightPanelVisibility, setRightPanelVisibility } = useContext(Context);

  return (
    <div id="arrows" className="absolute grid grid-rows-[1fr,auto] w-screen h-screen gap-2">
      <div id="spacer"></div>
      <div id="layoutButtons">
        <button
          id="leftPanelButton"
          onClick={() => setLeftPanelVisibility(!leftPanelVisibility)}
          className={`z-[100] box-content flex items-center justify-center absolute w-5 h-5 leading-5 top-1/2 left-0 transform -translate-y-1/2 bg-blue-500 rounded-full p-1 transition-transform ${leftPanelVisibility ? '-translate-x-4' : 'rotate-180 -translate-x-4'}`}
        
        >
          <span className="material-icons-rounded rounded-full leading-5 text-white">chevron_left</span>
        </button>
        <button
          id="rightPanelButton"
          onClick={() => setRightPanelVisibility(!rightPanelVisibility)}
          className={`z-[100] box-content flex items-center justify-center absolute w-5 h-5 leading-5 top-1/2 right-0 transform -translate-y-1/2 bg-blue-500 rounded-full p-1 transition-transform ${rightPanelVisibility ? 'translate-x-3' : 'rotate-180 translate-x-3'}`}
        
        >
          <span className="material-icons rounded-full leading-5 text-white">chevron_right</span>
        </button>
      </div>

    </div>
  );
}

export default Arrows;
