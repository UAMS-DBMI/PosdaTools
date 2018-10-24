#
DefineMacro="HierarchicalSOPInstanceReferenceMacro"
	Name="StudyInstanceUID"									Type="1"
	Sequence="ReferencedSeriesSequence"						Type="1"	VM="1-n"
		InvokeMacro="HierarchicalSeriesReferenceMacro"
	SequenceEnd
MacroEnd
	
DefineMacro="HierarchicalSeriesReferenceMacro"
	Name="SeriesInstanceUID"							Type="1"
	Name="RetrieveAETitle"								Type="3"
	Name="RetrieveLocationUID"							Type="3"
	Name="StorageMediaFileSetID"						Type="3"
	Name="StorageMediaFileSetUID"						Type="3"
	Sequence="ReferencedSOPSequence"					Type="1"	VM="1-n"
		InvokeMacro="SOPInstanceReferenceMacro"
		Sequence="PurposeOfReferenceCodeSequence"		Type="3"	VM="1-n"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
		Sequence="ReferencedDigitalSignatureSequence"	Type="3"	VM="1-n"
			Name="DigitalSignatureUID"					Type="1"
			Name="Signature"							Type="1"
		SequenceEnd
		Sequence="ReferencedSOPInstanceMACSequence"		Type="3"	VM="1"
			Name="MACCalculationTransferSyntaxUID"		Type="1"
			Name="MACAlgorithm"							Type="1"	StringDefinedTerms="MACAlgorithm"
			Name="DataElementsSigned"					Type="1"
			Name="MAC"									Type="1"
		SequenceEnd
	SequenceEnd
MacroEnd

DefineMacro="IdentifiedPersonOrDeviceMacro"
	Name="ObserverType"										Type="1"	StringEnumValues="ObserverType"
	Name="PersonName"										Type="1C"	Condition="ObserverTypeIsPerson"
	Sequence="PersonIdentificationCodeSequence"				Type="2C"	VM="0-1"	Condition="ObserverTypeIsPerson"
		InvokeMacro="CodeSequenceMacro"
	SequenceEnd
	Name="StationName"										Type="2C"	Condition="ObserverTypeIsDevice"
	Name="DeviceUID"										Type="1C"	Condition="ObserverTypeIsDevice"
	Name="Manufacturer"										Type="1C"	Condition="ObserverTypeIsDevice"
	Name="ManufacturerModelName"							Type="1C"	Condition="ObserverTypeIsDevice"
	Name="InstitutionName"									Type="2"
	Sequence="InstitutionCodeSequence"						Type="2"	VM="0-1"
		InvokeMacro="CodeSequenceMacro"
	SequenceEnd
MacroEnd

DefineMacro="NumericMeasurementMacro"
	Sequence="MeasuredValueSequence"						Type="2"	VM="0-1"
		Name="NumericValue"									Type="1"
		Sequence="MeasurementUnitsCodeSequence"				Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"								DefinedContextID="82"
		SequenceEnd
	SequenceEnd
	Sequence="NumericValueQualifierCodeSequence"			Type="3"	VM="1"
		InvokeMacro="CodeSequenceMacro"									DefinedContextID="42"
	SequenceEnd
MacroEnd

DefineMacro="CodeMacro"
	Sequence="ConceptCodeSequence"							Type="1"	VM="1"
		InvokeMacro="CodeSequenceMacro"
	SequenceEnd
MacroEnd

DefineMacro="CompositeObjectReferenceMacro"
	Sequence="ReferencedSOPSequence"								Type="1"	VM="1"
		InvokeMacro="SOPInstanceReferenceMacro"
	SequenceEnd
MacroEnd

DefineMacro="ImageReferenceMacro"
	Sequence="ReferencedSOPSequence"								Type="1"	VM="1"
		InvokeMacro="SOPInstanceReferenceMacro"
		Name="ReferencedFrameNumber"								Type="1C"	NotZeroError=""	NoCondition=""	# ValueTypeIsImage, but too difficult to determine multiframe ref
		Sequence="ReferencedSOPSequence"							Type="3"	VM="1"	# presentation states
			InvokeMacro="SOPInstanceReferenceMacro"
		SequenceEnd
		Sequence="ReferencedRealWorldValueMappingInstanceSequence"	Type="3"	VM="1"
			InvokeMacro="SOPInstanceReferenceMacro"
		SequenceEnd
		Sequence="IconImageSequence"								Type="3"	VM="1"
			InvokeMacro="IconImageSequenceMacro"
		SequenceEnd
	SequenceEnd
