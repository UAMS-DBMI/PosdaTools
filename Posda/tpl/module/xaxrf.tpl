#$Source: /home/bbennett/pass/archive/Posda/tpl/module/xaxrf.tpl,v $
#$Date: 2010/04/30 19:22:41 $
#$Revision: 1.4 $
#
Module="FramePointers"
	Name="RepresentativeFrameNumber"	Type="3"	NotZeroError=""
	Name="FrameNumbersOfInterest"		Type="3"	NotZeroError=""
	Name="FrameOfInterestDescription"	Type="3"
	Name="FrameOfInterestType"			Type="3"	StringDefinedTerms="FrameOfInterestTypeForUS"

ModuleEnd

Module="Mask"
	Sequence="MaskSubtractionSequence"		Type="1"	VM="1-n"
		Name="MaskOperation"				Type="1"	StringDefinedTerms="MaskOperation"
		Name="SubtractionItemID"			Type="1C"	Condition="SOPClassIsEnhancedXAXRF" mbpo="true"
		Name="ApplicableFrameRange"			Type="1C"	Condition="MaskOperationIsRevTID" mbpo="true"
		Name="MaskFrameNumbers"				Type="1C"	Condition="MaskOperationIsAvgSub"	NotZeroError=""
		Name="ContrastFrameAveraging"		Type="3"
		Name="MaskSubPixelShift"			Type="3"
		Name="TIDOffset"					Type="2C"	Condition="MaskOperationIsTIDOrRevTID"
		Name="MaskOperationExplanation"		Type="3"
		Name="MaskSelectionMode"			Type="3"	StringDefinedTerms="MaskSelectionMode"
	SequenceEnd
	Name="RecommendedViewingMode"			Type="2"	StringDefinedTerms="RecommendedViewingMode"

ModuleEnd

Module="DisplayShutter"
	InvokeMacro="DisplayShutterMacro"
ModuleEnd

Module="Device"
	# need to work in the 3 vs. 2C business for device parameters (C.7.6.12.1)
	Sequence="DeviceSequence"		Type="3"	VM="1-n"
		InvokeMacro="CodeSequenceMacro"
		Name="Manufacturer"			Type="3"
		Name="ManufacturerModelName"	Type="3"
		Name="DeviceSerialNumber"	Type="3"
		Name="DeviceID"				Type="3"
		Name="DeviceLength"			Type="3"	NotZeroWarning=""
		Name="DeviceDiameter"		Type="3"	NotZeroWarning=""
		Name="DeviceDiameterUnits"	Type="2C"	Condition="DeviceDiameterIsPresent"	StringEnumValues="DeviceDiameterUnits"
		Name="DeviceVolume"			Type="3"	NotZeroWarning=""
		Name="InterMarkerDistance"	Type="3"
		Name="DeviceDescription"	Type="3"
	SequenceEnd
ModuleEnd

Module="Intervention"
	Sequence="InterventionSequence"					Type="3"	VM="1-n"
		InvokeMacro="CodeSequenceMacro"							BaselineContextID="9"
		Name="InterventionStatus"					Type="2"	StringEnumValues="InterventionStatus"
		Sequence="InterventionDrugCodeSequence"		Type="3"	VM="1"
			InvokeMacro="CodeSequenceMacro"						BaselineContextID="10"
		SequenceEnd
		Name="InterventionDrugStartTime"			Type="3"
		Name="InterventionDrugStopTime"				Type="3"
		Sequence="AdministrationRouteCodeSequence"	Type="3"	VM="1"
			InvokeMacro="CodeSequenceMacro"						BaselineContextID="11"
		SequenceEnd
		Name="InterventionDescription"				Type="3"
	SequenceEnd
ModuleEnd

Module="XRayImage"
	Name="FrameIncrementPointer"					Type="1C"	Condition="NeedModuleMultiFrame"	TagEnumValues="XRayFrameIncrementPointerValues"
	Name="LossyImageCompression"					Type="1C"	NoCondition=""	StringEnumValues="LossyImageCompression"
	Name="ImageType"								Type="1"	ValueSelector="2"	StringEnumValues="XRayImageTypeValue3"
	Verify="ImageType"								Condition="ImageTypeValue3MissingOrEmpty"	ThenErrorMessage="A value is required for value 3 in XA/XRF Images"
	Name="PixelIntensityRelationship"				Type="1"	StringDefinedTerms="PixelIntensityRelationship"
	Name="SamplesPerPixel"							Type="1"	BinaryEnumValues="SamplesPerPixelIsOne"
	Name="PhotometricInterpretation"				Type="1"	StringEnumValues="PhotometricInterpretationMonochrome2"
	Name="BitsAllocated"							Type="1"	BinaryEnumValues="BitsAre8Or16"
	Name="BitsStored"								Type="1"	BinaryEnumValues="BitsAre8Or10Or12Or16"
	Name="HighBit"									Type="1"	BinaryEnumValues="BitsAre7Or9Or11Or15"
	Name="PixelRepresentation"						Type="1"	BinaryEnumValues="PixelRepresentationUnsigned"
	Name="ScanOptions"								Type="3"	StringDefinedTerms="XRayImageScanOptions"
	InvokeMacro="GeneralAnatomyOptionalMacro"
	Name="RWavePointer"								Type="3"
	Sequence="ReferencedImageSequence"				Type="1C"	VM="1-n"	Condition="ImageTypeValue3BiplaneAOrB" mbpo="true"
		InvokeMacro="ImageSOPInstanceReferenceMacro"
		Sequence="PurposeOfReferenceCodeSequence"	Type="3"	VM="1"
			InvokeMacro="CodeSequenceMacro"			DefinedContextID="7201"
		SequenceEnd
	SequenceEnd
	Name="DerivationDescription"					Type="3"
	Name="AcquisitionDeviceProcessingDescription"	Type="3"
	Name="FrameLabelVector"							Type="3"
	Name="FrameDimensionPointer"					Type="3"	TagEnumValues="XAFrameDimensionPointerValues"
	Name="CalibrationImage"							Type="3"	StringEnumValues="YesNoFull"
ModuleEnd

Module="XRayAcquisition"
	Name="KVP"										Type="2"	NotZeroWarning=""
	Name="RadiationSetting"							Type="1"	StringEnumValues="RadiationSetting"
	Name="XRayTubeCurrent"							Type="2C"	Condition="ExposureNotPresent" mbpo="true"	NotZeroWarning=""
	Name="XRayTubeCurrentInuA"						Type="3"	NotZeroWarning=""
	Verify="XRayTubeCurrentInmA"								Condition="XRayTubeCurrentInmAIsPresentAndOthersAreNot" ThenErrorMessage="Attribute should not be used with Module <XRayAcquisition> - use XRayTubeCurrent and/or XRayTubeCurrentInuA instead of"
	
	Name="ExposureTime"								Type="2C"	Condition="ExposureNotPresent" mbpo="true"	NotZeroWarning=""
	Name="ExposureTimeInuS"							Type="3"	NotZeroWarning=""
	Verify="ExposureTimeInms"									Condition="ExposureTimeInmsIsPresentAndOthersAreNot" ThenErrorMessage="Attribute should not be used with Module <XRayAcquisition> - use ExposureTime and/or ExposureTimeInuS instead of"
	
	Name="Exposure"									Type="2C"	Condition="XRayTubeCurrentAndExposureTimeNotPresent" mbpo="true"	NotZeroWarning=""
	Name="ExposureInuAs"							Type="3"	NotZeroWarning=""
	Verify="ExposureInmAs"										Condition="ExposureInmAsIsPresentAndOthersAreNot" ThenErrorMessage="Attribute should not be used with Module <XRayAcquisition> - use Exposure and/or ExposureInuAs instead of"
	
	Name="Grid"										Type="3"	StringDefinedTerms="Grid"
	Name="AveragePulseWidth"						Type="3"	NotZeroWarning=""
	Name="RadiationMode"							Type="3"	StringDefinedTerms="RadiationMode"
	Name="TypeOfFilters"							Type="3"
	Name="IntensifierSize"							Type="3"
	Name="FieldOfViewShape"							Type="3"	StringDefinedTerms="XRayFieldOfViewShape"
	Name="FieldOfViewDimensions"					Type="3"	NotZeroWarning=""
	Name="ImagerPixelSpacing"						Type="3"	NotZeroError=""
	InvokeMacro="BasicPixelSpacingCalibrationMacro"
	Name="FocalSpot"								Type="3"
	Name="ImageAndFluoroscopyAreaDoseProduct"		Type="3"	NotZeroWarning=""
