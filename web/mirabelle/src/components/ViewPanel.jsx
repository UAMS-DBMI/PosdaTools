import React, { forwardRef, useRef } from 'react';
import CornerstoneViewer from './CornerstoneViewer';

function ViewPanel({ files, zoom, opacity, layout, volumeName, iec, preset }) {
  return (
    <div id="viewPanel" className="grid grid-rows-[1fr,auto] text-center gap-2 overflow- h-full">
	  {files && files.length > 0 &&
        <CornerstoneViewer 
          zoom={zoom}
          opacity={opacity}
          layout={layout}
          files={files}
          volumeName={volumeName}
          iec={iec}
          preset={preset}
        />
	  }
    </div>
  );
};

export default ViewPanel;
