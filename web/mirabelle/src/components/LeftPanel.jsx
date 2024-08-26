import React, { useContext } from 'react';
import FilesPanel from './FilesPanel.jsx';
import ToolsPanel from './ToolsPanel.jsx';

import { Context } from './Context.js';

function LeftPanel() {
  const { layout } = useContext(Context);
  
  return (
    <div id="leftPanelWrapper" className="grid grid-rows-[1fr] h-full w-72 gap-2">
      {layout === '???' ? <FilesPanel /> : null }
      {/*<FilesPanel />*/}
      <ToolsPanel />
    </div>
  );
}

export default LeftPanel;