MacroEnd

DefineMacro="WaveformReferenceMacro"
	Sequence="ReferencedSOPSequence"								Type="1"	VM="1"
		InvokeMacro="SOPInstanceReferenceMacro"
		Name="ReferencedWaveformChannels"							Type="1C"	NoCondition=""  # too hard for multi-channel :(
	SequenceEnd
MacroEnd

DefineMacro="SpatialCoordinatesMacro"
	Name="GraphicData"					Type="1"
	Name="GraphicType"					Type="1"	StringEnumValues="SRGraphicType"
	Name="FiducialUID"					Type="3"
MacroEnd

DefineMacro="TemporalCoordinatesMacro"
	Name="TemporalRangeType"			Type="1"	StringEnumValues="TemporalRangeType"
	Name="ReferencedSamplePositions"	Type="1C"	Condition="NoReferencedDateTimeOrReferencedTimeOffsets"
	Name="ReferencedTimeOffsets"		Type="1C"	Condition="NoReferencedDateTimeOrReferencedSamplePositions"
	Name="ReferencedDateTime"			Type="1C"	Condition="NoReferencedTimeOffsetsOrReferencedSamplePositions"
MacroEnd

DefineMacro="ContainerMacro"
	Name="ContinuityOfContent"			Type="1"	StringEnumValues="ContinuityOfContent"
	Sequence="ContentTemplateSequence"	Type="1C"	VM="1"	NoCondition=""
		Name="MappingResource"			Type="1"	StringDefinedTerms="SRTemplateMappingResource"
		Name="TemplateIdentifier"		Type="1"
	SequenceEnd
MacroEnd

DefineMacro="DocumentContentMacro"
	Name="ValueType"								Type="1"	StringEnumValues="SRValueTypes"
	Verify="ValueType"											Condition="BasicTextSRStorageInstance"	StringEnumValues="BasicTextSRValueTypes"
	Verify="ValueType"											Condition="KeyObjectSelectionDocumentStorageInstance"	StringEnumValues="KeyObjectSelectionDocumentValueTypes"
	Verify="ValueType"											Condition="MammographyCADSRStorageInstance"	StringEnumValues="MammographyCADSRValueTypes"
	Verify="ValueType"											Condition="ChestCADSRStorageInstance"	StringEnumValues="ChestCADSRValueTypes"
	Verify="ValueType"											Condition="ProcedureLogStorageInstance"	StringEnumValues="ProcedureLogValueTypes"
	Verify="ValueType"											Condition="XRayRadiationDoseSRStorageInstance"	StringEnumValues="XRayRadiationDoseSRValueTypes"
	Sequence="ConceptNameCodeSequence"				Type="1C"	VM="1"	Condition="NeedConceptName"	mbpo="true"	# the mbpo is not correct but avoids incomplete condition issues
		InvokeMacro="CodeSequenceMacro"
	SequenceEnd
	Name="TextValue"								Type="1C"	Condition="ValueTypeIsText"
	Name="DateTime"									Type="1C"	Condition="ValueTypeIsDateTime"
	Name="Date"										Type="1C"	Condition="ValueTypeIsDate"
	Name="Time"										Type="1C"	Condition="ValueTypeIsTime"
	Name="PersonName"								Type="1C"	Condition="ValueTypeIsPersonName"
	Name="UID"										Type="1C"	Condition="ValueTypeIsUID"
	InvokeMacro="NumericMeasurementMacro"			Type="1C"	Condition="ValueTypeIsNumeric"
	InvokeMacro="CodeMacro"							Type="1C"	Condition="ValueTypeIsCode"
	InvokeMacro="CompositeObjectReferenceMacro"		Type="1C"	Condition="ValueTypeIsComposite"
	InvokeMacro="ImageReferenceMacro"				Type="1C"	Condition="ValueTypeIsImage"
	InvokeMacro="WaveformReferenceMacro"			Type="1C"	Condition="ValueTypeIsWaveform"
	InvokeMacro="SpatialCoordinatesMacro"			Type="1C"	Condition="ValueTypeIsSpatialCoordinates"
	InvokeMacro="ContainerMacro"					Type="1C"	Condition="ValueTypeIsContainer"
