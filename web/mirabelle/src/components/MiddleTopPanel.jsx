import React from 'react';
import { useContext } from 'react';
import { Context } from './Context.js';


import EditViewPanel from "./EditViewPanel.jsx";
import NavigationPanel from "./NavigationPanel.jsx";

function MiddleTopPanel({ iecs, onIecChange }) {
  const { layout } = useContext(Context);
  return (
    <div id="middleTopPanel" className="w-full flex justify-center items-center">
        {layout === "MaskerVR" && <NavigationPanel iecs={iecs} onIecChange={onIecChange}/>}
        {/*<EditViewPanel />*/}
      </div>
  );
}

export default MiddleTopPanel;
