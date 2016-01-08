#$Source: /home/bbennett/pass/archive/Posda/tpl/condn.tpl,v $
#$Date: 2009/09/21 19:14:31 $
#$Revision: 1.2 $
#
# Conditions to detect Composite IOD presence ...
#

Condition="EnhancedXAImageInstance"
	Element="SOPClassUID"		StringConstant="EnhancedXAImageStorageSOPClassUID"
ConditionEnd

Condition="EnhancedXRFImageInstance"
	Element="SOPClassUID"		StringConstant="EnhancedXRFImageStorageSOPClassUID"
ConditionEnd

Condition="RealWorldValueMappingInstance"
	Element="SOPClassUID"		StringConstant="RealWorldValueMappingStorageSOPClassUID"
ConditionEnd

Condition="EncapsulatedPDFInstance"
	Element="SOPClassUID"		StringConstant="EncapsulatedPDFStorageSOPClassUID"
ConditionEnd

Condition="EncapsulatedCDAInstance"
	Element="SOPClassUID"		StringConstant="EncapsulatedCDAStorageSOPClassUID"
ConditionEnd

Condition="OphthalmicPhotography8BitImageInstance"
	Element="SOPClassUID"		StringConstant="OphthalmicPhotography8BitImageStorageSOPClassUID"
ConditionEnd

Condition="OphthalmicPhotography16BitImageInstance"
	Element="SOPClassUID"		StringConstant="OphthalmicPhotography16BitImageStorageSOPClassUID"
ConditionEnd

Condition="StereometricRelationshipInstance"
	Element="SOPClassUID"		StringConstant="StereometricRelationshipStorageSOPClassUID"
ConditionEnd

Condition="OphthalmicTomographyImageInstance"
	Element="SOPClassUID"		StringConstant="OphthalmicTomographyImageStorageSOPClassUID"
ConditionEnd

Condition="HangingProtocolInstance"
	Element="SOPClassUID"		StringConstant="HangingProtocolStorageSOPClassUID"
ConditionEnd

Condition="SpatialFiducialsInstance"
	Element="SOPClassUID"		StringConstant="SpatialFiducialsStorageSOPClassUID"
ConditionEnd

Condition="SpatialRegistrationInstance"
	Element="SOPClassUID"		StringConstant="SpatialRegistrationStorageSOPClassUID"
ConditionEnd

Condition="DeformableSpatialRegistrationInstance"
	Element="SOPClassUID"		StringConstant="DeformableSpatialRegistrationStorageSOPClassUID"
ConditionEnd

Condition="EnhancedCTImageInstance"
	Element="SOPClassUID"		StringConstant="EnhancedCTImageStorageSOPClassUID"
ConditionEnd

Condition="RawDataInstance"
	Element="SOPClassUID"		StringConstant="RawDataStorageSOPClassUID"
ConditionEnd

Condition="MRSpectroscopyInstance"
	Element="SOPClassUID"		StringConstant="MRSpectroscopyStorageSOPClassUID"
ConditionEnd

Condition="EnhancedMRImageInstance"
	Element="SOPClassUID"		StringConstant="EnhancedMRImageStorageSOPClassUID"
ConditionEnd

Condition="KeyObjectSelectionDocumentStorageInstance"
	Element="SOPClassUID"		StringConstant="KeyObjectSelectionDocumentStorageSOPClassUID"
ConditionEnd

Condition="MammographyCADSRStorageInstance"
	Element="SOPClassUID"		StringConstant="MammographyCADSRStorageSOPClassUID"
ConditionEnd

Condition="ChestCADSRStorageInstance"
	Element="SOPClassUID"		StringConstant="ChestCADSRStorageSOPClassUID"
ConditionEnd

Condition="BasicTextSRStorageInstance"
	Element="SOPClassUID"		StringConstant="BasicTextSRStorageSOPClassUID"
ConditionEnd

Condition="EnhancedSRStorageInstance"
	Element="SOPClassUID"		StringConstant="EnhancedSRStorageSOPClassUID"
ConditionEnd

Condition="ComprehensiveSRStorageInstance"
	Element="SOPClassUID"		StringConstant="ComprehensiveSRStorageSOPClassUID"
ConditionEnd

Condition="ProcedureLogStorageInstance"
	Element="SOPClassUID"		StringConstant="ProcedureLogStorageSOPClassUID"
ConditionEnd

Condition="XRayRadiationDoseSRStorageInstance"
	Element="SOPClassUID"		StringConstant="XRayRadiationDoseSRStorageSOPClassUID"
ConditionEnd

Condition="GrayscaleSoftcopyPresentationStateInstance"
	Element="SOPClassUID"		StringConstant="GrayscaleSoftcopyPresentationStateStorageSOPClassUID"
ConditionEnd

Condition="ColorSoftcopyPresentationStateInstance"
	Element="SOPClassUID"		StringConstant="ColorSoftcopyPresentationStateStorageSOPClassUID"
ConditionEnd

Condition="PseudoColorSoftcopyPresentationStateInstance"
	Element="SOPClassUID"		StringConstant="PseudoColorSoftcopyPresentationStateStorageSOPClassUID"
ConditionEnd

Condition="BlendingSoftcopyPresentationStateInstance"
	Element="SOPClassUID"		StringConstant="BlendingSoftcopyPresentationStateStorageSOPClassUID"
ConditionEnd

Condition="IsForProcessingSOPClass"
	Element="SOPClassUID"		StringConstant="DigitalXRayImageStorageForProcessingSOPClassUID"
	Element="SOPClassUID"		StringConstant="DigitalMammographyXRayImageStorageForProcessingSOPClassUID"
	Element="SOPClassUID"		StringConstant="DigitalIntraoralXRayImageStorageForProcessingSOPClassUID"
ConditionEnd

Condition="IsForPresentationSOPClass"
	Element="SOPClassUID"		StringConstant="DigitalXRayImageStorageForPresentationSOPClassUID"
	Element="SOPClassUID"		StringConstant="DigitalMammographyXRayImageStorageForPresentationSOPClassUID"
	Element="SOPClassUID"		StringConstant="DigitalIntraoralXRayImageStorageForPresentationSOPClassUID"
ConditionEnd

Condition="DXImageForProcessingInstance"
	Element="SOPClassUID"		StringConstant="DigitalXRayImageStorageForProcessingSOPClassUID"
ConditionEnd

Condition="DXImageForPresentationInstance"
	Element="SOPClassUID"		StringConstant="DigitalXRayImageStorageForPresentationSOPClassUID"
ConditionEnd

Condition="MammographyImageForProcessingInstance"
	Element="SOPClassUID"		StringConstant="DigitalMammographyXRayImageStorageForProcessingSOPClassUID"
ConditionEnd

Condition="MammographyImageForPresentationInstance"
	Element="SOPClassUID"		StringConstant="DigitalMammographyXRayImageStorageForPresentationSOPClassUID"
ConditionEnd

Condition="IntraoralImageForProcessingInstance"
	Element="SOPClassUID"		StringConstant="DigitalIntraoralXRayImageStorageForProcessingSOPClassUID"
ConditionEnd

Condition="IntraoralImageForPresentationInstance"
	Element="SOPClassUID"		StringConstant="DigitalIntraoralXRayImageStorageForPresentationSOPClassUID"
ConditionEnd

Condition="MediaStorageDirectoryInstance"
	Element="MediaStorageSOPClassUID"	StringConstant="MediaStorageDirectoryStorageSOPClassUID"
ConditionEnd

Condition="PETImageInstance"
	Element="SOPClassUID"		StringConstant="PETImageStorageSOPClassUID"
ConditionEnd

Condition="StandalonePETCurveInstance"
	Element="SOPClassUID"		StringConstant="StandalonePETCurveStorageSOPClassUID"
ConditionEnd

Condition="RTImageInstance"
	Element="SOPClassUID"		StringConstant="RTImageStorageSOPClassUID"
ConditionEnd

Condition="RTDoseInstance"
	Element="SOPClassUID"		StringConstant="RTDoseStorageSOPClassUID"
ConditionEnd

Condition="RTStructureSetInstance"
	Element="SOPClassUID"		StringConstant="RTStructureSetStorageSOPClassUID"
ConditionEnd

Condition="RTPlanInstance"
	Element="SOPClassUID"		StringConstant="RTPlanStorageSOPClassUID"
ConditionEnd

Condition="RTIonPlanInstance"
	Element="SOPClassUID"		StringConstant="RTIonPlanStorageSOPClassUID"
ConditionEnd

Condition="RTBeamsTreatmentRecordInstance"
	Element="SOPClassUID"		StringConstant="RTBeamsTreatmentRecordStorageSOPClassUID"
ConditionEnd

Condition="RTIonBeamsTreatmentRecordInstance"
	Element="SOPClassUID"		StringConstant="RTIonBeamsTreatmentRecordStorageSOPClassUID"
ConditionEnd

Condition="RTBrachyTreatmentRecordInstance"
	Element="SOPClassUID"		StringConstant="RTBrachyTreatmentRecordStorageSOPClassUID"
ConditionEnd

Condition="RTTreatmentSummaryRecordInstance"
	Element="SOPClassUID"		StringConstant="RTTreatmentSummaryRecordStorageSOPClassUID"
ConditionEnd

Condition="VisibleLightEndoscopicImageInstance"
	Element="SOPClassUID"		StringConstant="VisibleLightEndoscopicImageStorageSOPClassUID"
ConditionEnd

Condition="VideoEndoscopicImageInstance"
	Element="SOPClassUID"		StringConstant="VideoEndoscopicImageStorageSOPClassUID"
ConditionEnd

Condition="VisibleLightMicroscopicImageInstance"
	Element="SOPClassUID"		StringConstant="VisibleLightMicroscopicImageStorageSOPClassUID"
ConditionEnd

Condition="VideoMicroscopicImageInstance"
	Element="SOPClassUID"		StringConstant="VideoMicroscopicImageStorageSOPClassUID"
ConditionEnd

Condition="VisibleLightSlideCoordinatesMicroscopicImageInstance"
	Element="SOPClassUID"		StringConstant="VisibleLightSlideCoordinatesMicroscopicImageStorageSOPClassUID"
ConditionEnd

Condition="VisibleLightPhotographicImageInstance"
	Element="SOPClassUID"		StringConstant="VisibleLightPhotographicImageStorageSOPClassUID"
ConditionEnd

Condition="VideoPhotographicImageInstance"
	Element="SOPClassUID"		StringConstant="VideoPhotographicImageStorageSOPClassUID"
ConditionEnd

Condition="BasicVoiceInstance"
	Element="SOPClassUID"		StringConstant="BasicVoiceStorageSOPClassUID"
ConditionEnd

Condition="TwelveLeadECGInstance"
	Element="SOPClassUID"		StringConstant="TwelveLeadECGStorageSOPClassUID"
ConditionEnd

Condition="GeneralECGInstance"
	Element="SOPClassUID"		StringConstant="GeneralECGStorageSOPClassUID"
ConditionEnd

Condition="AmbulatoryECGInstance"
	Element="SOPClassUID"		StringConstant="AmbulatoryECGStorageSOPClassUID"
ConditionEnd

Condition="HemodynamicWaveformInstance"
	Element="SOPClassUID"		StringConstant="HemodynamicWaveformStorageSOPClassUID"
ConditionEnd

Condition="CardiacElectrophysiologyWaveformInstance"
	Element="SOPClassUID"		StringConstant="CardiacElectrophysiologyWaveformStorageSOPClassUID"
ConditionEnd

Condition="CRImageInstance"
	Element="SOPClassUID"		StringConstant="ComputedRadiographyImageStorageSOPClassUID"
ConditionEnd

Condition="CTImageInstance"
	Element="SOPClassUID"		StringConstant="CTImageStorageSOPClassUID"
ConditionEnd

Condition="MRImageInstance"
	Element="SOPClassUID"		StringConstant="MRImageStorageSOPClassUID"
ConditionEnd

Condition="NMImageInstance"
	Element="SOPClassUID"		StringConstant="NuclearMedicineImageStorageSOPClassUID"
ConditionEnd

Condition="NMImageRetiredInstance"
	Element="SOPClassUID"		StringConstant="NuclearMedicineImageStorageRetiredSOPClassUID"
	Element="InstanceNumber"	Operator="And" ElementPresent=""
ConditionEnd

Condition="NMOverlayRetiredInstance"
	Element="SOPClassUID"		StringConstant="NuclearMedicineImageStorageRetiredSOPClassUID"
	Element="OverlayNumber"		Operator="And" ElementPresent=""
ConditionEnd

Condition="NMCurveRetiredInstance"
	Element="SOPClassUID"		StringConstant="NuclearMedicineImageStorageRetiredSOPClassUID"
	Element="CurveNumber"		Operator="And" ElementPresent=""
ConditionEnd

Condition="USImageRetiredInstance"
	Element="SOPClassUID"		StringConstant="UltrasoundImageStorageRetiredSOPClassUID"
	Element="InstanceNumber"	Operator="And" ElementPresent=""
ConditionEnd

Condition="USCurveRetiredInstance"
	Element="SOPClassUID"		StringConstant="UltrasoundImageStorageRetiredSOPClassUID"
	Element="CurveNumber"		Operator="And" ElementPresent=""
ConditionEnd

Condition="USMultiFrameImageRetiredInstance"
	Element="SOPClassUID"		StringConstant="UltrasoundMultiframeImageStorageRetiredSOPClassUID"
	Element="InstanceNumber"	Operator="And" ElementPresent=""
ConditionEnd

Condition="USMultiFrameCurveRetiredInstance"
	Element="SOPClassUID"		StringConstant="UltrasoundMultiframeImageStorageRetiredSOPClassUID"
	Element="CurveNumber"		Operator="And" ElementPresent=""
ConditionEnd

Condition="USImageInstance"
	Element="SOPClassUID"		StringConstant="UltrasoundImageStorageSOPClassUID"
	Element="InstanceNumber"	Operator="And" ElementPresent=""
ConditionEnd

Condition="USCurveInstance"
	Element="SOPClassUID"		StringConstant="UltrasoundImageStorageSOPClassUID"
	Element="CurveNumber"		Operator="And" ElementPresent=""
ConditionEnd

Condition="USMultiFrameImageInstance"
	Element="SOPClassUID"		StringConstant="UltrasoundMultiframeImageStorageSOPClassUID"
	Element="InstanceNumber"	Operator="And" ElementPresent=""
ConditionEnd

Condition="USMultiFrameCurveInstance"
	Element="SOPClassUID"		StringConstant="UltrasoundMultiframeImageStorageSOPClassUID"
	Element="CurveNumber"		Operator="And" ElementPresent=""
ConditionEnd

Condition="SCImageInstance"
	Element="SOPClassUID"		StringConstant="SecondaryCaptureImageStorageSOPClassUID"
ConditionEnd

Condition="MultiframeSingleBitSCImageInstance"
	Element="SOPClassUID"		StringConstant="MultiframeSingleBitSecondaryCaptureImageStorageSOPClassUID"
ConditionEnd

Condition="MultiframeGrayscaleByteSCImageInstance"
	Element="SOPClassUID"		StringConstant="MultiframeGrayscaleByteSecondaryCaptureImageStorageSOPClassUID"
ConditionEnd

Condition="MultiframeGrayscaleWordSCImageInstance"
	Element="SOPClassUID"		StringConstant="MultiframeGrayscaleWordSecondaryCaptureImageStorageSOPClassUID"
ConditionEnd

Condition="MultiframeTrueColorSCImageInstance"
	Element="SOPClassUID"		StringConstant="MultiframeTrueColorSecondaryCaptureImageStorageSOPClassUID"
ConditionEnd

Condition="XAImageInstance"
	Element="SOPClassUID"		StringConstant="XRayAngiographicImageStorageSOPClassUID"
ConditionEnd

Condition="XABiplaneImageInstance"
	Element="SOPClassUID"		StringConstant="XRayAngiographicBiplaneImageStorageSOPClassUID"
ConditionEnd

Condition="XRFImageInstance"
	Element="SOPClassUID"		StringConstant="XRayRadioFluoroscopicImageStorageSOPClassUID"
ConditionEnd

Condition="XRay3DAngiographicImageInstance"
	Element="SOPClassUID"		StringConstant="XRay3DAngiographicImageStorageSOPClassUID"
ConditionEnd

Condition="XRay3DCraniofacialImageInstance"
	Element="SOPClassUID"		StringConstant="XRay3DCraniofacialImageStorageSOPClassUID"
ConditionEnd

Condition="StandaloneOverlayInstance"
	Element="SOPClassUID"		StringConstant="StandaloneOverlayStorageSOPClassUID"
ConditionEnd

Condition="StandaloneCurveInstance"
	Element="SOPClassUID"		StringConstant="StandaloneCurveStorageSOPClassUID"
ConditionEnd

Condition="StandaloneModalityLUTInstance"
	Element="SOPClassUID"		StringConstant="StandaloneModalityLUTStorageSOPClassUID"
ConditionEnd

Condition="StandaloneVOILUTInstance"
	Element="SOPClassUID"		StringConstant="StandaloneVOILUTStorageSOPClassUID"
ConditionEnd

# Conditions for inclusion of Modules with Usage "C" in Composite IODs  ...

# General principle is that if any type 1 or 2 required attributes are
# present then the module is needed

# Really need to seperate concepts of when is "module required" from "module present" :(

Condition="NeedModuleAcquisitionContext"
	Element="AcquisitionContextSequence"		ElementPresent=""
ConditionEnd

Condition="NeedModuleContrastBolus"
	Element="ContrastBolusAgent"		ElementPresent=""
ConditionEnd

Condition="NeedModuleCine"
	Element="FrameTime"			ElementPresent=""
	Element="FrameTimeVector"		ElementPresent=""
ConditionEnd

Condition="NeedModuleMultiFrame"
	Element="NumberOfFrames"		ElementPresent=""
	Element="NumberOfFrames"		Operator="And" ValueSelector="0" BinaryValue="> 1"
ConditionEnd

Condition="NumberOfFramesGreaterThanOne"
	Element="NumberOfFrames"		ElementPresent=""
	Element="NumberOfFrames"		Operator="And" ValueSelector="0" BinaryValue="> 1"
ConditionEnd

Condition="NeedModuleNMMultiGatedAcquisitionImageRetired"
	Element="FrameTime"			ElementPresent=""
ConditionEnd

Condition="NeedModuleNMSPECTAcquisitionImageRetired"
	Element="AngularStep"			ElementPresent=""
ConditionEnd

Condition="NeedModuleUSFrameOfReference"
	Element="RegionLocationMinX0"		ElementPresent=""
	Element="RegionLocationMinY0"		ElementPresent=""
	Element="RegionLocationMaxX1"		ElementPresent=""
	Element="RegionLocationMaxY1"		ElementPresent=""
	Element="PhysicalUnitsXDirection"	ElementPresent=""
	Element="PhysicalUnitsYDirection"	ElementPresent=""
	Element="PhysicalDeltaX"		ElementPresent=""
	Element="PhysicalDeltaY"		ElementPresent=""
ConditionEnd

Condition="NeedModuleOverlayPlane"
	Element="OverlayRows"			ElementPresent="0xff00"
	Element="OverlayColumns"		ElementPresent="0xff00"
	Element="OverlayType"			ElementPresent="0xff00"
	Element="OverlaySubtype"		ElementPresent="0xff00"
	Element="OverlayOrigin"			ElementPresent="0xff00"
	Element="OverlayBitsAllocated"		ElementPresent="0xff00"
	Element="OverlayBitPosition"		ElementPresent="0xff00"
	Element="OverlayData"			ElementPresent="0xff00"
	Element="ROIArea"			ElementPresent="0xff00"
	Element="ROIMean"			ElementPresent="0xff00"
	Element="ROIStandardDeviation"		ElementPresent="0xff00"
	Element="OverlayDescriptorGray"		ElementPresent="0xff00"
	Element="OverlayDescriptorRed"		ElementPresent="0xff00"
	Element="OverlayDescriptorGreen"	ElementPresent="0xff00"
	Element="OverlayDescriptorBlue"		ElementPresent="0xff00"
	Element="OverlayGray"			ElementPresent="0xff00"
	Element="OverlayRed"			ElementPresent="0xff00"
	Element="OverlayGreen"			ElementPresent="0xff00"
	Element="OverlayBlue"			ElementPresent="0xff00"
	Element="OverlayDescription"		ElementPresent="0xff00"
	Element="OverlayLabel"			ElementPresent="0xff00"
ConditionEnd

Condition="NeedModuleApproval"
	Element="ApprovalStatus"		ElementPresent=""
	Element="ReviewDate"			ElementPresent=""
	Element="ReviewTime"			ElementPresent=""
	Element="ReviewerName"			ElementPresent=""
ConditionEnd

Condition="NeedModuleModalityLUT"
	Element="RescaleIntercept"		ElementPresent=""
	Element="RescaleSlope"			ElementPresent=""
	Element="RescaleType"			ElementPresent=""
	Element="ModalityLUTSequence"		ElementPresent=""
ConditionEnd

Condition="NeedModuleVOILUT"
	Element="WindowCenter"			ElementPresent=""
	Element="WindowWidth"			ElementPresent=""
	Element="WindowCenterWidthExplanation"	ElementPresent=""
	Element="VOILUTSequence"		ElementPresent=""
	Element="VOILUTFunction"		ElementPresent=""
ConditionEnd

Condition="NeedModuleFrameOfReference"
	Element="FrameOfReferenceUID"		ElementPresent=""
	Element="PositionReferenceIndicator"	ElementPresent=""
ConditionEnd

Condition="NeedModuleFrameOfReferenceInVLI"
	# should really check Image Acquisition Context for true condition
	Element="FrameOfReferenceUID"		ElementPresent=""
	Element="PositionReferenceIndicator"	ElementPresent=""
ConditionEnd

Condition="NeedModuleImagePlane"
	Element="PixelSpacing"			ElementPresent=""
	Element="ImageOrientationPatient"	ElementPresent=""
	Element="ImagePositionPatient"		ElementPresent=""
ConditionEnd

Condition="NeedModuleMultiFrameOverlay"
	Element="NumberOfFramesInOverlay"	ElementPresent=""
ConditionEnd

Condition="NeedModuleUSRegionCalibration"
	Element="SequenceOfUltrasoundRegions"	ElementPresent=""
ConditionEnd

Condition="NeedModuleGeneralEquipment"
	Element="Manufacturer"					ElementPresent=""
	Element="InstitutionName"				ElementPresent=""
	Element="InstitutionAddress"			ElementPresent=""
	Element="StationName"					ElementPresent=""
	Element="InstitutionalDepartmentName"	ElementPresent=""
	Element="ManufacturerModelName"			ElementPresent=""
	Element="DeviceSerialNumber"			ElementPresent=""
	Element="SoftwareVersion"				ElementPresent=""
	Element="GantryID"						ElementPresent=""
	Element="SpatialResolution"				ElementPresent=""
	Element="DateOfLastCalibration"			ElementPresent=""
	Element="TimeOfLastCalibration"			ElementPresent=""
	Element="PixelPaddingValue"				ElementPresent=""
