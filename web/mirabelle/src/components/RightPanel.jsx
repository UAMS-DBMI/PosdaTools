import React from 'react';

import DescriptionPanel from "./DescriptionPanel.jsx";

function RightPanel() {
  return (
    <div id="rightPanelWrapper" className="h-full overflow-y-scroll">
      <DescriptionPanel />
    </div>
  );
}

export default RightPanel;