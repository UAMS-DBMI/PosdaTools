#
CompositeIOD="PETImage"		Condition="PETImageInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="PETSeries"					Usage="M"
		Module="PETIsotope"					Usage="M"
		Module="PETMultigatedAcquisition"	Usage="C"	Condition="NeedModulePETMultigatedAcquisition"
		Module="NMPETPatientOrientation"	Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="M"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePlane"					Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="PETImage"					Usage="M"
		Module="OverlayPlane"				Usage="U"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="U"	Condition="NeedModuleVOILUT"
		Module="AcquisitionContext"			Usage="U"	Condition="NeedModuleAcquisitionContext"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="EnhancedPETImage"			Condition="EnhancedPETImageInstance"
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
		Module="EnhancedPETSeries"								Usage="M"
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
		Module="Intervention"									Usage="U"	Condition="NeedModuleIntervention"
		Module="AcquisitionContext"								Usage="M"
		Module="MultiFrameFunctionalGroupsCommon"				Usage="M"
		Module="MultiFrameFunctionalGroupsForEnhancedPETImage"	Usage="M"
		Module="MultiFrameDimension"							Usage="M"
		Module="CardiacSynchronization"							Usage="C"	Condition="NeedModuleCardiacSynchronization"
		Module="RespiratorySynchronization"						Usage="C"	Condition="NeedModuleRespiratorySynchronization"
		Module="Specimen"										Usage="U"	Condition="NeedModuleSpecimen"
		Module="EnhancedPETIsotope"								Usage="M"
		Module="EnhancedPETAcquisition"							Usage="M"
		Module="EnhancedPETImage"								Usage="M"
		Module="SOPCommon"										Usage="M"
		Module="FrameExtraction"								Usage="C"	Condition="NeedModuleFrameExtraction"
	InformationEntityEnd
CompositeIODEnd
