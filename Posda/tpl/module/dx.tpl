#$Source: /home/bbennett/pass/archive/Posda/tpl/module/dx.tpl,v $
#$Date: 2010/04/30 18:53:53 $
#$Revision: 1.2 $
#
Module="XRayAcquisitionDose"
	Name="KVP"									Type="3"	NotZeroWarning=""
	
	Name="XRayTubeCurrent"						Type="3"	NotZeroWarning=""
	Name="XRayTubeCurrentInuA"					Type="3"	NotZeroWarning=""
	Verify="XRayTubeCurrentInmA"							Condition="XRayTubeCurrentInmAIsPresentAndOthersAreNot" ThenErrorMessage="Attribute should not be used with Module <XRayAcquisitionDose> - use XRayTubeCurrent and/or XRayTubeCurrentInuA instead of"
	
	Name="ExposureTime"							Type="3"	NotZeroWarning=""
	Name="ExposureTimeInuS"						Type="3"	NotZeroWarning=""
	Verify="ExposureTimeInms"								Condition="ExposureTimeInmsIsPresentAndOthersAreNot" ThenErrorMessage="Attribute should not be used with Module <XRayAcquisitionDose> - use ExposureTime and/or ExposureTimeInuS instead of"
	
	Name="Exposure"								Type="3"	NotZeroWarning=""
	Name="ExposureInuAs"						Type="3"	NotZeroWarning=""
	Verify="ExposureInmAs"									Condition="ExposureInmAsIsPresentAndOthersAreNot" ThenErrorMessage="Attribute should not be used with Module <XRayAcquisitionDose> - use Exposure and/or ExposureInuAs instead of"
	
	Name="DistanceSourceToDetector"				Type="3"	NotZeroWarning=""
	Name="DistanceSourceToPatient"				Type="3"	NotZeroWarning=""
	Name="ImageAndFluoroscopyAreaDoseProduct"	Type="3"	NotZeroWarning=""
	Name="BodyPartThickness"					Type="3"	NotZeroWarning=""
	Name="RelativeXRayExposure"					Type="3"	NotZeroWarning=""
	Name="EntranceDose"							Type="3"	NotZeroWarning=""
	Name="EntranceDoseInmGy"					Type="3"	NotZeroWarning=""
	Name="ExposedArea"							Type="3"
	Name="DistanceSourceToEntrance"				Type="3"	NotZeroWarning=""
	Name="CommentsOnRadiationDose"				Type="3"
	Name="XRayOutput"							Type="3"	NotZeroWarning=""
	Name="HalfValueLayer"						Type="3"	NotZeroWarning=""
	Name="OrganDose"							Type="3"	NotZeroWarning=""
	Name="OrganExposed"							Type="3"	StringDefinedTerms="OrganExposed"
	Name="AnodeTargetMaterial"					Type="3"	StringDefinedTerms="AnodeTargetMaterial"
	Name="FilterMaterial"						Type="3"	StringDefinedTerms="DXFilterMaterial"
	Name="FilterThicknessMaximum"				Type="3"	NotZeroWarning=""
	Name="FilterThicknessMinimum"				Type="3"	NotZeroWarning=""
	Name="RectificationType"					Type="3"	StringDefinedTerms="RectificationType"
ModuleEnd

