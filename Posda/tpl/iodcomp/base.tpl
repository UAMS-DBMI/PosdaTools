#
CompositeIOD="CRImage"			Condition="CRImageInstance"
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
		Module="CRSeries"					Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="C"	Condition="NeedModuleContrastBolus"
		Module="DisplayShutter"				Usage="U"	Condition="NeedModuleDisplayShutter"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="CRImage"					Usage="M"
		Module="OverlayPlane"				Usage="U"	Condition="NeedModuleOverlayPlane"
		Module="ModalityLUT"				Usage="U"	Condition="NeedModuleModalityLUT"
		Module="VOILUT"						Usage="U"	Condition="NeedModuleVOILUT"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="CTImage"			Condition="CTImageInstance"
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
		Module="ContrastBolus"				Usage="C"	Condition="NeedModuleContrastBolus"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="CTImage"					Usage="M"
		Module="OverlayPlane"				Usage="U"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="U"	Condition="NeedModuleVOILUT"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="MRImage"			Condition="MRImageInstance"
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
		Module="ContrastBolus"				Usage="C"	Condition="NeedModuleContrastBolus"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="MRImage"					Usage="M"
		Module="OverlayPlane"				Usage="U"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="U"	Condition="NeedModuleVOILUT"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="NMImage"			Condition="NMImageInstance"
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
		Module="NMPETPatientOrientation"	Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="AcquisitionContext"			Usage="U"	Condition="NeedModuleAcquisitionContext"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="NMImagePixel"				Usage="M"
		Module="MultiFrame"					Usage="M"
		Module="NMMultiFrame"				Usage="M"
		Module="NMImage"					Usage="M"
		Module="NMIsotope"					Usage="M"
		Module="NMDetector"					Usage="M"
		Module="NMTomoAcquisition"			Usage="C"	Condition="NeedModuleNMTomoAcquisition"
		Module="NMMultiGatedAcquisition"	Usage="C"	Condition="NeedModuleNMMultiGatedAcquisition"
		Module="NMPhase"					Usage="C"	Condition="NeedModuleNMPhase"
		Module="NMReconstruction"			Usage="C"	Condition="NeedModuleNMReconstruction"
		Module="OverlayPlane"				Usage="U"	Condition="NeedModuleOverlayPlane"
		Module="MultiFrameOverlay"			Usage="U"	Condition="NeedModuleMultiFrameOverlay"
		Module="VOILUT"						Usage="U"	Condition="NeedModuleVOILUT"
		Module="SOPCommon"					Usage="M"
		Module="FrameExtraction"			Usage="C"	Condition="NeedModuleFrameExtraction"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="USImage"			Condition="USImageInstance"
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
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
		Module="Synchronization"			Usage="U"	Condition="NeedToCheckModuleSynchronization"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="C"	Condition="NeedModuleContrastBolus"
		Module="PaletteColorLookupTable"	Usage="C"	Condition="PhotometricInterpretationIsPaletteColor"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="USRegionCalibration"		Usage="U"	Condition="NeedModuleUSRegionCalibration"
		Module="USImage"					Usage="M"
		Module="OverlayPlane"				Usage="U"	Condition="NeedModuleOverlayPlane"
		Module="VOILUT"						Usage="U"	Condition="NeedModuleVOILUT"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="USMultiFrameImage"	Condition="USMultiFrameImageInstance"
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
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
		Module="Synchronization"			Usage="C"	Condition="NeedModuleSynchronizationForIVUS"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="ContrastBolus"				Usage="C"	Condition="NeedModuleContrastBolus"
		Module="Cine"						Usage="M"
		Module="MultiFrame"					Usage="M"
		Module="FramePointers"				Usage="U"	Condition="NeedModuleFramePointers"
		Module="PaletteColorLookupTable"	Usage="C"	Condition="PhotometricInterpretationIsPaletteColor"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="USRegionCalibration"		Usage="U"	Condition="NeedModuleUSRegionCalibration"
		Module="USImage"					Usage="M"
		Module="VOILUT"						Usage="U"	Condition="NeedModuleVOILUT"
		Module="SOPCommon"					Usage="M"
		Module="FrameExtraction"			Usage="C"	Condition="NeedModuleFrameExtraction"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="SCImage"			Condition="SCImageInstance"
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
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="U"	Condition="NeedModuleGeneralEquipment"
		Module="SCEquipment"				Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="M"
		Module="ImagePixel"					Usage="M"
		Module="Device"						Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"					Usage="U"	Condition="NeedModuleSpecimen"
		Module="SCImage"					Usage="M"
		Module="OverlayPlane"				Usage="U"	Condition="NeedModuleOverlayPlane"
		Module="ModalityLUT"				Usage="U"	Condition="NeedModuleModalityLUT"
		Module="VOILUT"						Usage="U"	Condition="NeedModuleVOILUT"
		Module="SOPCommon"					Usage="M"
		Module="CheckSingleFramePseudo"		Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="MultiframeSingleBitSCImage"			Condition="MultiframeSingleBitSCImageInstance"
	InformationEntity="File"
		Module="FileMetaInformation"				Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"							Usage="M"
		Module="ClinicalTrialSubject"				Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"						Usage="M"
		Module="PatientStudy"						Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"					Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"						Usage="M"
		Module="ClinicalTrialSeries"				Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"					Usage="U"	Condition="NeedModuleGeneralEquipment"
		Module="SCEquipment"						Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"						Usage="M"
		Module="ImagePixel"							Usage="M"
		Module="Cine"								Usage="C"	Condition="NeedModuleCineForSC"
		Module="MultiFrame"							Usage="M"
		Module="FramePointers"						Usage="U"	Condition="NeedModuleFramePointers"
		Module="Device"								Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"							Usage="U"	Condition="NeedModuleSpecimen"
		Module="SCImage"							Usage="U"
		Module="SCMultiFrameImage"					Usage="M"
		Module="SCMultiFrameVector"					Usage="C"	Condition="NumberOfFramesGreaterThanOne"
		Module="SOPCommon"							Usage="M"
		Module="FrameExtraction"						Usage="C"	Condition="NeedModuleFrameExtraction"
		Module="MultiframeSingleBitSCImagePseudo"	Usage="M"
		# how to forbid presence of VOI LUT Module and Overlay Module :( ?
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="MultiframeGrayscaleByteSCImage"			Condition="MultiframeGrayscaleByteSCImageInstance"
	InformationEntity="File"
		Module="FileMetaInformation"					Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"								Usage="M"
		Module="ClinicalTrialSubject"					Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"							Usage="M"
		Module="PatientStudy"							Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"						Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"							Usage="M"
		Module="ClinicalTrialSeries"					Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"						Usage="U"	Condition="NeedModuleGeneralEquipment"
		Module="SCEquipment"							Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"							Usage="M"
		Module="ImagePixel"								Usage="M"
		Module="Cine"									Usage="C"	Condition="NeedModuleCineForSC"
		Module="MultiFrame"								Usage="M"
		Module="FramePointers"							Usage="U"	Condition="NeedModuleFramePointers"
		Module="Device"									Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"								Usage="U"	Condition="NeedModuleSpecimen"
		Module="SCImage"								Usage="U"
		Module="SCMultiFrameImage"						Usage="M"
		Module="SCMultiFrameVector"						Usage="C"	Condition="NumberOfFramesGreaterThanOne"
		Module="VOILUT"									Usage="C"	Condition="NeedModuleVOILUT"
		Module="SOPCommon"								Usage="M"
		Module="FrameExtraction"						Usage="C"	Condition="NeedModuleFrameExtraction"
		Module="MultiframeGrayscaleByteSCImagePseudo"	Usage="M"
		# how to forbid presence of Overlay Module :( ?
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="MultiframeGrayscaleWordSCImage"			Condition="MultiframeGrayscaleWordSCImageInstance"
	InformationEntity="File"
		Module="FileMetaInformation"					Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"								Usage="M"
		Module="ClinicalTrialSubject"					Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"							Usage="M"
		Module="PatientStudy"							Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"						Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"							Usage="M"
		Module="ClinicalTrialSeries"					Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"						Usage="U"	Condition="NeedModuleGeneralEquipment"
		Module="SCEquipment"							Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"							Usage="M"
		Module="ImagePixel"								Usage="M"
		Module="Cine"									Usage="C"	Condition="NeedModuleCineForSC"
		Module="MultiFrame"								Usage="M"
		Module="FramePointers"							Usage="U"
		Module="Device"									Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"								Usage="U"	Condition="NeedModuleSpecimen"
		Module="SCImage"								Usage="U"
		Module="SCMultiFrameImage"						Usage="M"
		Module="SCMultiFrameVector"						Usage="C"	Condition="NumberOfFramesGreaterThanOne"
		Module="VOILUT"									Usage="C"	Condition="NeedModuleVOILUT"
		Module="SOPCommon"								Usage="M"
		Module="FrameExtraction"						Usage="C"	Condition="NeedModuleFrameExtraction"
		Module="MultiframeGrayscaleWordSCImagePseudo"	Usage="M"
		# how to forbid presence of Overlay Module :( ?
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="MultiframeTrueColorSCImage"				Condition="MultiframeTrueColorSCImageInstance"
	InformationEntity="File"
		Module="FileMetaInformation"					Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"								Usage="M"
		Module="ClinicalTrialSubject"					Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"							Usage="M"
		Module="PatientStudy"							Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"						Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"							Usage="M"
		Module="ClinicalTrialSeries"					Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"						Usage="U"	Condition="NeedModuleGeneralEquipment"
		Module="SCEquipment"							Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"							Usage="M"
		Module="ImagePixel"								Usage="M"
		Module="Cine"									Usage="C"	Condition="NeedModuleCineForSC"
		Module="MultiFrame"								Usage="M"
		Module="FramePointers"							Usage="U"
		Module="Device"									Usage="U"	Condition="NeedModuleDevice"
		Module="Specimen"								Usage="U"	Condition="NeedModuleSpecimen"
		Module="SCImage"								Usage="U"
		Module="SCMultiFrameImage"						Usage="M"
		Module="SCMultiFrameVector"						Usage="C"	Condition="NumberOfFramesGreaterThanOne"
		Module="SOPCommon"								Usage="M"
		Module="FrameExtraction"						Usage="C"	Condition="NeedModuleFrameExtraction"
		Module="MultiframeTrueColorSCImagePseudo"		Usage="M"
		# how to forbid presence of VOI LUT Module and Overlay Module :( ?
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="StandaloneOverlay"		Condition="StandaloneOverlayInstance"	Retired="true"
	InformationEntity="File"
		Module="FileMetaInformation"	Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"				Usage="M"
		Module="ClinicalTrialSubject"	Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"			Usage="M"
		Module="PatientStudy"			Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"		Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"			Usage="M"
		Module="ClinicalTrialSeries"	Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"		Usage="M"
	InformationEntityEnd
	InformationEntity="Overlay"
		Module="OverlayIdentification"	Usage="M"
		Module="OverlayPlane"			Usage="M"
		Module="SOPCommon"				Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="StandaloneCurve"			Condition="StandaloneCurveInstance"	Retired="true"
	InformationEntity="File"
		Module="FileMetaInformation"	Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"				Usage="M"
		Module="ClinicalTrialSubject"	Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"			Usage="M"
		Module="PatientStudy"			Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"		Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"			Usage="M"
		Module="ClinicalTrialSeries"	Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"		Usage="M"
	InformationEntityEnd
	InformationEntity="Curve"
		Module="CurveIdentification"	Usage="M"
		Module="Curve"					Usage="M"
		Module="SOPCommon"				Usage="M"
	InformationEntityEnd
