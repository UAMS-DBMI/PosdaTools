#!/bin/perl -w 
package ActivityBasedCuration::ButtonDefinition;
use ActivityBasedCuration::ElementDescriptions;
use Debug;
my $dbg = sub {print @_};

use vars qw( $ButtonDefinition %ElementOccurance %ButtonOccurance
  %PaletteOccurance %QueryButtons %QueryProcessingButtons %QueryToProcessingButton
  %QueryChaining);

$ButtonDefinition = <<EOF;

EOF

%QueryChaining = (
  qc_1 => {
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
    from_query => "WhatHasComeInRecentlyWithSubject",
    to_query => "ToExamineRecentFiles",
    arg_map => {
      subj => "patient_id",
      time => "import_time_1",
      time => "import_time_2",
    },
  },
  qc_4 => {
    caption => "Image Data Consistent?",
    from_query => "CtSeriesWithCtImageInfoByCollection",
    to_query => "CtImageDataConsistencyAcrossSeries",
    arg_map => {
      series_instance_uid => "series_instance_uid",
    },
  },
  qc_5 => {
    caption => "rpt",
    from_query => "CtSeriesWithCtImageInfoByCollection",
    to_query => "SeriesReport",
    arg_map => {
      series_instance_uid => "series_instance_uid",
    },
  },
  qc_6 => {
    caption => "drill",
    from_query => "QueriesRunning",
    to_query => "GetQuery",
    arg_map => {
      pid => "pid",
    },
  },
);
#chained_query_id	caption	from_query	to_query	from_column_name	to_parameter_name
#7	Get Series	VisibleColSiteWithCtpLikeSite	DistinctSeriesByCollectionSite	collection	project_name
#7	Get Series	VisibleColSiteWithCtpLikeSite	DistinctSeriesByCollectionSite	site	site_name
#8	Details	VisualReviewScanInstances	VisualReviewStatusById	id	id
#9	Details	ListActivities	InboxContentByActivityId	activity_id	activity_id
#12	close	ListOpenActivities	CloseActivity	activity_id	activity_id
#12	close	ListOpenActivities	CloseActivity	activity_id	activity_id
#13	Details	ListOpenActivitiesWithItems	InboxContentByActivityId	activity_id	activity_id
#14	close	ListOpenActivitiesWithItems	CloseActivity	activity_id	activity_id
#15	Details	ListClosedActivities	InboxContentByActivityId	activity_id	activity_id
#16	re-open	ListClosedActivitiesWithItems	ReOpenActivity	activity_id	activity_id
#17	Details	ListClosedActivitiesWithItems	InboxContentByActivityId	activity_id	activity_id
#10	Details	VisualReviewStatusById	VisualReviewStatusDetails	review_status	review_status
#10	Details	VisualReviewStatusById	VisualReviewStatusDetails	processing_status	processing_status
#10	Details	VisualReviewStatusById	VisualReviewStatusDetails	id	visual_review_instance_id
#10	Details	VisualReviewStatusById	VisualReviewStatusDetails	dicom_file_type	dicom_file_type
#11	Details	ListOpenActivities	InboxContentByActivityId	activity_id	activity_id
#18	re-open	ListClosedActivities	ReOpenActivity	activity_id	activity_id