Module="XRayGeneration"
	Name="KVP"									Type="3"	NotZeroWarning=""
	
	Name="XRayTubeCurrent"						Type="3"	NotZeroWarning=""
	Name="XRayTubeCurrentInuA"					Type="3"	NotZeroWarning=""
	Verify="XRayTubeCurrentInmA"							Condition="XRayTubeCurrentInmAIsPresentAndOthersAreNot" ThenErrorMessage="Attribute should not be used with Module <XRayGeneration> - use XRayTubeCurrent and/or XRayTubeCurrentInuA instead of"
	
	Name="ExposureTime"							Type="3"	NotZeroWarning=""
	Name="ExposureTimeInuS"						Type="3"	NotZeroWarning=""
	Verify="ExposureTimeInms"								Condition="ExposureTimeInmsIsPresentAndOthersAreNot" ThenErrorMessage="Attribute should not be used with Module <XRayGeneration> - use ExposureTime and/or ExposureTimeInuS instead of"
	
	Name="Exposure"								Type="3"	NotZeroWarning=""
	Name="ExposureInuAs"						Type="3"	NotZeroWarning=""
	Verify="ExposureInmAs"									Condition="ExposureInmAsIsPresentAndOthersAreNot" ThenErrorMessage="Attribute should not be used with Module <XRayGeneration> - use Exposure and/or ExposureInuAs instead of"
	
	Name="ExposureControlMode"					Type="3"	StringDefinedTerms="ExposureControlMode"
	Name="ExposureControlModeDescription"		Type="3"
	Name="ExposureStatus"						Type="3"	StringDefinedTerms="ExposureStatus"
	Name="PhototimerSetting"					Type="3"
	Name="FocalSpot"							Type="3"
	Name="AnodeTargetMaterial"					Type="3"	StringDefinedTerms="AnodeTargetMaterial"
	Name="RectificationType"					Type="3"	StringDefinedTerms="RectificationType"
	Name="GeneratorID"							Type="3"
ModuleEnd

Module="XRayFiltration"
	Name="FilterType"							Type="3"	StringDefinedTerms="DXFilterType"
	Name="FilterMaterial"						Type="3"	StringDefinedTerms="DXFilterMaterial"
	Name="FilterThicknessMaximum"				Type="3"	NotZeroWarning=""
	Name="FilterThicknessMinimum"				Type="3"	NotZeroWarning=""
ModuleEnd

Module="XRayGrid"
	Name="Grid"									Type="3"	StringDefinedTerms="XRayGrid"
	Name="GridAbsorbingMaterial"				Type="3"
	Name="GridSpacingMaterial"					Type="3"
	Name="GridThickness"						Type="3"	NotZeroWarning=""
	Name="GridPitch"							Type="3"	NotZeroWarning=""
	Name="GridAspectRatio"						Type="3"	NotZeroWarning=""
	Name="GridPeriod"							Type="3"	NotZeroWarning=""
	Name="GridFocalDistance"					Type="3"	NotZeroWarning=""
	Name="GridID"								Type="3"
ModuleEnd

Module="DXSeries"
	Name="Modality"										Type="1"	StringEnumValues="DXModality"
	Sequence="ReferencedPerformedProcedureStepSequence"	Type="1C"	VM="1"	Condition="SeriesNeedReferencedPerformedProcedureStepSequence"
		InvokeMacro="SOPInstanceReferenceMacro"
	SequenceEnd
	Name="PresentationIntentType"						Type="1"	StringEnumValues="PresentationIntentType"
	Verify="PresentationIntentType"									Condition="IsForProcessingSOPClass"	StringEnumValues="ForProcessing"
	Verify="PresentationIntentType"									Condition="IsForPresentationSOPClass"	StringEnumValues="ForPresentation"
ModuleEnd

Module="DXAnatomyImaged"
	Name="ImageLaterality"								Type="1"	StringEnumValues="ImageLaterality"
	InvokeMacro="GeneralAnatomyRequiredMacro"
ModuleEnd