CompositeIODEnd


CompositeIOD="StandaloneModalityLUT"	Condition="StandaloneModalityLUTInstance"	Retired="true"
	InformationEntity="File"
		Module="FileMetaInformation"	Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"				Usage="M"
		Module="ClinicalTrialSubject"	Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"			Usage="M"
		Module="PatientStudy"			Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"		Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"			Usage="M"
		Module="ClinicalTrialSeries"	Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"		Usage="M"
	InformationEntityEnd
	InformationEntity="ModalityLUT"
		Module="ModalityLUT"			Usage="M"
		Module="LUTIdentification"		Usage="M"
		Module="SOPCommon"				Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="StandaloneVOILUT"			Condition="StandaloneVOILUTInstance"	Retired="true"
	InformationEntity="File"
		Module="FileMetaInformation"	Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"				Usage="M"
		Module="ClinicalTrialSubject"	Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"			Usage="M"
		Module="PatientStudy"			Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"		Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"			Usage="M"
		Module="ClinicalTrialSeries"	Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"		Usage="M"
	InformationEntityEnd
	InformationEntity="VOILUT"
		Module="VOILUT"					Usage="M"
		Module="LUTIdentification"		Usage="M"
		Module="SOPCommon"				Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="Segmentation"				Condition="SegmentationInstance"
	InformationEntity="File"
		Module="FileMetaInformation"					Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"								Usage="M"
		Module="ClinicalTrialSubject"					Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"							Usage="M"
		Module="PatientStudy"							Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"						Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"							Usage="M"
		Module="ClinicalTrialSeries"					Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="SegmentationSeries"						Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"						Usage="C"	Condition="DerivationImageFunctionalGroupNotPresent"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"						Usage="M"
		Module="EnhancedGeneralEquipment"				Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"									Usage="M"
		Module="ImagePixel"										Usage="M"
		Module="SegmentationImage"								Usage="M"
		Module="CommonInstanceReference"						Usage="C"	Condition="DerivationImageFunctionalGroupPresent"
		Module="MultiFrameFunctionalGroupsCommon"				Usage="M"
		Module="MultiFrameFunctionalGroupsForSegmentation"		Usage="M"
		Module="MultiFrameDimension"							Usage="M"
		Module="Specimen"										Usage="U"	Condition="NeedModuleSpecimen"
		Module="SOPCommon"										Usage="M"
		Module="FrameExtraction"								Usage="C"	Condition="NeedModuleFrameExtraction"
		# how to forbid presence of VOI LUT Module and Overlay Module :( ?
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="SpatialRegistration"			Condition="SpatialRegistrationInstance"
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
		Module="SpatialRegistrationSeries"	Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="M"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="SpatialRegistration"
		Module="SpatialRegistration"		Usage="M"
		Module="CommonInstanceReference"	Usage="M"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="DeformableSpatialRegistration"			Condition="DeformableSpatialRegistrationInstance"
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
		Module="SpatialRegistrationSeries"	Usage="M"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="M"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
		Module="EnhancedGeneralEquipment"	Usage="M"
	InformationEntityEnd
	InformationEntity="SpatialRegistration"
		Module="DeformableSpatialRegistration"	Usage="M"
		Module="CommonInstanceReference"		Usage="M"
		Module="SOPCommon"						Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="SpatialFiducials"				Condition="SpatialFiducialsInstance"
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
		Module="SpatialFiducialsSeries"		Usage="M"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="SpatialFiducials"
		Module="SpatialFiducials"			Usage="M"
		Module="CommonInstanceReference"	Usage="M"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="EncapsulatedPDF"				Condition="EncapsulatedPDFInstance"
	InformationEntity="File"
		Module="FileMetaInformation"			Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"						Usage="M"
		Module="ClinicalTrialSubject"			Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"					Usage="M"
		Module="PatientStudy"					Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"				Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="EncapsulatedDocumentSeries"		Usage="M"
		Module="ClinicalTrialSeries"			Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"				Usage="M"
		Module="SCEquipment"					Usage="M"
	InformationEntityEnd
	InformationEntity="EncapsulatedDocument"
		Module="EncapsulatedDocument"			Usage="M"
		Module="EncapsulatedDocumentPDFPseudo"	Usage="M"
		Module="SOPCommon"						Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="EncapsulatedCDA"					Condition="EncapsulatedCDAInstance"
	InformationEntity="File"
		Module="FileMetaInformation"			Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"						Usage="M"
		Module="ClinicalTrialSubject"			Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"					Usage="M"
		Module="PatientStudy"					Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"				Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="EncapsulatedDocumentSeries"		Usage="M"
		Module="ClinicalTrialSeries"			Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"				Usage="M"
		Module="SCEquipment"					Usage="M"
	InformationEntityEnd
	InformationEntity="EncapsulatedDocument"
		Module="EncapsulatedDocument"			Usage="M"
		Module="EncapsulatedDocumentCDAPseudo"	Usage="M"
		Module="SOPCommon"						Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="RealWorldValueMapping"				Condition="RealWorldValueMappingInstance"
	InformationEntity="File"
		Module="FileMetaInformation"			Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"						Usage="M"
		Module="ClinicalTrialSubject"			Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd
	InformationEntity="Study"
		Module="GeneralStudy"					Usage="M"
		Module="PatientStudy"					Usage="U"	# no condition ... all attributes type 3
		Module="ClinicalTrialStudy"				Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"					Usage="M"
		Module="ClinicalTrialSeries"			Usage="U"	Condition="NeedModuleClinicalTrialSeries"
		Module="RealWorldValueMappingSeries"	Usage="M"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"				Usage="M"
	InformationEntityEnd
	InformationEntity="RealWorldValueMapping"
		Module="RealWorldValueMapping"			Usage="M"
		Module="CommonInstanceReference"		Usage="M"
		Module="SOPCommon"						Usage="M"
	InformationEntityEnd
CompositeIODEnd

