import React, { useState } from 'react';
import { useLoaderData, Link } from 'react-router-dom';
import Masker from '../../components/Masker.jsx';
import { Context } from '../../components/Context';

import { getDetails, getFiles } from '../../masking.js';

// function to load data for this component
// will be called by the Router before rendering
export async function loader({ params }) {


	const details = await getDetails(params.iec);
  const files = await getFiles(params.iec);

	return { details, files, iec: params.iec };
}

export default function MaskIEC() {
  const { details, files, iec } = useLoaderData();

  // default values for this route/mode
  const [template, setTemplate] = useState('Masker');
  const [zoom, setZoom] = useState(250);
  const [opacity, setOpacity] = useState(0.3);
  const [presets, setPresets] = useState([]);
  const [selectedPreset, setSelectedPreset] = useState('CT-MIP');
  const [leftPanelVisibility, setLeftPanelVisibility] = useState(true);
  const [rightPanelVisibility, setRightPanelVisibility] = useState(false);

  // Here we just assemble the various panels that we need for this mode
  return (
    <Context.Provider value={{
        template, setTemplate,
        zoom, setZoom,
        opacity, setOpacity,
        presets, setPresets,
        selectedPreset, setSelectedPreset,
        leftPanelVisibility, setLeftPanelVisibility,
        rightPanelVisibility, setRightPanelVisibility,
    }}>
        <Masker files={files} iec={iec} />
    </Context.Provider>
  );
}