ModuleEnd

Module="XRayCollimator"
	Name="CollimatorShape"					Type="1"	StringEnumValues="CollimatorShape"
	Name="CollimatorLeftVerticalEdge"		Type="1C"	Condition="CollimatorShapeIsRectangular"
	Name="CollimatorRightVerticalEdge"		Type="1C"	Condition="CollimatorShapeIsRectangular"
	Name="CollimatorUpperHorizontalEdge"	Type="1C"	Condition="CollimatorShapeIsRectangular"
	Name="CollimatorLowerHorizontalEdge"	Type="1C"	Condition="CollimatorShapeIsRectangular"
	Name="CenterOfCircularCollimator"		Type="1C"	Condition="CollimatorShapeIsCircular"
	Name="RadiusOfCircularCollimator"		Type="1C"	Condition="CollimatorShapeIsCircular"	NotZeroWarning=""
	Name="VerticesOfPolygonalCollimator"	Type="1C"	Condition="CollimatorShapeIsPolygonal"
ModuleEnd

Module="XRayTable"
	Name="TableMotion"					Type="2"	StringDefinedTerms="TableMotion"
	Name="TableVerticalIncrement"		Type="2C"	Condition="TableMotionDynamic"
	Name="TableLongitudinalIncrement"	Type="2C"	Condition="TableMotionDynamic"
	Name="TableLateralIncrement"		Type="2C"	Condition="TableMotionDynamic"
	Name="TableAngle"					Type="3"
ModuleEnd

Module="XAPositioner"
	Name="DistanceSourceToPatient"					Type="3"	NotZeroWarning=""
	Name="DistanceSourceToDetector"					Type="3"	NotZeroWarning=""
	Name="EstimatedRadiographicMagnificationFactor"	Type="3"	NotZeroWarning=""
	Name="PositionerMotion"							Type="2C"	StringDefinedTerms="PositionerMotion"	Condition="NeedModuleMultiFrame"
	Name="PositionerPrimaryAngle"					Type="2"
	Name="PositionerSecondaryAngle"					Type="2"
	Name="PositionerPrimaryAngleIncrement"			Type="2C"	Condition="PositionerMotionDynamic"	NotZeroWarning=""
	Name="PositionerSecondaryAngleIncrement"		Type="2C"	Condition="PositionerMotionDynamic"	NotZeroWarning=""
	Name="DetectorPrimaryAngle"						Type="3"
	Name="DetectorSecondaryAngle"					Type="3"

ModuleEnd

Module="XRFPositioner"
	Name="DistanceSourceToDetector"					Type="3"	NotZeroWarning=""
	Name="DistanceSourceToPatient"					Type="3"	NotZeroWarning=""
	Name="EstimatedRadiographicMagnificationFactor"	Type="3"	NotZeroWarning=""
	Name="ColumnAngulation"							Type="3"
ModuleEnd

Module="XRayTomographyAcquisition"
	Name="TomoLayerHeight"							Type="1"
	Name="TomoAngle"								Type="3"
	Name="TomoTime"									Type="3"
	Name="TomoType"									Type="3"	StringDefinedTerms="TomoType"
	Name="TomoClass"								Type="3"	StringDefinedTerms="TomoClass"
	Name="NumberOfTomosynthesisSourceImages"		Type="3"
ModuleEnd

# enhanced XA/XRF stuff ...

Module="XAXRFSeries"
	Name="Modality"										Type="1"	StringEnumValues="EnhancedXAXRFModality"
	Name="SeriesNumber"									Type="1"
	Sequence="ReferencedPerformedProcedureStepSequence"	Type="1C"	VM="1"	Condition="SeriesNeedReferencedPerformedProcedureStepSequence"
		InvokeMacro="SOPInstanceReferenceMacro"
	SequenceEnd
ModuleEnd

