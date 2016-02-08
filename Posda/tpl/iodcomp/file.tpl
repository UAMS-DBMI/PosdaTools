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

