import React from 'react';

function MarkPanel() {
  return (
    <div id="markPanel" className="w-full flex justify-center gap-2">
        <button id="markGood">Good</button>
        <button id="markBad">Bad</button>
        <button id="markBlank">Blank</button>
        <button id="markScout">Scout</button>
        <button id="markOther">Other</button>
      </div>
  );
}

export default MarkPanel;