Module="EnhancedXAXRFImage"
	InvokeMacro="MRImageAndSpectroscopyInstanceMacro"
	Name="ImageType"										Type="1"	VM="3-n"
	Verify="ImageType"													ValueSelector="0"	StringEnumValues="EnhancedXAXRFImageType1"
	Verify="ImageType"													ValueSelector="1"	StringEnumValues="EnhancedXAXRFImageType2"
	Verify="ImageType"													ValueSelector="2"	StringEnumValues="EnhancedXAXRFImageType3"
	Name="PlaneIdentification"								Type="1C"	Condition="ImageTypeValue3NotUndefined"	StringDefinedTerms="PlaneIdentification"
	Name="AcquisitionNumber"								Type="3"
	Name="AcquisitionDateTime"								Type="1"
	Name="BitsAllocated"									Type="1"	BinaryEnumValues="BitsAre8Or16"
	Name="BitsStored"										Type="1"	BinaryEnumValues="BitsAre8To16"
	Verify="BitsStored"													Condition="BitsAllocatedIs8"	BinaryEnumValues="BitsAre8"
	Verify="BitsStored"													Condition="BitsAllocatedIs16"	BinaryEnumValues="BitsAre9To16"
	Name="HighBit"											Type="1"	BinaryEnumValues="BitsAre7To15"
	Verify="HighBit"													Condition="BitsAllocatedIs8"	BinaryEnumValues="BitsAre7"
	Verify="HighBit"													Condition="BitsAllocatedIs16"	BinaryEnumValues="BitsAre8To15"
	Name="SamplesPerPixel"									Type="1"	BinaryEnumValues="SamplesPerPixelIsOne"
	Name="PixelRepresentation"								Type="1"	BinaryEnumValues="PixelRepresentationUnsigned"
	Name="PhotometricInterpretation"						Type="1"	StringEnumValues="PhotometricInterpretationMonochrome"
	Name="AcquisitionProtocolName"							Type="3"
	Name="AcquisitionProtocolDescription"					Type="3"
	Name="ScanOptions"										Type="3"	StringDefinedTerms="EnhancedXAXRFScanOptions"
	Name="ContentQualification"								Type="1"	StringEnumValues="ContentQualification"
	Sequence="PatientOrientationCodeSequence"				Type="1C"	VM="1"	Condition="PositionerIsCArmWithTableTopRelationship"
		InvokeMacro="CodeSequenceMacro"									BaselineContextID="19"
		Sequence="PatientOrientationModifierCodeSequence"   Type="1C"	VM="1"	NoCondition=""	# real-world - orientation wrt. gravity
 			InvokeMacro="CodeSequenceMacro"								BaselineContextID="20"
		SequenceEnd
	SequenceEnd
	Sequence="PatientGantryRelationshipCodeSequence"		Type="2C"	VM="0-1"	Condition="PositionerIsCArmWithTableTopRelationship"
		InvokeMacro="CodeSequenceMacro"									BaselineContextID="21"
	SequenceEnd
	Name="ExaminedBodyThickness"							Type="3"	NotZeroWarning=""
	Name="BurnedInAnnotation"								Type="1"	StringEnumValues="NoFull"
	Name="LossyImageCompression"							Type="1"	StringEnumValues="LossyImageCompression"
	Name="LossyImageCompressionRatio"						Type="1C"	Condition="LossyImageCompressionIs01"
	Name="LossyImageCompressionMethod"						Type="1C"	StringDefinedTerms="LossyImageCompressionMethod"	Condition="LossyImageCompressionIs01"
	Verify="LossyImageCompressionMethod"								Condition="LossyImageCompressionMethodInconsistentWithTransferSyntax"	ThenWarningMessage="method inconsistent with transfer syntax" ShowValueWithMessage="true"
	Sequence="ReferencedOtherPlaneSequence"					Type="1C"	VM="1"	Condition="ImageTypeValue3BiplaneAOrB"
		InvokeMacro="ImageSOPInstanceReferenceMacro"
	SequenceEnd
	Sequence="ReferencedImageEvidenceSequence"				Type="1C"	VM="1-n"	Condition="ReferencedImageSequenceIsPresent"
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Sequence="SourceImageEvidenceSequence"					Type="1C"	VM="1-n"	Condition="SourceImageSequenceIsPresent"
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Sequence="ReferencedInstanceSequence"					Type="3"	VM="1-n"
		InvokeMacro="SOPInstanceReferenceMacro"
		Sequence="PurposeOfReferenceCodeSequence"			Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"								DefinedContextID="7004"
		SequenceEnd
	SequenceEnd
	Name="ImageComments"									Type="3"
	Name="QualityControlImage"								Type="3"	StringEnumValues="YesNoFull"
	Sequence="IconImageSequence"							Type="3"	VM="1"
		InvokeMacro="IconImageSequenceMacro"
	SequenceEnd
	Name="PresentationLUTShape"								Type="1"	StringEnumValues="IdentityOrInversePresentationLUTShape"
	Verify="PresentationLUTShape"										Condition="PhotometricInterpretationIsMonochrome2"	StringEnumValues="IdentityPresentationLUTShape"
	Verify="PresentationLUTShape"										Condition="PhotometricInterpretationIsMonochrome1"	StringEnumValues="InversePresentationLUTShape"
ModuleEnd

Module="XAXRFAcquisition"
	Name="KVP"												Type="1"	NotZeroWarning=""
	Name="RadiationSetting"									Type="1"	StringEnumValues="EnhancedXAXRFRadiationSetting"
	Name="XRayTubeCurrentInmA"								Type="1C"	Condition="ExposureInmAsNotPresent"	NotZeroWarning=""
	Name="ExposureTimeInms"									Type="1C"	Condition="ExposureInmAsNotPresent"	NotZeroWarning=""
	Name="ExposureInmAs"									Type="1C"	Condition="XRayTubeCurrentInmAOrExposureTimeInmsNotPresent"	NotZeroWarning=""
	Name="AveragePulseWidth"								Type="1"	NotZeroWarning=""
	Name="AcquisitionDuration"								Type="1"	NotZeroWarning=""
	Name="RadiationMode"									Type="1"	StringDefinedTerms="EnhancedXAXRFRadiationMode"
	Name="FocalSpot"										Type="3"
	Name="AnodeTargetMaterial"								Type="3"	StringDefinedTerms="AnodeTargetMaterial"
	Name="RectificationType"								Type="3"	StringDefinedTerms="RectificationType"
	Name="XRayReceptorType"									Type="3"	StringEnumValues="XRayReceptorType"
	Name="DistanceReceptorPlaneToDetectorHousing"			Type="2"	NotZeroWarning=""
	Name="PositionerType"									Type="2"	StringDefinedTerms="EnhancedXAXRFPositionerType"
	Name="CArmPositionerTabletopRelationship"				Type="1C"	Condition="PositionerIsCArm"	StringEnumValues="YesNoFull"
	Name="AcquiredImageAreaDoseProduct"						Type="2"	NotZeroWarning=""
ModuleEnd

Module="XRayImageIntensifier"
	Name="IntensifierSize"									Type="1"	NotZeroWarning=""
	Name="IntensifierActiveShape"							Type="1"	StringEnumValues="IntensifierActiveShape"
	Name="IntensifierActiveDimensions"						Type="1"	NotZeroWarning=""
ModuleEnd

Module="XRayDetector"
	InvokeMacro="DigitalXRayDetectorMacro"
	Name="PhysicalDetectorSize"								Type="1"	NotZeroError=""
	Name="PositionOfIsocenterProjection"					Type="1C"	Condition="IsocenterReferenceSystemSequencePresent"
ModuleEnd

DefineMacro="XAXRFFrameCharacteristicsMacro" InformationEntity="FunctionalGroup"
	Sequence="XAXRFFrameCharacteristicsSequence"			Type="1"	VM="1"
		Name="DerivationDescription"						Type="3" 
		Sequence="DerivationCodeSequence"					Type="3"	VM="1-n"
			InvokeMacro="CodeSequenceMacro"								DefinedContextID="7203"
		SequenceEnd
		Name="AcquisitionDeviceProcessingDescription"		Type="3"
		Name="AcquisitionDeviceProcessingCode"				Type="3"
	SequenceEnd
MacroEnd

DefineMacro="XRayFieldOfViewMacro" InformationEntity="FunctionalGroup"
	Sequence="FieldOfViewSequence"							Type="1"	VM="1"
		Name="FieldOfViewShape"								Type="3" 	StringEnumValues="FieldOfViewShape"
		Name="FieldOfViewDimensionsInFloat"					Type="3"	NotZeroWarning=""
		Name="FieldOfViewOrigin"							Type="1C"	Condition="XRayReceptorTypeIsDigitalDetector"
		Name="FieldOfViewRotation"							Type="1"	StringEnumValues="DXFieldOfViewRotation"
		Name="FieldOfViewHorizontalFlip"					Type="1"	StringEnumValues="YesNoFull"
		Name="FieldOfViewDescription"						Type="3"
	SequenceEnd
MacroEnd

DefineMacro="XRayExposureControlSensingRegionsMacro" InformationEntity="FunctionalGroup"
	Sequence="ExposureControlSensingRegionsSequence"				Type="1"	VM="1-n"
		Name="ExposureControlSensingRegionShape"					Type="1" 	StringEnumValues="ExposureControlSensingRegionShape"
		Name="ExposureControlSensingRegionLeftVerticalEdge"			Type="1C" 	Condition="ExposureControlSensingRegionShapeIsRectangular"
		Name="ExposureControlSensingRegionRightVerticalEdge"		Type="1C" 	Condition="ExposureControlSensingRegionShapeIsRectangular"
		Name="ExposureControlSensingRegionUpperHorizontalEdge"		Type="1C" 	Condition="ExposureControlSensingRegionShapeIsRectangular"
		Name="ExposureControlSensingRegionLowerHorizontalEdge"		Type="1C" 	Condition="ExposureControlSensingRegionShapeIsRectangular"
		Name="CenterOfCircularExposureControlSensingRegion"			Type="1C" 	Condition="ExposureControlSensingRegionShapeIsCircular"
		Name="RadiusOfCircularExposureControlSensingRegion"			Type="1C" 	Condition="ExposureControlSensingRegionShapeIsCircular"
		Name="VerticesOfPolygonalExposureControlSensingRegion"		Type="1C" 	Condition="ExposureControlSensingRegionShapeIsPolygonal"
	SequenceEnd
