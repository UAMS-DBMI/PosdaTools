import React from 'react';

function EditViewPanel() {
  return (
    <div id="editViewPanel" className="flex gap-2">
      <button id="viewVolume">Volumes View</button>
      <button id="viewProjections">Projections View</button>
      <button id="3dView">3D View</button>
    </div>
  );
}

export default EditViewPanel;