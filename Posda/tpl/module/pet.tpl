#
Module="PETSeries"
	Name="SeriesDate"									Type="1"
	Name="SeriesTime"									Type="1"
	Name="Units"										Type="1"	StringDefinedTerms="PETUnits"
	Name="CountsSource"									Type="1"	StringEnumValues="CountsSource"
	Name="SeriesType"									Type="1"	ValueSelector="0"	StringEnumValues="PETSeriesType1"
	Verify="SeriesType"									Type="1"	ValueSelector="1"	StringEnumValues="PETSeriesType2"
	Name="ReprojectionMethod"							Type="2C"	Condition="PETSeriesType2Reprojection"	StringDefinedTerms="ReprojectionMethod"
	Name="NumberOfRRIntervals"							Type="1C"	Condition="PETSeriesType1Gated"
	Name="NumberOfTimeSlots"							Type="1C"	Condition="PETSeriesType1Gated"
	Name="NumberOfTimeSlices"							Type="1C"	Condition="PETSeriesType1Dynamic"
	Name="NumberOfSlices"								Type="1"
	Name="CorrectedImage"								Type="2"	StringDefinedTerms="CorrectedImage"
	Name="RandomsCorrectionMethod"						Type="3"	StringDefinedTerms="RandomsCorrectionMethod"
	Name="AttenuationCorrectionMethod"					Type="3"
	Name="ScatterCorrectionMethod"						Type="3"
	Name="DecayCorrection"								Type="1"	StringDefinedTerms="DecayCorrection"
	Name="ReconstructionDiameter"						Type="3"	NotZeroWarning=""
	Name="ConvolutionKernel"							Type="3"
	Name="ReconstructionMethod"							Type="3"
	Name="DetectorLinesOfResponseUsed"					Type="3"
	Name="AcquisitionStartCondition"					Type="3"	StringDefinedTerms="AcquisitionStartCondition"
	Name="AcquisitionStartConditionData"				Type="3"
	Name="AcquisitionTerminationCondition"				Type="3"	StringDefinedTerms="PETAcquisitionTerminationCondition"
	Name="AcquisitionTerminationConditionData"			Type="3"
	Name="FieldOfViewShape"								Type="3"	StringDefinedTerms="PETFieldOfViewShape"
	Name="FieldOfViewDimensions"						Type="3"	NotZeroWarning=""
	Name="GantryDetectorTilt"							Type="3"
	Name="GantryDetectorSlew"							Type="3"
	Name="TypeOfDetectorMotion"							Type="3"	StringDefinedTerms="TypeOfDetectorMotion"
	Name="CollimatorType"								Type="2"	StringDefinedTerms="PETCollimatorType"
	Name="CollimatorGridName"							Type="3"
	Name="AxialAcceptance"								Type="3"
	Name="AxialMash"									Type="3"
	Name="TransverseMash"								Type="3"
	Name="DetectorElementSize"							Type="3"	NotZeroError=""
	Name="CoincidenceWindowWidth"						Type="3"
	Sequence="EnergyWindowRangeSequence"				Type="3"	VM="0-n"
		Name="EnergyWindowLowerLimit"					Type="3"
		Name="EnergyWindowUpperLimit"					Type="3"
	SequenceEnd
	Name="SecondaryCountsType"							Type="3"	StringDefinedTerms="SecondaryCountsType"
ModuleEnd