MacroEnd

DefineMacro="XAXRFFramePixelDataPropertiesMacro" InformationEntity="FunctionalGroup"
	Sequence="FramePixelDataPropertiesSequence"				Type="1"	VM="1"
		Name="FrameType"									Type="1"	VM="3-n"
		Verify="FrameType"												ValueSelector="0"	StringEnumValues="EnhancedXAXRFImageType1"
		Verify="FrameType"												ValueSelector="1"	StringEnumValues="EnhancedXAXRFImageType2"
		Verify="FrameType"												ValueSelector="2"	StringEnumValues="EnhancedXAXRFImageType3"
		Name="PixelIntensityRelationship"					Type="1"	StringDefinedTerms="XAXRFPixelIntensityRelationship"
		Name="PixelIntensityRelationshipSign"				Type="1"	BinaryEnumValues="PixelIntensityRelationshipSign"
		Name="ImagerPixelSpacing"							Type="1C"	Condition="ImageTypeValue1IsOriginal" mbpo="true"
		Name="GeometricalProperties"						Type="1"	StringEnumValues="XAXRFGeometricalProperties"
		Name="GeometricMaximumDistortion"					Type="2C" 	Condition="GeometricalPropertiesIsNonUniform"
		Name="ImageProcessingApplied"						Type="1"	StringDefinedTerms="XAXRFImageProcessingApplied"
	SequenceEnd
MacroEnd

DefineMacro="XRayFrameDetectorParametersMacro" InformationEntity="FunctionalGroup"
	Sequence="FrameDetectorParametersSequence"				Type="1"	VM="1"
		Name="DetectorActiveTime"							Type="3"
		Name="DetectorActivationOffsetFromExposure"			Type="3"
	SequenceEnd
MacroEnd

DefineMacro="XRayCalibrationDeviceUsageMacro" InformationEntity="FunctionalGroup"
	Sequence="CalibrationSequence"							Type="1"	VM="1"
		Name="CalibrationImage"								Type="3"	StringEnumValues="YesNoFull"
	SequenceEnd
MacroEnd

DefineMacro="XRayObjectThicknessMacro" InformationEntity="FunctionalGroup"
	Sequence="ObjectThicknessSequence"							Type="1"	VM="1"
		Name="CalculatedAnatomyThickness"						Type="1"	NotZeroWarning=""
	SequenceEnd
MacroEnd

DefineMacro="XRayFrameAcquisitionMacro" InformationEntity="FunctionalGroup"
	Sequence="FrameAcquisitionSequence"							Type="1"	VM="1"
		Name="KVP"												Type="1"	NotZeroWarning=""
		Name="XRayTubeCurrentInmA"								Type="1"	NotZeroWarning=""
	SequenceEnd
MacroEnd

DefineMacro="XRayProjectionPixelCalibrationMacro" InformationEntity="FunctionalGroup"
	Sequence="ProjectionPixelCalibrationSequence"				Type="1"	VM="1"
		Name="DistanceObjectToTableTop"							Type="2"
		Name="ObjectPixelSpacingInCenterOfBeam"					Type="1C"	Condition="DistanceObjectToTableTopNotEmpty"
		Name="TableHeight"										Type="1C"	Condition="ImageTypeValue1Original"
		Name="BeamAngle"										Type="1C"	Condition="ImageTypeValue1Original"
	SequenceEnd
MacroEnd

DefineMacro="XRayPositionerMacro" InformationEntity="FunctionalGroup"
	Sequence="PositionerPositionSequence"						Type="1"	VM="1"
		Name="PositionerPrimaryAngle"							Type="1C"	Condition="PositionerIsCArm"
		Name="PositionerSecondaryAngle"							Type="1C"	Condition="PositionerIsCArm"
		Name="ColumnAngulationPatient"							Type="1C"	Condition="PositionerIsColumn"
	SequenceEnd
MacroEnd

DefineMacro="XRayTablePositionMacro" InformationEntity="FunctionalGroup"
	Sequence="TablePositionSequence"							Type="1"	VM="1"
		Name="TableTopVerticalPosition"							Type="1"
		Name="TableTopLongitudinalPosition"						Type="1"
		Name="TableTopLateralPosition"							Type="1"
		Name="TableHorizontalRotationAngle"						Type="1"
		Name="TableHeadTiltAngle"								Type="1"
		Name="TableCradleTiltAngle"								Type="1"
	SequenceEnd
MacroEnd

DefineMacro="XRayCollimatorMacro" InformationEntity="FunctionalGroup"
	Sequence="CollimatorShapeSequence"							Type="1"	VM="1"
		Name="CollimatorShape"									Type="1"	StringEnumValues="CollimatorShape"
		Name="CollimatorLeftVerticalEdge"						Type="1C"	Condition="CollimatorShapeIsRectangular"
		Name="CollimatorRightVerticalEdge"						Type="1C"	Condition="CollimatorShapeIsRectangular"
		Name="CollimatorUpperHorizontalEdge"					Type="1C"	Condition="CollimatorShapeIsRectangular"
		Name="CollimatorLowerHorizontalEdge"					Type="1C"	Condition="CollimatorShapeIsRectangular"
		Name="CenterOfCircularCollimator"						Type="1C"	Condition="CollimatorShapeIsCircular"	NotZeroWarning=""
		Name="RadiusOfCircularCollimator"						Type="1C"	Condition="CollimatorShapeIsCircular"	NotZeroWarning=""
		Name="VerticesOfPolygonalCollimator"					Type="1C"	Condition="CollimatorShapeIsPolygonal"
	SequenceEnd
MacroEnd

DefineMacro="XRayIsocenterReferenceSystemMacro" InformationEntity="FunctionalGroup"
	Sequence="IsocenterReferenceSystemSequence"					Type="1"	VM="1"
		Name="PositionerIsocenterPrimaryAngle"					Type="1"
		Name="PositionerIsocenterSecondaryAngle"				Type="1"
		Name="PositionerIsocenterDetectorRotationAngle"			Type="1"
		Name="TableXPositionToIsocenter"						Type="1"
		Name="TableYPositionToIsocenter"						Type="1"
		Name="TableZPositionToIsocenter"						Type="1"
		Name="TableHorizontalRotationAngle"						Type="1"
		Name="TableHeadTiltAngle"								Type="1"
		Name="TableCradleTiltAngle"								Type="1"
	SequenceEnd
MacroEnd

DefineMacro="XRayGeometryMacro" InformationEntity="FunctionalGroup"
	Sequence="XRayGeometrySequence"								Type="1"	VM="1"
		Name="DistanceSourceToIsocenter"						Type="1"	NotZeroWarning=""
		Name="DistanceSourceToDetector"							Type="1"	NotZeroWarning=""
	SequenceEnd
MacroEnd

