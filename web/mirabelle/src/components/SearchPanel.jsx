import React from 'react';

function SearchPanel() {
  return (
    <div id="searchPanel" className="flex gap-2 w-full rounded-lg justify-center">
      <label className="flex items-center space-x-1">
        {/*<span>Type:</span>*/}
        <select className="rounded-md border border-gray-300 h-8 px-2">
          <option>DICOM</option>
          <option>NIFTI</option>
        </select>
      </label>
      <label className="flex items-center space-x-1">
        {/*<span>File ID:</span>*/}
        <input type="text" placeholder="File ID" maxLength="8" size="10" className="rounded-md border border-gray-300 h-8 px-2"/>
      </label>
      <label className="flex items-center space-x-1">
        {/*<span>Series Instance UID:</span>*/}
        <input type="text" placeholder="Series Instance UID" size="50" className="rounded-md border border-gray-300 h-8 px-2"/>
      </label>
      <label className="flex items-center space-x-1">
        {/*<span>Timepoint ID:</span>*/}
        <input type="text" placeholder="Timepoint ID" maxLength="4" size="13" className="rounded-md border border-gray-300 h-8 px-2"/>
      </label>
      <button className="bg-blue-500 text-white rounded-md px-4 h-8 flex items-center justify-center">
        Search
      </button>
    </div>
  );
}

export default SearchPanel;