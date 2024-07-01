import React from 'react';

function MaskerPanel({ onExpand, onClear, onAccept }) {
  return (
    <div id="maskerPanel" className="h-12 flex justify-center gap-2">
      <button onClick={onExpand} id="expandSelection">Expand Selection</button>
      <button onClick={onClear} id="clearSelection">Clear Selection</button>
      <button onClick={onAccept} id="acceptSelection">Accept Selection</button>
    </div>
  );
}

export default MaskerPanel;
