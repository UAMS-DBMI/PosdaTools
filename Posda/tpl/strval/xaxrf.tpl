#$Source: /home/bbennett/pass/archive/Posda/tpl/strval/xaxrf.tpl,v $
#$Date: 2009/03/25 14:09:02 $
#$Revision: 1.1 $
#
StringValues="XRayFieldOfViewShape" {
	ROUND,
	RECTANGLE
}

StringValues="Grid" {
	IN = Grid is positioned,
	NONE = No Grid is used
}

StringValues="RadiationSetting" {
	SC = low dose exposure for preparation,
	GR = high dose exposure for diagnostic quality image acquisition
}

StringValues="XRayImageScanOptions" {
	EKG = EKG Event Trigger,
	PHY = Physiological Event Trigger,
	TOMO = Tomography,
	CHASE = Bolus Chasing,
	STEP = Stepping,
	ROTA = Rotation
}

StringValues="PhotometricInterpretationMonochrome2" {
	MONOCHROME2
}

StringValues="PixelIntensityRelationship" {
	LIN = Approximately proportional to X-Ray beam intensity,
	LOG = Non-linear Log Function,
	DISP = Ready to be displayed
}

StringValues="XRayImageTypeValue3" {
	SINGLE PLANE = Image is a single plane acquisition,
	BIPLANE A = Image is the first plane of a Bi-plane acquisition,
	BIPLANE B = Image is the second plane of a Bi-plane acquisition,
	BIPLANE = Image is both planes of a Bi-plane acquisition 
}


StringValues="InterventionStatus" {
	PRE,
	INTERMEDIATE,
	POST,
	NONE
}

StringValues="XADeviceCodingSchemeDesignators" {
	99DEV = X-Ray Angiographic IOD Interim Intervention Device List,
	99SDM = SNOMED DICOM Microglossary
}

StringValues="XATherapyCodingSchemeDesignators" {
	99THR = X-Ray Angiographic IOD Interim Intervention Therapy List,
	99SDM = SNOMED DICOM Microglossary
}

StringValues="XAAnatomyCodingSchemeDesignators" {
	99ANA = X-Ray Angiographic IOD Interim Anatomic Term List,
	99SDM = SNOMED DICOM Microglossary
}

StringValues="DeviceDiameterUnits" {
	FR = French,
	GA = Gauge,
	IN = Inch,
	MM = Millimeter
}

StringValues="ShutterShape" {
	RECTANGULAR,
	CIRCULAR,
	POLYGONAL
}

StringValues="BitmapShutterShape" {
	BITMAP
}

StringValues="CollimatorShape" {
	RECTANGULAR,
	CIRCULAR,
	POLYGONAL
}

StringValues="MaskOperation" {
	NONE = No Subtraction,
	AVG_SUB = Average Subtraction,
	TID = Time Interval Differencing
	REV_TID = Reversed Time Interval Differencing
}

StringValues="RecommendedViewingMode" {
	SUB = for subtraction with mask images,
	NAT = native viewing of image as sent
}

StringValues="RadiationMode" {
	CONTINUOUS,
	PULSED
}

StringValues="MaskSelectionMode" {
	SYSTEM,
	USER
}

# enhanced XA/XRF stuff ...

StringValues="EnhancedXAXRFModality" {
	XA,
	XRF
}

StringValues="EnhancedXAXRFImageType1" {
	ORIGINAL,
	DERIVED
}

StringValues="EnhancedXAXRFImageType2" {
	PRIMARY,
	SECONDARY
}

StringValues="EnhancedXAXRFImageType3" {
	SINGLE PLANE,
	BIPLANE A,
	BIPLANE B,
	UNDEFINED
}

StringValues="PlaneIdentification" {
	MONOPLANE,
	PLANE A,
	PLANE B
}

StringValues="EnhancedXAXRFScanOptions" {
	TOMO,
	CHASE,
	STEP,
	ROTA
}

StringValues="EnhancedXAXRFRadiationSetting" {
	SC,
	GR
}

StringValues="EnhancedXAXRFRadiationMode" {
	CONTINUOUS,
	PULSED
}

StringValues="XRayReceptorType" {
	IMG_INTENSIFIER,
	DIGITAL_DETECTOR
}

StringValues="EnhancedXAXRFPositionerType" {
	CARM,
	COLUMN
}

StringValues="IntensifierActiveShape" {
	RECTANGLE,
	ROUND,
	HEXAGONAL
}

StringValues="FieldOfViewShape" {
	RECTANGLE,
	ROUND,
	HEXAGONAL
}

StringValues="ExposureControlSensingRegionShape" {
	RECTANGULAR,
	CIRCULAR,
	POLYGONAL
}

StringValues="XAXRFPixelIntensityRelationship" {
	LIN,
	LOG,
	OTHER
}

StringValues="XAXRFGeometricalProperties" {
	UNIFORM,
	NON_UNIFORM
}

StringValues="XAXRFImageProcessingApplied" {
	DIGITAL_SUBTR,
	HIGH_PASS_FILTER,
	LOW_PASS_FILTER,
	MULTI_BAND_FLTR,
	FRAME_AVERAGING,
	NONE
}

StringValues="SkipFrameRangeFlag" {
	DISPLAY,
	SKIP
}

StringValues="XRay3DImageAndFrameType4" {
	NONE
}