Module="DXImage"
	Name="ImageType"									Type="1"	ValueSelector="0"	StringEnumValues="ImageType1"
	Verify="ImageType"												ValueSelector="1"	StringEnumValues="ImageType2"
	Verify="ImageType"												ValueSelector="2"	StringEnumValues="DXImageType3"
	Name="SamplesPerPixel"								Type="1"	BinaryEnumValues="SamplesPerPixelIsOne"
	Name="PhotometricInterpretation"					Type="1"	StringEnumValues="PhotometricInterpretationMonochrome"
	Name="BitsAllocated"								Type="1"	BinaryEnumValues="BitsAre8Or16"
	Name="BitsStored"									Type="1"	BinaryEnumValues="BitsAre6To16"
	Name="HighBit"										Type="1"	BinaryEnumValues="BitsAre5To15"
	Name="PixelRepresentation"							Type="1"	BinaryEnumValues="PixelRepresentationUnsigned"
	Name="PixelIntensityRelationship"					Type="1"	StringEnumValues="DXPixelIntensityRelationship"
	Name="PixelIntensityRelationshipSign"				Type="1"	BinaryEnumValues="PixelIntensityRelationshipSign"
	Name="RescaleIntercept"								Type="1"	BinaryEnumValues="Zero"
	Name="RescaleSlope"									Type="1"	BinaryEnumValues="One"
	Name="RescaleType"									Type="1"	StringEnumValues="ModalityLUTTypeUnspecified"
	Name="PresentationLUTShape"							Type="1"	StringEnumValues="DXPresentationLUTShape"
	Name="LossyImageCompression"						Type="1"	StringEnumValues="LossyImageCompression"
	Name="LossyImageCompressionRatio"					Type="1C"	NoCondition=""
	Name="DerivationDescription"						Type="3"
	Name="AcquisitionDeviceProcessingDescription"		Type="3"
	Name="AcquisitionDeviceProcessingCode"				Type="3"
	Name="PatientOrientation"							Type="1C"	Condition="DXPatientOrientationRequired" mbpo="true"
	Name="CalibrationImage"								Type="3"	StringEnumValues="YesNoFull"
	Name="BurnedInAnnotation"							Type="1"	StringEnumValues="YesNoFull"
	Sequence="VOILUTSequence"							Type="1C"	VM="1-n"	Condition="ForPresentationAndWindowCenterNotPresent" mbpo="true"
		Name="LUTDescriptor"							Type="1"
		Verify="LUTDescriptor"										ValueSelector="2"	BinaryEnumValues="BitsAre10To16"
		Name="LUTExplanation"							Type="3"
		Name="LUTData"									Type="1"
	SequenceEnd
	Verify="VOILUTSequence"											Condition="VOILUTSequencePresentAndPresentationIntentTypeIsNotForPresentation" ThenErrorMessage="May only be present in For Presentation images"
	Name="WindowCenter"									Type="1C"	Condition="ForPresentationAndVOILUTSequenceNotPresent" mbpo="true"
	Verify="WindowCenter"											Condition="WindowCenterPresentAndPresentationIntentTypeIsNotForPresentation" ThenErrorMessage="May only be present in For Presentation images"
	Name="WindowWidth"									Type="1C"	Condition="WindowCenterPresent"	NotZeroError=""
	Name="WindowCenterWidthExplanation"					Type="3"
ModuleEnd

DefineMacro="DigitalXRayDetectorMacro" InformationEntity="Image"
	Name="DetectorType"									Type="2"	StringDefinedTerms="DetectorType"
	Name="DetectorConfiguration"						Type="3"	StringDefinedTerms="DetectorConfiguration"
	Name="DetectorDescription"							Type="3"
	Name="DetectorMode"									Type="3"
	Name="DetectorID"									Type="3"
	Name="DateOfLastDetectorCalibration"				Type="3"
	Name="TimeOfLastDetectorCalibration"				Type="3"
	Name="ExposuresOnDetectorSinceLastCalibration"		Type="3"
	Name="ExposuresOnDetectorSinceManufactured"			Type="3"
	Name="DetectorTimeSinceLastExposure"				Type="3"
	Name="DetectorBinning"								Type="3"
	Name="DetectorManufacturerName"						Type="3"
	Name="DetectorManufacturerModelName"				Type="3"
	Name="DetectorConditionsNominalFlag"				Type="3"	StringEnumValues="YesNoFull"
	Name="DetectorTemperature"							Type="3"
	Name="Sensitivity"									Type="3"	NotZeroWarning=""
	Name="DetectorElementPhysicalSize"					Type="3"	NotZeroError=""
	Name="DetectorElementSpacing"						Type="3"	NotZeroError=""
	Name="DetectorActiveShape"							Type="3"	StringEnumValues="DXShape"
	Name="DetectorActiveDimensions"						Type="3"
	Name="DetectorActiveOrigin"							Type="3"
