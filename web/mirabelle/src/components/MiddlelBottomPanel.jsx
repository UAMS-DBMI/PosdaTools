import React, { useContext } from 'react';

import { Context } from './Context.js';
import MaskerPanel from './MaskerPanel.jsx';
import NavigationPanel from './NavigationPanel.jsx';

function MiddlelBottomPanel({ onExpand, onClear, onAccept, onNext, onPrevious }) {
  const {
    template,
  } = useContext(Context);

  return (
    <div id="middleBottomPanel" className="w-full h-12 flex justify-between gap-2">
        <MaskerPanel 
          onExpand={onExpand}
          onClear={onClear}
          onAccept={onAccept}
        />
        {template === "MaskerVR" && (
          <NavigationPanel 
            onNext={onNext}
            onPrevious={onPrevious}
          />
        )}
      </div>
  );
}

export default MiddlelBottomPanel;