%QueryDisplayButtons = (
  popup_2 => {
    query_name => "SopsDupsInDifferentSeriesByCollectionSite",
    object_class => "Posda::PopupImageViewer",
    column_name => "file_id",
    caption => "View",
  },
  popup_3 => {
    query_name => "SopsDupsInDifferentSeriesByCollectionSite",
    object_class => "Posda::PopupCompare",
    column_name => "sop_instance_uid",
    caption => "Compare",
  },
  popup_4 => {
    query_name => "DupSopsByCollectionSiteDateRange",
    object_class => "Posda::PopupCompare",
    column_name => "sop_instance_uid",
    caption => "Compare",
  },
  popup_5 => {
    query_name => "DuplicateFilesBySop",
    object_class => "Posda::PopupCompare",
    column_name => "sop_instance_uid",
    caption => "Compare",
  },
  popup_6 => {
    query_name => "DuplicateFilesBySop",
    object_class => "Posda::PopupCompare",
    column_name => "sop_instance_uid",
    caption => "Compare",
  },
  popup_7 => {
    query_name => "DuplicateFilesBySop",
    object_class => "Posda::PopupCompare",
    column_name => "sop_instance_uid",
    caption => "Compare",
  },
  popup_9 => {
    query_name => "GetSimilarDupContourCounts",
    object_class => "Posda::PopupCompare",
    caption => "Compare",
  },
  popup_10 => {
    query_name => "DistinctSeriesByCollection",
    object_class => "Posda::ProcessPopup",
    caption => "BackgroundPhiScan",
    operation => "BackgroundPhiScan",
  },
  popup_11 => {
    query_name => "DistinctSeriesByCollection",
    object_class => "Posda::ProcessPopup",
    caption => "BackgroundDciodvfySeries",
    operation => "BackgroundDciodvfySeries",
  },
  popup_12 => {
    query_name => "DistinctSeriesByCollection",
    object_class => "Posda::ProcessPopup",
    caption => "DciodvfySeriesReport",
    operation => "DciodvfySeriesReport",
  },
  popup_13 => {
    query_name => "DistinctStudySeriesByCollection",
    object_class => "Posda::ProcessPopup",
    caption => "BackgroundApplyPrivateDispositions",
    operation => "BackgroundApplyPrivateDispositions",
  },
  popup_14 => {
    query_name => "GetDoses",
    object_class => "Posda::ProcessPopup",
    caption => "BackgroundDoseLinkageCheck",
    operation => "BackgroundDoseLinkageCheck",
  },
  popup_15 => {
    query_name => "GetPlans",
    object_class => "Posda::ProcessPopup",
    caption => "BackgroundPlanLinkageCheck",
    operation => "BackgroundPlanLinkageCheck",
  },
  popup_16 => {
    query_name => "GetSsByCollection",
    object_class => "Posda::ProcessPopup",
    caption => "BackgroundStructLinkageCheck",
    operation => "BackgroundStructLinkageCheck",
  },
  popup_17 => {
    query_name => "DistinctStudySeriesByCollectionSite",
    object_class => "Posda::ProcessPopup",
    caption => "BackgroundApplyPrivateDispositions",
    operation => "BackgroundApplyPrivateDispositions",
  },
  popup18 => {
    query_name => "DistinctSeriesByCollectionSite",
    object_class => "Posda::ProcessPopup",
    caption => "BackgroundPhiScan",
    operation => "BackgroundPhiScan",
  },
  popup_19 => {
    query_name => "DistinctSeriesByCollectionSite",
    object_class => "Posda::ProcessPopup",
    caption => "BackgroundDciodvfySeries",
    operation => "BackgroundDciodvfySeries",
  },
  popup_20 => {
    query_name => "DistinctSeriesByCollectionSite",
    object_class => "Posda::ProcessPopup",
    caption => "DciodvfySeriesReport",
    operation => "DciodvfySeriesReport",
  },
  popup_21 => {
    query_name => "DistinctSeriesByCollectionSitePublic",
    object_class => "Posda::ProcessPopup",
    caption => "BackgroundPhiScan",
    operation => "BackgroundPhiScan",
  },
  popup_22 => {
    query_name => "%",
    object_class => "Quince",
    column_name => "series_instance_uid",
    caption => "view",
  },
  popup_8 => {
    query_name => "%",
    object_class => "choose",
    column_name => "file_id",
    caption => "view",
  },
  popup_73 => {
    query_name => "foo",
    object_class => "Posda::TestPopup",
    column_name => "id",
    caption => "test",
  },
  popup_74 => {
    query_name => "VisualReviewStatusById",
    object_class => "Posda::TestRedirectPopup",
    column_name => "id",
    caption => "review",
  },
  popup_67 => {
    query_name => "VisualReviewScanInstances",
    object_class => "Posda::ProcessPopup",
    column_name => "fubar",
    caption => "CreateActivityTimepoint",
    operation => "CreateActivityTimepoint",
  },
  popup_36 => {
    query_name => "ColSiteDetails",
    object_class => "Posda::ProcessPopup",
    caption => "PhiScan",
    operation => "PhiScan",
  },
  popup_37 => {
    query_name => "DistinctSeriesByPatient",
    object_class => "Posda::ProcessPopup",
    caption => "LinkSeries",
    operation => "LinkSeries",
  },
  popup_38 => {
    query_name => "DistinctSeriesByPatient",
    object_class => "Posda::ProcessPopup",
    caption => "PhiScan",
    operation => "PhiScan",
  },
  popup_39 => {
    query_name => "DistinctSeriesByPatientAdvanced",
    object_class => "Posda::ProcessPopup",
    caption => "CheckConsistency",
    operation => "CheckConsistency",
  },
  popup_40 => {
    query_name => "DistinctSeriesByPatientAdvanced",
    object_class => "Posda::ProcessPopup",
    caption => "DicomValidation",
    operation => "DicomValidation",
  },
  popup_41 => {
    query_name => "DistinctSeriesByPatientAdvanced",
    object_class => "Posda::ProcessPopup",
    caption => "LinkForDownload",
    operation => "LinkForDownload",
  },
  popup_42 => {
    query_name => "DistinctSeriesByPatientAdvanced",
    object_class => "Posda::ProcessPopup",
    caption => "PrivateDispositions",
    operation => "PrivateDispositions",
  },
  popup_43 => {
    query_name => "PatientDetailsWithBlankCtp",
    object_class => "Posda::ProcessPopup",
    caption => "InitialAnonymizerCommands",
    operation => "InitialAnonymizerCommands",
  },
  popup_44 => {
    query_name => "PatientDetailsWithNoCtp",
    object_class => "Posda::ProcessPopup",
    caption => "InitialAnonymizerCommands",
    operation => "InitialAnonymizerCommands",
  },
  popup_45 => {
    query_name => "SummaryOfToFiles",
    object_class => "Posda::ProcessPopup",
    caption => "LinkSeries",
    operation => "LinkSeries",
  },
  popup_46 => {
    query_name => "SummaryOfToFilesForPatient",
    object_class => "Posda::ProcessPopup",
    caption => "LinkSeries",
    operation => "LinkSeries",
  },
  popup_63 => {
    query_name => "InboxContentByActivityId",
    object_class => "DbIf::ShowSubprocessLines",
    column_name => "sub_id",
    caption => "view",
  },
  popup_47 => {
    query_name => "GetZipUploadEventsByDateRangeNonDicomOnly",
    object_class => "Posda::ProcessPopup",
    caption => "ProcessRADCOMPUpload",
    operation => "ProcessRADCOMPUpload",
  },
  popup_49 => {
    query_name => "GetXlsToConvert",
    object_class => "Posda::ProcessPopup",
    caption => "XlsConverter",
    operation => "XlsConverter",
  },
  popup_50 => {
    query_name => "GetXlsxToConvert",
    object_class => "Posda::ProcessPopup",
    caption => "XlsxConverter",
    operation => "XlsxConverter",
  },
  popup_48 => {
    query_name => "GetDocxToConvert",
    object_class => "Posda::ProcessPopup",
    caption => "RadcompSubmissionConverter",
    operation => "RadcompSubmissionConverter",
  },
  popup_51 => {
    query_name => "GeFromToFilesFromNonDicomEditCompare",
    object_class => "choose_to",
    column_name => "to_file_id",
    caption => "view",
  },
  popup_52 => {
    query_name => "GeFromToFilesFromNonDicomEditCompare",
    object_class => "choose_from",
    column_name => "from_file_id",
    caption => "view",
  },
  popup_53 => {
    query_name => "AllPatientDetailsWithNoCtpLike",
    object_class => "Posda::ProcessPopup",
    caption => "InitialAnonymizerCommands",
    operation => "InitialAnonymizerCommands",
  },
  popup_55 => {
    query_name => "DistinctSeriesByCollectionSite",
    object_class => "Posda::ProcessPopup",
    caption => "VisualReview",
    operation => "VisualReview",
  },
  popup_56 => {
    query_name => "SeriesWithDupSopsByCollectionSiteNew",
    object_class => "Posda::ProcessPopup",
    caption => "AnalyzeSeriesDuplicates",
    operation => "AnalyzeSeriesDuplicates",
  },
  popup_57 => {
    query_name => "GetFilesWithNoSeriesInfoByCollection",
    object_class => "Posda::ProcessPopup",
    caption => "BackgroundProcessModules",
    operation => "BackgroundProcessModules",
  },
  popup_58 => {
    query_name => "InboxContentAll",
    object_class => "Posda::ProcessPopup",
    caption => "FileAndDismissNotifications",
    operation => "FileAndDismissNotifications",
  },
  popup_59 => {
    query_name => "VisualReviewStatusById",
    object_class => "Posda::ProcessPopup",
    caption => "MakePassThru",
    operation => "MakePassThru",
  },
  popup_61 => {
    query_name => "VisualReviewStatusById",
    object_class => "Posda::ProcessPopup",
    caption => "ProcessVisualReview",
    operation => "ProcessVisualReview",
  },
  popup_62 => {
    query_name => "VisualReviewStatusById",
    object_class => "Posda::ProcessPopup",
    caption => "SendBlankToDest",
    operation => "SendBlankToDest",
  },
  popup_64 => {
    query_name => "VisualReviewStatusDetails",
    object_class => "Posda::ProcessPopup",
    caption => "RetryFailedProjections",
    operation => "RetryFailedProjections",
  },
  popup_54 => {
    query_name => "InboxContentByActivityId",
    object_class => "choose_spreadsheet",
    column_name => "spreadsheet_file_id",
    caption => "view",
  },
  popup_60 => {
    query_name => "VisualReviewStatusDetails",
    object_class => "Posda::ProcessPopup",
    caption => "HideEquivalenceClasses",
    operation => "HideEquivalenceClasses",
  },
  popup_65 => {
    query_name => "VisualReviewStatusDetails",
    object_class => "Posda::ProcessPopup",
    caption => "ChangeReviewStatus",
    operation => "ChangeReviewStatus",
  },
  popup_66 => {
    query_name => "VisualReviewStatusById",
    object_class => "Posda::ProcessPopup",
    caption => "ApplyDispositions",
    operation => "ApplyDispositions",
  },
  popup_68 => {
    query_name => "DistinctVisibleSeriesByCollectionSite",
    object_class => "Posda::ProcessPopup",
    caption => "CreateActivityTimepointFromSeriesList",
    operation1 => "CreateActivityTimepointFromSeriesList",
  },
  popup_69 => {
    query_name => "DistinctSeriesByPatientId",
    object_class => "Posda::ProcessPopup",
    caption => "CreateActivityTimepointFromSeriesList",
    operation => "CreateActivityTimepointFromSeriesList",
  },
  popup_70 => {
    query_name => "ListSrPublic",
    object_class => "DbIf::ShowSr",
    column_name => "dicom_file_uri",
    caption => "view",
  },
  popup_71 => {
    query_name => "ListSrPosda",
    object_class => "DbIf::ShowSr",
    column_name => "file_path",
    caption => "view",
  },
  popup_72 => {
    query_name => "ListSrPosdaHidden",
    object_class => "DbIf::ShowSr",
    column_name => "file_path",
    caption => "view",
  },
  popup_75 => {
    query_name => "GetEditStatusByDisposition",
    object_class => "DbIf::EditStatus",
    column_name => "id",
    caption => "info",
  },
  popup_35 => {
    query_name => "AllPatientDetailsWithNoCtp%",
    object_class => "Posda::ProcessPopup",
    caption => "InitialAnonymizerCommands",
    operation => "InitialAnonymizerCommands",
  }
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
      SeriesByMatchingImportEventsWithEventInfoAndFileCount => 1,
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
);
# BackgroundDoseLinkageCheck            │ GetDoses                                  │ Posda::ProcessPopup
# BackgroundPhiScan                     │ DistinctSeriesByCollection                │ Posda::ProcessPopup
# BackgroundPhiScan                     │ DistinctSeriesByCollectionSite            │ Posda::ProcessPopup
# BackgroundPhiScan                     │ DistinctSeriesByCollectionSitePublic      │ Posda::ProcessPopup
# BackgroundPlanLinkageCheck            │ GetPlans                                  │ Posda::ProcessPopup
# BackgroundProcessModules              │ GetFilesWithNoSeriesInfoByCollection      │ Posda::ProcessPopup
# BackgroundStructLinkageCheck          │ GetSsByCollection                         │ Posda::ProcessPopup
# ChangeReviewStatus                    │ VisualReviewStatusDetails                 │ Posda::ProcessPopup
# CheckConsistency                      │ DistinctSeriesByPatientAdvanced           │ Posda::ProcessPopup
# Compare                               │ GetSimilarDupContourCounts                │ Posda::PopupCompare
# CreateActivityTimepointFromSeriesList │ DistinctSeriesByPatientId                 │ Posda::ProcessPopup
# CreateActivityTimepointFromSeriesList │ DistinctVisibleSeriesByCollectionSite     │ Posda::ProcessPopup
# DciodvfySeriesReport                  │ DistinctSeriesByCollection                │ Posda::ProcessPopup
# DciodvfySeriesReport                  │ DistinctSeriesByCollectionSite            │ Posda::ProcessPopup
# DicomValidation                       │ DistinctSeriesByPatientAdvanced           │ Posda::ProcessPopup
# FileAndDismissNotifications           │ InboxContentAll                           │ Posda::ProcessPopup
# HideEquivalenceClasses                │ VisualReviewStatusDetails                 │ Posda::ProcessPopup
# InitialAnonymizerCommands             │ AllPatientDetailsWithNoCtp%               │ Posda::ProcessPopup
# InitialAnonymizerCommands             │ AllPatientDetailsWithNoCtpLike            │ Posda::ProcessPopup
# InitialAnonymizerCommands             │ PatientDetailsWithBlankCtp                │ Posda::ProcessPopup
# InitialAnonymizerCommands             │ PatientDetailsWithNoCtp                   │ Posda::ProcessPopup
# LinkForDownload                       │ DistinctSeriesByPatientAdvanced           │ Posda::ProcessPopup
# LinkSeries                            │ DistinctSeriesByPatient                   │ Posda::ProcessPopup
# LinkSeries                            │ SummaryOfToFiles                          │ Posda::ProcessPopup
# LinkSeries                            │ SummaryOfToFilesForPatient                │ Posda::ProcessPopup
# MakePassThru                          │ VisualReviewStatusById                    │ Posda::ProcessPopup
# PhiScan                               │ ColSiteDetails                            │ Posda::ProcessPopup
# PhiScan                               │ DistinctSeriesByPatient                   │ Posda::ProcessPopup
# PrivateDispositions                   │ DistinctSeriesByPatientAdvanced           │ Posda::ProcessPopup
# ProcessRADCOMPUpload                  │ GetZipUploadEventsByDateRangeNonDicomOnly │ Posda::ProcessPopup
# ProcessVisualReview                   │ VisualReviewStatusById                    │ Posda::ProcessPopup
# RadcompSubmissionConverter            │ GetDocxToConvert                          │ Posda::ProcessPopup
# RetryFailedProjections                │ VisualReviewStatusDetails                 │ Posda::ProcessPopup
# SendBlankToDest                       │ VisualReviewStatusById                    │ Posda::ProcessPopup
# VisualReview                          │ DistinctSeriesByCollectionSite            │ Posda::ProcessPopup
# XlsConverter                          │ GetXlsToConvert                           │ Posda::ProcessPopup
# XlsxConverter                         │ GetXlsxToConvert                          │ Posda::ProcessPopup



