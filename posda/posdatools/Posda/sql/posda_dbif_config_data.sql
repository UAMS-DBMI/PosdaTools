\connect posda_files
--
-- PostgreSQL database dump
--

-- Dumped from database version 13.6
-- Dumped by pg_dump version 13.1 (Ubuntu 13.1-1.pgdg18.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: background_buttons; Type: TABLE DATA; Schema: dbif_config; Owner: -
--

COPY dbif_config.background_buttons (background_button_id, operation_name, object_class, button_text, tags) FROM stdin;
25	QuickCheckPublicPosdaConsistLike	Posda::ProcessPopup	Quick Public Posda Like Collection	{public_posda_consistency}
29	UpdateActivityTimepoint	Posda::ProcessPopup	Update Activity Timepoint	{activity_timepoints}
27	CreateActivityTimepointFromCollectionSite	Posda::ProcessPopup	Create Activity Timepoint	{activity_timepoints}
28	FixBadSopInstanceLungFusedCtPathology	Posda::ProcessPopup	Fix Bad SOP Instances in Lung-Fused-CT-Pathology	{"Curation of Lung-Fused-CT-Pathology"}
30	VisualReviewFromTimepoint	Posda::ProcessPopup	Schedule Visual Review	{activity_timepoints}
31	PhiReviewFromTimepoint	Posda::ProcessPopup	Schedule PHI Scan	{activity_timepoints}
32	ConsistencyFromTimePoint	Posda::ProcessPopup	Check Consistency	{activity_timepoints}
33	LinkRtFromTimepoint	Posda::ProcessPopup	Link RT Data for ItcTools	{activity_timepoints}
34	CheckStructLinkagesTp	Posda::ProcessPopup	Check Structure Set Linkages	{activity_timepoints}
35	DispositionNeededWorksheet	Posda::ProcessPopup	Make Worksheet for Diapositions Needed	{phi_maint}
36	PhiPublicScanTp	Posda::ProcessPopup	Public Phi Scan Based on Current TP by Activity	{activity_timepoints}
37	SummarizeStructLinkage	Posda::ProcessPopup	Summarize Structure Set Linkages for a File	{activity_timepoint_support}
38	BackgroundDciodvfyTp	Posda::ProcessPopup	Run Dciodvfy for Time Point	{activity_timepoints}
39	CondensedActivityTimepointReport	Posda::ProcessPopup	Produce Condensed Activity Timepoint Report	{activity_timepoints}
26	AnalyzeSeriesDuplicates	Posda::ProcessPopup	Analyze Series With Duplicates	{"ACRIN-FMISO-Brain Duplicate Elimination",dup_sops,activity_timepoint_support}
40	FilesInTpNotInPublic	Posda::ProcessPopup	Find Files in Tp, not in Public	{activity_timepoints}
41	CompareSopsInTpToPublic	Posda::ProcessPopup	Compare Corresponding SOPs in Time Point to Public	{activity_timepoints}
42	AnalyzeSeriesDuplicatesForTimepoint	Posda::ProcessPopup	Analyze Series In Time Point with Duplicates	{activity_timepoint_support}
43	CompareSopsTpPosdaPublic	Posda::ProcessPopup	Compare Sops in Timepoint, Posda, and Public	{activity_timepoint_support}
44	FixFilesWithNullNumberOfFrames	Posda::ProcessPopup	Fix Files With Null Number of Frames	{Exceptional-Responders_NCI_Oct2018_curation}
45	FixCtInExceptionalRespondersWithNullNumberOfFrames	Posda::ProcessPopup	Fix CT Files in Exceptional-Responders with Null Number of Frames	{Exceptional-Responders_NCI_Oct2018_curation}
46	PrivateTagReports	Posda::ProcessPopup	Create Private Tag Vr and Disposition Reports	{phi_maint}
47	BackgroundPrivateDispositionsTp	Posda::ProcessPopup	Apply Background Dispositions To Timepoint (non baseline date)	{activity_timepoints}
48	BackgroundPrivateDispositionsTpBaseline	Posda::ProcessPopup	Apply Background Dispositions To Timepoint (baseline date)	{activity_timepoints}
49	MakeWeeklyFilesReport	Posda::ProcessPopup	Generate Report of File Uploads By Type By Week	{downloads_by_date}
50	CompareSopsTpPosdaPublicLike	Posda::ProcessPopup	Compare Sops in Timepoint, Posda, and Public like Collection	{activity_timepoint_support}
1	ImportFromDicomFileEdit	Posda::ProcessPopup	Import Edits	{edit_files}
2	CheckPublicMissingFilesInSeriesByCollection	Posda::ProcessPopup	Check Missing Files Public	{bills_test}
3	CopyCollectionToStaging	Posda::ProcessPopup	Copy Files To Dir	{bills_test}
4	CheckStructLinkagesByCollectionSite	Posda::ProcessPopup	Check Struct Links	{struct_linkages}
5	CheckPosdaPublicConsistency	Posda::ProcessPopup	Check Public Posda	{public_posda_consistency}
6	BackOutEdit	Posda::ProcessPopup	Backout Import Edits	{edit_files}
7	QuickCheckPosdaPublicConsistency	Posda::ProcessPopup	Quick Check Posda PUblic	{public_posda_consistency}
8	SetUpPublicToPosdaCopy	Posda::ProcessPopup	Set Up Copy of Collection From Public To Posda	{public_posda_consistency}
9	StartPublicToPosdaCopy	Posda::ProcessPopup	Start a waiting Public to Posda Copy	{public_posda_consistency}
10	DciodvfyReport	Posda::ProcessPopup	Dciodvfy Report	{dciodvfy}
11	StartFixPublicToPosdaCopy	Posda::ProcessPopup	Retry failed Public Copy	{public_posda_consistency}
12	LookForDupSopsInPublicByCollectionSite	Posda::ProcessPopup	Look for Conflicting Sops already in Public By Collection, Site	{comparing_posda_to_public}
13	DeletePvtExceptCtp	Posda::ProcessPopup	Copy Collection to Scratch Deleting All Private tags exept CTP tags	{bills_test}
14	CheckRtReferenceChain	Posda::ProcessPopup	Check Rt Linkage Chain	{struct_linkages}
56	InitialAnonymizerCommandsTp	Posda::ProcessPopup	Produce Initial Anonymization File for Timepoint	{initial_anonymization,patient_mapping,activity_timepoints}
20	RejectEdits	Posda::ProcessPopup	Reject Edits	{find_patients,check_edits}
21	ImportEdits	Posda::ProcessPopup	Import Edits	{find_patients,check_edits}
22	CheckEditCurrent	Posda::ProcessPopup	Check If Edits Current	{find_patients,check_edits}
24	NonDicomPhiScan	Posda::ProcessPopup	Phi Scan of Non-Dicom Files	{non_dicom_phi}
18	ProcessVisualReview	Posda::ProcessPopup	Process Visual Review Results	{visual_review_new_workflow,visual_review_reports}
51	CompareSopsTpPosdaPublicCollectionLikeSiteEqual	Posda::ProcessPopup	Compare Sops in Timpoint, Posda, and Public like Collection for Site	{activity_timepoint_support}
52	AdHocReportForTracy	Posda::ProcessPopup	Make CPTAC Report	{clin_qual}
53	HideFilesVisbleInBadEquivalenceClassesByVisualReviewId	Posda::ProcessPopup	Hide Files in Equivalence Classes Marked Bad	{visual_review_status}
54	BackgroundLinkActivityToTemp	Posda::ProcessPopup	Link Files in Activity to Temp Directory	{send_series}
19	RepealEdits	Posda::ProcessPopup	Repeal Edits	{find_patients,check_edits,edit_status}
16	FirstPassPhiByCollection	Posda::ProcessPopup	First Pass Phi By Collection	{phi_status,simple_phi}
15	FirstPassPhiScanAndReport	Posda::ProcessPopup	First Pass Phi by collection, site and (optional) batch	{phi_status,simple_phi}
17	FullPhiById	Posda::ProcessPopup	Full Phi Report by Scan Id	{phi_status,simple_phi}
23	PhiPublicScan	Posda::ProcessPopup	Public Scan By Collection, Site	{phi_status,simple_phi}
55	CreateActivityTimepointFromImportName	Posda::ProcessPopup	Create Activity Timepoint From Import Description	{activity_timepoints}
\.


--
-- Data for Name: chained_query; Type: TABLE DATA; Schema: dbif_config; Owner: -
--

COPY dbif_config.chained_query (chained_query_id, from_query, to_query, caption) FROM stdin;
1	PixelTypes	FileIdByPixelType	files
2	HideEvents	HideEventInfo	Info
3	WhatHasComeInRecentlyWithSubject	ToExamineRecentFiles	files
4	CtSeriesWithCtImageInfoByCollection	CtImageDataConsistencyAcrossSeries	Image Data Consistent?
5	CtSeriesWithCtImageInfoByCollection	SeriesReport	rpt
6	QueriesRunning	GetQuery	drill
7	VisibleColSiteWithCtpLikeSite	DistinctSeriesByCollectionSite	Get Series
8	VisualReviewScanInstances	VisualReviewStatusById	Details
9	ListActivities	InboxContentByActivityId	Details
10	VisualReviewStatusById	VisualReviewStatusDetails	Details
11	ListOpenActivities	InboxContentByActivityId	Details
12	ListOpenActivities	CloseActivity	close
13	ListOpenActivitiesWithItems	InboxContentByActivityId	Details
14	ListOpenActivitiesWithItems	CloseActivity	close
15	ListClosedActivities	InboxContentByActivityId	Details
16	ListClosedActivitiesWithItems	ReOpenActivity	re-open
17	ListClosedActivitiesWithItems	InboxContentByActivityId	Details
18	ListClosedActivities	ReOpenActivity	re-open
19	ActivityStuffMoreWithEmailByUser	LinkEmailToActivity	file
20	ActivityStuffMoreWithEmailByUser	UnlinkEmailFromActivity	unfile
21	ActivityStuffMoreWithEmailByUserDateRange	LinkEmailToActivity	file
22	ActivityStuffMoreWithEmailByUserDateRange	UnlinkEmailFromActivity	unfile
\.


--
-- Data for Name: chained_query_cols_to_params; Type: TABLE DATA; Schema: dbif_config; Owner: -
--

COPY dbif_config.chained_query_cols_to_params (chained_query_id, from_column_name, to_parameter_name) FROM stdin;
1	samples_per_pixel	samples_per_pixel
1	bits_allocated	bits_allocated
1	bits_stored	bits_stored
1	high_bit	high_bit
1	pixel_representation	pixel_representation
1	planar_configuration	planar_configuration
1	photometric_interpretation	photometric_interpretation
2	when_done	day_of_change
2	reason_for	reason_for
2	user_name	user_name
3	subj	patient_id
3	time	import_time_1
3	time	import_time_2
4	series_instance_uid	series_instance_uid
5	series_instance_uid	series_instance_uid
6	pid	pid
7	collection	project_name
7	site	site_name
8	id	id
9	activity_id	activity_id
12	activity_id	activity_id
12	activity_id	activity_id
13	activity_id	activity_id
14	activity_id	activity_id
15	activity_id	activity_id
16	activity_id	activity_id
17	activity_id	activity_id
10	review_status	review_status
10	processing_status	processing_status
10	id	visual_review_instance_id
10	dicom_file_type	dicom_file_type
11	activity_id	activity_id
18	activity_id	activity_id
19	user_inbox_content_id	user_inbox_content_id
20	activity_id	activity_id
20	user_inbox_content_id	user_inbox_content_id
21	activity_id	activity_id
21	user_inbox_content_id	user_inbox_content_id
22	activity_id	activity_id
22	user_inbox_content_id	user_inbox_content_id
\.


--
-- Data for Name: popup_buttons; Type: TABLE DATA; Schema: dbif_config; Owner: -
--

COPY dbif_config.popup_buttons (popup_button_id, name, object_class, btn_col, is_full_table, btn_name) FROM stdin;
2	SopsDupsInDifferentSeriesByCollectionSite	Posda::PopupImageViewer	file_id	f	View
3	SopsDupsInDifferentSeriesByCollectionSite	Posda::PopupCompare	sop_instance_uid	f	Compare
1	%EditResults%	Posda::PopupCompareFilesPath	\N	f	Compare Files
4	DupSopsByCollectionSiteDateRange	Posda::PopupCompare	sop_instance_uid	f	Compare
5	DuplicateFilesBySop	Posda::PopupCompare	sop_instance_uid	f	Compare
6	DuplicateFilesBySop	Posda::PopupCompare	sop_instance_uid	f	Compare
7	DuplicateFilesBySop	Posda::PopupCompare	sop_instance_uid	f	Compare
9	GetSimilarDupContourCounts	Posda::PopupCompare	\N	t	Compare
10	DistinctSeriesByCollection	Posda::ProcessPopup	\N	t	BackgroundPhiScan
11	DistinctSeriesByCollection	Posda::ProcessPopup	\N	t	BackgroundDciodvfySeries
12	DistinctSeriesByCollection	Posda::ProcessPopup	\N	t	DciodvfySeriesReport
13	DistinctStudySeriesByCollection	Posda::ProcessPopup	\N	t	BackgroundApplyPrivateDispositions
14	GetDoses	Posda::ProcessPopup	\N	t	BackgroundDoseLinkageCheck
15	GetPlans	Posda::ProcessPopup	\N	t	BackgroundPlanLinkageCheck
16	GetSsByCollection	Posda::ProcessPopup	\N	t	BackgroundStructLinkageCheck
17	DistinctStudySeriesByCollectionSite	Posda::ProcessPopup	\N	t	BackgroundApplyPrivateDispositions
18	DistinctSeriesByCollectionSite	Posda::ProcessPopup	\N	t	BackgroundPhiScan
19	DistinctSeriesByCollectionSite	Posda::ProcessPopup	\N	t	BackgroundDciodvfySeries
20	DistinctSeriesByCollectionSite	Posda::ProcessPopup	\N	t	DciodvfySeriesReport
21	DistinctSeriesByCollectionSitePublic	Posda::ProcessPopup	\N	t	BackgroundPhiScan
22	%	Quince	series_instance_uid	f	view
8	%	choose	file_id	f	view
73	foo	Posda::TestPopup	id	\N	test
74	VisualReviewStatusById	Posda::TestRedirectPopup	id	\N	review
67	VisualReviewScanInstances	Posda::ProcessPopup	fubar	f	CreateActivityTimepoint
36	ColSiteDetails	Posda::ProcessPopup	\N	t	PhiScan
37	DistinctSeriesByPatient	Posda::ProcessPopup	\N	t	LinkSeries
38	DistinctSeriesByPatient	Posda::ProcessPopup	\N	t	PhiScan
39	DistinctSeriesByPatientAdvanced	Posda::ProcessPopup	\N	t	CheckConsistency
40	DistinctSeriesByPatientAdvanced	Posda::ProcessPopup	\N	t	DicomValidation
41	DistinctSeriesByPatientAdvanced	Posda::ProcessPopup	\N	t	LinkForDownload
42	DistinctSeriesByPatientAdvanced	Posda::ProcessPopup	\N	t	PrivateDispositions
43	PatientDetailsWithBlankCtp	Posda::ProcessPopup	\N	t	InitialAnonymizerCommands
44	PatientDetailsWithNoCtp	Posda::ProcessPopup	\N	t	InitialAnonymizerCommands
45	SummaryOfToFiles	Posda::ProcessPopup	\N	t	LinkSeries
46	SummaryOfToFilesForPatient	Posda::ProcessPopup	\N	t	LinkSeries
63	InboxContentByActivityId	DbIf::ShowSubprocessLines	sub_id	\N	view
47	GetZipUploadEventsByDateRangeNonDicomOnly	Posda::ProcessPopup	\N	t	ProcessRADCOMPUpload
49	GetXlsToConvert	Posda::ProcessPopup	\N	t	XlsConverter
50	GetXlsxToConvert	Posda::ProcessPopup	\N	t	XlsxConverter
48	GetDocxToConvert	Posda::ProcessPopup	\N	t	RadcompSubmissionConverter
51	GeFromToFilesFromNonDicomEditCompare	choose_to	to_file_id	f	view
52	GeFromToFilesFromNonDicomEditCompare	choose_from	from_file_id	f	view
53	AllPatientDetailsWithNoCtpLike	Posda::ProcessPopup	\N	t	InitialAnonymizerCommands
55	DistinctSeriesByCollectionSite	Posda::ProcessPopup	\N	t	VisualReview
56	SeriesWithDupSopsByCollectionSiteNew	Posda::ProcessPopup	\N	t	AnalyzeSeriesDuplicates
57	GetFilesWithNoSeriesInfoByCollection	Posda::ProcessPopup	\N	t	BackgroundProcessModules
58	InboxContentAll	Posda::ProcessPopup	\N	t	FileAndDismissNotifications
59	VisualReviewStatusById	Posda::ProcessPopup	\N	t	MakePassThru
61	VisualReviewStatusById	Posda::ProcessPopup	\N	t	ProcessVisualReview
62	VisualReviewStatusById	Posda::ProcessPopup	\N	t	SendBlankToDest
64	VisualReviewStatusDetails	Posda::ProcessPopup	\N	t	RetryFailedProjections
54	InboxContentByActivityId	choose_spreadsheet	spreadsheet_file_id	\N	view
60	VisualReviewStatusDetails	Posda::ProcessPopup	\N	t	HideEquivalenceClasses
65	VisualReviewStatusDetails	Posda::ProcessPopup	\N	t	ChangeReviewStatus
66	VisualReviewStatusById	Posda::ProcessPopup	\N	t	ApplyDispositions
68	DistinctVisibleSeriesByCollectionSite	Posda::ProcessPopup	\N	t	CreateActivityTimepointFromSeriesList
69	DistinctSeriesByPatientId	Posda::ProcessPopup	\N	t	CreateActivityTimepointFromSeriesList
70	ListSrPublic	DbIf::ShowSr	dicom_file_uri	\N	view
71	ListSrPosda	DbIf::ShowSr	file_path	\N	view
72	ListSrPosdaHidden	DbIf::ShowSr	file_path	\N	view
75	GetEditStatusByDisposition	DbIf::EditStatus	id	f	info
35	AllPatientDetailsWithNoCtp%	Posda::ProcessPopup	\N	t	InitialAnonymizerCommands
\.


--
-- Data for Name: query_tabs; Type: TABLE DATA; Schema: dbif_config; Owner: -
--

COPY dbif_config.query_tabs (query_tab_name, query_tab_description, defines_dropdown, sort_order, defines_search_engine) FROM stdin;
count_check	for checking counts	t	10	f
curation	queries used in curation	t	20	f
scripting	queries used in scripts	t	50	f
db_admin	queries used for db_maintenance	t	30	f
legacy	compatable with old interface	t	90	f
bills_test_queries	Bills testing ground	t	100	f
Consistency	Consistency Checks	t	50	f
DicomValidation	DICOM validation (dciodvfy)	t	40	f
Finalize	Finalize, download, etc	t	60	f
PHI	used for PHI scans etc	t	30	f
Phi	Phi scanning and review operations	t	30	f
UploadedData	Operations on uploaded data	t	10	f
VisualReview	Visual review related operations	t	20	f
initial_upload	used in initial uploads of tar files	t	10	f
Activities	Operartions related to reviewing Acivities	t	60	f
View Structured Reports	View Structured Reports	t	1	f
Status	Collects Status Related Filters	t	60	f
\.


--
-- Data for Name: query_tabs_query_tag_filter; Type: TABLE DATA; Schema: dbif_config; Owner: -
--

COPY dbif_config.query_tabs_query_tag_filter (query_tab_name, filter_name, sort_order) FROM stdin;
count_check	view_posda_backlog	1
count_check	downloads_by_date	2
count_check	counts_patient_status	3
curation	duplicate_sop_evaluation	1
curation	duplicate_sop_resolution	2
curation	linkage_check	3
curation	consistency_check	4
scripting	used_in	1
curation	phi_review	5
curation	dicom_batch_file_editing	6
curation	send_data_via_dicom	6
db_admin	db_stats	10
curation	visual_review_scheduling	7
scripting	for_popups	2
db_admin	db_config	20
curation	dciodvfy	8
bills_test_queries	under_development	1
legacy	.Unlimited	1
legacy	.Show No Tags	1
legacy	universal	3
bills_test_queries	old_queries	10
bills_test_queries	linkage	3
scripting	for_public_posda_compare	3
bills_test_queries	posda_db_populate	4
bills_test_queries	copy_from_public	5
bills_test_queries	comparing_public_to_posda	6
db_admin	postgres_stats	30
bills_test_queries	for_ct_evaluation	50
bills_test_queries	subprocess	60
bills_test_queries	non_dicom_editing	70
bills_test_queries	database_fixup	80
UploadedData	with_ctp_anonymization	10
UploadedData	without_ctp_anonymization	20
bills_test_queries	bills_ad_hoc_scripts	90
VisualReview	select_for_visual_review	20
VisualReview	visual_review_status	30
VisualReview	visual_review_reports	40
bills_test_queries	activities	100
bills_test_queries	activity_based	200
Activities	activities	1
bills_test_queries	trace_edits	300
Phi	PhiStatus	1
Activities	activity_timepoints	2
View Structured Reports	View Structured Reports	1
scripting	dicom_file_table	4
Activities	activity_based	3
Status	edit_status	10
Status	visual_review_status	5
Status	phi_status	7
\.


--
-- Data for Name: query_tag_filter; Type: TABLE DATA; Schema: dbif_config; Owner: -
--

COPY dbif_config.query_tag_filter (filter_name, tags_enabled) FROM stdin;
.Show No Tags	{}
.Unlimited	{}
for_popups	{universal,used_in_process_popup}
view_posda_backlog	{backlog_analysis_reporting_tools,backlog_round_history,backlog_status,universal}
review_roles	{universal,roles}
visual_review_tracking_processing	{visual_review_results,universal}
send_data_via_dicom	{universal,search_series,send_series,send_directory}
manage_posda_backlog	{universal,backlog_status,backlog}
db_config	{query_tags,query_tabs,popups}
counts_patient_status	{universal,count_queries,patient_status,adding_ctp}
dciodvfy	{dciodvfy,universal}
duplicate_sop_evaluation	{universal,dup_sops,sops_different_series,series_report}
dicom_batch_file_editing	{hash_unhashed,hide_files,apply_disposition,universal,edit_files,show_hidden}
monthly_report_queries	{universal,end_of_month}
for_ct_evaluation	{ct_image_consistency}
database_fixup	{dicom_file_type,reimport_queries}
linkage_check	{universal,plan_linkages,dose_linkages,struct_linkages,dose_linkages}
used_in	{universal,used_in_simple_phi,used_in_file_import_into_posda,used_in_import_edited_files,used_in_reconcile_tag_names,used_processing_structure_set_linkages,used_in_phi_maint,used_in_background_processing,used_in_dciodvfy,used_in_file_migration,used_in_linkage_check}
visual_review_scheduling	{universal,visual_review,visual_review_new_workflow}
for_public_posda_compare	{public_posda_counts}
linkage	{used_in_dose_linkage_check,used_in_plan_linkage_check,used_in_structure_linkage_check,old_linkage_checks,used_in_struct_linkage_check}
subprocess	{subprocess}
consistency_check	{series_consistency,study_consistency,universal,public_posda_consistency}
old_queries	{for_bill,for_bill_counts,for_bill_study_consistency,for_bill_series_consistency,old_visibility}
posda_db_populate	{posda_db_populate}
copy_from_public	{copy_from_public}
comparing_public_to_posda	{comparing_posda_to_public}
db_stats	{q_stats,q_stats_by_date,q_list,queries,query_tags,universal,schema}
phi_review	{universal,phi_schedule,simple_phi,phi_maint,meta_q_queries,scan_status}
duplicate_sop_resolution	{universal,dup_sops,hide_dup_sops,distinguished_digest}
phi_status	{phi_status}
select_for_phi	{select_for_phi}
series_for_phi	{series_selection}
phi_reports	{phi_reports}
find_patients	{find_patients,mapping_tables,for_scripting}
download_results	{patient_queries}
visual_review_status	{visual_review_status,visual_review_new_workflow}
trace_edits	{trace_edits}
non_dicom_editing	{non_dicom_edit,non_dicom_phi,non_dicom_phi_status,non_dicom_import,non_dicom_reject,radcomp}
bills_ad_hoc_scripts	{bills_ad_hoc_scripts}
select_for_visual_review	{visual_review_selection}
visual_review_reports	{visual_review_reports}
with_ctp_anonymization	{ctp_patients,ctp_col_site,ctp_details,check_edits,hide,check_dups}
PhiStatus	{scan_status}
activities	{activities,activity_support}
without_ctp_anonymization	{no_ctp_patients,no_ctp_details,patient_mapping,insert_pat_mapping,import_event}
View Structured Reports	{view_structured_reports}
under_development	{universal,hide_events,bills_test,for_tracy,radcomp,non_dicom_phi,non_dicom_phi_status,non_dicom_edit,testing_edit_objects}
dicom_file_table	{adding_pixels_to_dicom_file}
downloads_by_date	{downloads_by_date,import_events,universal}
edit_status	{edit_status}
activity_timepoints	{activity_timepoints,activity_timepoint_support,compare_series,clin_qual,manifests}
activity_based	{"ACRIN-FMISO-Brain Duplicate Elimination","Curation of Lung-Fused-CT-Pathology","CPTAC Bolus September 2018","ACRIN-NSCLC-FDG-PET Curation",Exceptional-Responders_NCI_Oct2018_curation,"Test Case based on Soft-tissue-Sarcoma",QIN-GBM-DSC-MRI-DRO/Barrow,"Reconcile Public and Posda for CPTAC"}
postgres_stats	{database_size,table_size,postgres_query_stats,invoking_user}
\.


--
-- Data for Name: role; Type: TABLE DATA; Schema: dbif_config; Owner: -
--

COPY dbif_config.role (role_name) FROM stdin;
legacy_bbennett
legacy_ksmith01
legacy_priorf
legacy_rddobbins
legacy_smberryman
legacy_tracyn
workflow_1
curator
developer
SrViewer
\.


--
-- Data for Name: role_tabs; Type: TABLE DATA; Schema: dbif_config; Owner: -
--

COPY dbif_config.role_tabs (role_name, query_tab_name, sort_order) FROM stdin;
legacy_bbennett	UploadedData	10
legacy_bbennett	bills_test_queries	20
legacy_bbennett	count_check	30
legacy_bbennett	curation	40
legacy_bbennett	db_admin	50
legacy_bbennett	legacy	60
legacy_bbennett	scripting	70
legacy_ksmith01	bills_test_queries	10
legacy_ksmith01	count_check	20
legacy_ksmith01	curation	30
legacy_ksmith01	db_admin	40
legacy_ksmith01	legacy	50
legacy_ksmith01	scripting	60
legacy_priorf	count_check	10
legacy_priorf	curation	20
legacy_priorf	legacy	30
legacy_priorf	scripting	40
legacy_rddobbins	count_check	10
legacy_rddobbins	curation	20
legacy_rddobbins	db_admin	30
legacy_rddobbins	legacy	40
legacy_rddobbins	scripting	50
legacy_smberryman	curation	10
legacy_smberryman	legacy	20
legacy_tracyn	bills_test_queries	10
legacy_tracyn	count_check	20
legacy_tracyn	curation	30
legacy_tracyn	legacy	40
legacy_tracyn	scripting	50
curator	UploadedData	10
curator	VisualReview	20
curator	Phi	30
developer	bills_test_queries	20
developer	count_check	30
developer	curation	40
developer	db_admin	50
developer	legacy	60
developer	scripting	70
curator	Activities	40
SrViewer	View Structured Reports	1
curator	Status	30
\.


--
-- Data for Name: spreadsheet_operation; Type: TABLE DATA; Schema: dbif_config; Owner: -
--

COPY dbif_config.spreadsheet_operation (operation_name, command_line, operation_type, input_line_format, tags, can_chain, outdated, worker_priority) FROM stdin;
CompareDuplicateSops	CompareDupSopList.pl	legacy	<sop_instance_uid>	{dup_sops}	\N	f	0
ScanPhi	PhiScan.pl <type> "<description>"	legacy	<series_instance_uid>, <signature>	{phi_review}	\N	f	0
LinkDirectory	MakeLinkedDirectory.pl <target_dir>	legacy	<path>, <sop_instance_uid>	{send_series}	\N	f	0
AddInitialStatus	PopulatePatStat.pl	legacy	<patient_id>, <status>	{patient_status}	\N	f	0
ChangePatientStatus	UpdatePatStat.pl <who> "<why>"	legacy	<patient_id>, <old_status>, <new_status>	{patient_status}	\N	f	0
SendSeriesToDestination	SendSetOfSeriesToDestination.pl <host> <port> <called> <calling> <user> "<reason>"	legacy	<series_instance_uid>	{send_series}	\N	f	0
UpdateCollectionPrio	UpdateBacklogPriorities.pl	legacy	<collection>&<priority>	{backlog_status}	\N	f	0
RepairBadVrs	RepairBadVrs.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<file_id>	{update_timepoint,activities}	\N	f	0
CompareIntakeFilesToPublicFiles	CompareIntakeFilesToPublicFiles.pl <report_file> <notify>	legacy	<sop_instance_uid> <file_in_intake> <file_in_public>	{compare_collection_site}	\N	f	0
CompareDuplicateSopFirstInSeries	CompareDupSopSeriesList.pl	legacy	<series_instance_uid>	{dup_sops}	\N	f	0
BackgroundCompareDupSops	BackgroundCompareDupSopList.pl <file_name> "<notify>"	legacy	<sop_instance_uid>&<file_id>&<path>&<first_loaded>	{dup_sops}	\N	f	0
BackgroundCompareDuplicateSopFirstInSeries	BackgroundCompareDupSopSeriesList.pl <file_name> "<notify>"	legacy	<series_instance_uid>	{dup_sops}	\N	f	0
TdrAndPhiReports	PrepareTdrAndPhiReport.pl	legacy	<id>&<TdrReportFile>&<PhiReportFile>&<notify>	{phi_review}	\N	f	0
EquivalenceClasses	BatchCreateSeriesEquivalenceClasses.pl <notify>	legacy	<series_instance_uid>	{visual_review}	\N	f	0
BackgroundCompareSopsInMultipleSeries	BackgroundCompareSopsInMultipleSeries.pl <file_name> "<notify>"	legacy	<series_instance_uid>&<sop_instance_uid>&<file_id>&<file_path>	{sops_different_series}	\N	f	0
BulkHashStructUids	BulkHashStructUids.pl <dir> <uid_root> <notify>	legacy	<sop_instance_uid>	{hash_unhashed}	\N	f	0
BulkHashDoseLinks	BulkHashDoseLinks.pl <dir> <uid_root> <notify>	legacy	<sop_instance_uid>	{hash_unhashed}	\N	f	0
ScanDirPhi	PhiDirScan.pl <dir> "<description>"	legacy		{phi_review}	\N	f	0
UpdatePrivateDispositions	UpdatePrivateDisposition.pl <who> "<why>"	legacy	<element_signature>&<vr>&<disposition>	{phi_maint}	\N	f	0
SimplePhiScan	PhiSimpleScan.pl "<description>" <file_query_name> <notify>	legacy	<series_instance_uid>	{simple_phi}	\N	f	0
MakeWeeklyFilesReport	MakeWeeklyLoadReport.pl <?bkgrnd_id?> <notify> <from> <to>	background_process	\N	{downloads_by_date}	\N	f	0
BackgroundDciodvfySeries	BackgroundDciodvfySeries.pl <?bkgrnd_id?> "<description>" <type> <notify>	background_process	<series_instance_uid>	{dciodvfy}	\N	f	0
UpdateSimplePrivateDisposition	UpdateSimplePrivateDisposition.pl <who> "<why>"	legacy	<id>&<disp>	{phi_maint}	\N	f	0
HideSeriesWithStatus	HideBatchSeriesWithStatus.pl <who> "<why>"	legacy	<series_instance_uid>	{hide_files,hide_dup_sops}	\N	f	0
HideEarlyDupSopsInSeries	HideBatchEarlySopDupsInSeries.pl <who> "<why>"	legacy	<series_instance_uid>	{hide_files,hide_dup_sops}	\N	f	0
BackgroundPhiScan	PhiBackgroundScan.pl <?bkgrnd_id?> "<description>" <file_query_name> <notify>	background_process	<series_instance_uid>	{background,simple_phi}	\N	f	0
BackgroundCompareFromTo	BackgroundCompareFromToFiles.pl <?bkgrnd_id?> <notify>	background_process	<sop_instance_uid>&<from_file>&<to_file>	{dup_sops,edit_files}	\N	f	0
FindSeriesInScanWithPhi	FindSeriesInScanWithPhi.pl <?bkgrnd_id?> <scan_id> <notify>	background_process	<element>&<vr>&<value>&<description>	{simple_phi}	\N	f	0
ApplyPrivateDisposition	CsvApplyPrivateDisposition.pl <dest_dir> <uid_root> <offset> <low_date> <high_date>	legacy	<patient_id>&<study_instance_uid>&<series_instance_uid>	{send_series,apply_disposition}	\N	f	0
MakeSelectedTagValueReport	MakeSelectedTagValueReport.pl /cache/UserData/DbIf/PreparedReports/<report_file_name> <notify>	legacy	<element_signature>&<vr>&<disposition>&<name_chain>&<num_phi_values>&<num_simple_phi_values>	{phi_maint}	\N	f	0
MakeEditProposal	MakeEditProposal.pl <?bkgrnd_id?> <scan_id> <notify>	background_process	<element>&<vr>&<value>&<description>	{simple_phi}	\N	f	0
BatchEditBySop	BatchEditDicomFile.pl <?bkgrnd_id?> /nas/public/posda/edited/<rel_dest_root> <who> "<edit_description>" <notify>	background_process	<command>&<arg1>&<arg2>&<arg3>&<arg4>	{edit_files}	\N	f	0
HideFilesWithStatus	HideFilesWithStatus.pl <who> "<why>"	legacy	<file_id>&<old_visibility>	{hide_files,hide_dup_sops}	\N	f	0
ApplyHnsccEdits	ApplyHnsccEdits.pl	legacy	<new_file>&<element>&<new_value>	{}	\N	f	0
ApplyPublicPrivateDisposition	CsvApplyPublicAndPrivateDisposition.pl <dest_dir> <uid_root> <offset> <low_date> <high_date> <sop_class_uid> "<name>"	legacy	<patient_id>&<study_instance_uid>&<series_instance_uid>	{}	\N	f	0
CreatePublicDispositionTable	CreatePublicDispositionTable.pl <sop_class_uid> "<Description>" <who>	legacy	<Tag>^<VR>^<Disposition>^<NameChain>	{}	\N	f	0
ExtractZ	ExtractZ.pl	legacy	<file_id>&<unique_pixel_data_id>&<ipp>	{}	\N	f	0
LinkFileHierarchy	LinkFileHierarchy.pl <Destination>	legacy	<patient_id>  <study_instance_uid> <series_instance_uid>	{}	\N	f	0
OnlyIn	OnlyIn.pl Posda Intake	legacy	<SeriesInPosda>, <SeriesInIntake>	{}	\N	f	0
PatConsistency	CheckPatConsistency.pl "<collection>" <patient_id>	legacy		{}	\N	f	0
PipeCommand1	PipeCommand1.pl <var1> <var2> 1 2 3	legacy	<vals1>,<vals2>,<vals3>	{}	\N	f	0
SeriesConsistency	CheckSeriesConsistency.pl <series_instance_uid>	legacy		{}	\N	f	0
StudyConsistency	CheckStudyConsistency.pl <study_instance_uid>	legacy		{}	\N	f	0
SymLinkToIntake	SymLinkToIntake.pl /cache/bbennett/Symlinks	legacy	<PID>, <Modality>, <SopInstance>, <FilePath>	{}	\N	f	0
TestCommand	TestCommand.pl <host> <port> <called> <calling> <series_instance_uid>	legacy		{}	\N	f	0
UpdateKnowlegeBase	UpdateKnowledgeBase.pl <who> "<why>"	legacy	<Tag>^<VR>^<Disposition>^<NameChain>	{}	\N	f	0
UnHideFilesWithStatus	UnHideFilesWithStatus.pl <who> "<why>"	legacy	<file_id>&<old_visibility>	{hide_files,hide_dup_sops}	\N	f	0
SplitPdxPilot	GeneratePdxEdits.pl <?bkgrnd_id?> <rel_dest_root> <notify>	background_process	<patient_id>&<new_patient_id>&<new_study_desc>&<new_series_desc>	{bills_test}	\N	f	0
CheckCounts1	CompareCounts1.pl <?bkgrnd_id?> "<collection>" <uid_root> "<site>" "<notify>"	background_process	<id>&<study_instance_uid>&<series_instance_uid>&<num_files>	{bills_test}	\N	f	0
BackgroundDoseLinkageCheck	BackgroundDoseLinkageCheck.pl <?bkgrnd_id?> <notify_email>	background_process	<file_id>&<collection>&<site>&<patient_id>&<series_instance_uid>	{background}	\N	f	0
DciodvfySeriesReport	BackgroundDciodvfySeriesReport.pl <?bkgrnd_id?> "<description>" <scan_id> /cache/UserData/DbIf/PreparedReports/<report_file_name> <notify>	background_process	<series_instance_uid>	{dciodvfy}	\N	f	0
CopyBySeriesToScratch	CopyBySeriesToScratch.pl <to_dir> <notify>	legacy	<patient_id>&<study_instance_uid>&<series_instance_uid>	{send_series,apply_disposition}	\N	f	0
BackgroundPlanLinkageCheck	BackgroundPlanLinkageCheck.pl <?bkgrnd_id?> <notify_email>	background_process	<file_id>&<collection>&<site>&<patient_id>&<series_instance_uid>	{background}	\N	f	0
CompareSpreadsheetToPosda	compare_spreadsheet_to_posda.py <?bkgrnd_id?> "<collection>" "<site>" "<notify>"	background_process	<filename>,<collection>,<site>,<patient>,<series>,<sop>,<md5sum>,<size>	{background}	\N	f	0
SendPublicSeriesToDestination	SendPublicSetOfSeriesToDestination.pl <host> <port> <called> <calling>	legacy	<series_instance_uid>	{send_series}	\N	f	0
CompareSpreadsheetToIntake	compare_spreadsheet_to_intake.py <?bkgrnd_id?> "<collection>" "<site>" "<notify>"	background_process	<filename>,<collection>,<site>,<patient>,<series>,<sop>,<md5sum>,<size>	{background}	\N	f	0
BatchEditBySop2	BatchEditDicomFile2.pl <?bkgrnd_id?> /cache/UserData/DbIf/PreparedReports/<report_file> /nas/public/posda/edited/<rel_dest_root> <who> "<edit_description>" <notify>	background_process	<command>&<arg1>&<arg2>&<arg3>&<arg4>	{edit_files}	\N	f	0
BackgroundStructLinkageCheck	BackgroundStructLinkageCheck.pl <?bkgrnd_id?> <notify_email>	background_process	<file_id>&<collection>&<site>&<patient_id>&<series_instance_uid>	{background}	\N	f	0
BackgroundApplyPrivateDispositions	BackgroundApplyPrivateDispositions.pl <?bkgrnd_id?> <to_dir> <uid_root> <offset> <notify>	background_process	<patient_id>&<study_uid>&<series_uid>	{edit,send_series}	\N	f	0
SumPatients	SumPatients.pl <?bkgrnd_id?> "/cache/UserData/DbIf/PreparedReports/<report_file>" <notify>	background_process	<id>&<study>&<series>&<num_files>	{bills_test}	\N	f	0
BackgroundUpdatePrivatedDispositonVr	BackgroundUpdatePrivateDispositionsVr.pl <?bkgrnd_id?> "<why>" <notify>	background_process	<element_sig_pattern>&<vr>&<disp>	{phi_maint}	\N	f	0
TestNewDicomCompare	TestNewDicomCompare.pl <?bkgrnd_id?> <edit_file_id> <notify>	background_process	<sop_instance_uid>&<from_file>&<to_file>	{bills_test}	\N	f	0
CheckCounts	CompareCounts.pl <?bkgrnd_id?> "<collection>" "<site>" <notify>	background_process	<id>&<study>&<series>&<num_files>	{bills_test}	\N	f	0
ImportEditedFiles	ImportEditedFiles.pl <?bkgrnd_id?> <report_file_id> "/cache/UserData/DbIf/PreparedReports/<import_report>" "<edit_comment>" <notify>	background_process	<sop_instance_uid>&<from_digest>&<to_file>&<to_digest>&<status>	{edit_files}	\N	f	0
CheckCounts2	CompareCounts2.pl  <?bkgrnd_id?> "<collection>" <uid_root> "<site>" "<notify>"	background_process	<id>&<study_instance_uid>&<series_instance_uid>&<num_files>	{bills_test}	\N	f	0
FixAcrinFiles	CsvFixAcrin.pl <?bkgrnd_id?> <to_dir> <uid_root> <low_date> <high_date> <notify>	background_process	<patient_id>&<study_uid>&<series_uid>&<offset_pat_id>&<offset>	{bills_test}	\N	f	0
CheckPublicMissingFilesInSeriesByCollection	CheckPublicMissingFilesInSeriesByCollection.pl <?bkgrnd_id?> "<collection>" <notify>	background_process	\N	{bills_test}	\N	f	0
AnnotateCountsSpreadsheet	AnnotateCountsSpreadsheet.pl <?bkgrnd_id?> "<notify>"	background_process	<PID>|<ImageType>|<Modality>|<Images>|<StudyDate>|<StudyDescription>|<SeriesDescription>|<SeriesNumber>|<StudyInstanceUID>|<SeriesInstanceUID>|<Mfr>|<Model>|<software_versions>	{bills_test}	\N	f	0
ImportFromDicomFileEdit	ImportEditedFilesFromDicomEditCompare.pl <?bkgrnd_id?> <sub_invoc_id> <files_per_round> <max_queue_size> <notify>	background_process	\N	{edit_files}	\N	f	0
MakePatHierachy	GetHierarchyFromSeries.pl <?bkgrnd_id?> <notify>	background_process	<series_instance_uid>	{bills_test}	\N	f	0
CopyCollectionToStaging	CopyCollectionToStaging.pl <?bkgrnd_id?> <collection> "/nas/public/posda/scratch/staging/<rel_dir>" <notify>	background_process	\N	{bills_test}	\N	f	0
CheckStructLinkagesByCollectionSite	CheckStructLinkages.pl <?bkgrnd_id?> <collection> <site> <notify>	background_process	\N	{struct_linkages}	\N	f	0
CheckPosdaPublicConsistency	PublicPosdaCompare.pl <?bkgrnd_id?> <collection>  <notify>	background_process	\N	{public_posda_consistency}	\N	f	0
NewFixAcrinFiles	CsvNewFixAcrin.pl <?bkgrnd_id?> <to_dir> <uid_root> <low_date> <high_date> <notify>	background_process	<patient_id>&<study_uid>&<series_uid>&<sop_instance_uid>&<file_id>&<offset_pat_id>&<offset>	{bills_test}	\N	f	0
BackOutEdit	BackOutFromDicomEditCompare.pl <?bkgrnd_id?> <sub_invoc_id> <user> <notify>	background_process	\N	{edit_files}	\N	f	0
PrepareAcrinEdits	PrepareAcrinEdits.pl <?bkgrnd_id?> <notify>	background_process	<ele_pattern>&<value>&<series_instance_uid>	{bills_test}	\N	f	0
QuickCheckPosdaPublicConsistency	QuickPublicPosdaCompare.pl <?bkgrnd_id?> "<collection>"  <notify>	background_process	\N	{public_posda_consistency}	\N	f	0
ImportAndEnsureVisible	ImportAndEnsureVisible.py <?bkgrnd_id?> <activity_id> <notify>	background_process	<path>	{import}	\N	f	0
NewerFixAcrinFiles	CsvNewerFixAcrin.pl <?bkgrnd_id?> <to_dir> <uid_root> <low_date> <high_date> <notify>	background_process	<patient_id>&<study_uid>&<series_uid>&<offset_pat_id>&<offset>	{bills_test}	\N	f	0
CountFilesInSeries	TotalFilesForSelectedSeries.pl <?bkgrnd_id?> <notify>	background_process	<series_instance_uid>	{bills_test}	\N	f	0
FixCtpFileRow	FixCtpFileRow.pl <?bkgrnd_id?> <notify>	background_process	<file_id>&<file_path>	{bills_test}	\N	f	0
BackgroundDoProposedEdits	BackgroundDoProposedEdits.pl <?bkgrnd_id?> /nas/public/posda/edited/<rel_dest_root> "<description>" <notify>	background_process	<unmapped_id>&<mapped_id>&<series_instance_uid>&<num_files>&<operations>&<tag>&<val1>&<val2>	{edit_files}	\N	f	0
SetUpPublicToPosdaCopy	SetUpPublicToPosdaCopy.pl <?bkgrnd_id?> <collection> <notify> "<why_done>"	background_process	\N	{pubic_posda_consistency}	\N	f	0
StartPublicToPosdaCopy	BackgroundPublicToPosdaCopy.pl <?bkgrnd_id?> <copy_id> "<why>" <notify>	background_process	\N	{pubic_posda_consistency}	\N	f	0
MakeHierarcyBySeries	GetSeriesHierarchyBySeries.pl <?bkgrnd_id?> <notify>	background_process	<series_instance_uid>	{bills_test}	\N	f	0
UnHideSeriesWithStatus	UnhideBatchSeriesWithStatus.pl <who> "<why>"	legacy	<series_instance_uid>	{hide_files}	\N	f	0
DciodvfyReport	BackgroundDciodvfyReport.pl <?bkgrnd_id?> <scan_id> <notify>	background_process	\N	{dciodvfy}	\N	f	0
StartFixPublicToPosdaCopy	BackgroundFixPublicToPosdaCopy.pl <?bkgrnd_id?> <copy_id> "<why>", <notify>	background_process	\N	{public_posda_consistency}	\N	f	0
LookForDupSopsInPublicByCollectionSite	LookForPublicDupSops.pl <?bkgrnd_id?> "<collection>" "<site>" <notify>	background_process	\N	{comparing_posda_to_public}	\N	f	0
BuildUidMap	BuildUidMap.pl <?bkgrnd_id?> <notify>	background_process	<unmapped_uid>	{bills_test}	\N	f	0
BackgroundLinkSeriesToStaging	BackgroundLinkSeriesToStaging.pl <?bkgrnd_id?> /nas/public/posda/scratch/staging/<to_rel_dir> <notify>	background_process	<patient_id>&<study_instance_uid>&<series_instance_uid>	{send_series}	\N	f	0
AnonymizerToEditor	AnonymizerToEditor.pl <?bkgrnd_id?> <notify>	background_process	<operation_scope>&<operation>&<tag>&<value1>&<value2>&<patient_id>&<study_instance_uid>&<series_instance_uid>&<unmapped_uid>&<mapped_uid>	{bills_test}	\N	f	0
DeletePvtExceptCtp	DeletePrivateFromCollection.pl <?bkgrnd_id?> <collection> /nas/public/posda/scratch/converted/<rel_to_dir> <notify>	background_process	\N	{bills_test}	\N	f	0
HidePatientWithStatus	HideBatchPatientWithStatus.pl <who> "<why>"	legacy	<patient_id>	{hide_files,hide_dup_sops}	\N	f	0
MakeRtReport	MakeRtReport.pl <?bkgrnd_id?> <notify>	background_process	<patient_id>&<study_instance_uid>&<series_instance_uid>&<modality>&<num_files>	{bills_test}	\N	f	0
BackgroundOnlyEditDicomSeries	BackgroundOnlyEditDicomSeries.pl <?bkgrnd_id?> "/nas/public/posda/scratch/staging/<rel_dest_root>" "<desciption>" <notify>	background_process	<unmapped_uid>&<mapped_uid>&<series_instance_uid>&<operation>&<tag>&<val1>&<val2>	{bills_test}	\N	f	0
BackgroundCopySeriesToStaging	BackgroundCopySeriesToStaging.pl <?bkgrnd_id?> /nas/public/posda/scratch/staging/<to_rel_dir> <notify>	background_process	<patient_id>&<study_instance_uid>&<series_instance_uid>	{send_series}	\N	f	0
CheckCollectionAgainstPatientId	CheckCollectionAgainstPatientId.pl <?bkgrnd_id?> <notify>	background_process	<collection>&<patient_id>	{bills_test}	\N	f	0
BackgroundLinkPublicSeries	BackgroundLinkPublicSeries.pl <?bkgrnd_id?> /nas/public/posda/scratch/staging/<to_rel_dir> <notify>	background_process	<patient_id>&<study_instance_uid>&<series_instance_uid>	{send_series}	\N	f	0
BackgroundDciodvfyTp	BackgroundDciodvfyTp.pl <?bkgrnd_id?> <activity_id> <type> <notify>	background_process		{activity_timepoint}	\N	f	0
CheckRtReferenceChain	CheckRtReferenceChain.pl <?bkgrnd_id?> <collection> <site> <notify>	background_process	\N	{struct_linkages}	\N	f	0
MakeRtReport1	MakeRtReport1.pl <?bkgrnd_id?> <notify>	background_process	<collection>&<site>&<patient_id>&<study_uid>&<series_uid>&<file_type>&<modality>&<num_files>	{bills_test}	\N	f	0
FirstPassPhiScanAndReport	FirstPassPhiScanAndReport.pl <?bkgrnd_id?> <collection> <site> "<batch_no>" <notify>	background_process	\N	{bills_test}	\N	f	0
FirstPassPhiByCollection	FirstPassPhiByCollection.pl <?bkgrnd_id?> <collection> <notify>	background_process	\N	{bills_test}	\N	f	0
BackgroundCreateEquivalenceClasses	BackgroundCreateSeriesEquivalenceClasses.pl <?bkgrnd_id?> "<why>" <notify>	background_process	<series_instance_uid>	{visual_review}	\N	f	0
UncompressFilesTp	UncompressFilesTp.py <?bkgrnd_id?> <activity_id> <notify>	background_process	\N	{uncompress,activity_timepoint}	\N	f	0
AdHocReportForTracy	MakeCptacReport.pl <?bkgrnd_id?> <notify>	background_process	\N	{clin_qual}	\N	f	0
RepealEdits	RepealEdits.pl <?bkgrnd_id?> <subprocess_invoc_id> <notify>	background_process	\N	{find_patients}	\N	f	0
RejectEdits	RejectEdits.pl <?bkgrnd_id?> <subprocess_invoc_id> <notify>	background_process	\N	{find_patients}	\N	f	0
ImportEdits	ImportEdits.pl <?bkgrnd_id?> <subprocess_invoc_id> <notify>	background_process	\N	{find_patients}	\N	f	0
LinkSeries	BackgroundLinkSeries.pl <?bkgrnd_id?> <notify>	background_process	<patient_id>&<study_instance_uid>&<series_instance_uid>	{patient_queries}	\N	f	0
VisualReview	ScheduleVisualReview.pl <?bkgrnd_id?> "<why>" <notify>	background_process	<series_instance_uid>	{visual_review}	\N	f	0
MakeHierarchyBySeries	GetSeriesHierarchyBySeriesWithFileTypeAndModality.pl <?bkgrnd_id?> <notify>	background_process	<series_jnstance_uid>	{bills_test,activity_timepoints}	\N	f	0
PhiScan	NewPhiScan.pl <?bkgrnd_id?> "<description>" <notify>	background_process	<series_instance_uid>	{scan_status,phi_status,new_phi}	\N	f	0
InsertPatientMapping	ProcessCollectionSiteWorksheet.pl <?bkgrnd_id?>	background_process	<site_code>&<collection_code>&<site_id>&<site_name>&<collection_name>	{bills_test,mapping_tables,patient_mapping}	\N	f	0
ProcessRADCOMPUpload	CategorizeRadcompFiles.pl <?bkgrnd_id?> <collection> <site> <notify>	background_process	<import_event_id>	{radcomp}	\N	f	0
RadcompSubmissionConverter	RadcompSubmissionConverter.pl <?bkgrnd_id?> <notify>	background_process	<file_id>	{radcomp}	\N	f	0
XlsConverter	XlsConverter.pl <?bkgrnd_id?> <notify>	background_process	<file_id>	{radcomp}	\N	f	0
FullPhiById	FullPhiById.pl <?bkgrnd_id?> <scan_id> <notify> <max_rows>	background_process		{bills_test}	\N	f	0
NewFirstPassPhi	NewFirstPassPhiScan.pl <?bkgrnd_id?> "<description>" <notify>	background_process	<series_instance_uid>	{bills_test,new_workflow}	\N	f	0
XlsxConverter	XlsxConverter.pl <?bkgrnd_id?> <notify>	background_process	<file_id>	{radcomp}	\N	f	0
NonDicomPhiScan	NonDicomPhiScan.pl <?bkgrnd_id?> <collection> <site> <notify>	background_process	\N	{non_dicom_phi}	\N	f	0
ProposeCsvEdits	ProposeCsvEdits.pl <?bkgrnd_id?> <scan_id> "<description>" <notify>	background_process	<type>&<path>&<q_value>&<num_files>&<p_op>&<q_arg1>&<q_arg2>&<q_arg3>	{non_dicom_edit}	\N	f	0
ProposeJsonEdits	ProposeJsonEdits.pl <?bkgrnd_id?> <scan_id> "<description>" <notify>	background_process	<type>&<path>&<q_value>&<num_files>&<p_op>&<q_arg1>&<q_arg2>&<q_arg3>	{non_dicom_edit}	\N	f	0
BackgroundCsvEdit	BackgroundCsvEditor.pl <?bkgrnd_id?> "<description>" <notify>	background_process	<file_id>&<op>&<path>&<val1>&<val2>&<val3>	{edit,non_dicom_edit}	\N	f	0
BackgroundJsonEdit	BackgroundJsonEditor.pl <?bkgrnd_id?> "<description>" <notify>	background_process	<file_id>&<op>&<path>&<val1>&<val2>&<val3>	{edit,non_dicom_edit}	\N	f	0
NewPhiScanAll	NewPhiScanAll.pl <?bkgrnd_id?> "<description>" <db> <max_lines> <notify>	background_process	<series_uid>	{bills_test,new_workflow}	\N	f	0
FileAndDismissNotifications	FileAndDismissNotification.pl <?bkgrnd_id?> <activity_id> "<description>" <notify>	background_process	<id>	{activity_support}	\N	f	0
ImportNonDicomEdits	ImportNonDicomEditedFiles.pl <?bkgrnd_id?> <subprocess_invoc_id> <notify>	background_process	\N	{non_dicom_edit}	\N	f	0
GenerateYearOfDiagnosisEdits	GenerateEditsForYearsOfDiagnosis.pl <?bkgrnd_id?> <notify>	background_process	<patient_id>&<year>	{bills_ad_hoc_scripts}	\N	f	0
RadcompPrivateDisp	BackgroundPrivateDispositionsByPatShift.pl <?bkgrnd_id?> <to_dir> <uid_root> <notify>	background_process	<patient_id>&<study_uid>&<series_uid>&<offset>	{bills_test}	\N	f	0
MakeHierarchyByPat	GetHierarchyFromPatientId.pl <?bkgrnd_id?> <notify>	background_process	<patient_id>	{bills_test}	\N	f	0
QuickCheckPublicPosdaConsistLike	QuickPublicPosdaCompareLikeCollection.pl <?bkgrnd_id?> "<collection_pat>"  <notify>	background_process	\N	{public_posda_consistency}	\N	f	0
ProposeAdHocMelanomaEdits	ProposeAdHocMelanomaEdits.pl <?bkgrnd_id?> <shift> <old_uid_root> <new_uid_root> <notify>	background_process	<patient_id>&<series_uid>&<study_date>&<num_files>&<pat_id_for_diag_date>&<diag_date>	{bills_test,bills_ad_hoc_scripts}	\N	f	0
FixReallyBadDicomFilesInTimepoint	FixReallyBadDicomFilesInTimepoint.pl <?bkgrnd_id?> <activity_id> <activity_timepoint_id> <notify>	background_process		{ad_hoc_process}	\N	f	0
HideLateDupSopsInSeries	HideBatchLateSopDupsInSeries.pl <who> "<why>"	legacy	<series_instance_uid>	{hide_files,hide_dup_sops}	\N	f	0
BackgroundProcessModules	BackgroundProcessModules.pl <?bkgrnd_id?> "<description>" <notify>	background_process	<file_id>	{dicom_file_type}	\N	f	0
HideEquivalenceClasses	HideEquivalenceClasses.pl <?bkgrnd_id?> <notify>	background_process	<image_equivalence_class_id>&<processing_status>&<review_status>	{visual_review_status}	\N	f	0
MakePassThru	MakePassThru.pl <?bkgrnd_id?> <visual_review_id> <notify>	background_process	<processing_status>&<review_status>&<dicom_file_type>	{visual_review_status}	\N	f	0
RetryFailedProjections	RetryFailedProjections.pl <?bkgrnd_id?> <notify>	background_process	<image_equivalence_class_id>&<processing_status>&<review_status>	{visual_review_status}	\N	f	0
ChangeReviewStatus	ChangeReviewStatus.pl <?bkgrnd_id?> <review_status> <processing_status> <notify>	background_process	<image_equivalence_class_id>&<processing_status>&<review_status>	{visual_review_status}	\N	f	0
ApplyDispositions	BackgroundApplyDispositionsFromVisualScan.pl <?bkgrnd_id?> <dest_dir> <uid_root> <date_offset> <notify>	background_process	<id>&<processing_status>&<review_status>&<dicom_file_type>	{visual_review_status}	\N	f	0
CreateActivityTimepoint	CreateActivityTimepoint.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	\N	{visual_review_status}	\N	f	0
ProcessVisualReview	ProcessVisualReview.pl <?bkgrnd_id?> <scan_id> <notify>	background_process	\N	{visual_review_new_workflow}	\N	f	0
BackgroundHideFiles	BackgroundHideFilesWithStatus.pl <?bkgrnd_id?> <notify> "<reason>"	background_process	<file_id>	{compare_series}	\N	f	0
CreateActivityTimepointFromSeriesList	CreateActivityTimepointFromSeriesList.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<series_instance_uid>	{activity_timepoints}	\N	f	0
CreateActivityTimepointFromCollectionSite	CreateActivityTimepointFromCollectionSite.pl <?bkgrnd_id?> <activity_id> <collection> <site> "<comment>" <notify>	background_process	\N	{timepoint_buttons}	\N	f	0
LinkPublicCollection	LinkPublicCollection.pl <?bkgrnd_id?> <directory> <notify>	background_process	<collection>&<patient_id>&<series_instance_uid>&<dicom_file_uri>	{activity_timepoints,send_series,bills_test}	\N	f	0
ListOfAnnotatedFiles	InsertListOfAnnotatedFiles.pl <?bkgrnd_id?> "<comment>" <notify>	background_process	<file_id>&<file_name>&<mime_type>&<description>	{activity_timepoints,send_series_via_dicom,bills_test}	\N	f	0
FixBadSopInstanceLungFusedCtPathology	FixBadSopInstancesLungFusedCtPathology.pl <?bkgrnd_id?> <notify>	background_process	\N	{"Curation of Lung-Fused-CT-Pathology"}	\N	f	0
BackgroundPrivateDispositions	BackgroundPrivateDispositions.pl <?bkgrnd_id?> <to_dir> <uid_root> <offset> <notify>	background_process	<patient_id>&<study_instance_uid>&<series_instance_uid>	{edit,send_series}	\N	f	0
BackgroundPrivateDispositionsBaseline	BackgroundPrivateDispositionsBaseline.pl <?bkgrnd_id?> <to_dir> <notify>	background_process	<patient_id>&<study_instance_uid>&<series_instance_uid>	{edit,send_series}	\N	f	0
MakeDownloadableDirectory	MakeDownloadableDirectory.pl <?bkgrnd_id?> <sub_dir> <notify>	background_process	<collection>&<patient_id>&<study_instance_uid>&<series_instance_uid>	{send_series}	\N	f	0
BackgroundHideSeries	BackgroundHideSeriesWithIndividualStatus.pl <?bkgrnd_id?> <notify>	background_process	<series_uid>&<reason_to_hide>	{bills_test,new_workflow,activity_support}	\N	f	0
UpdateTimepointAfterEdit	UpdateTimepointAfterEdit.pl <?bkgrnd_id?> <activity_id> <activity_timepoint_id> <subprocess_invocation_id> <notify>	background_process	\N	{update_timepoint,activities}	\N	f	0
AnalyzeSeriesDuplicatesForTimepoint	AnalyzeTpSeriesDuplicates.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	\N	{activity_timepoint_support}	\N	f	0
VisualReviewFromTimepoint	ScheduleVisualReviewFromActivityTimepoint.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	\N	{visual_review}	\N	f	0
PhiReviewFromTimepoint	SchedulePhiReviewFromActivityTimepoint.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	\N	{visual_review}	\N	f	0
CompareSopsTpPosdaPublic	CompareSopsTpPosdaPublic.pl <?bkgrnd_id?> "<collection>" <activity_id> <notify>	background_process	\N	{activity_timepoint_support}	\N	f	0
BackgroundHideEarlyDupSops	BackgroundHideEarlyDupSopsInSeries.pl <?bkgrnd_id?> <notify> "<reason>"	background_process	<series_instance_uid>	{activity_timepoint_support}	\N	f	0
AdHocTestSetConversion	AdHocSecondaryCaptureConverter.pl <?bkgrnd_id?> <notify> <source_dir> <dest_dir>	background_process	<pat_code>&<anon_pat_id>&<uid_root>&<pat_sex>	{"Bills Test"}	\N	f	0
BackgroundUpdatePrivateDispositionEle	BackgroundUpdatePrivateDispositionsEle.pl <?bkgrnd_id?> "<why>" <notify>	background_process	<element_sig_pattern>&<disp>	{phi_maint}	\N	f	0
DispositionNeededWorksheet	DispositionsNeededWorksheet.pl <?bkgrnd_id?> <notify>	background_process	\N	{phi_maint}	\N	f	0
AnalyzeSeriesDuplicates	AnalyzeSeriesDuplicates.pl <?bkgrnd_id?> "<collection>" <site> <notify>	background_process	\N	{"ACRIN-FMISO-Brain Duplicate Elimination",dup_sops,activity_timepoint_support}	\N	f	0
BackgroundHideSeriesByCollection	BackgroundHideSeriesByCollection.pl <?bkgrnd_id?> "<reason>" <collection> <notify>	background_process	<series_instance_uid>	{activity_timepoint_support}	\N	f	0
BackgroundUpdatePrivateDisposition	BackgroundUpdatePrivateDispositions.pl <?bkgrnd_id?> "<why>" <notify>	background_process	<id>&<disp>	{phi_maint}	\N	f	0
RejectEditsTp	RejectEditsTp.pl <?bkgrnd_id?> <activity_id> <subprocess_invoc_id> <notify>	background_process	\N	{find_patients}	\N	f	0
SummarizeStructLinkage	SummarizeStructLinkagesByFileId.pl <?bkgrnd_id?> <file_id> <notify>	background_process	\N	{activity_timepoint_support}	\N	f	0
DeleteSeriesFromActivityTimepoint	DeleteSeriesFromActivityTimepoint.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<series_instance_uid>	{activity_timepoints}	\N	f	0
FilesInTpNotInPublic	FilesInLatestActivityNotInPublic.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	\N	{activity_timepoints_support}	\N	f	0
BackgroundUnhideFiles	BackgroundUnhideFilesWithStatus.pl <?bkgrnd_id?> <notify> "<reason>"	background_process	<file_id>&<old_visibility>	{activity_timepoint_support}	\N	f	0
FixFilesWithNullNumberOfFrames	FixFilesWithNullNumberOfFrames.pl <?bkgrnd_id?> "<comment>" <notify>	background_process	\N	{Exceptional-Responders_NCI_Oct2018_curation}	\N	f	0
FixCtInExceptionalRespondersWithNullNumberOfFrames	FixCtErwWithNullNumberOfFrames.pl <?bkgrnd_id?> "<comment>" <notify>	background_process	\N	{Exceptional-Responders_NCI_Oct2018_curation}	\N	f	0
AddSeriesToActivityTimepoint	AddSeriesToActivityTimepoint.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<series_instance_uid>	{activity_timepoint_support}	\N	f	0
BackgroundEditByStudy	BackgroundEditStudy.pl <?bkgrnd_id?> "<description>" <notify>	background_process	<study_instance_uid>&<op>&<tag>&<val1>&<val2>	{activity_timepoints}	\N	f	0
CompareSopsInTpToPublic	CompareSopsInTpToPublic.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	\N	{activity_timepoints_support}	\N	f	0
TestProcessEditByFile	TestProcessBackgroundEditFileInstructions.pl <?bkgrnd_id?> <notify>	background_process	<file_id>&<op>&<tag>&<val1>&<val2>	{testing_edit_objects}	\N	f	0
ModifySeriesInActivityTp	ModifySeriesInActivityTimepoint.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<series_instance_uid>&<function>	{activity_timepoints}	\N	f	0
UpdateActivityTimepoint	UpdateActivityTimepointForChange.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	\N	{timepoint_buttons}	\N	f	0
ConsistencyFromTimePoint	AnalyzeStudySeriesConsistencyByActivity.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	\N	{timepoint_buttons}	\N	f	0
LinkRtFromTimepoint	LinkRtByActivityTimepoint.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	\N	{timepoint_buttons}	\N	f	0
CondensedActivityTimepointReport	CondensedActivityTimepointReport.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	\N	{timepoint_buttons}	\N	f	0
ImportPatientMapping	ImportPatientMapping.pl <?bkgrnd_id?> <notify>	background_process	<from_patient_id>&<to_patient_id>&<to_patient_name>&<collection_name>&<site_name>&<batch_number>&<date_shift>&<diagnosis_date>&<baseline_date>&<uid_root>	{bills_test,mapping_tables,patient_mapping}	\N	f	0
PrivateTagReports	PrivateElementReports.pl <?bkgrnd_id?> <notify>	background_process	\N	{phi_maint}	\N	f	0
CompareSopsTpPosdaPublicLike	CompareSopsTpPosdaPublicLike.pl <?bkgrnd_id?> "<collection_like>" <activity_id> <notify>	background_process	\N	{activity_timepoint_support}	\N	f	0
CreateActivityTimepointFromPatientList	CreateActivityTimepointFromPatientList.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<collection>&<site>&<patient_id>	{activity_timepoints}	\N	f	0
CompareSopsTpPosdaPublicCollectionLikeSiteEqual	CompareSopsTpPosdaPublicLikeEq.pl <?bkgrnd_id?> "<collection_like>" "<site>" <activity_id> <notify>	background_process	\N	{activity_timepoint_support}	\N	f	0
InitialAnonymizerCommands	ProduceInitialAnonymizerCommands.pl <?bkgrnd_id?> <collection> <site> <notify>	background_process	<series_instance_uid>&<patient_id>&<patient_name>	{initial_anonymization,patient_mapping}	\N	f	0
UpdateQualifiedPatients	UpdateQualifiedPatients.pl <?bkgrnd_id?> <notify>	background_process	<collection>&<site>&<patient_id>&<qualified>	{activity_timepoint_support}	\N	f	0
HideFilesVisbleInBadEquivalenceClassesByVisualReviewId	HideVisibleFilesInBadIecs.pl <?bkgrnd_id?> <visual_review_instance_id> <notify>	background_process	\N	{visual_review_status}	\N	f	0
TestProcessEditByStudy	TestProcessBackgroundEditStudyInstructions.pl <?bkgrnd_id?> <notify>	background_process	<study_instance_uid>&<op>&<tag>&<val1><val2>	{testing_edit_objects}	\N	f	0
BackgroundLinkActivityToTemp	BackgroundLinkActivityToTemp.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	\N	{send_series}	\N	f	0
PhiPublicScanTp	PhiPublicScanTp.pl <?bkgrnd_id?> <activity_id> <max_rows> <notify>	background_process	\N	{simple_phi}	\N	f	0
BackgroundFixRtstruct	BackgroundFixStructLinkages.pl <?bkgrnd_id?> "<comment>" <notify>	background_process	<img_series>&<struct_file_id>	{activity_timepoints}	\N	f	0
ProposeEdits	NewProposeEdits.pl <?bkgrnd_id?> <scan_id> <notify>	background_process	<element>%<vr>%<q_value>%<num_series>%<p_op>%<q_arg1>%<q_arg2>	{simple_phi,activity_timepoints}	\N	f	0
PopulateFileImport	PopulateFileImportForImportEvent.pl <?bkgrnd_id?> <import_event_id> <notify>	background_process	<file_name>&<digest>	{QIN-GBM-DSC-MRI-DRO/Barrow}	\N	f	0
BackgroundUnhideSeries	BackgroundUnhideSeriesWithIndividualStatus.pl <?bkgrnd_id?> <notify>	background_process	<series_uid>&<reason_to_unhide>	{bills_test,new_workflow,activity_support}	\N	f	0
SimpleBackgroundTestProcess	SimpleBackgroundTestSubprocess.pl <?bkgrnd_id?> "<message>" <notify>	background_process	<column1>&<column2>&<column3>	{bills_test}	\N	f	0
InitialAnonymizerCommandsTp	ProduceInitialAnonymizerCommandsTp.pl <?bkgrnd_id?> <collection> <site> <activity_id> <notify>	background_process	\N	{initial_anonymization,patient_mapping}	\N	f	0
CreateActivityTimepointFromImportName	CreateActivityTimepointFromImportName.pl <?bkgrnd_id?> <activity_id> "<import_name>" "<comment>" <notify>	background_process	\N	{activity_timepoints}	\N	f	0
BackgroundEdit	BackgroundEditor.pl <?bkgrnd_id?> "<description>" <notify>	background_process	<series_instance_uid><op><tag><val1><val2>	{activity_timepoints,uses_field_separator}	\N	f	0
HelloWorldPython	BackgroundHelloWorldWithInput.py <?bkgrnd_id?> <activity_id> <notify>	background_process	<series_instance_uid>	{foo}	\N	f	0
CompareTimepoints	CompareTimepoints.pl <?bkgrnd_id?> <activity_id> <from_timepoint_id> <to_timepoint_id> <notify>	background_process		{}	\N	f	0
HideFilesByCollectionSiteAndSeries	HideFilesByCollectionSiteAndSeries.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<collection>&<site>&<series_instance_uid>	{update_timepoint,activities}	\N	f	0
SeriesWithDupSopsDifferentSopClassTp	SeriesWithDupSopsDifferentSopClassTp.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<foo>	{background}	\N	f	0
CreateActivityTimepointFromImportId	CreateActivityTimepointFromImportEventId.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<import_event_id>	{activity_timepoints}	\N	f	0
KeepOnlyFilesDupFilesInTimepointAndSeriesWithMatchingDescriminator	KeepOnlyFilesDupFilesInTimepointAndSeriesWithMatchingDescriminator.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<series_instance_uid>:<descriminator>:<value>	{dup_sops,background}	\N	f	0
BackgroundHideFilesWithStatusTp	BackgroundHideFilesWithStatusTp.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<file_id>&<visibility>	{update_timepoint,activities}	\N	f	0
HideFilesBySeriesAndPatient	BackgroundHideFilesBySeriesAndPatient.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<patient_id>&<series_instance_uid>	{hide_files}	\N	f	0
MakeDownloadableDirectoryFromSpreadsheet	MakeDownloadableDirectoryFromSpreadsheet.pl <?bkgrnd_id?> <activity_id> <sub_dir> <notify>	background_process	<uploaded_file_name>&<stored_file_name>	{update_timepoint,activities}	\N	f	0
HelloWorldPerl	BackgroundHelloWorldWithInput.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<series_instance_uid>	{foo}	\N	f	0
MakeDownloadableDirectoryTp	MakeDownloadableDirectoryTp.pl <?bkgrnd_id?> <activity_id> <sub_dir> <notify>	background_process		{send_series}	\N	f	0
ProposeEditsTp	ProposeEditsTp.pl <?bkgrnd_id?> <activity_id> <scan_id> <notify> "<sep_char>"	background_process	<element><sep_char><vr><sep_char><q_value><sep_char><num_series><sep_char><p_op><sep_char><q_arg1><sep_char><q_arg2>	{simple_phi,activity_timepoints}	\N	f	0
UpdateOrCreatePatientMapping	UpdateOrCreatePatientMapping.pl <?bkgrnd_id?> <activity_id> "<comment>" "<overwrite>" <notify>	background_process	<in_patient_mapping>&<from_patient_id>&<collection>&<site>&<to_patient_id>&<to_patient_name>&<diagnosis_date>&<min_study_date>&<uid_root>&<batch_number>&<site_code>&<baseline_date>&<date_shift>	{patient_mapping}	\N	f	0
FindCorrespondingPosdaPublicPath	CorrespondingFilesPosdaPublic.pl <?bkgrnd_id?> <notify>	background_process	<file_id>	{public_posda_compare}	\N	f	0
HideEquivalenceClassesTp	HideEquivalenceClassesTp.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<image_equivalence_class_id>&<processing_status>&<review_status>	{visual_review_status}	\N	f	0
CreateActivityTimepointFromImportEventId	CreateActivityTimepointFromImportEventIdAll.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<import_event_id>	{activity_timepoints}	\N	f	0
SuggestPatientMappings	SuggestPatientMapping.pl <?bkgrnd_id?> <activity_id> "<col_name>" "<crc>" "<site_name>" "<src>" "<date_spec>" "<pat_map_pat>" "<num_dig>" <notify>	background_process		{}	\N	f	0
AddPublicHierarchy	AddHierarchyToSpreadsheetByPublicSop.pl <new_root>	legacy	<file>&<Element>&<OldValue>&<NewValue>	{}	\N	f	0
InsertPrivateTagKb	InsertPrivateTagKb.pl <?bkgrnd_id?> <activity_id> <is_dry_run> <notify>	background_process	<pt_signature>&<pt_consensus_vr>&<pt_consensus_name>&<pt_consensus_vm>&<pt_consensus_description>&<pt_consensus_disposition>	{}	\N	f	0
Path_SVS_VisualReview	PathologyScheduleSVSReview.py <?bkgrnd_id?> <activity_id> <notify>	background_process		{visual_review}	\N	f	0
ApplyPrivateDispositionIntake	CsvApplyPrivateDispositionIntake.pl <dest_dir> <uid_root> <offset> <low_date> <high_date>	legacy	<patient_id>&<study_instance_uid>&<series_instance_uid>	{}	\N	f	0
BackgroundEditBySop	BackgroundEditDicomFile.pl  <?bkgrnd_id?> /nas/public/posda/edited/<rel_dest_root> <who> "<edit_description>" <notify>	background_process	<command>&<arg1>&<arg2>&<arg3>&<arg4>	{obsolete}	\N	f	0
BackgroundEditTp	BackgroundEditorTp.pl <?bkgrnd_id?> <activity_id> "<edit_description>" <notify>	background_process	<series_instance_uid>&<op>&<tag>&<val1>&<val2>	{activity_timepoints}	\N	f	0
ImportEditsTp	ImportEditsTp.pl <?bkgrnd_id?> <activity_id> <subprocess_invoc_id> <notify>	background_process	\N	{edit_files}	\N	f	0
CreateActivityTimepointFromSopList	CreateActivityTimepointFromSopList.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<sop_instance_uid>	{activity_timepoints}	\N	f	0
CreateActivityTimepointFromFileList	CreateActivityTimepointFromFileList.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<file_id>	{activity_timepoints}	\N	f	0
StartExportEvent	StartAnExport.pl <?bkgrnd_id?> <activity_id> <export_event_id> "<import_comment>" <notify>	background_process		{export}	\N	f	0
ConsolidateTimepoints	ConsolidateActivityTimepoints.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<activity_timepoint_id>	{activity_timepoints}	\N	f	0
ExportTimepoint	ExportTimepoint.pl <?bkgrnd_id?> <activity_id> "<destination_name>" "<only_group_13>" "<only_dicom>" "<apply_dispositions>" "<base_line>" "<days_to_shift>" "<uid_root>" <notify>	background_process		{export}	\N	f	0
CloseExportEvent	CloseAnExport.pl <?bkgrnd_id?> <activity_id> "<export_event_id>"  <notify>	background_process		{export}	\N	f	0
ComparePosdaPrivateDataDictToPrivateTagKb	CompareNewPrivateTagDbToOld.pl <?bkgrnd_id?> <activity_id> <notify>	background_process		{private_tag_kb}	\N	f	0
CopyPriorTimepoint	CreateNewTimepointByCopyingOldTp.pl <?bkgrnd_id?> <activity_id> <old_tp_id> <notify>	background_process		{backup}	\N	f	0
AnnotateTimeline	InsertListOfAnnotatedFiles.pl <?bkgrnd_id?> "<comment>" <notify>	background_process	<file_id>&<file_name>&<mime_type>&<description>	{activity_timepoints,send_series_via_dicom,bills_test}	\N	f	0
PseudoNominizerEditsConstructor	PseudoNominizerEditsConstructor.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<operation_scope>&<operation>&<tag>&<value1>&<value2>&<patient_id>&<study_instance_uid>&<series_instance_uid>&<sop_instance_uid>&<unmapped_uid>&<mapped_uid>	{pseudonominizer}	\N	f	0
BackgroundPopulateSegStructFile	BackgroundPopulateSegStructFiles.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<file_id>	{SegBitmaps}	\N	f	0
CopyPriorTimepointInSeriesOnly	CopyPriorTimepointInSeriesOnly.pl <?bkgrnd_id?> <activity_id> <old_tp_id> <notify>	background_subprocess	<series_instance_uid>	{activity_timepoints}	\N	f	0
ConsolidateActivities	ConsolidateActivities.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<activity_id>	{activity_timepoints}	\N	f	0
RemoveFilesMarkedBadFromActivity	RemoveFilesMarkedBadFromActivity.pl <?bkgrnd_id?> <activity_id> <visual_review_id> <notify>	background_process		{visual_review}	\N	f	0
CreateActivityTimepointFromFileIds	CreateActivityTimepointFromFileIds.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<file_id>	{activity_timepoints}	\N	f	0
PhiVaPublicScanTp	PhiVaPublicScanTp.pl <?bkgrnd_id?> <activity_id> <import_event_id> <max_rows> <notify>	background_process		{simple_phi,va}	\N	f	0
CreateCompleteActivityTimepointFromImportEvent_id	CreateCompleteActivityTimepointFromImportEventId.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<import_event_id>	{activity_timepoints}	\N	f	0
CopyPriorTimepointExcludingFiles	CopyPriorTimepointExcludingFiles.pl <?bkgrnd_id?> <activity_id> <old_tp_id> <notify>	background_process	<file_id>	{activity_timepoints}	\N	f	0
ListOfFilesBySeriesAndTimepoint	ListOfFilesBySeriesAndTimepoint.pl <?bkgrnd_id?> <activity_id> <activity_timepoint_id> <notify>	background_process	<series_instance_uid>	{Duke,DBT}	\N	f	0
BackgroundEditBySopInstanceTp	BackgroundEditBySopInstanceTp.pl <?bkgrnd_id?> <activity_id> <desciption> <notify>	background_process	<unmapped_uid><mapped_uid><sop_instance_uid><operation><tag><val1><val2>	{editor}	\N	f	0
PhiPublicScan	PhiPublicScan.pl <?bkgrnd_id?> <activity_id> <max_rows> "<collection>" "<site>" <notify>	background_process		{simple_phi}	\N	f	0
BackgroundPrivateDispositionsTp	BackgroundPrivateDispositionsTp.pl <?bkgrnd_id?> <activity_id> "<uid_root>" "<offset>" "<notify>" "<skip_dispositions>" "<upd_nbia>" "<dir>"	background_process		{activity_timepoints}	\N	f	0
CompareDupSopsInTimepoint	CompareDupSopsInTp.pl <?bkgrnd_id?> <activity_id> <activity_timepoint_id> <notify>	background_subprocess		{dup_sops}	\N	f	0
AddFilesToTimepoint	AddFilesToTimepoint.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<file_id>	{activity}	\N	f	0
CompareFileList	CompareFileList.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<from_file_id>&<to_file_path>	{file_compare}	\N	f	0
SelectGoodAndBadFilesFromDupSopsWorksheet	SelectGoodAndBadFilesFromDupSopsWorksheet.pl <?bkgrnd_id?> <activity_id> <comparison_id> <notify>	background_process	<equiv_class>&<select>	{dup_sops}	\N	f	0
ImportDownloadableDirectory	ImportDownloadableDirectory.pl <?bkgrnd_id?> <activity_id> "<comment>" "<sub_dir>" <notify>	background_process		{VA,dispositions}	\N	f	0
PhiVaPublicScanDD	PhiVaPublicScanDD.pl <?bkgrnd_id?> <activity_id> <rel_dir> <max_rows> <notify>	background_process		{simple_phi,va}	\N	f	0
MakeUIDMap	create-hashed-uid-mapping.py <?bkgrnd_id?> <notify> <timepoint_id>	background_process		{}	\N	f	0
SlowRoll0	SlowRoll.pl <?bkgrnd_id?> <activity_id> <notify>	background_process		{demo_background}	\N	f	0
SlowRoll1	SlowRoll.pl <?bkgrnd_id?> <activity_id> <notify>	background_process		{demo_background}	\N	f	0
CreateDownloadableDirectoryAllTp	CreateDownloadableDirectoryAllTp.pl <?bkgrnd_id?> <activity_id> <sub_dir> <notify>	background_process		{test}	\N	f	0
InitializeFileNiftiDefacing	InitializeFileNiftiDefacing.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<nifti_file_id>	{nifti}	\N	f	0
ProcessSeriesWithHeads	ProcessSeriesWithHeads.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<series_instance_uid>&<has_head>	{defacing}	\N	f	0
ConstructCrosswalk	CrosswalkConstructor.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<batch_1_uids><batch_2_uids><batch_3_uids><batch_4_uids><batch_5_uids>	{editor}	\N	f	0
CopySeriesFromPublic	CopySeriesFromPublic.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<series_instance_uid>	{nbia_copy}	\N	f	0
SR_phiscanOp	SR_phiscan.pl <?bkgrnd_id?> <activity_id> <notify>	background_process		{"PHI report"}	\N	f	0
BackgroundConvertSeriesInTpToNifti	BackgroundConvertSeriesInTpToNifti.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<series_instance_uid>	{nifti}	\N	f	0
CollectUidsFromFileList	CollectAllUidsFromFileList.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<file_id>	{activity_timepoint}	\N	f	0
MakeDownloadableNonDicomTp	MakeDownloadableNonDicomTp.pl <?bkgrnd_id?> <activity_id> <sub_dir> <notify>	background_process		{send_series}	\N	f	0
PopulateNiftiSlicesAndProjectionsForTimepoint	PopulateNiftiSlicesAndProjectionsForTimepoint.pl <?bkgrnd_id?> <activity_id> <notify> <render_slices> <render_volumes> <render_projections> <verbose>	background_process		{nifti}	\N	f	0
TempMprPopulateInitialAxialVolume	TempMprPopulateInitialAxialVolume.pl <?bkgrnd_id?> <activity_id> <series> <notify>	background_process	<file_id>&<pix_rows>&<pix_cols>&<ipp_x>&<ipp_y>&<ipp_z>&<row_spc>&<col_spc>	{temp_mpr}	\N	f	0
TempMprRotateTransposedConronalToSagittal	TempMprRotateTransposedConronalToSagittal.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<key>,<value>,<x>,<y>,<z>,<gray_file_id>,<jpeg_file_id>	{temp_mpr}	\N	f	0
BackgroundConvertDefacedNiftisToDicom	BackgroundConvertDefacedNiftisToDicom.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<nifti_file_id>	{nifti}	\N	f	0
CreateImportEventFromSeriesInPublic	CreateImportEventFromSeriesInPublic.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<series_instance_uid>	{copy_from_public}	\N	f	0
ReQueueFileNiftiDefacing	ReQueueFileNiftiDefacingTp.pl <?bkgrnd_id?> <activity_id> <notify>	background_subprocess		{nifti}	\N	f	0
TempMprTempMprProcessAxialResampling	TempMprTempMprProcessAxialResampling.pl <?bkgrnd_id?> <activity_id> <temp_mpr_volume_id> <notify>	background_process	<i_slice_no>&<slice_offset>&<slice_spacing>	{temp_mpr}	\N	f	0
Path_PHI_Scan	PathologyPhiScan.py <?bkgrnd_id?> <activity_id> <notify>	background_process		{phi_reports}	\N	f	0
CreateActivityListFromPatientCountAndUploadSpecSpreadsheet	CreateActivityListFromPatientCountAndUploadSpecSpreadsheet.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<patient_id>&<num_files>&<import_comment_like>&<import_type_like>&<from>&<to>	{activity_timepoints}	\N	f	0
TempMprMakeRotatedAxialFromCoronalStack	TempMprMakeRotatedAxialFromCoronalStack.pl <?bkgrnd_id?> <activity_id> <temp_mpr_volume_id> <notify>	background_process		{temp_mpr}	\N	f	0
PopulateFileNiftiTp	PopulateFileNiftiTp.pl <?bkgrnd_id?> <activity_id> <update_existing> <notify>	background_subprocess		{nifti}	\N	f	0
TempMprMakeIsoTropicCoronalFromAxialStack	TempMprMakeIsoTropicCoronalFromAxialStack.pl <?bkgrnd_id?> <activity_id> <temp_mpr_volume_id> <notify>	background_process		{temp_mpr}	\N	f	0
BackgroundFixRtstructTp	BackgroundFixStructLinkagesTp.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>	background_process	<img_series>&<struct_file_id>	{activity_timepoints}	\N	f	0
SRProposeEditsTp	SRProposeEditsTp.pl <?bkgrnd_id?> <activity_id> <scan_id> <notify> "<sep_char>"	background_process	<element><sep_char><q_value><sep_char><path_sig_pattern><sep_char><p_op><sep_char><q_arg1><sep_char><q_arg2>	{simple_phi,activity_timepoints}	\N	f	0
MakeDukeDbtMappingSpreadsheet	MakeDukeDbtMappingSpreadsheet.pl <?bkgrnd_id?> <activity_id> <notify>	background_process		{Duke,DBT}	\N	f	0
AssociateNiftisWithDicoms	AssociateNiftisWithDicoms.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<activity_timepoint_id>&<nifti_file_id>&<series_instance_uid>	{nifti}	\N	f	0
TempMprPopulateIsoTropicCoronalFromAxialStack	TempMprPopulateIsoTropicCoronalFromAxialStack.pl <?bkgrnd_id?> <activity_id> <notify>	background_process	<key>&<value>&<x>&<y>&<z>&<gray_file_id>&<jpeg_file_id>	{temp_mpr}	\N	f	0
TempMprProcessAxialResampling	TempMprProcessAxialResampling.pl <?bkgrnd_id?> <activity_id> <temp_mpr_volume_id> <notify>	background_process	<i_slice_no>&<slice_offset>&<slice_spacing>	{temp_mpr}	\N	f	0
TempMprTransposeVolume	TempMprTransposeVolume.pl <?bkgrnd_id?> <activity_id> <temp_mpr_volume_id> <notify>	background_process		{temp_mpr}	\N	f	0
BackgroundSingleRtLinkageDetailReports	BackgroundSingleRtLinkageDetailReports.pl <?bkgrnd_id?> <activity_id> <file_path> <notify>	background_process		{StuctLinkages}	\N	f	0
BackgroundPrivateDispositionsTpBaseline	BackgroundPrivateDispositionsTpBaseline.pl <?bkgrnd_id?> <activity_id>  "<notify>" "<skip_dispositions>" "<upd_nbia>" "<dir>"	background_process		{activity_timepoints}	\N	f	0
CheckStructLinkagesTp	CheckStructLinkagesTpId.pl <?bkgrnd_id?> <activity_id> "<check_public>" <notify>	background_process		{timepoint_buttons}	\N	f	0
\.


--
-- Name: background_buttons_background_button_id_seq; Type: SEQUENCE SET; Schema: dbif_config; Owner: -
--

SELECT pg_catalog.setval('dbif_config.background_buttons_background_button_id_seq', 56, true);


--
-- Name: chained_query_chained_query_id_seq; Type: SEQUENCE SET; Schema: dbif_config; Owner: -
--

SELECT pg_catalog.setval('dbif_config.chained_query_chained_query_id_seq', 22, true);


--
-- Name: popup_buttons_popup_button_id_seq1; Type: SEQUENCE SET; Schema: dbif_config; Owner: -
--

SELECT pg_catalog.setval('dbif_config.popup_buttons_popup_button_id_seq1', 75, true);


--
-- PostgreSQL database dump complete
--