ConditionEnd

Condition="NeedModuleNMTomoAcquisition"
	Element="ImageType"			ValueSelector="2"	StringValue="TOMO"
	Element="ImageType"			ValueSelector="2"	StringValue="GATED TOMO"
	Element="ImageType"			ValueSelector="2"	StringValue="RECON TOMO"
	Element="ImageType"			ValueSelector="2"	StringValue="RECON GATED TOMO"
ConditionEnd

Condition="NeedModuleNMMultiGatedAcquisition"
	Element="ImageType"			ValueSelector="2"	StringValue="TOMO"
	Element="ImageType"			ValueSelector="2"	StringValue="GATED TOMO"
	Element="ImageType"			ValueSelector="2"	StringValue="RECON TOMO"
	Element="ImageType"			ValueSelector="2"	StringValue="RECON GATED TOMO"
ConditionEnd

Condition="NeedModuleNMPhase"
	Element="ImageType"			ValueSelector="2"	StringValue="DYNAMIC"
ConditionEnd

Condition="NeedModuleNMReconstruction"
	Element="ImageType"			ValueSelector="2"	StringValue="RECON TOMO"
	Element="ImageType"			ValueSelector="2"	StringValue="RECON GATED TOMO"
ConditionEnd

Condition="NeedModuleSpecimen"
	Element="SpecimenAccessionNumber"			ElementPresent=""
	Element="SpecimenSequence"				ElementPresent=""
ConditionEnd

Condition="NeedModuleSpecimenIdentification"
	Element="SpecimenAccessionNumber"			ElementPresent=""
	Element="SpecimenSequence"				ElementPresent=""
ConditionEnd

Condition="NeedModuleDXDetector"
	Element="DetectorType"							ElementPresent=""
ConditionEnd

Condition="NeedModuleXAXRFMultiFramePresentation"
	Element="PreferredPlaybackSequencing"					ElementPresent=""
	Element="FrameDisplaySequence"							ElementPresent=""
	Element="RecommendedViewingMode"						ElementPresent=""
	Element="DisplayFilterPercentage"						ElementPresent=""
ConditionEnd

Condition="RecommendedViewingModeIsSUB"
	Element="RecommendedViewingMode"						StringValue="SUB"
ConditionEnd

Condition="CodingSchemeVersionRequired"
	Element="CodingSchemeDesignator"							StringValue="BI"
	Element="CodingSchemeDesignator"			Operator="Or"	StringValue="SCPECG"
	Element="CodingSchemeDesignator"			Operator="Or"	StringValue="BARI"
	Element="CodingSchemeDesignator"			Operator="Or"	StringValue="UCUM"
	Element="CodingSchemeDesignator"			Operator="Or"	StringValue="NCDR"
ConditionEnd

Condition="SpecimenIsSlide"
# too difficult to check real world condition ? ... best guess is ...
	Element="Modality"			StringValue="SM"
ConditionEnd

Condition="ModalityIsSM"
	Element="Modality"			StringValue="SM"
ConditionEnd

Condition="SpecimenNeedsDescription"
# too difficult to check real world condition ?
ConditionEnd

Condition="NeedMeasurementUnitsCodeSequence"
	Element="ValueType"			Operator="Or"	StringValue="NUM"
	Element="NumericValue"			ElementPresent=""
ConditionEnd

Condition="MeasurementUnitsCodeSequencePresentAndNumericValueAbsent"
	Element="MeasurementUnitsCodeSequence"	ElementPresent=""
	Element="NumericValue"					Operator="And"	Modifier="Not" ElementPresent=""
ConditionEnd

Condition="AcquisitionContextItemIsNumericValueOrMeasurementUnitsCodeSequenceIsPresent"
# too difficult to check ConceptNameCodeSequence
# so require by absence of other alternatives ...
	Element="Time"						Modifier="Not" ElementPresent=""
	Element="PersonName"			Operator="And"	Modifier="Not" ElementPresent=""
	Element="TextValue"			Operator="And"	Modifier="Not" ElementPresent=""
	Element="ConceptCodeSequence"		Operator="And"	Modifier="Not" ElementPresent=""
	Element="Date"				Operator="And"	Modifier="Not" ElementPresent=""
# need to place these or conditions here at the end
	Element="ValueType"			Operator="Or"	StringValue="NUM"
	Element="MeasurementUnitsCodeSequence"	Operator="Or"	ElementPresent=""
ConditionEnd

Condition="AcquisitionContextItemIsDate"
# too difficult to check ConceptNameCodeSequence
# so require by absence of other alternatives ...
	Element="Time"						Modifier="Not" ElementPresent=""
	Element="PersonName"			Operator="And"	Modifier="Not" ElementPresent=""
	Element="TextValue"			Operator="And"	Modifier="Not" ElementPresent=""
	Element="ConceptCodeSequence"		Operator="And"	Modifier="Not" ElementPresent=""
	Element="NumericValue"			Operator="And"	Modifier="Not" ElementPresent=""
# need to place this or condition here at the end
	Element="ValueType"			Operator="Or"	StringValue="DATE"
ConditionEnd

Condition="AcquisitionContextItemIsTime"
# too difficult to check ConceptNameCodeSequence
# so require by absence of other alternatives ...
	Element="Date"						Modifier="Not" ElementPresent=""
	Element="PersonName"			Operator="And"	Modifier="Not" ElementPresent=""
	Element="TextValue"			Operator="And"	Modifier="Not" ElementPresent=""
	Element="ConceptCodeSequence"		Operator="And"	Modifier="Not" ElementPresent=""
	Element="NumericValue"			Operator="And"	Modifier="Not" ElementPresent=""
# need to place this or condition here at the end
	Element="ValueType"			Operator="Or"	StringValue="TIME"
ConditionEnd

Condition="AcquisitionContextItemIsPersonName"
# too difficult to check ConceptNameCodeSequence
# so require by absence of other alternatives ...
	Element="Date"						Modifier="Not" ElementPresent=""
	Element="Time"				Operator="And"	Modifier="Not" ElementPresent=""
	Element="TextValue"			Operator="And"	Modifier="Not" ElementPresent=""
	Element="ConceptCodeSequence"		Operator="And"	Modifier="Not" ElementPresent=""
	Element="NumericValue"			Operator="And"	Modifier="Not" ElementPresent=""
# need to place this or condition here at the end
	Element="ValueType"			Operator="Or"	StringValue="PNAME"
ConditionEnd

Condition="AcquisitionContextItemIsTextValue"
# too difficult to check ConceptNameCodeSequence
# so require by absence of other alternatives ...
	Element="Date"						Modifier="Not" ElementPresent=""
	Element="Time"				Operator="And"	Modifier="Not" ElementPresent=""
	Element="PersonName"			Operator="And"	Modifier="Not" ElementPresent=""
	Element="ConceptCodeSequence"		Operator="And"	Modifier="Not" ElementPresent=""
	Element="NumericValue"			Operator="And"	Modifier="Not" ElementPresent=""
# need to place this or condition here at the end
	Element="ValueType"			Operator="Or"	StringValue="TEXT"
ConditionEnd

Condition="AcquisitionContextItemIsConceptCodeSequence"
# required by absence of other alternatives ...
	Element="Date"						Modifier="Not" ElementPresent=""
	Element="Time"				Operator="And"	Modifier="Not" ElementPresent=""
	Element="PersonName"			Operator="And"	Modifier="Not" ElementPresent=""
	Element="TextValue"			Operator="And"	Modifier="Not" ElementPresent=""
	Element="NumericValue"			Operator="And"	Modifier="Not" ElementPresent=""
# need to place this or condition here at the end
	Element="ValueType"			Operator="Or"	StringValue="CODE"
ConditionEnd

Condition="ConceptNameCodeSequenceNotPresent"
	Element="ConceptNameCodeSequence"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="UnformattedTextValueNotPresent"
	Element="UnformattedTextValue"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ContextIdentifierIsPresent"
	Element="ContextIdentifier"		ElementPresent=""
ConditionEnd

Condition="ExtendedCodingScheme"
	Element="ContextGroupExtensionFlag"	StringValue="Y"
ConditionEnd

# Conditions for inclusion of type 1C and 2C Elements in Modules  ...

Condition="SamplesPerPixelGreaterThanOne"
	Element="SamplesPerPixel"		ValueSelector="0"	BinaryValue="> 1"
ConditionEnd

Condition="PhotometricInterpretationNeedsPalette"
	Element="PhotometricInterpretation"	StringValue="PALETTE COLOR"
ConditionEnd

Condition="NeedsNonSegmentedLookupTableData"
	Element="SegmentedRedPaletteColorLookupTableData"				   Modifier="Not" ElementPresent=""
	Element="SegmentedGreenPaletteColorLookupTableData"	Operator="And" Modifier="Not" ElementPresent=""
	Element="SegmentedBluePaletteColorLookupTableData"	Operator="And" Modifier="Not" ElementPresent=""
	Element="SOPClassUID"								Operator="Or" StringValue="1.2.840.10008.5.1.4.1.1.11.3"
	Element="SOPClassUID"								Operator="Or" StringValue="1.2.840.10008.5.1.4.1.1.11.4"
ConditionEnd

Condition="NeedsSegmentedLookupTableData"
	Element="RedPaletteColorLookupTableData"					   Modifier="Not" ElementPresent=""
	Element="GreenPaletteColorLookupTableData"		Operator="And" Modifier="Not" ElementPresent=""
	Element="BluePaletteColorLookupTableData"		Operator="And" Modifier="Not" ElementPresent=""
	Element="SOPClassUID"							Operator="And" Modifier="Not" StringValue="1.2.840.10008.5.1.4.1.1.11.3"
	Element="SOPClassUID"							Operator="And" Modifier="Not" StringValue="1.2.840.10008.5.1.4.1.1.11.4"
ConditionEnd

Condition="PhotometricInterpretationIsPaletteColor"
	Element="PhotometricInterpretation"	StringValue="PALETTE COLOR"
ConditionEnd

Condition="PhotometricInterpretationIsMonochrome2"
	Element="PhotometricInterpretation"	StringValue="MONOCHROME2"
ConditionEnd

Condition="PhotometricInterpretationIsMonochrome1"
	Element="PhotometricInterpretation"	StringValue="MONOCHROME1"
ConditionEnd

Condition="PhotometricInterpretationNeedsOneSample"
	Element="PhotometricInterpretation"	StringValue="PALETTE COLOR"
	Element="PhotometricInterpretation"	StringValue="MONOCHROME1"
	Element="PhotometricInterpretation"	StringValue="MONOCHROME2"
ConditionEnd

# use from root since check may be from inside functional group macro
# check present first, since not true for presentation states (as opposed to images)
Condition="PhotometricInterpretationIsGrayscaleOrAbsent"
	Element="PhotometricInterpretation"	Modifier="Not"	ElementPresent=""
	Element="PhotometricInterpretation"	Operator="Or"	StringValueFromRootAttribute="MONOCHROME1"
	Element="PhotometricInterpretation"	Operator="Or"	StringValueFromRootAttribute="MONOCHROME2"
ConditionEnd

Condition="PhotometricInterpretationNeedsThreeSamples"
	Element="PhotometricInterpretation"	StringValue="RGB"
	Element="PhotometricInterpretation"	StringValue="YBR_FULL"
	Element="PhotometricInterpretation"	StringValue="YBR_FULL_422"
	Element="PhotometricInterpretation"	StringValue="YBR_PARTIAL_422"
	Element="PhotometricInterpretation"	StringValue="YBR_PARTIAL_420"
	Element="PhotometricInterpretation"	StringValue="YBR_RCT"
	Element="PhotometricInterpretation"	StringValue="YBR_ICT"
ConditionEnd

Condition="SOPClassIsCTOrMR"
	Element="SOPClassUID"			StringConstant="EnhancedMRImageStorageSOPClassUID"
	Element="SOPClassUID"			StringConstant="MRSpectroscopyStorageSOPClassUID"
	Element="SOPClassUID"			StringConstant="MRImageStorageSOPClassUID"
	Element="SOPClassUID"			StringConstant="EnhancedCTImageStorageSOPClassUID"
	Element="SOPClassUID"			StringConstant="CTImageStorageSOPClassUID"
ConditionEnd

Condition="ModalityIsCTOrMR"
	Element="Modality"			StringValue="MR"
	Element="Modality"			StringValue="CT"
ConditionEnd

Condition="PatientOrientationRequired"
	# General Image Module: "Required if image does not require Image Orientation (Patient) (0020,0037) and Image Position (Patient) (0020,0032)."
	Element="SOPClassUID"			               Modifier="Not" StringConstant="EnhancedMRImageStorageSOPClassUID"
	Element="SOPClassUID"			Operator="And" Modifier="Not" StringConstant="MRSpectroscopyStorageSOPClassUID"
	Element="SOPClassUID"			Operator="And" Modifier="Not" StringConstant="MRImageStorageSOPClassUID"
	Element="SOPClassUID"			Operator="And" Modifier="Not" StringConstant="CTImageStorageSOPClassUID"
	Element="SOPClassUID"			Operator="And" Modifier="Not" StringConstant="EnhancedCTImageStorageSOPClassUID"
	Element="SOPClassUID"			Operator="And" Modifier="Not" StringConstant="NuclearMedicineImageStorageSOPClassUID"
	Element="SOPClassUID"			Operator="And" Modifier="Not" StringConstant="NuclearMedicineImageStorageRetiredSOPClassUID"
	Element="SOPClassUID"			Operator="And" Modifier="Not" StringConstant="PETImageStorageSOPClassUID"
	# not required for RT dose, since either needed for grid (image) or not an image hence not applicable
	Element="SOPClassUID"			Operator="And" Modifier="Not" StringConstant="RTDoseStorageSOPClassUID"
ConditionEnd

Condition="MRIsNotEchoPlanarNotSegmentedKSpace"
	Element="ScanningSequence"						Modifier="Not" ValueSelector="*"	StringValue="EP"
	Element="SequenceVariant"		Operator="Or"	Modifier="Not" ValueSelector="*"	StringValue="SK"
ConditionEnd

Condition="MRIsInversionRecovery"
	Element="ScanningSequence"		ValueSelector="*"	StringValue="IR"
ConditionEnd

Condition="MRIsCardiacOrPulseGated"
	Element="ScanOptions"							ValueSelector="*"	StringValue="CG"
	Element="ScanOptions"			Operator="Or"	ValueSelector="*"	StringValue="PPG"
ConditionEnd

Condition="NMIsWholeBody"
	Element="NuclearMedicineSeriesTypeRetired"	StringValue="WHOLE BODY"
ConditionEnd

Condition="CurveDataDescriptorPresent"
	Element="CurveDataDescriptor"		ElementPresent="0xff00"
ConditionEnd

Condition="ModalityLUTSequenceNotPresent"
	Element="ModalityLUTSequence"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="RescaleInterceptPresent"
	Element="RescaleIntercept"		ElementPresent=""
ConditionEnd

Condition="RescaleInterceptNotPresent"
	Element="RescaleIntercept"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="WindowCenterPresent"
	Element="WindowCenter"			ElementPresent=""
ConditionEnd

Condition="WindowCenterNotPresent"
	Element="WindowCenter"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="MonochromeAndWindowCenterNotPresent"
	Element="WindowCenter"								Modifier="Not" ElementPresent=""
	Element="SamplesPerPixel"							Operator="And"	ValueSelector="0" BinaryValueFromRootAttribute="== 1"
	Element="RedPaletteColorLookupTableDescriptor"		Operator="And"	Modifier="Not" ElementPresent=""
ConditionEnd

Condition="VOILUTSequenceNotPresent"
	Element="VOILUTSequence"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="MonochromeAndVOILUTSequenceNotPresent"
	Element="VOILUTSequence"							Modifier="Not" ElementPresent=""
	Element="SamplesPerPixel"							Operator="And"	ValueSelector="0" BinaryValueFromRootAttribute="== 1"
	Element="RedPaletteColorLookupTableDescriptor"		Operator="And"	Modifier="Not" ElementPresent=""
ConditionEnd

Condition="NumberOfFramesPresent"
	Element="NumberOfFrames"	ElementPresent=""
ConditionEnd

# Conditions for NM object ...

Condition="ImageTypeValue3WholeBodyOrStatic"
	Element="ImageType"		ValueSelector="2"	StringValue="WHOLE BODY"
	Element="ImageType"		ValueSelector="2"	StringValue="STATIC"
ConditionEnd

Condition="ImageTypeValue3WholeBody"
	Element="ImageType"		ValueSelector="2"	StringValue="WHOLE BODY"
ConditionEnd

Condition="ImageTypeValue3Gated"
	Element="ImageType"		ValueSelector="2"	StringValue="GATED"
ConditionEnd

Condition="ImageTypeValue3Dynamic"
	Element="ImageType"		ValueSelector="2"	StringValue="DYNAMIC"
ConditionEnd

Condition="ImageTypeValue3Tomo"
	Element="ImageType"		ValueSelector="2"	StringValue="TOMO"
ConditionEnd

Condition="ImageTypeValue3GatedTomo"
	Element="ImageType"		ValueSelector="2"	StringValue="GATED TOMO"
ConditionEnd

Condition="ImageTypeValue3ReconTomo"
	Element="ImageType"		ValueSelector="2"	StringValue="RECON TOMO"
ConditionEnd

Condition="ImageTypeValue3ReconGatedTomo"
	Element="ImageType"		ValueSelector="2"	StringValue="RECON GATED TOMO"
ConditionEnd

Condition="ImageTypeValue3TomoFamily"
	Element="ImageType"		ValueSelector="2"	StringValue="TOMO"
	Element="ImageType"		ValueSelector="2"	StringValue="GATED TOMO"
	Element="ImageType"		ValueSelector="2"	StringValue="RECON TOMO"
	Element="ImageType"		ValueSelector="2"	StringValue="RECON GATED TOMO"
ConditionEnd

Condition="ImageTypeValue4TransmissionAndNotTomo"
	# ie. all except the TOMO values ... check if there are more :(
	Element="ImageType"		ValueSelector="2"	StringValue="STATIC"
	Element="ImageType"		ValueSelector="2"	StringValue="WHOLE BODY"
	Element="ImageType"		ValueSelector="3"	Operator="And" StringValue="TRANSMISSION"
ConditionEnd

Condition="ImageTypeValue4Transmission"
	Element="ImageType"		ValueSelector="3"	StringValue="TRANSMISSION"
ConditionEnd

Condition="FrameIncrementPointerContainsEnergyWindowVector"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0054,0x0010"
ConditionEnd

Condition="FrameIncrementPointerContainsDetectorVector"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0054,0x0020"
ConditionEnd

Condition="FrameIncrementPointerContainsPhaseVector"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0054,0x0030"
ConditionEnd

Condition="FrameIncrementPointerContainsRotationVector"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0054,0x0050"
ConditionEnd

Condition="FrameIncrementPointerContainsRRIntervalVector"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0054,0x0060"
ConditionEnd

Condition="FrameIncrementPointerContainsTimeSlotVector"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0054,0x0070"
ConditionEnd

Condition="FrameIncrementPointerContainsSliceVector"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0054,0x0080"
ConditionEnd

Condition="FrameIncrementPointerContainsAngularViewVector"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0054,0x0090"
ConditionEnd

Condition="FrameIncrementPointerContainsTimeSliceVector"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0054,0x0100"
ConditionEnd

Condition="FrameIncrementPointerContainsInstanceNumber"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0020,0x0013"
ConditionEnd

Condition="FrameIncrementPointerContainsImageTime"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0008,0x0033"
ConditionEnd

Condition="TriggerVectorIsPresent"
	Element="TriggerVector"					ElementPresent=""
ConditionEnd

# for existing cine module ...

Condition="FrameIncrementPointerContainsFrameTime"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0018,0x1063"
ConditionEnd

Condition="FrameIncrementPointerContainsFrameTimeVector"
	Element="FrameIncrementPointer"	ValueSelector="*"	TagValue="0x0018,0x1065"
ConditionEnd

# Conditions for new XA and XRF objects ...

Condition="ImageTypeValue3BiplaneAOrB"
	Element="ImageType"		ValueSelector="2"	StringValue="BIPLANE A"
	Element="ImageType"		ValueSelector="2"	StringValue="BIPLANE B"
ConditionEnd

Condition="OneOverlayForBothPlanesOfBiplane"
	Element="OverlayPlanes"		ValueSelector="0"	BinaryValue="== 1"
	Element="ImageType"		Operator="And" ValueSelector="2" StringValue="BIPLANE"
ConditionEnd

Condition="PositionerMotionDynamic"
	Element="PositionerMotion"	StringValue="DYNAMIC"
ConditionEnd

Condition="TableMotionDynamic"
	Element="TableMotion"		StringValue="DYNAMIC"
ConditionEnd

Condition="ExposureNotPresent"
	Element="Exposure"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="XRayTubeCurrentAndExposureTimeNotPresent"
	Element="XRayTubeCurrent"	Modifier="Not" ElementPresent=""
	Element="ExposureTime"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="DeviceDiameterIsPresent"
	Element="DeviceDiameter"	ElementPresent=""
ConditionEnd

Condition="ShutterShapeIsAbsent"
	Element="ShutterShape"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ShutterShapeIsPresent"
	Element="ShutterShape"		ElementPresent=""
ConditionEnd

Condition="ShutterShapeIsRectangular"
	Element="ShutterShape"		StringValue="RECTANGULAR"
ConditionEnd

Condition="ShutterShapeIsCircular"
	Element="ShutterShape"		StringValue="CIRCULAR"
ConditionEnd

Condition="ShutterShapeIsPolygonal"
	Element="ShutterShape"		StringValue="POLYGONAL"
ConditionEnd

Condition="CollimatorShapeIsRectangular"
	Element="CollimatorShape"	StringValue="RECTANGULAR"
ConditionEnd

Condition="CollimatorShapeIsCircular"
	Element="CollimatorShape"	StringValue="CIRCULAR"
ConditionEnd

Condition="CollimatorShapeIsPolygonal"
	Element="CollimatorShape"	StringValue="POLYGONAL"
ConditionEnd

Condition="MaskOperationIsTID"
	Element="MaskOperation"		StringValue="TID"
ConditionEnd

Condition="MaskOperationIsAvgSub"
	Element="MaskOperation"		StringValue="AVG_SUB"
ConditionEnd

Condition="NeedModuleFramePointers"
	Element="RepresentativeFrameNumber"	ElementPresent=""
	Element="FrameNumbersOfInterest"	ElementPresent=""
	Element="FrameOfInterestDescription"	ElementPresent=""
ConditionEnd

