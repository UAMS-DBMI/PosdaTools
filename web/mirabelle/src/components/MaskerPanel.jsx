import React, { useContext } from 'react';
import { Context } from './Context.js';

function MaskerPanel({ onExpand, onClear, onAccept, onMarkAccepted, onMarkRejected }) {
  const {
    template,
  } = useContext(Context);

  if (template === 'MaskerReview') {
    // The review buttons
    return (
      <div id="maskerPanel" className="h-12 flex justify-center gap-2">
        <button
          id="markAccepted"
          onClick={onMarkAccepted}
          className="text-white bg-blue-700 hover:bg-blue-800">Accept Mask</button>
        <button
          id="markRejected"
          onClick={onMarkRejected}
          className="text-white bg-red-700 hover:bg-red-800">Reject Mask</button>
      </div>
    );
  } else {
    // the normal masking buttons
    return (
      <div id="maskerPanel" className="h-12 flex justify-center gap-2">
        <button onClick={onExpand} id="expandSelection">Expand Selection</button>
        <button onClick={onClear} id="clearSelection">Clear Selection</button>
        <button onClick={onAccept} id="acceptSelection">Accept Selection</button>
      </div>
    );
  }
}

export default MaskerPanel;