Module="PETIsotope"
	Sequence="RadiopharmaceuticalInformationSequence"	Type="2"	VM="0-n"
		Sequence="RadionuclideCodeSequence"				Type="2"	VM="0-1"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="4020"
		SequenceEnd
		Name="RadiopharmaceuticalRoute"					Type="3"
		Sequence="AdministrationRouteCodeSequence"		Type="3"	VM="1"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="11"
		SequenceEnd
		Name="RadiopharmaceuticalVolume"				Type="3"
		Name="RadiopharmaceuticalStartTime"				Type="3"
		Name="RadiopharmaceuticalStartDateTime"			Type="3"
		Name="RadiopharmaceuticalStopTime"				Type="3"
		Name="RadiopharmaceuticalStopDateTime"			Type="3"
		Name="RadionuclideTotalDose"					Type="3"
		Name="RadionuclideHalfLife"						Type="3"
		Name="RadionuclidePositronFraction"				Type="3"
		Name="RadiopharmaceuticalSpecificActivity"		Type="3"
		Name="Radiopharmaceutical"						Type="3"
		Sequence="RadiopharmaceuticalCodeSequence"		Type="3"	VM="1"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="4021"
		SequenceEnd
	SequenceEnd
	Sequence="InterventionDrugInformationSequence"		Type="3"	VM="1-n"
		Name="InterventionDrugName"						Type="3"
		Sequence="InterventionDrugCodeSequence"			Type="3"	VM="1"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="10"
		SequenceEnd
		Name="InterventionDrugStartTime"				Type="3"
		Name="InterventionDrugStopTime"					Type="3"
		Name="InterventionDrugDose"						Type="3"
	SequenceEnd
ModuleEnd

Module="PETMultigatedAcquisition"
	Name="BeatRejectionFlag"							Type="2"	StringEnumValues="YesNoLetter"
	Name="TriggerSourceOrType"							Type="3"	StringDefinedTerms="EKG"
	Name="PVCRejection"									Type="3"
	Name="SkipBeats"									Type="3"
	Name="HeartRate"									Type="3"
	Name="CardiacFramingType"							Type="3"	StringDefinedTerms="CardiacFramingType"
ModuleEnd

Module="PETImage"
	Name="ImageType"									Type="1"	ValueSelector="0"	StringEnumValues="ImageType1"
	Verify="ImageType"									Type="1"	ValueSelector="1"	StringEnumValues="PETImageTypeValue2"
	Name="SamplesPerPixel"								Type="1"	BinaryEnumValues="SamplesPerPixelIsOne"
	Name="PhotometricInterpretation"					Type="1"	StringEnumValues="PhotometricInterpretationMonochrome2"
	Name="BitsAllocated"								Type="1"	BinaryEnumValues="BitsAre16"
	Name="BitsStored"									Type="1"	BinaryEnumValues="BitsAre16"
	Name="HighBit"										Type="1"	BinaryEnumValues="BitsAre15"
	Name="RescaleIntercept"								Type="1"	BinaryEnumValues="Zero"
	Name="RescaleSlope"									Type="1"	NotZeroError=""
	Name="FrameReferenceTime"							Type="1"
	Name="TriggerTime"									Type="1C"	Condition="PETSeriesType1Gated"
	Name="FrameTime"									Type="1C"	Condition="PETSeriesType1Gated"
	Name="LowRRValue"									Type="1C"	Condition="PETSeriesType1GatedAndBeatRejection"
	Name="HighRRValue"									Type="1C"	Condition="PETSeriesType1GatedAndBeatRejection"
	Name="LossyImageCompression"						Type="1C"	NoCondition=""	StringEnumValues="LossyImageCompression"
	Name="ImageIndex"									Type="1"
	Name="AcquisitionDate"								Type="2"
	Name="AcquisitionTime"								Type="2"
	Name="ActualFrameDuration"							Type="2"
	Name="NominalInterval"								Type="3"
	Name="IntervalsAcquired"							Type="3"
	Name="IntervalsRejected"							Type="3"
	Name="PrimaryPromptsCountsAccumulated"				Type="3"
	Name="SecondaryCountsAccumulated"					Type="3"
	Name="SliceSensitivityFactor"						Type="3"
	Name="DecayFactor"									Type="1C"	Condition="DecayCorrectionNotNone"
	Name="DoseCalibrationFactor"						Type="3"
	Name="ScatterFractionFactor"						Type="3"
	Name="DeadTimeFactor"								Type="3"
	InvokeMacro="GeneralAnatomyOptionalMacro"
	Name="SliceProgressionDirection"					Type="3"	StringEnumValues="SliceProgressionDirection"
	Sequence="ViewCodeSequence"							Type="3"	VM="1"
		InvokeMacro="CodeSequenceMacro"								BaselineContextID="26"
		Sequence="ViewModifierCodeSequence"				Type="2C"	VM="1"	NoCondition=""
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="23"
		SequenceEnd
	SequenceEnd