Condition="NeedModuleMask"
	Element="MaskSubtractionSequence"	ElementPresent=""
	Element="RecommendedViewingMode"	ElementPresent=""
ConditionEnd

Condition="NeedModuleDisplayShutter"
	Element="ShutterShape"				ElementPresent=""
	Element="ShutterShape"				Operator="And"	Modifier="Not"	StringValue="BITMAP"
	Element="ShutterLeftVerticalEdge"	ElementPresent=""
	Element="ShutterRightVerticalEdge"	ElementPresent=""
	Element="ShutterUpperHorizontalEdge"	ElementPresent=""
	Element="ShutterLowerHorizontalEdge"	ElementPresent=""
	Element="CenterOfCircularShutter"	ElementPresent=""
	Element="RadiusOfCircularShutter"	ElementPresent=""
	Element="VerticesOfPolygonalShutter"	ElementPresent=""
ConditionEnd

Condition="NeedModuleDevice"
	Element="DeviceSequence"		ElementPresent=""
ConditionEnd

Condition="NeedModuleIntervention"
	Element="InterventionSequence"	ElementPresent=""
ConditionEnd

Condition="NeedModuleXRayCollimator"
	Element="CollimatorShape"		ElementPresent=""
ConditionEnd

Condition="NeedModuleXRayTable"
	Element="TableMotion"			ElementPresent=""
	Element="TableAngle"			ElementPresent=""
ConditionEnd

Condition="XRayNeedModuleModalityLUT"
	Element="PixelIntensityRelationship"	StringValue="LOG"
	# Optional if Pixel Intensity Relationship is DISP
ConditionEnd

Condition="NeedModuleBiplaneOverlay"
	Element="OverlayPlanes"			ElementPresent=""
	Element="PlaneOrigin"			ElementPresent=""
ConditionEnd

Condition="NeedModuleXRayTomographyAcquisitionBasedOnScanOptions"
	Element="ScanOptions"		StringValue="TOMO"
ConditionEnd

Condition="NeedToCheckModuleXRayTomographyAcquisition"
	Element="TomoLayerHeight"			ElementPresent=""
ConditionEnd

# Meta Information Header stuff ...

Condition="NeedModuleFileMetaInformation"
	Element="FileMetaInformationVersion"	GroupPresent=""
ConditionEnd

Condition="PrivateInformationCreatorUIDPresent"
	Element="PrivateInformationCreatorUID"	ElementPresent=""
ConditionEnd

Condition="NeedPixelComponentOrganization"
# condition is real world, but assume on presence of dependent atributes ...
	Element="PixelComponentMask"		ElementPresent=""
	Element="PixelComponentRangeStart"	ElementPresent=""
	Element="PixelComponentRangeStop"	ElementPresent=""
	Element="PixelComponentPhysicalUnits"	ElementPresent=""
	Element="PixelComponentDataType"	ElementPresent=""
	Element="NumberOfTableBreakPoints"	ElementPresent=""
	Element="TableOfXBreakPoints"		ElementPresent=""
	Element="TableOfYBreakPoints"		ElementPresent=""
	Element="NumberOfTableEntries"		ElementPresent=""
	Element="TableOfPixelValues"		ElementPresent=""
	Element="TableOfParameterValues"	ElementPresent=""
ConditionEnd

Condition="PixelComponentOrganizationPresent"
	Element="PixelComponentOrganization"	ElementPresent=""
ConditionEnd

Condition="PixelComponentOrganizationIs0Or1"
	Element="PixelComponentOrganization"	ValueSelector="0"	BinaryValue="== 0"
	Element="PixelComponentOrganization"	ValueSelector="0"	BinaryValue="== 1"
ConditionEnd

Condition="PixelComponentOrganizationIs0"
	Element="PixelComponentOrganization"	ValueSelector="0"	BinaryValue="== 0"
ConditionEnd

Condition="PixelComponentOrganizationIs1"
	Element="PixelComponentOrganization"	ValueSelector="0"	BinaryValue="== 1"
ConditionEnd

Condition="PixelComponentOrganizationIs2"
	Element="PixelComponentOrganization"	ValueSelector="0"	BinaryValue="== 2"
ConditionEnd

Condition="PixelComponentOrganizationIs3"
	Element="PixelComponentOrganization"	ValueSelector="0"	BinaryValue="== 3"
ConditionEnd

Condition="PixelComponentOrganizationIs2Or3"
	Element="PixelComponentOrganization"	ValueSelector="0"	BinaryValue="== 2"
	Element="PixelComponentOrganization"	ValueSelector="0"	BinaryValue="== 3"
ConditionEnd

Condition="US8BitSamples"
	Element="PhotometricInterpretation"	StringValue="MONOCHROME2"
	Element="PhotometricInterpretation"	StringValue="RGB"
	Element="PhotometricInterpretation"	StringValue="YBR_FULL"
	Element="PhotometricInterpretation"	StringValue="YBR_FULL_422"
	Element="PhotometricInterpretation"	StringValue="YBR_PARTIAL_422"
ConditionEnd

Condition="US8Or16BitSamples"
	Element="PhotometricInterpretation"	StringValue="PALETTE COLOR"
ConditionEnd

Condition="USNeedsColorByPlaneOrPixel"
	Element="PhotometricInterpretation"	StringValue="RGB"
ConditionEnd

Condition="USNeedsColorByPlane"
	Element="PhotometricInterpretation"	StringValue="YBR_FULL"
ConditionEnd

Condition="USNeedsColorByPixel"
	Element="PhotometricInterpretation"	StringValue="YBR_FULL_422"
	Element="PhotometricInterpretation"	StringValue="YBR_PARTIAL_422"
ConditionEnd

Condition="DirectorySOPInstance"
	Element="DirectoryRecordType"		StringValue="IMAGE"
	Element="DirectoryRecordType"		StringValue="OVERLAY"
	Element="DirectoryRecordType"		StringValue="MODALITY LUT"
	Element="DirectoryRecordType"		StringValue="VOI LUT"
	Element="DirectoryRecordType"		StringValue="CURVE"
	Element="DirectoryRecordType"		StringValue="VISIT"
	Element="DirectoryRecordType"		StringValue="RESULTS"
	Element="DirectoryRecordType"		StringValue="INTERPRETATION"
	Element="DirectoryRecordType"		StringValue="STUDY COMPONENT"
	Element="DirectoryRecordType"		StringValue="FILM SESSION"
	Element="DirectoryRecordType"		StringValue="FILM BOX"
	Element="DirectoryRecordType"		StringValue="IMAGE BOX"
	Element="DirectoryRecordType"		StringValue="STORED PRINT"
	Element="DirectoryRecordType"		StringValue="RT DOSE"
	Element="DirectoryRecordType"		StringValue="RT STRUCTURE SET"
	Element="DirectoryRecordType"		StringValue="RT PLAN"
	Element="DirectoryRecordType"		StringValue="RT TREAT RECORD"
	Element="DirectoryRecordType"		StringValue="PRESENTATION"
	Element="DirectoryRecordType"		StringValue="WAVEFORM"
	Element="DirectoryRecordType"		StringValue="SR DOCUMENT"
	Element="DirectoryRecordType"		StringValue="KEY OBJECT DOC"
	Element="DirectoryRecordType"		StringValue="SPECTROSCOPY"
	Element="DirectoryRecordType"		StringValue="RAW DATA"
	Element="DirectoryRecordType"		StringValue="REGISTRATION"
	Element="DirectoryRecordType"		StringValue="FIDUCIAL"
	Element="DirectoryRecordType"		StringValue="ENCAP DOC"
	Element="DirectoryRecordType"		StringValue="HL7 STRUC DOC"
	Element="DirectoryRecordType"		StringValue="HANGING PROTOCOL"
	Element="DirectoryRecordType"		StringValue="VALUE MAP"
	Element="DirectoryRecordType"		StringValue="STEREOMETRIC"
ConditionEnd

Condition="DirectoryRecordTypeIsPatient"
	Element="DirectoryRecordType"		StringValue="PATIENT"
ConditionEnd

Condition="DirectoryRecordTypeIsStudy"
	Element="DirectoryRecordType"		StringValue="STUDY"
ConditionEnd

Condition="DirectoryRecordTypeIsSeries"
	Element="DirectoryRecordType"		StringValue="SERIES"
ConditionEnd

Condition="DirectoryRecordTypeIsImage"
	Element="DirectoryRecordType"		StringValue="IMAGE"
ConditionEnd

Condition="DirectoryRecordTypeIsOverlay"
	Element="DirectoryRecordType"		StringValue="OVERLAY"
ConditionEnd

Condition="DirectoryRecordTypeIsModalityLUT"
	Element="DirectoryRecordType"		StringValue="MODALITY LUT"
ConditionEnd

Condition="DirectoryRecordTypeIsVOILUT"
	Element="DirectoryRecordType"		StringValue="VOI LUT"
ConditionEnd

Condition="DirectoryRecordTypeIsCurve"
	Element="DirectoryRecordType"		StringValue="CURVE"
ConditionEnd

Condition="DirectoryRecordTypeIsTopic"
	Element="DirectoryRecordType"		StringValue="TOPIC"
ConditionEnd

Condition="DirectoryRecordTypeIsVisit"
	Element="DirectoryRecordType"		StringValue="VISIT"
ConditionEnd

Condition="DirectoryRecordTypeIsResults"
	Element="DirectoryRecordType"		StringValue="RESULTS"
ConditionEnd

Condition="DirectoryRecordTypeIsInterpretation"
	Element="DirectoryRecordType"		StringValue="INTERPRETATION"
ConditionEnd

Condition="DirectoryRecordTypeIsStudyComponent"
	Element="DirectoryRecordType"		StringValue="STUDY COMPONENT"
ConditionEnd

Condition="DirectoryRecordTypeIsPrintQueue"
	Element="DirectoryRecordType"		StringValue="PRINT QUEUE"
ConditionEnd

Condition="DirectoryRecordTypeIsFilmSession"
	Element="DirectoryRecordType"		StringValue="FILM SESSION"
ConditionEnd

Condition="DirectoryRecordTypeIsFilmBox"
	Element="DirectoryRecordType"		StringValue="FILM BOX"
ConditionEnd

Condition="DirectoryRecordTypeIsImageBox"
	Element="DirectoryRecordType"		StringValue="IMAGE BOX"
ConditionEnd

Condition="DirectoryRecordTypeIsStoredPrint"
	Element="DirectoryRecordType"		StringValue="STORED PRINT"
ConditionEnd

Condition="DirectoryRecordTypeIsRTDose"
	Element="DirectoryRecordType"		StringValue="RT DOSE"
ConditionEnd

Condition="DirectoryRecordTypeIsRTStructureSet"
	Element="DirectoryRecordType"		StringValue="RT STRUCTURE SET"
ConditionEnd

Condition="DirectoryRecordTypeIsRTPlan"
	Element="DirectoryRecordType"		StringValue="RT PLAN"
ConditionEnd

Condition="DirectoryRecordTypeIsRTTreatmentRecord"
	Element="DirectoryRecordType"		StringValue="RT TREAT RECORD"
ConditionEnd

Condition="DirectoryRecordTypeIsPresentation"
	Element="DirectoryRecordType"		StringValue="PRESENTATION"
ConditionEnd

Condition="DirectoryRecordTypeIsWaveform"
	Element="DirectoryRecordType"		StringValue="WAVEFORM"
ConditionEnd

Condition="DirectoryRecordTypeIsSRDocument"
	Element="DirectoryRecordType"		StringValue="SR DOCUMENT"
ConditionEnd

Condition="DirectoryRecordTypeIsKeyObjectDocument"
	Element="DirectoryRecordType"		StringValue="KEY OBJECT DOC"
ConditionEnd

Condition="DirectoryRecordTypeIsSpectroscopy"
	Element="DirectoryRecordType"		StringValue="SPECTROSCOPY"
ConditionEnd

Condition="DirectoryRecordTypeIsRawData"
	Element="DirectoryRecordType"		StringValue="RAW DATA"
ConditionEnd

Condition="DirectoryRecordTypeIsRegistration"
	Element="DirectoryRecordType"		StringValue="REGISTRATION"
ConditionEnd

Condition="DirectoryRecordTypeIsFiducial"
	Element="DirectoryRecordType"		StringValue="FIDUCIAL"
ConditionEnd

Condition="DirectoryRecordTypeIsEncapsulatedDocument"
	Element="DirectoryRecordType"		StringValue="ENCAP DOC"
ConditionEnd

Condition="DirectoryRecordTypeIsHL7StructuredDocument"
	Element="DirectoryRecordType"		StringValue="HL7 STRUC DOC"
ConditionEnd

Condition="DirectoryRecordTypeIsHangingProtocol"
	Element="DirectoryRecordType"		StringValue="HANGING PROTOCOL"
ConditionEnd

Condition="DirectoryRecordTypeIsRealWorldValueMapping"
	Element="DirectoryRecordType"		StringValue="VALUE MAP"
ConditionEnd

Condition="DirectoryRecordTypeIsStereometricRelationship"
	Element="DirectoryRecordType"		StringValue="STEREOMETRIC"
ConditionEnd

Condition="DirectoryRecordTypeIsPrivate"
	Element="DirectoryRecordType"		StringValue="PRIVATE"
ConditionEnd

Condition="DirectoryRecordTypeIsMRDR"
	Element="DirectoryRecordType"		StringValue="MRDR"
ConditionEnd

Condition="ReferencedSOPInstanceUIDInFileIsNotPresent"
	Element="ReferencedSOPInstanceUIDInFile"	Modifier="Not" ElementPresent=""
ConditionEnd

# for RT

Condition="NeedModuleRTPrescription"
	Element="PrescriptionDescription"	ElementPresent=""
	Element="DoseReferenceSequence"		ElementPresent=""
ConditionEnd

Condition="NeedModuleRTToleranceTables"
	Element="ToleranceTableSequence"	ElementPresent=""
ConditionEnd

Condition="NeedModuleRTIonToleranceTables"
	Element="IonToleranceTableSequence"	ElementPresent=""
ConditionEnd

Condition="NeedModuleRTPatientSetup"
	Element="PatientSetupSequence"		ElementPresent=""
ConditionEnd

Condition="NeedModuleRTFractionScheme"
	Element="FractionGroupSequence"		ElementPresent=""
ConditionEnd

Condition="NeedRTBeams"
	Element="FractionGroupSequence"		ElementPresent=""
	Element="FractionGroupSequence[0]NumberOfBeams"			Operator="And" ElementPresent=""
	Element="FractionGroupSequence[0]NumberOfBeams"			Operator="And" ValueSelector="0" BinaryValue="> 0"
# Below is for presence of module, above is its requirement to be present ...
	Element="BeamSequence"			ElementPresent=""
ConditionEnd

Condition="NeedRTIonBeams"
	Element="FractionGroupSequence"		ElementPresent=""
	Element="FractionGroupSequence[0]NumberOfBeams"			Operator="And" ElementPresent=""
	Element="FractionGroupSequence[0]NumberOfBeams"			Operator="And" ValueSelector="0" BinaryValue="> 0"
# Below is for presence of module, above is its requirement to be present ...
	Element="IonBeamSequence"			ElementPresent=""
ConditionEnd

Condition="NeedRTBrachyApplicationSetups"
	Element="FractionGroupSequence"			ElementPresent=""
	Element="NumberOfBrachyApplicationSetups"	Operator="And" ElementPresent=""
	Element="NumberOfBrachyApplicationSetups"	Operator="And" ValueSelector="0" BinaryValue="> 0"
# Below is for presence of module, above is its requirement to be present ...
	Element="BrachyTreatmentTechnique"		ElementPresent=""
	Element="BrachyTreatmentType"			ElementPresent=""
	Element="TreatmentMachineSequence"		ElementPresent=""
	Element="ApplicationSetupSequence"		ElementPresent=""
ConditionEnd

Condition="DoseDataGridbased"
	Element="InstanceNumber"		ElementPresent=""
	Element="PixelSpacing"			ElementPresent=""
	Element="ImageOrientationPatient"	ElementPresent=""
	Element="ImagePositionPatient"		ElementPresent=""
	Element="SliceThickness"		ElementPresent=""
	Element="SamplesPerPixel"		ElementPresent=""
	Element="PhotometricInterpretation"	ElementPresent=""
	Element="Rows"				ElementPresent=""
	Element="Columns"			ElementPresent=""
	Element="BitsAllocated"			ElementPresent=""
	Element="BitsStored"			ElementPresent=""
	Element="HighBit"			ElementPresent=""
	Element="PixelRepresentation"		ElementPresent=""
	Element="PixelData"			ElementPresent=""
ConditionEnd

Condition="DoseDataGridbasedAndNeedModuleMultiFrame"
	Element="InstanceNumber"		ElementPresent=""
	Element="PixelSpacing"			ElementPresent=""
	Element="ImageOrientationPatient"	ElementPresent=""
	Element="ImagePositionPatient"		ElementPresent=""
	Element="SliceThickness"		ElementPresent=""
	Element="SamplesPerPixel"		ElementPresent=""
	Element="PhotometricInterpretation"	ElementPresent=""
	Element="Rows"				ElementPresent=""
	Element="Columns"			ElementPresent=""
	Element="BitsAllocated"			ElementPresent=""
	Element="BitsStored"			ElementPresent=""
	Element="HighBit"			ElementPresent=""
	Element="PixelRepresentation"		ElementPresent=""
	Element="PixelData"			ElementPresent=""
	Element="NumberOfFrames"		ElementPresent=""
	Element="NumberOfFrames"		Operator="And" ValueSelector="0" BinaryValue="> 1"
ConditionEnd

Condition="DoseDataPointsOrCurves"
	Element="StructureSetLabel"		ElementPresent=""
	Element="ROIContourSequence"		ElementPresent=""
	Element="RTDoseROISequence"		ElementPresent=""
ConditionEnd

Condition="NeedModuleRTDVH"
	Element="ReferencedStructureSetSequence"	ElementPresent=""
	Element="DVHNormalizationPoint"			ElementPresent=""
	Element="DVHNormalizationDoseValue"		ElementPresent=""
	Element="DVHSequence"				ElementPresent=""
ConditionEnd

Condition="ImageTypeValue3SimulatorOrPortal"
	Element="ImageType"		ValueSelector="2"	StringValue="SIMULATOR"
	Element="ImageType"		ValueSelector="2"	StringValue="PORTAL"
ConditionEnd

Condition="ImageTypeValue3SimulatorOrPortalOrRadiograph"
	Element="ImageType"		ValueSelector="2"	StringValue="SIMULATOR"
	Element="ImageType"		ValueSelector="2"	StringValue="PORTAL"
	Element="ImageType"		ValueSelector="2"	StringValue="RADIOGRAPH"
ConditionEnd

Condition="ImageTypeValue3SimulatorOrRadiograph"
	Element="ImageType"		ValueSelector="2"	StringValue="SIMULATOR"
	Element="ImageType"		ValueSelector="2"	StringValue="RADIOGRAPH"
ConditionEnd

Condition="ImageTypeValue3Portal"
	Element="ImageType"		ValueSelector="2"	StringValue="PORTAL"
ConditionEnd

Condition="ImageTypeValue3Fluence"
	Element="ImageType"		ValueSelector="2"	StringValue="FLUENCE"
ConditionEnd

Condition="RTImagePlaneIsNonNormal"
	Element="RTImagePlane"		StringValue="NON_NORMAL"
ConditionEnd

Condition="NeedExposureSequenceReferencedFrameNumber"
# not strictly correct ... doesn't check for more than one item in ExposureSequence
	Element="NumberOfFrames"		ElementPresent=""
	Element="NumberOfFrames"		Operator="And" ValueSelector="0" BinaryValue="> 1"
ConditionEnd

Condition="RTBeamLimitingDeviceTypeMLCXOrMLCY"
	Element="RTBeamLimitingDeviceType"	StringValue="MLCX"
	Element="RTBeamLimitingDeviceType"	StringValue="MLCY"
ConditionEnd

Condition="NumberOfBlocksNotZero"
	Element="NumberOfBlocks"		ElementPresent=""
	Element="NumberOfBlocks"		Operator="And" ValueSelector="0" BinaryValue="> 0"
ConditionEnd

Condition="NumberOfRangeShiftersNotZero"
	Element="NumberOfRangeShifters"		ElementPresent=""
	Element="NumberOfRangeShifters"		Operator="And" ValueSelector="0" BinaryValue="> 0"
ConditionEnd

Condition="NumberOfLateralSpreadingDevicesNotZero"
	Element="NumberOfLateralSpreadingDevices"		ElementPresent=""
	Element="NumberOfLateralSpreadingDevices"		Operator="And" ValueSelector="0" BinaryValue="> 0"
ConditionEnd

Condition="NumberOfRangeModulatorsNotZero"
	Element="NumberOfRangeModulators"		ElementPresent=""
	Element="NumberOfRangeModulators"		Operator="And" ValueSelector="0" BinaryValue="> 0"
ConditionEnd

Condition="NumberOfBeamsNotZero"
	Element="FractionGroupSequence[0]NumberOfBeams"			ElementPresent=""
	Element="FractionGroupSequence[0]NumberOfBeams"			Operator="And" ValueSelector="0" BinaryValue="> 0"
ConditionEnd

Condition="NumberOfBrachyApplicationSetupsNotZero"
	Element="NumberOfBrachyApplicationSetups"	ElementPresent=""
	Element="NumberOfBrachyApplicationSetups"	Operator="And" ValueSelector="0" BinaryValue="> 0"
ConditionEnd

Condition="NumberOfWedgesNotZero"
	Element="NumberOfWedges"			ElementPresent=""
	Element="NumberOfWedges"			Operator="And" ValueSelector="0" BinaryValue="> 0"
ConditionEnd

Condition="NumberOfCompensatorsNotZero"
	Element="NumberOfCompensators"			ElementPresent=""
	Element="NumberOfCompensators"			Operator="And" ValueSelector="0" BinaryValue="> 0"
ConditionEnd

Condition="NeedSourceToCompensatorDistance"
	Element="MaterialID"				ElementPresent=""
	Element="MaterialID"				Operator="And" ValuePresent=""
	Element="CompensatorMountingPosition"		Operator="And" ElementPresent=""
	Element="CompensatorMountingPosition"		Operator="And" StringValue="DOUBLE_SIDED"
ConditionEnd

Condition="NeedIsocenterToCompensatorDistance"
	Element="MaterialID"				ElementPresent=""
	Element="MaterialID"				Operator="And" ValuePresent=""
	Element="CompensatorMountingPosition"		Operator="And" ElementPresent=""
	Element="CompensatorMountingPosition"		Operator="And" StringValue="DOUBLE_SIDED"
ConditionEnd

Condition="NumberOfBoliNotZero"
	Element="NumberOfBoli"			ElementPresent=""
	Element="NumberOfBoli"			Operator="And" ValueSelector="0" BinaryValue="> 0"