MacroEnd

DefineMacro="DocumentRelationshipMacro"
	Name="ObservationDateTime"								Type="1C"	NoCondition=""	# Real world condition
	Sequence="ContentSequence"								Type="1C"	VM="1-n"	NoCondition=""  # whether or not leaf is real world
		Name="RelationshipType"								Type="1"	StringDefinedTerms="SRRelationshipType"
		InvokeMacro="DocumentRelationshipMacro"				Type="1C"	Condition="RelationshipByValue"
		InvokeMacro="DocumentContentMacro"					Type="1C"	Condition="RelationshipByValue"
		Name="ReferencedContentItemIdentifier"				Type="1C"	Condition="RelationshipByReference"	NotZeroError=""
	SequenceEnd
MacroEnd

Module="SRDocumentSeries"
	Name="Modality"										Type="1"	StringEnumValues="SRModality"
	Name="SeriesInstanceUID"							Type="1"
	Name="SeriesNumber"									Type="1"
	Name="SeriesDate"									Type="3"
	Name="SeriesTime"									Type="3"
	Name="SeriesDescription"							Type="3"
	Sequence="ReferencedPerformedProcedureStepSequence"	Type="2"	VM="0-1"
		InvokeMacro="SOPInstanceReferenceMacro"
	SequenceEnd
ModuleEnd

Module="SRDocumentGeneral"
	Name="InstanceNumber"											Type="1"
	Name="PreliminaryFlag"											Type="3"	StringEnumValues="PreliminaryFlag"
	Name="CompletionFlag"											Type="1"	StringEnumValues="CompletionFlag"
	Name="CompletionFlagDescription"								Type="3"
	Name="VerificationFlag"											Type="1"	StringEnumValues="VerificationFlag"
	Verify="VerificationFlag"													Condition="VerificationFlagIsVerifiedAndCompletionFlagIsNotComplete"	ThenErrorMessage="Only permitted to be VERIFIED if CompletionFlag is COMPLETE"
	Name="ContentDate"												Type="1"
	Name="ContentTime"												Type="1"
	Sequence="VerifyingObserverSequence"							Type="1C"	VM="1-n"	Condition="VerificationFlagIsVerified"
		Name="VerifyingObserverName"								Type="1"
		Sequence="VerifyingObserverIdentificationCodeSequence"		Type="2"	VM="0-1"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
		Name="VerifyingOrganization"								Type="1"
		Name="VerificationDateTime"									Type="1"
	SequenceEnd
	Sequence="AuthorObserverSequence"								Type="3"	VM="1-n"
		InvokeMacro="IdentifiedPersonOrDeviceMacro"
	SequenceEnd
	Sequence="ParticipantSequence"									Type="3"	VM="1-n"
		Name="ParticipationType"									Type="1"	StringDefinedTerms="ParticipationType"
		Name="ParticipationDateTime"								Type="2"
		InvokeMacro="IdentifiedPersonOrDeviceMacro"
	SequenceEnd
	Sequence="CustodialOrganizationSequence"						Type="3"	VM="1"
		Name="InstitutionName"										Type="2"
		Sequence="InstitutionCodeSequence"							Type="2"	VM="0-1"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
	SequenceEnd
	Sequence="PredecessorDocumentsSequence"							Type="1C"	VM="1-n"	NoCondition=""	# real world
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Sequence="IdenticalDocumentsSequence"							Type="1C"	VM="1-n"	NoCondition=""	# Real world condition
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Sequence="ReferencedRequestSequence"							Type="1C"	VM="1-n"	NoCondition=""	# Real world condition
		Name="StudyInstanceUID"										Type="1"
		Sequence="ReferencedStudySequence"							Type="2"	VM="0-1"
			InvokeMacro="SOPInstanceReferenceMacro"
		SequenceEnd
		Name="AccessionNumber"										Type="2"
		Sequence="IssuerOfAccessionNumberSequence"					Type="3"	VM="1"
			InvokeMacro="HL7v2HierarchicDesignatorMacro"
		SequenceEnd
		Name="PlacerOrderNumberOfImagingServiceRequest"				Type="2"
		Sequence="OrderPlacerIdentifierSequence"					Type="3"	VM="1"
			InvokeMacro="HL7v2HierarchicDesignatorMacro"
		SequenceEnd
		Name="FillerOrderNumberOfImagingServiceRequest"				Type="2"
		Sequence="OrderFillerIdentifierSequence"					Type="3"	VM="1"
			InvokeMacro="HL7v2HierarchicDesignatorMacro"
		SequenceEnd
		Name="RequestedProcedureID"									Type="2"
		Name="RequestedProcedureDescription"						Type="2"
		Sequence="RequestedProcedureCodeSequence"					Type="2"	VM="0-1"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
 		Name="ReasonForRequestedProcedure"							Type="3"
		Sequence="ReasonForRequestedProcedureCodeSequence"			Type="3"	VM="1"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
	SequenceEnd
	Sequence="PerformedProcedureCodeSequence"						Type="2"	VM="0-n"
		InvokeMacro="CodeSequenceMacro"
	SequenceEnd
	Sequence="CurrentRequestedProcedureEvidenceSequence"			Type="1C"	VM="1-n"	NoCondition=""	# real world
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Sequence="PertinentOtherEvidenceSequence"						Type="1C"	VM="1-n"	NoCondition=""	# real world
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Sequence="ReferencedInstanceSequence"							Type="1C"	VM="1"	NoCondition=""	# real world
		InvokeMacro="SOPInstanceReferenceMacro"
		Sequence="PurposeOfReferenceCodeSequence"					Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
	SequenceEnd
