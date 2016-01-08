#$Source: /home/bbennett/pass/archive/Posda/tpl/module/file.tpl,v $
#$Date: 2009/03/25 14:04:49 $
#$Revision: 1.1 $
#
Module="FileMetaInformation"

	Name="FileMetaInformationGroupLength"	Type="1"
	Name="FileMetaInformationVersion"	Type="1"
	Name="MediaStorageSOPClassUID"	Type="1"
	Name="MediaStorageSOPInstanceUID"	Type="1"
	Name="TransferSyntaxUID"		Type="1"
	Name="ImplementationClassUID"		Type="1"
	Name="ImplementationVersionName"	Type="3"
	Name="SourceApplicationEntityTitle"	Type="3"
	Name="PrivateInformationCreatorUID"	Type="3"
	Name="PrivateInformation"		Type="1C"	Condition="PrivateInformationCreatorUIDPresent"

ModuleEnd

Module="FileSetIdentification"

	Name="FileSetID"			Type="2"
	Name="FileSetDescriptorFileID"		Type="3"
	Name="FileSetCharacterSet"		Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"

ModuleEnd

Module="DirectoryInformation"

	Name="RootDirectoryFirstRecord"					Type="1"
	Name="RootDirectoryLastRecord"					Type="1"
	Name="FileSetConsistencyFlag"					Type="1"	BinaryEnumValues="FileSetConsistencyFlag"
	Sequence="DirectoryRecordSequence"				Type="2"	VM="0-n"
		Name="NextDirectoryRecordOffset"			Type="1"
		Name="RecordInUseFlag"						Type="1"	BinaryEnumValues="RecordInUseFlag"
		Name="LowerLevelDirectoryOffset"			Type="1"
		Name="DirectoryRecordType"					Type="1"	StringEnumValues="DirectoryRecordType"
		Name="PrivateRecordUID"						Type="1C"	Condition="DirectoryRecordTypeIsPrivate"
		Name="ReferencedFileID"						Type="1C"	Condition="DirectorySOPInstance" mbpo="true"	# mbpo since may be (optional) Detached Patient instance reference, for example
		Name="ReferencedSOPClassUIDInFile"			Type="1C"	Condition="DirectorySOPInstance" mbpo="true"
		Name="ReferencedSOPInstanceUIDInFile"		Type="1C"	Condition="DirectorySOPInstance" mbpo="true"
		Name="ReferencedTransferSyntaxUIDInFile"	Type="1C"	Condition="DirectorySOPInstance" mbpo="true"
		
		InvokeMacro="PatientDirectoryRecord"					Condition="DirectoryRecordTypeIsPatient"
		InvokeMacro="StudyDirectoryRecord"						Condition="DirectoryRecordTypeIsStudy"
		InvokeMacro="SeriesDirectoryRecord"						Condition="DirectoryRecordTypeIsSeries"
		InvokeMacro="ImageDirectoryRecord"						Condition="DirectoryRecordTypeIsImage"
		InvokeMacro="RTDoseDirectoryRecord"						Condition="DirectoryRecordTypeIsRTDose"
		InvokeMacro="RTStructureSetDirectoryRecord"				Condition="DirectoryRecordTypeIsRTStructureSet"
		InvokeMacro="RTPlanDirectoryRecord"						Condition="DirectoryRecordTypeIsRTPlan"
		InvokeMacro="RTTreatmentRecordDirectoryRecord"			Condition="DirectoryRecordTypeIsRTTreatmentRecord"
		InvokeMacro="PresentationDirectoryRecord"				Condition="DirectoryRecordTypeIsPresentation"
		InvokeMacro="WaveformDirectoryRecord"					Condition="DirectoryRecordTypeIsWaveform"
		InvokeMacro="SRDocumentDirectoryRecord"					Condition="DirectoryRecordTypeIsSRDocument"
		InvokeMacro="KeyObjectDocumentDirectoryRecord"			Condition="DirectoryRecordTypeIsKeyObjectDocument"
		InvokeMacro="SpectroscopyDirectoryRecord"				Condition="DirectoryRecordTypeIsSpectroscopy"
		InvokeMacro="RawDataDirectoryRecord"					Condition="DirectoryRecordTypeIsRawData"
		InvokeMacro="RegistrationDirectoryRecord"				Condition="DirectoryRecordTypeIsRegistration"
		InvokeMacro="FiducialDirectoryRecord"					Condition="DirectoryRecordTypeIsFiducial"
		InvokeMacro="HangingProtocolDirectoryRecord"			Condition="DirectoryRecordTypeIsHangingProtocol"
		InvokeMacro="EncapsulatedDocumentDirectoryRecord"		Condition="DirectoryRecordTypeIsEncapsulatedDocument"
		InvokeMacro="HL7StructuredDocumentDirectoryRecord"		Condition="DirectoryRecordTypeIsHL7StructuredDocument"
		InvokeMacro="RealWorldValueMappingDirectoryRecord"		Condition="DirectoryRecordTypeIsRealWorldValueMapping"
		InvokeMacro="StereometricRelationshipDirectoryRecord"	Condition="DirectoryRecordTypeIsStereometricRelationship"
	SequenceEnd
