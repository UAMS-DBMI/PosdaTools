#!/bin/perl -w
package ActivityBasedCuration::WorkflowDefinition;
use Debug;
my $dbg = sub {print @_};

@ActivityCategories = (
  {
    id => "1_associate",
    name => "Associate Imported Data with an Activity Timepoint",
    note => "You must first Import Data into Posda and create an Activity!",
    description => "Curation workflow tasks performed on a collection are grouped together into an Activity Timepoint to allow for better management and analysis.  This step is tying the data to the Activity.",
    operation1 => {
        caption => "Suggested Queries by Series",
        action => { "SuggestQueries" => { "SeriesByMatchingImportEventsWithEventInfo", "SeriesByMatchingImportEventsAndDateRangeWithEventInfoAndPatientID", "SeriesByMatchingImportEventsAndDateRangeWithEventInfoCondensed", "SeriesByMatchingImportEventsAndDateRangeWithEventInfoAndPatientID" ,"SeriesByMatchingImportEventsWithEventInfoCondensed", "SeriesByMatchingImportEventsWithEventInfoAndFileCountAll" }},
        },
    operation2 => {
        caption => "Suggested Queries by other parameters",
        action => { "SuggestQueries" => { "ImportEventsByMatchingName","ImportEventsByMatchingNameAndType","ImportEventsWithTypeAndPatientId" }},
    },
  },
  {
    id => "2_count",
    name => "Run Count Checks",
    description => "Verification of the number of files sent to confirm with the sending site that everything arrived as expected.",
    operation1 => {
        caption => "Suggested Queries",
        action => { "SuggestQueries" => { "CountsByCollectionDateRange","CountsByCollectionSiteDateRange","CountsByPatientID","CountsByPatientStatus","CountsByCollectionLike" }},
    },
  },
  {
    id => "3_dupes",
    name => "Check for Duplicate SOPs",
    description => "This process builds a report to alert you to duplicated data or data where multiple entities are using the same identifiers.",
    operation1 => {
        caption => "Analyze Series in Time Point with Duplicates",
        action =>  "AnalyzeSeriesDuplicates",
    },
  },
  {
    id => "4_pmap",
    name => "Create Patient Mapping",
    note => " This step should not be needed if your data was imported through CTP",
    description => "Maps each patient to a new identifier that does not contain PHI. (e.g. Pat_030)",
    operation1 => {
        caption => "Suggest Patient Mappings For Timepoint",
        action =>  "SuggestPatientMappings",
    },
  },
  {
    id => "5_ianon",
    name => "Initial Anonymization",
    note => " This step should not be needed if your data was imported through CTP",
    description => "Once the mapping is in place, we can run the initial anonymization step. Again, this step can often be skipped if the data is already initially de-identified, such as when it was sent from CTP(A tool some sites use that sends and partially de-identifies data).",
    operation1 => {
        caption => "Produce Initial Anonymizer for Timepoint",
        action =>  "InitialAnonymizerCommandsTp",
    },
  },
  {
    id => "6_concheck",
    name => "Run Consistency Check",
    description => "Verification that the series data is consistent.",
    operation1 => {
        caption => "Check Consistency",
        action =>  "ConsistencyFromTimePoint",
    },
  },
  {
    id => "7_vr",
    name => "Start Visual Review",
    description => "Examine the pixel data for Personal Health Information.",
    operation1 => {
        caption => "Schedule Visual Review",
        action =>  "VisualReviewFromTimepoint",
    },
  },
  {
    id => "8_dciodvfy",
    name => "Verify DICOM IOD (Dciodvfy)",
    description => "Verify the IOD is correct for DICOM standard.",
    operation1 => {
        caption => "Dciodvfy",
        action =>  "BackgroundDciodvfyTp",
    },
  },
  {
    id => "9_phirev",
    name => "PHI Review",
    description => "This will create a report. Any PHI found should be edited in the report and the report should be uploaded and processed.",
    operation1 => {
        caption => "Schedule PHI Scan",
        action =>  "PhiReviewFromTimepoint",
    },
  },
  {
    id => "10_structlinkcheck",
    name => "Check Struct Linkage",
    note => "Radiation Therapy Data only",
    description => "Verify that the ROIs and Structures are properly linked to the image files and pixel data. ",
    operation1 => {
        caption => "Check Structure Set Linkage",
        action =>  "CheckStructLinkagesTp",
    },
  },
  {
    id => "11_linkrt",
    name => "Link RT Data",
    note => "Radiation Therapy Data only ",
    description => "Link RT data",
    operation1 => {
        caption => "Link RT Data",
        action =>  "LinkRtFromTimepoint",
    },
  },
  {
    id => "12_send",
    name => "Send to Server (NBIA)",
    description => "Confirm data is fully cleaned and ready to be sent to the publicly accessibly server and send the data.",
    operation1 => {
        caption => "Apply Background Dispositions to Timepoint (non baseline date)",
        action =>  "BackgroundPrivateDispositionsTp",
      },
    operation2 => {
        caption => "Apply Background Dispositions to Timepoint (baseline date)",
        action =>  "BackgroundPrivateDispositionsTpBaseline",
    },
  },
  {
    id => "13_compare",
    name => "Compare data to Server (NBIA)",
    description => "Ensure all the files sent to the public server properly",
    operation1 => {
        caption => "Public Phi Scan Based on Current TP by Activity",
        action =>  "PhiPublicScanTp",
      },
    operation2 => {
        caption => "Find Files in Tp, not in Public",
        action =>  "FilesInTpNotInPublic",
    },
  },
  {
    id => "14_report",
    name => "Produce Activity Report",
    description => "Create an activity report.",
    operation1 => {
        caption => "Produce Condensed Activity Timepoint Report",
        action =>  "CondensedActivityTimepointReport",
    },
  },
  {
    id => "14_other",
    name => "Other",
    description => "Miscellaneous operations",
    operation1 => {
        caption => "Make a Downloadable Directory",
        action =>  "MakeDownloadableDirectoryTp",
      },
    },
);