ConditionEnd

Condition="PixelDataPresent"
	Element="PixelData"			ElementPresent=""
ConditionEnd

Condition="DoseSummationTypePlanOrFractionOrBeamOrBrachyOrControlPoint"
	Element="DoseSummationType"		StringValueFromRootAttribute="PLAN"
	Element="DoseSummationType"		StringValueFromRootAttribute="FRACTION"
	Element="DoseSummationType"		StringValueFromRootAttribute="BEAM"
	Element="DoseSummationType"		StringValueFromRootAttribute="CONTROL_POINT"
	Element="DoseSummationType"		StringValueFromRootAttribute="BRACHY"
ConditionEnd

Condition="DoseSummationTypeFractionOrBeamOrBrachyOrControlPoint"
	Element="DoseSummationType"		StringValueFromRootAttribute="FRACTION"
	Element="DoseSummationType"		StringValueFromRootAttribute="BEAM"
	Element="DoseSummationType"		StringValueFromRootAttribute="CONTROL_POINT"
	Element="DoseSummationType"		StringValueFromRootAttribute="BRACHY"
ConditionEnd

Condition="DoseSummationTypeBeamOrControlPoint"
	Element="DoseSummationType"		StringValueFromRootAttribute="BEAM"
	Element="DoseSummationType"		StringValueFromRootAttribute="CONTROL_POINT"
ConditionEnd

Condition="DoseSummationTypeControlPoint"
	Element="DoseSummationType"		StringValueFromRootAttribute="CONTROL_POINT"
ConditionEnd

Condition="DoseSummationTypeBrachy"
	Element="DoseSummationType"		StringValueFromRootAttribute="BRACHY"
ConditionEnd

Condition="NeedGridFrameOffsetVector"
	Element="FrameIncrementPointer"		ValueSelector="*"	TagValue="0x3004,0x000C"
ConditionEnd

Condition="RTPlanGeometryIsPatient"
	Element="RTPlanGeometry"		StringValue="PATIENT"
ConditionEnd

Condition="PlanIntentIsVerification"
	Element="PlanIntent"		StringValueFromRootAttribute="VERIFICATION"
ConditionEnd

Condition="DoseReferenceStructureTypePointOrVolume"
	Element="DoseReferenceStructureType"	StringValue="POINT"
	Element="DoseReferenceStructureType"	StringValue="VOLUME"
ConditionEnd

Condition="DoseReferenceStructureTypeCoordinates"
	Element="DoseReferenceStructureType"	StringValue="COORDINATES"
ConditionEnd

Condition="PatientAdditionalPositionNotPresent"
	Element="PatientAdditionalPosition"	Modifier="Not" ElementPresent=""
ConditionEnd

Condition="PatientPositionNotPresent"
	Element="PatientPosition"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="BrachyTreatmentTypePDR"
	Element="BrachyTreatmentType"		StringValue="PDR"
ConditionEnd

Condition="SourceApplicatorNumberPresent"
	Element="SourceApplicatorNumber"	ElementPresent=""
ConditionEnd

Condition="SourceMovementTypeStepwise"
	Element="SourceMovementType"		StringValue="STEPWISE"
ConditionEnd

Condition="TransferTubeNumberNotNull"
	Element="TransferTubeNumber"		ElementPresent=""
	Element="TransferTubeNumber"		Operator="And" ValuePresent=""
ConditionEnd

Condition="ApprovalStatusApprovedOrRejected"
	Element="ApprovalStatus"		StringValue="APPROVED"
	Element="ApprovalStatus"		StringValue="REJECTED"
ConditionEnd

Condition="NeedReferencedFrameNumberInContourImageSequence"
# too difficult to check real world condition
ConditionEnd

# RT Treatment Record

Condition="NeedModuleRTTreatmentSummaryRecord"
	Element="CurrentTreatmentStatus"		ElementPresent=""
ConditionEnd

Condition="NeedModuleCalculatedDoseReferenceRecord"
	Element="CalculatedDoseReferenceSequence"	ElementPresent=""
ConditionEnd

Condition="NeedModuleMeasuredDoseReferenceRecord"
	Element="MeasuredDoseReferenceSequence"		ElementPresent=""
ConditionEnd

Condition="MeasuredDoseReferenceNumberNotPresent"
	Element="MeasuredDoseReferenceNumber"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ReferencedMeasuredDoseReferenceNumberNotPresent"
	Element="ReferencedMeasuredDoseReferenceNumber"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ReferencedDoseReferenceNumberNotPresent"
	Element="ReferencedDoseReferenceNumber"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ReferencedCalculatedDoseReferenceNumberNotPresent"
	Element="ReferencedCalculatedDoseReferenceNumber"	Modifier="Not" ElementPresent=""
ConditionEnd

Condition="CalculatedDoseReferenceNumberNotPresent"
	Element="CalculatedDoseReferenceNumber"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="NominalBeamEnergyIsPresent"
	Element="NominalBeamEnergy"				ElementPresent=""
ConditionEnd

Condition="BrachyTreatmentTypeIsPDR"
	Element="BrachyTreatmentType"				StringValue="PDR"
ConditionEnd

Condition="TransferTubeNumberIsNotEmpty"
	Element="TransferTubeNumber"				ValuePresent=""
ConditionEnd

Condition="SourceIsNotGammaEmitter"
	Element="ReferenceAirKermaRate"				ValueSelector="0" BinaryValue="== 0"
ConditionEnd

# PET

Condition="NeedModulePETMultigatedAcquisition"
	Element="SeriesType"				ValueSelector="0"	StringValue="GATED"
ConditionEnd

Condition="PETSeriesType2Reprojection"
	Element="SeriesType"				ValueSelector="1"	StringValue="REPROJECTION"
ConditionEnd

Condition="PETSeriesType1Gated"
	Element="SeriesType"				ValueSelector="0"	StringValue="GATED"
ConditionEnd

Condition="PETSeriesType1Dynamic"
	Element="SeriesType"				ValueSelector="0"	StringValue="DYNAMIC"
ConditionEnd

Condition="PETSeriesType1GatedAndBeatRejection"
	Element="SeriesType"				ValueSelector="0"	StringValue="DYNAMIC"
	Element="BeatRejectionFlag"			Operator="And" ElementPresent=""
	Element="BeatRejectionFlag"			Operator="And" StringValue="Y"
ConditionEnd

Condition="DecayCorrectionNotNone"
	Element="DecayCorrection"			ElementPresent=""
	Element="DecayCorrection"			Operator="And" Modifier="Not" StringValue="NONE"
ConditionEnd

Condition="TypeOfDataIsBloodSample"
	Element="TypeOfData"				ElementPresent=""
	Element="TypeOfData"				Operator="And" StringValue="BLDSMPL"
ConditionEnd

Condition="AxisUnitsIncludesCounts"
	Element="TypeOfData"				StringValue="CNTS"
	Element="TypeOfData"				StringValue="CPS"
ConditionEnd

# DX Letter Ballot stuff ...

#
# note that ExposureInmAs, XRayTubeCurrentInmA and ExposureTimeInms are not in the Module, but used here to trigger checker for their (unwanted) presence
#
Condition="NeedModuleXRayAcquisitionDose"
	Element="KVP"						ElementPresent=""
	
	Element="XRayTubeCurrent"			ElementPresent=""
	Element="XRayTubeCurrentInuA"		ElementPresent=""
	Element="XRayTubeCurrentInmA"		ElementPresent=""
	
	Element="ExposureTime"				ElementPresent=""
	Element="ExposureTimeInuS"			ElementPresent=""
	Element="ExposureTimeInms"			ElementPresent=""
	
	Element="Exposure"					ElementPresent=""
	Element="ExposureInuAs"				ElementPresent=""
	Element="ExposureInmAs"				ElementPresent=""
	
	Element="DistanceSourceToDetector"	ElementPresent=""
	Element="DistanceSourceToPatient"	ElementPresent=""
	Element="ImageAndFluoroscopyAreaDoseProduct"		ElementPresent=""
	Element="BodyPartThickness"		ElementPresent=""
	Element="EntranceDose"			ElementPresent=""
	Element="ExposedArea"			ElementPresent=""
	Element="DistanceSourceToEntrance"	ElementPresent=""
	Element="CommentsOnRadiationDose"	ElementPresent=""
	Element="XRayOutput"			ElementPresent=""
	Element="HalfValueLayer"		ElementPresent=""
	Element="OrganDose"			ElementPresent=""
	Element="OrganExposed"			ElementPresent=""
	Element="AnodeTargetMaterial"		ElementPresent=""
	Element="FilterMaterial"		ElementPresent=""
	Element="FilterThicknessMaximum"	ElementPresent=""
	Element="FilterThicknessMinimum"	ElementPresent=""
	Element="RectificationType"		ElementPresent=""
ConditionEnd

#
# note that ExposureInmAs, XRayTubeCurrentInmA and ExposureTimeInms are not in the Module, but used here to trigger checker for their (unwanted) presence
#
Condition="NeedModuleXRayGeneration"
	Element="KVP"						ElementPresent=""
	
	Element="XRayTubeCurrent"			ElementPresent=""
	Element="XRayTubeCurrentInuA"		ElementPresent=""
	Element="XRayTubeCurrentInmA"		ElementPresent=""
	
	Element="ExposureTime"				ElementPresent=""
	Element="ExposureTimeInuS"			ElementPresent=""
	Element="ExposureTimeInms"			ElementPresent=""
	
	Element="Exposure"					ElementPresent=""
	Element="ExposureInuAs"				ElementPresent=""
	Element="ExposureInmAs"				ElementPresent=""
	
	Element="ExposureControlMode"				ElementPresent=""
	Element="ExposureControlModeDescription"	ElementPresent=""
	Element="ExposureStatus"					ElementPresent=""
	Element="PhototimerSetting"					ElementPresent=""
	Element="FocalSpot"							ElementPresent=""
	Element="AnodeTargetMaterial"				ElementPresent=""
	Element="RectificationType"					ElementPresent=""
ConditionEnd

Condition="XRayTubeCurrentInmAIsPresentAndOthersAreNot"
	Element="XRayTubeCurrentInmA"				ElementPresent=""
	Element="XRayTubeCurrent"					Operator="And" Modifier="Not" ValuePresent=""
	Element="XRayTubeCurrentInuA"				Operator="And" Modifier="Not" ValuePresent=""
ConditionEnd

Condition="ExposureTimeInmsIsPresentAndOthersAreNot"
	Element="ExposureTimeInms"					ElementPresent=""
	Element="ExposureTime"						Operator="And" Modifier="Not" ValuePresent=""
	Element="ExposureTimeInuS"					Operator="And" Modifier="Not" ValuePresent=""
ConditionEnd

Condition="ExposureInmAsIsPresentAndOthersAreNot"
	Element="ExposureInmAs"						ElementPresent=""
	Element="Exposure"							Operator="And" Modifier="Not" ValuePresent=""
	Element="ExposureInuAs"						Operator="And" Modifier="Not" ValuePresent=""
ConditionEnd

Condition="NeedModuleXRayFiltration"
	Element="FilterType"			ElementPresent=""
	Element="FilterMaterial"		ElementPresent=""
	Element="FilterThicknessMaximum"	ElementPresent=""
	Element="FilterThicknessMinimum"	ElementPresent=""
ConditionEnd

# strategy here is any mandatory element and any optional that isn't used elsewhere in the IOD ...
Condition="NeedModuleDXPositioning"
	Element="ProjectionEponymousNameCodeSequence"		ElementPresent=""
	Element="PatientPosition"		ElementPresent=""
	Element="ViewPosition"		ElementPresent=""
	Element="ViewCodeSequence"		ElementPresent=""
	Element="ViewModifierCodeSequence"		ElementPresent=""
	Element="PatientOrientationCodeSequence"		ElementPresent=""
	Element="EstimatedRadiographicMagnificationFactor"	ElementPresent=""
	Element="PositionerType"				ElementPresent=""
	Element="DetectorPrimaryAngle"				ElementPresent=""
	Element="DetectorSecondaryAngle""			ElementPresent=""
	Element="ColumnAngulation"				ElementPresent=""
	Element="TableAngle"					ElementPresent=""
ConditionEnd

Condition="NeedModuleXRayGrid"
	Element="Grid"				ElementPresent=""
	Element="GridAbsorbingMaterial"		ElementPresent=""
	Element="GridSpacingMaterial"		ElementPresent=""
	Element="GridThickness"			ElementPresent=""
	Element="GridPitch"			ElementPresent=""
	Element="GridAspectRatio"		ElementPresent=""
	Element="GridPeriod"			ElementPresent=""
	Element="GridFocalDistance"		ElementPresent=""
ConditionEnd

Condition="DXNeedModuleVOILUT"
	Element="PresentationIntentType"	StringValue="FOR PRESENTATION"
ConditionEnd

Condition="NeedModuleImageHistogram"
	Element="HistogramSequence"		ElementPresent=""
ConditionEnd

Condition="ImageLateralityNotSent"
	Element="ImageLaterality"	Modifier="Not" ElementPresent=""
ConditionEnd

Condition="SeriesNeedReferencedPerformedProcedureStepSequence"
	# real world - Modality or General Purpose Performed Procedure Step SOP Class supported, so just check if sequence present anyway
	Element="ReferencedPerformedProcedureStepSequence"		ElementPresent=""
ConditionEnd

Condition="CodingSchemeDesignatorisSNM3"
	Element="CodingSchemeDesignator"	StringValue="SNM3"
ConditionEnd

Condition="ForPresentationAndWindowCenterNotPresent"
	Element="PresentationIntentType"	StringValue="FOR PRESENTATION"
	Element="WindowCenter"			Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ForPresentationAndVOILUTSequenceNotPresent"
	Element="PresentationIntentType"	StringValue="FOR PRESENTATION"
	Element="VOILUTSequence"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="FieldOfViewRotationOrFieldOfViewHorizontalFlipPresent"
	Element="FieldOfViewRotation"		ElementPresent=""
	Element="FieldOfViewHorizontalFlip"	ElementPresent=""
ConditionEnd

Condition="FieldOfViewRotationPresent"
	Element="FieldOfViewRotation"		ElementPresent=""
ConditionEnd

Condition="FieldOfViewHorizontalFlipPresent"
	Element="FieldOfViewHorizontalFlip"	ElementPresent=""
ConditionEnd

Condition="NoPrimaryAnatomicStructureSequence"
	Element="PrimaryAnatomicStructureSequence"	Modifier="Not" ElementPresentAbove=""
ConditionEnd

Condition="NoAnatomicRegionModifierSequence"
	Element="AnatomicRegionModifierSequence"	Modifier="Not" ElementPresentWithin="AnatomicRegionSequence"
ConditionEnd

# for softcopy presentation state ...

Condition="NeedModuleSoftcopyVOILUT"
	Element="SoftcopyVOILUTSequence"	ElementPresent=""
ConditionEnd

Condition="RequireTextObjectSequence"
	Element="TextObjectSequence"		ElementPresent=""
	Element="GraphicObjectSequence"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="RequireGraphicObjectSequence"
	Element="GraphicObjectSequence"		ElementPresent=""
	Element="TextObjectSequence"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="BoundingBoxTopLeftHandCornerPresent"
	Element="BoundingBoxTopLeftHandCorner"		ElementPresent=""
ConditionEnd

Condition="BoundingBoxTopLeftHandCornerOrBottomRightHandCornerPresent"
	Element="BoundingBoxTopLeftHandCorner"		ElementPresent=""
	Element="BoundingBoxBottomRightHandCorner"		ElementPresent=""
ConditionEnd

Condition="BoundingBoxTopLeftHandCornerOrBottomRightHandCornerNotPresent"
	Element="BoundingBoxTopLeftHandCorner"		Modifier="Not" ElementPresent=""
	Element="BoundingBoxBottomRightHandCorner"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="AnchorPointNeeded"
	Element="BoundingBoxTopLeftHandCorner"		Modifier="Not" ElementPresent=""
	Element="BoundingBoxBottomRightHandCorner"		Operator="And" Modifier="Not" ElementPresent=""
	Element="AnchorPoint"			ElementPresent=""
ConditionEnd

Condition="AnchorPointPresent"
	Element="AnchorPoint"			ElementPresent=""
ConditionEnd

Condition="AnchorPointNotPresent"
	Element="AnchorPoint"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="BoundingBoxNeeded"
	Element="BoundingBoxTopLeftHandCorner"		ElementPresent=""
	Element="BoundingBoxBottomRightHandCorner"		ElementPresent=""
	Element="AnchorPoint"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="PresentationLUTShapeNotPresent"
	Element="PresentationLUTShape"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="PresentationLUTSequenceNotPresent"
	Element="PresentationLUTSequence"	Modifier="Not" ElementPresent=""
ConditionEnd

Condition="DisplayOrBitmapDisplayShutterModulePresent"
	Element="ShutterShape"					ElementPresent=""
	Element="ShutterLeftVerticalEdge"		ElementPresent=""
	Element="ShutterRightVerticalEdge"		ElementPresent=""
	Element="ShutterUpperHorizontalEdge"	ElementPresent=""
	Element="ShutterLowerHorizontalEdge"	ElementPresent=""
	Element="CenterOfCircularShutter"		ElementPresent=""
	Element="RadiusOfCircularShutter"		ElementPresent=""
	Element="VerticesOfPolygonalShutter"	ElementPresent=""
	Element="ShutterPresentationValue"		ElementPresent=""
	Element="ShutterOverlayGroup"			ElementPresent=""
ConditionEnd

# would like to detect ShutterOverlayGroup as well, but cannot do boolean expression :(
Condition="DisplayOrBitmapDisplayShutterModulePresentAndNotGrayscaleSoftcopyPresentationState"
	Element="SOPClassUID"					Modifier="Not" StringConstant="GrayscaleSoftcopyPresentationStateStorageSOPClassUID"
	Element="ShutterShape"					Operator="And"	ElementPresent=""
ConditionEnd

Condition="MaskModulePresent"
	Element="MaskSubtractionSequence"	ElementPresent=""
	Element="RecommendedViewingMode"	ElementPresent=""
ConditionEnd

Condition="NeedModuleBitmapDisplayShutter"
	Element="ShutterShape"			StringValue="BITMAP"
ConditionEnd

Condition="NeedModuleOverlayActivation"
	Element="OverlayActivationLayer"	ElementPresent=""
	Element="CurveActivationLayer"		ElementPresent=""
ConditionEnd

Condition="NeedModuleGraphicAnnotation"
	Element="GraphicAnnotationSequence"	ElementPresent=""
ConditionEnd

Condition="NeedModuleSpatialTransformation"
	Element="ImageRotation"			ElementPresent=""
	Element="ImageHorizontalFlip"		ElementPresent=""
ConditionEnd

Condition="NeedModuleGraphicLayer"
	Element="GraphicLayerSequence"		ElementPresent=""
ConditionEnd

Condition="ImageTypeValue3StereoLOrR"
	Element="ImageType"		ValueSelector="2"	StringValue="STEREO L"
	Element="ImageType"		ValueSelector="2"	StringValue="STEREO R"
ConditionEnd

Condition="RequirePresentationPixelSpacing"
	Element="PresentationSizeMode"		StringValue="TRUE SIZE"
	Element="PresentationPixelAspectRatio"	Modifier="Not" ElementPresent=""
ConditionEnd

Condition="RequirePresentationPixelAspectRatio"
	Element="PresentationPixelSpacing"	Modifier="Not" ElementPresent=""
ConditionEnd

Condition="RequirePresentationPixelMagnificationRatio"
	Element="PresentationSizeMode"		StringValue="MAGNIFY"
ConditionEnd

# for structured reporting ...

Condition="VerificationFlagIsVerified"
	Element="VerificationFlag"		StringValue="VERIFIED"
ConditionEnd

Condition="TemplateExtensionFlagIsY"
	Element="TemplateExtensionFlag"		StringValue="Y"
ConditionEnd

Condition="ValueTypeIsText"
	Element="ValueType"			StringValue="TEXT"
ConditionEnd

Condition="ValueTypeIsNumeric"
	Element="ValueType"			StringValue="NUM"
ConditionEnd

Condition="ValueTypeIsCode"
	Element="ValueType"			StringValue="CODE"
ConditionEnd

Condition="ValueTypeIsDateTime"
	Element="ValueType"			StringValue="DATETIME"
ConditionEnd

Condition="ValueTypeIsDate"
	Element="ValueType"			StringValue="DATE"
ConditionEnd

Condition="ValueTypeIsTime"
	Element="ValueType"			StringValue="TIME"
ConditionEnd

Condition="ValueTypeIsPersonName"
	Element="ValueType"			StringValue="PNAME"
ConditionEnd

Condition="ValueTypeIsUID"
	Element="ValueType"			StringValue="UIDREF"
ConditionEnd

Condition="NeedConceptName"
	Element="ValueType"			StringValue="TEXT"
	Element="ValueType"			StringValue="NUM"
	Element="ValueType"			StringValue="CODE"
	Element="ValueType"			StringValue="DATETIME"
	Element="ValueType"			StringValue="DATE"
	Element="ValueType"			StringValue="TIME"
	Element="ValueType"			StringValue="PNAME"
	Element="ValueType"			StringValue="UIDREF"
#	Element="ValueType"			StringValue="CONTAINER"		# not quite right ... "and a heading is present, or this is the Root Content Item"
#	Element="ValueType"			StringValue="COMPOSITE"		# not quite right ... "and the Purpose of Reference is conveyed in the Concept Name" 
#	Element="ValueType"			StringValue="IMAGE"			# not quite right ... "and the Purpose of Reference is conveyed in the Concept Name"
#	Element="ValueType"			StringValue="WAVEFORM"		# not quite right ... "and the Purpose of Reference is conveyed in the Concept Name"
#	Element="ValueType"			StringValue="SCOORD"		# not quite right ... "and the Purpose of Reference is conveyed in the Concept Name"
#	Element="ValueType"			StringValue="TCOORD"		# not quite right ... "and the Purpose of Reference is conveyed in the Concept Name"
ConditionEnd

Condition="ValueTypeIsTextOrNumericOrCodeOrDateTimeOrDateOrTimeOrPersonNameOrUIDOrContainer"
	Element="ValueType"			StringValue="TEXT"
	Element="ValueType"			StringValue="NUM"
	Element="ValueType"			StringValue="CODE"
	Element="ValueType"			StringValue="DATETIME"
	Element="ValueType"			StringValue="DATE"
	Element="ValueType"			StringValue="TIME"
	Element="ValueType"			StringValue="PNAME"
	Element="ValueType"			StringValue="UIDREF"
	Element="ValueType"			StringValue="CONTAINER"
ConditionEnd

Condition="ValueTypeIsImage"
	Element="ValueType"			StringValue="IMAGE"
ConditionEnd

Condition="ValueTypeIsWaveform"
	Element="ValueType"			StringValue="WAVEFORM"