ModuleEnd

DefineMacro="PatientDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="PatientName"							Type="2"
		Name="PatientID"							Type="1"
MacroEnd

DefineMacro="StudyDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="StudyDate"							Type="1"
		Name="StudyTime"							Type="1"
		Name="StudyDescription"						Type="2"
		Name="StudyInstanceUID"						Type="1C"	Condition="ReferencedSOPInstanceUIDInFileIsNotPresent"
		Name="StudyID"								Type="1"
		Name="AccessionNumber"						Type="2"
MacroEnd
		
DefineMacro="SeriesDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="Modality"								Type="1"
		Name="SeriesInstanceUID"					Type="1"
		Name="SeriesNumber"							Type="1"
		Sequence="IconImageSequence"				Type="3"	VM="1"
			InvokeMacro="IconImageSequenceMacro"
		SequenceEnd
MacroEnd
		
DefineMacro="ImageDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="InstanceNumber"						Type="1"
		Sequence="IconImageSequence"				Type="3"	VM="1"
			InvokeMacro="IconImageSequenceMacro"
		SequenceEnd
MacroEnd

DefineMacro="RTDoseDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="InstanceNumber"						Type="1"
		Name="DoseSummationType"					Type="1"
		Name="DoseComment"							Type="3"
		Sequence="IconImageSequence"				Type="3"	VM="1"
			InvokeMacro="IconImageSequenceMacro"
		SequenceEnd
MacroEnd

DefineMacro="RTStructureSetDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="InstanceNumber"						Type="1"
		Name="StructureSetLabel"					Type="1"
		Name="StructureSetDate"						Type="2"
		Name="StructureSetTime"						Type="2"
MacroEnd

DefineMacro="RTPlanDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="InstanceNumber"						Type="1"
		Name="RTPlanLabel"							Type="1"
		Name="RTPlanDate"							Type="2"
		Name="RTPlanTime"							Type="2"
MacroEnd

DefineMacro="RTTreatmentRecordDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="InstanceNumber"						Type="1"
		Name="TreatmentDate"						Type="2"
		Name="TreatmentTime"						Type="2"
MacroEnd

DefineMacro="PresentationDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="PresentationCreationDate"				Type="1C"	Condition="DirectoryRecordTypeIsPresentation"
		Name="PresentationCreationTime"				Type="1C"	Condition="DirectoryRecordTypeIsPresentation"
		InvokeMacro="ContentIdentificationMacro"
		Sequence="ReferencedSeriesSequence"			Type="1C"	VM="1-n"	Condition="BlendingSequenceIsNotPresent"				# condition is actually whether or not present in instance, but this is equivalent based on SOP Classes known
			Name="SeriesInstanceUID"				Type="1"
			Sequence="ReferencedImageSequence"		Type="1"	VM="1-n"
				InvokeMacro="SOPInstanceReferenceMacro"
			SequenceEnd
		SequenceEnd
		Sequence="BlendingSequence"					Type="1C"	VM="2"		Condition="ReferencedSeriesSequenceIsNotPresent"		# condition is actually whether or not present in instance, but this is equivalent based on SOP Classes known
			Name="StudyInstanceUID"					Type="1"
			Sequence="ReferencedSeriesSequence"		Type="1"	VM="1-n"
				Name="SeriesInstanceUID"			Type="1"
				Sequence="ReferencedImageSequence"	Type="1"	VM="1-n"
					InvokeMacro="SOPInstanceReferenceMacro"
				SequenceEnd
			SequenceEnd
		SequenceEnd
MacroEnd

DefineMacro="WaveformDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="InstanceNumber"						Type="1"
		Name="ContentDate"							Type="1"
		Name="ContentTime"							Type="1"
MacroEnd

DefineMacro="SRDocumentDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="InstanceNumber"						Type="1"
		Name="CompletionFlag"						Type="1"
		Name="VerificationFlag"						Type="1"
		Name="ContentDate"							Type="1"
		Name="ContentTime"							Type="1"
		Name="VerificationDateTime"					Type="1C"	Condition="VerificationFlagIsVerified"
		Sequence="ConceptNameCodeSequence"			Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
		Sequence="ContentSequence"					Type="1C"	VM="1-n"	NoCondition=""
			Name="RelationshipType"					Type="1"	StringEnumValues="SRRelationshipTypeHasConceptModifier"
			InvokeMacro="DocumentContentMacro"
		SequenceEnd
MacroEnd

DefineMacro="KeyObjectDocumentDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="InstanceNumber"						Type="1"
		Name="ContentDate"							Type="1"
		Name="ContentTime"							Type="1"
		Sequence="ConceptNameCodeSequence"			Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
		Sequence="ContentSequence"					Type="1C"	VM="1-n"	NoCondition=""
			Name="RelationshipType"					Type="1"	StringEnumValues="SRRelationshipTypeHasConceptModifier"
			InvokeMacro="DocumentContentMacro"
		SequenceEnd
