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

import { setParameters, loaded, flagAsAccepted, flagAsRejected, flagAsSkipped, flagAsNonmaskable } from '../masking';

import resizeButtonLogo from '../assets/resize-button.svg';
import { defaults } from 'autoprefixer';

//import { add, subtract, multiply, dotMultiply, inv, min, max, map } from 'mathjs';
import * as math from 'mathjs';

function getOrCreateToolgroup(toolgroup_name) {
  let group = cornerstoneTools.ToolGroupManager.getToolGroup(toolgroup_name);
  if (group === undefined) {
    group = cornerstoneTools.ToolGroupManager.createToolGroup(toolgroup_name);
  }
  return group;
}

//TODO this should probably be moved somewhere else, masking.js maybe?
async function finalCalc(coords, volumeId, iec, maskForm, maskFunction) {

    // Experimental adjustment of coordinates for masker
    function invert(val, maxval) {
        return maxval - val;
    }

    function convertLPStoRAS(point, dims) {
        const [dimX, dimY, dimZ] = dims;
        let [x, y, z] = point;
        x = invert(x, dimX);
        y = invert(y, dimY);
        return [x, y, z];
    }

    function scaleBySpacing(point, spacings) {
        const [spaceX, spaceY, spaceZ] = spacings;
        let [x, y, z] = point;
        return [Math.floor(x * spaceX), Math.floor(y * spaceY), Math.floor(z * spaceZ)];
    }

    function convertCoordinates(
        coords,                    // The input coordinates (min/max for x, y, z)
        volume,                    // The image volume
        targetDirection,           // The direction matrix of the target space
    ) {

        // Add 1 to max values to ensure that the max values are inclusive
        coords = Object.keys(coords).reduce((acc, axis) => {
            acc[axis] = {
                min: coords[axis].min,
                max: coords[axis].max + 1
            };
            return acc;
        }, {});

        const sourceDimensions = volume.dimensions
        const sourceOrigin = volume.origin
        const sourceSpacing = volume.spacing
        const sourceDirection = [
            [volume.direction[0], volume.direction[1], volume.direction[2]],
            [volume.direction[3], volume.direction[4], volume.direction[5]],
            [volume.direction[6], volume.direction[7], volume.direction[8]]
        ];
        const sourceDimensionsPhysical = math.dotMultiply(sourceDimensions, sourceSpacing) 

        // Calculate the transformation matrix from source to target direction
        const transformationMatrix = math.multiply(
            math.inv(targetDirection),  // Inverse of the target direction matrix
            math.inv(sourceDirection)   // Multiplied by inverse of source direction matrix
        );

        // Transform origin / spacing / dimensions based on the transformation matrix
        const targetOrigin = math.multiply(transformationMatrix, sourceOrigin)
        const targetSpacing = math.abs(math.dotMultiply(transformationMatrix, sourceSpacing)).map(row => math.sum(row))
        const targetDimensions = math.round(math.dotDivide(math.abs(math.multiply(transformationMatrix, math.dotMultiply(sourceDimensions, sourceSpacing))), targetSpacing))
        const targetDimensionsPhysical = math.dotMultiply(targetDimensions, targetSpacing)

        // Define the 8 corners of the cuboid in the source voxel space
        const sourceVoxelCorners = [
            [coords.x.min, coords.y.min, coords.z.min],  // Bottom-front-left corner
            [coords.x.min, coords.y.min, coords.z.max],  // Bottom-front-right corner
            [coords.x.min, coords.y.max, coords.z.min],  // Top-front-left corner
            [coords.x.min, coords.y.max, coords.z.max],  // Top-front-right corner
            [coords.x.max, coords.y.min, coords.z.min],  // Bottom-back-left corner
            [coords.x.max, coords.y.min, coords.z.max],  // Bottom-back-right corner
            [coords.x.max, coords.y.max, coords.z.min],  // Top-back-left corner
            [coords.x.max, coords.y.max, coords.z.max]   // Top-back-right corner
        ];

        // Scale voxel coordinates to physical space (updated to include origin for non-standard translations)
        const sourcePhysicalCorners = sourceVoxelCorners.map(corner =>
            math.add(
                sourceOrigin,                             // Add the origin of the source space
                math.dotMultiply(corner, sourceSpacing)   // Scale the corner coordinates by the source spacing
            )
        );

        // Apply the transformation matrix to convert physical coordinates from source to target space
        let targetPhysicalCorners = sourcePhysicalCorners.map(corner =>
            math.add(
                math.multiply(
                    transformationMatrix,                 // Apply the transformation matrix
                    math.subtract(corner, sourceOrigin)   // Subtract the source origin from the physical coordinates
                ),
                targetOrigin                              // Add the target origin to the transformed coordinates
            )
        );

        // Reapply the target origin to the transformed corners(comment out if not applying above)
        targetPhysicalCorners = math.subtract(targetPhysicalCorners, targetOrigin)

        // Reflect both min and max if min is negative (flip to other end of axis)
        for (let i = 0; i < 3; i++) {  // Iterate over x, y, z dimensions
            let column = math.column(targetPhysicalCorners, i).flat();  // Extract the i-th column (corresponding to x, y, or z)
            let minVal = math.min(column);  // Find the minimum value in this dimension

            if (minVal < 0) {  // If the minimum value is negative, reflect the coordinates
                targetPhysicalCorners =
                    targetPhysicalCorners.map(corner => {
                        // Reflect the negative value by adding the target dimension
                        corner[i] = targetDimensionsPhysical[i] + corner[i];
                        return corner;  // Return the modified corner
                });
            }
        }

        // Clip the voxel coordinates to ensure they stay within the target dimensions
        targetPhysicalCorners =
            targetPhysicalCorners.map(corner =>
                corner.map((value, index) =>
                    math.max(0, math.min(value, targetDimensionsPhysical[index]))
                )
            );

        // Applying rounding to get final physical coordinates
        targetPhysicalCorners = targetPhysicalCorners.map(corner =>
            corner.map(coord => math.round(coord))
        );

        // Convert physical corners to voxel space in the target plane
        // Not used, only for debugging
        let targetVoxelCorners = targetPhysicalCorners.map(corner =>
            corner.map((coord, index) => math.round(coord / targetSpacing[index]))
        );

        // Compute the final transformed coordinates (min/max for x, y, z)
        const transformedCoords = {
            x: {
                min: math.min(targetPhysicalCorners.map(corner => corner[0])),  // Minimum x-coordinate
                max: math.max(targetPhysicalCorners.map(corner => corner[0]))   // Maximum x-coordinate
            },
            y: {
                min: math.min(targetPhysicalCorners.map(corner => corner[1])),  // Minimum y-coordinate
                max: math.max(targetPhysicalCorners.map(corner => corner[1]))   // Maximum y-coordinate
            },
            z: {
                min: math.min(targetPhysicalCorners.map(corner => corner[2])),  // Minimum z-coordinate
                max: math.max(targetPhysicalCorners.map(corner => corner[2]))   // Maximum z-coordinate
            }
        };

        // Return the transformed coordinates
        return transformedCoords;
    }

    console.log("finalCalc running");
    console.log(coords);

    const volume = cornerstone.cache.getVolume(volumeId);

    //// sagittal plane
    //// 1.3.6.1.4.1.14519.5.2.1.1600.1206.239190725826528812824420431561: 6994
    //const volume_test = {
    //    dimensions: [512, 512, 200],
    //    direction: [0, 1, 0, 0, 0, -1, -1, 0, 0],
    //    origin: [247.1846313, -816.7918091, 1671.210083],
    //    spacing: [3.192499876, 3.192499876, 2.5]
    //}
    //const coords_test = { x: { min: 231, max: 260 }, y: { min: 0, max: 221 }, z: { min: 0, max: 199 } };

    const targetDirection = [[-1, 0, 0], [0, -1, 0], [0, 0, 1]];  // RAS Axial

    const transformedCoords = convertCoordinates(coords, volume, targetDirection);

    console.log("Transformed coordinates in the target plane:");
    console.log(transformedCoords);

    let cornerPoints = {
        l: transformedCoords.x.min,
        r: transformedCoords.x.max,
        p: transformedCoords.y.min,
        a: transformedCoords.y.max,
        i: transformedCoords.z.min,
        s: transformedCoords.z.max
    }

    let centerPoint = [
        math.round((transformedCoords.x.max + transformedCoords.x.min) / 2),
        math.round((transformedCoords.y.max + transformedCoords.y.min) / 2),
        math.round((transformedCoords.z.max + transformedCoords.z.min) / 2)
    ];

    // Dimensions calculation
    const width = math.round(math.abs(transformedCoords.x.max - transformedCoords.x.min));
    const height = math.round(math.abs(transformedCoords.y.max - transformedCoords.y.min));
    const depth = math.round(math.abs(transformedCoords.z.max - transformedCoords.z.min));

    const output = {
        lr: centerPoint[0], // Left-right position
        pa: centerPoint[1], // Posterior-anterior position
        is: centerPoint[2], // Inferior-Superior position
        width: width,
        height: height,
        depth: depth,
        form: maskForm,
        function: maskFunction,
    };

    console.log(output);
    await setParameters(iec, output);
    alert("Submitted for masking!");
}


