-- Deploy posda:spreadsheet to pg

BEGIN;

CREATE TABLE spreadsheet_operation (
    operation_name text NOT NULL PRIMARY KEY,
    command_line text,
    operation_type text,
    input_line_format text,
    tags text[]
);

COPY spreadsheet_operation (operation_name, command_line, operation_type, input_line_format, tags) FROM stdin;
SeriesConsistency	CheckSeriesConsistency.pl <series_instance_uid>	legacy	\N	\N
StudyConsistency	CheckStudyConsistency.pl <study_instance_uid>	legacy	\N	\N
PatConsistency	CheckPatConsistency.pl "<collection>" <patient_id>	legacy	\N	\N
SendSeriesToDestination	SendSetOfSeriesToDestination.pl <host> <port> <called> <calling> <user> "<reason>"	legacy	<series_instance_uid>	\N
ScanPhi	PhiScan.pl <type> "<description>"	legacy	<series_instance_uid>, <signature>	\N
OnlyIn	OnlyIn.pl Posda Intake	legacy	<SeriesInPosda>, <SeriesInIntake>	\N
CompareDuplicateSops	CompareDupSopList.pl	legacy	<sop_instance_uid>	\N
TestCommand	TestCommand.pl <host> <port> <called> <calling> <series_instance_uid>	legacy	\N	\N
PipeCommand1	PipeCommand1.pl <var1> <var2> 1 2 3	legacy	<vals1>,<vals2>,<vals3>	\N
SymLinkToIntake	SymLinkToIntake.pl /cache/bbennett/Symlinks	legacy	<PID>, <Modality>, <SopInstance>, <FilePath>	\N
LinkDirectory	MakeLinkedDirectory.pl <target_dir>	legacy	<path>, <sop_instance_uid>	\N
AddInitialStatus	PopulatePatStat.pl	legacy	<patient_id>, <status>	\N
ChangePatientStatus	UpdatePatStat.pl <who> "<why>"	legacy	<patient_id>, <old_status>, <new_status>	\N
UpdateKnowlegeBase	UpdateKnowledgeBase.pl <who> "<why>"	legacy	<Tag>^<VR>^<Disposition>^<NameChain>	\N
LinkFileHierarchy	LinkFileHierarchy.pl <Destination>	legacy	<patient_id>  <study_instance_uid> <series_instance_uid>	\N
ApplyPrivateDisposition	CsvApplyPrivateDisposition.pl <dest_dir> <uid_root> <offset> <low_date> <high_date>	legacy	<patient_id>&<study_instance_uid>&<series_instance_uid>	\N
ApplyPublicPrivateDisposition	CsvApplyPrivateDisposition.pl <dest_dir> <uid_root> <offset> <low_date> <high_date>	legacy	<patient_id>&<study_instance_uid>&<series_instance_uid>	\N
HideSeriesWithStatus	HideBatchSeriesWithStatus.pl <who> "<why>"	legacy	<series_instance_uid>	\N
CreatePublicDispositionTable	CreatePublicDispositionTable.pl <sop_class_uid> "<Description>" <who>	legacy	<Tag>^<VR>^<Disposition>^<NameChain>	\N
UpdateCollectionPrio	UpdateBacklogPriorities.pl	legacy	<collection>&<priority>	\N
\.


COMMIT;
