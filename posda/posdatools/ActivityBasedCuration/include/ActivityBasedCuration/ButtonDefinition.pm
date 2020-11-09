#!/bin/perl -w
use strict;
package ActivityBasedCuration::ButtonDefinition;
use ActivityBasedCuration::WorkflowDefinition;
use ActivityBasedCuration::ElementDescriptions;
use Debug;
my $dbg = sub {print STDERR @_};

use vars qw( $ButtonDefinition %ElementOccurance %ButtonOccurance
  %PaletteOccurance %QueryButtons %QueryProcessingButtons %QueryToProcessingButton
  %QueryChaining %WorkflowQueries %QueryDisplayButtons %QueryChainColumnButtons
  %QueryButtonsByQueryColumn %QueryButtonsByQueryPatColumn %QueryChainingByQuery
  %QueryChainingDetails);

$ButtonDefinition = <<EOF;

EOF

%QueryChaining = (
  qc_1 => {
    chained_query_id => "qc_1",
    caption => "files",
    from_query => "PixelTypes",
    to_query => "FileIdByPixelType",
    arg_map => {
      samples_per_pixel => "samples_per_pixel",
      bits_allocated => "bits_allocated",
      bits_stored => "bits_stored",
      high_bit => "high_bit",
      pixel_representation => "pixel_representation",
      planar_configuration => "planar_configuration",
      photometric_interpretation => "photometric_interpretation",
    },
  },
  qc_2 => {
    chained_query_id => "qc_2",
    caption => "Info",
    from_query => "HideEvents",
    to_query => "HideEventInfo",
    arg_map => {
      when_done => "day_of_change",
      reason_for => "reason_for",
      user_name => "user_name",
    },
  },
  qc_3 => {
    caption => "files",
    chained_query_id => "qc_3",
    from_query => "WhatHasComeInRecentlyWithSubject",
    to_query => "ToExamineRecentFiles",
    arg_map => {
      subj => "patient_id",
      time => "import_time_1",
      time => "import_time_2",
    },
  },
  qc_4 => {
    chained_query_id => "qc_4",
    caption => "Image Data Consistent?",
    from_query => "CtSeriesWithCtImageInfoByCollection",
    to_query => "CtImageDataConsistencyAcrossSeries",
    arg_map => {
      series_instance_uid => "series_instance_uid",
    },
  },
  qc_5 => {
    caption => "rpt",
    chained_query_id => "qc_5",
    from_query => "CtSeriesWithCtImageInfoByCollection",
    to_query => "SeriesReport",
    arg_map => {
      series_instance_uid => "series_instance_uid",
    },
  },
  qc_6 => {
    chained_query_id => "qc_6",
    caption => "drill",
    from_query => "QueriesRunning",
    to_query => "GetQuery",
    arg_map => {
      pid => "pid",
    },
  },
  qc_10 => {
    caption => "Details",
    chained_query_id => "qc_10",
    from_query => "VisualReviewStatusById",
    to_query => "VisualReviewStatusDetails",
    arg_map => {
      review_status => "review_status",
      processing_status => "processing_status",
      id => "visual_review_instance_id",
      dicom_file_type => "dicom_file_type",
    },
  },
  qc_8 => {
    chained_query_id => "qc_8",
    caption => "Details",
    from_query => "VisualReviewScanInstances",
    to_query => "VisualReviewStatusById",
    arg_map => {
      id => "id",
    },
  },
  qc_7 => {
    chained_query_id => "qc_7",
    caption => "GetSeries",
    from_query => "VisibleColSiteWithCtpLikeSite",
    to_query => "DistinctSeriesByCollectionSite",
    arg_map => {
      collection => "project_name",
      site => "site_name",
    },
  },
  qc_9 => {
    chained_query_id => "qc_9",
    caption => "Details",
    from_query => "ListActivities",
    to_query => "InboxContentByActivityId",
    arg_map => {
      activity_id => "activity_id",
    },
  },
  qc_12 => {
    chained_query_id => "qc_12",
    caption => "close",
    from_query => "ListOpenActivities",
    to_query => "CloseActivity",
    arg_map => {
      activity_id => "activity_id",
    },
  },
  qc_13 => {
    chained_query_id => "qc_13",
    caption => "Details",
    from_query => "ListOpenActivitiesWithItems",
    to_query => "InboxContentByActivityId",
    arg_map => {
      activity_id => "activity_id",
    },
  },
  qc_14 => {
    chained_query_id => "qc_14",
    caption => "close",
    from_query => "ListOpenActivitiesWithItems",
    to_query => "CloseActivity",
    arg_map => {
      activity_id => "activity_id",
    },
  },
  qc_15 => {
    chained_query_id => "qc_15",
    caption => "Details",
    from_query => "ListClosedActivities",
    to_query => "InboxContentByActivityId",
    arg_map => {
      activity_id => "activity_id",
    },
  },
  qc_16 => {
    chained_query_id => "qc_16",
    caption => "re-open",
    from_query => "ListClosedActivitiesWithItems",
    to_query => "ReOpenActivity",
    arg_map => {
      activity_id => "activity_id",
    },
  },
  qc_17=> {
    chained_query_id => "qc_17",
    caption => "Details",
    from_query => "ListClosedActivitiesWithItems",
    to_query => "InboxContentByActivityId",
    arg_map => {
      activity_id => "activity_id",
    },
  },
  qc_11=> {
    chained_query_id => "qc_11",
    caption => "Details",
    from_query => "ListOpenActivities",
    to_query => "InboxContentByActivityId",
    arg_map => {
      activity_id => "activity_id",
    },
  },
  qc_18=> {
    chained_query_id => "qc_18",
    caption => "re-open",
    from_query => "ListClosedActivities",
    to_query => "ReOpenActivity",
    arg_map => {
      activity_id => "activity_id",
    },
  },
  qc_19=> {
    chained_query_id => "qc_19",
    caption => "dismiss",
    from_query => "PendingExportRequests",
    to_query => "DismissExportEvent",
    arg_map => {
      export_event_id => "export_event_id",
    },
  },
  qc_20=> {
    chained_query_id => "qc_20",
    caption => "dismiss",
    from_query => "PendingExportRequestsByActivity",
    to_query => "DismissExportEvent",
    arg_map => {
      export_event_id => "export_event_id",
    },
  },
  qc_21=> {
    chained_query_id => "qc_21",
    caption => "dismiss",
    from_query => "ExportEventStatusSummary",
    to_query => "DismissExportEvent",
    arg_map => {
      export_event_id => "export_event_id",
    },
  },
  qc_22=> {
    chained_query_id => "qc_22",
    caption => "dismiss",
    from_query => "ExportEventStatusSummaryByActivity",
    to_query => "DismissExportEvent",
    arg_map => {
      export_event_id => "export_event_id",
    },
  },
  qc_23=> {
    chained_query_id => "qc_23",
    caption => "undismiss",
    from_query => "DismissedExportEventStatusSummary",
    to_query => "UnDismissExportEvent",
    arg_map => {
      export_event_id => "export_event_id",
    },
  },
  qc_24=> {
    chained_query_id => "qc_24",
    caption => "chain",
    from_query => "GetVisualReviewByActivityId",
    to_query => "VisualReviewStatusById",
    arg_map => {
      visual_review_instance_id => "id",
    },
  },
);

