#$Source: /home/bbennett/pass/archive/Posda/tpl/module/waveform.tpl,v $
#$Date: 2010/04/30 19:21:25 $
#$Revision: 1.4 $
#
Module="Synchronization"
	Name="SynchronizationFrameOfReferenceUID"		Type="1"
	Name="SynchronizationTrigger"					Type="1"	StringEnumValues="SynchronizationTrigger"
	Name="TriggerSourceOrType"						Type="3"
	Name="SynchronizationChannel"					Type="1C"	NoCondition=""	# real world
	Name="AcquisitionTimeSynchronized"				Type="1"	StringEnumValues="YesNoLetter"
	Name="TimeSource"								Type="3"
	Name="TimeDistributionProtocol"					Type="3"	StringEnumValues="TimeDistributionProtocol"
	Name="NTPSourceAddress"							Type="3"
ModuleEnd

Module="WaveformIdentification"
	Name="InstanceNumber"							Type="1"
	Name="ContentDate"								Type="1"
	Name="ContentTime"								Type="1"
	Name="AcquisitionDateTime"						Type="1"
	Sequence="ReferencedInstanceSequence"			Type="3"	VM="1-n"
		InvokeMacro="SOPInstanceReferenceMacro"
		Sequence="PurposeOfReferenceCodeSequence"	Type="3"	VM="1"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
	SequenceEnd
ModuleEnd

Module="Waveform"
	Sequence="WaveformSequence"							Type="1"	VM="1-n"
		Name="MultiplexGroupTimeOffset"					Type="1C"	Condition="AcquisitionTimeSynchronizedIsY"
		Name="TriggerTimeOffset"						Type="1C"	NoCondition=""	# real world
		Name="TriggerSamplePosition"					Type="3"
		Name="WaveformOriginality"						Type="1"	StringEnumValues="WaveformOriginality"
		Name="NumberOfWaveformChannels"					Type="1"	NotZeroError=""
		Name="NumberOfWaveformSamples"					Type="1"	NotZeroError=""
		Name="SamplingFrequency"						Type="1"
		Name="MultiplexGroupLabel"						Type="3"
		Sequence="ChannelDefinitionSequence"			Type="1"	VM="1-n"
			Name="WaveformChannelNumber"				Type="3"
			Name="ChannelLabel"							Type="3"
			Name="ChannelStatus"						Type="3"	StringDefinedTerms="ChannelStatus"
			Sequence="ChannelSourceSequence"			Type="1"	VM="1"
				InvokeMacro="CodeSequenceMacro"
			SequenceEnd
			Sequence="ChannelSourceModifiersSequence"	Type="1C"	VM="1-n"	NoCondition=""
				InvokeMacro="CodeSequenceMacro"
			SequenceEnd
			Sequence="SourceWaveformSequence"			Type="3"	VM="1-n"
				InvokeMacro="SOPInstanceReferenceMacro"
				Name="ReferencedWaveformChannels"		Type="1"
			SequenceEnd
			Name="ChannelDerivationDescription"			Type="3"
			Name="ChannelSensitivity"					Type="1C"	NoCondition=""	# real world
			Sequence="ChannelSensitivityUnitsSequence"	Type="1C"	VM="1"	Condition="ChannelSensitivityIsPresent"
				InvokeMacro="CodeSequenceMacro"						DefinedContextID="3082"
			SequenceEnd
			Name="ChannelSensitivityCorrectionFactor"	Type="1C"	Condition="ChannelSensitivityIsPresent"
			Name="ChannelBaseline"						Type="1C"	Condition="ChannelSensitivityIsPresent"
			Name="ChannelTimeSkew"						Type="1C"	Condition="ChannelSampleSkewNotPresent"
			Name="ChannelSampleSkew"					Type="1C"	Condition="ChannelTimeSkewNotPresent"
			Name="ChannelOffset"						Type="3"
			Name="WaveformBitsStored"					Type="1"
			Name="FilterLowFrequency"					Type="3"
			Name="FilterHighFrequency"					Type="3"
			Name="NotchFilterFrequency"					Type="3"
			Name="NotchFilterBandwidth"					Type="3"
			Name="ChannelMinimumValue"					Type="3"
			Name="ChannelMaximumValue"					Type="3"
		SequenceEnd
		Name="WaveformBitsAllocated"					Type="1"	BinaryEnumValues="BitsAre8Or16"
		Verify="WaveformBitsAllocated"								Condition="WaveformSampleInterpretationNeeds8Bit" BinaryEnumValues="BitsAre8"
		Verify="WaveformBitsAllocated"								Condition="WaveformSampleInterpretationNeeds16Bit" BinaryEnumValues="BitsAre16"
		Name="WaveformSampleInterpretation"				Type="1"	StringEnumValues="WaveformSampleInterpretation"	
		Name="WaveformPaddingValue"						Type="1C"	NoCondition=""	# real world
		Name="WaveformData"								Type="1"
		Name="WaveformDataDisplayScale"						Type="3"	NotZeroError=""
		Name="WaveformDisplayBackgroundCIELabValue"			Type="3"
		Sequence="WaveformPresentationGroupSequence"		Type="3"	VM="1-n"
			Name="PresentationGroupNumber"					Type="1"
			Sequence="ChannelDisplaySequence"				Type="1"	VM="1-n"
				Name="ReferencedWaveformChannels"			Type="1"
				Name="ChannelOffset"						Type="3"
				Name="ChannelRecommendedDisplayCIELabValue"	Type="1"
				Name="ChannelPosition"						Type="1"
				Name="DisplayShadingFlag"					Type="3"	StringEnumValues="DisplayShadingFlag"
				Name="FractionalChannelDisplayScale"		Type="1C"	Condition="AbsoluteChannelDisplayScaleIsNotPresent"
				Name="AbsoluteChannelDisplayScale"			Type="1C"	Condition="FractionalChannelDisplayScaleIsNotPresent"
			SequenceEnd
		SequenceEnd
	SequenceEnd
