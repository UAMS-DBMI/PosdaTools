#$Source: /home/bbennett/pass/archive/Posda/tpl/iodcomp/file.tpl,v $
#$Date: 2009/03/25 14:02:28 $
#$Revision: 1.1 $
#
CompositeIOD="BasicDirectory"					Condition="MediaStorageDirectoryInstance"
	InformationEntity="File"
		Module="FileMetaInformation"			Usage="M"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Directory"
		Module="FileSetIdentification"			Usage="M"
		Module="DirectoryInformation"			Usage="U"
	InformationEntityEnd
CompositeIODEnd

CompositeIOD="BasicDirectoryDental"				Condition="MediaStorageDirectoryInstance"	Profile="Dental"
	InformationEntity="File"
		Module="FileMetaInformation"			Usage="M"	Condition="NeedModuleFileMetaInformation"
	InformationEntityEnd
	InformationEntity="Directory"
		Module="FileSetIdentification"			Usage="M"
		Module="DirectoryInformation"			Usage="U"
		Module="DirectoryInformationDental"		Usage="U"
	InformationEntityEnd
CompositeIODEnd

