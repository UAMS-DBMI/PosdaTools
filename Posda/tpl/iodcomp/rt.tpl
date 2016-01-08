#$Source: /home/bbennett/pass/archive/Posda/tpl/iodcomp/rt.tpl,v $
#$Date: 2010/04/30 18:53:53 $
#$Revision: 1.2 $
#
CompositeIOD="RTImage"		Condition="RTImageInstance"
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
		Module="RTSeries"					Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
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
		Module="ContrastBolus"				Usage="C"	Condition="NeedModuleContrastBolus"
		Module="Cine"						Usage="C"	Condition="NeedModuleCine"
		Module="MultiFrame"					Usage="C"	Condition="NeedModuleMultiFrame"
		Module="RTImage"					Usage="M"
		Module="ModalityLUT"				Usage="U"	Condition="NeedModuleModalityLUT"
		Module="VOILUT"						Usage="U"	Condition="NeedModuleVOILUT"
		Module="Approval"					Usage="U"	Condition="NeedModuleApproval"
		Module="SOPCommon"					Usage="M"
		Module="FrameExtraction"			Usage="C"	Condition="NeedModuleFrameExtraction"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="RTDose"		Condition="RTDoseInstance"
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
		Module="RTSeries"					Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="M"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Image"
		Module="GeneralImage"				Usage="C"	Condition="DoseDataGridbased"
		Module="ImagePlane"					Usage="C"	Condition="DoseDataGridbased"
		Module="ImagePixel"					Usage="C"	Condition="DoseDataGridbased"
		Module="MultiFrame"					Usage="C"	Condition="DoseDataGridbasedAndNeedModuleMultiFrame"
		Module="OverlayPlane"				Usage="U"	Condition="NeedModuleOverlayPlane"
		Module="MultiFrameOverlay"			Usage="U"	Condition="NeedModuleMultiFrameOverlay"
		Module="ModalityLUT"				Usage="U"	Condition="NeedModuleModalityLUT"
		Module="RTDose"						Usage="M"
		Module="RTDVH"						Usage="U"	Condition="NeedModuleRTDVH"
		Module="StructureSet"				Usage="C"	Condition="DoseDataPointsOrCurves"
		Module="ROIContour"					Usage="C"	Condition="DoseDataPointsOrCurves"
		Module="RTDoseROI"					Usage="C"	Condition="DoseDataPointsOrCurves"
		Module="SOPCommon"					Usage="M"
		Module="FrameExtraction"			Usage="C"	Condition="NeedModuleFrameExtraction"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="RTStructureSet"		Condition="RTStructureSetInstance"
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
		Module="RTSeries"					Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="StructureSet"
		Module="StructureSet"				Usage="M"
		Module="ROIContour"					Usage="M"
		Module="RTROIObservations"			Usage="M"
		Module="Approval"					Usage="U"	Condition="NeedModuleApproval"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="RTPlan"			Condition="RTPlanInstance"
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
		Module="RTSeries"					Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="U"	Condition="NeedModuleFrameOfReference"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Plan"
		Module="RTGeneralPlan"				Usage="M"
		Module="RTPrescription"				Usage="U"	Condition="NeedModuleRTPrescription"
		Module="RTToleranceTables"			Usage="U"	Condition="NeedModuleRTToleranceTables"
		Module="RTPatientSetup"				Usage="U"	Condition="NeedModuleRTPatientSetup"
		Module="RTFractionScheme"			Usage="U"	Condition="NeedModuleRTFractionScheme"
		Module="RTBeams"					Usage="C"	Condition="NeedRTBeams"
		Module="RTBrachyApplicationSetups"	Usage="C"	Condition="NeedRTBrachyApplicationSetups"
		Module="Approval"					Usage="U"	Condition="NeedModuleApproval"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="RTBeamsTreatmentRecord"			Condition="RTBeamsTreatmentRecordInstance"
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
		Module="RTSeries"						Usage="M"
		Module="ClinicalTrialSeries"			Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"				Usage="M"
	InformationEntityEnd
	InformationEntity="TreatmentRecord"
		Module="RTGeneralTreatmentRecord"		Usage="M"
		Module="RTPatientSetup"					Usage="U"	Condition="NeedModuleRTPatientSetup"
		Module="RTTreatmentMachineRecord"		Usage="M"
		Module="MeasuredDoseReferenceRecord"	Usage="U"	Condition="NeedModuleMeasuredDoseReferenceRecord"
		Module="CalculatedDoseReferenceRecord"	Usage="U"	Condition="NeedModuleCalculatedDoseReferenceRecord"
		Module="RTBeamsSessionRecord"			Usage="M"
		Module="RTTreatmentSummaryRecord"		Usage="U"	Condition="NeedModuleRTTreatmentSummaryRecord"
		Module="SOPCommon"						Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="RTBrachyTreatmentRecord"			Condition="RTBrachyTreatmentRecordInstance"
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
		Module="RTSeries"						Usage="M"
		Module="ClinicalTrialSeries"			Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"				Usage="M"
	InformationEntityEnd
	InformationEntity="TreatmentRecord"
		Module="RTGeneralTreatmentRecord"		Usage="M"
		Module="RTPatientSetup"					Usage="U"	Condition="NeedModuleRTPatientSetup"
		Module="RTTreatmentMachineRecord"		Usage="M"
		Module="MeasuredDoseReferenceRecord"	Usage="U"	Condition="NeedModuleMeasuredDoseReferenceRecord"
		Module="CalculatedDoseReferenceRecord"	Usage="U"	Condition="NeedModuleCalculatedDoseReferenceRecord"
		Module="RTBrachySessionRecord"			Usage="M"
		Module="RTTreatmentSummaryRecord"		Usage="U"	Condition="NeedModuleRTTreatmentSummaryRecord"
		Module="SOPCommon"						Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="RTTreatmentSummaryRecord"			Condition="RTTreatmentSummaryRecordInstance"
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
		Module="RTSeries"					Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="TreatmentRecord"
		Module="RTGeneralTreatmentRecord"	Usage="M"
		Module="RTTreatmentSummaryRecord"	Usage="U"	Condition="NeedModuleRTTreatmentSummaryRecord"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="RTIonPlan"			Condition="RTIonPlanInstance"
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
		Module="RTSeries"					Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="FrameOfReference"			Usage="M"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Plan"
		Module="RTGeneralPlan"				Usage="M"
		Module="RTPrescription"				Usage="U"	Condition="NeedModuleRTPrescription"
		Module="RTIonToleranceTables"		Usage="U"	Condition="NeedModuleRTIonToleranceTables"
		Module="RTPatientSetup"				Usage="U"	Condition="NeedModuleRTPatientSetup"
		Module="RTFractionScheme"			Usage="U"	Condition="NeedModuleRTFractionScheme"
		Module="RTIonBeams"					Usage="C"	Condition="NeedRTIonBeams"
		Module="Approval"					Usage="U"	Condition="NeedModuleApproval"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="RTIonBeamsTreatmentRecord"			Condition="RTIonBeamsTreatmentRecordInstance"
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
		Module="RTSeries"						Usage="M"
		Module="ClinicalTrialSeries"			Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"				Usage="M"
	InformationEntityEnd
	InformationEntity="TreatmentRecord"
		Module="RTGeneralTreatmentRecord"		Usage="M"
		Module="RTPatientSetup"					Usage="U"	Condition="NeedModuleRTPatientSetup"
		Module="RTTreatmentMachineRecord"		Usage="M"
		Module="MeasuredDoseReferenceRecord"	Usage="U"	Condition="NeedModuleMeasuredDoseReferenceRecord"
		Module="CalculatedDoseReferenceRecord"	Usage="U"	Condition="NeedModuleCalculatedDoseReferenceRecord"
		Module="RTIonBeamsSessionRecord"		Usage="M"
		Module="RTTreatmentSummaryRecord"		Usage="U"	Condition="NeedModuleRTTreatmentSummaryRecord"
		Module="SOPCommon"						Usage="M"
	InformationEntityEnd
CompositeIODEnd

