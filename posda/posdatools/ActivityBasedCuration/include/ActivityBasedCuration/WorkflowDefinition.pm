#!/bin/perl -w
use strict;
package ActivityBasedCuration::WorkflowDefinition;
use Debug;
my $dbg = sub {print @_};
use vars qw(@ActivityCategories %WorkflowQueries);

@ActivityCategories = (
  {
    id => "1_associate",
    name => "Create and Manage Activity Timepoints",
    note => "You must first Import Data into Posda and create an Activity!",
    description => "Curation workflow tasks performed on a collection are " .
      "grouped together into an Activity Timepoint to allow for better " .
      "management and analysis.  This step is tying the data to the Activity.",
    operations => [
      {
        operation => "FilesInTpNotInPublic",
        caption => "Find files In Timepoint Not In Public",
        action =>  "FilesInTpNotInPublic",
      },
    #  {
    #    operation => "ConsolidateVisualReview",
    #    caption =>"ConsolidateVisualReview",
    #    action =>"ConsolidateVisualReview",
    #  },
    ],
    queries => [
      {
        caption => "Suggested Queries for Creating a Timepoint from Import Event IDs",
        operation => "SelectQueryGroup",
        query_list_name => "FindImportEvents",
      },
      {
        caption => "Suggested Queries for Creating a Timepoint from Date Range for CTP data",
        operation => "SelectQueryGroup",
        query_list_name => "CTPImports",
      },
    ],
  },
  {
    id => "2_pmap",
    name => "Patient Mapping",
    note => " This step should not be needed if your data was imported through CTP",
    description => "Maps each patient to a new identifier that does not contain PHI. (e.g. Pat_030)",
    operations => [
      {
       operation => "InvokeNewOperation",
       caption => "Import Patient Mappings For Timepoint",
       action =>  "ImportPatientMapping",
       special => "spreadsheetRequest"
     },
    ],
  },
  {
    id => "3_ianon",
    name => "Initial Anonymization",
    note => " This step should not be needed if your data was imported through CTP",
    description => "Once the mapping is in place, we can run the initial " .
      "anonymization step. Again, this step can often be skipped if the data is " .
      "already initially de-identified, such as when it was sent from CTP(A tool " .
      "some sites use that sends and partially de-identifies data).",
    operations => [
     {
        operation => "InvokeNewOperation",
        caption => "Produce Initial Anonymizer for Timepoint",
        action =>  "InitialAnonymizerCommandsTp",
      },
    ],
  },
  {
    id => "4_count",
    name => "Run Count Checks",
    description => "Verification of the number of files sent to confirm " .
      "with the sending site that everything arrived as expected.",
    queries => [
      {
        caption => "Suggested Queries for Count Checks",
        operation => "SelectQueryGroup",
        query_list_name => "RunCountChecks",
      },
    ],
  },
    {
      id => "5_dupes",
      name => "Check for Duplicate SOPs",
      description => "This process builds a report to alert you to " .
        "duplicated data or data where multiple entities are using the same identifiers.",
        operations => [
          {
            operation => "InvokeNewOperation",
            caption => "Compare Duplicate Sops in Timepoint",
            action =>  "CompareDupSopsInTimepoint",
          },
        ],
        queries => [
          {
            caption => "Suggested Queries for Duplicate SOPs",
            operation => "SelectQueryGroup",
            query_list_name => "DupeSops",
          },
      ],
    },
  {
    id => "6_concheck",
    name => "Run Consistency Check",
    description => "Verification that the series data is consistent.",
    operations => [
      {
        operation => "InvokeNewOperation",
        caption => "Check Consistency",
        action =>  "ConsistencyFromTimePoint",
      },
    ],
  },
  {
    id => "7_dciodvfy",
    name => "Verify DICOM IOD (Dciodvfy)",
    description => "Verify the IOD is correct for DICOM standard.",
    operations => [
      {
        caption => "Dciodvfy",
        action =>  "BackgroundDciodvfyTp",
      },
    ],
  },
  {
    id => "8_vr",
    name => "Visual Review",
    description => "Examine the pixel data for Personal Health Information.",
    operations => [
      {
        operation => "InvokeNewOperation",
        caption => "Schedule Visual Review",
        action =>  "VisualReviewFromTimepoint",
      },
      {
        operation => "InvokeNewOperation",
        caption => "Pathology Schedule Visual Review",
        action =>  "Path_SVS_VisualReview",
      },
    ],
    queries => [
      {
        caption => "Suggested Queries for Visual Review Status",
        operation => "SelectQueryGroup",
        query_list_name => "VisualReviewStatus",
      },
    ],
  },
  {
    id => "9_phirev",
    name => "PHI Review",
    description => "This will create a report. Any PHI found should be " .
      "edited in the report and the report should be uploaded and processed.",
    operations => [
      {
        caption => "Schedule PHI Scan",
        action =>  "PhiReviewFromTimepoint",
      },
      {
        caption => "Schedule Structured Report PHI Scan",
        action =>  "SRPhiScanOp",
      },
    ],
  },
  {
    id => "10_structlinkcheck",
    name => "Check Struct Linkage",
    note => "Radiation Therapy Data only",
    description => "Verify that the ROIs and Structures are properly " .
      "linked to the image files and pixel data. ",
    operations => [
      {
        caption => "Check Structure Set Linkage",
        action =>  "CheckStructLinkagesTp",
      },
    ],
  },
  {
    id => "11_linkrt",
    name => "Link RT Data",
    note => "Radiation Therapy Data only ",
    description => "Link RT data",
    operations => [
      {
        caption => "Link RT Data",
        action =>  "LinkRtFromTimepoint",
      },
    ],
    queries => [
       {
        caption => "Series Linked to RtStructs",
        operation => "SelectQueryGroup",
        query_list_name => "LinkedRtStructs",
      },
    ],
  },
  {
    id => "12_send",
    name => "Send to Server (NBIA)",
    description => "Confirm data is fully cleaned and ready to be sent to " .
      "the publicly accessibly server and send the data.",
    operations => [
      {
        caption => "Apply Background Dispositions to Timepoint (non baseline date)",
        action =>  "BackgroundPrivateDispositionsTp",
      },
      {
        caption => "Apply Background Dispositions to Timepoint (baseline date)",
        action =>  "BackgroundPrivateDispositionsTpBaseline",
      },
      {
        caption => "Queue An Export of All Files in Timepoint",
        action =>  "ExportTimepoint",
      },
    ],
    queries => [
      {
        caption => "Suggested Queries For Export Events By Activity",
        operation => "SelectQueryGroup",
        query_list_name => "ExportEventsByActivity",
      },
      {
        caption => "Suggested Queries For Export Events",
        operation => "SelectQueryGroup",
        query_list_name => "ExportEvents",
      },
    ],
  },
  {
    id => "13_compare",
    name => "Compare data to Server (NBIA)",
    description => "Ensure all the files sent to the public server properly",
    operations => [
      {
        caption => "Public Phi Scan Based on Current TP by Activity",
        action =>  "PhiPublicScanTp",
      },
      {
        caption => "VA Phi 'Public' Scan Based on ImportEventId",
        action =>  "PhiVaPublicScanTp",
      },
      {
        caption => "VA Phi 'Public' Scan Based on Download Dir",
        action =>  "PhiVaPublicScanDD",
      },
      {
        caption => "VA Import Download Dir",
        action =>  "ImportDownloadableDirectory",
      },
      {
        caption => "Find Files in Tp, not in Public",
        action =>  "FilesInTpNotInPublic",
      },
    ],
  },
  {
    id => "14_report",
    name => "Produce Activity Report",
    description => "Create an activity report.",
    operations => [
      {
        caption => "Produce Condensed Activity Timepoint Report",
        action =>  "CondensedActivityTimepointReport",
      },
    ],
    queries => [
       {
        caption => "Activity Report Queries",
        operation => "SelectQueryGroup",
        query_list_name => "ActivityReports",
      },
    ],
  },
  {
    id => "15_copyTP",
    name => "Copy or Consolidate Timepoints",
    note => "These operations require uploading a Spreadsheet",
    description => "Sometimes in order to solve an unusual issue " .
      "you will want to make a second copy of the Timepoint " .
      "You may also want to merge Timepoints together.",
    operations => [
    {
      operation => "CopyPriorTimepoint",
      caption => "Copy Prior Timepoint",
      action => "CopyPriorTimepoint"
    },
    {
      operation => "CopyPriorTimepointExcludingFiles",
      caption => "Copy Prior Timepoint Excluding Files",
      action => "CopyPriorTimepointExcludingFiles",
      special => "spreadsheetRequest"
    },
    {
      operation => "ConsolidateTimepoints",
      caption =>"Consolidate Timepoints",
      action =>"ConsolidateTimepoints",
      special => "spreadsheetRequest"
    },
    {
      operation => "ConsolidateActivities",
      caption =>"Consolidate Activities",
      action =>"ConsolidateActivities",
      special => "spreadsheetRequest"
    },
    ],
    queries => [
      {
        caption => "Copy Files",
        operation => "SelectQueryGroup",
        query_list_name => "CopyFiles",
      },
    ],
  },
  {
    id => "16_Pathology",
    name => "Pathology",
    note => "These operations are PATHOLOGY specific",
    description => "Pathology workflow items",
    operations => [
      # {
      #   caption => "View Latest VR",
      #   action => 'setForegroundQuery',
      #   query_name => 'ViewPathologyVisualReviewInstances'
      # },
    {
      operation => "InvokeNewOperation",
      caption => "Create Activity from Import",
      action =>  "PathologyCreateActivityAndTP"
    },
    {
      operation => "InvokeNewOperation",
      caption => "Patient Mapping",
      action =>  "Path_Patient_Mapping",
      special => "spreadsheetRequest"
    },
    {
      caption => "Schedule PHI Scan",
      action =>  "Path_PHI_Scan",
    },
    {
      operation => "InvokeNewOperation",
      caption => "Create Visual Review",
      action =>  "Path_SVS_VisualReview",
    },
    {
      operation => "InvokeNewOperation",
      caption => "Commit Queued Edits",
      action =>  "Path_Commit_Edits",
    },
   ],
    queries => [
      {
         caption => "View PHI Scan",
         operation => "SelectQueryGroup",
         query_list_name => "Display_TiffPHI_Report",
       },
      {
        caption => "Visual Review and Status",
        operation => "SelectQueryGroup",
        query_list_name => "PathVisualReviewStatus",
       },
    ],
  },
  {
    id => "17_other",
    name => "Other",
    description => "Miscellaneous operations",
    operations => [
      {
        caption => "Make a Downloadable Directory",
        action =>  "MakeDownloadableDirectoryTp",
      },
      {
        caption => "Make a Downloadable Directory with non-dicom files",
        action =>  "CreateDownloadableDirectoryAllTp",
      },
      {
        caption => "Import Downloadable Directory",
        action =>  "ImportDownloadableDirectory",
      },
      {
        caption => "Copy SOP Class and SOP instance from Meta-header",
        action =>  "FixReallyBadDicomFilesInTimepoint",
      },
      {
        caption => "Generate List of Weekly Uploads By File Type",
        action =>  "MakeWeeklyFilesReport",
      },
      {
        caption => "Make Worksheet For Dispositions Needed",
        action =>  "DispositionNeededWorksheet",
      },
      {
        caption => "Create Private Tag VR and Disposition Reports",
        action =>  "PrivateTagReports",
      },
      {
        caption => "Create New Timepoint from Old Timepoint Id",
        action =>  "CopyPriorTimepoint",
      },
      {
        caption => "Correct Tomosynthesis Files",
        action =>  "TomosynthesisConverterTP",
      },
      {
        caption => "Make a hashed UID mapping spreadsheet",
        action =>  "MakeUIDMap",
      },
      {
        caption => "Process Nifti Files In Timepoint",
        action =>  "PopulateNiftiSlicesAndProjectionsForTimepoint",
      },
      {
        caption => "Find Nifti Files In Timepoint",
        action =>  "PopulateFileNiftiTp",
      },
      {
        caption => "Make a Downloadable Directory (including Non-Dicom)",
        action =>  "MakeDownloadableNonDicomTp",
      },
      {
        caption => "Byte Swap Dicom Pixel Data",
        action =>  "BackgroundSwapDicomPixelsData",
      },
      {
        caption => "Big Endian -> Little Endian",
        action =>  "ConvertBigEndianToLittle",
      },
    ],
  },
  {
    id => "18_defacing",
    name => "Dicom Image Defacing",
    note => "Operations and queries related to determing if images need defacing ".
      "and defacig them if they do",
    description => "Curators are expected to determine if DICOM series in the collection " .
      "need to be defaced, and to see that they are defaced if they do.  Here is a " .
      "set of scripts and queries to assist in this activity.",
    operations => [
      {
        operation => "PopulateFileNiftiTp",
        caption => "Find files In Timepoint which parse as Nifti, and populate file_nifti table",
        action =>  "PopulateFileNiftiTp",
      },
      {
        operation => "ReQueueFileNiftiDefacing",
        caption => "Requeue Files in FileNiftiDefacing",
        action =>  "ReQueueFileNiftiDefacing",
      },
      {
        operation => "ProposeUIDchangeEdits",
        caption => "Shift UIDs for new version",
        action =>  "ProposeUIDchangeEdits",
      },
    ],
    queries => [
      {
        caption => "Suggested Queries for Managing Image Defacing",
        operation => "SelectQueryGroup",
        query_list_name => "ImageDefacing",
      },
    ],
  },
);