ConditionEnd

Condition="ValueTypeIsComposite"
	Element="ValueType"			StringValue="COMPOSITE"
ConditionEnd

Condition="ValueTypeIsCompositeOrImageOrWaveform"
	Element="ValueType"			StringValue="COMPOSITE"
	Element="ValueType"			StringValue="IMAGE"
	Element="ValueType"			StringValue="WAVEFORM"
ConditionEnd

Condition="ValueTypeIsSpatialCoordinates"
	Element="ValueType"			StringValue="SCOORD"
ConditionEnd

Condition="ValueTypeIsTemporalCoordinates"
	Element="ValueType"			StringValue="TCOORD"
ConditionEnd

Condition="NoReferencedDateTimeOrReferencedTimeOffsets"
	Element="ReferencedDateTime"						Modifier="Not" ElementPresent=""
	Element="ReferencedTimeOffsets"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="NoReferencedDateTimeOrReferencedSamplePositions"
	Element="ReferencedSamplePositions"					Modifier="Not" ElementPresent=""
	Element="ReferencedDateTime"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="NoReferencedTimeOffsetsOrReferencedSamplePositions"
	Element="ReferencedSamplePositions"					Modifier="Not" ElementPresent=""
	Element="ReferencedTimeOffsets"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ValueTypeIsContainer"
	Element="ValueType"			StringValue="CONTAINER"
ConditionEnd

Condition="RelationshipByReference"
	Element="ValueType"				Modifier="Not" ElementPresent=""
	Element="ReferencedContentItemIdentifier"	Operator="And" ElementPresent=""
	Element="RelationshipType"			Operator="And" Modifier="Not" StringValue="CONTAINS"
ConditionEnd

Condition="RelationshipByValue"
	Element="ValueType"				ElementPresent=""
	Element="ReferencedContentItemIdentifier"	Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

# Waveform

Condition="NeedModuleWaveformAnnotation"
	Element="AnnotationSequence"		ElementPresent=""
ConditionEnd

Condition="ReallyNeedModuleSynchronization"
	Element="WaveformOriginality"			StringValue="ORIGINAL"
	Element="SynchronizationFrameOfReferenceUID"	ElementPresent=""
	Element="SynchronizationTrigger"		ElementPresent=""
	Element="TriggerSourceOrType"			ElementPresent=""
	Element="SynchronizationChannel"		ElementPresent=""
	Element="AcquisitionTimeSynchronized"		ElementPresent=""
	Element="TimeSource"				ElementPresent=""
	Element="TimeDistributionProtocol"		ElementPresent=""
ConditionEnd

Condition="NeedModuleSynchronizationForIVUS"
	Element="Modality"								StringValue="IVUS"
	Element="SynchronizationFrameOfReferenceUID"	ElementPresent=""
	Element="SynchronizationTrigger"				ElementPresent=""
	Element="TriggerSourceOrType"					ElementPresent=""
	Element="SynchronizationChannel"				ElementPresent=""
	Element="AcquisitionTimeSynchronized"			ElementPresent=""
	Element="TimeSource"							ElementPresent=""
	Element="TimeDistributionProtocol"				ElementPresent=""
ConditionEnd

Condition="NeedToCheckModuleSynchronization"
	Element="SynchronizationFrameOfReferenceUID"	ElementPresent=""
	Element="SynchronizationTrigger"		ElementPresent=""
	Element="TriggerSourceOrType"			ElementPresent=""
	Element="SynchronizationChannel"		ElementPresent=""
	Element="AcquisitionTimeSynchronized"		ElementPresent=""
	Element="TimeSource"				ElementPresent=""
	Element="TimeDistributionProtocol"		ElementPresent=""
ConditionEnd

Condition="AcquisitionTimeSynchronizedIsY"
	Element="AcquisitionTimeSynchronized"		StringValue="Y"
ConditionEnd

Condition="ChannelSensitivityIsPresent"
	Element="ChannelSensitivity"			ElementPresent=""
ConditionEnd

Condition="ChannelSampleSkewNotPresent"
	Element="ChannelSampleSkew"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ChannelTimeSkewNotPresent"
	Element="ChannelTimeSkew"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="AnnotationNeedsReferencedSamplePositions"
	Element="TemporalRangeType"		ElementPresent=""
	Element="ReferencedTimeOffsets"		Operator="And" Modifier="Not" ElementPresent=""
	Element="ReferencedDateTime"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="AnnotationNeedsReferencedTimeOffsets"
	Element="TemporalRangeType"		ElementPresent=""
	Element="ReferencedSamplePositions"	Operator="And" Modifier="Not" ElementPresent=""
	Element="ReferencedDateTime"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="AnnotationNeedsReferencedDateTime"
	Element="TemporalRangeType"		ElementPresent=""
	Element="ReferencedSamplePositions"	Operator="And" Modifier="Not" ElementPresent=""
	Element="ReferencedTimeOffsets"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

# for new SC objects ...

# Check that FrameIncrementPointer equals FrameTime or FrameTimeVector
#
Condition="NeedModuleCineForSC"
	Element="FrameIncrementPointer"		ValueSelector="*"	TagValue="0x0018,0x1063"
	Element="FrameIncrementPointer"		ValueSelector="*"	TagValue="0x0018,0x1065"
ConditionEnd

Condition="FrameIncrementPointerContainsPageNumberVector"
	Element="FrameIncrementPointer"		ValueSelector="*"	TagValue="0x0018,0x2001"
ConditionEnd

Condition="FrameIncrementPointerContainsFrameLabelVector"
	Element="FrameIncrementPointer"		ValueSelector="*"	TagValue="0x0018,0x2002"
ConditionEnd

Condition="FrameIncrementPointerContainsFramePrimaryAngleVector"
	Element="FrameIncrementPointer"		ValueSelector="*"	TagValue="0x0018,0x2003"
ConditionEnd

Condition="FrameIncrementPointerContainsFrameSecondaryAngleVector"
	Element="FrameIncrementPointer"		ValueSelector="*"	TagValue="0x0018,0x2004"
ConditionEnd

Condition="FrameIncrementPointerContainsSliceLocationVector"
	Element="FrameIncrementPointer"		ValueSelector="*"	TagValue="0x0018,0x2005"
ConditionEnd

Condition="FrameIncrementPointerContainsDisplayWindowLabelVector"
	Element="FrameIncrementPointer"		ValueSelector="*"	TagValue="0x0018,0x2006"
ConditionEnd

Condition="MonochromeNotBitmapPhotometricInterpretation"
	Element="PhotometricInterpretation"	StringValue="MONOCHROME2"
	Element="BitsStored"			Operator="And" ValueSelector="0" BinaryValue="> 1"
ConditionEnd

Condition="ConversionTypeDigitizedFilm"
	Element="ConversionType"		StringValue="DF"
ConditionEnd

Condition="NotSCMultiFrameOrNumberOfFramesGreaterThanOne"
	Element="SOPClassUID"			               Modifier="Not" StringValue="1.2.840.10008.5.1.4.1.1.7.1"
	Element="SOPClassUID"			Operator="And" Modifier="Not" StringValue="1.2.840.10008.5.1.4.1.1.7.2"
	Element="SOPClassUID"			Operator="And" Modifier="Not" StringValue="1.2.840.10008.5.1.4.1.1.7.3"
	Element="SOPClassUID"			Operator="And" Modifier="Not" StringValue="1.2.840.10008.5.1.4.1.1.7.4"
	Element="NumberOfFrames"		Operator="Or"  ValueSelector="0" BinaryValue="> 1"
ConditionEnd

Condition="ModalityIsIVUS"
	Element="Modality"			StringValue="IVUS"
ConditionEnd

Condition="IVUSAcquisitionIsMotor"
	Element="IVUSAcquisition"		StringValue="MOTOR_PULLBACK"
ConditionEnd

Condition="IVUSAcquisitionIsGated"
	Element="IVUSAcquisition"		StringValue="GATED_PULLBACK"
ConditionEnd

Condition="IVUSAcquisitionIsMotorOrGated"
	Element="IVUSAcquisition"		StringValue="MOTOR_PULLBACK"
	Element="IVUSAcquisition"		Operator="Or"  StringValue="GATED_PULLBACK"
ConditionEnd

Condition="CertifiedTimestampIsPresent"
	Element="CertifiedTimestamp"		ElementPresent=""
ConditionEnd

# for new MR objects ...

Condition="NeedModuleMRPulseSequence"
	Element="PulseSequenceName"				ElementPresent=""
	Element="MRAcquisitionType"				Operator="Or" ElementPresent=""
	# could add all the other attributes of the module
	# the following is the condition from the IOD table ...
	Element="ImageType"					Operator="Or" ValueSelector="0" StringValue="ORIGINAL"
ConditionEnd

Condition="NeedModuleMRSpectroscopyPulseSequence"
	Element="PulseSequenceName"				ElementPresent=""
	Element="MRSpectroscopyAcquisitionType"			Operator="Or" ElementPresent=""
	# could add all the other attributes of the module
	# the following is the condition from the IOD table ...
	Element="ImageType"					Operator="Or" ValueSelector="0" StringValue="ORIGINAL"
ConditionEnd

Condition="NeedModuleCardiacSynchronization"
	Element="CardiacSynchronizationTechnique"		ElementPresent=""
ConditionEnd

Condition="NeedModuleRespiratorySynchronization"
	Element="RespiratoryMotionCompensationTechnique"	ElementPresent=""
ConditionEnd

Condition="NeedModuleBulkMotion"
	Element="BulkMotionCompensationTechnique"		ElementPresent=""
ConditionEnd

Condition="NeedModuleSupplementalPaletteColorLUT"
	Element="PixelPresentation"				StringValue="COLOR"
	Element="PixelPresentation"				Operator="Or" StringValue="MIXED"
ConditionEnd

Condition="StackIDIsPresent"
	Element="StackID"					ElementPresent=""
ConditionEnd

Condition="RealWorldValueLUTDataNotPresent"
	Element="RealWorldValueLUTData"				Modifier="Not" ElementPresent=""
ConditionEnd

Condition="RealWorldValueInterceptNotPresent"
	Element="RealWorldValueIntercept"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="CardiacSynchronizationTechniqueNotNoneAndOriginalOrMixed"
	Element="ImageType"								ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CardiacSynchronizationTechnique"		Operator="And" ElementPresent=""
	Element="CardiacSynchronizationTechnique"		Operator="And" Modifier="Not" StringValue="NONE"
ConditionEnd

Condition="CardiacSynchronizationTechniqueProspectiveOrRetrospective"
	Element="CardiacSynchronizationTechnique"		StringValue="PROSPECTIVE"
	Element="CardiacSynchronizationTechnique"		Operator="Or" StringValue="RETROSPECTIVE"
ConditionEnd

Condition="RespiratoryMotionCompensationTechniqueNotNone"
	Element="RespiratoryMotionCompensationTechnique"	ElementPresent=""
	Element="RespiratoryMotionCompensationTechnique"	Operator="And" Modifier="Not" StringValue="NONE"
ConditionEnd

Condition="RespiratoryMotionCompensationTechniqueNotNoneOrRealTimeOrBreathHoldAndOriginalOrMixed"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="RespiratoryMotionCompensationTechnique"	Operator="And" ElementPresent=""
	Element="RespiratoryMotionCompensationTechnique"	Operator="And" Modifier="Not" StringValue="NONE"
	Element="RespiratoryMotionCompensationTechnique"	Operator="And" Modifier="Not" StringValue="BREATH_HOLD"
	Element="RespiratoryMotionCompensationTechnique"	Operator="And" Modifier="Not" StringValue="REALTIME"
ConditionEnd

Condition="BulkMotionCompensationTechniqueNotNoneAndOriginalOrMixed"
	Element="ImageType"								ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="BulkMotionCompensationTechnique"		Operator="And" ElementPresent=""
	Element="BulkMotionCompensationTechnique"		Operator="And" Modifier="Not" StringValue="NONE"
ConditionEnd

Condition="ImageTypeValue1Original"
	Element="ImageType"		ValueSelector="0"	StringValueFromRootAttribute="ORIGINAL"
ConditionEnd

Condition="ImageTypeValue1Derived"
	Element="ImageType"		ValueSelector="0"	StringValueFromRootAttribute="DERIVED"
ConditionEnd

Condition="ImageTypeValue1OriginalOrMixed"
	Element="ImageType"		ValueSelector="0"	StringValueFromRootAttribute="ORIGINAL"
	Element="ImageType"		ValueSelector="0"	StringValueFromRootAttribute="MIXED"
ConditionEnd

Condition="ImageTypeValue1OriginalOrMixedAndRectilinear"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="GeometryOfKSpaceTraversal"	Operator="And"	StringValueFromRootAttribute="RECTILINEAR"
ConditionEnd

Condition="ImageTypeValue1OriginalOrMixedAnd3D"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRAcquisitionType"	Operator="And"	StringValueFromRootAttribute="3D"
ConditionEnd

Condition="ImageTypeValue1OriginalOrMixedAndSpectroscopyVolume"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRSpectroscopyAcquisitionType"	Operator="And"	StringValueFromRootAttribute="VOLUME"
ConditionEnd

Condition="ImageTypeValue1OriginalOrMixedAndEchoPulseSequenceNotGradient"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="EchoPulseSequence"	Operator="And"	Modifier="Not"	StringValueFromRootAttribute="GRADIENT"
ConditionEnd

Condition="ConcatenationUIDIsPresent"
	Element="ConcatenationUID"				ElementPresent=""
ConditionEnd

Condition="ReferencedImageSequenceIsPresent"
	Element="ReferencedImageSequence"			ElementPresent=""
ConditionEnd

Condition="SourceImageSequenceIsPresent"
	Element="SourceImageSequence"				ElementPresent=""
ConditionEnd

Condition="ImageTypeNotPresent"
	Element="ImageType"					Modifier="Not" ElementPresent=""
ConditionEnd

Condition="FrameTypeNotPresent"
	Element="FrameType"					Modifier="Not" ElementPresent=""
ConditionEnd

Condition="GradientOutputIsPresent"
	Element="GradientOutput"				ElementPresent=""
ConditionEnd

Condition="GradientOutputTypeIsPresent"
	Element="GradientOutputType"				ElementPresent=""
ConditionEnd

Condition="InversionRecoveryIsYes"
	Element="InversionRecovery"				StringValue="YES"
ConditionEnd

Condition="FlowCompensationNotNone"
	Element="FlowCompensation"				Modifier="Not" StringValue="NONE"
ConditionEnd

Condition="EchoPulseSequenceGradientOrBoth"
	Element="EchoPulseSequence"				StringValueFromRootAttribute="GRADIENT"
	Element="EchoPulseSequence"				Operator="Or" StringValueFromRootAttribute="BOTH"
ConditionEnd

Condition="PartialFourierIsYes"
	Element="PartialFourier"				StringValue="YES"
ConditionEnd

Condition="ParallelAcquisitionIsYes"
	Element="ParallelAcquisition"				StringValue="YES"
ConditionEnd

Condition="TaggingIsGridOrLine"
	Element="Tagging"					StringValue="GRID"
	Element="Tagging"					StringValue="LINE"
ConditionEnd

Condition="TaggingIsGrid"
	Element="Tagging"					StringValue="GRID"
ConditionEnd

Condition="ReceiveCoilTypeIsMultiCoil"
	Element="ReceiveCoilType"				StringValue="MULTICOIL"
ConditionEnd

# should check FrameType[0] etc. :(
Condition="NeedDiffusionBValue"
	Element="DiffusionBMatrixSequence"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="DiffusionDirectionalityIsDirectional"
	Element="DiffusionDirectionality"			StringValue="DIRECTIONAL"
ConditionEnd

Condition="DiffusionDirectionalityIsBMatrix"
	Element="DiffusionDirectionality"			StringValue="BMATRIX"
ConditionEnd

Condition="PixelMeasuresSequenceNotInSharedFunctionalGroupSequence"
	Element="PixelMeasuresSequence"				Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="PixelMeasuresSequenceNotInPerFrameFunctionalGroupSequence"
	Element="PixelMeasuresSequence"				Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="PlanePositionSequenceNotInSharedFunctionalGroupSequence"
	Element="PlanePositionSequence"				Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="PlanePositionSequenceNotInPerFrameFunctionalGroupSequence"
	Element="PlanePositionSequence"				Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="PlaneOrientationSequenceNotInSharedFunctionalGroupSequence"
	Element="PlaneOrientationSequence"			Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="PlaneOrientationSequenceNotInPerFrameFunctionalGroupSequence"
	Element="PlaneOrientationSequence"			Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="FrameAnatomySequenceNotInSharedFunctionalGroupSequence"
	Element="FrameAnatomySequence"				Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="FrameAnatomySequenceNotInPerFrameFunctionalGroupSequence"
	Element="FrameAnatomySequence"				Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="PixelValueTransformationSequenceNotInSharedFunctionalGroupSequence"
	Element="PixelValueTransformationSequence"		Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="PixelValueTransformationSequenceNotInPerFrameFunctionalGroupSequence"
	Element="PixelValueTransformationSequence"		Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="MRImageFrameTypeSequenceNotInSharedFunctionalGroupSequence"
	Element="MRImageFrameTypeSequence"			Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="MRImageFrameTypeSequenceNotInPerFrameFunctionalGroupSequence"
	Element="MRImageFrameTypeSequence"			Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="MRSpectroscopyFrameTypeSequenceNotInSharedFunctionalGroupSequence"
	Element="MRSpectroscopyFrameTypeSequence"			Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="MRSpectroscopyFrameTypeSequenceNotInPerFrameFunctionalGroupSequence"
	Element="MRSpectroscopyFrameTypeSequence"			Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

# more specific conditions for particular macros that have to also be only in one or the other functional groups sequences ...

Condition="NeedCardiacSynchronizationMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CardiacSynchronizationTechnique"			Operator="And" ElementPresentInRoot=""
	Element="CardiacSynchronizationTechnique"			Operator="And" Modifier="Not" StringValueFromRootAttribute="NONE"
	Element="CardiacSynchronizationSequence"					Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CardiacSynchronizationSequence"					Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCardiacSynchronizationMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CardiacSynchronizationTechnique"			Operator="And" ElementPresentInRoot=""
	Element="CardiacSynchronizationTechnique"			Operator="And" Modifier="Not" StringValueFromRootAttribute="NONE"
	Element="CardiacSynchronizationSequence"					Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CardiacSynchronizationSequence"					Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedRespiratorySynchronizationMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="RespiratoryMotionCompensationTechnique "	Operator="And" ElementPresentInRoot=""
	Element="RespiratoryMotionCompensationTechnique "	Operator="And" Modifier="Not" StringValueFromRootAttribute="NONE"
	Element="RespiratoryMotionCompensationTechnique "	Operator="And" Modifier="Not" StringValueFromRootAttribute="REALTIME"
	Element="RespiratoryMotionCompensationTechnique "	Operator="And" Modifier="Not" StringValueFromRootAttribute="BREATH_HOLD"
	Element="RespiratorySynchronizationSequence"				Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="RespiratorySynchronizationSequence"				Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedRespiratorySynchronizationMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="RespiratoryMotionCompensationTechnique "	Operator="And" ElementPresentInRoot=""
	Element="RespiratoryMotionCompensationTechnique "	Operator="And" Modifier="Not" StringValueFromRootAttribute="NONE"
	Element="RespiratoryMotionCompensationTechnique "	Operator="And" Modifier="Not" StringValueFromRootAttribute="REALTIME"
	Element="RespiratoryMotionCompensationTechnique "	Operator="And" Modifier="Not" StringValueFromRootAttribute="BREATH_HOLD"
	Element="RespiratorySynchronizationSequence"				Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="RespiratorySynchronizationSequence"				Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRTimingAndRelatedParametersMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRTimingAndRelatedParametersSequence"	Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MRTimingAndRelatedParametersSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRTimingAndRelatedParametersMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRTimingAndRelatedParametersSequence"	Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MRTimingAndRelatedParametersSequence"	Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRFOVGeometryMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="GeometryOfKSpaceTraversal"		Operator="And" StringValueFromRootAttribute="RECTILINEAR"
	Element="MRFOVGeometrySequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MRFOVGeometrySequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRFOVGeometryMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="GeometryOfKSpaceTraversal"		Operator="And" StringValueFromRootAttribute="RECTILINEAR"
	Element="MRFOVGeometrySequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MRFOVGeometrySequence"			Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRSpectroscopyFOVGeometryMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="GeometryOfKSpaceTraversal"		Operator="And" StringValueFromRootAttribute="RECTILINEAR"
	Element="MRSpectroscopyFOVGeometrySequence"	Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MRSpectroscopyFOVGeometrySequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRSpectroscopyFOVGeometryMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="GeometryOfKSpaceTraversal"		Operator="And" StringValueFromRootAttribute="RECTILINEAR"
	Element="MRSpectroscopyFOVGeometrySequence"	Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MRSpectroscopyFOVGeometrySequence"			Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMREchoMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MREchoSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MREchoSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMREchoMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MREchoSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MREchoSequence"			Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRModifierMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRModifierSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MRModifierSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRModifierMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRModifierSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MRModifierSequence"			Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRImagingModifierMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRImagingModifierSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MRImagingModifierSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRImagingModifierMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRImagingModifierSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MRImagingModifierSequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRReceiveCoilMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRReceiveCoilSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MRReceiveCoilSequence"			Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRReceiveCoilMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRReceiveCoilSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MRReceiveCoilSequence"			Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRTransmitCoilMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRTransmitCoilSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MRTransmitCoilSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRTransmitCoilMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRTransmitCoilSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MRTransmitCoilSequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRDiffusionMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="AcquisitionContrast"			Operator="And" StringValueFromRootAttribute="DIFFUSION"
	Element="MRDiffusionSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MRDiffusionSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRDiffusionMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="AcquisitionContrast"			Operator="And" StringValueFromRootAttribute="DIFFUSION"
	Element="MRDiffusionSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MRDiffusionSequence"			Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRSpatialSaturationMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="SpatialPresaturation"					Operator="And" StringValueFromRootAttribute="SLAB"
	Element="MRSpatialSaturationSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MRSpatialSaturationSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRSpatialSaturationMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="SpatialPresaturation"					Operator="And" StringValueFromRootAttribute="SLAB"
	Element="MRSpatialSaturationSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MRSpatialSaturationSequence"			Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRAveragesMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRAveragesSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MRAveragesSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRAveragesMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="MRAveragesSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MRAveragesSequence"			Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRMetaboliteMapMacroInSharedFunctionalGroupSequence"
	Element="ImageType"					       ValueSelector="2" StringValueFromRootAttribute="METABOLITE_MAP"
	Element="MRMetaboliteMapSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MRMetaboliteMapSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRMetaboliteMapMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"					       ValueSelector="2" StringValueFromRootAttribute="METABOLITE_MAP"
	Element="MRMetaboliteMapSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MRMetaboliteMapSequence"			Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRVelocityEncodingMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="PhaseContrast"				Operator="And" StringValueFromRootAttribute="YES"
	Element="MRVelocityEncodingSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="MRVelocityEncodingSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedMRVelocityEncodingMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="PhaseContrast"				Operator="And" StringValueFromRootAttribute="YES"
	Element="MRVelocityEncodingSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="MRVelocityEncodingSequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="LossyImageCompressionIs01"
	Element="LossyImageCompression"			StringValue="01"
