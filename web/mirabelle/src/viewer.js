import * as cornerstone from '@cornerstonejs/core';
import * as cornerstoneTools from '@cornerstonejs/tools';

import {
    initVolumeLoader,
    initCornerstoneDICOMImageLoader
} from './utilities.js';

//import { cornerstoneNiftiImageVolumeLoader } from '@cornerstonejs/nifti-volume-loader';

// ============================= //
// Page Elements
// ============================= //

let viewerFunction = null;
let viewerType = null;
let viewerConfig = null;

let fileID = null;
let seriesUID = null;
let timepointID = null;
let groupID = null;

let file = null;
let fileList = null;
let groupList = null;

let volumeId = null;
let volume = null;


// Adjusts the rendered size when the window size changes
const resizeObserver = new ResizeObserver(() => {
    // console.log('Size changed');

    const renderingEngine = cornerstone.getRenderingEngine('viewer_render_engine');

    if (renderingEngine) {
        renderingEngine.resize(true, false);
    }
});

// ============================= //
// Page Functions
// ============================= //

function setupVolPanel() {

    const volGrid = document.createElement('div')
    volGrid.id = 'vol_grid';

    const volAxialContent = document.createElement('div')
    volAxialContent.id = 'vol_axial';
    const volSagittalContent = document.createElement('div')
    volSagittalContent.id = 'vol_sagittal';
    const volCoronalContent = document.createElement('div')
    volCoronalContent.id = 'vol_coronal';

    document.getElementById('vol_content').appendChild(volGrid);

    volGrid.style.display = 'flex';
    volGrid.style.flexDirection = 'row';
    volGrid.style.width = '100%';
    volGrid.style.height = '100%';

    volAxialContent.style.gridColumnStart = '1';
    volAxialContent.style.gridRowStart = '1';
    volSagittalContent.style.gridColumnStart = '2';
    volSagittalContent.style.gridRowStart = '1';
    volCoronalContent.style.gridColumnStart = '3';
    volCoronalContent.style.gridRowStart = '1';

    volGrid.appendChild(volAxialContent);
    volGrid.appendChild(volSagittalContent);
    volGrid.appendChild(volCoronalContent);

    const elementList = [
        volAxialContent,
        volSagittalContent,
        volCoronalContent,
    ];

    elementList.forEach((element) => {
        element.style.width = '100%';
        element.style.height = '100%';
        element.oncontextmenu = (e) => e.preventDefault();
        resizeObserver.observe(element);
    });

    return { "axial": volAxialContent, "sagittal": volSagittalContent, "coronal": volCoronalContent }
}

function setupMipPanel() {

    const mipGrid = document.createElement('div')
    mipGrid.id = 'mip_grid';
    const mipAxialContent = document.createElement('div')
    mipAxialContent.id = 'mip_axial';
    const mipSagittalContent = document.createElement('div')
    mipSagittalContent.id = 'mip_sagittal';
    const mipCoronalContent = document.createElement('div')
    mipCoronalContent.id = 'mip_coronal';

    document.getElementById('mip_content').appendChild(mipGrid);

    mipGrid.style.display = 'flex';
    mipGrid.style.flexDirection = 'row';
    mipGrid.style.width = '100%';
    mipGrid.style.height = '100%';

    mipAxialContent.style.gridColumnStart = '1';
    mipAxialContent.style.gridRowStart = '1';
    mipSagittalContent.style.gridColumnStart = '2';
    mipSagittalContent.style.gridRowStart = '1';
    mipCoronalContent.style.gridColumnStart = '3';
    mipCoronalContent.style.gridRowStart = '1';

    mipGrid.appendChild(mipAxialContent);
    mipGrid.appendChild(mipSagittalContent);
    mipGrid.appendChild(mipCoronalContent);

    const elementList = [
        mipAxialContent,
        mipSagittalContent,
        mipCoronalContent,
    ];

    elementList.forEach((element) => {
        element.style.width = '100%';
        element.style.height = '100%';
        element.oncontextmenu = (e) => e.preventDefault();

        resizeObserver.observe(element);
    });

    return { "axial": mipAxialContent, "sagittal": mipSagittalContent, "coronal": mipCoronalContent }
}

