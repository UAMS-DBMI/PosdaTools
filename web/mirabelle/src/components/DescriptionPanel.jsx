import React, { useContext } from 'react';
import { Context } from './Context.js';

function DescriptionPanel() {

    //function downloadFile() {
    //    const element = document.createElement("a");
    //    const file = new Blob([fileData["test"]], { type: 'text/plain' });
    //    element.href = URL.createObjectURL(file);
    //    element.target = "_blank"
    //    element.download = "file.txt";
    //    document.body.appendChild(element); // Required for this to work in FireFox
    //    element.click();
    //}

    function downloadFile() {
        // Fetch the file from the path specified in fileData["path"]
        fetch(fileData["download_path"])
            .then(response => response.blob()) // Convert the response to a blob
            .then(blob => {
                const element = document.createElement("a");
                const url = URL.createObjectURL(blob);
                element.href = url;
                element.target = "_blank";
                element.download = fileData["import_name"]
                document.body.appendChild(element); // Required for this to work in FireFox
                element.click();
                document.body.removeChild(element); // Clean up after download
                URL.revokeObjectURL(url); // Free up memory
            })
            .catch(error => console.error('Error downloading file:', error));
    }

    const {
        layout, fileData
    } = useContext(Context);

    if (layout === "NiftiReview") {

        return (
            <div id="descriptionPanel" className="h-full overflow-auto p-6 rounded-lg bg-blue-100 dark:bg-blue-900">
                {/*<div className="w-full mb-2 font-bold">Description:</div>*/}
                <hr className="border-t border-gray-300 mb-4" />

                <button
                    id="downloadFile"
                    onClick={downloadFile}
                    className="text-white bg-green-700 hover:bg-green-800 mb-4">Download File</button>
                <hr className="border-t border-gray-300 mb-4" />

                <div className="w-full mb-2 font-bold">Import File Name:</div>
                <div className="w-full mb-2 font-normal break-words mb-4">{fileData["import_name"]}</div>
                <hr className="border-t border-gray-300 mb-4" />

                <div className="w-full mb-2 font-bold">Import File Path:</div>
                <div className="w-full mb-2 font-normal break-words mb-4">{fileData["import_path"]}</div>
                <hr className="border-t border-gray-300 mb-4" />

                <div className="w-full mb-2 font-bold">Posda File Path:</div>
                <div className="w-full mb-2 font-normal break-words mb-4">{fileData["posda_path"]}</div>
                <hr className="border-t border-gray-300 mb-4" />

            </div>
        );
    }
    else {

        return (
            <div id="descriptionPanel" className="h-full overflow-hidden p-6 rounded-lg bg-blue-100 dark:bg-blue-900">
                <div className="w-full mb-2 font-semibold">Description</div>
                <div className="w-full h-full overflow-y-scroll no-scrollbars pb-8">Heres a 4-sentence random description about the current selection or feature being reviewed, description about the current selection or feature being reviewed, description about the current selection random description about the current selection or feature being reviewed, description about the current selection or feature being reviewed, description about the current selection or feature being reviewed, providing context or additional information as required.</div>
            </div>
        );
    }
}

export default DescriptionPanel;
