#
CompositeIOD="EnhancedCTImage"			Condition="EnhancedCTImageInstance"
	InformationEntity="File"
		Module="FileMetaInformation"							Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"										Usage="M"
		Module="ClinicalTrialSubject"							Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"									Usage="M"
		Module="PatientStudy"									Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"								Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"									Usage="M"
		Module="ClinicalTrialSeries"							Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="CTSeries"										Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"								Usage="M"
		Module="Synchronization"								Usage="U"	Condition="NeedToCheckModuleSynchronization"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"								Usage="M"
		Module="EnhancedGeneralEquipment"						Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="ImagePixel"										Usage="M"
		Module="EnhancedContrastBolus"							Usage="C"	Condition="NeedModuleEnhancedContrastBolus"
		Module="MultiFrameFunctionalGroupsCommon"				Usage="M"
		Module="MultiFrameFunctionalGroupsForEnhancedCTImage"	Usage="M"
		Module="MultiFrameDimension"							Usage="M"
		Module="CardiacSynchronization"							Usage="C"	Condition="NeedModuleCardiacSynchronization"
		Module="RespiratorySynchronization"						Usage="C"	Condition="NeedModuleRespiratorySynchronization"
		Module="SupplementalPaletteColorLUT"					Usage="C"	Condition="NeedModuleSupplementalPaletteColorLUT"
		Module="AcquisitionContext"								Usage="M"
		Module="Device"											Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"										Usage="U"	Condition="NeedModuleSpecimen"
		Module="EnhancedCTImage"								Usage="M"
		Module="SOPCommon"										Usage="M"
		Module="FrameExtraction"								Usage="C"	Condition="NeedModuleFrameExtraction"
	InformationEntityEnd
CompositeIODEnd
