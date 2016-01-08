#$Source: /home/bbennett/pass/archive/Posda/tpl/module/vl.tpl,v $
#$Date: 2010/04/30 18:53:53 $
#$Revision: 1.2 $
#
Module="VLImage"
	Name="ImageType"									Type="1"	ValueSelector="0"	StringEnumValues="ImageType1"
	Verify="ImageType"									Type="1"	ValueSelector="1"	StringEnumValues="ImageType2"
	Verify="ImageType"									Type="1"	ValueSelector="2"	StringEnumValues="VLImageType3"
	Name="PhotometricInterpretation"					Type="1"	StringEnumValues="PhotometricInterpretationMonochrome2OrRGBorYBRFULL422orYBRPARTIAL420orYBRRCTorYBRICT"
	Name="BitsAllocated"								Type="1"	BinaryEnumValues="BitsAre8"
	Name="BitsStored"									Type="1"	BinaryEnumValues="BitsAre8"
	Name="HighBit"										Type="1"	BinaryEnumValues="BitsAre7"
	Name="PixelRepresentation"							Type="1"	BinaryEnumValues="PixelRepresentationUnsigned"
	Name="SamplesPerPixel"								Type="1"	BinaryEnumValues="SamplesPerPixelIsOneOrThree"
	Verify="SamplesPerPixel"										Condition="PhotometricInterpretationNeedsOneSample"	BinaryEnumValues="One"
	Verify="SamplesPerPixel"										Condition="PhotometricInterpretationNeedsThreeSamples"	BinaryEnumValues="Three"
	Name="PlanarConfiguration"							Type="1C"	BinaryEnumValues="PlanarConfigurationIsColorByPixel"	Condition="SamplesPerPixelGreaterThanOne"
	Name="ContentTime"									Type="1C"	NoCondition=""	# "if temporally related" ... real world
	Name="LossyImageCompression"						Type="2"	StringEnumValues="LossyImageCompression"
	Sequence="ReferencedImageSequence"					Type="1C"	VM="1-n"	Condition="ImageTypeValue3StereoLOrR" mbpo="true"
		InvokeMacro="ImageSOPInstanceReferenceMacro"
		Sequence="PurposeOfReferenceCodeSequence"		Type="2"	VM="0-1"
			InvokeMacro="CodeSequenceMacro"							DefinedContextID="7201"
		SequenceEnd
	SequenceEnd
	Name="WindowCenter"									Type="3C"	Condition="PhotometricInterpretationIsMonochrome2"
	Name="WindowWidth"									Type="1C"	Condition="WindowCenterPresent" 	NotZeroError=""
	Sequence="AnatomicRegionSequence"					Type="1C"	VM="1"	Condition="MultiFrameIODAndNotSpecimen" mbpo="true"
		InvokeMacro="CodeSequenceMacro"
		Sequence="AnatomicRegionModifierSequence"		Type="3"	VM="1-n"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="2"
		SequenceEnd
	SequenceEnd
	InvokeMacro="PrimaryAnatomicStructureMacro"
ModuleEnd

Module="VLEndoscopicSeriesPseudo"
	Name="Modality"										Type="1"	StringEnumValues="VLEndoscopyModality"
ModuleEnd

Module="VLMicroscopicSeriesPseudo"
	Name="Modality"										Type="1"	StringEnumValues="VLMicroscopyModality"
ModuleEnd

Module="VLSlideCoordinatesMicroscopicSeriesPseudo"
	Name="Modality"										Type="1"	StringEnumValues="VLSlideCoordinatesMicroscopyModality"
ModuleEnd

Module="VLPhotographicSeriesPseudo"
	Name="Modality"										Type="1"	StringEnumValues="VLPhotographyModality"
ModuleEnd

Module="SlideCoordinates"
	Sequence="ImageCenterPointCoordinatesSequence"		Type="2"	VM="0-1"
		Name="XOffsetInSlideCoordinateSystem"			Type="1"
		Name="YOffsetInSlideCoordinateSystem"			Type="1"
		Name="ZOffsetInSlideCoordinateSystem"			Type="2"
	SequenceEnd
	Sequence="PixelSpacingSequence"						Type="3"	VM="1-n"
		Sequence="CoordinateSystemAxisCodeSequence"		Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="95"
		SequenceEnd
		Name="NumericValue"								Type="1"
		Sequence="MeasurementUnitsCodeSequence"			Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="82"
		SequenceEnd
	SequenceEnd