%QueryChainColumnButtons = (
  qc_c_2 => {
    query => "SopsDupsInDifferentSeriesByCollectionSite",
    obj => "Posda::PopupImageViewer",
    type => "ChainColumnToPopup",
    col_name => "file_id",
    caption => "View",
  },
  qc_cc_3 => {
    query => "SopsDupsInDifferentSeriesByCollectionSite",
    type => "ChainColumnToPopup",
    obj => "Posda::PopupCompare",
    col_name => "sop_instance_uid",
    caption => "Compare",
  },
  qc_cc_4 => {
    query => "DupSopsByCollectionSiteDateRange",
    type => "ChainColumnToPopup",
    obj => "Posda::PopupCompare",
    col_name => "sop_instance_uid",
    caption => "Compare",
  },
  qc_cc_5 => {
    query => "DuplicateFilesBySop",
    type => "ChainColumnToPopup",
    obj => "Posda::PopupCompare",
    col_name => "sop_instance_uid",
    caption => "Compare",
  },
  qc_cc_6 => {
    query => "DuplicateFilesBySop",
    type => "ChainColumnToPopup",
    obj => "Posda::PopupCompare",
    col_name => "sop_instance_uid",
    caption => "Compare",
  },
  qc_cc_7 => {
    query => "DuplicateFilesBySop",
    type => "ChainColumnToPopup",
    obj => "Posda::PopupCompare",
    col_name => "sop_instance_uid",
    caption => "Compare",
  },
  qc_cc_22 => {
    query_pat => "%",
    type => "ChainColumnToPopup",
    obj => "Quince",
    col_name => "series_instance_uid",
    caption => "view",
  },
  qc_cc_72_1 => {
    query => "ListSrTimepoint",
    type => "ChainColumnToPopup",
    obj => "DbIf::ShowSr",
    col_name => "file_path",
    caption => "view",
  },
  qc_cc_8 => {
    query_pat => "%",
    type => "ChainColumnToPopup",
    obj => "Posda::FileVisualizer",
    col_name => "file_id",
    caption => "view",
  },
  qc_cc_73 => {
    query =>"foo",
    type => "ChainColumnToPopup",
    obj => "Posda::TestPopup",
    col_name => "id",
    caption => "test",
  },
  qc_cc_74 => {
    query => "VisualReviewStatusById",
    type => "ChainColumnToPopup",
    obj => "Posda::TestRedirectPopup",
    col_name => "id",
    caption => "review",
  },
  qc_cc_67 => {
    query => "VisualReviewScanInstances",
    type => "ChainColumnToPopup",
    obj => "Posda::NewerProcessPopup",
    col_name => "fubar",
    spreadsheet_operation => "CreateActivityTimepoint",
    caption => "Create Activity Timepoint",
  },
  qc_cc_63 => {
    query => "InboxContentByActivityId",
    type => "ChainColumnToPopup",
    obj => "DbIf::ShowSubprocessLines",
    col_name => "sub_id",
    caption => "view",
  },
  qc_cc_51 => {
    query => "GeFromToFilesFromNonDicomEditCompare",
    type => "ChainColumnToPopup",
    obj => "choose_from_file_type",
    col_name => "to_file_id",
    col_to_param => {
      to_file_id => "file_id",
    },
    caption => "view",
  },
  qc_cc_52 => {
    query => "GeFromToFilesFromNonDicomEditCompare",
    type => "ChainColumnToPopup",
    obj => "choose_from_file_type",
    col_name => "from_file_id",
    col_to_param => {
      from_file_id => "file_id",
    },
    caption => "view",
  },
  qc_cc_54 => {
    query => "InboxContentByActivityId",
    type => "ChainColumnToPopup",
    obj => "choose_from_file_type",
    col_name => "spreadsheet_file_id",
    col_to_param => {
      spreadsheet_file_id => "file_id",
    },
    caption => "view",
  },
  qc_cc_70 => {
    query => "ListSrPublic",
    type => "ChainColumnToPopup",
    obj => "DbIf::ShowSr",
    col_name => "dicom_file_uri",
    caption => "view",
  },
  qc_cc_71 => {
    query => "ListSrPosda",
    type => "ChainColumnToPopup",
    obj => "DbIf::ShowSr",
    col_name => "file_path",
    caption => "view",
  },
  qc_cc_72 => {
    query => "ListSrPosdaHidden",
    type => "ChainColumnToPopup",
    obj => "DbIf::ShowSr",
    col_name => "file_path",
    caption => "view",
  },
  qc_cc_75 => {
    query => "GetEditStatusByDisposition",
    type => "ChainColumnToPopup",
    obj => "DbIf::EditStatus",
    col_name => "id",
    caption => "info",
  },
  qc_cc_76 => {
    query => "PendingExportRequestsByActivity",
    type => "ChainColumnToSubprocess",
    obj => "Posda::NewerProcessPopup",
    col_name => "export_event_id",
    caption => "start",
    operation => "StartExportEvent"
  },
  qc_cc_77 => {
    query => "PendingExportRequests",
    type => "ChainColumnToSubprocess",
    obj => "Posda::NewerProcessPopup",
    col_name => "export_event_id",
    caption => "start",
    operation => "StartExportEvent"
  },
  qc_cc_78 => {
    query => "ExportEventsAwaitingClosure",
    type => "ChainColumnToSubprocess",
    obj => "Posda::NewerProcessPopup",
    col_name => "export_event_id",
    caption => "close",
    operation => "CloseExportEvent"
  },
  qc_cc_79 => {
    query => "ExportEventsAwaitingClosureByActivity",
    type => "ChainColumnToSubprocess",
    obj => "Posda::NewerProcessPopup",
    col_name => "export_event_id",
    caption => "close",
    operation => "CloseExportEvent"
  },
);

