#$Source: /home/bbennett/pass/archive/Posda/tpl/iodcomp/vl.tpl,v $
#$Date: 2010/04/30 18:53:52 $
#$Revision: 1.2 $
#
CompositeIOD="VLEndoscopicImage"		Condition="VisibleLightEndoscopicImageInstance"
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
		Module="VLEndoscopicSeriesPseudo"	Usage="M"	# not in standard ... use to check conditions
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="AcquisitionContext"			Usage="M"	# not check for baseline CIDs yet
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="VLImage"					Usage="M"
		Module="OverlayPlane"				Usage="U"	Condition="NeedModuleOverlayPlane"
		Module="CheckSingleFramePseudo"		Usage="M"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="VLMicroscopicImage"		Condition="VisibleLightMicroscopicImageInstance"
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
		Module="VLMicroscopicSeriesPseudo"	Usage="M"	# not in standard ... use to check conditions
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="AcquisitionContext"			Usage="M"	# not check for baseline CIDs yet
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="C"	Condition="NeedModuleSpecimen"	# real-world "is a specimen"
		Module="VLImage"					Usage="M"
		Module="OverlayPlane"				Usage="U"	Condition="NeedModuleOverlayPlane"
		Module="CheckSingleFramePseudo"		Usage="M"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="VLSlideCoordinatesMicroscopicImage"		Condition="VisibleLightSlideCoordinatesMicroscopicImageInstance"
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
		Module="VLSlideCoordinatesMicroscopicSeriesPseudo"	Usage="M"	# not in standard ... use to check conditions
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="M"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="AcquisitionContext"			Usage="M"	# not check for baseline CIDs yet
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="C"	Condition="NeedModuleSpecimen"	# real-world "is a specimen"
		Module="VLImage"					Usage="M"
		Module="SlideCoordinates"			Usage="M"
		Module="OverlayPlane"				Usage="U"	Condition="NeedModuleOverlayPlane"
		Module="CheckSingleFramePseudo"		Usage="M"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="VLPhotographicImage"		Condition="VisibleLightPhotographicImageInstance"
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
		Module="VLPhotographicSeriesPseudo"	Usage="M"	# not in standard ... use to check conditions
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="AcquisitionContext"			Usage="M"	# not check for baseline CIDs yet
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="C"	Condition="NeedModuleSpecimen"	# real-world "is a specimen"
		Module="VLImage"					Usage="M"
		Module="OverlayPlane"				Usage="U"	Condition="NeedModuleOverlayPlane"
		Module="CheckSingleFramePseudo"		Usage="M"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="VideoEndoscopicImage"			Condition="VideoEndoscopicImageInstance"
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
		Module="VLEndoscopicSeriesPseudo"	Usage="M"	# not in standard ... use to check conditions
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="Cine"						Usage="M"
		Module="MultiFrame"					Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="AcquisitionContext"			Usage="M"	# no check for baseline CIDs yet
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="C"	Condition="NeedModuleSpecimen"	# real-world "is a specimen"
		Module="VLImage"					Usage="M"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="VideoMicroscopicImage"		Condition="VideoMicroscopicImageInstance"
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
		Module="VLMicroscopicSeriesPseudo"	Usage="M"	# not in standard ... use to check conditions
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="Cine"						Usage="M"
		Module="MultiFrame"					Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="AcquisitionContext"			Usage="M"	# not check for baseline CIDs yet
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="C"	Condition="NeedModuleSpecimen"	# real-world "is a specimen"
		Module="VLImage"					Usage="M"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="VideoPhotographicImage"		Condition="VideoPhotographicImageInstance"
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
		Module="VLPhotographicSeriesPseudo"	Usage="M"	# not in standard ... use to check conditions
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="Cine"						Usage="M"
		Module="MultiFrame"					Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="AcquisitionContext"			Usage="M"	# not check for baseline CIDs yet
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="C"	Condition="NeedModuleSpecimen"	# real-world "is a specimen"
		Module="VLImage"					Usage="M"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="OphthalmicPhotography8BitImage"		Condition="OphthalmicPhotography8BitImageInstance"
	InformationEntity="File"
		Module="FileMetaInformation"						Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"									Usage="M"
		Module="ClinicalTrialSubject"						Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd	
	InformationEntity="Study"
		Module="GeneralStudy"								Usage="M"
		Module="PatientStudy"								Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"							Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"								Usage="M"
		Module="OphthalmicPhotographySeries"				Usage="M"
		Module="ClinicalTrialSeries"						Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="Synchronization"							Usage="M"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"							Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"								Usage="M"
		Module="ImagePixel"									Usage="M"
		Module="EnhancedContrastBolus"						Usage="C"	Condition="NeedModuleEnhancedContrastBolus"
		Module="Cine"										Usage="C"	Condition="NeedModuleCine"
		Module="MultiFrame"									Usage="M"
		Module="OphthalmicPhotographyImage"					Usage="M"
		Module="OphthalmicPhotography8BitImagePseudo"		Usage="M"	# not in standard ... use to check bit depths
		Module="OcularRegionImaged"							Usage="M"
		Module="OphthalmicPhotographyAcquisitionParameters"	Usage="M"
		Module="OphthalmicPhotographicParameters"			Usage="M"
		Module="CheckSingleFramePseudo"						Usage="M"
		Module="SOPCommon"									Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="OphthalmicPhotography16BitImage"		Condition="OphthalmicPhotography16BitImageInstance"
	InformationEntity="File"
		Module="FileMetaInformation"						Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"									Usage="M"
		Module="ClinicalTrialSubject"						Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd	
	InformationEntity="Study"
		Module="GeneralStudy"								Usage="M"
		Module="PatientStudy"								Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"							Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"								Usage="M"
		Module="OphthalmicPhotographySeries"					Usage="M"
		Module="ClinicalTrialSeries"						Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="Synchronization"							Usage="M"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"							Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"								Usage="M"
		Module="ImagePixel"									Usage="M"
		Module="EnhancedContrastBolus"						Usage="C"	Condition="NeedModuleEnhancedContrastBolus"
		Module="Cine"										Usage="C"	Condition="NeedModuleCine"
		Module="MultiFrame"									Usage="M"
		Module="OphthalmicPhotographyImage"					Usage="M"
		Module="OphthalmicPhotography16BitImagePseudo"		Usage="M"	# not in standard ... use to check bit depths
		Module="OcularRegionImaged"							Usage="M"
		Module="OphthalmicPhotographyAcquisitionParameters"	Usage="M"
		Module="OphthalmicPhotographicParameters"			Usage="M"
		Module="CheckSingleFramePseudo"						Usage="M"
		Module="SOPCommon"									Usage="M"
	InformationEntityEnd