ModuleEnd

Module="OphthalmicPhotographySeries"
	Name="Modality"										Type="1"	StringEnumValues="OphthalmologyModality"
ModuleEnd

Module="OphthalmicPhotography8BitImagePseudo"
	Name="BitsAllocated"								Type="1"	BinaryEnumValues="BitsAre8"
	Name="BitsStored"									Type="1"	BinaryEnumValues="BitsAre8"
	Name="HighBit"										Type="1"	BinaryEnumValues="BitsAre7"
ModuleEnd

Module="OphthalmicPhotography16BitImagePseudo"
	Name="BitsAllocated"								Type="1"	BinaryEnumValues="BitsAre16"
	Name="BitsStored"									Type="1"	BinaryEnumValues="BitsAre16"
	Name="HighBit"										Type="1"	BinaryEnumValues="BitsAre15"
ModuleEnd

Module="OphthalmicPhotographyImage"
	Name="ImageType"									Type="1"	ValueSelector="0"	StringEnumValues="ImageType1"
	Verify="ImageType"									Type="1"	ValueSelector="1"	StringEnumValues="OphthalmologyImageType2"
	
	Verify="ImageType"									Type="1"	Condition="ImageTypeValue1Derived" ValueSelector="2"	StringDefinedTerms="OphthalmologyImageType3IfDerived"
	Verify="ImageType"												Condition="ImageTypeValue1DerivedAndImageTypeValue3MissingOrEmpty"	ThenErrorMessage="A value for Value 3 is required for DERIVED images"
	Verify="ImageType"												Condition="ImageTypeValue1NotDerivedAndImageTypeValueNotMissingOrEmpty"	ThenErrorMessage="A value for Value 3 may not be present for non-DERIVED images"
	
	Verify="ImageType"									Type="1"	ValueSelector="3"	StringDefinedTerms="OphthalmologyImageType4"

	Name="InstanceNumber"								Type="1"
	Name="SamplesPerPixel"								Type="1"	BinaryEnumValues="SamplesPerPixelIsOneOrThree"
	Verify="SamplesPerPixel"										Condition="PhotometricInterpretationNeedsOneSample"	BinaryEnumValues="One"
	Verify="SamplesPerPixel"										Condition="PhotometricInterpretationNeedsThreeSamples"	BinaryEnumValues="Three"
	Name="SamplesPerPixelUsed"							Type="1C"	NoCondition="" BinaryEnumValues="SamplesPerPixelUsedIsTwo"		# condition is real world
	Name="PhotometricInterpretation"					Type="1"	StringEnumValues="PhotometricInterpretationMonochrome2OrRGBorYBRFULL422orYBRPARTIAL420orYBRRCTorYBRICT"
	Name="PixelRepresentation"							Type="1"	BinaryEnumValues="PixelRepresentationUnsigned"
	Name="PlanarConfiguration"							Type="1C"	BinaryEnumValues="PlanarConfigurationIsColorByPixel"	Condition="SamplesPerPixelGreaterThanOne"
	Name="PixelSpacing"									Type="1C"	NoCondition=""		# too hard to check code in Acquisition Device Type Code Sequence :(
	Name="ContentDate"									Type="1"
	Name="ContentTime"									Type="1"
	Name="AcquisitionDateTime"							Type="1C"	Condition="ImageTypeValue1Original" mbpo="true"
	Sequence="SourceImageSequence"						Type="2C"	VM="0-n"	Condition="ImageTypeValue1Derived"
		InvokeMacro="ImageSOPInstanceReferenceMacro"
		Sequence="PurposeOfReferenceCodeSequence"		Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"							DefinedContextID="7202"
		SequenceEnd
	SequenceEnd
	Name="LossyImageCompression"						Type="1"	StringEnumValues="LossyImageCompression"
	Name="LossyImageCompressionRatio"					Type="1C"	Condition="LossyImageCompressionIs01"
	Name="LossyImageCompressionMethod"					Type="1C"	StringDefinedTerms="LossyImageCompressionMethod"	Condition="LossyImageCompressionIs01"
	Verify="LossyImageCompressionMethod"							Condition="LossyImageCompressionMethodInconsistentWithTransferSyntax"	ThenWarningMessage="method inconsistent with transfer syntax" ShowValueWithMessage="true"
	Name="PresentationLUTShape"							Type="1C"	Condition="PhotometricInterpretationIsMonochrome2"	StringEnumValues="IdentityPresentationLUTShape"
	Name="CalibrationImage"								Type="3"	StringEnumValues="YesNoFull"
	Name="BurnedInAnnotation"							Type="1"	StringEnumValues="YesNoFull"