function CornerstoneViewer({ volumeName,
                             files,
                             iec }) {

  const { 

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
    maskForm, maskFunction,
  } = useContext(Context);

  const [ loading, setLoading ] = useState(true);
  const [ filesLoaded, setFilesLoaded ] = useState(false);

  // set a state variable that will save each viewport's normal/expanded/minimized state
  const [ expandedViewports, setExpandedViewports ] = useState([
    { id: 'axial', state: 'normal' },
    { id: 'sagittal', state: 'normal' },
    { id: 'coronal', state: 'normal' },
    { id: 't3d_coronal', state: 'normal' },
  ]);

  const containerRef = useRef(null);
  const renderingEngineRef = useRef(null);

  // console.log(
  //   ">>>>>>>>>>>>>>>>>>>>>>",
  //   "CornerstoneViewer() running",
  //   "loading is set to:", loading,
  // );

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
      const renderingEngine = cornerstone.getRenderingEngine('viewer_render_engine');
      if (renderingEngine) {
          renderingEngine.resize(true, true);
      }
      // console.log("Zoo---------------------------------ming! ")
      // console.log("Previous zoom level:");
      // save the zoom level in all viewports
      // const zoomLevel = [];
      // const renderingEngine = renderingEngineRef.current;
      // if (renderingEngine) {
      //   renderingEngine.getViewports().forEach((viewport, index) => {
      //     const camera = viewport.getCamera();
      //     zoomLevel[index] = camera.parallelScale;
      //     // console.log(index, viewport.id, zoomLevel[index] );
      //   });

      //   // save the pan location in all viewports
      //   const panLocation = [];
      //   renderingEngine.getViewports().forEach((viewport, index) => {
      //     const camera = viewport.getCamera();
      //     panLocation[index] = camera.position;
      //     // console.log(index, viewport.id, panLocation[index] );
      //   });

      //   renderingEngine.resize(true, true);

      //   setTimeout(() => {
      //     //console.log("Current zoom level:");
      //     renderingEngine.getViewports().forEach((viewport, index) => {
      //       const camera = viewport.getCamera();
      //       camera.parallelScale = zoomLevel[index];
      //       viewport.setCamera(camera);
      //       // console.log(index, viewport.id, camera.parallelScale );
      //       viewport.render();
      //     });

      //     // console.log("Current pan location:");
      //     renderingEngine.getViewports().forEach((viewport, index) => {
      //       const camera = viewport.getCamera();
      //       camera.position = panLocation[index];
      //       viewport.setCamera(camera);
      //       // console.log(index, viewport.id, camera.position );
      //       viewport.render();
      //     });
        
      //   }, 50);
      // }

      
    });

    function setupPanel(panelId) {
      const panelWrapper = document.createElement('div');
      const resizeButton = document.createElement('button');
      const panel = document.createElement('div');

      // set panelWrapper styles
      panelWrapper.id = panelId + '_wrapper';
      panelWrapper.style.display = 'block';
      panelWrapper.style.width = '100%';
      panelWrapper.style.height = '100%';
      panelWrapper.style.position = 'relative';
      panelWrapper.style.borderRadius = '8px';
      panelWrapper.style.overflow = 'hidden';
      panelWrapper.style.backgroundColor = 'black';
      panelWrapper.style.visibility = 'hidden';

      // remove default button styling
      resizeButton.style.border = 'none';
      resizeButton.style.outline = 'none';
      resizeButton.style.cursor = 'pointer';
      resizeButton.style.backgroundColor = 'transparent';
      resizeButton.style.padding = '8px';

      // set resizeButton backgorund image to the resizeButtonLogo
      resizeButton.id = panelId + '_resize_button';
      //resizeButton.innerHTML = '<span class="material-symbols-rounded" style="color: white">open_in_full</span>';
      resizeButton.style.backgroundColor = '#424242';
      resizeButton.style.color = 'white';
      resizeButton.classList.add('material-symbols-rounded');
      resizeButton.textContent = 'open_in_full';
      // resizeButton.style.backgroundImage = `url(${resizeButtonLogo})`;
      // resizeButton.style.backgroundSize = 'contain';
      // resizeButton.style.backgroundRepeat = 'no-repeat';
      // resizeButton.style.backgroundPosition = 'center';
      // resizeButton.style.padding = '8px 8px';
      // resizeButton.style.paddingBottom = '3px';
      ///resizeButton.style.width = '30px';
      //resizeButton.style.height = '30px';
      resizeButton.style.position = 'absolute';
      resizeButton.style.top = '10px';
      resizeButton.style.left = '10px';
      resizeButton.style.zIndex = '1000';
      resizeButton.style.display = 'none';

      resizeButton.onmouseover = () => {  
        resizeButton.style.backgroundColor = 'rgb(59 130 246)';
      };
      resizeButton.onmouseleave = () => {  
        resizeButton.style.backgroundColor = '#424242';
      };

      // set button to show when mouse is over panelWrapper
      panelWrapper.onmouseover = () => {  
        resizeButton.style.display = 'block';
      };
      panelWrapper.onmouseout = () => {  resizeButton.style.display = 'none'; };
      
      // on resizeButton click, set the panelWrapper to be full viewport size
      resizeButton.onclick = (event) => {
        // panelWrapper.style.width = '100vw';
        // panelWrapper.style.height = '100vh';
        // panelWrapper.style.position = 'fixed';
        // panelWrapper.style.top = '0';
        // panelWrapper.style.left = '0';
        // panelWrapper.style.zIndex = '1000';
        // resizeButton.style.display = 'none';

        // Haydex: I can improve this code by using a state variable to keep track of the expanded viewport
        
        // Minimization
        if (event.currentTarget.parentNode.classList.contains('Expanded')) {
          event.currentTarget.textContent = 'open_in_full';
          event.currentTarget.title = 'Maximize';
          event.currentTarget.parentNode.classList.remove('Expanded');
          event.currentTarget.parentNode.style.gridColumn = 'span 1';
          event.currentTarget.parentNode.style.gridRow = 'span 1';
          // set the gridArea of the panelWrapper to the saved gridArea
          event.currentTarget.parentNode.style.gridArea = event.currentTarget.parentNode.getAttribute('data-gridArea');
          
          
          // Show all other minimized panelWrappers
          const allPanelWrappers = event.currentTarget.parentNode.parentNode.childNodes;
          allPanelWrappers.forEach((panelWrapper) => {
            if (panelWrapper.classList.contains('Minimized')) {
              panelWrapper.querySelector('button').title = 'Maximize';
              panelWrapper.style.visibility = 'visible';
              panelWrapper.style.display = 'block';
              panelWrapper.classList.remove('Minimized');
            }
          });
          // render all viewports
          renderingEngineRef.current.getViewports().forEach((viewport) => {
            viewport.render();
          });
          console.log('Minimized', event.currentTarget.parentNode.id);

        } else { // Maximization
          // console.log (event.currentTarget.parentNode.id);
          // Get the gridArea of the panelWrapper
          const gridArea = event.currentTarget.parentNode.style.gridArea;
          // save the gridArea into the panelWrapper
          event.currentTarget.parentNode.setAttribute('data-gridArea', gridArea);
          event.currentTarget.parentNode.style.gridColumn = 'span 2';
          event.currentTarget.parentNode.style.gridRow = 'span 2';
          event.currentTarget.parentNode.classList.add('Expanded');
          expandedViewports.id = event.currentTarget.parentNode.id;
          event.currentTarget.textContent = 'close_fullscreen';
          event.currentTarget.title = 'Minimize';
          
          // hide all other visible panelWrappers
          const allPanelWrappers = event.currentTarget.parentNode.parentNode.childNodes;
          allPanelWrappers.forEach((panelWrapper) => {
            if (panelWrapper.id !== event.currentTarget.parentNode.id && panelWrapper.style.visibility === 'visible') {
              panelWrapper.querySelector('button').title = 'Minimize';
              panelWrapper.style.visibility = 'hidden';
              panelWrapper.style.display = 'none';
              panelWrapper.classList.add('Minimized');
            }
          });
          // render all viewports
          renderingEngineRef.current.getViewports().forEach((viewport) => {
            viewport.render();
          });
          console.log('Expanded', event.currentTarget.parentNode.id);
        }
        
      };

      panel.id = panelId;
      panel.style.display = 'block';
      panel.style.width = '100%';
      panel.style.height = '100%';
      panel.style.borderRadius = '8px';
      panel.style.overflow = 'hidden';
      panel.style.backgroundColor = 'black';
      panel.oncontextmenu = e => e.preventDefault();
      resizeObserver.observe(panel);

      // add resizebutton and panel to panelWrapper
      panelWrapper.appendChild(panel);
      panelWrapper.appendChild(resizeButton);

      return panelWrapper;
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

      t3dToolGroup.addTool(cornerstoneTools.PanTool.toolName);
      t3dToolGroup.addTool(cornerstoneTools.ZoomTool.toolName);

      if (viewportNavigation === 'Pan') {
        // Pan
        // cornerstoneTools.addTool(cornerstoneTools.PanTool);
        t3dToolGroup.setToolActive(cornerstoneTools.PanTool.toolName, {
          bindings: [
            {
              mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary, // Right Click
            },
          ],
        });
      } else {
        // Zoom
        // cornerstoneTools.addTool(cornerstoneTools.ZoomTool);
        t3dToolGroup.setToolActive(cornerstoneTools.ZoomTool.toolName, {
          bindings: [
            {
              mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary, // Right Click
            },
          ],
        });
      }

      // Pan
      t3dToolGroup.setToolActive(cornerstoneTools.PanTool.toolName, {
          bindings: [
              {
                  mouseButton: cornerstoneTools.Enums.MouseBindings.Auxiliary, // Middle Click
              },
          ],
      });

      // Segmentation Display
      // cornerstoneTools.addTool(cornerstoneTools.SegmentationDisplayTool);
      t3dToolGroup.addTool(cornerstoneTools.SegmentationDisplayTool.toolName);
      t3dToolGroup.setToolEnabled(cornerstoneTools.SegmentationDisplayTool.toolName);
    }

    function setupVolViewportTools() {

      const viewportColors = {
        ['vol_axial']: 'rgb(200, 0, 0)',
        ['vol_sagittal']: 'rgb(200, 200, 0)',
        ['vol_coronal']: 'rgb(0, 200, 0)',
      };

      const viewportReferenceLineControllable = [
          'vol_axial',
          'vol_sagittal',
          'vol_coronal',
      ];

      const viewportReferenceLineDraggableRotatable = [
          'vol_axial',
          'vol_sagittal',
          'vol_coronal',
      ];

      const viewportReferenceLineSlabThicknessControlsOn = [
          'vol_axial',
          'vol_sagittal',
          'vol_coronal',
      ];

      function getReferenceLineColor(viewportId) {
          return viewportColors[viewportId];
      }

      function getReferenceLineControllable(viewportId) {
          const index = viewportReferenceLineControllable.indexOf(viewportId);
          return index !== -1;
      }

      function getReferenceLineDraggableRotatable(viewportId) {
          const index = viewportReferenceLineDraggableRotatable.indexOf(viewportId);
          return index !== -1;
      }

      function getReferenceLineSlabThicknessControlsOn(viewportId) {
          const index =
              viewportReferenceLineSlabThicknessControlsOn.indexOf(viewportId);
          return index !== -1;
      }
      
      try {
        cornerstoneTools.addTool(cornerstoneTools.RectangleScissorsTool);
        cornerstoneTools.addTool(cornerstoneTools.SegmentationDisplayTool);
        cornerstoneTools.addTool(cornerstoneTools.StackScrollMouseWheelTool);
        cornerstoneTools.addTool(cornerstoneTools.PanTool);
        cornerstoneTools.addTool(cornerstoneTools.ZoomTool);
        cornerstoneTools.addTool(cornerstoneTools.CrosshairsTool);
        cornerstoneTools.addTool(cornerstoneTools.WindowLevelTool);
      } catch (error) {
        // console.log("errors while loading tools:", error);
      }

      // Create group and add viewports
      // TODO: should the render engine be coming from a var instead?
      const group = getOrCreateToolgroup('vol_tool_group');
      group.addViewport('vol_axial', 'viewer_render_engine');
      group.addViewport('vol_sagittal', 'viewer_render_engine');
      group.addViewport('vol_coronal', 'viewer_render_engine');

      // Stack Scroll Tool
      group.addTool(cornerstoneTools.StackScrollMouseWheelTool.toolName);
      group.setToolActive(cornerstoneTools.StackScrollMouseWheelTool.toolName);

      group.addTool(cornerstoneTools.SegmentationDisplayTool.toolName);
      // group.setToolActive(cornerstoneTools.SegmentationDisplayTool.toolName);
      // group.setToolEnabled(cornerstoneTools.SegmentationDisplayTool.toolName);

      group.addTool(cornerstoneTools.RectangleScissorsTool.toolName);

      if (rectangleScissors)  {
        group.setToolActive(cornerstoneTools.RectangleScissorsTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Primary },
          ]
        });
      } 

      group.addTool(cornerstoneTools.PanTool.toolName);
      group.addTool(cornerstoneTools.ZoomTool.toolName);

      if (viewportNavigation === 'Pan') {
        group.setToolActive(cornerstoneTools.PanTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary },
          ],
        });
      } else {
        group.setToolActive(cornerstoneTools.ZoomTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary },
          ],
        });
      }

      // Pan
      group.setToolActive(cornerstoneTools.PanTool.toolName, {
          bindings: [
              {
                  mouseButton: cornerstoneTools.Enums.MouseBindings.Auxiliary, // Middle Click
              },
          ],
      });

      // Window Level
      group.addTool(cornerstoneTools.WindowLevelTool.toolName);

      if (windowLevel) {
        group.setToolActive(cornerstoneTools.WindowLevelTool.toolName, {
            bindings: [
                {
                    mouseButton: cornerstoneTools.Enums.MouseBindings.Primary, // Left Click
                },
            ],
        });
      }
      
      group.addTool(cornerstoneTools.CrosshairsTool.toolName, {
        getReferenceLineColor,
        getReferenceLineControllable,
        getReferenceLineDraggableRotatable,
        getReferenceLineSlabThicknessControlsOn,
      });

      if (crosshairs) {
        group.setToolActive(cornerstoneTools.CrosshairsTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Primary },
          ],
        });
      }

      const volVOISyncronizer = cornerstoneTools.synchronizers.createVOISynchronizer("vol_voi_syncronizer");

      ['vol_axial', 'vol_sagittal', 'vol_coronal'].forEach((viewport) => {
          volVOISyncronizer.add({ renderingEngineId: 'viewer_render_engine', viewportId: viewport });
      });

    }

    function setupMipViewportTools() {

      const viewportColors = {
        ['mip_axial']: 'rgb(200, 0, 0)',
        ['mip_sagittal']: 'rgb(200, 200, 0)',
        ['mip_coronal']: 'rgb(0, 200, 0)',
      };

      const viewportReferenceLineControllable = [
          'mip_axial',
          'mip_sagittal',
          'mip_coronal',
      ];

      const viewportReferenceLineDraggableRotatable = [
          'mip_axial',
          'mip_sagittal',
          'mip_coronal',
      ];

      const viewportReferenceLineSlabThicknessControlsOn = [
          'mip_axial',
          'mip_sagittal',
          'mip_coronal',
      ];

      function getReferenceLineColor(viewportId) {
          return viewportColors[viewportId];
      }

      function getReferenceLineControllable(viewportId) {
          const index = viewportReferenceLineControllable.indexOf(viewportId);
          return index !== -1;
      }

      function getReferenceLineDraggableRotatable(viewportId) {
          const index = viewportReferenceLineDraggableRotatable.indexOf(viewportId);
          return index !== -1;
      }

      function getReferenceLineSlabThicknessControlsOn(viewportId) {
          const index =
              viewportReferenceLineSlabThicknessControlsOn.indexOf(viewportId);
          return index !== -1;
      }
      
      try {
        cornerstoneTools.addTool(cornerstoneTools.RectangleScissorsTool);
        cornerstoneTools.addTool(cornerstoneTools.SegmentationDisplayTool);
        cornerstoneTools.addTool(cornerstoneTools.StackScrollMouseWheelTool);
        cornerstoneTools.addTool(cornerstoneTools.PanTool);
        cornerstoneTools.addTool(cornerstoneTools.ZoomTool);
        cornerstoneTools.addTool(cornerstoneTools.CrosshairsTool);
        cornerstoneTools.addTool(cornerstoneTools.WindowLevelTool);
      } catch (error) {
        // console.log("errors while loading tools:", error);
      }

      // Create group and add viewports
      // TODO: should the render engine be coming from a var instead?
      const group = getOrCreateToolgroup('mip_tool_group');
      group.addViewport('mip_axial', 'viewer_render_engine');
      group.addViewport('mip_sagittal', 'viewer_render_engine');
      group.addViewport('mip_coronal', 'viewer_render_engine');

      // Stack Scroll Tool
      group.addTool(cornerstoneTools.StackScrollMouseWheelTool.toolName);
      group.setToolActive(cornerstoneTools.StackScrollMouseWheelTool.toolName);

      group.addTool(cornerstoneTools.SegmentationDisplayTool.toolName);
      // group.setToolActive(cornerstoneTools.SegmentationDisplayTool.toolName);
      // group.setToolEnabled(cornerstoneTools.SegmentationDisplayTool.toolName);

      group.addTool(cornerstoneTools.RectangleScissorsTool.toolName);

      if (rectangleScissors)  {
        group.setToolActive(cornerstoneTools.RectangleScissorsTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Primary },
          ]
        });
      } 

      group.addTool(cornerstoneTools.PanTool.toolName);
      group.addTool(cornerstoneTools.ZoomTool.toolName);

      if (viewportNavigation === 'Pan') {
        group.setToolActive(cornerstoneTools.PanTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary },
          ],
        });
      } else {
        group.setToolActive(cornerstoneTools.ZoomTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary },
          ],
        });
      }

      // Pan
      group.setToolActive(cornerstoneTools.PanTool.toolName, {
          bindings: [
              {
                  mouseButton: cornerstoneTools.Enums.MouseBindings.Auxiliary, // Middle Click
              },
          ],
      });

      // Window Level
      group.addTool(cornerstoneTools.WindowLevelTool.toolName);

      if (windowLevel) {
        group.setToolActive(cornerstoneTools.WindowLevelTool.toolName, {
            bindings: [
                {
                    mouseButton: cornerstoneTools.Enums.MouseBindings.Primary, // Left Click
                },
            ],
        });
      }
      
      group.addTool(cornerstoneTools.CrosshairsTool.toolName, {
        getReferenceLineColor,
        getReferenceLineControllable,
        getReferenceLineDraggableRotatable,
        getReferenceLineSlabThicknessControlsOn,
      });

      if (crosshairs) {
        group.setToolActive(cornerstoneTools.CrosshairsTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Primary },
          ],
        });
      }

      const mipVOISyncronizer = cornerstoneTools.synchronizers.createVOISynchronizer("mip_voi_syncronizer");

      ['mip_axial', 'mip_sagittal', 'mip_coronal'].forEach((viewport) => {
          mipVOISyncronizer.add({ renderingEngineId: 'viewer_render_engine', viewportId: viewport });
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

      if (layout === 'Masker' || layout === 'MaskerVR' || layout === 'MaskerReview') {
        const viewportInput = [];

        container.style.display = 'grid';
        if (view === 'All') {
          container.style.gridTemplateColumns = 'repeat(3, 1fr)';
          container.style.gridTemplateRows = 'repeat(3, 1fr)';
        } else {
          container.style.gridTemplateColumns = 'repeat(2, 1fr)';
          container.style.gridTemplateRows = 'repeat(2, 1fr)';
        }

        container.style.gridGap = '6px';
        container.style.width = '100%';
        container.style.height = '100%';

        const volAxialContent = setupPanel('vol_axial');
        const volSagittalContent = setupPanel('vol_sagittal');
        const volCoronalContent = setupPanel('vol_coronal');
        const mipAxialContent = setupPanel('mip_axial');
        const mipSagittalContent = setupPanel('mip_sagittal');
        const mipCoronalContent = setupPanel('mip_coronal');
        const t3dCoronalContent = setupPanel('t3d_coronal');
        
        container.appendChild(volAxialContent);
        container.appendChild(volSagittalContent);
        container.appendChild(volCoronalContent);
        container.appendChild(mipAxialContent);
        container.appendChild(mipSagittalContent);
        container.appendChild(mipCoronalContent);
        container.appendChild(t3dCoronalContent);

        viewportInput.push(
          {
            viewportId: 'vol_axial',
            type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
            element: volAxialContent.childNodes[0],
            defaultOptions: {
              orientation: cornerstone.Enums.OrientationAxis.AXIAL,
            },
          },  
          {
            viewportId: 'vol_sagittal',
            type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
            element: volSagittalContent.childNodes[0],
            defaultOptions: {
              orientation: cornerstone.Enums.OrientationAxis.SAGITTAL,
            },
          },
          {
            viewportId: 'vol_coronal',
            type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
            element: volCoronalContent.childNodes[0],
            defaultOptions: {
              orientation: cornerstone.Enums.OrientationAxis.CORONAL,
            },
          },
          {
            viewportId: 'mip_axial',
            type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
            element: mipAxialContent.childNodes[0],
            defaultOptions: {
              orientation: cornerstone.Enums.OrientationAxis.AXIAL,
            },
          },
          {
            viewportId: 'mip_sagittal',
            type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
            element: mipSagittalContent.childNodes[0],
            defaultOptions: {
              orientation: cornerstone.Enums.OrientationAxis.SAGITTAL,
            },
          },
          {
            viewportId: 'mip_coronal',
            type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
            element: mipCoronalContent.childNodes[0],
            defaultOptions: {
              orientation: cornerstone.Enums.OrientationAxis.CORONAL,
            },
          },
          {
            viewportId: 't3d_coronal',
            type: cornerstone.Enums.ViewportType.VOLUME_3D,
            element: t3dCoronalContent.childNodes[0],
            defaultOptions: {
              orientation: cornerstone.Enums.OrientationAxis.CORONAL,
            },
          }
        );

        renderingEngine.setViewports(viewportInput);
      }

      setupVolViewportTools();
      setupMipViewportTools();
      setup3dViewportTools();

      setLoading(false);
      
    }

    run();

    return () => {
      cache.purgeCache();
      resizeObserver.disconnect();
    };
  }, [layout]);

  useEffect(() => {
    
    // check if files are loaded before setting viewports
    if (!filesLoaded) {
      return;
    }

    // console.log("viewports loaded");
    
    const container = containerRef.current;

    const volAxialContent = document.getElementById('vol_axial_wrapper');
    const volSagittalContent = document.getElementById('vol_sagittal_wrapper');
    const volCoronalContent = document.getElementById('vol_coronal_wrapper');
    const mipAxialContent = document.getElementById('mip_axial_wrapper');
    const mipSagittalContent = document.getElementById('mip_sagittal_wrapper');
    const mipCoronalContent = document.getElementById('mip_coronal_wrapper');
    const t3dCoronalContent = document.getElementById('t3d_coronal_wrapper');

    if (view === 'All') {
      // set all viewport panels to be visible

      container.style.gridTemplateColumns = 'repeat(3, 1fr)';
      container.style.gridTemplateRows = 'repeat(3, 1fr)';

      volAxialContent.style.visibility = 'visible';
      volSagittalContent.style.visibility = 'visible';
      volCoronalContent.style.visibility = 'visible';
      volAxialContent.style.display = 'block';
      volSagittalContent.style.display = 'block';
      volCoronalContent.style.display = 'block';

      mipAxialContent.style.visibility = 'visible';
      mipSagittalContent.style.visibility = 'visible';
      mipCoronalContent.style.visibility = 'visible';
      mipAxialContent.style.display = 'block';
      mipSagittalContent.style.display = 'block';
      mipCoronalContent.style.display = 'block';

      t3dCoronalContent.style.visibility = 'visible';
      t3dCoronalContent.style.display = 'block';
      //set t3dCoronalContent to expand to take up 3 columns
      t3dCoronalContent.style.gridColumn = 'span 3';
    } else if (view === 'Volume') {

      // Haydex: I can improve this code by using a state variable to keep track of the expanded viewport

      // remove all viewports Minimized and Expanded classes
      const allPanelWrappers = container.childNodes;
      allPanelWrappers.forEach((panelWrapper) => {
        panelWrapper.classList.remove('Minimized');
        panelWrapper.classList.remove('Expanded');
        panelWrapper.querySelector('button').textContent = 'open_in_full';
        panelWrapper.querySelector('button').title = 'Maximize';
      });

      container.style.gridTemplateColumns = 'repeat(2, 1fr)';
      container.style.gridTemplateRows = 'repeat(2, 1fr)';

      // set volume viewport panels to be visible

      volAxialContent.style.visibility = 'visible';
      volSagittalContent.style.visibility = 'visible';
      volCoronalContent.style.visibility = 'visible';
      volAxialContent.style.display = 'block';
      volSagittalContent.style.display = 'block';
      volCoronalContent.style.display = 'block';

      mipAxialContent.style.visibility = 'hidden';
      mipSagittalContent.style.visibility = 'hidden';
      mipCoronalContent.style.visibility = 'hidden';
      mipAxialContent.style.display = 'none';
      mipSagittalContent.style.display = 'none';
      mipCoronalContent.style.display = 'none';

      t3dCoronalContent.style.visibility = 'visible';
      t3dCoronalContent.style.display = 'block';

      // move t3dCoronalContent to the top right cell of the grid
      t3dCoronalContent.style.gridColumn = 2;
      t3dCoronalContent.style.gridRow = 1;

      // move volCoronalContent to the bottom left cell of the grid
      volCoronalContent.style.gridColumn = 1;
      volCoronalContent.style.gridRow = 2;

      volSagittalContent.style.gridColumn = 2;
      volSagittalContent.style.gridRow = 2;

      volAxialContent.style.gridColumn = 1;
      volAxialContent.style.gridRow = 1;
      
      // t3dCoronalContent.style.gridColumn = 'span 3';
    } else if (view === 'Projection') {

      // Haydex: I can improve this code by using a state variable to keep track of the expanded viewport

      // remove all viewports Minimized and Expanded classes
      const allPanelWrappers = container.childNodes;
      allPanelWrappers.forEach((panelWrapper) => {
        panelWrapper.classList.remove('Minimized');
        panelWrapper.classList.remove('Expanded');
      });

      container.style.gridTemplateColumns = 'repeat(2, 1fr)';
      container.style.gridTemplateRows = 'repeat(2, 1fr)';

      // set projection viewport panels to be visible
      volAxialContent.style.visibility = 'hidden';
      volSagittalContent.style.visibility = 'hidden';
      volCoronalContent.style.visibility = 'hidden';
      volAxialContent.style.display = 'none';
      volSagittalContent.style.display = 'none';
      volCoronalContent.style.display = 'none';
      
      mipAxialContent.style.visibility = 'visible';
      mipSagittalContent.style.visibility = 'visible';
      mipCoronalContent.style.visibility = 'visible';
      mipAxialContent.style.display = 'block';
      mipSagittalContent.style.display = 'block';
      mipCoronalContent.style.display = 'block';

      t3dCoronalContent.style.visibility = 'visible';
      t3dCoronalContent.style.display = 'block';

      // move t3dCoronalContent to the top right cell of the grid
      t3dCoronalContent.style.gridColumn = 2;
      t3dCoronalContent.style.gridRow = 1;

      // move mipCoronalContent to the bottom left cell of the grid
      mipCoronalContent.style.gridColumn = 1;
      mipCoronalContent.style.gridRow = 2;

      mipSagittalContent.style.gridColumn = 2;
      mipSagittalContent.style.gridRow = 2;

      mipAxialContent.style.gridColumn = 1;
      mipAxialContent.style.gridRow = 1;

      // t3dCoronalContent.style.gridColumn = 'span 3';
    }
    
  }, [view, filesLoaded]);

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
      
      // console.log("about to setVolumes for rendering engine:", renderingEngine);
      
      await cornerstone.setVolumesForViewports(
          renderingEngine,
          [{ volumeId: volumeId }],
          ['vol_axial', 'vol_sagittal', 'vol_coronal']
      );

      const volDimensions = volume.dimensions;

      const volSlab = Math.sqrt(
          volDimensions[0] * volDimensions[0] +
          volDimensions[1] * volDimensions[1] +
          volDimensions[2] * volDimensions[2]
      );

      // Add volumes to MIP viewports
      await cornerstone.setVolumesForViewports(
          renderingEngine,
          [
              //https://www.cornerstonejs.org/api/core/namespace/Types#IVolumeInput
              {
                  volumeId: volumeId,
                  blendMode: cornerstone.Enums.BlendModes.MAXIMUM_INTENSITY_BLEND,
                  slabThickness: volSlab,
              },
          ],
          ['mip_axial', 'mip_sagittal', 'mip_coronal']
      );

      await cornerstone.setVolumesForViewports(
        renderingEngine, 
        [{ volumeId: volumeId }], 
        ['t3d_coronal']
      ).then(() => {
        const viewport = renderingEngine.getViewport('t3d_coronal');
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

      await cornerstoneTools.segmentation.addSegmentationRepresentations(
        'mip_tool_group',
        [
          {
            segmentationId: segId,
            type: cornerstoneTools.Enums.SegmentationRepresentations.Labelmap,
          },
        ]
      );

      setFilesLoaded(true);
      
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
      // console.log(cornerstone.cache.getVolumes());
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

  useEffect(() => {

    // Volumes
    const volToolGroup = cornerstoneTools.ToolGroupManager.getToolGroup('vol_tool_group');

    if (volToolGroup) {
      // Add the WindowLevelTool if it hasn't been added already
      
      if (!volToolGroup.getToolInstance(cornerstoneTools.WindowLevelTool.toolName)) {
        
        cornerstoneTools.addTool(cornerstoneTools.WindowLevelTool);
        volToolGroup.addTool(cornerstoneTools.WindowLevelTool.toolName);
      }

      // Activate or deactivate the WindowLevelTool based on the windowLevel state
      if (windowLevel) {
        
        volToolGroup.setToolActive(cornerstoneTools.WindowLevelTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Primary },
          ],
        });
      } else {
        volToolGroup.setToolDisabled(cornerstoneTools.WindowLevelTool.toolName);
      }
    }

    // MIPs
    const mipToolGroup = cornerstoneTools.ToolGroupManager.getToolGroup('mip_tool_group');

    if (mipToolGroup) {
      // Add the WindowLevelTool if it hasn't been added already
      
      if (!mipToolGroup.getToolInstance(cornerstoneTools.WindowLevelTool.toolName)) {
        
        cornerstoneTools.addTool(cornerstoneTools.WindowLevelTool);
        mipToolGroup.addTool(cornerstoneTools.WindowLevelTool.toolName);
      }

      // Activate or deactivate the WindowLevelTool based on the windowLevel state
      if (windowLevel) {
        
        mipToolGroup.setToolActive(cornerstoneTools.WindowLevelTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Primary },
          ],
        });
      } else {
        mipToolGroup.setToolDisabled(cornerstoneTools.WindowLevelTool.toolName);
      }
    }
  }, [windowLevel]);

  useEffect(() => {

    // Volumes
    const volToolGroup = cornerstoneTools.ToolGroupManager.getToolGroup('vol_tool_group');
    
    if (volToolGroup) {

      // Activate or deactivate the CrosshairsTool based on the crosshairs state
      if (crosshairs) {
        volToolGroup.setToolActive(cornerstoneTools.CrosshairsTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Primary },
          ],
        });
      } else {
        volToolGroup.setToolDisabled(cornerstoneTools.CrosshairsTool.toolName);
      }
    }

    // MIPs
    const mipToolGroup = cornerstoneTools.ToolGroupManager.getToolGroup('mip_tool_group');
    
    if (mipToolGroup) {
      // Activate or deactivate the CrosshairsTool based on the crosshairs state
      if (crosshairs) {
        mipToolGroup.setToolActive(cornerstoneTools.CrosshairsTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Primary },
          ],
        });
      } else {
        mipToolGroup.setToolDisabled(cornerstoneTools.CrosshairsTool.toolName);
      }
    }
  }, [crosshairs]);

  useEffect(() => {

    // Volumes
    const volToolGroup = cornerstoneTools.ToolGroupManager.getToolGroup('vol_tool_group');

    if (volToolGroup) {
      // Add the RectangleScissorsTool if it hasn't been added already
      
      if (!volToolGroup.getToolInstance(cornerstoneTools.RectangleScissorsTool.toolName)) {
        
        cornerstoneTools.addTool(cornerstoneTools.RectangleScissorsTool);
        volToolGroup.addTool(cornerstoneTools.RectangleScissorsTool.toolName);
      }

      // Activate or deactivate the RectangleScissorsTool based on the rectangleScissors state
      if (rectangleScissors) {
        
        volToolGroup.setToolActive(cornerstoneTools.RectangleScissorsTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Primary },
          ],
        });
        
      } else {
        volToolGroup.setToolDisabled(cornerstoneTools.RectangleScissorsTool.toolName);
      }
    }

    // MIPs
    const mipToolGroup = cornerstoneTools.ToolGroupManager.getToolGroup('mip_tool_group');

    if (mipToolGroup) {
      // Add the RectangleScissorsTool if it hasn't been added already
      
      if (!mipToolGroup.getToolInstance(cornerstoneTools.RectangleScissorsTool.toolName)) {
        
        cornerstoneTools.addTool(cornerstoneTools.RectangleScissorsTool);
        mipToolGroup.addTool(cornerstoneTools.RectangleScissorsTool.toolName);
      }

      // Activate or deactivate the RectangleScissorsTool based on the rectangleScissors state
      if (rectangleScissors) {
        
        mipToolGroup.setToolActive(cornerstoneTools.RectangleScissorsTool.toolName, {
          bindings: [
            { mouseButton: cornerstoneTools.Enums.MouseBindings.Primary },
          ],
        });
        
      } else {
        mipToolGroup.setToolDisabled(cornerstoneTools.RectangleScissorsTool.toolName);
      }
    }
  }, [rectangleScissors]);

  useEffect(() => {

    // Volumes
    const volToolGroup = cornerstoneTools.ToolGroupManager.getToolGroup('vol_tool_group');
    if (viewportNavigation === 'Pan') {
      if (volToolGroup) {
        
        volToolGroup.setToolDisabled(cornerstoneTools.ZoomTool.toolName);
        volToolGroup.setToolActive(cornerstoneTools.PanTool.toolName, {
          bindings: [ { mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary } ],
        });
        // access the t3d_tool_group and do the same
        const t3dToolGroup = cornerstoneTools.ToolGroupManager.getToolGroup('t3d_tool_group');
        t3dToolGroup.setToolDisabled(cornerstoneTools.ZoomTool.toolName);
        t3dToolGroup.setToolActive(cornerstoneTools.PanTool.toolName, {
          bindings: [ { mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary } ],
        });
      }
    } else {
      if (volToolGroup) {
        volToolGroup.setToolDisabled(cornerstoneTools.PanTool.toolName);
        volToolGroup.setToolActive(cornerstoneTools.ZoomTool.toolName, {
          bindings: [ { mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary } ],
        });
        // access the t3d_tool_group and do the same
        const t3dToolGroup = cornerstoneTools.ToolGroupManager.getToolGroup('t3d_tool_group');
        t3dToolGroup.setToolDisabled(cornerstoneTools.PanTool.toolName);
        t3dToolGroup.setToolActive(cornerstoneTools.ZoomTool.toolName, {
          bindings: [ { mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary } ],
        });
      }
    }

    // MIPs
    const mipToolGroup = cornerstoneTools.ToolGroupManager.getToolGroup('mip_tool_group');
    if (viewportNavigation === 'Pan') {
      if (mipToolGroup) {
        
        mipToolGroup.setToolDisabled(cornerstoneTools.ZoomTool.toolName);
        mipToolGroup.setToolActive(cornerstoneTools.PanTool.toolName, {
          bindings: [ { mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary } ],
        });
      }
    } else {
      if (mipToolGroup) {
        mipToolGroup.setToolDisabled(cornerstoneTools.PanTool.toolName);
        mipToolGroup.setToolActive(cornerstoneTools.ZoomTool.toolName, {
          bindings: [ { mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary } ],
        });
      }
    }
  }, [viewportNavigation]);

  useEffect(() => {
    
    if (resetViewports) {

      setZoom(defaults.zoom);
      setOpacity(defaults.opacity);
      setSelectedPreset(defaults.selectedPreset);
      setWindowLevel(defaults.windowLevel);
      setCrosshairs(defaults.crosshairs);
      setRectangleScissors(defaults.rectangleScissors);

      // Haydex: I can improve this code by using a state variable to keep track of the expanded viewport
      setView(defaults.view + " "); // force a re-render
      setTimeout(() => {
       setView(defaults.view);
      }, 50);

      setViewportNavigation(defaults.viewportNavigation);
      setResetViewports(defaults.resetViewports);

      // Remove all segmentations
      const segVolume = cornerstone.cache.getVolume(segId);
      // console.log("segVolume is", segVolume);
      const scalarData = segVolume.scalarData;
      // console.log("scalarData is", scalarData);
      scalarData.fill(0);
      // redraw segmentation
      cornerstoneTools.segmentation
        .triggerSegmentationEvents
        .triggerSegmentationDataModified(segId);
  
      // reset cameras for all the viewports that its wrapper is visible
      const renderingEngine = cornerstone.getRenderingEngine('viewer_render_engine');
      renderingEngine.getViewports().forEach((viewport) => {
        // if the viewport parent node is visible, reset camera
        const viewportElement = document.getElementById(viewport.id);
        if (viewportElement.parentNode.style.display !== 'none') {
          viewport.resetCamera(true, true, true, true);
          viewport.render();
        }
      });
      
      // Wait 100ms then reset the cameras and crosshairs of all the viewports that its wrapper is visible
      setTimeout(() => {
        
        // if the viewport parent node is visible, reset camera
        renderingEngine.getViewports().forEach((viewport) => {
          const viewportElement = document.getElementById(viewport.id);
          if (viewportElement.parentNode.style.display !== 'none') {
            viewport.resetCamera(true, true, true, true);
            viewport.render();
          }
        });

        // reset crosshairs tool slab thickness if the volume viewport is visible
        if (document.getElementById('vol_axial_wrapper').style.display !== 'none') {
          const volToolGroup = cornerstoneTools.ToolGroupManager.getToolGroup('vol_tool_group');
          const crosshairsToolInstance = volToolGroup.getToolInstance(cornerstoneTools.CrosshairsTool.toolName);
          crosshairsToolInstance.resetCrosshairs();
        }
      }, 150);
    }
  }, [resetViewports]);

  async function handleExpandSelection() {
    // console.log('handleExpandSelection called, setId is', segId);
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
    await finalCalc(coords, volumeId, iec, maskForm, maskFunction);
  }
  async function handleMarkAccepted() {
    await flagAsAccepted(iec);
    alert("Marked as accepted!");
  }
  async function handleMarkRejected() {
    await flagAsRejected(iec);
    alert("Marked as rejected!");
  }
  async function handleMarkSkipped() {
    await flagAsSkipped(iec);
    alert("Marked as skipped!");
  }
  async function handleMarkNonmaskable() {
    await flagAsNonmaskable(iec);
    alert("Marked as Non-Maskable!");
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
        onMarkAccepted={handleMarkAccepted}
        onMarkRejected={handleMarkRejected}
        onMarkSkip={handleMarkSkipped}
        onMarkNonMaskable={handleMarkNonmaskable}
      />
    </>
  );
};

export default CornerstoneViewer;