ConditionEnd

Condition="VolumeLocalizationTechniqueNotNone"
	Element="VolumeLocalizationTechnique"		Modifier="Not"	StringValue="NONE"
ConditionEnd

Condition="DecouplingIsYes"
	Element="Decoupling"				StringValue="YES"
ConditionEnd

Condition="DataPointRowsGreaterThanOne"
	Element="DataPointRows"				ValueSelector="0" BinaryValue="> 1"
ConditionEnd

Condition="FirstOrderPhaseCorrectionIsYes"
	Element="FirstOrderPhaseCorrection"				StringValue="YES"
ConditionEnd

Condition="ClinicalTrialSubjectReadingIDAbsent"
	Element="ClinicalTrialSubjectReadingID"		Modifier="Not"	ElementPresent=""
ConditionEnd

Condition="ClinicalTrialSubjectIDAbsent"
	Element="ClinicalTrialSubjectID"		Modifier="Not"	ElementPresent=""
ConditionEnd

Condition="NeedModuleClinicalTrialSubject"
	Element="ClinicalTrialSponsorName"		ElementPresent=""
	Element="ClinicalTrialProtocolID"		ElementPresent=""
	Element="ClinicalTrialProtocolName"		ElementPresent=""
	Element="ClinicalTrialSiteID"			ElementPresent=""
	Element="ClinicalTrialSiteName"			ElementPresent=""
	Element="ClinicalTrialSubjectID"		ElementPresent=""
	Element="ClinicalTrialSubjectReadingID"		ElementPresent=""
ConditionEnd

Condition="NeedModuleClinicalTrialStudy"
	Element="ClinicalTrialTimePointID"		ElementPresent=""
	Element="ClinicalTrialTimePointDescription"	ElementPresent=""
ConditionEnd

Condition="NeedModuleClinicalTrialSeries"
	Element="ClinicalTrialCoordinatingCenterName"	ElementPresent=""
ConditionEnd

Condition="NeedModuleEnhancedContrastBolus"
	Element="ContrastBolusAgentSequence"		ElementPresent=""
ConditionEnd

Condition="NeedModuleMultiFrameDimension"
	Element="DimensionOrganizationSequence"		ElementPresent=""
	Element="DimensionIndexSequence"			ElementPresent=""
ConditionEnd

Condition="NeedContrastBolusUsageMacroInSharedFunctionalGroupSequence"
	Element="ContrastBolusAgentSequence"		ElementPresentInRoot=""
	Element="ContrastBolusUsageSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="ContrastBolusUsageSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedContrastBolusUsageMacroInPerFrameFunctionalGroupSequence"
	Element="ContrastBolusAgentSequence"		ElementPresentInRoot=""
	Element="ContrastBolusUsageSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="ContrastBolusUsageSequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="CTImageFrameTypeSequenceNotInSharedFunctionalGroupSequence"
	Element="CTImageFrameTypeSequence"		Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="CTImageFrameTypeSequenceNotInPerFrameFunctionalGroupSequence"
	Element="CTImageFrameTypeSequence"		Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTAcquisitionTypeMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTAcquisitionTypeSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CTAcquisitionTypeSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTAcquisitionTypeMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTAcquisitionTypeSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CTAcquisitionTypeSequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTAcquisitionDetailsMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTAcquisitionDetailsSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CTAcquisitionDetailsSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTAcquisitionDetailsMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTAcquisitionDetailsSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CTAcquisitionDetailsSequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTTableDynamicsMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTTableDynamicsSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CTTableDynamicsSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTTableDynamicsMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTTableDynamicsSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CTTableDynamicsSequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTPositionMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTPositionSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CTPositionSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTPositionMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTPositionSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CTPositionSequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTGeometryMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTGeometrySequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CTGeometrySequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTGeometryMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTGeometrySequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CTGeometrySequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTReconstructionMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTReconstructionSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CTReconstructionSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTReconstructionMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTReconstructionSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CTReconstructionSequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTExposureMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTExposureSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CTExposureSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTExposureMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTExposureSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CTExposureSequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTXRayDetailsMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="CTXRayDetailsSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CTXRayDetailsSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedCTXRayDetailsMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0" Modifier="Not" StringValueFromRootAttribute="DERIVED"
	Element="AcquisitionType"			Operator="And" Modifier="Not" StringValueFromRootAttribute="CONSTANT_ANGLE"
	Element="CTXRayDetailsSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CTXRayDetailsSequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="CTAdditionalXRaySourceMacroInSharedFunctionalGroupSequence"
	Element="CTAdditionalXRaySourceSequence"		Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CTAdditionalXRaySourceSequence"		Operator="And" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="CTAdditionalXRaySourceMacroInPerFrameFunctionalGroupSequence"
	Element="CTAdditionalXRaySourceSequence"		Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CTAdditionalXRaySourceSequence"		Operator="And" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="AcquisitionTypeConstantAngle"
	Element="AcquisitionType"			StringValue="CONSTANT_ANGLE"
ConditionEnd

Condition="AcquisitionTypeNotConstantAngle"
	Element="AcquisitionType"			Modifier="Not" StringValue="CONSTANT_ANGLE"
ConditionEnd

Condition="AcquisitionTypeConstantAngleOrSpiral"
	Element="AcquisitionType"			StringValue="CONSTANT_ANGLE"
	Element="AcquisitionType"			Operator="Or" StringValue="SPIRAL"
ConditionEnd

Condition="AcquisitionTypeSpiral"
	Element="AcquisitionType"			StringValue="SPIRAL"
ConditionEnd

Condition="ConvolutionKernelIsPresent"
	Element="ConvolutionKernel"			ElementPresent=""
ConditionEnd

Condition="ReconstructionFieldOfViewAbsent"
	Element="ReconstructionFieldOfView"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ReconstructionDiameterAbsent"
	Element="ReconstructionDiameter"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ExposureModulationTypeIsNotNone"
	Element="ExposureModulationType"		Modifier="Not" StringValue="NONE"
ConditionEnd

Condition="MultiFrameIODAndNotSpecimen"
	Element="NumberOfFrames"			ElementPresent=""
	Element="SpecimenAccessionNumber"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="VOILUTSequenceLUTDescriptorRequiredToBe8Or16"
	Element="SOPClassUID"		               Modifier="Not" StringConstantFromRootAttribute="DigitalXRayImageStorageForProcessingSOPClassUID"
	Element="SOPClassUID"		Operator="And" Modifier="Not" StringConstantFromRootAttribute="DigitalMammographyXRayImageStorageForProcessingSOPClassUID"
	Element="SOPClassUID"		Operator="And" Modifier="Not" StringConstantFromRootAttribute="DigitalIntraoralXRayImageStorageForProcessingSOPClassUID"
	Element="SOPClassUID"		Operator="And" Modifier="Not" StringConstantFromRootAttribute="DigitalXRayImageStorageForPresentationSOPClassUID"
	Element="SOPClassUID"		Operator="And" Modifier="Not" StringConstantFromRootAttribute="DigitalMammographyXRayImageStorageForPresentationSOPClassUID"
	Element="SOPClassUID"		Operator="And" Modifier="Not" StringConstantFromRootAttribute="DigitalIntraoralXRayImageStorageForPresentationSOPClassUID"
ConditionEnd

Condition="ReferencedImageSequenceNotPresent"
	Element="ReferencedImageSequence"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="FrameOfReferenceUIDNotPresent"
	Element="FrameOfReferenceUID"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="FiducialIdentifierNotPresent"
	Element="FiducialIdentifier"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ContourDataIsPresent"
	Element="ContourData"				ElementPresent=""
ConditionEnd

Condition="ContourDataNotPresent"
	Element="ContourData"				Modifier="Not" ElementPresent=""
ConditionEnd

Condition="FrameOfReferenceUIDIsPresentInParent"
	Element="FrameOfReferenceUID"			ElementPresentAbove=""
ConditionEnd

Condition="JPEGTransferSyntaxButNotYBR_FULL_422"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.50"
	Element="PhotometricInterpretation"			Operator="And"	Modifier="Not" StringValue="YBR_FULL_422"
ConditionEnd

Condition="JPEG2000LosslessTransferSyntaxButNotYBR_RCT"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.90"
	Element="PhotometricInterpretation"			Operator="And"	Modifier="Not" StringValue="YBR_RCT"
ConditionEnd

Condition="JPEG2000TransferSyntaxButNotYBR_RCTorYBR_ICT"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.91"
	Element="PhotometricInterpretation"			Operator="And"	Modifier="Not" StringValue="YBR_RCT"
	Element="PhotometricInterpretation"			Operator="And"	Modifier="Not" StringValue="YBR_ICT"
ConditionEnd

Condition="MPEGTransferSyntaxButNotYBR_PARTIAL_420"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.100"
	Element="PhotometricInterpretation"			Operator="And"	Modifier="Not" StringValue="YBR_PARTIAL_420"
ConditionEnd

Condition="JPEGTransferSyntaxAndThreeSamples"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.50"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.51"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.52"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.53"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.54"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.55"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.56"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.57"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.58"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.59"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.60"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.61"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.62"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.63"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.64"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.65"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.66"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.70"
	Element="SamplesPerPixel"			Operator="And"	ValueSelector="0" BinaryValue="== 3"
ConditionEnd

Condition="JPEG2000LosslessTransferSyntaxAndThreeSamples"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.90"
	Element="SamplesPerPixel"			Operator="And"	ValueSelector="0" BinaryValue="== 3"
ConditionEnd

Condition="JPEG2000TransferSyntaxAndThreeSamples"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.90"
	Element="TransferSyntaxUID"			Operator="Or"	StringValue="1.2.840.10008.1.2.4.91"
	Element="SamplesPerPixel"			Operator="And"	ValueSelector="0" BinaryValue="== 3"
ConditionEnd

Condition="MPEGTransferSyntax"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.4.100"
	Element="SamplesPerPixel"			Operator="And"	ValueSelector="0" BinaryValue="== 3"
ConditionEnd

Condition="RLETransferSyntaxAndThreeSamples"
	Element="TransferSyntaxUID"					StringValue="1.2.840.10008.1.2.5"
	Element="SamplesPerPixel"			Operator="And"	ValueSelector="0" BinaryValue="== 3"
ConditionEnd

Condition="ModalityNotPresent"
	Element="Modality"				Modifier="Not" ElementPresent=""
ConditionEnd

Condition="AnatomicRegionSequenceNotPresent"
	Element="AnatomicRegionSequence"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="AnatomicRegionSequencePresent"
	Element="AnatomicRegionSequence"		ElementPresent=""
ConditionEnd

Condition="ImageSetSelectorCategoryIsRelativeTime"
	Element="ImageSetSelectorCategory"		StringValue="RELATIVE_TIME"
ConditionEnd

Condition="RelativeTimePresent"
	Element="RelativeTime"				ElementPresent=""
ConditionEnd

Condition="ImageSetSelectorCategoryIsAbstractPriorAndAbstractPriorCodeSequenceNotPresent"
	Element="ImageSetSelectorCategory"		StringValue="ABSTRACT_PRIOR"
	Element="AbstractPriorCodeSequence"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ImageSetSelectorCategoryIsAbstractPriorAndAbstractPriorValueNotPresent"
	Element="ImageSetSelectorCategory"		StringValue="ABSTRACT_PRIOR"
	Element="AbstractPriorValue"			Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ScreenMinimumColorBitDepthNotPresent"
	Element="ScreenMinimumColorBitDepth"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ScreenMinimumGrayscaleBitDepthNotPresent"
	Element="ScreenMinimumGrayscaleBitDepth"	Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ImageBoxLayoutTypeIsTiled"
	Element="ImageBoxLayoutType"			StringValue="TILED"
ConditionEnd

Condition="ImageBoxLayoutTypeIsCine"
	Element="ImageBoxLayoutType"			StringValue="CINE"
ConditionEnd

Condition="ImageBoxLayoutTypeIsTiledAndMoreThanOneTile"
	Element="ImageBoxTileHorizontalDimension"	ValueSelector="0" BinaryValue="> 1"
	Element="ImageBoxTileVerticalDimension"		ValueSelector="0" BinaryValue="> 1"
	Element="ImageBoxLayoutType"			Operator="And" StringValue="TILED"
ConditionEnd

Condition="ImageBoxSmallScrollTypePresentWithValue"
	Element="ImageBoxSmallScrollType"		 ElementPresent=""
	# cannot check whether value is present or not
ConditionEnd

Condition="ImageBoxLargeScrollTypePresentWithValue"
	Element="ImageBoxLargeScrollType"		 ElementPresent=""
	# cannot check whether value is present or not
ConditionEnd

Condition="ImageBoxLayoutTypeIsCineAndCineRelativeToRealTimeNotPresent"
	Element="ImageBoxLayoutType"			StringValue="CINE"
	Element="CineRelativeToRealTime"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ImageBoxLayoutTypeIsCineAndRecommendedDisplayFrameRateNotPresent"
	Element="ImageBoxLayoutType"			StringValue="CINE"
	Element="RecommendedDisplayFrameRate"		Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="SelectorAttributeNotPresent"
	Element="SelectorAttribute"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="SelectorAttributePresentAndFilterByOperatorNotPresent"
	Element="SelectorAttribute"			ElementPresent=""
	Element="FilterByOperator"			Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="FilterByCategoryNotPresent"
	Element="FilterByCategory"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="SelectorAttributeOrFilterByCategoryAndFilterByOperatorPresent"
	Element="SelectorAttribute"			ElementPresent=""
	Element="FilterByCategory"			ElementPresent=""
	Element="FilterByOperator"			Operator="And" ElementPresent=""
ConditionEnd

Condition="SelectorAttributeAndFilterByOperatorPresent"
	Element="SelectorAttribute"			ElementPresent=""
	Element="FilterByOperator"			Operator="And" ElementPresent=""
ConditionEnd

Condition="SelectorAttributePresentAndFilterByAttributePresenceNotPresentOrFilterByCategoryPresent"
	Element="SelectorAttribute"			ElementPresent=""
	Element="FilterByAttributePresence"		Operator="And" ElementPresent=""
	Element="FilterByCategory"			Operator="Or"  ElementPresent=""
ConditionEnd

Condition="SortByCategoryNotPresent"
	Element="SortByCategory"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="SelectorAttributePresent"
	Element="SelectorAttribute"			ElementPresent=""
ConditionEnd

Condition="ReformattingOperationTypeIsSlabOrMPR"
	Element="ReformattingOperationType"		StringValue="SLAB"
	Element="ReformattingOperationType"		Operator="Or" StringValue="MPR"
ConditionEnd

Condition="ReformattingOperationTypeIsMPROr3D"
	Element="ReformattingOperationType"		StringValue="MPR"
	Element="ReformattingOperationType"		Operator="Or" StringValue="3D_RENDERING"
ConditionEnd

Condition="ReformattingOperationTypeIs3D"
	Element="ReformattingOperationType"		StringValue="3D_RENDERING"
ConditionEnd

Condition="SelectorAttributeVRIsAT"
	Element="SelectorAttributeVR"		StringValue="AT"
ConditionEnd

Condition="SelectorAttributeVRIsCS"
	Element="SelectorAttributeVR"		StringValue="CS"
ConditionEnd

Condition="SelectorAttributeVRIsIS"
	Element="SelectorAttributeVR"		StringValue="IS"
ConditionEnd

Condition="SelectorAttributeVRIsLO"
	Element="SelectorAttributeVR"		StringValue="LO"
ConditionEnd

Condition="SelectorAttributeVRIsLT"
	Element="SelectorAttributeVR"		StringValue="LT"
ConditionEnd

Condition="SelectorAttributeVRIsPN"
	Element="SelectorAttributeVR"		StringValue="PN"
ConditionEnd

Condition="SelectorAttributeVRIsSH"
	Element="SelectorAttributeVR"		StringValue="SH"
ConditionEnd

Condition="SelectorAttributeVRIsST"
	Element="SelectorAttributeVR"		StringValue="ST"
ConditionEnd

Condition="SelectorAttributeVRIsUT"
	Element="SelectorAttributeVR"		StringValue="UT"
ConditionEnd

Condition="SelectorAttributeVRIsDS"
	Element="SelectorAttributeVR"		StringValue="DS"
ConditionEnd

Condition="SelectorAttributeVRIsFD"
	Element="SelectorAttributeVR"		StringValue="FD"
ConditionEnd

Condition="SelectorAttributeVRIsFL"
	Element="SelectorAttributeVR"		StringValue="FL"
ConditionEnd

Condition="SelectorAttributeVRIsUL"
	Element="SelectorAttributeVR"		StringValue="UL"
ConditionEnd

Condition="SelectorAttributeVRIsUS"
	Element="SelectorAttributeVR"		StringValue="US"
ConditionEnd

Condition="SelectorAttributeVRIsSL"
	Element="SelectorAttributeVR"		StringValue="SL"
ConditionEnd

Condition="SelectorAttributeVRIsSS"
	Element="SelectorAttributeVR"		StringValue="SS"
ConditionEnd

Condition="SelectorAttributeVRIsSQ"
	Element="SelectorAttributeVR"		StringValue="SQ"
ConditionEnd

Condition="PatientEyeMovementCommandedIsYes"
	Element="PatientEyeMovementCommanded"				StringValue="YES"
ConditionEnd

Condition="PupilDilatedIsYes"
	Element="PupilDilated"						StringValue="YES"
ConditionEnd

Condition="PartialViewIsYes"
	Element="PartialView"						StringValue="YES"
ConditionEnd

Condition="PixelPaddingValueIsAbsent"
	Element="PixelPaddingValue"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="PixelSpacingCalibrationTypeIsPresent"
	Element="PixelSpacingCalibrationType"		ElementPresent=""
ConditionEnd

Condition="PatientIdentityRemovedAndNotDeidentificationMethodCodeSequence"
	Element="PatientIdentityRemoved"				StringValue="YES"
	Element="DeidentificationMethodCodeSequence"	Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="PatientIdentityRemovedAndNotDeidentificationMethod"
	Element="PatientIdentityRemoved"				StringValue="YES"
	Element="DeidentificationMethod"				Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd

Condition="TransferSyntaxIsReferencedPixelData"
	Element="TransferSyntaxUID"								StringValue="1.2.840.10008.1.2.4.94"
	Element="TransferSyntaxUID"				Operator="Or"	StringValue="1.2.840.10008.1.2.4.95"
ConditionEnd

Condition="PixelDataProviderURLIsAbsent"
	Element="PixelDataProviderURL"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="SOPClassIsEnhancedXAXRF"
	Element="SOPClassUID"								StringValue="1.2.840.10008.5.1.4.1.1.12.1.1"
	Element="SOPClassUID"				Operator="Or"	StringValue="1.2.840.10008.5.1.4.1.1.12.2.1"
ConditionEnd

Condition="MaskOperationIsRevTID"
	Element="MaskOperation"				StringValue="REV_TID"
ConditionEnd

Condition="MaskOperationIsTIDOrRevTID"
	Element="MaskOperation"				StringValue="TID"
	Element="MaskOperation"				Operator="Or"	StringValue="REV_TID"
ConditionEnd

Condition="ModalityIsMR"
	Element="Modality"			StringValueFromRootAttribute="MR"
ConditionEnd

Condition="ModalityIsCT"
	Element="Modality"			StringValueFromRootAttribute="CT"
ConditionEnd

Condition="IsocenterPositionIsPresent"
	Element="IsocenterPosition"		ElementPresent=""
ConditionEnd

Condition="RadiationTypeIsIon"
	Element="RadiationType"			StringValue="ION"
ConditionEnd

Condition="CompensatorMountingPositionNotDoubleSided"
	Element="CompensatorMountingPosition"			Modifier="Not" StringValue="DOUBLE_SIDED"
ConditionEnd

Condition="RangeModulatorTypeIsWhlModWeights"
	Element="RangeModulatorType"			StringValue="WHL_MODWEIGHTS"
ConditionEnd

Condition="ScanModeIsModulated"
	Element="ScanMode"			StringValue="MODULATED"
ConditionEnd

Condition="ImageTypeValue3NotUndefined"
	Element="ImageType"		ValueSelector="2"	Modifier="Not" StringValue="UNDEFINED"
ConditionEnd

Condition="PositionerIsCArm"
	Element="PositionerType"							StringValueFromRootAttribute="CARM"
ConditionEnd

Condition="PositionerIsCArmWithTableTopRelationship"
	Element="PositionerType"							StringValueFromRootAttribute="CARM"
	Element="CArmPositionerTabletopRelationship"		Operator="And"	StringValueFromRootAttribute="YES"
ConditionEnd

Condition="CArmPositionerTabletopRelationshipIsYes"
	Element="CArmPositionerTabletopRelationship"		StringValueFromRootAttribute="YES"
ConditionEnd

Condition="PositionerIsColumn"
	Element="PositionerType"							StringValueFromRootAttribute="COLUMN"
ConditionEnd

Condition="BitsAllocatedIs8"
	Element="BitsAllocated"				ValueSelector="0"	BinaryValue="== 8"
ConditionEnd

Condition="BitsAllocatedIs16"
	Element="BitsAllocated"				ValueSelector="0"	BinaryValue="== 16"
ConditionEnd

Condition="BitsStoredIs8"
	Element="BitsStored"				ValueSelector="0"	BinaryValue="== 8"
ConditionEnd

Condition="BitsStoredGreaterThan8"
	Element="BitsStored"				ValueSelector="0"	BinaryValue="> 8"
ConditionEnd

Condition="ExposureInmAsNotPresent"
	Element="ExposureInmAs"				Modifier="Not" ElementPresent=""
ConditionEnd

Condition="XRayTubeCurrentInmAOrExposureTimeInmsNotPresent"
	Element="XRayTubeCurrentInmA"		Modifier="Not" ElementPresent=""
	Element="ExposureTimeInms"			Operator="Or"	Modifier="Not" ElementPresent=""
ConditionEnd

Condition="IsocenterReferenceSystemSequencePresent"
	Element="IsocenterReferenceSystemSequence"			ElementPresent=""
ConditionEnd

Condition="XRayReceptorTypeIsImageIntensifier"
	Element="XRayReceptorType"		StringValueFromRootAttribute="IMG_INTENSIFIER"
ConditionEnd

Condition="XRayReceptorTypeIsDigitalDetector"
	Element="XRayReceptorType"		StringValueFromRootAttribute="DIGITAL_DETECTOR"