ModuleEnd

Module="OphthalmicPhotographicParameters"
	Sequence="AcquisitionDeviceTypeCodeSequence"		Type="1"	VM="1"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="4202"
	SequenceEnd
	Sequence="IlluminationTypeCodeSequence"				Type="2"	VM="0-1"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="4203"
	SequenceEnd
	Sequence="LightPathFilterTypeStackCodeSequence"		Type="2"	VM="0-n"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="4204"
	SequenceEnd
	Name="LightPathFilterPassThroughWavelength"			Type="3"
	Name="LightPathFilterPassBand"						Type="3"
	Sequence="ImagePathFilterTypeStackCodeSequence"		Type="2"	VM="0-n"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="4204"
	SequenceEnd
	Name="ImagePathFilterPassThroughWavelength"			Type="3"
	Name="ImagePathFilterPassBand"						Type="3"
	Sequence="LensesCodeSequence"						Type="2"	VM="0-n"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="4205"
	SequenceEnd
	Name="DetectorType"									Type="2"	StringDefinedTerms="OphthalmologyDetectorType"
	Sequence="ChannelDescriptionCodeSequence"			Type="1C"	VM="1-3"	NoCondition=""
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="4206"
	SequenceEnd
ModuleEnd

DefineMacro="OphthalmicAcquisitionParametersMacro" InformationEntity="Image"
	Sequence="RefractiveStateSequence"					Type="2"	VM="0-1"
		Name="SphericalLensPower"						Type="1"	NotZeroWarning=""
		Name="CylinderLensPower"						Type="1"	NotZeroWarning=""
		Name="CylinderAxis"								Type="1"	NotZeroWarning=""
	SequenceEnd
	Name="EmmetropicMagnification"						Type="2"	NotZeroWarning=""
	Name="IntraOcularPressure"							Type="2"	NotZeroWarning=""
	Name="HorizontalFieldOfView"						Type="2"	NotZeroWarning=""
	Name="PupilDilated"									Type="2"	StringEnumValues="YesNoFull"
	Sequence="MydriaticAgentSequence"					Type="2C"	VM="0-n"	Condition="PupilDilatedIsYes"
		Sequence="MydriaticAgentCodeSequence"			Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="4208"
		SequenceEnd
		Name="MydriaticAgentConcentration"				Type="3"	NotZeroWarning=""
		Sequence="MydriaticAgentConcentrationUnitsSequence"	Type="1C"	VM="1" Condition="MydriaticAgentConcentrationIsPresent"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="3082"
		SequenceEnd
	SequenceEnd
	Name="DegreeOfDilation"								Type="2C"	Condition="PupilDilatedIsYes"
MacroEnd

Module="OphthalmicPhotographyAcquisitionParameters"
	Name="PatientEyeMovementCommanded"					Type="2"	StringEnumValues="YesNoFull"
	Sequence="PatientEyeMovementCommandedCodeSequence"	Type="1C"	VM="1"	Condition="PatientEyeMovementCommandedIsYes"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="4201"
	SequenceEnd
	InvokeMacro="OphthalmicAcquisitionParametersMacro"
ModuleEnd

Module="OcularRegionImaged"
	Name="ImageLaterality"								Type="1"	StringEnumValues="OphthalmologyImageLaterality"
	Sequence="RelativeImagePositionCodeSequence"		Type="3"	VM="1"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="4207"
	SequenceEnd
	InvokeMacro="GeneralAnatomyMandatoryMacro"
ModuleEnd

Module="StereometricSeries"
	Name="Modality"										Type="1"	StringEnumValues="StereometricModality"
ModuleEnd

