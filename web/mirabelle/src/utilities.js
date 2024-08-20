import * as cornerstone from '@cornerstonejs/core';
import {
	cornerstoneStreamingImageVolumeLoader,
	cornerstoneStreamingDynamicImageVolumeLoader,
} from '@cornerstonejs/streaming-image-volume-loader';
import cornerstoneDICOMImageLoader from '@cornerstonejs/dicom-image-loader';
import dicomParser from 'dicom-parser';
import { cornerstoneNiftiImageVolumeLoader } from '@cornerstonejs/nifti-volume-loader';

const { volumeLoader } = cornerstone;

export function initVolumeLoader() {
	volumeLoader.registerUnknownVolumeLoader(
		cornerstoneStreamingImageVolumeLoader
	);
	volumeLoader.registerVolumeLoader(
		'cornerstoneStreamingImageVolume',
		cornerstoneStreamingImageVolumeLoader
	);
	volumeLoader.registerVolumeLoader(
		'cornerstoneStreamingDynamicImageVolume',
		cornerstoneStreamingDynamicImageVolumeLoader
	);
	volumeLoader.registerVolumeLoader(
		'nifti',
		cornerstoneNiftiImageVolumeLoader
	);
}

export function initCornerstoneDICOMImageLoader() {
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

	var config = {
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

export function expandSegTo3D(segmentationId) {
	const segmentationVolume = cornerstone.cache.getVolume(segmentationId);
	const scalarData = segmentationVolume.scalarData;
	const dims = segmentationVolume.dimensions;

	const [x_size, y_size, z_size] = dims;

	let xmin = z_size * y_size * x_size;
	let xmax = 0;
	let ymin = xmin;
	let ymax = 0;
	let zmin = xmin;
	let zmax = 0;

	for (let z = 0; z < z_size; z++) {
		for (let y = 0; y < y_size; y++) {
			for (let x = 0; x < x_size; x++) {
				// offset into the array
				let offset = (z * x_size * y_size) + (y * x_size) + x;

				if (scalarData[offset] > 0) {
					if (x < xmin) { xmin = x; }
					if (x > xmax) { xmax = x; }
					if (y < ymin) { ymin = y; }
					if (y > ymax) { ymax = y; }
					if (z < zmin) { zmin = z; }
					if (z > zmax) { zmax = z; }
				}
			}
		}
	}
	// Expand into a cube
	for (let z = 0; z < z_size; z++) {
		for (let y = 0; y < y_size; y++) {
			for (let x = 0; x < x_size; x++) {
				// offset into the array
				let offset = (z * x_size * y_size) + (y * x_size) + x;
				if (
					x >= xmin &&
					x <= xmax &&
					y >= ymin &&
					y <= ymax &&
					z >= zmin &&
					z <= zmax
				) {
					scalarData[offset] = 2;
				} else {
					scalarData[offset] = 0;
				}
			}
		}
	}

	return {
		x: { min: xmin, max: xmax },
		y: { min: ymin, max: ymax },
		z: { min: zmin, max: zmax },
	};
}

/**
 * A generic distance calucaltion between two (3D) points
 */
export function calculateDistance(point1, point2) {
	const dx = point2[0] - point1[0];
	const dy = point2[1] - point1[1];
	const dz = point2[2] - point1[2];

	const distance = Math.sqrt(dx ** 2 + dy ** 2 + dz ** 2);

	return distance;
}