Module="XAXRFMultiFramePresentation"
	Name="PreferredPlaybackSequencing"							Type="3"	BinaryEnumValues="PreferredPlaybackSequencing"
	Sequence="FrameDisplaySequence"								Type="3"	VM="1-n"
		Name="StartTrim"										Type="1"
		Name="StopTrim"											Type="1"
		Name="SkipFrameRangeFlag"								Type="1"	StringDefinedTerms="SkipFrameRangeFlag"
		Name="RecommendedDisplayFrameRateInFloat"				Type="1"
		Name="RecommendedViewingMode"							Type="2"	StringDefinedTerms="RecommendedViewingMode"
		Name="DisplayFilterPercentage"							Type="2"
		Name="MaskVisibilityPercentage"							Type="1C"	Condition="RecommendedViewingModeIsSUB"
	SequenceEnd
ModuleEnd


Module="MultiFrameFunctionalGroupsForEnhancedXAImage"
	Sequence="SharedFunctionalGroupsSequence"	Type="2"	VM="0-1"
		InvokeMacro="ReferencedImageMacro"		Condition="ReferencedImageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="DerivationImageMacro"		Condition="DerivationImageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="CardiacSynchronizationMacro"		Condition="CardiacSynchronizationMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="FrameAnatomyMacro"			Condition="FrameAnatomySequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameVOILUTMacro"			Condition="FrameVOILUTSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="ContrastBolusUsageMacro"		Condition="NeedContrastBolusUsageMacroInSharedFunctionalGroupSequence"
		InvokeMacro="PixelIntensityRelationshipLUTMacro"		Condition="NeedPixelIntensityRelationshipLUTMacroInSharedFunctionalGroupSequence"
		InvokeMacro="FramePixelShiftMacro"		Condition="FramePixelShiftMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="PatientOrientationInFrameMacro"		Condition="NeedPatientOrientationInFrameMacroInSharedFunctionalGroupSequence"
		InvokeMacro="FrameDisplayShutterMacro"		Condition="FrameDisplayShutterMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="RespiratorySynchronizationMacro"		Condition="RespiratorySynchronizationMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="IrradiationEventIdentificationMacro"			Condition="IrradiationEventIdentificationSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="XAXRFFrameCharacteristicsMacro"		Condition="XAXRFFrameCharacteristicsMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="XRayFieldOfViewMacro"		Condition="NeedXRayFieldOfViewMacroInSharedFunctionalGroupSequence"
		InvokeMacro="XRayExposureControlSensingRegionsMacro"		Condition="XRayExposureControlSensingRegionsMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="XAXRFFramePixelDataPropertiesMacro"			Condition="FramePixelDataPropertiesSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayFrameDetectorParametersMacro"		Condition="NeedXRayFrameDetectorParametersMacroInSharedFunctionalGroupSequence"
		InvokeMacro="XRayCalibrationDeviceUsageMacro"		Condition="XRayCalibrationDeviceUsageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="XRayObjectThicknessMacro"		Condition="XRayObjectThicknessMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="XRayFrameAcquisitionMacro"		Condition="XRayFrameAcquisitionMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="XRayProjectionPixelCalibrationMacro"		Condition="NeedXRayProjectionPixelCalibrationMacroInSharedFunctionalGroupSequence"
		InvokeMacro="XRayPositionerMacro"		Condition="NeedXRayPositionerMacroInSharedFunctionalGroupSequence"
		InvokeMacro="XRayTablePositionMacro"		Condition="NeedXRayTablePositionMacroInSharedFunctionalGroupSequence"
		InvokeMacro="XRayCollimatorMacro"		Condition="NeedXRayCollimatorMacroInSharedFunctionalGroupSequence"
		InvokeMacro="XRayIsocenterReferenceSystemMacro"		Condition="XRayIsocenterReferenceSystemMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="XRayGeometryMacro"		Condition="NeedXRayGeometryMacroInSharedFunctionalGroupSequence"
	SequenceEnd
	Sequence="PerFrameFunctionalGroupsSequence"	Type="1"	VM="1-n"
		InvokeMacro="FrameContentMacro"
		InvokeMacro="ReferencedImageMacro"		Condition="ReferencedImageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="DerivationImageMacro"		Condition="DerivationImageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="CardiacSynchronizationMacro"		Condition="CardiacSynchronizationMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameAnatomyMacro"			Condition="FrameAnatomySequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="FrameVOILUTMacro"			Condition="FrameVOILUTSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="ContrastBolusUsageMacro"		Condition="NeedContrastBolusUsageMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="PixelIntensityRelationshipLUTMacro"		Condition="NeedPixelIntensityRelationshipLUTMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="FramePixelShiftMacro"		Condition="FramePixelShiftMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="PatientOrientationInFrameMacro"		Condition="NeedPatientOrientationInFrameMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameDisplayShutterMacro"		Condition="FrameDisplayShutterMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="RespiratorySynchronizationMacro"		Condition="RespiratorySynchronizationMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="IrradiationEventIdentificationMacro"			Condition="IrradiationEventIdentificationSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="XAXRFFrameCharacteristicsMacro"		Condition="XAXRFFrameCharacteristicsMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayFieldOfViewMacro"		Condition="NeedXRayFieldOfViewMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayExposureControlSensingRegionsMacro"		Condition="XRayExposureControlSensingRegionsMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="XAXRFFramePixelDataPropertiesMacro"			Condition="FramePixelDataPropertiesSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="XRayFrameDetectorParametersMacro"		Condition="NeedXRayFrameDetectorParametersMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayCalibrationDeviceUsageMacro"		Condition="XRayCalibrationDeviceUsageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayObjectThicknessMacro"		Condition="XRayObjectThicknessMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayFrameAcquisitionMacro"		Condition="XRayFrameAcquisitionMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayProjectionPixelCalibrationMacro"		Condition="NeedXRayProjectionPixelCalibrationMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayPositionerMacro"		Condition="NeedXRayPositionerMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayTablePositionMacro"		Condition="NeedXRayTablePositionMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayCollimatorMacro"		Condition="NeedXRayCollimatorMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayIsocenterReferenceSystemMacro"		Condition="XRayIsocenterReferenceSystemMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayGeometryMacro"		Condition="NeedXRayGeometryMacroInPerFrameFunctionalGroupSequence"
	SequenceEnd
ModuleEnd

