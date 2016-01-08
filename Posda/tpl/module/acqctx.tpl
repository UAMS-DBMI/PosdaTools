#$Source: /home/bbennett/pass/archive/Posda/tpl/module/acqctx.tpl,v $
#$Date: 2009/03/25 14:04:14 $
#$Revision: 1.1 $
#
Module="AcquisitionContext"
	Sequence="AcquisitionContextSequence"			Type="2"	VM="0-n"
		Name="ValueType"							Type="3"	StringDefinedTerms="AcquisitionContextValueTypes"
		Sequence="ConceptNameCodeSequence"			Type="1"	VM="1"	# should check for 1 and only 1 item present
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
		Name="ReferencedFrameNumbers"				Type="1C"	NoCondition=""	NotZeroError=""
		Name="NumericValue"							Type="1C"	Condition="AcquisitionContextItemIsNumericValueOrMeasurementUnitsCodeSequenceIsPresent"
		Sequence="MeasurementUnitsCodeSequence"		Type="1C"	VM="1"	Condition="NeedMeasurementUnitsCodeSequence"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
		Verify="MeasurementUnitsCodeSequence"					Condition="MeasurementUnitsCodeSequencePresentAndNumericValueAbsent"	ThenErrorMessage="May not be present when NumericValue is absent"
		Name="Date"									Type="1C"	Condition="AcquisitionContextItemIsDate"
		Name="Time"									Type="1C"	Condition="AcquisitionContextItemIsTime"
		Name="PersonName"							Type="1C"	Condition="AcquisitionContextItemIsPersonName"
		Name="TextValue"							Type="1C"	Condition="AcquisitionContextItemIsTextValue"
		Sequence="ConceptCodeSequence"				Type="1C"	VM="1"	Condition="AcquisitionContextItemIsConceptCodeSequence"
			InvokeMacro="CodeSequenceMacro"
		SequenceEnd
	SequenceEnd
	Name="AcquisitionContextDescription"			Type="3"
ModuleEnd

