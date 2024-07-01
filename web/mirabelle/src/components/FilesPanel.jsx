import React from 'react';

function FilesPanel() {
  return (
    <div id="filesPanel" className=" p-6 rounded-lg overflow-hidden dark:bg-opacity-5 bg-gray-100">
      <div className="mb-2 text-lg font-semibold">Files</div>
      <ul className="h-full overflow-y-scroll">
        <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file1.dcm</li>
        <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file2.dcm</li>
        <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file3.dcm</li>
        <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file4.dcm</li>
        <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file5.dcm</li>
        <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file3.dcm</li>
        <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file4.dcm</li>
        <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file5.dcm</li>
          <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file1.dcm</li>
          <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file3.dcm</li>
        <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white   rounded-lg">file4.dcm</li>
        <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file5.dcm</li>
          <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file1.dcm</li>
          <li className="mb-2 p-2 dark:bg-opacity-5 bg-white cursor-pointer hover:bg-blue-500 hover:text-white  rounded-lg">file1.dcm</li>
      </ul>
      <div className="h-6 w-full"></div>
    </div>
  );
}

export default FilesPanel;