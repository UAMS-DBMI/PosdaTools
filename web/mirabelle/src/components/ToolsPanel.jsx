import React, { useState, useContext } from 'react';
import { Context } from './Context.js';
import NavigationPanel from './NavigationPanel';
import FunctionPanel from './FunctionPanel';
import FormPanel from './FormPanel';


function ToolsPanel() {
  const { 
    defaultLayout,
    defaultZoom,
    defaultOpacity,
    defaultPresets,
    // defaultSelectedPreset,
    defaultWindowLevel,
    defaultCrosshairs,
    defaultRectangleScissors,
    defaultViewportNavigation,
    defaultResetViewports,
    defaultLeftPanelVisibility,
    defaultRightPanelVisibility,
    defaultView,

    layout, setLayout,
    zoom, setZoom,
    opacity, setOpacity,
    presets, setPresets,
    selectedPreset, setSelectedPreset,
    leftPanelVisibility, setLeftPanelVisibility,
    rightPanelVisibility, setRightPanelVisibility,
    windowLevel, setWindowLevel,
    crosshairs, setCrosshairs,
    rectangleScissors, setRectangleScissors,
    viewportNavigation, setViewportNavigation,
    resetViewports, setResetViewports,
    view, setView,
  } = useContext(Context);

  const handleZoomChange = (event) => {
    const newZoom = event.target.value;
    setZoom(newZoom);
  };

  const handleOpacityChange = (event) => {
    const newOpacity = parseFloat(event.target.value);
    setOpacity(newOpacity);
  };

  const handlePresetChange = (event) => {
    const newPreset = event.target.value;
    setSelectedPreset(newPreset);
  };

  const handleWindowLevelButtonClick = () => {
    setWindowLevel(true);
    setCrosshairs(false);
    setRectangleScissors(false);
  };

  const handleCrosshairsButtonClick = () => {
    setWindowLevel(false);
    setCrosshairs(true);
    setRectangleScissors(false);
  };

  const handleRectangleScissorsButtonClick = () => {
    setWindowLevel(false);
    setCrosshairs(false);
    setRectangleScissors(true);
  };

  const handleZoomButtonClick = () => {
    setViewportNavigation("Zoom");
    console.log('Zoom button clicked');
  };

  const handlePanButtonClick = () => {
    setViewportNavigation("Pan");
    console.log('Pan button clicked');
  };

  const handleVolumeButtonClick = () => {
    setView("Volume");
    console.log('Volume button clicked');
  };

  const handleProjectionButtonClick = () => {
    setView("Projection");
    console.log('Projection button clicked');
  };

  const handleAllButtonClick = () => {
    setView("All");
    console.log('All button clicked');
  };

  const handleResetViewportsButtonClick = () => {
    setResetViewports(true);
  };

  function handleOnNext() {
    alert("Not yet implemented :(");
  }
  function handleOnPrevious() {
    alert("Not yet implemented :(");
  }

  return (
    <div id="toolsPanel" className="overflow-y-auto no-scrollbars p-6 rounded-lg bg-blue-100 dark:bg-blue-900">
      {/*<div className="mb-2 font-semib  old">Tools</div>*/}
      <ul className=" h-full pb-4">

        {
          layout === "MaskerVR" &&  
          <NavigationPanel 
            onNext={handleOnNext}
            onPrevious={handleOnPrevious}
          />
        }

        <label>View:</label>
        <li className="pt-1 dark:bg-opacity-5  rounded-lg">
          <button onClick={handleVolumeButtonClick}className={`w-full ${ view === "Volume" ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
            Volume
          </button>
        </li>
        <li className=" pt-2 mb-4 dark:bg-opacity-5  rounded-lg">
          <button onClick={handleProjectionButtonClick}className={`w-full ${ view === "Projection" ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
            Projection
          </button>
        </li>
        {/*<li className="pb-4 pt-2 dark:bg-opacity-5  rounded-lg">
          <button onClick={handleAllButtonClick}className={`w-full ${ view === "All" ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
            All
          </button>
        </li>*/}

        {
          layout !== "MaskerReview" &&  
          <>
            <FunctionPanel />
            <FormPanel />
          </>
        }

        {/*<li className="mb-2 pb-2 pt-2 dark:bg-opacity-5  rounded-lg">
          <label>Zoom:</label>
          <input
            className='w-full cursor-pointer'
            type="range"
            min="1"
            max="250"
            step="1"
            value={zoom}
            onChange={handleZoomChange}
          />
          <span>{zoom}</span>
        </li>*/}
        <label>Left-Click:</label>
        <li className="pb-1 pt-1 rounded-lg">
          <button onClick={handleWindowLevelButtonClick} className={`w-full ${ windowLevel ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
            Window Level
          </button>
        </li>
        <li className="pb-1 pt-1 rounded-lg">
          <button onClick={handleCrosshairsButtonClick} className={`w-full ${ crosshairs ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
            Crosshairs
          </button>
        </li>

        {
          layout !== "MaskerReview" &&  
          <li className="mb-1 pt-1 rounded-lg">
            <button onClick={handleRectangleScissorsButtonClick} className={`w-full ${ rectangleScissors ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
              Selection
            </button>
          </li>
        }
        {/*{ rectangleScissors ? <><li className="pb-1 pt-1 rounded-lg">
          <button className={`w-full bg-slate-900`}>
            Expand
          </button>
        </li>
        <li className="pb-1 pt-1 rounded-lg">
          <button className={`w-full bg-slate-900`}>
            Clear
          </button>
        </li>
        <li className="pb-2 pt-1 rounded-lg">
          <button className={`w-full  bg-slate-900`}>
            Accept
          </button>
        </li>
        </> : null } */}
        <div className="h-2"></div>
        <label>Right-Click:</label>
        <li className="pb-1 pt-1 rounded-lg">
          <button onClick={handleZoomButtonClick} className={`w-full ${ viewportNavigation === "Zoom" ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
            Zoom
          </button>
        </li>
        <li className="pb-1 pt-1 rounded-lg">
          <button onClick={handlePanButtonClick} className={`w-full ${ viewportNavigation === "Pan" ? 'text-white bg-blue-500' : 'bg-white dark:bg-slate-900'}`}>
            Pan
          </button>
        </li>
        <li className="pt-2 dark:bg-opacity-5 rounded-lg">
          <label>Opacity:</label>
          <input
            className='w-full cursor-pointer'
            type="range"
            min="0"
            max="1"
            step="0.01"
            value={opacity}
            onChange={handleOpacityChange}
          />
          <span>{opacity}</span>
        </li>
        <li className="pb-2 pt-2 rounded-lg">
          <label>Preset:</label>
          <select value={selectedPreset} onChange={handlePresetChange} className="w-full cursor-pointer text-black dark:text-white border border-gray-300 dark:bg-slate-800 rounded-lg p-2 mt-1">
            {presets.map((preset) => (
              <option key={preset} value={preset}>{preset}</option>
            ))}
          </select>
        </li>
        <li className="mb-2 pb-2 pt-4 rounded-lg">
          <button onClick={handleResetViewportsButtonClick}className="w-full text-white bg-red-600">
            Reset Viewports
          </button>
        </li>
      </ul>
    </div>
  );
}

export default ToolsPanel;