ModuleEnd

Module="MultiFrameFunctionalGroupsForEnhancedPETImage"
	Sequence="SharedFunctionalGroupsSequence"	Type="2"	VM="0-1"
		InvokeMacro="PixelMeasuresMacro"		Condition="PixelMeasuresSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PlanePositionMacro"		Condition="PlanePositionSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PlaneOrientationMacro"		Condition="PlaneOrientationSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="ReferencedImageMacro"		Condition="ReferencedImageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="DerivationImageMacro"		Condition="DerivationImageMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="FrameAnatomyMacro"			Condition="FrameAnatomySequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PixelValueTransformationMacro"	Condition="PixelValueTransformationSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameVOILUTMacro"			Condition="FrameVOILUTMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="RealWorldValueMappingMacro"	Condition="RealWorldValueMappingMacroOKInSharedFunctionalGroupSequence"
		InvokeMacro="CardiacSynchronizationMacro"		Condition="NeedCardiacSynchronizationMacroInSharedFunctionalGroupSequence"
		InvokeMacro="RespiratorySynchronizationMacro"		Condition="NeedRespiratorySynchronizationMacroInSharedFunctionalGroupSequence"
		InvokeMacro="RadiopharmaceuticalUsageMacro"		Condition="RadiopharmaceuticalUsageSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PatientPhysiologicalStateMacro"	Condition="NeedPatientPhysiologicalStateMacroInSharedFunctionalGroupSequence"
		InvokeMacro="PETFrameTypeMacro"		Condition="PETFrameTypeSequenceNotInPerFrameFunctionalGroupSequence"
		InvokeMacro="PETFrameAcquisitionMacro"	Condition="NeedPETFrameAcquisitionMacroInSharedFunctionalGroupSequence"
		InvokeMacro="PETDetectorMotionDetailsMacro"	Condition="NeedPETDetectorMotionDetailsMacroInSharedFunctionalGroupSequence"
		InvokeMacro="PETPositionMacro"	Condition="NeedPETPositionMacroInSharedFunctionalGroupSequence"
		InvokeMacro="PETFrameCorrectionFactorsMacro"	Condition="NeedPETFrameCorrectionFactorsMacroInSharedFunctionalGroupSequence"
		InvokeMacro="PETReconstructionMacro"	Condition="NeedPETReconstructionMacroInSharedFunctionalGroupSequence"
		InvokeMacro="PETTableDynamicsMacro"	Condition="NeedPETTableDynamicsMacroInSharedFunctionalGroupSequence"
	SequenceEnd
	Sequence="PerFrameFunctionalGroupsSequence"	Type="1"	VM="1-n"
		InvokeMacro="PixelMeasuresMacro"		Condition="PixelMeasuresSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="FrameContentMacro"
		InvokeMacro="PlanePositionMacro"		Condition="PlanePositionSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="PlaneOrientationMacro"		Condition="PlaneOrientationSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="ReferencedImageMacro"		Condition="ReferencedImageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="DerivationImageMacro"		Condition="DerivationImageMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="FrameAnatomyMacro"			Condition="FrameAnatomySequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="PixelValueTransformationMacro"	Condition="PixelValueTransformationSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="FrameVOILUTMacro"			Condition="FrameVOILUTMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="RealWorldValueMappingMacro"	Condition="RealWorldValueMappingMacroOKInPerFrameFunctionalGroupSequence"
		InvokeMacro="CardiacSynchronizationMacro"		Condition="NeedCardiacSynchronizationMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="RespiratorySynchronizationMacro"		Condition="NeedRespiratorySynchronizationMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="RadiopharmaceuticalUsageMacro"		Condition="RadiopharmaceuticalUsageSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="PatientPhysiologicalStateMacro"	Condition="NeedPatientPhysiologicalStateMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="PETFrameTypeMacro"		Condition="PETFrameTypeSequenceNotInSharedFunctionalGroupSequence"
		InvokeMacro="PETFrameAcquisitionMacro"	Condition="NeedPETFrameAcquisitionMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="PETDetectorMotionDetailsMacro"	Condition="NeedPETDetectorMotionDetailsMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="PETPositionMacro"	Condition="NeedPETPositionMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="PETFrameCorrectionFactorsMacro"	Condition="NeedPETFrameCorrectionFactorsMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="PETReconstructionMacro"	Condition="NeedPETReconstructionMacroInPerFrameFunctionalGroupSequence"
		InvokeMacro="PETTableDynamicsMacro"	Condition="NeedPETTableDynamicsMacroInPerFrameFunctionalGroupSequence"
	SequenceEnd
