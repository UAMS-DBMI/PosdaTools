
import React, { useState } from 'react';
import { PresetsContext } from './PresetsContext';

export default function PresetsContextProvider({ children, presets = ["Preset 1", "Preset 2", "Preset 3"] }) {

  return (
    <PresetsContext.Provider value = { presets }>
      {children}
    </PresetsContext.Provider>
  );
}