function setup3dPanel() {

    const t3dGrid = document.createElement('div')
    t3dGrid.id = 't3d_grid';
    const t3dCoronalContent = document.createElement('div')
    t3dCoronalContent.id = 't3d_coronal';

    document.getElementById('t3d_content').appendChild(t3dGrid);

    t3dGrid.style.display = 'flex';
    t3dGrid.style.flexDirection = 'row';
    t3dGrid.style.width = '100%';
    t3dGrid.style.height = '100%';

    t3dCoronalContent.style.gridColumnStart = '1';
    t3dCoronalContent.style.gridRowStart = '1';

    t3dGrid.appendChild(t3dCoronalContent);

    t3dCoronalContent.style.width = '100%';
    t3dCoronalContent.style.height = '100%';
    t3dCoronalContent.oncontextmenu = (e) => e.preventDefault();

    resizeObserver.observe(t3dCoronalContent);

    return { "coronal": t3dCoronalContent }
}

function setupTools() {
    // Tools setup
    // --------------------------------
    cornerstoneTools.addTool(cornerstoneTools.StackScrollMouseWheelTool);
    cornerstoneTools.addTool(cornerstoneTools.SegmentationDisplayTool);
    cornerstoneTools.addTool(cornerstoneTools.ZoomTool);
    cornerstoneTools.addTool(cornerstoneTools.WindowLevelTool);
    cornerstoneTools.addTool(cornerstoneTools.PanTool);
    cornerstoneTools.addTool(cornerstoneTools.VolumeRotateMouseWheelTool);
    cornerstoneTools.addTool(cornerstoneTools.TrackballRotateTool);
    cornerstoneTools.addTool(cornerstoneTools.CrosshairsTool);

    setupVolTools();
    setupMipTools();
    setup3dTools();
}

function setupVolTools() {

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

    // Tool group setup
    const volToolGroup = cornerstoneTools.ToolGroupManager.createToolGroup('vol_tool_group');
    volToolGroup.addViewport('vol_axial', 'viewer_render_engine');
    volToolGroup.addViewport('vol_sagittal', 'viewer_render_engine');
    volToolGroup.addViewport('vol_coronal', 'viewer_render_engine');

    // Scroll Mouse Wheel
    volToolGroup.addTool(cornerstoneTools.StackScrollMouseWheelTool.toolName);
    volToolGroup.setToolActive(cornerstoneTools.StackScrollMouseWheelTool.toolName);

    // Segmentation Display
    volToolGroup.addTool(cornerstoneTools.SegmentationDisplayTool.toolName);
    volToolGroup.setToolEnabled(cornerstoneTools.SegmentationDisplayTool.toolName);

    // Window Level
    volToolGroup.addTool(cornerstoneTools.WindowLevelTool.toolName);
    volToolGroup.setToolActive(cornerstoneTools.WindowLevelTool.toolName, {
        bindings: [
            {
                mouseButton: cornerstoneTools.Enums.MouseBindings.Primary, // Left Click
            },
        ],
    });

    // Pan
    volToolGroup.addTool(cornerstoneTools.PanTool.toolName);
    volToolGroup.setToolActive(cornerstoneTools.PanTool.toolName, {
        bindings: [
            {
                mouseButton: cornerstoneTools.Enums.MouseBindings.Auxiliary, // Middle Click
            },
        ],
    });

    // Zoom
    volToolGroup.addTool(cornerstoneTools.ZoomTool.toolName);
    volToolGroup.setToolActive(cornerstoneTools.ZoomTool.toolName, {
        bindings: [
            {
                mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary, // Right Click
            },
        ],
    });

    // Crosshairs
    volToolGroup.addTool(cornerstoneTools.CrosshairsTool.toolName, {
        getReferenceLineColor,
        getReferenceLineControllable,
        getReferenceLineDraggableRotatable,
        getReferenceLineSlabThicknessControlsOn,
    });
    //volToolGroup.setToolPassive(cornerstoneTools.CrosshairsTool.toolName);
    //volToolGroup.setToolEnabled(cornerstoneTools.CrosshairsTool.toolName);

    const volVOISyncronizer = cornerstoneTools.synchronizers.createVOISynchronizer("vol_voi_syncronizer");

    ['vol_axial', 'vol_sagittal', 'vol_coronal'].forEach((viewport) => {
        volVOISyncronizer.add({ renderingEngineId: 'viewer_render_engine', viewportId: viewport });
    });

    const tool_panel = document.getElementById('vol_tools');

    const renderingEngine = cornerstone.getRenderingEngine('viewer_render_engine');

    const viewport = renderingEngine.getViewport('vol_axial');
    addButtonToToolbar({
        id: 'vol_reset_button',
        container: tool_panel,
        title: 'Reset Viewports',
        onClick: () => {
            renderingEngine.getViewports().forEach((viewport) => {
                // Needs to be called twice to ensure the camera is reset
                // Not sure why this is the case
                viewport.resetCamera(true, true, true, true);
                viewport.resetCamera(true, true, true, true);
            });
            renderingEngine.render();
        },
    });

    addToggleButtonToToolbar({
        id: 'vol_crosshair_button',
        container: tool_panel,
        title: 'Toggle Crosshairs',
        defaultToggle: false,
        onClick: async (toggle) => {
            const set_active = toggle;

            const toolGroup = cornerstoneTools.ToolGroupManager.getToolGroup('vol_tool_group');

            if (set_active) {
                toolGroup.setToolPassive(cornerstoneTools.CrosshairsTool.toolName);
            }
            else {
                toolGroup.setToolDisabled(cornerstoneTools.CrosshairsTool.toolName);
            }
        },
    });

}