ModuleEnd

DefineMacro="PETFrameTypeMacro" InformationEntity="FunctionalGroup"
	Sequence="PETFrameTypeSequence"	Type="1"	VM="1"
		Name="FrameType"						Type="1"	VM="4"
		Verify="FrameType"									ValueSelector="0"	StringEnumValues="CommonEnhancedFrameType1"
		Verify="FrameType"									ValueSelector="1"	StringEnumValues="CommonEnhancedImageAndFrameType2"
		Verify="FrameType"									ValueSelector="2"	StringDefinedTerms="CommonEnhancedImageAndFrameType3"
		Verify="FrameType"									ValueSelector="3"	StringDefinedTerms="CommonEnhancedFrameType4"
		InvokeMacro="CommonCTMRImageDescriptionFrameLevelMacro"
	SequenceEnd
MacroEnd

DefineMacro="PETFrameAcquisitionMacro" InformationEntity="FunctionalGroup"
	Sequence="PETFrameAcquisitionSequence"		Type="1"	VM="1"
		Name="TableHeight"						Type="1"	NotZeroWarning=""
		Name="GantryDetectorTilt"				Type="1"
		Name="GantryDetectorSlew"				Type="1"
		Name="DataCollectionDiameter"			Type="1"	NotZeroWarning=""
	SequenceEnd
MacroEnd

DefineMacro="PETDetectorMotionDetailsMacro" InformationEntity="FunctionalGroup"
	Sequence="PETDetectorMotionDetailsSequence"	Type="1"	VM="1"
		Name="RotationDirection"				Type="1"	StringEnumValues="RotationDirection"
		Name="RevolutionTime"					Type="1"	NotZeroWarning=""
	SequenceEnd
MacroEnd

DefineMacro="PETPositionMacro" InformationEntity="FunctionalGroup"
	Sequence="PETPositionSequence"					Type="1"	VM="1"
		Name="TablePosition"						Type="1C"	Condition="Always"	# ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
		Name="DataCollectionCenterPatient"			Type="1C"	Condition="Always"	# ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
		Name="ReconstructionTargetCenterPatient"	Type="1C"	Condition="Always"	# ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
	SequenceEnd
MacroEnd

DefineMacro="PETFrameCorrectionFactorsMacro" InformationEntity="FunctionalGroup"
	Sequence="PETFrameCorrectionFactorsSequence"	Type="1"	VM="1"
		Name="PrimaryPromptsCountsAccumulated"		Type="1C"	Condition="Always"				NotZeroWarning=""	# ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
		Name="SliceSensitivityFactor"				Type="1C"	Condition="Always"				NotZeroWarning=""	# ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
		Name="DecayFactor"							Type="1C"	Condition="IsDecayCorrected"	NotZeroWarning=""	# ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
		Name="ScatterFractionFactor"				Type="1C"	Condition="Always"									# ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
		Name="DeadTimeFactor"						Type="1C"	Condition="Always"				NotZeroWarning=""	# ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
	SequenceEnd
MacroEnd

