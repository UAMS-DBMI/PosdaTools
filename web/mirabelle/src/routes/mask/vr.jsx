import React, { useState } from 'react';
import { useLoaderData, Link } from 'react-router-dom';
import Masker from '../../components/Masker.jsx';


import { getDetails, getIECsForVR } from '../../masking.js';

import { Context } from '../../components/Context';

export async function loader({ params }) {

  const iecs = await getIECsForVR(params.visual_review_instance_id);

  return { iecs };

}

export default function MaskVR() {
  const { iecs } = useLoaderData();

  // default values for this route/mode

  const defaults = {
    layout: 'MaskerVR',
    zoom: 250,
    opacity: 0.3,
    presets: [],
    selectedPreset: 'CT-MIP',
    windowLevel: true,
    crosshairs: false,
    rectangleScissors: false,
    viewportNavigation: "Zoom",
    resetViewports: false,
    leftPanelVisible: true,
    rightPanelVisible: false,
    view: 'Volume',
    form: 'cylinder',
    function: 'mask',
  };

  const [layout, setLayout] = useState(defaults.layout);
  const [zoom, setZoom] = useState(defaults.zoom);
  const [opacity, setOpacity] = useState(defaults.opacity);
  const [presets, setPresets] = useState(defaults.presets);
  const [selectedPreset, setSelectedPreset] = useState(defaults.selectedPreset);
  const [windowLevel, setWindowLevel] = useState(defaults.windowLevel);
  const [crosshairs, setCrosshairs] = useState(defaults.crosshairs);
  const [rectangleScissors, setRectangleScissors] = useState(defaults.rectangleScissors);
  const [viewportNavigation, setViewportNavigation] = useState(defaults.viewportNavigation);
  const [resetViewports, setResetViewports] = useState(defaults.resetViewports);
  const [leftPanelVisibility, setLeftPanelVisibility] = useState(defaults.leftPanelVisible);
  const [rightPanelVisibility, setRightPanelVisibility] = useState(defaults.rightPanelVisible);
  const [view, setView] = useState(defaults.view);
  const [maskFunction, setMaskFunction] = useState(defaults.function);
  const [maskForm, setMaskForm] = useState(defaults.form);

  // Here we just assemble the various panels that we need for this mode
  return (
    <Context.Provider value={{

        defaults,

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
        maskFunction, setMaskFunction,
        maskForm, setMaskForm,
        
    }}>
        <Masker iecs={iecs} />
    </Context.Provider>
  );
}
