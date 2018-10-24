#
DefineMacro="SpecimenMacro"
	Name="ContainerIdentifier"								Type="1"
	Sequence="IssuerOfTheContainerIdentifierSequence"		Type="2"	VM="0-1"
		InvokeMacro="HL7v2HierarchicDesignatorMacro"
	SequenceEnd
	Sequence="AlternateContainerIdentifierSequence"			Type="3"	VM="1-n"
		Name="ContainerIdentifier"							Type="1"
		Sequence="IssuerOfTheContainerIdentifierSequence"	Type="2"	VM="0-1"
			InvokeMacro="HL7v2HierarchicDesignatorMacro"
		SequenceEnd
	SequenceEnd
	Sequence="ContainerTypeCodeSequence"					Type="2"	VM="0-1"
		InvokeMacro="CodeSequenceMacro"						BaselineContextID="8101"
	SequenceEnd
	Name="ContainerDescription"								Type="3"
	Sequence="ContainerComponentSequence"					Type="3"	VM="1-n"
		Sequence="ContainerComponentTypeCodeSequence"		Type="1"	VM="1"
			InvokeMacro="CodeSequenceMacro"					BaselineContextID="8102"
		SequenceEnd
		Name="Manufacturer"									Type="3"
		Name="ManufacturerModelName"						Type="3"
		Name="ContainerComponentID"							Type="3"
		Name="ContainerComponentLength"						Type="3"
		Name="ContainerComponentWidth"						Type="3"
		Name="ContainerComponentDiameter"					Type="3"
		Name="ContainerComponentThickness"					Type="3"
		Name="ContainerComponentMaterial"					Type="3"	StringDefinedTerms="ContainerComponentMaterial"
		Name="ContainerComponentDescription"				Type="3"
	SequenceEnd
	Sequence="SpecimenDescriptionSequence"					Type="1"	VM="1-n"
		Name="SpecimenIdentifier"							Type="1"
		Sequence="IssuerOfTheSpecimenIdentifierSequence"	Type="2"	VM="0-1"
			InvokeMacro="HL7v2HierarchicDesignatorMacro"
		SequenceEnd
		Name="SpecimenUID"									Type="1"
		Sequence="SpecimenTypeCodeSequence"					Type="3"	VM="1"
			InvokeMacro="CodeSequenceMacro"					BaselineContextID="8103"
		SequenceEnd
		Name="SpecimenShortDescription"						Type="3"
		Name="SpecimenDetailedDescription"					Type="3"
		Sequence="SpecimenPreparationSequence"				Type="2"	VM="0-n"
			Sequence="SpecimenPreparationStepContentItemSequence"	Type="1"	VM="1-n"
				InvokeMacro="ContentItemMacro"
			SequenceEnd
		SequenceEnd
		InvokeMacro="PrimaryAnatomicStructureMacro" 
		Sequence="SpecimenLocalizationContentItemSequence"	Type="1C"	VM="1-n"	NoCondition=""	mbpo="true" # real-world multiple specimens
			InvokeMacro="ContentItemMacro"
		SequenceEnd
	SequenceEnd
MacroEnd

Module="Specimen"
	InvokeMacro="SpecimenMacro"
ModuleEnd