DefineMacro="PETReconstructionMacro" InformationEntity="FunctionalGroup"
	Sequence="PETReconstructionSequence"			Type="1"	VM="1"
		Name="ReconstructionType"					Type="1C"	Condition="Always"	StringDefinedTerms="PETReconstructionType"		# ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
		Name="ReconstructionAlgorithm"				Type="1C"	Condition="Always"	StringDefinedTerms="PETReconstructionAlgorithm"	# ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
		Name="IterativeReconstructionMethod"		Type="1"						StringEnumValues="YesNoFull"
		Name="NumberOfIterations"					Type="1C"	Condition="IsIterativeReconstruction"		NotZeroWarning=""		# && ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
		Name="NumberOfSubsets"						Type="1C"	Condition="IsIterativeReconstruction"		NotZeroWarning=""		# && ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
		Name="ReconstructionDiameter"				Type="1C"	Condition="ReconstructionFieldOfViewAbsent"	NotZeroWarning=""		# ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
		Name="ReconstructionFieldOfView"			Type="1C"	Condition="ReconstructionDiameterAbsent"	NotZeroWarning=""		# ../PETFrameTypeMacro/FrameType[0] == ORIGINAL
	SequenceEnd
MacroEnd

DefineMacro="PETTableDynamicsMacro" InformationEntity="FunctionalGroup"
	Sequence="PETTableDynamicsSequence"				Type="1"	VM="1"
		Name="TableSpeed"							Type="1"	NotZeroWarning=""
	SequenceEnd
MacroEnd

Module="EnhancedPETSeries"
	Name="Modality"										Type="1"	StringEnumValues="PETModality"
	Sequence="ReferencedPerformedProcedureStepSequence"	Type="1C"	VM="1"	Condition="SeriesNeedReferencedPerformedProcedureStepSequence"
		InvokeMacro="SOPInstanceReferenceMacro"
	SequenceEnd
	Sequence="RelatedSeriesSequence"					Type="1C"	VM="1-n"	NoCondition=""
		Name="StudyInstanceUID"							Type="1"
		Name="SeriesInstanceUID"						Type="1"
		Sequence="PurposeOfReferenceCodeSequence"		Type="2"	VM="0-n"
			InvokeMacro="CodeSequenceMacro"				BaselineContextID="7210"
		SequenceEnd
	SequenceEnd
ModuleEnd

Module="EnhancedPETIsotope"
	Sequence="RadiopharmaceuticalInformationSequence"	Type="1"	VM="1-n"
		Name="RadiopharmaceuticalAgentNumber"			Type="1"
		Sequence="RadionuclideCodeSequence"				Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="4020"
		SequenceEnd
		Sequence="AdministrationRouteCodeSequence"		Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="11"
		SequenceEnd
		Name="RadiopharmaceuticalVolume"				Type="3"	NotZeroWarning=""
		Name="RadiopharmaceuticalStartDateTime"			Type="1"
		Name="RadiopharmaceuticalStopDateTime"			Type="3"
		Name="RadionuclideTotalDose"					Type="2"	NotZeroWarning=""
		Name="RadionuclideHalfLife"						Type="1"	NotZeroWarning=""
		Name="RadionuclidePositronFraction"				Type="1"	NotZeroWarning=""
		Name="RadiopharmaceuticalSpecificActivity"		Type="3"	NotZeroWarning=""
		Sequence="RadiopharmaceuticalCodeSequence"		Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="4021"
		SequenceEnd
	SequenceEnd
ModuleEnd