MacroEnd

Module="DXDetector"
	InvokeMacro="DigitalXRayDetectorMacro"
	Name="DetectorActiveTime"							Type="3"
	Name="DetectorActivationOffsetFromExposure"			Type="3"
	Name="FieldOfViewShape"								Type="3"	StringEnumValues="DXShape"
	Name="FieldOfViewDimensions"						Type="3"	NotZeroError=""
	Name="FieldOfViewOrigin"							Type="1C"	Condition="FieldOfViewRotationOrFieldOfViewHorizontalFlipPresent"
	Name="FieldOfViewRotation"							Type="1C"	Condition="FieldOfViewHorizontalFlipPresent"	StringEnumValues="DXFieldOfViewRotation"
	Name="FieldOfViewHorizontalFlip"					Type="1C"	Condition="FieldOfViewRotationPresent"		StringEnumValues="YesNoFull"
	Name="ImagerPixelSpacing"							Type="1"	NotZeroError=""
	InvokeMacro="BasicPixelSpacingCalibrationMacro"
	Name="CassetteID"									Type="3"
	Name="PlateID"										Type="3"
ModuleEnd

Module="DXPositioning"
	Sequence="ProjectionEponymousNameCodeSequence"		Type="3"	VM="1"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="4012"
	SequenceEnd
	Name="PatientPosition"								Type="3"	StringDefinedTerms="PatientPosition"
	Name="ViewPosition"									Type="3"	StringDefinedTerms="ViewPosition"
	Sequence="ViewCodeSequence"							Type="3"	VM="1"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="4010"
		Sequence="ViewModifierCodeSequence"				Type="3"	VM="0-n"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="4011"
		SequenceEnd
	SequenceEnd
	Verify="ViewCodeSequence"										Condition="ViewCodeSequenceAbsentOrEmptyButViewPositionHasValue"	ThenWarningMessage="ViewCodeSequence is empty or absent, but view is known since ViewPosition has a value"
	Sequence="ViewModifierCodeSequence"					Type="1C"	VM="0-n"	Condition="Never"
	SequenceEnd
	Sequence="PatientOrientationCodeSequence"			Type="3"	VM="1"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="19"
		Sequence="PatientOrientationModifierCodeSequence"	Type="3"	VM="1"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="20"
		SequenceEnd
	SequenceEnd
	Sequence="PatientOrientationModifierCodeSequence"	Type="1C"	VM="1"	Condition="Never"
	SequenceEnd
	Sequence="PatientGantryRelationshipCodeSequence"	Type="3"	VM="1"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="21"
	SequenceEnd
	Name="DistanceSourceToPatient"						Type="3"	NotZeroWarning=""
	Name="DistanceSourceToDetector"						Type="3"	NotZeroWarning=""
	Name="EstimatedRadiographicMagnificationFactor"		Type="3"
	Name="PositionerType"								Type="2"	StringDefinedTerms="DXPositionerType"
	Name="PositionerPrimaryAngle"						Type="3"
	Name="PositionerSecondaryAngle"						Type="3"
	Name="DetectorPrimaryAngle"							Type="3"
	Name="DetectorSecondaryAngle"						Type="3"
	Name="ColumnAngulation"								Type="3"
	Name="TableType"									Type="3"	StringDefinedTerms="DXTableType"
	Name="TableAngle"									Type="3"
	Name="BodyPartThickness"							Type="3"	NotZeroWarning=""
	Name="CompressionForce"								Type="3"