Module="MultiFrameFunctionalGroupsForEnhancedXRFImage"
	Sequence="SharedFunctionalGroupsSequence"	Type="2"	VM="0-1"
		InvokeMacro="ReferencedImageMacro"		Condition="ReferencedImageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="DerivationImageMacro"		Condition="DerivationImageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="CardiacSynchronizationMacro"		Condition="CardiacSynchronizationMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="FrameAnatomyMacro"			Condition="FrameAnatomySequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameVOILUTMacro"			Condition="FrameVOILUTSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="ContrastBolusUsageMacro"		Condition="NeedContrastBolusUsageMacroInSharedFunctionalGroupSequence"
		InvokeMacro="PixelIntensityRelationshipLUTMacro"		Condition="NeedPixelIntensityRelationshipLUTMacroInSharedFunctionalGroupSequence"
		InvokeMacro="FramePixelShiftMacro"		Condition="FramePixelShiftMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="PatientOrientationInFrameMacro"		Condition="NeedPatientOrientationInFrameMacroInSharedFunctionalGroupSequence"
		InvokeMacro="FrameDisplayShutterMacro"		Condition="FrameDisplayShutterMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="RespiratorySynchronizationMacro"		Condition="RespiratorySynchronizationMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="IrradiationEventIdentificationMacro"			Condition="IrradiationEventIdentificationSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="XAXRFFrameCharacteristicsMacro"		Condition="XAXRFFrameCharacteristicsMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="XRayFieldOfViewMacro"		Condition="NeedXRayFieldOfViewMacroInSharedFunctionalGroupSequence"
		InvokeMacro="XRayExposureControlSensingRegionsMacro"		Condition="XRayExposureControlSensingRegionsMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="XAXRFFramePixelDataPropertiesMacro"			Condition="FramePixelDataPropertiesSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayFrameDetectorParametersMacro"		Condition="NeedXRayFrameDetectorParametersMacroInSharedFunctionalGroupSequence"
		InvokeMacro="XRayCalibrationDeviceUsageMacro"		Condition="XRayCalibrationDeviceUsageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="XRayObjectThicknessMacro"		Condition="XRayObjectThicknessMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="XRayFrameAcquisitionMacro"		Condition="XRayFrameAcquisitionMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="XRayPositionerMacro"		Condition="NeedXRayPositionerMacroInSharedFunctionalGroupSequence"
		InvokeMacro="XRayTablePositionMacro"		Condition="NeedXRayTablePositionMacroInSharedFunctionalGroupSequence"
		InvokeMacro="XRayCollimatorMacro"		Condition="NeedXRayCollimatorMacroInSharedFunctionalGroupSequence"
		InvokeMacro="XRayGeometryMacro"		Condition="NeedXRayGeometryMacroInSharedFunctionalGroupSequence"
	SequenceEnd
	Sequence="PerFrameFunctionalGroupsSequence"	Type="1"	VM="1-n"
		InvokeMacro="FrameContentMacro"
		InvokeMacro="ReferencedImageMacro"		Condition="ReferencedImageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="DerivationImageMacro"		Condition="DerivationImageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="CardiacSynchronizationMacro"		Condition="CardiacSynchronizationMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameAnatomyMacro"			Condition="FrameAnatomySequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="FrameVOILUTMacro"			Condition="FrameVOILUTSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="ContrastBolusUsageMacro"		Condition="NeedContrastBolusUsageMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="PixelIntensityRelationshipLUTMacro"		Condition="NeedPixelIntensityRelationshipLUTMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="FramePixelShiftMacro"		Condition="FramePixelShiftMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="PatientOrientationInFrameMacro"		Condition="NeedPatientOrientationInFrameMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameDisplayShutterMacro"		Condition="FrameDisplayShutterMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="RespiratorySynchronizationMacro"		Condition="RespiratorySynchronizationMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="IrradiationEventIdentificationMacro"			Condition="IrradiationEventIdentificationSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="XAXRFFrameCharacteristicsMacro"		Condition="XAXRFFrameCharacteristicsMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayFieldOfViewMacro"		Condition="NeedXRayFieldOfViewMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayExposureControlSensingRegionsMacro"		Condition="XRayExposureControlSensingRegionsMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="XAXRFFramePixelDataPropertiesMacro"			Condition="FramePixelDataPropertiesSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="XRayFrameDetectorParametersMacro"		Condition="NeedXRayFrameDetectorParametersMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayCalibrationDeviceUsageMacro"		Condition="XRayCalibrationDeviceUsageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayObjectThicknessMacro"		Condition="XRayObjectThicknessMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayFrameAcquisitionMacro"		Condition="XRayFrameAcquisitionMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayPositionerMacro"		Condition="NeedXRayPositionerMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayTablePositionMacro"		Condition="NeedXRayTablePositionMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayCollimatorMacro"		Condition="NeedXRayCollimatorMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRayGeometryMacro"		Condition="NeedXRayGeometryMacroInPerFrameFunctionalGroupSequence"
	SequenceEnd
ModuleEnd

Module="MultiFrameFunctionalGroupsForXRay3DAngiographicImage"
	Sequence="SharedFunctionalGroupsSequence"	Type="2"	VM="0-1"
		InvokeMacro="PixelMeasuresMacro"		Condition="PixelMeasuresSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PlanePositionMacro"		Condition="PlanePositionSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PlaneOrientationMacro"		Condition="PlaneOrientationSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="ReferencedImageMacro"		Condition="ReferencedImageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="DerivationImageMacro"		Condition="DerivationImageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="CardiacSynchronizationMacro"		Condition="CardiacSynchronizationMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="FrameAnatomyMacro"			Condition="FrameAnatomySequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PixelValueTransformationMacro"	Condition="PixelValueTransformationSequenceOKInSharedFunctionalGroupSequence"
		InvokeMacro="FrameVOILUTMacro"			Condition="FrameVOILUTSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="RealWorldValueMappingMacro"	Condition="RealWorldValueMappingMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="ContrastBolusUsageMacro"		Condition="NeedContrastBolusUsageMacroInSharedFunctionalGroupSequence"
		InvokeMacro="RespiratorySynchronizationMacro"		Condition="RespiratorySynchronizationMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="XRay3DFrameTypeMacro"		Condition="XRay3DFrameTypeSequenceNotInPerFrameFunctionalGroupSequence"
	SequenceEnd
	Sequence="PerFrameFunctionalGroupsSequence"	Type="1"	VM="1-n"
		InvokeMacro="PixelMeasuresMacro"		Condition="PixelMeasuresSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="FrameContentMacro"
		InvokeMacro="PlanePositionMacro"		Condition="PlanePositionSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="PlaneOrientationMacro"		Condition="PlaneOrientationSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="ReferencedImageMacro"		Condition="ReferencedImageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="DerivationImageMacro"		Condition="DerivationImageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="CardiacSynchronizationMacro"		Condition="CardiacSynchronizationMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameAnatomyMacro"			Condition="FrameAnatomySequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="PixelValueTransformationMacro"	Condition="PixelValueTransformationSequenceOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameVOILUTMacro"			Condition="FrameVOILUTSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="RealWorldValueMappingMacro"	Condition="RealWorldValueMappingMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="ContrastBolusUsageMacro"		Condition="NeedContrastBolusUsageMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="RespiratorySynchronizationMacro"		Condition="RespiratorySynchronizationMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRay3DFrameTypeMacro"		Condition="XRay3DFrameTypeSequenceNotInSharedFunctionalGroupSequence"
	SequenceEnd
ModuleEnd

Module="MultiFrameFunctionalGroupsForXRay3DCraniofacialImage"
	Sequence="SharedFunctionalGroupsSequence"	Type="2"	VM="0-1"
		InvokeMacro="PixelMeasuresMacro"		Condition="PixelMeasuresSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PlanePositionMacro"		Condition="PlanePositionSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PlaneOrientationMacro"		Condition="PlaneOrientationSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="ReferencedImageMacro"		Condition="ReferencedImageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="DerivationImageMacro"		Condition="DerivationImageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="FrameAnatomyMacro"			Condition="FrameAnatomySequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PixelValueTransformationMacro"	Condition="PixelValueTransformationSequenceOKInSharedFunctionalGroupSequence"
		InvokeMacro="FrameVOILUTMacro"			Condition="FrameVOILUTSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="RealWorldValueMappingMacro"	Condition="RealWorldValueMappingMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="ContrastBolusUsageMacro"		Condition="NeedContrastBolusUsageMacroInSharedFunctionalGroupSequence"
		InvokeMacro="XRay3DFrameTypeMacro"		Condition="XRay3DFrameTypeSequenceNotInPerFrameFunctionalGroupSequence"
	SequenceEnd
	Sequence="PerFrameFunctionalGroupsSequence"	Type="1"	VM="1-n"
		InvokeMacro="PixelMeasuresMacro"		Condition="PixelMeasuresSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="FrameContentMacro"
		InvokeMacro="PlanePositionMacro"		Condition="PlanePositionSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="PlaneOrientationMacro"		Condition="PlaneOrientationSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="ReferencedImageMacro"		Condition="ReferencedImageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="DerivationImageMacro"		Condition="DerivationImageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameAnatomyMacro"			Condition="FrameAnatomySequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="PixelValueTransformationMacro"	Condition="PixelValueTransformationSequenceOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameVOILUTMacro"			Condition="FrameVOILUTSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="RealWorldValueMappingMacro"	Condition="RealWorldValueMappingMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="ContrastBolusUsageMacro"		Condition="NeedContrastBolusUsageMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="XRay3DFrameTypeMacro"		Condition="XRay3DFrameTypeSequenceNotInSharedFunctionalGroupSequence"
	SequenceEnd