function setupMipTools() {

    // Tool group setup
    const mipToolGroup = cornerstoneTools.ToolGroupManager.createToolGroup('mip_tool_group');
    mipToolGroup.addViewport('mip_axial', 'viewer_render_engine');
    mipToolGroup.addViewport('mip_sagittal', 'viewer_render_engine');
    mipToolGroup.addViewport('mip_coronal', 'viewer_render_engine');

    // Scroll Mouse Wheel
    mipToolGroup.addTool(cornerstoneTools.VolumeRotateMouseWheelTool.toolName);
    mipToolGroup.setToolActive(cornerstoneTools.VolumeRotateMouseWheelTool.toolName);

    // Segmentation Display
    mipToolGroup.addTool(cornerstoneTools.SegmentationDisplayTool.toolName);
    mipToolGroup.setToolEnabled(cornerstoneTools.SegmentationDisplayTool.toolName);

    // Window Level
    mipToolGroup.addTool(cornerstoneTools.WindowLevelTool.toolName);
    mipToolGroup.setToolActive(cornerstoneTools.WindowLevelTool.toolName, {
        bindings: [
            {
                mouseButton: cornerstoneTools.Enums.MouseBindings.Primary, // Left Click
            },
        ],
    });

    // Pan
    mipToolGroup.addTool(cornerstoneTools.PanTool.toolName);
    mipToolGroup.setToolActive(cornerstoneTools.PanTool.toolName, {
        bindings: [
            {
                mouseButton: cornerstoneTools.Enums.MouseBindings.Auxiliary, // Middle Click
            },
        ],
    });

    // Zoom
    mipToolGroup.addTool(cornerstoneTools.ZoomTool.toolName);
    mipToolGroup.setToolActive(cornerstoneTools.ZoomTool.toolName, {
        bindings: [
            {
                mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary, // Right Click
            },
        ],
    });

    const mipVOISyncronizer = cornerstoneTools.synchronizers.createVOISynchronizer("mip_voi_syncronizer");

    ['mip_axial', 'mip_sagittal', 'mip_coronal'].forEach((viewport) => {
        mipVOISyncronizer.add({ renderingEngineId: 'viewer_render_engine', viewportId: viewport });
    });

    const tool_panel = document.getElementById('mip_tools');

    const renderingEngine = cornerstone.getRenderingEngine('viewer_render_engine');

    addButtonToToolbar({
        id: 'mip_reset_button',
        container: tool_panel,
        title: 'Reset Viewports',
        onClick: () => {
            renderingEngine.getViewports().forEach((viewport) => {
                // Needs to be called twice to ensure the camera is reset
                // Not sure why this is the case
                viewport.resetCamera(true, true, true, true);
                viewport.resetCamera(true, true, true, true);
            });
            renderingEngine.render();
        },
    });
}