Module="StereometricRelationship"
	Sequence="StereoPairsSequence"						Type="1"	VM="1-n"
		Name="StereoBaselineAngle"						Type="3"
		Name="StereoBaselineDisplacement"				Type="3"
		Name="StereoHorizontalPixelOffset"				Type="3"
		Name="StereoVerticalPixelOffset"				Type="3"
		Name="StereoRotation"							Type="3"
		Sequence="LeftImageSequence"					Type="1"	VM="1"
			InvokeMacro="ImageSOPInstanceReferenceMacro"
		SequenceEnd
		Sequence="RightImageSequence"					Type="1"	VM="1"
			InvokeMacro="ImageSOPInstanceReferenceMacro"
		SequenceEnd
	SequenceEnd
ModuleEnd

Module="OphthalmicTomographySeries"
	Name="Modality"										Type="1"	StringEnumValues="OphthalmicTomographyModality"
	Name="SeriesNumber"									Type="1"
	Sequence="ReferencedPerformedProcedureStepSequence"	Type="1C"	VM="0-1"	Condition="SeriesNeedReferencedPerformedProcedureStepSequence"
		InvokeMacro="SOPInstanceReferenceMacro"
	SequenceEnd
ModuleEnd

Module="OphthalmicTomographyImage"
	Name="ImageType"									Type="1"	ValueSelector="0"	StringEnumValues="ImageType1"
	Verify="ImageType"									Type="1"	ValueSelector="1"	StringEnumValues="ImageType2"
	Name="SamplesPerPixel"								Type="1"	BinaryEnumValues="SamplesPerPixelIsOne"
	Name="AcquisitionDateTime"							Type="1"
	Name="AcquisitionDuration"							Type="1C"	Condition="ImageTypeValue1Original" mbpo="true"
	Name="AcquisitionNumber"							Type="1"
	Name="PhotometricInterpretation"					Type="1"	StringEnumValues="PhotometricInterpretationMonochrome2"
	Name="PixelRepresentation"							Type="1"	BinaryEnumValues="PixelRepresentationUnsigned"
	Name="BitsAllocated"								Type="1"	BinaryEnumValues="BitsAre8Or16"
	Name="BitsStored"									Type="1"	BinaryEnumValues="BitsAre8Or12Or16"
	Name="HighBit"										Type="1"	BinaryEnumValues="BitsAre7Or11Or15"
	Name="PresentationLUTShape"							Type="1"	StringEnumValues="IdentityPresentationLUTShape"
	Name="LossyImageCompression"						Type="1"	StringEnumValues="LossyImageCompression"
	Name="LossyImageCompressionRatio"					Type="1C"	Condition="LossyImageCompressionIs01"
	Name="LossyImageCompressionMethod"					Type="1C"	StringDefinedTerms="LossyImageCompressionMethod"	Condition="LossyImageCompressionIs01"
	Verify="LossyImageCompressionMethod"							Condition="LossyImageCompressionMethodInconsistentWithTransferSyntax"	ThenWarningMessage="method inconsistent with transfer syntax" ShowValueWithMessage="true"
	Name="BurnedInAnnotation"							Type="1"	StringEnumValues="NoFull"
	Name="ConcatenationFrameOffsetNumber"				Type="1"	BinaryEnumValues="Zero"
	Name="InConcatenationNumber"						Type="1"	BinaryEnumValues="One"
	Name="InConcatenationTotalNumber"					Type="1"	BinaryEnumValues="One"
	Name="ImageComments"								Type="3"
ModuleEnd

Module="OphthalmicTomographyAcquisitionParameters"
	Name="AxialLengthOfEye"								Type="2"
	Name="HorizontalFieldOfView"						Type="2"
	InvokeMacro="OphthalmicAcquisitionParametersMacro"
ModuleEnd

