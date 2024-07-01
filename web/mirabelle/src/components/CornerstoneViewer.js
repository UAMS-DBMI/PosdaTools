import React, { useContext, useState, useEffect, useLayoutEffect, useRef } from 'react';
import MiddlelBottomPanel from './MiddlelBottomPanel.jsx';

import { Context } from './Context.js';

import * as cornerstone from '@cornerstonejs/core';
import { CONSTANTS, cache } from '@cornerstonejs/core';
import * as cornerstoneTools from '@cornerstonejs/tools';
import {
  cornerstoneStreamingImageVolumeLoader,
  cornerstoneStreamingDynamicImageVolumeLoader,
} from '@cornerstonejs/streaming-image-volume-loader';
import cornerstoneDICOMImageLoader from '@cornerstonejs/dicom-image-loader';
import dicomParser from 'dicom-parser';

import {
	expandSegTo3D,
	calculateDistance,
} from '../utilities';

import { setParameters, loaded } from '../masking';

function getOrCreateToolgroup(toolgroup_name) {
  let group = cornerstoneTools.ToolGroupManager.getToolGroup(toolgroup_name);
  if (group === undefined) {
    group = cornerstoneTools.ToolGroupManager.createToolGroup(toolgroup_name);
  }
  return group;
}

//TODO this should probably be moved somewhere else, masking.js maybe?
async function finalCalc(coords, volumeId, iec) {
  console.log("finalCalc running");
  console.log(coords);

  const volume = cornerstone.cache.getVolume(volumeId);
  const volumeDims = volume.dimensions;
  const volumeSpacing = volume.spacing;


  // Extracting the coordinates of the corners of the top face
  const topLeft = [coords.x.min, coords.y.min, coords.z.max];
  const topRight = [coords.x.max, coords.y.min, coords.z.max];
  const bottomLeft = [coords.x.min, coords.y.max, coords.z.max];
  const bottomRight = [coords.x.max, coords.y.max, coords.z.max];

  // Top face coordinates for black boxing
  const bbTopLeft = [coords.x.min, coords.y.min];
  const bbBottomRight = [coords.x.max, coords.y.max];

  const topFaceCorners = [topLeft, topRight, bottomLeft, bottomRight];

  console.log("Coordinates of the corners of the top face:", topFaceCorners);

  // Calculate the center point
  const centerX = (topLeft[0] + topRight[0] + bottomLeft[0] + bottomRight[0]) / 4;
  const centerY = (topLeft[1] + topRight[1] + bottomLeft[1] + bottomRight[1]) / 4;
  const centerZ = (topLeft[2] + topRight[2] + bottomLeft[2] + bottomRight[2]) / 4;

  const centerPoint = [centerX, centerY, centerZ];

  console.log("Center point of the top face:", centerPoint);

  const radius = calculateDistance(topFaceCorners[0], centerPoint);
  const height = coords.z.max - coords.z.min;

  // experimental adjustment of coordinates for masker
  function invert(val, maxval) {
    return maxval - val
  }
  /*
    * Convert a point in LPS to RAS.
    * This just inverts the first two points (which is why it needs
    * the dims). This is only useful if the input is actually in LPS!
    */
  function convertLPStoRAS(point, dims) {
    const [ dimX, dimY, dimZ ] = dims;
    let [x, y, z] = point;
    x = invert(x, dimX);
    y = invert(y, dimY);

    return [ x, y, z];
  }
  function scaleBySpacing(point, spacings) {
    const [ spaceX, spaceY, spaceZ ] = spacings;
    let [x, y, z] = point;

    return [ Math.floor(x * spaceX),
          Math.floor(y * spaceY),
          Math.floor(z * spaceZ) ];
  }

  const [ dimX, dimY, dimZ ] = volumeDims;
  const [ spaceX, spaceY, spaceZ ] = volumeSpacing;

  // let [x, y, z] = centerPoint;
  // let x2 = invert(x, dimX) * spaceX;
  // let y2 = invert(y, dimY) * spaceY;
  // let z2 = z * spaceZ;

  let centerPointRAS = convertLPStoRAS(centerPoint, volumeDims);
  let centerPointFix = scaleBySpacing(centerPointRAS, volumeSpacing);

  const diameter = Math.floor((radius * spaceX) * 2);
  const i = Math.floor((centerPointRAS[2] - height) * spaceZ);

  // LR PA S I diameter
  const output = {
    lr: centerPointFix[0],
    pa: centerPointFix[1],
    i: centerPointFix[2],
    s: i,
    d: diameter,
  };
  console.log(output);
  await setParameters(iec, output);
  //TODO need better way for this
  alert("Submitted for masking!");

}