ModuleEnd

Module="XRay3DImage"
	Name="ImageType"										Type="1"	VM="4"
	Verify="ImageType"													ValueSelector="0"	StringEnumValues="CommonEnhancedImageType1"
	Verify="ImageType"													ValueSelector="1"	StringEnumValues="CommonEnhancedImageAndFrameType2"
	Verify="ImageType"													ValueSelector="2"	StringDefinedTerms="CommonEnhancedImageAndFrameType3"
	Verify="ImageType"													ValueSelector="3"	StringEnumValues="XRay3DImageAndFrameType4"
	InvokeMacro="CommonCTMRImageDescriptionImageLevelMacro"
	Name="BitsAllocated"									Type="1"	BinaryEnumValues="BitsAre8Or16"
	Name="BitsStored"										Type="1"	BinaryEnumValues="BitsAre8To16"
	Name="HighBit"											Type="1"	BinaryEnumValues="BitsAre7To15"
	Name="SamplesPerPixel"									Type="1"	BinaryEnumValues="SamplesPerPixelIsOne"
	Name="PhotometricInterpretation"						Type="1"	StringEnumValues="PhotometricInterpretationMonochrome2"
	Name="ContentQualification"								Type="1"	StringEnumValues="ContentQualification"
	Name="BurnedInAnnotation"								Type="1"	StringEnumValues="NoFull"
	Name="LossyImageCompression"							Type="1"	StringEnumValues="LossyImageCompression"
	Name="LossyImageCompressionRatio"						Type="1C"	Condition="LossyImageCompressionIs01"
	Name="LossyImageCompressionMethod"						Type="1C"	StringDefinedTerms="LossyImageCompressionMethod"	Condition="LossyImageCompressionIs01"
	Verify="LossyImageCompressionMethod"								Condition="LossyImageCompressionMethodInconsistentWithTransferSyntax"	ThenWarningMessage="method inconsistent with transfer syntax" ShowValueWithMessage="true"
	Sequence="ReferencedImageEvidenceSequence"				Type="1C"	VM="1-n"	Condition="ReferencedImageSequenceIsPresent"
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Name="ImageComments"									Type="3"
	Name="QualityControlImage"								Type="3"	StringEnumValues="YesNoFull"
	Sequence="IconImageSequence"							Type="3"	VM="1"
		InvokeMacro="IconImageSequenceMacro"
	SequenceEnd
	Name="PresentationLUTShape"								Type="1"	StringEnumValues="IdentityPresentationLUTShape"
ModuleEnd

Module="XRay3DAngiographicImageContributingSources"
	Sequence="ContributingSourcesSequence"		Type="1"	VM="1-n"
		InvokeMacro="GeneralContributingSourcesMacro"
		InvokeMacro="ContributingImageSourcesMacro"
		Name="AcquisitionDeviceProcessingDescription"		Type="1C"	NoCondition=""	# if present and have an equal value in the contributing SOP Instances :(
		Name="AcquisitionDeviceProcessingCode"				Type="1C"	NoCondition=""	# if present and have an equal value in the contributing SOP Instances :(
		Name="PlaneIdentification"							Type="1C"	NoCondition=""	StringEnumValues="PlaneIdentification"	# if present and have an equal value in the contributing SOP Instances :(
		Name="ImagerPixelSpacing"							Type="1C"	NoCondition=""	# if present and have an equal value in the contributing SOP Instances :(
	SequenceEnd
ModuleEnd

Module="XRay3DCraniofacialImageContributingSources"
	Sequence="ContributingSourcesSequence"		Type="1"	VM="1-n"
		InvokeMacro="GeneralContributingSourcesMacro"
		InvokeMacro="ContributingImageSourcesMacro"
		Name="AcquisitionDeviceProcessingDescription"		Type="1C"	NoCondition=""	# if present and have an equal value in the contributing SOP Instances :(
		Name="AcquisitionDeviceProcessingCode"				Type="1C"	NoCondition=""	# if present and have an equal value in the contributing SOP Instances :(
		Name="ImagerPixelSpacing"							Type="1C"	NoCondition=""	# if present and have an equal value in the contributing SOP Instances :(
	SequenceEnd
ModuleEnd

DefineMacro="XRay3DGeneralSharedAcquisitionMacro"
	Sequence="SourceImageEvidenceSequence"					Type="1C"	VM="1-n"	Condition="SourceImageSequenceIsPresent"	# if present and have an equal value in the contributing SOP Instances :(
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Name="FieldOfViewShape"								Type="1C"	NoCondition=""	StringDefinedTerms="FieldOfViewShape"		# if present and have an equal value in the contributing SOP Instances :(
	Name="FieldOfViewDimensionsInFloat"					Type="1C"	NoCondition=""	NotZeroWarning=""							# if present and have an equal value in the contributing SOP Instances :(
	Name="FieldOfViewOrigin"							Type="1C"	Condition="XRayReceptorTypeIsDigitalDetector"
	Name="FieldOfViewRotation"							Type="1C"	NoCondition=""	StringEnumValues="DXFieldOfViewRotation"	# if present and have an equal value in the contributing SOP Instances :(
	Name="FieldOfViewHorizontalFlip"					Type="1C"	NoCondition=""	StringEnumValues="YesNoFull"				# if present and have an equal value in the contributing SOP Instances :(
	Name="Grid"											Type="1C"	NoCondition=""	StringDefinedTerms="XRayGrid"				# if present and have an equal value in the contributing SOP Instances :(
	Name="XRayReceptorType"								Type="1C"	NoCondition=""	StringEnumValues="XRayReceptorType"			# if present and have an equal value in the contributing SOP Instances :(
	Name="KVP"											Type="1C"	NoCondition=""	NotZeroWarning=""							# if present and have an equal value in the contributing SOP Instances :(
	Name="XRayTubeCurrentInmA"							Type="1C"	NoCondition=""	NotZeroWarning=""							# if present and have an equal value in the contributing SOP Instances :(
	Name="ExposureTimeInms"								Type="1C"	NoCondition=""	NotZeroWarning=""							# if present and have an equal value in the contributing SOP Instances :(
	Name="ExposureInmAs"								Type="1C"	NoCondition=""	NotZeroWarning=""							# if present and have an equal value in the contributing SOP Instances :(
	Name="ContrastBolusAgent"							Type="1C"	NoCondition=""												# if present and have an equal value in the contributing SOP Instances :(
	Sequence="ContrastBolusAgentSequence"				Type="1C"	VM="1-n"	NoCondition=""									# if present and have an equal value in the contributing SOP Instances :(
		InvokeMacro="CodeSequenceMacro"
	SequenceEnd
	Name="StartAcquisitionDateTime"						Type="1C"	NoCondition=""												# if present and have an equal value in the contributing SOP Instances :(
	Name="EndAcquisitionDateTime"						Type="1C"	NoCondition=""												# if present and have an equal value in the contributing SOP Instances :(