Module="OphthalmicTomographyParameters"
	Sequence="AcquisitionDeviceTypeCodeSequence"		Type="1"	VM="1"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="4210"
	SequenceEnd
	Sequence="LightPathFilterTypeStackCodeSequence"		Type="2"	VM="0-n"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="4204"
	SequenceEnd
	Name="LightPathFilterPassThroughWavelength"			Type="3"
	Name="LightPathFilterPassBand"						Type="3"
	Name="DetectorType"									Type="1"	StringDefinedTerms="OphthalmicTomographyDetectorType"
	Name="IlluminationWaveLength"						Type="1C"	Condition="AcquisitionDeviceTypeCodeSequenceIsOpticalCoherenceTomographyScanner" mbpo="true"
	Name="IlluminationPower"							Type="1C"	Condition="AcquisitionDeviceTypeCodeSequenceIsOpticalCoherenceTomographyScanner" mbpo="true"
	Name="IlluminationBandwidth"						Type="1C"	Condition="AcquisitionDeviceTypeCodeSequenceIsOpticalCoherenceTomographyScanner" mbpo="true"
	Name="DepthSpatialResolution"						Type="1C"	Condition="AcquisitionDeviceTypeCodeSequenceIsOpticalCoherenceTomographyScanner" mbpo="true"
	Name="MaximumDepthDistortion"						Type="1C"	Condition="AcquisitionDeviceTypeCodeSequenceIsOpticalCoherenceTomographyScanner" mbpo="true"
	Name="AlongScanSpatialResolution"					Type="1C"	Condition="AcquisitionDeviceTypeCodeSequenceIsOpticalCoherenceTomographyScanner" mbpo="true"
	Name="MaximumAlongScanDistortion"					Type="1C"	Condition="AcquisitionDeviceTypeCodeSequenceIsOpticalCoherenceTomographyScanner" mbpo="true"
	Name="AcrossScanSpatialResolution"					Type="1C"	Condition="AcquisitionDeviceTypeCodeSequenceIsOpticalCoherenceTomographyScanner" mbpo="true"
	Name="MaximumAcrossScanDistortion"					Type="1C"	Condition="AcquisitionDeviceTypeCodeSequenceIsOpticalCoherenceTomographyScanner" mbpo="true"
ModuleEnd

DefineMacro="OphthalmicFrameLocationMacro" InformationEntity="Frame"
	Sequence="OphthalmicFrameLocationSequence"			Type="1"	VM="1-n"
		InvokeMacro="ImageSOPInstanceReferenceMacro"
		Name="ReferenceCoordinates"						Type="1"
		Name="DepthOfTransverseImage"					Type="2C"	Condition="OphthalmicImageOrientationIsTransverse"
		Name="OphthalmicImageOrientation"				Type="1"	StringEnumValues="OphthalmicImageOrientation"
	SequenceEnd
MacroEnd

Module="MultiFrameFunctionalGroupsForOphthalmicTomography"
	Sequence="SharedFunctionalGroupsSequence"	Type="2"	VM="0-1"
		InvokeMacro="PixelMeasuresMacro"			Condition="PixelMeasuresSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PlanePositionMacro"			Condition="PlanePositionSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PlaneOrientationMacro"			Condition="PlaneOrientationSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="ReferencedImageMacro"			Condition="ReferencedImageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="DerivationImageMacro"			Condition="DerivationImageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="FrameAnatomyMacro"				Condition="FrameAnatomySequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="CardiacSynchronizationMacro"	Condition="NeedCardiacSynchronizationMacroInSharedFunctionalGroupSequence"
		InvokeMacro="ContrastBolusUsageMacro"		Condition="NeedContrastBolusUsageMacroInSharedFunctionalGroupSequence"
		InvokeMacro="OphthalmicFrameLocationMacro"	Condition="NeedOphthalmicFrameLocationMacroInSharedFunctionalGroupSequence"
	SequenceEnd

	Sequence="PerFrameFunctionalGroupsSequence"	Type="1"	VM="1-n"
		InvokeMacro="PixelMeasuresMacro"			Condition="PixelMeasuresSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="FrameContentMacro"
		InvokeMacro="PlanePositionMacro"			Condition="PlanePositionSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="PlaneOrientationMacro"			Condition="PlaneOrientationSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="ReferencedImageMacro"			Condition="ReferencedImageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="DerivationImageMacro"			Condition="DerivationImageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameAnatomyMacro"				Condition="FrameAnatomySequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="CardiacSynchronizationMacro"	Condition="NeedCardiacSynchronizationMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="ContrastBolusUsageMacro"		Condition="NeedContrastBolusUsageMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="OphthalmicFrameLocationMacro"	Condition="NeedOphthalmicFrameLocationMacroInPerFrameFunctionalGroupSequence"
	SequenceEnd
ModuleEnd