Module="EnhancedPETAcquisition"
	Name="AcquisitionStartCondition"					Type="1C"	Condition="ImageTypeValue1Original" mbpo="true" StringDefinedTerms="EnhancedPETAcquisitionStartCondition"
	Name="StartDensityThreshold"						Type="1C"	Condition="AcquisitionStartConditionDENS"
	Name="StartRelativeDensityDifferenceThreshold"		Type="1C"	Condition="AcquisitionStartConditionRDD"
	Name="StartCardiacTriggerCountThreshold"			Type="1C"	Condition="AcquisitionStartConditionCARD_TRIG"
	Name="StartRespiratoryTriggerCountThreshold"		Type="1C"	Condition="AcquisitionStartConditionRESP_TRIG"
	Name="AcquisitionTerminationCondition"				Type="1C"	Condition="ImageTypeValue1Original" mbpo="true" StringDefinedTerms="EnhancedPETAcquisitionTerminationCondition"
	Name="TerminationCountsThreshold"					Type="1C"	Condition="AcquisitionTerminationConditionCNTS"
	Name="TerminationDensityThreshold"					Type="1C"	Condition="AcquisitionTerminationConditionDENS"
	Name="TerminationRelativeDensityThreshold"			Type="1C"	Condition="AcquisitionTerminationConditionRDD"
	Name="TerminationTimeThreshold"						Type="1C"	Condition="AcquisitionTerminationConditionTIME"
	Name="TerminationCardiacTriggerCountThreshold"		Type="1C"	Condition="AcquisitionTerminationConditionCARD_TRIG"
	Name="TerminationRespiratoryTriggerCountThreshold"	Type="1C"	Condition="AcquisitionTerminationConditionRESP_TRIG"
	Name="TypeOfDetectorMotion"							Type="1C"	Condition="ImageTypeValue1Original" mbpo="true" StringDefinedTerms="EnhancedPETTypeOfDetectorMotion"
	Name="DetectorGeometry"								Type="1C"	Condition="OriginalAndTypeOfDetectorMotionIsStationary" mbpo="true" StringDefinedTerms="DetectorGeometry"
	Verify="DetectorGeometry"										Condition="DetectorGeometryPresentAndTypeOfDetectorMotionIsNotStationary"	ThenErrorMessage="may only be present when TypeOfDetectorMotion is STATIONARY " ShowValueWithMessage="false"
	Name="TransverseDetectorSeparation"					Type="1C"	Condition="ImageTypeValue1Original" mbpo="true"
	Name="AxialDetectorDimension"						Type="1C"	Condition="ImageTypeValue1Original" mbpo="true"
	Name="CollimatorType"								Type="1C"	Condition="ImageTypeValue1Original" mbpo="true" StringDefinedTerms="PETCollimatorType"
	Name="CoincidenceWindowWidth"						Type="1C"	Condition="ImageTypeValue1Original" mbpo="true"
	Sequence="EnergyWindowRangeSequence"				Type="1C"	VM="1-n"	Condition="ImageTypeValue1Original" mbpo="true"
		Name="EnergyWindowLowerLimit"					Type="1"
		Name="EnergyWindowUpperLimit"					Type="1"
	SequenceEnd
	Name="TableMotion"									Type="1"	StringEnumValues="TableMotion"
	Name="TimeOfFlightInformationUsed"					Type="1"	StringEnumValues="TrueFalseFull"
	Sequence="ViewCodeSequence"							Type="1"	VM="1"
		InvokeMacro="CodeSequenceMacro"					BaselineContextID="26"
		Sequence="ViewModifierCodeSequence"				Type="2C"	VM="0-1"	NoCondition=""
			InvokeMacro="CodeSequenceMacro"				BaselineContextID="23"
		SequenceEnd
	SequenceEnd
	Name="SliceProgressionDirection"					Type="1C"	NoCondition="" mbpo="true"StringEnumValues="PETSliceProgressionDirection" # ViewCodeSequenceIsShortAxis is too hard :(
ModuleEnd

