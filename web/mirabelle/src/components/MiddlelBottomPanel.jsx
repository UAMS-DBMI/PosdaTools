import React, { useContext } from 'react';

import { Context } from './Context.js';
import MaskerPanel from './MaskerPanel.jsx';
import NavigationPanel from './NavigationPanel.jsx';

function MiddlelBottomPanel({ onExpand,
                              onClear,
                              onAccept,
                              onNext, 
                              onPrevious,
                              onMarkAccepted,
                              onMarkRejected,
                              onMarkSkip,
                              onMarkNonMaskable }) {
  const {
    template,
  } = useContext(Context);

  return (
    <div id="middleBottomPanel" className="w-full h-12 flex justify-center gap-2">
        <MaskerPanel 
          onExpand={onExpand}
          onClear={onClear}
          onAccept={onAccept}
          onMarkAccepted={onMarkAccepted}
          onMarkRejected={onMarkRejected}
          onMarkSkip={onMarkSkip}
          onMarkNonMaskable={onMarkNonMaskable}
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
