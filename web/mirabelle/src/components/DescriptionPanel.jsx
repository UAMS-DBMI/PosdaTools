import React from 'react';

function DescriptionPanel() {
  return (
      <div id="descriptionPanel" className="h-full overflow-hidden p-6 rounded-lg bg-blue-100 dark:bg-blue-900">
        <div className="w-full mb-2 font-semibold">Description</div>
        <div className="w-full h-full overflow-y-scroll no-scrollbars pb-8">Heres a 4-sentence random description about the current selection or feature being reviewed, description about the current selection or feature being reviewed, description about the current selection random description about the current selection or feature being reviewed, description about the current selection or feature being reviewed, description about the current selection or feature being reviewed, providing context or additional information as required.</div>
      </div>
  );
}

export default DescriptionPanel;