for my $k(keys %ElementOccurance){
  my $d = $ElementOccurance{$k};
  if(exists $d->{is_posda_button}){
    $ButtonOccurance{$k} = 1;
    if(
      exists($d->{occurance}->{where}) &&
      ref($d->{occurance}->{where}) eq ""
    ){
      $w = $d->{occurance}->{where};
      if(
        exists $ElementOccurance{$w} &&
        exists $ElementOccurance{$w}->{occurance}->{is_posda_button_palette}
      ){
        unless(exists $PaletteOccurance{$w}){
          $PaletteOccurance{$w} = {};
        }
        $PaletteOccurance{$w}->{buttons}->{$k} = 1;
      }
    } elsif(exists $d->{occurance}->{is_posda_button_palette}){
      unless(exists $PaletteOccurance{$w}){
        $PaletteOccurance{$w} = {};
      }
    }
  }
}
for my $i (keys %QueryProcessingButtons){
  for my $q (keys %{$QueryProcessingButtons{$i}->{queries}}){
    unless(exists $QueryToProcessingButton{$q}){ $QueryToProcessingButton{$q} = [] }
    push @{$QueryToProcessingButton{$q}}, $QueryProcessingButtons{$i};
  }
}


print "PaletteOccurance: ";
Debug::GenPrint($dbg, \%PaletteOccurance, 1);
print "\n";
print "ButtonOccurance: ";
Debug::GenPrint($dbg, \%ButtonOccurance, 1);
print "\n";