ModuleEnd

Module="MammographySeries"
	Name="Modality"										Type="1"	StringEnumValues="MammographyModality"
	Sequence="RequestAttributesSequence"				Type="3"	VM="1-n"
		InvokeMacro="RequestAttributesMacro"
	SequenceEnd
ModuleEnd

Module="MammographyImage"
	Name="ImageType"									Type="1"	ValueSelector="2"	StringEnumValues="MammoImageType3"
	Name="PositionerType"								Type="1"	StringEnumValues="MammographyPositionerType"
	Name="DistanceSourceToPatient"						Type="3"	NotZeroWarning=""
	Name="DistanceSourceToDetector"						Type="3"	NotZeroWarning=""
	Name="PositionerPrimaryAngle"						Type="3"
	Name="PositionerSecondaryAngle"						Type="3"
	Name="ImageLaterality"								Type="1"	StringEnumValues="MammographyImageLaterality"
	Name="OrganExposed"									Type="1"	StringDefinedTerms="MammographyOrganExposed"
	Name="BreastImplantPresent"							Type="3"	StringEnumValues="YesNoFull"
	Name="PartialView"									Type="3"	StringEnumValues="YesNoFull"
	Name="PartialViewDescription"						Type="3"
	Sequence="PartialViewCodeSequence"					Type="3"	VM="1-2"
		InvokeMacro="CodeSequenceMacro"								DefinedContextID="4005"
	SequenceEnd
	InvokeMacro="GeneralAnatomyMandatoryMacro"
	Sequence="ViewCodeSequence"							Type="1"	VM="1"
		InvokeMacro="CodeSequenceMacro"								EnmeratedContextID="4014"
		Sequence="ViewModifierCodeSequence"				Type="2"	VM="0-n"
			InvokeMacro="CodeSequenceMacro"							EnmeratedContextID="4015"
		SequenceEnd
	SequenceEnd
ModuleEnd

Module="IntraoralSeries"
	Name="Modality"										Type="1"	StringEnumValues="IntraoralModality"
ModuleEnd

Module="IntraoralImage"
	Name="PositionerType"								Type="1"	StringEnumValues="IntraoralPositionerType"
	Name="ImageLaterality"								Type="1"	StringEnumValues="IntraoralImageLaterality"
	Sequence="AnatomicRegionSequence"					Type="1"	VM="1"
		InvokeMacro="CodeSequenceMacro"								DefinedContextID="4016"
		Sequence="AnatomicRegionModifierSequence"		Type="1C"	VM="1"	Condition="NoPrimaryAnatomicStructureSequence"
			InvokeMacro="CodeSequenceMacro"							DefinedContextID="4017"
		SequenceEnd
	SequenceEnd
	Sequence="PrimaryAnatomicStructureSequence"			Type="1C"	VM="1-n"	Condition="NoAnatomicRegionModifierSequence"
		InvokeMacro="CodeSequenceMacro"								DefinedContextID="4018 or 4019"
	SequenceEnd
ModuleEnd

Module="ImageHistogram"
	Sequence="HistogramSequence"						Type="1"	VM="1-n"
		Name="HistogramNumberOfBins"					Type="1"
		Name="HistogramFirstBinValue"					Type="1"
		Name="HistogramLastBinValue"					Type="1"
		Name="HistogramBinWidth"						Type="1"
		Name="HistogramExplanation"						Type="3"
		Name="HistogramData"							Type="1"
	SequenceEnd
ModuleEnd