CompositeIODEnd


CompositeIOD="StereometricRelationship"			Condition="StereometricRelationshipInstance"
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
		Module="StereometricSeries"			Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="StereometricRelationship"	Usage="M"
		Module="CommonInstanceReference"	Usage="M"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="OphthalmicTomographyImage"		Condition="OphthalmicTomographyImageInstance"
	InformationEntity="File"
		Module="FileMetaInformation"						Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"									Usage="M"
		Module="ClinicalTrialSubject"						Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd	
	InformationEntity="Study"
		Module="GeneralStudy"								Usage="M"
		Module="PatientStudy"								Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"							Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"								Usage="M"
		Module="ClinicalTrialSeries"						Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="OphthalmicTomographySeries"					Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"							Usage="C"	Condition="NeedModuleFrameOfReference"			# condition is real-world (Ophthalmic Photography Reference Image available) ... just check if present
		Module="Synchronization"							Usage="C"	Condition="NeedToCheckModuleSynchronization"	# condition is real-world (Ophthalmic Photography Reference Image available) ... just check if present
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"							Usage="M"
		Module="EnhancedGeneralEquipment"					Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="ImagePixel"									Usage="M"
		Module="EnhancedContrastBolus"						Usage="C"	Condition="NeedModuleEnhancedContrastBolus"
		Module="MultiFrameFunctionalGroupsCommon"			Usage="M"
		Module="MultiFrameFunctionalGroupsForOphthalmicTomography"	Usage="M"
		Module="MultiFrameDimension"						Usage="M"
		Module="AcquisitionContext"							Usage="M"
		Module="CardiacSynchronization"						Usage="C"	Condition="NeedModuleCardiacSynchronization"
		Module="OphthalmicTomographyImage"					Usage="M"
		Module="OphthalmicTomographyAcquisitionParameters"	Usage="M"
		Module="OphthalmicTomographyParameters"				Usage="M"
		Module="OcularRegionImaged"							Usage="M"
		Module="SOPCommon"									Usage="M"
		Module="FrameExtraction"							Usage="C"	Condition="NeedModuleFrameExtraction"
	InformationEntityEnd
CompositeIODEnd