ModuleEnd

Module="SRDocumentContent"
	InvokeMacro="DocumentContentMacro"
	InvokeMacro="DocumentRelationshipMacro"
ModuleEnd

Module="KeyObjectDocumentSeries"
	Name="Modality"										Type="1"	StringEnumValues="KOModality"
	Name="SeriesInstanceUID"							Type="1"
	Name="SeriesNumber"									Type="1"
	Name="SeriesDate"									Type="3"
	Name="SeriesTime"									Type="3"
	Name="SeriesDescription"							Type="3"
	Sequence="ReferencedPerformedProcedureStepSequence"	Type="2"	VM="0-1"
		InvokeMacro="SOPInstanceReferenceMacro"
	SequenceEnd
ModuleEnd

Module="KeyObjectDocument"
	Name="InstanceNumber"									Type="1"
	Name="ContentDate"										Type="1"
	Name="ContentTime"										Type="1"
	Sequence="ReferencedRequestSequence"					Type="1C"	VM="1-n"	NoCondition=""	# Real world condition
		Name="StudyInstanceUID"								Type="1"
		Sequence="ReferencedStudySequence"					Type="2"	VM="0-1"
			InvokeMacro="SOPInstanceReferenceMacro"
		SequenceEnd
		Name="AccessionNumber"								Type="2"
		Name="PlacerOrderNumberOfImagingServiceRequest"		Type="2"
		Name="FillerOrderNumberOfImagingServiceRequest"		Type="2"
		Name="RequestedProcedureID"							Type="2"
		Name="RequestedProcedureDescription"				Type="2"
		Sequence="RequestedProcedureCodeSequence"			Type="2"	VM="0-1"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
	SequenceEnd
	Sequence="CurrentRequestedProcedureEvidenceSequence"	Type="1"	VM="1-n"
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
	Sequence="IdenticalDocumentsSequence"					Type="1C"	VM="1-n"	NoCondition=""	# real world
		InvokeMacro="HierarchicalSOPInstanceReferenceMacro"
	SequenceEnd
ModuleEnd