MacroEnd

DefineMacro="XRay3DGeneralPerProjectionAcquisitionMacro"
	Name="KVP"											Type="1C"	NoCondition=""	NotZeroWarning=""							# if present and have an equal value in the contributing SOP Instances :(
	Name="XRayTubeCurrentInmA"							Type="1C"	NoCondition=""	NotZeroWarning=""							# if present and have an equal value in the contributing SOP Instances :(
	Name="FrameAcquisitionDuration"						Type="1C"	NoCondition=""	NotZeroWarning=""							# if present and have an equal value in the contributing SOP Instances :(
	Name="CollimatorShape"								Type="1C"	NoCondition=""	StringEnumValues="CollimatorShape"			# if present and have an equal value in the contributing SOP Instances :(
	Name="CollimatorLeftVerticalEdge"					Type="1C"	Condition="CollimatorShapeIsRectangular"
	Name="CollimatorRightVerticalEdge"					Type="1C"	Condition="CollimatorShapeIsRectangular"
	Name="CollimatorUpperHorizontalEdge"				Type="1C"	Condition="CollimatorShapeIsRectangular"
	Name="CollimatorLowerHorizontalEdge"				Type="1C"	Condition="CollimatorShapeIsRectangular"
	Name="CenterOfCircularCollimator"					Type="1C"	Condition="CollimatorShapeIsCircular"
	Name="RadiusOfCircularCollimator"					Type="1C"	Condition="CollimatorShapeIsCircular"	NotZeroWarning=""
	Name="VerticesOfPolygonalCollimator"				Type="1C"	Condition="CollimatorShapeIsPolygonal"
MacroEnd

Module="XRay3DAngiographicAcquisition"
	Sequence="XRay3DAcquisitionSequence"		Type="1"	VM="1-n"
		InvokeMacro="XRay3DGeneralSharedAcquisitionMacro"
		InvokeMacro="DigitalXRayDetectorMacro"
		Name="PhysicalDetectorSize"								Type="1C"	NoCondition=""	NotZeroError=""							# if present and have an equal value in the contributing SOP Instances :(
		Name="PositionOfIsocenterProjection"					Type="1C"	Condition="IsocenterReferenceSystemSequencePresent"		# if present and have an equal value in the contributing SOP Instances :(
		Name="DistanceSourceToPatient"							Type="1C"	NoCondition=""	NotZeroWarning=""						# if present and have an equal value in the contributing SOP Instances :(
		Name="DistanceSourceToDetector"							Type="1C"	NoCondition=""	NotZeroWarning=""						# if present and have an equal value in the contributing SOP Instances :(
		Name="FocalSpot"										Type="1C"	NoCondition=""
		Name="FilterType"										Type="1C"	NoCondition=""	StringDefinedTerms="DXFilterType"		# if present and have an equal value in the contributing SOP Instances :(
		Name="FilterMaterial"									Type="1C"	NoCondition=""	StringDefinedTerms="DXFilterMaterial"	# if present and have an equal value in the contributing SOP Instances :(
		Name="FilterThicknessMaximum"							Type="1C"	NoCondition=""	NotZeroWarning=""						# if present and have an equal value in the contributing SOP Instances :(
		Name="FilterThicknessMinimum"							Type="1C"	NoCondition=""	NotZeroWarning=""						# if present and have an equal value in the contributing SOP Instances :(
		Name="PrimaryPositionerScanArc"							Type="1C"	NoCondition=""	NotZeroWarning=""						# if present and have an equal value in the contributing SOP Instances :(
		Name="PrimaryPositionerScanStartAngle"					Type="1C"	NoCondition=""											# if present and have an equal value in the contributing SOP Instances :(
		Name="PrimaryPositionerIncrement"						Type="1C"	NoCondition=""	NotZeroWarning=""						# if present and have an equal value in the contributing SOP Instances :(
		Name="SecondaryPositionerScanArc"						Type="1C"	NoCondition=""	NotZeroWarning=""						# if present and have an equal value in the contributing SOP Instances :(
		Name="SecondaryPositionerScanStartAngle"				Type="1C"	NoCondition=""											# if present and have an equal value in the contributing SOP Instances :(
		Name="SecondaryPositionerIncrement"						Type="1C"	NoCondition=""	NotZeroWarning=""						# if present and have an equal value in the contributing SOP Instances :(
		Sequence="PerProjectionAcquisitionSequence"				Type="1C"	VM="0-n"	NoCondition=""								# if present and have an equal value in the contributing SOP Instances :(
			InvokeMacro="XRay3DGeneralPerProjectionAcquisitionMacro"
			Name="PositionerIsocenterPrimaryAngle"				Type="1C"	NoCondition=""											# if present and have an equal value in the contributing SOP Instances :(
			Name="PositionerIsocenterSecondaryAngle"			Type="1C"	NoCondition=""											# if present and have an equal value in the contributing SOP Instances :(
			Name="PositionerIsocenterDetectorRotationAngle"		Type="1C"	NoCondition=""											# if present and have an equal value in the contributing SOP Instances :(
		SequenceEnd
	SequenceEnd
ModuleEnd

Module="XRay3DCraniofacialAcquisition"
	Sequence="XRay3DAcquisitionSequence"		Type="1"	VM="1-n"
		InvokeMacro="XRay3DGeneralSharedAcquisitionMacro"
		InvokeMacro="DigitalXRayDetectorMacro"
		Sequence="PerProjectionAcquisitionSequence"				Type="1C"	VM="0-n"	NoCondition=""								# if present and have an equal value in the contributing SOP Instances :(
			InvokeMacro="XRay3DGeneralPerProjectionAcquisitionMacro"
		SequenceEnd
	SequenceEnd
ModuleEnd

Module="XRay3DReconstruction"
	Sequence="XRay3DReconstructionSequence"		Type="1"	VM="1-n"
		Name="ReconstructionDescription"		Type="3"
		Name="ApplicationName"					Type="1"
		Name="ApplicationVersion"				Type="1"
		Name="ApplicationManufacturer"			Type="1"
		Name="AlgorithmType"					Type="1"
		Name="AlgorithmDescription"				Type="3"
		Name="AcquisitionIndex"				Type="1"
	SequenceEnd
ModuleEnd

DefineMacro="XRay3DFrameTypeMacro"
	Sequence="XRay3DFrameTypeSequence"				Type="1"	VM="1"
		Name="FrameType"							Type="1"	VM="4"
		Verify="FrameType"										ValueSelector="0"	StringEnumValues="CommonEnhancedFrameType1"
		Verify="FrameType"										ValueSelector="1"	StringEnumValues="CommonEnhancedImageAndFrameType2"
		Verify="FrameType"										ValueSelector="2"	StringDefinedTerms="CommonEnhancedImageAndFrameType3"
		Verify="FrameType"										ValueSelector="3"	StringEnumValues="XRay3DImageAndFrameType4"
		InvokeMacro="CommonCTMRImageDescriptionFrameLevelMacro"
		Name="ReconstructionIndex"					Type="1"
	SequenceEnd
MacroEnd
