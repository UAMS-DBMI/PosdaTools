import React from 'react';
import {useState} from 'react';

import Header from './Header.jsx';
import LeftPanel from './LeftPanel.jsx';
import MiddlePanel from './MiddlePanel.jsx';
import RightPanel from './RightPanel.jsx';
import TopPanel from './TopPanel.jsx';

function VisualReview({ template }) {
  const [leftPanelVisibility, setLeftPanelVisibility] = useState(true);
  const [rightPanelVisibility, setRightPanelVisibility] = useState(true);
  const [topPanelVisibility, setTopPanelVisibility] = useState(true);

  const [zoom, setZoom] = useState(1);
  const [opacity, setOpacity] = useState(0.2); // Default opacity value
  const [layout, setLayout] = useState('all');

  const gridTemplate = leftPanelVisibility && rightPanelVisibility
    ? 'grid-cols-[auto,1fr,auto]'
    : leftPanelVisibility 
    ? 'grid-cols-[auto,1fr]'
    : rightPanelVisibility 
    ? 'grid-cols-[1fr,auto]'
    : 'grid-cols-1';
  
  return (
    <div id="app" className={`grid ${topPanelVisibility ? 'grid-rows-[auto,1fr]' : 'grid-rows-[1fr]'} gap-2 w-screen h-screen p-2`}>
      {topPanelVisibility && <Header title={"Visual Review"}/>}
      {/*{topPanelVisibility && <TopPanel />}*/}
      <div id="main" className={`h-full grid ${gridTemplate} rounded-lg gap-2 overflow-hidden`}>
        {leftPanelVisibility && (
          <div id="leftPanel" className={`w-72 h-full rounded-lg overflow-y-hidden ${leftPanelVisibility ? 'slide-in' : 'slide-out'}`} >
            <LeftPanel setZoom={setZoom} setOpacity={setOpacity} template={template} />
          </div>
        )}
        <MiddlePanel
          leftPanelVisibility={leftPanelVisibility} 
          setLeftPanelVisibility={setLeftPanelVisibility} 
          rightPanelVisibility={rightPanelVisibility} 
          setRightPanelVisibility={setRightPanelVisibility}
          topPanelVisibility={topPanelVisibility} 
          setTopPanelVisibility={setTopPanelVisibility}
          zoom={zoom}
          opacity={opacity}
          layout={layout}
        />
        {rightPanelVisibility && (
          <div id="rightPanel" className="w-72 h-full rounded-lg overflow-hidden">
            <RightPanel />
          </div>
        )}
      </div>
    </div>
  )
}

export default VisualReview
