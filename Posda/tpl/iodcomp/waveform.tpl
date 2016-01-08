#$Source: /home/bbennett/pass/archive/Posda/tpl/iodcomp/waveform.tpl,v $
#$Date: 2009/03/25 14:03:35 $
#$Revision: 1.1 $
#
CompositeIOD="BasicVoice"		Condition="BasicVoiceInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd	
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="Synchronization"			Usage="U"	Condition="NeedToCheckModuleSynchronization"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Waveform"
		Module="WaveformIdentification"		Usage="M"
		Module="Waveform"					Usage="M"
		Module="AcquisitionContext"			Usage="M"
		Module="WaveformAnnotation"			Usage="U"	Condition="NeedModuleWaveformAnnotation"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="TwelveLeadECG"				Condition="TwelveLeadECGInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd	
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="Synchronization"			Usage="U"	Condition="NeedToCheckModuleSynchronization"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Waveform"
		Module="WaveformIdentification"		Usage="M"
		Module="Waveform"					Usage="M"
		Module="AcquisitionContext"			Usage="M"
		Module="WaveformAnnotation"			Usage="C"	Condition="NeedModuleWaveformAnnotation"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="GeneralECG"				Condition="GeneralECGInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd	
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="Synchronization"			Usage="U"	Condition="NeedToCheckModuleSynchronization"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Waveform"
		Module="WaveformIdentification"		Usage="M"
		Module="Waveform"					Usage="M"
		Module="AcquisitionContext"			Usage="M"
		Module="WaveformAnnotation"			Usage="C"	Condition="NeedModuleWaveformAnnotation"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="AmbulatoryECG"				Condition="AmbulatoryECGInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd	
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="Synchronization"			Usage="U"	Condition="NeedToCheckModuleSynchronization"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Waveform"
		Module="WaveformIdentification"		Usage="M"
		Module="Waveform"					Usage="M"
		Module="AcquisitionContext"			Usage="M"
		Module="WaveformAnnotation"			Usage="C"	Condition="NeedModuleWaveformAnnotation"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="HemodynamicWaveform"			Condition="HemodynamicWaveformInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd	
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="Synchronization"			Usage="C"	Condition="ReallyNeedModuleSynchronization"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Waveform"
		Module="WaveformIdentification"		Usage="M"
		Module="Waveform"					Usage="M"
		Module="AcquisitionContext"			Usage="M"
		Module="WaveformAnnotation"			Usage="C"	Condition="NeedModuleWaveformAnnotation"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="CardiacElectrophysiologyWaveform"		Condition="CardiacElectrophysiologyWaveformInstance"
	InformationEntity="File"
		Module="FileMetaInformation"		Usage="C"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Patient"
		Module="Patient"					Usage="M"
		Module="ClinicalTrialSubject"		Usage="U"	Condition="NeedModuleClinicalTrialSubject"
	InformationEntityEnd	
	InformationEntity="Study"
		Module="GeneralStudy"				Usage="M"
		Module="PatientStudy"				Usage="U"
		Module="ClinicalTrialStudy"			Usage="U"	Condition="NeedModuleClinicalTrialStudy"
	InformationEntityEnd
	InformationEntity="Series"
		Module="GeneralSeries"				Usage="M"
		Module="ClinicalTrialSeries"		Usage="U"	Condition="NeedModuleClinicalTrialSeries"
	InformationEntityEnd
	InformationEntity="FrameOfReference"
		Module="Synchronization"			Usage="C"	Condition="ReallyNeedModuleSynchronization"
	InformationEntityEnd
	InformationEntity="Equipment"
		Module="GeneralEquipment"			Usage="M"
	InformationEntityEnd
	InformationEntity="Waveform"
		Module="WaveformIdentification"		Usage="M"
		Module="Waveform"					Usage="M"
		Module="AcquisitionContext"			Usage="M"
		Module="WaveformAnnotation"			Usage="C"	Condition="NeedModuleWaveformAnnotation"
		Module="SOPCommon"					Usage="M"
	InformationEntityEnd
CompositeIODEnd