ConditionEnd

Condition="ExposureControlSensingRegionShapeIsRectangular"
	Element="ExposureControlSensingRegionShape"		StringValue="RECTANGULAR"
ConditionEnd

Condition="ExposureControlSensingRegionShapeIsCircular"
	Element="ExposureControlSensingRegionShape"		StringValue="CIRCULAR"
ConditionEnd

Condition="ExposureControlSensingRegionShapeIsPolygonal"
	Element="ExposureControlSensingRegionShape"		StringValue="POLYGONAL"
ConditionEnd

Condition="GeometricalPropertiesIsNonUniform"
	Element="GeometricalProperties"		StringValue="NON_UNIFORM"
ConditionEnd

Condition="DistanceObjectToTableTopNotEmpty"
	Element="DistanceObjectToTableTop"				ValuePresent=""
ConditionEnd

Condition="WaveformSampleInterpretationNeeds8Bit"
	Element="WaveformSampleInterpretation"							StringValue="SB"
	Element="WaveformSampleInterpretation"			Operator="Or"	StringValue="UB"
	Element="WaveformSampleInterpretation"			Operator="Or"	StringValue="MB"
	Element="WaveformSampleInterpretation"			Operator="Or"	StringValue="AB"
ConditionEnd

Condition="WaveformSampleInterpretationNeeds16Bit"
	Element="WaveformSampleInterpretation"							StringValue="SS"
	Element="WaveformSampleInterpretation"			Operator="Or"	StringValue="US"
ConditionEnd

Condition="InstitutionCodeSequenceNotPresent"
	Element="InstitutionCodeSequence"				Modifier="Not" ElementPresent=""
ConditionEnd

Condition="InstitutionNameNotPresent"
	Element="InstitutionName"				Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ObserverTypeIsPerson"
	Element="ObserverType"							StringValue="PSN"
ConditionEnd

Condition="ObserverTypeIsDevice"
	Element="ObserverType"							StringValue="DEV"
ConditionEnd

Condition="FrameVOILUTMacroOKInSharedFunctionalGroupSequence"
	Element="FrameVOILUTSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="FrameVOILUTSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="FrameVOILUTMacroOKInPerFrameFunctionalGroupSequence"
	Element="FrameVOILUTSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="FrameVOILUTSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="RealWorldValueMappingMacroOKInSharedFunctionalGroupSequence"
	Element="RealWorldValueMappingSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="RealWorldValueMappingSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="RealWorldValueMappingMacroOKInPerFrameFunctionalGroupSequence"
	Element="RealWorldValueMappingSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="RealWorldValueMappingSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="ReferencedImageMacroOKInSharedFunctionalGroupSequence"
	Element="ReferencedImageSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="ReferencedImageSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="ReferencedImageMacroOKInPerFrameFunctionalGroupSequence"
	Element="ReferencedImageSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="ReferencedImageSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="DerivationImageMacroOKInSharedFunctionalGroupSequence"
	Element="DerivationImageSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="DerivationImageSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="DerivationImageMacroOKInPerFrameFunctionalGroupSequence"
	Element="DerivationImageSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="DerivationImageSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="CardiacSynchronizationMacroOKInSharedFunctionalGroupSequence"
	Element="CardiacSynchronizationSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CardiacSynchronizationSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="CardiacSynchronizationMacroOKInPerFrameFunctionalGroupSequence"
	Element="CardiacSynchronizationSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CardiacSynchronizationSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="FramePixelShiftMacroOKInSharedFunctionalGroupSequence"
	Element="FramePixelShiftSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="FramePixelShiftSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="FramePixelShiftMacroOKInPerFrameFunctionalGroupSequence"
	Element="FramePixelShiftSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="FramePixelShiftSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="FrameDisplayShutterMacroOKInSharedFunctionalGroupSequence"
	Element="FrameDisplayShutterSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="FrameDisplayShutterSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="FrameDisplayShutterMacroOKInPerFrameFunctionalGroupSequence"
	Element="FrameDisplayShutterSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="FrameDisplayShutterSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="RespiratorySynchronizationMacroOKInSharedFunctionalGroupSequence"
	Element="RespiratorySynchronizationSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="RespiratorySynchronizationSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="RespiratorySynchronizationMacroOKInPerFrameFunctionalGroupSequence"
	Element="RespiratorySynchronizationSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="RespiratorySynchronizationSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="XAXRFFrameCharacteristicsMacroOKInSharedFunctionalGroupSequence"
	Element="XAXRFFrameCharacteristicsSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="XAXRFFrameCharacteristicsSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="XAXRFFrameCharacteristicsMacroOKInPerFrameFunctionalGroupSequence"
	Element="XAXRFFrameCharacteristicsSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="XAXRFFrameCharacteristicsSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="XRayExposureControlSensingRegionsMacroOKInSharedFunctionalGroupSequence"
	Element="ExposureControlSensingRegionsSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="ExposureControlSensingRegionsSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="XRayExposureControlSensingRegionsMacroOKInPerFrameFunctionalGroupSequence"
	Element="ExposureControlSensingRegionsSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="ExposureControlSensingRegionsSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="XRayCalibrationDeviceUsageMacroOKInSharedFunctionalGroupSequence"
	Element="CalibrationSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CalibrationSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="XRayCalibrationDeviceUsageMacroOKInPerFrameFunctionalGroupSequence"
	Element="CalibrationSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CalibrationSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="XRayObjectThicknessMacroOKInSharedFunctionalGroupSequence"
	Element="ObjectThicknessSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="ObjectThicknessSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="XRayObjectThicknessMacroOKInPerFrameFunctionalGroupSequence"
	Element="ObjectThicknessSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="ObjectThicknessSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="XRayFrameAcquisitionMacroOKInSharedFunctionalGroupSequence"
	Element="FrameAcquisitionSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="FrameAcquisitionSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="XRayFrameAcquisitionMacroOKInPerFrameFunctionalGroupSequence"
	Element="FrameAcquisitionSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="FrameAcquisitionSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="XRayIsocenterReferenceSystemMacroOKInSharedFunctionalGroupSequence"
	Element="IsocenterReferenceSystemSequence"				Modifier="Not"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="IsocenterReferenceSystemSequence"				Operator="And"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CArmPositionerTabletopRelationship"			Operator="And"	StringValueFromRootAttribute="YES"
ConditionEnd

Condition="XRayIsocenterReferenceSystemMacroOKInPerFrameFunctionalGroupSequence"
	Element="IsocenterReferenceSystemSequence"				Modifier="Not"	ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="IsocenterReferenceSystemSequence"				Operator="And"	ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CArmPositionerTabletopRelationship"			Operator="And"	StringValueFromRootAttribute="YES"
ConditionEnd

Condition="FrameVOILUTSequenceNotInSharedFunctionalGroupSequence"
	Element="FrameVOILUTSequence"				Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="FrameVOILUTSequenceNotInPerFrameFunctionalGroupSequence"
	Element="FrameVOILUTSequence"				Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="IrradiationEventIdentificationSequenceNotInSharedFunctionalGroupSequence"
	Element="IrradiationEventIdentificationSequence"				Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="IrradiationEventIdentificationSequenceNotInPerFrameFunctionalGroupSequence"
	Element="IrradiationEventIdentificationSequence"				Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="FramePixelDataPropertiesSequenceNotInSharedFunctionalGroupSequence"
	Element="FramePixelDataPropertiesSequence"				Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="FramePixelDataPropertiesSequenceNotInPerFrameFunctionalGroupSequence"
	Element="FramePixelDataPropertiesSequence"				Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedPixelIntensityRelationshipLUTMacroInSharedFunctionalGroupSequence"
	Element="PixelIntensityRelationship"			StringValueFromRootAttribute="LOG"
	Element="PixelIntensityRelationshipLUTSequence"	Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="PixelIntensityRelationshipLUTSequence"	Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedPixelIntensityRelationshipLUTMacroInPerFrameFunctionalGroupSequence"
	Element="PixelIntensityRelationship"			StringValueFromRootAttribute="LOG"
	Element="PixelIntensityRelationshipLUTSequence"	Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="PixelIntensityRelationshipLUTSequence"	Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedPatientOrientationInFrameMacroInSharedFunctionalGroupSequence"
	Element="CArmPositionerTabletopRelationship"		StringValueFromRootAttribute="YES"
	Element="PatientOrientationInFrameSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="PatientOrientationInFrameSequence"			Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedPatientOrientationInFrameMacroInPerFrameFunctionalGroupSequence"
	Element="CArmPositionerTabletopRelationship"		StringValueFromRootAttribute="YES"
	Element="PatientOrientationInFrameSequence"			Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="PatientOrientationInFrameSequence"			Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayFieldOfViewMacroInSharedFunctionalGroupSequence"
	Element="IsocenterReferenceSystemSequence"		ElementPresentInRoot=""
	Element="FieldOfViewSequence"					Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="FieldOfViewSequence"					Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayFieldOfViewMacroInPerFrameFunctionalGroupSequence"
	Element="IsocenterReferenceSystemSequence"		ElementPresentInRoot=""
	Element="FieldOfViewSequence"					Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="FieldOfViewSequence"					Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayFrameDetectorParametersMacroInSharedFunctionalGroupSequence"
	Element="XRayReceptorType"					StringValueFromRootAttribute="DIGITAL_DETECTOR"
	Element="FrameDetectorParametersSequence"	Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="FrameDetectorParametersSequence"	Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayFrameDetectorParametersMacroInPerFrameFunctionalGroupSequence"
	Element="XRayReceptorType"					StringValueFromRootAttribute="DIGITAL_DETECTOR"
	Element="FrameDetectorParametersSequence"	Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="FrameDetectorParametersSequence"	Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayProjectionPixelCalibrationMacroInSharedFunctionalGroupSequence"
	Element="CArmPositionerTabletopRelationship"		StringValueFromRootAttribute="YES"
	Element="ProjectionPixelCalibrationSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="ProjectionPixelCalibrationSequence"		Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayProjectionPixelCalibrationMacroInPerFrameFunctionalGroupSequence"
	Element="CArmPositionerTabletopRelationship"		StringValueFromRootAttribute="YES"
	Element="ProjectionPixelCalibrationSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="ProjectionPixelCalibrationSequence"		Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayPositionerMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0"	StringValueFromRootAttribute="ORIGINAL"
	Element="CArmPositionerTabletopRelationship"		StringValueFromRootAttribute="YES"
	Element="PositionerPositionSequence"				Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="PositionerPositionSequence"				Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayPositionerMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0"	StringValueFromRootAttribute="ORIGINAL"
	Element="CArmPositionerTabletopRelationship"		StringValueFromRootAttribute="YES"
	Element="PositionerPositionSequence"				Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="PositionerPositionSequence"				Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayTablePositionMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0"	StringValueFromRootAttribute="ORIGINAL"
	Element="CArmPositionerTabletopRelationship"		StringValueFromRootAttribute="YES"
	Element="TablePositionSequence"						Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="TablePositionSequence"						Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayTablePositionMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0"	StringValueFromRootAttribute="ORIGINAL"
	Element="CArmPositionerTabletopRelationship"		StringValueFromRootAttribute="YES"
	Element="TablePositionSequence"						Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="TablePositionSequence"						Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayCollimatorMacroInSharedFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0"	StringValueFromRootAttribute="ORIGINAL"
	Element="CollimatorShapeSequence"					Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="CollimatorShapeSequence"					Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayCollimatorMacroInPerFrameFunctionalGroupSequence"
	Element="ImageType"									ValueSelector="0"	StringValueFromRootAttribute="ORIGINAL"
	Element="CollimatorShapeSequence"					Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="CollimatorShapeSequence"					Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

# should really check for ProjectionPixelCalibrationSequence in either shared or per-frame sequence, but cannot ... 

Condition="NeedXRayGeometryMacroInSharedFunctionalGroupSequence"
	Element="CArmPositionerTabletopRelationship"		StringValueFromRootAttribute="YES"
	Element="XRayGeometrySequence"						Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="XRayGeometrySequence"						Operator="Or" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedXRayGeometryMacroInPerFrameFunctionalGroupSequence"
	Element="CArmPositionerTabletopRelationship"		StringValueFromRootAttribute="YES"
	Element="XRayGeometrySequence"						Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="XRayGeometrySequence"						Operator="Or" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="ResponsiblePersonIsPresentWithValue"
	Element="ResponsiblePerson"	ElementPresent=""
	Element="ResponsiblePerson"							Operator="And" ValuePresent=""
ConditionEnd

Condition="IsAnimal"
	Element="PatientSpeciesDescription"					ElementPresent=""
	Element="PatientSpeciesCodeSequence"				Operator="Or"	ElementPresent=""
	Element="PatientBreedDescription"					Operator="Or"	ElementPresent=""
	Element="PatientBreedCodeSequence"					Operator="Or"	ElementPresent=""
	Element="BreedRegistrationSequence"					Operator="Or"	ElementPresent=""
ConditionEnd

Condition="IsAnimalAndPatientSpeciesCodeSequenceAbsent"
	Element="PatientSpeciesCodeSequence"				Modifier="Not" ElementPresent=""
	(
		Element="PatientSpeciesDescription"				ElementPresent=""
		Element="PatientBreedDescription"				Operator="Or"	ElementPresent=""
		Element="PatientBreedCodeSequence"				Operator="Or"	ElementPresent=""
		Element="BreedRegistrationSequence"				Operator="Or"	ElementPresent=""
	) Operator="And"
ConditionEnd

Condition="IsAnimalAndPatientSpeciesDescriptionAbsent"
	Element="PatientSpeciesDescription"					Modifier="Not" ElementPresent=""
	(
		Element="PatientSpeciesCodeSequence"			ElementPresent=""
		Element="PatientBreedDescription"				Operator="Or"	ElementPresent=""
		Element="PatientBreedCodeSequence"				Operator="Or"	ElementPresent=""
		Element="BreedRegistrationSequence"				Operator="Or"	ElementPresent=""
	) Operator="And"
ConditionEnd

Condition="IsAnimalAndPatientBreedCodeSequenceEmpty"
	Element="PatientBreedCodeSequence"					Modifier="Not" SequenceHasItems=""
	(
		Element="PatientSpeciesDescription"				ElementPresent=""
		Element="PatientSpeciesCodeSequence"			Operator="Or"	ElementPresent=""
		Element="PatientBreedDescription"				Operator="Or"	ElementPresent=""
		Element="PatientBreedCodeSequence"				Operator="Or"	ElementPresent=""
		Element="BreedRegistrationSequence"				Operator="Or"	ElementPresent=""
	) Operator="And"
ConditionEnd

Condition="DetectorTypeIsStorage"
	Element="DetectorType"								StringValue="STORAGE"
ConditionEnd

Condition="DetectorTypeIsNotStorage"
	Element="DetectorType"								Modifier="Not" StringValue="STORAGE"
ConditionEnd

# Conditions to detect mapping betweeb coding scheme designator and UID ...
#
Condition="CodingSchemeDesignatorIsACR"
	Element="CodingSchemeDesignator"	StringValue="ACR"
ConditionEnd

Condition="CodingSchemeDesignatorIsASTMSigpurpose"
	Element="CodingSchemeDesignator"	StringValue="ASTM-sigpurpose"
ConditionEnd

Condition="CodingSchemeDesignatorIsC4"
	Element="CodingSchemeDesignator"	StringValue="C4"
ConditionEnd

Condition="CodingSchemeDesignatorIsC5"
	Element="CodingSchemeDesignator"	StringValue="C5"
ConditionEnd

Condition="CodingSchemeDesignatorIsCD2"
	Element="CodingSchemeDesignator"	StringValue="CD2"
ConditionEnd

Condition="CodingSchemeDesignatorIsDCM"
	Element="CodingSchemeDesignator"	StringValue="DCM"
ConditionEnd

Condition="CodingSchemeDesignatorIsDCMUID"
	Element="CodingSchemeDesignator"	StringValue="DCMUID"
ConditionEnd

Condition="CodingSchemeDesignatorIsHPC"
	Element="CodingSchemeDesignator"	StringValue="HPC"
ConditionEnd

Condition="CodingSchemeDesignatorIsI10"
	Element="CodingSchemeDesignator"	StringValue="I10"
ConditionEnd

Condition="CodingSchemeDesignatorIsI10P"
	Element="CodingSchemeDesignator"	StringValue="I10P"
ConditionEnd

Condition="CodingSchemeDesignatorIsI9"
	Element="CodingSchemeDesignator"	StringValue="I9"
ConditionEnd

Condition="CodingSchemeDesignatorIsI9C"
	Element="CodingSchemeDesignator"	StringValue="I9C"
ConditionEnd

Condition="CodingSchemeDesignatorIsISO3166_1"
	Element="CodingSchemeDesignator"	StringValue="ISO3166_1"
ConditionEnd

Condition="CodingSchemeDesignatorIsISO639_1"
	Element="CodingSchemeDesignator"	StringValue="ISO639_1"
ConditionEnd

Condition="CodingSchemeDesignatorIsISO639_2"
	Element="CodingSchemeDesignator"	StringValue="ISO639_2"
ConditionEnd

Condition="CodingSchemeDesignatorIsLN"
	Element="CodingSchemeDesignator"	StringValue="LN"
ConditionEnd

Condition="CodingSchemeDesignatorIsPOS"
	Element="CodingSchemeDesignator"	StringValue="POS"
ConditionEnd

Condition="CodingSchemeDesignatorIsRFC3066"
	Element="CodingSchemeDesignator"	StringValue="RFC3066"
ConditionEnd

Condition="CodingSchemeDesignatorIsSNM3"
	Element="CodingSchemeDesignator"	StringValue="SNM3"
ConditionEnd

Condition="CodingSchemeDesignatorIsSRT"
	Element="CodingSchemeDesignator"	StringValue="SRT"
ConditionEnd

Condition="CodingSchemeDesignatorIsUCUM"
	Element="CodingSchemeDesignator"	StringValue="UCUM"
ConditionEnd

Condition="CodingSchemeDesignatorIsUMLS"
	Element="CodingSchemeDesignator"	StringValue="UMLS"
ConditionEnd

Condition="CodingSchemeDesignatorIsUPC"
	Element="CodingSchemeDesignator"	StringValue="UPC"
ConditionEnd

Condition="PixelPaddingRangeLimitIsPresent"
	Element="PixelPaddingRangeLimit"	ElementPresent=""
ConditionEnd

Condition="PatientPositionAndPatientOrientationCodeSequencePresent"
	Element="PatientPosition"					ElementPresent=""
	Element="PatientOrientationCodeSequence"	Operator="And" ElementPresent=""
ConditionEnd

Condition="VOILUTSequencePresentAndPresentationIntentTypeIsNotForPresentation"
	Element="VOILUTSequence"			ElementPresent=""
	Element="PresentationIntentType"	Operator="And" Modifier="Not" StringValue="FOR PRESENTATION"
ConditionEnd

Condition="WindowCenterPresentAndPresentationIntentTypeIsNotForPresentation"
	Element="WindowCenter"			ElementPresent=""
	Element="PresentationIntentType"	Operator="And" Modifier="Not" StringValue="FOR PRESENTATION"
ConditionEnd

Condition="SpatialLocationsPreservedReorientedOnly"
	Element="SpatialLocationsPreserved"	StringValue="REORIENTED_ONLY"
ConditionEnd

Condition="UnwantedPixelAspectRatioWhenPixelSpacingPresent"
	Element="PixelAspectRatio"					ElementPresent=""
	Element="PixelSpacing"						Operator="And" ElementPresent=""
ConditionEnd

Condition="UnwantedPixelAspectRatioWhenImagerPixelSpacingPresent"
	Element="PixelAspectRatio"					ElementPresent=""
	Element="ImagerPixelSpacing"				Operator="And" ElementPresent=""
ConditionEnd

Condition="UnwantedPixelAspectRatioWhenNominalScannedPixelSpacingPresent"
	Element="PixelAspectRatio"					ElementPresent=""
	Element="NominalScannedPixelSpacing"		Operator="And" ElementPresent=""
ConditionEnd

Condition="UnwantedPixelAspectRatioWhenSharedPixelMeasuresMacro"
	Element="PixelAspectRatio"					ElementPresent=""
	Element="PixelMeasuresSequence"				Operator="And" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="UnwantedPixelAspectRatioWhenPerFramePixelMeasuresMacro"
	Element="PixelAspectRatio"					ElementPresent=""
	Element="PixelMeasuresSequence"				Operator="And" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="DimensionIndexPointerIsNotFunctionalGroup"
	Element="DimensionIndexPointer"				               Modifier="Not" TagValue="0x0018,0x9304"	# CT Acquisition Details Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9301"	# CT Acquisition Type Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9321"	# CT Exposure Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9312"	# CT Geometry Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9329"	# CT Image Frame Type Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9326"	# CT Position Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9314"	# CT Reconstruction Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9308"	# CT Table Dynamics Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9325"	# CT X-ray Details Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9455"	# Calibration Sequence
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9118"	# Cardiac Trigger Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9407"	# Collimator Shape Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9341"	# Contrast/Bolus Usage Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0008,0x9124"	# Derivation Image Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9434"	# Exposure Control Sensing Regions Sequence
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9432"	# Field of View Sequence
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9417"	# Frame Acquisition Sequence
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0020,0x9071"	# Frame Anatomy Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9451"	# Frame Detector Parameters Sequence
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9472"	# Frame Display Shutter Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0028,0x9443"	# Frame Pixel Data Properties Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0028,0x9415"	# Frame Pixel Shift Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0028,0x9132"	# Frame VOI LUT Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9477"	# Irradiation Event Identification Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9462"	# Isocenter Reference System Sequence
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9119"	# MR Averages Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9117"	# MR Diffusion Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9114"	# MR Echo Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9125"	# MR FOV/Geometry Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9226"	# MR Image Frame Type Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9006"	# MR Imaging Modifier Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9152"	# MR Metabolite Map Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9115"	# MR Modifier Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9042"	# MR Receive Coil Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9107"	# MR Spatial Saturation Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9103"	# MR Spectroscopy FOV/Geometry Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9227"	# MR Spectroscopy Frame Type Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9112"	# MR Timing and Related Parameters Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9049"	# MR Transmit Coil Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9197"	# MR Velocity Encoding Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9456"	# Object Thickness Sequence
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0020,0x9450"	# Patient Orientation in Frame Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0028,0x9422"	# Pixel Intensity Relationship LUT Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0028,0x9110"	# Pixel Measures Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0028,0x9145"	# Pixel Value Transformation Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0020,0x9116"	# Plane Orientation Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0020,0x9113"	# Plane Position Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9405"	# Positioner Position Sequence
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9401"	# Projection Pixel Calibration Sequence
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0040,0x9096"	# Real World Value Mapping Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0008,0x1140"	# Referenced Image Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0020,0x9253"	# Respiratory Trigger Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9406"	# Table Position Sequence
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9476"	# X-Ray Geometry Sequence 
	Element="DimensionIndexPointer"				Operator="And" Modifier="Not" TagValue="0x0018,0x9412"	# XA/XRF Frame Characteristics Sequence 