ModuleEnd

Module="WaveformAnnotation"
	Sequence="WaveformAnnotationSequence"				Type="1"	VM="1-n"
		Name="UnformattedTextValue"						Type="1C"	Condition="ConceptNameCodeSequenceNotPresent"
		Sequence="ConceptNameCodeSequence"				Type="1C"	VM="1"	Condition="UnformattedTextValueNotPresent"
			InvokeMacro="CodeSequenceMacro"
			Sequence="ModifierCodeSequence"				Type="1C"	VM="1-n"	NoCondition=""	# real world
				InvokeMacro="CodeSequenceMacro"
			SequenceEnd
		SequenceEnd
		Sequence="ConceptCodeSequence"					Type="3"	VM="1"
			InvokeMacro="CodeSequenceMacro"
			Sequence="ModifierCodeSequence"				Type="1C"	VM="1-n"	NoCondition=""	# real world
				InvokeMacro="CodeSequenceMacro"
			SequenceEnd
		SequenceEnd
		Name="NumericValue"								Type="3"
		Sequence="MeasurementUnitsCodeSequence"			Type="3"	VM="1"
			InvokeMacro="CodeSequenceMacro"							BaselineContextID="82"
		SequenceEnd
		Name="ReferencedWaveformChannels"				Type="1"
		Name="TemporalRangeType"						Type="1C"	NoCondition=""	StringEnumValues="TemporalRangeTypeForWaveformAnnotation"
		Name="ReferencedSamplePositions"				Type="1C"	Condition="AnnotationNeedsReferencedSamplePositions"
		Name="ReferencedTimeOffsets"					Type="1C"	Condition="AnnotationNeedsReferencedTimeOffsets"
		Name="ReferencedDateTime"						Type="1C"	Condition="AnnotationNeedsReferencedDateTime"
		Name="AnnotationGroupNumber"					Type="3"
	SequenceEnd
ModuleEnd