function setup3dTools() {

    // Tool group setup
    const t3dToolGroup = cornerstoneTools.ToolGroupManager.createToolGroup('t3d_tool_group');
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

    // Segmentation Display
    t3dToolGroup.addTool(cornerstoneTools.SegmentationDisplayTool.toolName);
    t3dToolGroup.setToolEnabled(cornerstoneTools.SegmentationDisplayTool.toolName);

    // Pan
    t3dToolGroup.addTool(cornerstoneTools.PanTool.toolName);
    t3dToolGroup.setToolActive(cornerstoneTools.PanTool.toolName, {
        bindings: [
            {
                mouseButton: cornerstoneTools.Enums.MouseBindings.Auxiliary, // Middle Click
            },
        ],
    });

    // Zoom
    t3dToolGroup.addTool(cornerstoneTools.ZoomTool.toolName);
    t3dToolGroup.setToolActive(cornerstoneTools.ZoomTool.toolName, {
        bindings: [
            {
                mouseButton: cornerstoneTools.Enums.MouseBindings.Secondary, // Right Click
            },
        ],
    });

    const renderingEngine = cornerstone.getRenderingEngine('viewer_render_engine');

    const viewport = renderingEngine.getViewport('t3d_coronal');

    const tool_panel = document.getElementById('t3d_tools');

    addButtonToToolbar({
        id: 't3d_reset_button',
        container: tool_panel,
        title: 'Reset Viewports',
        onClick: () => {
            renderingEngine.getViewports().forEach((viewport) => {
                // Needs to be called twice to ensure the camera is reset
                // Not sure why this is the case
                viewport.resetCamera(true, true, true, true);
                viewport.resetCamera(true, true, true, true);
            });
            renderingEngine.render();
        },
    });

    const preset_panel = document.createElement('div');
    preset_panel.className = 'label-select-container'

    tool_panel.appendChild(preset_panel);

    addDropDownToToolbar({
        id: 't3d_preset_dropdown',
        container: preset_panel,
        labelText: 'Preset: ',
        options: {
            values: cornerstone.CONSTANTS.VIEWPORT_PRESETS.map((preset) => preset.name),
            defaultValue: 'MR-Default',
        },
        onSelectedValueChange: (presetName) => {
            viewport.setProperties({ preset: presetName });
            viewport.render();
        },
    });


    addToggleButtonToToolbar({
        id: 't3d_visibility_button',
        container: tool_panel,
        title: 'Toggle Visibility',
        defaultToggle: true,
        onClick: async (toggle) => {
            const viewport = renderingEngine.getViewport('t3d_coronal');
            const volumeActor = viewport.getDefaultActor().actor;
            const visibility = toggle;
            volumeActor.setVisibility(visibility);

            viewport.resetCamera();
            viewport.render();
        },
    });

    const alpha_panel = document.createElement('div');
    preset_panel.className = 'label-slider-container'

    tool_panel.appendChild(alpha_panel);

    addSliderToToolbar({
        id: 't3d_alpha_slider',
        container: alpha_panel,
        title: 'Volume Alpha',
        range: [1, 100],
        defaultValue: 100,
        onSelectedValueChange: (value) => {
            const mappedValue = Number(value) / 100.0;
            const viewport = renderingEngine.getViewport('t3d_coronal');
            setConfigValue(viewport, 'fillAlphaInactive', mappedValue);
            renderingEngine.renderViewports('t3d_coronal');
        },
    });


}

// ============================= //