Module="EnhancedPETImage"
	Name="ImageType"									Type="1"	VM="4"
	Verify="ImageType"											ValueSelector="0"	StringEnumValues="CommonEnhancedImageType1"
	Verify="ImageType"											ValueSelector="1"	StringEnumValues="CommonEnhancedImageAndFrameType2"
	Verify="ImageType"											ValueSelector="2"	StringDefinedTerms="CommonEnhancedImageAndFrameType3"
	Verify="ImageType"											ValueSelector="3"	StringDefinedTerms="CommonEnhancedImageType4"
	InvokeMacro="CommonCTMRImageDescriptionImageLevelMacro"
	Name="AcquisitionNumber"							Type="3"
	Name="AcquisitionDateTime"							Type="1C"	Condition="ImageTypeValue1Original" mbpo="true"
	Name="AcquisitionDuration"							Type="1C"	Condition="ImageTypeValue1Original" mbpo="true"
	Name="CountsSource"									Type="1"	StringEnumValues="CountsSource"
	Name="DecayCorrected"								Type="1"	StringEnumValues="YesNoFull"
	Name="AttenuationCorrected"							Type="1"	StringEnumValues="YesNoFull"
	Name="ScatterCorrected"								Type="1"	StringEnumValues="YesNoFull"
	Name="DeadTimeCorrected"							Type="1"	StringEnumValues="YesNoFull"
	Name="GantryMotionCorrected"						Type="1"	StringEnumValues="YesNoFull"
	Name="PatientMotionCorrected"						Type="1"	StringEnumValues="YesNoFull"
	Name="CountLossNormalizationCorrected"				Type="1"	StringEnumValues="YesNoFull"
	Name="RandomsCorrected"								Type="1"	StringEnumValues="YesNoFull"
	Name="NonUniformRadialSamplingCorrected"			Type="1"	StringEnumValues="YesNoFull"
	Name="SensitivityCalibrated"						Type="1"	StringEnumValues="YesNoFull"
	Name="DetectorNormalizationCorrection"				Type="1"	StringEnumValues="YesNoFull"
	Name="RandomsCorrectionMethod"						Type="1C"	Condition="IsRandomsCorrected"	StringDefinedTerms="RandomsCorrectionMethodEnhanced"
	Name="AttenuationCorrectionSource"					Type="1C"	Condition="IsAttenuationCorrected"	StringDefinedTerms="AttenuationCorrectionSource"
	Name="AttenuationCorrectionTemporalRelationship"	Type="1C"	Condition="IsAttenuationCorrected"	StringDefinedTerms="AttenuationCorrectionTemporalRelationship"
	Name="ScatterCorrectionMethod"						Type="1C"	Condition="IsScatterCorrected"
	Name="DecayCorrectionDateTime"						Type="1C"	Condition="IsDecayCorrected"
	Sequence="ReferencedRawDataSequence"				Type="3"	VM="1-n"
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Sequence="ReferencedWaveformSequence"				Type="3"	VM="1-n"
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Sequence="ReferencedImageEvidenceSequence"			Type="1C"	VM="1-n"	NoCondition=""	# cannot recurse from root to find any Referenced Image Sequence
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Sequence="SourceImageEvidenceSequence"				Type="1C"	VM="1-n"	NoCondition=""	# cannot recurse from root to find any Source Image Sequence
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Name="SamplesPerPixel"							Type="1"	BinaryEnumValues="SamplesPerPixelIsOne"
	Name="PhotometricInterpretation"				Type="1"	StringEnumValues="PhotometricInterpretationMonochrome2"
	Name="BitsAllocated"							Type="1"	BinaryEnumValues="BitsAre16"
	Name="BitsStored"								Type="1"	BinaryEnumValues="BitsAre16"
	Name="HighBit"									Type="1"	BinaryEnumValues="BitsAre15"
	Name="ContentQualification"						Type="1"	StringEnumValues="ContentQualification"
	Name="ImageComments"							Type="3"
	Name="BurnedInAnnotation"						Type="1"	StringEnumValues="NoFull"
	Name="LossyImageCompression"					Type="1"	StringEnumValues="LossyImageCompression"
	Name="LossyImageCompressionRatio"				Type="1C"	Condition="LossyImageCompressionIs01"
	Name="LossyImageCompressionMethod"				Type="1C"	StringDefinedTerms="LossyImageCompressionMethod"	Condition="LossyImageCompressionIs01"
	Verify="LossyImageCompressionMethod"						Condition="LossyImageCompressionMethodInconsistentWithTransferSyntax"	ThenWarningMessage="method inconsistent with transfer syntax" ShowValueWithMessage="true"
	Name="PresentationLUTShape"						Type="1"	StringEnumValues="IdentityPresentationLUTShape"
	Sequence="IconImageSequence"					Type="3"	VM="1"
		InvokeMacro="IconImageSequenceMacro"
	SequenceEnd
ModuleEnd