Module="IHEMammoProfile"
	Name="PatientName"						Type="1"
	Name="PatientID"						Type="1"
	Name="PatientBirthDate"					Type="1"
	Name="PatientAge"						Type="1"
	Name="AcquisitionDate"					Type="1"
	Name="AcquisitionTime"					Type="1"
	Name="OperatorName"						Type="1"
	Name="Manufacturer"						Type="1"
	Name="InstitutionName"					Type="1"
	Name="InstitutionAddress"				Type="1"
	Name="ManufacturerModelName"			Type="1"
	Name="DeviceSerialNumber"				Type="1"
	Name="DetectorID"						Type="1"
	Name="SoftwareVersion"					Type="1"
	Name="StationName"						Type="1"
	Name="GantryID"							Type="1C"	Condition="DetectorTypeIsStorage" mbpo="true"
	Name="KVP"								Type="1"	NotZeroWarning=""
	Name="Exposure"							Type="1"	NotZeroWarning=""
	Name="ExposureTime"						Type="1"	NotZeroWarning=""
	Name="FilterMaterial"					Type="1"
	Name="AnodeTargetMaterial"				Type="1"
	Name="CompressionForce"					Type="1"
	Name="BodyPartThickness"				Type="1"	NotZeroWarning=""
	Name="PositionerPrimaryAngle"			Type="1"
	Name="RelativeXRayExposure"				Type="1"	NotZeroWarning=""
	Name="EntranceDoseInmGy"				Type="1"	NotZeroWarning=""
	Name="OrganDose"						Type="1"	NotZeroWarning=""
	Name="BurnedInAnnotation"				Type="1"	StringEnumValues="NoFull"
	Name="BreastImplantPresent"				Type="1"
	Name="PixelPaddingValue"				Type="1"	# really only required if skin edge detected, but cannot check the real world intent
	Name="EstimatedRadiographicMagnificationFactor"	Type="1"
	Name="DateOfLastDetectorCalibration"	Type="1C"	Condition="DetectorTypeIsNotStorage" mbpo="true"
	Verify="PixelSpacing"								Condition="PixelSpacingIsPresent" ThenWarningMessage="Attribute present but not used in IHE Mammo Profile"
ModuleEnd

Module="IHEMammoProfileWithoutPartialViewOption"
	Verify="PartialView"								Condition="PartialViewNotPresent"	ThenWarningMessage="IHE Mammo Profile Partial View Option not supported"
ModuleEnd

Module="IHEMammoProfileWithPartialViewOption"
	Name="PartialView"						Type="1"	# really only required for partial view named option
	Sequence="PartialViewCodeSequence"		Type="1C"	VM="1-2"	Condition="PartialViewIsYes"
	SequenceEnd
ModuleEnd

Module="IHEMammoProfileForPresentationOnly"
	Sequence="SourceImageSequence"			Type="1"	VM="1"
		Name="SpatialLocationsPreserved"	Type="1"
	SequenceEnd
	Sequence="VOILUTSequence"				Type="3"	VM="1-n"
		Name="LUTExplanation"				Type="1"	# really only required if number of items > 1, but cannot check this
	SequenceEnd
	Name="WindowCenterWidthExplanation"		Type="1C"	Condition="WindowCenterPresent"	# really only required if number of values > 1, but cannot check this
	Name="VOILUTFunction"					Type="1"	# really only required if not linear, but cannot check the real world intent
ModuleEnd

Module="DentalImageOnMediaProfile"
	Name="BitsAllocated"					Type="1"	BinaryEnumValues="BitsAre8Or16"
	Verify="BitsAllocated"								Condition="BitsStoredIs8"			BinaryEnumValues="BitsAre8"
	Verify="BitsAllocated"								Condition="BitsStoredGreaterThan8"	BinaryEnumValues="BitsAre16"
	Name="BitsStored"						Type="1"	BinaryEnumValues="BitsAre8Or10Or12Or16"
	Name="InstitutionName"					Type="2"
	Name="ManufacturerModelName"			Type="2"
	Name="DetectorID"						Type="2"
	Name="DetectorManufacturerName"			Type="2"
	Name="DetectorManufacturerModelName"	Type="2"
ModuleEnd