%WorkflowQueries = (
  FindImportEvents => [
    "Suggested Queries for Import Events",
    [
    {
      caption =>"ApiImportEvents",
      query =>"ApiImportEvents",
    }, {
      caption =>"ApiImportEventsDateRange",
      query =>"ApiImportEventsDateRange",
    },
    {
      caption =>"ApiImportEventsForPatient",
      query =>"ApiImportEventsForPatient",
    },
    {
      caption =>"FindingImportEvent",
      query =>"FindingImportEvent",
    },
    {
      caption =>"GetAllFilesByImportEventId",
      query =>"GetAllFilesByImportEventId",
    },
    {
      caption =>"GetDicomFilesByImportEventId",
      query =>"GetDicomFilesByImportEventId",
    },
    {
      caption =>"GetImportEventIdByImportName",
      query =>"GetImportEventIdByImportName",
    },
    {
      caption => "ImportEvents",
      query => "ImportEvents",
    },
    {
      caption => "ImportEventsByDateRange",
      query => "ImportEventsByDateRange",
    },
    {
      caption => "ImportEventsByMatchingName",
      query => "ImportEventsByMatchingName",
    },
    {
      caption => "ImportEventsByMatchingNameAndType",
      query => "ImportEventsByMatchingNameAndType",
    },
    {
      caption =>"ImportEventsWithTypeAndPatientId",
      query =>"ImportEventsWithTypeAndPatientId",
    }
    ],
  ],
  CTPImports => [
    "Suggested Queries for Importing CTP data by Date Range",
    [
      {
        caption => "CTP Brief Import Summary By Date Range",
        query => "CtpImportBriefSummaryByDateRange",
      },
      {
        caption => "CTP Import Summary By Date Range",
        query => "CtpImportSummaryByDateRange",
      },
      {
        caption => "CTP Imports By Date Range",
        query => "CtpImportsByDateRange",
      },
      {
        caption => "CTP Imports By Date Range With Series and Study",
        query => "CtpImportsByDateRangeWithSeriesStudy",
      },
      {
        caption => "CTP Imports By Date Range With FileId",
        query => "CtpImportsByDateRangeWithFileId",
      },
    ],
  ],
  DupeSops => [
    "Suggested Queries for Duplicate SOPs",
    [
      {
        caption => "Series with Dup Sops in Tp with SOP and file counts",
        query => "SeriesWithDupSopsInTimepoint",
      },
      {
        caption => "Dup Sops In Timepoint With Series File Ids And Load Times",
        query => "DupSopsInTimepointWithSeriesFileIdsAndLoadTimes",
      },
    ],
  ],
  CopyFiles => [
    "Suggested Queries for Copying Files",
    [
      {
	      caption => "Files In Timepoint With PatientId",
        query => "FilesInTimepointWithPatientId",
      },
      {
        caption => "Files In Timepoint Excluding Patient Id",
        query => "FilesInTimepointExcludingPatientId",
      },
    ],
  ],
  RunCountChecks => [
    "Suggested Queries for Count Checks",
    [
      {
	      caption => "CountsByCollectionLikeSite",
        query => "CountsByCollectionLikeSite",
      },
      {
        caption => "CountsByCollectionSite",
        query => "CountsByCollectionSite",
      },
      {
	      caption => "CountsByCollectionDateRange",
        query => "CountsByCollectionDateRange",
      },
      {
        caption => "CountsByCollectionSiteDateRange",
        query => "CountsByCollectionSiteDateRange",
      },
      {
        caption => "CountsByPatientId",
        query => "CountsByPatientId",
      },
      {
        caption => "PatientStatusCounts",
        query => "PatientStatusCounts",
      },
      {
        caption => "CountsByCollectionLike",
        query => "CountsByCollectionLike",
      },
    ],
  ],
  VisualReviewStatus => [
    "Suggested Queries for Visual Review Status",
    [
      {
        caption => "VisualReviewScanInstances (generally obsolete)",
        query => "VisualReviewScanInstances",
      },
      {
        caption => "VisualReviewForActivity",
        query => "GetVisualReviewByActivityId",
      },
    ],
  ],
  ActivityReports => [
    "Suggested Queries for Activity Timepoint Reports",
    [
      {
        caption => "VerboseActivityTimepointReport",
        query => "VerboseActivityTimepointReport",
      },
      {
        caption => "FilesSeriesNumFIlesAndSopsVisibilityInTimepoint",
        query => "FilesSeriesNumFIlesAndSopsVisibilityInTimepoint",
      },
      {
        caption => "TimepointCreationReport",
        query => "TimepointCreationReport",
      },
    ],
  ],
  LinkedRtStructs => [
    "Suggested Queries for Series with Linked RT Structs",
    [
      {
        caption => "LinkedSeriesForStructsInTimepoint",
        query => "LinkedSeriesForStructsInTimepoint",
      },
    ],
  ],
  ExportEventsByActivity => [
    "Suggested Queries for ExportEvents By Activity",
    [
      {
        caption => "Pending Exports",
        query => "PendingExportRequestsByActivity",
      },
#      {
#        caption => "Running Exports",
#        query => "RunningExportRequestsByActivity",
#      },
#      {
#        caption => "Completed Exports",
#        query => "CompletedExportRequestsByActivity",
#      },
      {
        caption => "Export Event Summary",
        query => "ExportEventStatusSummaryByActivity",
      },
      {
        caption => "Export Events Awaiting Closure",
        query => "ExportEventsAwaitingClosureByActivity",
      },
    ],
  ],
  ExportEvents => [
    "Suggested Queries for ExportEvents",
    [
      {
        caption => "Pending Exports",
        query => "PendingExportRequests",
      },
      {
        caption => "Running Exports",
        query => "RunningExportRequests",
      },
      {
        caption => "Completed Exports",
        query => "CompletedExportRequests",
      },
      {
        caption => "Export Event Summary",
        query => "ExportEventStatusSummary",
      },
      {
        caption => "Dismissed Export Event Summary",
        query => "DismissedExportEventStatusSummary",
      },
      {
        caption => "Export Events Awaiting Closure",
        query => "ExportEventsAwaitingClosure",
      },
    ],
  ],
  ImageDefacing => [
    "Suggested Queries for ImageDefacing",
    [
      {
        caption => "Series Which May Need Defacing",
        query => "SeriesWhichMayNeedDefacing",
      },
      {
        caption => "Nifti Conversions For Timepoint",
        query => "ListNiftiConversionsForActivityTp",
      },
      {
        caption => "Nifti Files For Nifti Conversion",
        query => "ListNiftiFileFromSeriesByNiftiConversion",
      },
    ],
  ],
  Display_TiffPHI_Report => [
    "Suggested Queries for Tiff PHI Reporting",
    [
      {
        caption => "Display created Tiff PHI Report",
        query => "RunTiffPHIReport",
      },
    ],
  ],
  PathVisualReviewStatus => [
    "Pathology Suggested Queries for Visual Review",
    [
      {
        caption => "View Pathology VR Instances (Launcher)",
        query => "ViewPathologyVisualReviewInstances",
      },
      {
        caption => "PathologyVRlogs",
        query => "PathologyVRlogs",
      },
      {
        caption => "PathologyReviewCountByActivity",
        query => "PathologyReviewCountByActivity",
      },
      {
        caption => "PathologyReviewCountByActivityTimepoint",
        query => "PathologyReviewCountByActivityTimepoint",
      },
      {
        caption => "PathologyBadFilesInTPCheck",
        query => "PathologyBadFilesInTPCheck",
      },
      {
        caption => "PathologyViewEdits",
        query => "PathologyViewEdits",
      },
    ],
   ],
);