function CornerstoneViewer({ volumeName,
                             files,
                             layout,
                             iec }) {

  const { zoom, opacity, setPresets, selectedPreset } = useContext(Context);

  const [ loading, setLoading ] = useState(true);
  const containerRef = useRef(null);
  const renderingEngineRef = useRef(null);

  console.log(
    ">>>>>>>>>>>>>>>>>>>>>>",
    "CornerstoneViewer() running",
    "loading is set to:", loading,
  );

  let coords;
  let segId = 'seg' + volumeName;
  let volumeId = 'cornerstoneStreamingImageVolume: newVolume' + volumeName;

  // Load presets when component mounts
  useEffect(() => {
    const loadPresets = () => {
      const fetchedPresets = CONSTANTS.VIEWPORT_PRESETS.map((preset) => preset.name);
      setPresets(fetchedPresets);
    };

    loadPresets();
  }, [setPresets]);

  useLayoutEffect(() => {
    let volume = null;
    cache.purgeCache();

    const { volumeLoader } = cornerstone;

    function initVolumeLoader() {
      volumeLoader.registerUnknownVolumeLoader(cornerstoneStreamingImageVolumeLoader);
      volumeLoader.registerVolumeLoader('cornerstoneStreamingImageVolume', cornerstoneStreamingImageVolumeLoader);
      volumeLoader.registerVolumeLoader('cornerstoneStreamingDynamicImageVolume', cornerstoneStreamingDynamicImageVolumeLoader);
    }

    function initCornerstoneDICOMImageLoader() {
      const { preferSizeOverAccuracy, useNorm16Texture } = cornerstone.getConfiguration().rendering;
      cornerstoneDICOMImageLoader.external.cornerstone = cornerstone;
      cornerstoneDICOMImageLoader.external.dicomParser = dicomParser;
      cornerstoneDICOMImageLoader.configure({
        useWebWorkers: true,
        decodeConfig: {
          convertFloatPixelDataToInt: false,
          use16BitDataType: preferSizeOverAccuracy || useNorm16Texture,
        },
      });

      let maxWebWorkers = 1;

      if (navigator.hardwareConcurrency) {
        maxWebWorkers = Math.min(navigator.hardwareConcurrency, 7);
      }

      const config = {
        maxWebWorkers,
        startWebWorkersOnDemand: false,
        taskConfiguration: {
          decodeTask: {
            initializeCodecsOnStartup: false,
            strict: false,
          },
        },
      };

      cornerstoneDICOMImageLoader.webWorkerManager.initialize(config);
    }


    const resizeObserver = new ResizeObserver(() => {
      const renderingEngine = renderingEngineRef.current;
      if (renderingEngine) {
        renderingEngine.resize(true, false);
      }
    });

    function setupPanel(panelId) {
      const panel = document.createElement('div');
      panel.id = panelId;
      panel.style.width = '100%';
      panel.style.height = '100%';
      panel.style.borderRadius = '8px';
      panel.style.overflow = 'hidden';
      panel.oncontextmenu = e => e.preventDefault();
      resizeObserver.observe(panel);
      return panel;
    }

    function setup3dViewportTools() {
      // Add tools if needed
      try {
        cornerstoneTools.addTool(cornerstoneTools.TrackballRotateTool);
      } catch (error) { }

      // Tool Group Setup
      const t3dToolGroup = getOrCreateToolgroup('t3d_tool_group');
      t3dToolGroup.addViewport('t3d_coronal', 'viewer_render_engine');

      // Trackball Rotate
      t3dToolGroup.addTool(cornerstoneTools.TrackballRotateTool.toolName);
      t3dToolGroup.setToolActive(cornerstoneTools.TrackballRotateTool.toolName, {
        bindings: [
          {
            mouseButton: cornerstoneTools.Enums.MouseBindings.Primary, // Left Click
          },
        ],
      });

      // Pan
      // cornerstoneTools.addTool(cornerstoneTools.PanTool);
      t3dToolGroup.addTool(cornerstoneTools.PanTool.toolName);
      t3dToolGroup.setToolActive(cornerstoneTools.PanTool.toolName, {
        bindings: [
          {
            mouseButton: cornerstoneTools.Enums.MouseBindings.Auxiliary, // Middle Click
          },
        ],
      });

      // Zoom
      // cornerstoneTools.addTool(cornerstoneTools.ZoomTool);
      t3dToolGroup.addTool(cornerstoneTools.ZoomTool.toolName);
      t3dToolGroup.setToolActive(cornerstoneTools.ZoomTool.toolName, {
        bindings: [
          {
            mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary, // Right Click
          },
        ],
      });

      // Segmentation Display
      // cornerstoneTools.addTool(cornerstoneTools.SegmentationDisplayTool);
      t3dToolGroup.addTool(cornerstoneTools.SegmentationDisplayTool.toolName);
      t3dToolGroup.setToolEnabled(cornerstoneTools.SegmentationDisplayTool.toolName);
    }

    function setupVolViewportTools() {
      try {
        cornerstoneTools.addTool(cornerstoneTools.RectangleScissorsTool);
        cornerstoneTools.addTool(cornerstoneTools.SegmentationDisplayTool);
        cornerstoneTools.addTool(cornerstoneTools.StackScrollMouseWheelTool);
        cornerstoneTools.addTool(cornerstoneTools.PanTool);
        cornerstoneTools.addTool(cornerstoneTools.ZoomTool);
      } catch (error) {
        console.log("errors while loading tools:", error);
      }

      // Create group and add viewports
      // TODO: should the render engine be coming from a var instead?
      const group = getOrCreateToolgroup('vol_tool_group');
      group.addViewport('vol_sagittal', 'viewer_render_engine');
      group.addViewport('vol_coronal', 'viewer_render_engine');

      // Stack Scroll Tool
      group.addTool(cornerstoneTools.StackScrollMouseWheelTool.toolName);
      group.setToolActive(cornerstoneTools.StackScrollMouseWheelTool.toolName);

      group.addTool(cornerstoneTools.SegmentationDisplayTool.toolName);
      // group.setToolActive(cornerstoneTools.SegmentationDisplayTool.toolName);
      // group.setToolEnabled(cornerstoneTools.SegmentationDisplayTool.toolName);

      group.addTool(cornerstoneTools.RectangleScissorsTool.toolName);
      group.setToolActive(cornerstoneTools.RectangleScissorsTool.toolName, {
        bindings: [
          { mouseButton: cornerstoneTools.Enums.MouseBindings.Primary },
        ]
      });

      group.addTool(cornerstoneTools.PanTool.toolName);
      group.setToolActive(cornerstoneTools.PanTool.toolName, {
        bindings: [
          // Middle mouse button
          { mouseButton: cornerstoneTools.Enums.MouseBindings.Auxiliary },
        ],
      });

      group.addTool(cornerstoneTools.ZoomTool.toolName);
      group.setToolActive(cornerstoneTools.ZoomTool.toolName, {
        bindings: [
          { mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary },
        ],
      });

    }

    function setupMipViewportTools() {
      // Tool Group setup
      const mipToolGroup = cornerstoneTools.ToolGroupManager.createToolGroup('mip_tool_group');
      mipToolGroup.addViewport('mip_axial', 'viewer_render_engine');
      mipToolGroup.addViewport('mip_sagittal', 'viewer_render_engine');
      mipToolGroup.addViewport('mip_coronal', 'viewer_render_engine');

      // Window Level
      cornerstoneTools.addTool(cornerstoneTools.WindowLevelTool);
      mipToolGroup.addTool(cornerstoneTools.WindowLevelTool.toolName);
      mipToolGroup.setToolActive(cornerstoneTools.WindowLevelTool.toolName, {
        bindings: [
          {
            mouseButton: cornerstoneTools.Enums.MouseBindings.Primary, // Left Click
          },
        ],
      });
    }
    
    async function run() {
      if (!loaded.loaded) {
        await cornerstone.init();
        await cornerstoneTools.init();
        await initVolumeLoader();
        await initCornerstoneDICOMImageLoader();
        loaded.loaded = true;
      }

      const renderingEngine = new cornerstone.RenderingEngine('viewer_render_engine');
      renderingEngineRef.current = renderingEngine;

      const container = containerRef.current;
      container.innerHTML = ''; // Clear previous content

      if (layout === 'Masker') {
        const viewportInput = [];

        container.style.display = 'grid';
        container.style.gridTemplateColumns = 'repeat(3, 1fr)';
        container.style.gridGap = '6px';
        container.style.width = '100%';
        container.style.height = '100%';

        const volSagittalContent = setupPanel('vol_sagittal');
        const volCoronalContent = setupPanel('vol_coronal');
        const t3dCoronalContent = setupPanel('t3d_coronal');
          
        container.appendChild(volSagittalContent);
        container.appendChild(volCoronalContent);
        container.appendChild(t3dCoronalContent);

        viewportInput.push(
            {
              viewportId: 'vol_sagittal',
              type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
              element: volSagittalContent,
              defaultOptions: {
                orientation: cornerstone.Enums.OrientationAxis.SAGITTAL,
              },
            },
            {
              viewportId: 'vol_coronal',
              type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
              element: volCoronalContent,
              defaultOptions: {
                orientation: cornerstone.Enums.OrientationAxis.CORONAL,
              },
            },
            {
              viewportId: 't3d_coronal',
              type: cornerstone.Enums.ViewportType.VOLUME_3D,
              element: t3dCoronalContent,
              defaultOptions: {
                orientation: cornerstone.Enums.OrientationAxis.CORONAL,
              },
            }
        );

        renderingEngine.setViewports(viewportInput);
      }

      if (layout === 'all' || layout === 'volumes' || layout === 'Masker') {
        setupVolViewportTools();
      }

      if (layout === 'all' || layout === '3d' | layout === 'Masker') {
        setup3dViewportTools();
      }
      setLoading(false); // signal that setup is complete
    }

    run();

    return () => {
      cache.purgeCache();
      resizeObserver.disconnect();
      
    };
  }, [layout]);

  // Load the actual volume into the display here
  useEffect(() => {

    cache.purgeCache();

    // do nothing if Cornerstone is still loading
    if (loading) {
      return;
    }

    // TODO: not sure if this is helpful here
    cornerstone.cache.purgeCache();
    cornerstone.cache.purgeVolumeCache();

    let volume = null;
    const renderingEngine = renderingEngineRef.current;

    async function getFileData() {
      let fileList = files.map(file_id => `wadouri:/papi/v1/files/${file_id}/data`);
      // TODO: could probably use a better way to generate unique volumeIds
      volume = await cornerstone.volumeLoader.createAndCacheVolume(volumeId, { imageIds: fileList });
    }

    async function doit() {
      window.cornerstone = cornerstone;
      window.cornerstoneTools = cornerstoneTools;
      await getFileData();
      volume.load();

      await cornerstone.setVolumesForViewports(
          renderingEngine,
          [{ volumeId: volumeId }],
          ['vol_sagittal', 'vol_coronal']
        );

      await cornerstone.setVolumesForViewports(
        renderingEngine, 
        [{ volumeId: volumeId }], 
        ['t3d_coronal']).then(() => {
        const viewport = renderingEngine.getViewport('t3d_coronal');
        // viewport.setProperties({ preset: 'MR-Default' });
        viewport.setProperties({ preset: selectedPreset });
      });        

      // create and bind a new segmentation
      await cornerstone.volumeLoader.createAndCacheDerivedSegmentationVolume(
        volumeId,
        { volumeId: segId }
      );

      // make sure it doesn't already exist
      cornerstoneTools.segmentation.state.removeSegmentation(segId);
      cornerstoneTools.segmentation.state.removeSegmentationRepresentations('t3d_tool_group');
      cornerstoneTools.segmentation.addSegmentations([
        {
          segmentationId: segId,
          representation: {
            type: cornerstoneTools.Enums.SegmentationRepresentations.Labelmap,
            data: {
              volumeId: segId,
            },
          },
        },
      ]);

      await cornerstoneTools.segmentation.addSegmentationRepresentations(
        'vol_tool_group',
        [
          {
            segmentationId: segId,
            type: cornerstoneTools.Enums.SegmentationRepresentations.Labelmap,
          },
        ]
      );

    }

    doit();

  }, [files, loading]);


  // TODO: this will explode if there is no t3d_coronal!
  /***
   * Handle changes to the `preset` prop
   */
  useEffect(() => {
    const renderingEngine = renderingEngineRef.current;
    if (renderingEngine) {
      const viewport = renderingEngine.getViewport('t3d_coronal');
      viewport.setProperties({ preset: selectedPreset });
      console.log(cornerstone.cache.getVolumes());
    }
  }, [selectedPreset]);

  /***
   * Handle changes to the `zoom` prop
   */
  useEffect(() => {
    const renderingEngine = renderingEngineRef.current;
    if (renderingEngine) {
      const volSagittalViewport = renderingEngine.getViewport('vol_sagittal');
      if (volSagittalViewport) {
        const camera = volSagittalViewport.getCamera();
        camera.parallelScale = zoom;
        volSagittalViewport.setCamera(camera);
        volSagittalViewport.render();
      }
    }
  }, [zoom]);

  /***
   * Handle changes to the `opacity` prop
   */
  useEffect(() => {
    const renderingEngine = renderingEngineRef.current;
    if (renderingEngine) {
      const viewport = renderingEngine.getViewport('t3d_coronal');
      if (viewport) {
        const actorEntry = viewport.getActors()[0];
        if (actorEntry && actorEntry.actor) {
          const volumeActor = actorEntry.actor;
          const property = volumeActor.getProperty();
          const opacityFunction = property.getScalarOpacity(0);

          opacityFunction.removeAllPoints();
          opacityFunction.addPoint(0, 0.0);
          opacityFunction.addPoint(500, opacity);
          opacityFunction.addPoint(1000, opacity);
          opacityFunction.addPoint(1500, opacity);
          opacityFunction.addPoint(2000, opacity);

          property.setScalarOpacity(0, opacityFunction);
          viewport.render();
        }
      }
    }
  }, [opacity]);

  async function handleExpandSelection() {
    console.log('handleExpandSelection called, setId is', segId);
    coords = expandSegTo3D(segId);

    cornerstoneTools.segmentation
      .triggerSegmentationEvents
      .triggerSegmentationDataModified(segId);

    await cornerstoneTools.segmentation.addSegmentationRepresentations(
      't3d_tool_group', [
        {
          segmentationId: segId,
          type: cornerstoneTools.Enums.SegmentationRepresentations.Surface,
          options: {
            polySeg: {
              enabled: true,
            }
          }
        }
      ]
    );
  }

  async function handleClearSelection() {
    const segVolume = cornerstone.cache.getVolume(segId);
    const scalarData = segVolume.scalarData;
    scalarData.fill(0);

    // redraw segmentation
    cornerstoneTools.segmentation
      .triggerSegmentationEvents
      .triggerSegmentationDataModified(segId);
  }
  async function handleAcceptSelection() {
    await finalCalc(coords, volumeId, iec);
  }

  return (
    <>
      <div ref={containerRef}
           style={{ width: '100%', height: '100%' }}
           id="container"></div>
      <MiddlelBottomPanel 
        onAccept={handleAcceptSelection}
        onClear={handleClearSelection}
        onExpand={handleExpandSelection}
      />
    </>
  );
};

export default CornerstoneViewer;