ConditionEnd

Condition="CardiacSignalSourcePresentAndCardiacSynchronizationTechniqueIsNone"
	Element="CardiacSignalSource"				ElementPresent=""
	Element="CardiacSynchronizationTechnique"	Operator="And" StringValue="NONE"
ConditionEnd

Condition="CardiacRRIntervalSpecifiedPresentAndCardiacSynchronizationTechniqueIsNone"
	Element="CardiacRRIntervalSpecified"		ElementPresent=""
	Element="CardiacSynchronizationTechnique"	Operator="And" StringValue="NONE"
ConditionEnd

Condition="CardiacBeatRejectionTechniquePresentAndCardiacSynchronizationTechniqueIsNotProspectiveOrRetrospective"
	Element="CardiacBeatRejectionTechnique"		ElementPresent=""
	Element="CardiacSynchronizationTechnique"	Operator="And" Modifier="Not" StringValue="PROSPECTIVE"
	Element="CardiacSynchronizationTechnique"	Operator="And" Modifier="Not" StringValue="RETROSPECTIVE"
ConditionEnd

Condition="LowRRValuePresentAndCardiacSynchronizationTechniqueIsNotProspectiveOrRetrospective"
	Element="LowRRValue"						ElementPresent=""
	Element="CardiacSynchronizationTechnique"	Operator="And" Modifier="Not" StringValue="PROSPECTIVE"
	Element="CardiacSynchronizationTechnique"	Operator="And" Modifier="Not" StringValue="RETROSPECTIVE"
ConditionEnd

Condition="HighRRValuePresentAndCardiacSynchronizationTechniqueIsNotProspectiveOrRetrospective"
	Element="HighRRValue"						ElementPresent=""
	Element="CardiacSynchronizationTechnique"	Operator="And" Modifier="Not" StringValue="PROSPECTIVE"
	Element="CardiacSynchronizationTechnique"	Operator="And" Modifier="Not" StringValue="RETROSPECTIVE"
ConditionEnd

Condition="IntervalsAcquiredPresentAndCardiacSynchronizationTechniqueIsNone"
	Element="IntervalsAcquired"					ElementPresent=""
	Element="CardiacSynchronizationTechnique"	Operator="And" StringValue="NONE"
ConditionEnd

Condition="IntervalsRejectedPresentAndCardiacSynchronizationTechniqueIsNone"
	Element="IntervalsRejected"					ElementPresent=""
	Element="CardiacSynchronizationTechnique"	Operator="And" StringValue="NONE"
ConditionEnd

Condition="RespiratorySignalSourcePresentAndRespiratoryMotionCompensationTechniqueIsNone"
	Element="RespiratorySignalSource"					ElementPresent=""
	Element="RespiratoryMotionCompensationTechnique"	Operator="And" StringValue="NONE"
ConditionEnd

Condition="BulkMotionSignalSourcePresentAndBulkMotionCompensationTechniqueIsNone"
	Element="BulkMotionSignalSource"			ElementPresent=""
	Element="BulkMotionCompensationTechnique"	Operator="And" StringValue="NONE"
ConditionEnd

Condition="ReferencedFrameNumberAndReferencedSegmentNumberPresent"
	Element="ReferencedFrameNumber"				ElementPresent=""
	Element="ReferencedSegmentNumber"			Operator="And" ElementPresent=""
ConditionEnd

# Real-world condition - assume true if any of the relevant attributes are present
Condition="IsUltrasoundStageProtocol"
	Element="NumberOfStages"							ElementPresent=""
	Element="NumberOfViewsInStage"						ElementPresent=""
	Element="StageName"									ElementPresent=""
	Element="StageCodeSequence"							ElementPresent=""
	Element="StageNumber"								ElementPresent=""
	Element="ViewName"									ElementPresent=""
	Element="ViewNumber"								ElementPresent=""
ConditionEnd

Condition="NominalScannedPixelSpacingPresentAndConversionTypeNotDigitizedFilmScannedDocumentScannedImage"
	Element="NominalScannedPixelSpacing"					ElementPresent=""
	Element="ConversionType"	Operator="And" Modifier="Not" StringValue="DF"
	Element="ConversionType"	Operator="And" Modifier="Not" StringValue="SD"
	Element="ConversionType"	Operator="And" Modifier="Not" StringValue="SI"
ConditionEnd

Condition="PartialViewNotPresent"
	Element="PartialView"		Modifier="Not" ElementPresent=""
ConditionEnd

Condition="CodeValueIllegalOrDeprecated"
	Element="CodeValue"		StringValue="Y-X1770"
	Element="CodeValue"		StringValue="Y-X1771"
ConditionEnd

Condition="CodingSchemeDesignatorDeprecated"
	Element="CodingSchemeDesignator"		StringValue="SNM3"
	Element="CodingSchemeDesignator"		StringValue="99SDM"
ConditionEnd

Condition="NeedOphthalmicFrameLocationMacroInSharedFunctionalGroupSequence"
	Element="OphthalmicFrameLocationSequence"		Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	Element="OphthalmicFrameLocationSequence"		Operator="And" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="NeedOphthalmicFrameLocationMacroInPerFrameFunctionalGroupSequence"
	Element="OphthalmicFrameLocationSequence"		Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="OphthalmicFrameLocationSequence"		Operator="And" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

# should check AcquisitionDeviceTypeCodeSequence contains (A-00FBE, SRT, ”Optical Coherence Tomography Scanner”) ... too hard for now :(
Condition="AcquisitionDeviceTypeCodeSequenceIsOpticalCoherenceTomographyScanner"
ConditionEnd

Condition="OphthalmicImageOrientationIsTransverse"
	Element="OphthalmicImageOrientation"	StringValue="TRANSVERSE"
ConditionEnd

Condition="ReferencedSOPClassUIDInFileIsEncapsulatedCDADocument"
	Element="ReferencedSOPClassUIDInFile"		StringConstant="EncapsulatedCDAStorageSOPClassUID"
ConditionEnd

Condition="XRay3DFrameTypeSequenceNotInSharedFunctionalGroupSequence"
	Element="XRay3DFrameTypeSequence"		Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
ConditionEnd

Condition="XRay3DFrameTypeSequenceNotInPerFrameFunctionalGroupSequence"
	Element="XRay3DFrameTypeSequence"		Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
ConditionEnd

Condition="NeedModulePatientOrientation"
	Element="PatientOrientationCodeSequence"			ElementPresent=""
	Element="PatientGantryRelationshipCodeSequence"		ElementPresent=""
ConditionEnd

Condition="NeedModuleImageEquipmentCoordinateRelationship"
	Element="ImageToEquipmentMappingMatrix"				ElementPresent=""
	Element="EquipmentCoordinateSystemIdentification"	ElementPresent=""
ConditionEnd

Condition="NeedModuleXRay3DAngiographicImageContributingSources"
	Element="ContributingSourcesSequence"			ElementPresent=""
ConditionEnd

Condition="NeedModuleXRay3DCraniofacialImageContributingSources"
	Element="ContributingSourcesSequence"			ElementPresent=""
ConditionEnd

Condition="NeedModuleXRay3DAngiographicAcquisition"
	Element="XRay3DAcquisitionSequence"			ElementPresent=""
ConditionEnd

Condition="NeedModuleXRay3DCraniofacialAcquisition"
	Element="XRay3DAcquisitionSequence"			ElementPresent=""
ConditionEnd

Condition="NeedModuleXRay3DReconstruction"
	Element="XRay3DReconstructionSequence"			ElementPresent=""
ConditionEnd

Condition="SingleCardiacIntervalAcquired"
	Element="IntervalsAcquired"			ValueSelector="0"	BinaryValue="== 1"
ConditionEnd

Condition="CardiacSynchronizationTechniqueNoneOrRealTime"
	Element="CardiacSynchronizationTechnique"		StringValueFromRootAttribute="NONE"
	Element="CardiacSynchronizationTechnique"		StringValueFromRootAttribute="REALTIME"
ConditionEnd

Condition="NeedRespiratoryIntervalTime"
	Element="RespiratoryMotionCompensationTechnique"		Modifier="Not" StringValueFromRootAttribute="NONE"
	Element="RespiratoryMotionCompensationTechnique"		Operator="And" Modifier="Not" StringValueFromRootAttribute="REALTIME"
	Element="RespiratoryTriggerType"						Operator="And" Modifier="Not" StringValueFromRootAttribute="AMPLITUDE"	# i.e., not absent, TIME or BOTH
ConditionEnd

Condition="RespiratoryTriggerTypeTimeOrBoth"
	Element="RespiratoryTriggerType"				StringValueFromRootAttribute="TIME"
	Element="RespiratoryTriggerType"				StringValueFromRootAttribute="BOTH"
ConditionEnd

Condition="RespiratoryTriggerTypeAmplitudeOrBoth"
	Element="RespiratoryTriggerType"				StringValueFromRootAttribute="AMPLITUDE"
	Element="RespiratoryTriggerType"				StringValueFromRootAttribute="BOTH"
ConditionEnd

Condition="StartingRespiratoryAmplitudeIsPresent"
	Element="StartingRespiratoryAmplitude"			ElementPresent=""
ConditionEnd

Condition="EndingRespiratoryAmplitudeIsPresent"
	Element="EndingRespiratoryAmplitude"			ElementPresent=""
ConditionEnd

Condition="BlendingSequenceIsNotPresent"
	Element="BlendingSequence"						Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ReferencedSeriesSequenceIsNotPresent"
	Element="ReferencedSeriesSequence"				Modifier="Not" ElementPresent=""
ConditionEnd

Condition="AnatomicRegionSequenceIsPresent"
	Element="AnatomicRegionSequence"				ElementPresent=""
ConditionEnd

Condition="AnatomicRegionSequenceIsNotPresent"
	Element="AnatomicRegionSequence"				Modifier="Not" ElementPresent=""
ConditionEnd

Condition="ModalityIsNotPresent"
	Element="Modality"								Modifier="Not" ElementPresent=""
ConditionEnd

Condition="AbsoluteChannelDisplayScaleIsNotPresent"
	Element="AbsoluteChannelDisplayScale"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="FractionalChannelDisplayScaleIsNotPresent"
	Element="FractionalChannelDisplayScale"			Modifier="Not" ElementPresent=""
ConditionEnd

Condition="SpecimenIdentifierIsPresentWithValue"
	Element="SpecimenIdentifier"					ElementPresent=""
	Element="SpecimenIdentifier"					Operator="And" ValuePresent=""
ConditionEnd

Condition="ROIPhysicalPropertyIsElemFraction"
	Element="ROIPhysicalProperty"					StringValue="ELEM_FRACTION"
ConditionEnd

Condition="PixelSpacingIsPresent"
	Element="PixelSpacing"							ElementPresent=""
ConditionEnd

Condition="ImageTypeValue3MissingOrEmpty"
	Element="ImageType"								Modifier="Not" ValueSelector="2" ValuePresent=""
	Element="ImageType"								Operator="Or" ValueSelector="2" StringValue=""
ConditionEnd

Condition="ImageTypeValue4MissingOrEmpty"
	Element="ImageType"								Modifier="Not" ValueSelector="3" ValuePresent=""
	Element="ImageType"								Operator="Or" ValueSelector="3" StringValue=""
ConditionEnd

Condition="LateralityHasNoValue"
	Element="Laterality"							ElementPresent=""
	Element="Laterality"							Operator="And" Modifier="Not" ValuePresent=""
ConditionEnd

# should really check for FrameLaterality, but ElementPresentInPathFromRoot only checks one level down :(
# checking AnatomicRegionSequence is probably futile, since ImageLaterality rather than laterality is generally used for those IODs :(
Condition="LateralityRequired"
	Element="ImageLaterality"						Modifier="Not" ElementPresent=""
	Element="FrameAnatomySequence"					Operator="And" Modifier="Not" ElementPresentInPathFromRoot="SharedFunctionalGroupsSequence"
	Element="FrameAnatomySequence"					Operator="And" Modifier="Not" ElementPresentInPathFromRoot="PerFrameFunctionalGroupsSequence"
	(
		Element="BodyPartExamined"					              StringValue="ABDOMEN"
		Element="BodyPartExamined"					Operator="Or" StringValue="ABDOMENPELVIS"
		Element="BodyPartExamined"					Operator="Or" StringValue="AORTA"
		Element="BodyPartExamined"					Operator="Or" StringValue="BACK"
		Element="BodyPartExamined"					Operator="Or" StringValue="BLADDER"
		Element="BodyPartExamined"					Operator="Or" StringValue="BRAIN"
		Element="BodyPartExamined"					Operator="Or" StringValue="CEREBELLUM"
		Element="BodyPartExamined"					Operator="Or" StringValue="CSPINE"
		Element="BodyPartExamined"					Operator="Or" StringValue="CTSPINE"
		Element="BodyPartExamined"					Operator="Or" StringValue="CERVIX"
		Element="BodyPartExamined"					Operator="Or" StringValue="CHEST"
		Element="BodyPartExamined"					Operator="Or" StringValue="CHESTABDOMEN"
		Element="BodyPartExamined"					Operator="Or" StringValue="CHESTABDPELVIS"
		Element="BodyPartExamined"					Operator="Or" StringValue="CIRCLEOFWILLIS"
		Element="BodyPartExamined"					Operator="Or" StringValue="COCCYX"
		Element="BodyPartExamined"					Operator="Or" StringValue="COLON"
		Element="BodyPartExamined"					Operator="Or" StringValue="CORONARYARTERY"
		Element="BodyPartExamined"					Operator="Or" StringValue="DUODENUM"
		Element="BodyPartExamined"					Operator="Or" StringValue="WHOLEBODY"
		Element="BodyPartExamined"					Operator="Or" StringValue="ESOPHAGUS"
		Element="BodyPartExamined"					Operator="Or" StringValue="FACE"
		Element="BodyPartExamined"					Operator="Or" StringValue="GALLBLADDER"
		Element="BodyPartExamined"					Operator="Or" StringValue="HEAD"
		Element="BodyPartExamined"					Operator="Or" StringValue="HEADNECK"
		Element="BodyPartExamined"					Operator="Or" StringValue="HEART"
		Element="BodyPartExamined"					Operator="Or" StringValue="ILEUM"
		Element="BodyPartExamined"					Operator="Or" StringValue="ILIUM"
		Element="BodyPartExamined"					Operator="Or" StringValue="JAW"
		Element="BodyPartExamined"					Operator="Or" StringValue="JEJUNUM"
		Element="BodyPartExamined"					Operator="Or" StringValue="LARYNX"
		Element="BodyPartExamined"					Operator="Or" StringValue="LIVER"
		Element="BodyPartExamined"					Operator="Or" StringValue="LSPINE"
		Element="BodyPartExamined"					Operator="Or" StringValue="LSSPINE"
		Element="BodyPartExamined"					Operator="Or" StringValue="JAW"
		Element="BodyPartExamined"					Operator="Or" StringValue="MAXILLA"
		Element="BodyPartExamined"					Operator="Or" StringValue="MEDIASTINUM"
		Element="BodyPartExamined"					Operator="Or" StringValue="MOUTH"
		Element="BodyPartExamined"					Operator="Or" StringValue="NECK"
		Element="BodyPartExamined"					Operator="Or" StringValue="NECKCHEST"
		Element="BodyPartExamined"					Operator="Or" StringValue="NECKCHESTABDOMEN"
		Element="BodyPartExamined"					Operator="Or" StringValue="NECKCHESTABDPELV"
		Element="BodyPartExamined"					Operator="Or" StringValue="NOSE"
		Element="BodyPartExamined"					Operator="Or" StringValue="PANCREAS"
		Element="BodyPartExamined"					Operator="Or" StringValue="PELVIS"
		Element="BodyPartExamined"					Operator="Or" StringValue="PENIS"
		Element="BodyPartExamined"					Operator="Or" StringValue="PHARYNX"
		Element="BodyPartExamined"					Operator="Or" StringValue="PROSTATE"
		Element="BodyPartExamined"					Operator="Or" StringValue="RECTUM"
		Element="BodyPartExamined"					Operator="Or" StringValue="SSPINE"
		Element="BodyPartExamined"					Operator="Or" StringValue="SCALP"
		Element="BodyPartExamined"					Operator="Or" StringValue="SKULL"
		Element="BodyPartExamined"					Operator="Or" StringValue="SPINE"
		Element="BodyPartExamined"					Operator="Or" StringValue="SPLEEN"
		Element="BodyPartExamined"					Operator="Or" StringValue="STERNUM"
		Element="BodyPartExamined"					Operator="Or" StringValue="STOMACH"
		Element="BodyPartExamined"					Operator="Or" StringValue="TSPINE"
		Element="BodyPartExamined"					Operator="Or" StringValue="TLSPINE"
		Element="BodyPartExamined"					Operator="Or" StringValue="THYMUS"
		Element="BodyPartExamined"					Operator="Or" StringValue="THYROID"
		Element="BodyPartExamined"					Operator="Or" StringValue="TONGUE"
		Element="BodyPartExamined"					Operator="Or" StringValue="TRACHEA"
		Element="BodyPartExamined"					Operator="Or" StringValue="URETER"
		Element="BodyPartExamined"					Operator="Or" StringValue="URETHRA"
		Element="BodyPartExamined"					Operator="Or" StringValue="UTERUS"
		Element="BodyPartExamined"					Operator="Or" StringValue="VAGINA"
		Element="BodyPartExamined"					Operator="Or" StringValue="VULVA"
	) Operator="And" Modifier="Not"
	(
		(
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	              StringValue="T-D4000"	# Abdomen
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="R-FAB57"	# Abdomen and Pelvis
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-42500"	# Abdominal aorta
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-41070"	# Abdominal aorta and its branches
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-59490"	# Anus, rectum and sigmoid colon
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-42000"	# Aorta
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-42300"	# Aortic arch
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-32602"	# Apex of left ventricle
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-32502"	# Apex of right ventricle
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-42100"	# Ascending aorta
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D2100"	# Back
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-60610"	# Bile duct
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-74000"	# Bladder
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-DD123"	# Bladder and urethra
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-A0100"	# Brain
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D6500"	# Broad ligament
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-11501"	# Cervical spine
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D00F7"	# Cervico-thoracic spine
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-83200"	# Cervix
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D3000"	# Chest
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="R-FAB55"	# Chest and Abdomen
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="R-FAB56"	# Chest, Abdomen and Pelvis
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-45526"	# Circle of Willis
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-11BF0"	# Coccyx
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-59300"	# Colon
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-42400"	# Descending aorta
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-58200"	# Duodenum
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D0010"	# Entire body
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-56000"	# Esophagus
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-DD163"	# Esophagus, stomach and duodenum
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-63000"	# Gall  bladder
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D1100"	# Head
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D1000"	# Head and Neck
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-32000"	# Heart
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-58600"	# Ileum
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-58400"	# Jejunum
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-59000"	# Large intestine
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-24100"	# Larynx
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-62000"	# Liver
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-11503"	# Lumbar spine
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D00F9"	# Lumbo-sacral spine
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-28000"	# Lung
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D3300"	# Mediastinum
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-2300C"	# Naso pharynx 
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D1600"	# Neck
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="R-FAB52"	# Neck and Chest 
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="R-FAB53"	# Neck, Chest and Abdomen
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="R-FAB54"	# Neck, Chest, Abdomen and Pelvis
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-21000"	# Nose
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-65000"	# Pancreas
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-65010"	# Pancreatic duct
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-65600"	# Pancreatic duct and bile duct systems
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D6000"	# Pelvis
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="R-FAB58"	# Pelvis and lower extremeties
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-91000"	# Penis
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D2700"	# Perineum
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-55002"	# Pharynx
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-20101"	# Pharynx and larynx
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-9200B"	# Prostate
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-59600"	# Rectum
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D4900"	# Retroperitoneum
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-11AD0"	# Sacrum
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D1160"	# Scalp
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D1460"	# Sella turcica
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-59470"	# Sigmoid colon
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-11000"	# Skeletal system structure (not in DICOM PS 3.16, but Siemens uses for bone scans)
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-11100"	# Skull
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-58000"	# Small intestine
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-A7010"	# Spinal cord
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D0146"	# Spine
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-C3000"	# Spleen
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-46460"	# Splenic artery
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-48890"	# Splenic vein
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-11210"	# Sternum
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-57000"	# Stomach
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-11218"	# Suprasternal notch
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-42070"	# Thoracic aorta
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-11502"	# Thoracic spine
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D00F8"	# Thoraco-lumbar spine
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D3000"	# Thorax
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-C8000"	# Thymus
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-B6000"	# Thyroid
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-53000"	# Tongue
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-25000"	# Trachea
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-DD006"	# Trachea and bronchus
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-F1810"	# Umbilical artery
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-D4230"	# Umbilical region
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-48817"	# Umbilical vein
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-75000"	# Urethra
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-83000"	# Uterus
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-88920"	# Uterus and fallopian tubes
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-82000"	# Vagina
			Element="CodeValue"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="T-81000"	# Vulva
		)
		(
			Element="CodingSchemeDesignator"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="SRT"
			Element="CodingSchemeDesignator"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="SNM3"
			Element="CodingSchemeDesignator"	ElementPresentWithin="AnatomicRegionSequence"	Operator="Or" StringValue="99SDM"
		) Operator="And"
	) Operator="And" Modifier="Not"
ConditionEnd

Condition="UniversalEntityIDPresent"
	Element="UniversalEntityID"						ElementPresent=""
ConditionEnd

Condition="UniversalEntityIDNotPresent"
	Element="UniversalEntityID"						Modifier="Not" ElementPresent=""
ConditionEnd

Condition="LocalNamespaceEntityIDNotPresent"
	Element="LocalNamespaceEntityID"				Modifier="Not" ElementPresent=""
ConditionEnd

Condition="CodeMeaningEmptyOrNotPresent"
	Element="CodeMeaning"							Modifier="Not" ElementPresent=""
	Element="CodeMeaning"							Operator="Or" Modifier="Not" ValuePresent=""
ConditionEnd

Condition="AnatomicRegionSequencePresentAndEmptyButBodyPartExaminedHasValue"
	Element="AnatomicRegionSequence"				ElementPresent=""
	Element="AnatomicRegionSequence"				Operator="And" Modifier="Not" SequenceHasItems=""
	Element="BodyPartExamined"						Operator="And" ValuePresent=""
ConditionEnd

Condition="ViewCodeSequenceAbsentOrEmptyButViewPositionHasValue"
	Element="ViewPosition"							ValuePresent=""
	Element="ViewCodeSequence"						Operator="And" Modifier="Not" SequenceHasItems=""
ConditionEnd

Condition="InstanceIsNotAnImage"
	Element="PixelData"								Modifier="Not" ElementPresent=""
	Element="PixelDataProviderURL"					Operator="And" Modifier="Not" ElementPresent=""
ConditionEnd