async function run() {
    await cornerstone.init();
    await cornerstoneTools.init();
    await initVolumeLoader();
    await initCornerstoneDICOMImageLoader();
    await initViewer();

    if (volume) {
        const renderingEngine = new cornerstone.RenderingEngine('viewer_render_engine');

        if (viewerFunction == 'view') {
            const volContent = setupVolPanel();
            const mipContent = setupMipPanel();
            const t3dContent = setup3dPanel();

            const viewportInput = [
                {
                    viewportId: 'vol_axial',
                    type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
                    element: volContent["axial"],
                    defaultOptions: {
                        orientation: cornerstone.Enums.OrientationAxis.AXIAL,
                    },
                },
                {
                    viewportId: 'vol_sagittal',
                    type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
                    element: volContent["sagittal"],
                    defaultOptions: {
                        orientation: cornerstone.Enums.OrientationAxis.SAGITTAL,
                    },
                },
                {
                    viewportId: 'vol_coronal',
                    type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
                    element: volContent["coronal"],
                    defaultOptions: {
                        orientation: cornerstone.Enums.OrientationAxis.CORONAL,
                    },
                },
                {
                    viewportId: 'mip_axial',
                    type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
                    element: mipContent["axial"],
                    defaultOptions: {
                        orientation: cornerstone.Enums.OrientationAxis.AXIAL,
                    },
                },
                {
                    viewportId: 'mip_sagittal',
                    type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
                    element: mipContent["sagittal"],
                    defaultOptions: {
                        orientation: cornerstone.Enums.OrientationAxis.SAGITTAL,
                    },
                },
                {
                    viewportId: 'mip_coronal',
                    type: cornerstone.Enums.ViewportType.ORTHOGRAPHIC,
                    element: mipContent["coronal"],
                    defaultOptions: {
                        orientation: cornerstone.Enums.OrientationAxis.CORONAL,
                    },
                },
                {
                    viewportId: 't3d_coronal',
                    type: cornerstone.Enums.ViewportType.VOLUME_3D,
                    element: t3dContent["coronal"],
                    defaultOptions: {
                        orientation: cornerstone.Enums.OrientationAxis.CORONAL,
                    },
                },
            ];

            renderingEngine.setViewports(viewportInput);

            volume.load();

            await cornerstone.setVolumesForViewports(
                renderingEngine,
                [
                    {
                        volumeId: volumeId,
                    }
                ],
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

            // Add volumes to 3D viewports
            const viewport = renderingEngine.getViewport('t3d_coronal');
            await cornerstone.setVolumesForViewports(
                renderingEngine,
                [
                    //https://www.cornerstonejs.org/api/core/namespace/Types#IVolumeInput
                    {
                        volumeId: volumeId
                    },
                ],
                ['t3d_coronal']
            ).then(() => {
                viewport.setProperties({
                    preset: 'MR-Default',
                    //preset: 'MR-T2-Brain',
                });
            });

            renderingEngine.render();

            setupTools();            
        }
    }


    ////const seg_path = getNiftiSeg()
    ////addOverlay(seg_path);


}

async function initViewer() {

    parseURLParams();
    //getViewerConfig();
    await getFileData();
}

function parseURLParams() {
    const urlParams = new URLSearchParams(window.location.search);

    if (urlParams.size > 0) {

        // function = ['visual_review','masking','overlay','view']
        viewerFunction = urlParams.get('function') || 'view';

        // type = ['dicom','nifti']
        viewerType = urlParams.get('type') || 'dicom';
        document.getElementById('type').value = viewerType || '';

        // file =
        fileID = urlParams.get('file');
        document.getElementById('file').value = fileID || '';

        // series =
        seriesUID = urlParams.get('series');
        document.getElementById('series').value = seriesUID || '';
        timepointID = urlParams.get('timepoint');
        document.getElementById('timepoint').value = timepointID || '';

        //const seriesParam = urlParams.get('series');
        //if (seriesParam && seriesParam.includes(':')) {
        //    const parts = seriesParam.split(':');
        //    seriesUID = parts[0];
        //    timepointID = parts[1];
        //} else {
        //    seriesUID = seriesParam;
        //}

        // group =
        groupID = urlParams.get('group');
    }
}

//function getViewerConfig() {
//    // Get Viewer Config
//    if (viewerFunction == null || viewerType == null) {
//        viewerConfig = {
//            function: viewerFunction,
//            type: viewerType,
//            file: fileID,
//            series: seriesUID,
//            timepoint: timepointID,
//            group: groupID,
//        };
//    } else {
//        viewerConfig = {
//            function: viewerFunction,
//            type: viewerType,
//            file: fileID,
//            series: seriesUID,
//            timepoint: timepointID,
//            group: groupID,
//        };    
//    }
//}


async function getFileData()
{
    // retrieve file data 
    if (fileID) {
        file = `/papi/v1/files/${fileID}/data`;
        //file = `wadouri:/papi/v1/files/${fileID}/data`;
        //file = '/nifti/brain/BraTS-MET-00086-000-t1n.nii.gz';
    }
    else if (seriesUID) {

        let response;
        if (timepointID) {
            response = await fetch(`/papi/v1/series/${seriesUID}:${timepointID}/files`);
        } else {
            response = await fetch(`/papi/v1/series/${seriesUID}/files`);   
        }
        
        if (response.ok) {
            const files = await response.json();
            fileList = files.file_ids.map(file_id => `wadouri:/papi/v1/files/${file_id}/data`);
        }
    }

    // create volume
    if (file) {
        if (viewerType == 'dicom') {
            volumeId = 'cornerstoneStreamingImageVolume: newVolume';
            volume = await cornerstone.volumeLoader.createAndCacheVolume(volumeId, { imageIds: file });
        }
        else if (viewerType == 'nifti') {
            volumeId = 'nifti:' + file;
            volume = await cornerstone.volumeLoader.createAndCacheVolume(volumeId, { type: 'image' });
        }
    }
    else if (fileList) {
        volumeId = 'cornerstoneStreamingImageVolume: newVolume';
        volume = await cornerstone.volumeLoader.createAndCacheVolume(volumeId, { imageIds: fileList });
    }
}


// ============================= //
// HTML Functions
// ============================= //

function addButtonToToolbar({ id, title, container, onClick }) {
    const button = document.createElement('button');

    button.id = id;
    button.innerHTML = title;
    button.onclick = onClick;

    container = container || document.getElementById('demo-toolbar');
    container.append(button);

    return button;
}

function addDropDownToToolbar({ id, options, container, style, onSelectedValueChange, labelText }) {
    const { values, defaultValue } = options;
    container = container || document.getElementById('demo-toolbar');

    // Create label element if labelText is provided
    if (labelText) {
        const label = document.createElement('label');
        label.htmlFor = id;
        label.innerText = labelText;
        container.append(label);
    }

    const select = document.createElement('select');
    select.id = id;

    if (style) {
        Object.assign(select.style, style);
    }

    values.forEach((value) => {
        const optionElement = document.createElement('option');
        optionElement.value = String(value);
        optionElement.innerText = String(value);
        if (value === defaultValue) {
            optionElement.selected = true;
        }
        select.append(optionElement);
    });

    select.onchange = (evt) => {
        const selectElement = evt.target;
        if (selectElement) {
            onSelectedValueChange(selectElement.value);
        }
    };

    container.append(select);
}

function addToggleButtonToToolbar({ id, title, container, onClick, defaultToggle = false }) {
    const button = document.createElement('button');

    const toggleOnBackgroundColor = '#fcfba9';
    const toggleOffBackgroundColor = '#ffffff';

    let toggle = !!defaultToggle;

    function setBackgroundColor() {
        button.style.backgroundColor = toggle
            ? toggleOnBackgroundColor
            : toggleOffBackgroundColor;
    }

    setBackgroundColor();

    button.id = id;
    button.innerHTML = title;
    button.onclick = () => {
        toggle = !toggle;
        setBackgroundColor();
        onClick.call(button, toggle);
    };

    container = container || document.getElementById('demo-toolbar');
    container.append(button);
}

function addSliderToToolbar({ id, title, range, step, defaultValue, container, onSelectedValueChange, updateLabelOnChange }) {
    const label = document.createElement('label');
    const input = document.createElement('input');

    if (id) {
        input.id = id;
        label.id = `${id}-label`;
    }

    label.htmlFor = title;
    label.innerText = title;

    input.type = 'range';
    input.name = title;
    input.min = String(range[0]);
    input.max = String(range[1]);

    // Add step before setting its value to make sure it works for steps different than 1.
    // Example: range (0-1), step (0.1) and value (0.5)
    if (step) {
        input.step = String(step);
    }

    input.value = String(defaultValue);

    input.oninput = (evt) => {
        const selectElement = evt.target;

        if (selectElement) {
            onSelectedValueChange(selectElement.value);
            if (updateLabelOnChange !== undefined) {
                updateLabelOnChange(selectElement.value, label);
            }
        }
    };

    container = container || document.getElementById('demo-toolbar');
    container.append(label);
    container.append(input);
}





run();