%QueryProcessingButtons = (
  qpb_CreateActivityTimepointFromSeriesList => {
    caption => "Create Timepoint From Series List",
    spreadsheet_operation => "CreateActivityTimepointFromSeriesList",
    operation => "OpenNewTableLevelPopup",
    obj_class => "Posda::NewerProcessPopup",
    queries => {
      DistinctVisibleSeriesByCollectionSite => 1,
      DistinctSeriesByPatientId => 1,
      SeriesByMatchingImportEventsWithEventInfo => 1,
      SeriesByMatchingImportEventsAndDateRangeWithEventInfoAndPatientID => 1,
      SeriesByMatchingImportEventsAndDateRangeWithEventInfoCondensed => 1,
      SeriesByMatchingImportEventsAndDateRangeWithEventInfoAndPatientID => 1,
      SeriesByMatchingImportEventsWithEventInfoCondensed => 1,
      SeriesByMatchingImportEventsWithEventInfoAndFileCountAll => 1,
      SeriesByMatchingImportEventsWithEventInfoAndFileCount => 1,
    },
  },
  qpb_CreateActivityTimepointFromImportId => {
    caption => "Create Timepoint From DICOM Files in Import Event List",
    spreadsheet_operation => "CreateActivityTimepointFromImportId",
    operation => "OpenNewTableLevelPopup",
    obj_class => "Posda::NewerProcessPopup",
    queries => {
      ImportEventsByMatchingName => 1,
      ImportEventsByMatchingNameAndType => 1,
      ImportEventsWithTypeAndPatientId => 1,
    },
  },
  qpb_CreateActivityTimepointFromImportEventId => {
    caption => "Create Timepoint From All Files in Import Event List",
    spreadsheet_operation => "CreateActivityTimepointFromImportEventId",
    operation => "OpenNewTableLevelPopup",
    obj_class => "Posda::NewerProcessPopup",
    queries => {
      ImportEventsByMatchingName => 1,
      ImportEventsByMatchingNameAndType => 1,
      ImportEventsWithTypeAndPatientId => 1,
    },
  },
  qpb_BogusQueryHandlingButton => {
    caption => "Linked to non-existent operation",
    spreadsheet_operation => "DontEverNameAnOperationThis",
    operation => "OpenNewTableLevelPopup",
    obj_class => "Posda::NewerProcessPopup",
    queries => {
      SeriesByMatchingImportEventsWithEventInfoAndFileCount => 1,
    },
  },
  qpb_AnalyzeSeriesDuplicates => {
    caption => "Analyze Series Duplicates",
    spreadsheet_operation => "AnalyzeSeriesDuplicates",
    operation => "OpenNewTableLevelPopup",
    obj_class => "Posda::NewerProcessPopup",
    queries => {
      SeriesWithDupSopsByCollectionSiteNew => 1,
    },
  },
  qbp_BackgroundApplyPrivateDispositions => {
    caption => "Apply Private Dispositions",
    spreadsheet_operation => "BackgroundApplyPrivateDispositions",
    operation => "OpenNewTableLevelPopup",
    obj_class => "Posda::NewerProcessPopup",
    queries => {
      DistinctStudySeriesByCollection => 1,
      DistinctStudySeriesByCollectionSite => 1,
    },
  },
  qbp_BackgroundDciodvfySeries => {
    caption => "Run dciodvfy for series",
    spreadsheet_operation => "BackgroundDciodvfySeries",
    operation => "OpenNewTableLevelPopup",
    obj_class => "Posda::NewerProcessPopup",
    queries => {
      DistinctSeriesByCollection => 1,
      DistinctSeriesByCollectionSite => 1,
    },
  },
  qbp_ChangeReviewStatus => {
    caption => "Change Review Status",
    spreadsheet_operation => "ChangeReviewStatus",
    operation => "OpenNewTableLevelPopup",
    obj_class => "Posda::NewerProcessPopup",
    queries => {
      VisualReviewStatusDetails => 1,
    },
  },
  qbp_RetryFailedProjections => {
    caption => "Retry Failed Projections",
    spreadsheet_operation => "RetryFailedProjections",
    operation => "OpenNewTableLevelPopup",
    obj_class => "Posda::NewerProcessPopup",
    queries => {
      VisualReviewStatusDetails => 1,
    },
  },
  qbp_RemoveFilesMarkedBadFromActivity => {
    caption => "Remove Bad Sops from Timepoint",
    spreadsheet_operation => "RemoveFilesMarkedBadFromActivity",
    operation => "OpenNewTableLevelPopup",
    obj_class => "Posda::NewerProcessPopup",
    queries => {
      VisualReviewStatusById => 1,
    },
    params => {
      visual_review_id => 0,
    }
  },
);
# BackgroundDoseLinkageCheck            │ GetDoses                                  │ Posda::NewerProcessPopup
# BackgroundPhiScan                     │ DistinctSeriesByCollection                │ Posda::NewerProcessPopup
# BackgroundPhiScan                     │ DistinctSeriesByCollectionSite            │ Posda::NewerProcessPopup
# BackgroundPhiScan                     │ DistinctSeriesByCollectionSitePublic      │ Posda::NewerProcessPopup
# BackgroundPlanLinkageCheck            │ GetPlans                                  │ Posda::NewerProcessPopup
# BackgroundProcessModules              │ GetFilesWithNoSeriesInfoByCollection      │ Posda::NewerProcessPopup
# BackgroundStructLinkageCheck          │ GetSsByCollection                         │ Posda::NewerProcessPopup
# CheckConsistency                      │ DistinctSeriesByPatientAdvanced           │ Posda::NewerProcessPopup
# Compare                               │ GetSimilarDupContourCounts                │ Posda::PopupCompare
# CreateActivityTimepointFromSeriesList │ DistinctSeriesByPatientId                 │ Posda::NewerProcessPopup
# CreateActivityTimepointFromSeriesList │ DistinctVisibleSeriesByCollectionSite     │ Posda::NewerProcessPopup
# DciodvfySeriesReport                  │ DistinctSeriesByCollection                │ Posda::NewerProcessPopup
# DciodvfySeriesReport                  │ DistinctSeriesByCollectionSite            │ Posda::NewerProcessPopup
# DicomValidation                       │ DistinctSeriesByPatientAdvanced           │ Posda::NewerProcessPopup
# FileAndDismissNotifications           │ InboxContentAll                           │ Posda::NewerProcessPopup
# InitialAnonymizerCommands             │ AllPatientDetailsWithNoCtp%               │ Posda::NewerProcessPopup
# InitialAnonymizerCommands             │ AllPatientDetailsWithNoCtpLike            │ Posda::NewerProcessPopup
# InitialAnonymizerCommands             │ PatientDetailsWithBlankCtp                │ Posda::NewerProcessPopup
# InitialAnonymizerCommands             │ PatientDetailsWithNoCtp                   │ Posda::NewerProcessPopup
# LinkForDownload                       │ DistinctSeriesByPatientAdvanced           │ Posda::NewerProcessPopup
# LinkSeries                            │ DistinctSeriesByPatient                   │ Posda::NewerProcessPopup
# LinkSeries                            │ SummaryOfToFiles                          │ Posda::NewerProcessPopup
# LinkSeries                            │ SummaryOfToFilesForPatient                │ Posda::NewerProcessPopup
# MakePassThru                          │ VisualReviewStatusById                    │ Posda::NewerProcessPopup
# PhiScan                               │ ColSiteDetails                            │ Posda::NewerProcessPopup
# PhiScan                               │ DistinctSeriesByPatient                   │ Posda::NewerProcessPopup
# PrivateDispositions                   │ DistinctSeriesByPatientAdvanced           │ Posda::NewerProcessPopup
# ProcessRADCOMPUpload                  │ GetZipUploadEventsByDateRangeNonDicomOnly │ Posda::NewerProcessPopup
# ProcessVisualReview                   │ VisualReviewStatusById                    │ Posda::NewerProcessPopup
# RadcompSubmissionConverter            │ GetDocxToConvert                          │ Posda::NewerProcessPopup
# RetryFailedProjections                │ VisualReviewStatusDetails                 │ Posda::NewerProcessPopup
# SendBlankToDest                       │ VisualReviewStatusById                    │ Posda::NewerProcessPopup
# VisualReview                          │ DistinctSeriesByCollectionSite            │ Posda::NewerProcessPopup
# XlsConverter                          │ GetXlsToConvert                           │ Posda::NewerProcessPopup
# XlsxConverter                         │ GetXlsxToConvert                          │ Posda::NewerProcessPopup


for my $i (keys %QueryProcessingButtons){
  for my $q (keys %{$QueryProcessingButtons{$i}->{queries}}){
    unless(exists $QueryToProcessingButton{$q}){ $QueryToProcessingButton{$q} = [] }
    push @{$QueryToProcessingButton{$q}}, $QueryProcessingButtons{$i};
  }
}
  #%QueryButtonsByQueryColumn %QueryButtonsByQueryPatColumn);
for my $i (keys %QueryChainColumnButtons){
  my $r = $QueryChainColumnButtons{$i};
  if(exists $r->{query_pat}){
    $QueryButtonsByQueryPatColumn{$r->{query_pat}}->{$r->{col_name}} = $i;
  } elsif (exists $r->{query}){
    $QueryButtonsByQueryColumn{$r->{query}}->{$r->{col_name}} = $i;
  }
}
for my $i (keys %QueryChaining){
   my $r = $QueryChaining{$i};
  $QueryChainingByQuery{$r->{from_query}} = $i;
  my $m = $r->{arg_map};
  my @map;
  for my $k (keys %{$m}){
    push @map, { $k => $m->{$k} };
  }
  $QueryChainingDetails{$i} = \@map;
}

1;