MacroEnd

DefineMacro="SpectroscopyDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="ImageType"							Type="1"
		Name="ContentDate"							Type="1"
		Name="ContentTime"							Type="1"
		Name="InstanceNumber"						Type="1"
		Sequence="ReferencedImageEvidenceSequence"	Type="1"	VM="1-n"	NoCondition=""
			InvokeMacro="SOPInstanceReferenceMacro"
		SequenceEnd
		Name="NumberOfFrames"						Type="1"
		Name="Rows"									Type="1"
		Name="Columns"								Type="1"
		Name="DataPointRows"						Type="1"
		Name="DataPointColumns"						Type="1"
		Sequence="IconImageSequence"				Type="3"	VM="1"
			InvokeMacro="IconImageSequenceMacro"
		SequenceEnd
MacroEnd

DefineMacro="RawDataDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="ContentDate"							Type="1"
		Name="ContentTime"							Type="1"
		Name="InstanceNumber"						Type="2"
		Sequence="IconImageSequence"				Type="3"	VM="1"
			InvokeMacro="IconImageSequenceMacro"
		SequenceEnd
MacroEnd

DefineMacro="RegistrationDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="ContentDate"							Type="1"
		Name="ContentTime"							Type="1"
		InvokeMacro="ContentIdentificationMacro"
MacroEnd

DefineMacro="FiducialDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="ContentDate"							Type="1"
		Name="ContentTime"							Type="1"
		InvokeMacro="ContentIdentificationMacro"
MacroEnd

DefineMacro="HangingProtocolDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="HangingProtocolName"									Type="1"
		Name="HangingProtocolDescription"							Type="1"
		Name="HangingProtocolLevel"									Type="1"
		Name="HangingProtocolCreator"								Type="1"
		Name="HangingProtocolCreationDateTime"						Type="1"
		Sequence="HangingProtocolDefinitionSequence"				Type="1"	VM="1-n"
			Name="Modality"											Type="1C"	Condition="AnatomicRegionSequenceIsNotPresent" mbpo="true"
			Sequence="AnatomicRegionSequence"						Type="1C"	VM="1-n"	Condition="ModalityIsNotPresent" mbpo="true"
				InvokeMacro="CodeSequenceMacro"
			SequenceEnd
			Name="Laterality"										Type="2C"	Condition="AnatomicRegionSequenceIsPresent" mbpo="true"
			Sequence="ProcedureCodeSequence"						Type="2"	VM="1-n"
				InvokeMacro="CodeSequenceMacro"
			SequenceEnd
			Sequence="ReasonForRequestedProcedureCodeSequence"		Type="2"	VM="1-n"
				InvokeMacro="CodeSequenceMacro"
			SequenceEnd
		SequenceEnd
		Name="NumberOfPriorsReferenced"								Type="1"
		Sequence="HangingProtocolUserIdentificationCodeSequence"	Type="2"	VM="0-1"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
MacroEnd

DefineMacro="EncapsulatedDocumentDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="ContentDate"							Type="2"
		Name="ContentTime"							Type="2"
		Name="InstanceNumber"						Type="1"
		Name="DocumentTitle"						Type="2"
		Name="HL7InstanceIdentifier"				Type="1C"	Condition="ReferencedSOPClassUIDInFileIsEncapsulatedCDADocument"
		Sequence="ConceptNameCodeSequence"			Type="2"	VM="0-1"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
		Name="MIMETypeOfEncapsulatedDocument"		Type="1"
MacroEnd

DefineMacro="HL7StructuredDocumentDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="HL7InstanceIdentifier"				Type="1"
		Name="HL7DocumentEffectiveTime"				Type="1"
		Sequence="HL7DocumentTypeCodeSequence"		Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
MacroEnd

DefineMacro="RealWorldValueMappingDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		Name="ContentDate"							Type="1"
		Name="ContentTime"							Type="1"
		InvokeMacro="ContentIdentificationMacro"
MacroEnd

DefineMacro="StereometricRelationshipDirectoryRecord"
		Name="SpecificCharacterSet"					Type="1C"	NoCondition=""	StringDefinedTerms="SpecificCharacterSet"
		InvokeMacro="ContentIdentificationMacro"
MacroEnd

Module="DirectoryInformationDental"
	Sequence="DirectoryRecordSequence"				Type="2"	VM="0-n"
		Name="ReferencedSOPClassUIDInFile"			Type="1C"	Condition="DirectorySOPInstance"	StringEnumValues="DentalMediaProfileSOPClasses"
		Name="ReferencedTransferSyntaxUIDInFile"	Type="1C"	Condition="DirectorySOPInstance"	StringEnumValues="DentalMediaProfileTransferSyntaxes"
	SequenceEnd
ModuleEnd

