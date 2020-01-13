#!/bin/perl -w  
package ActivityBasedCuration::ButtonDefinition;
use Debug;
my $dbg = sub {print @_};

use vars qw( $Description %ElementOccurance %ButtonOccurance
  %PaletteOccurance %QueryButtons %QueryProcessingButtons %QueryToProcessingButton);

$Definition = <<EOF;
Definition of Button Descriptor Structure
The ButtonDescriptorStructure is a recursive hash/array structure which
contains a defintion of all of the buttons which occur in the
ActivityBasedCuration application in Posda.  It replaces the data
currently found in the following database tables:

chained_queries
chained_query_cols_to_params
popup_buttons
background_buttons

In general, the purpose of this structure is to assign the following things
to a "button_occurance":
 - a "button_occurance_id" which is unique to this button.
 - a place it shows up in the user_interface, this can be in a number of
   different types of places:
     - In a palatte of buttons (like the current "ActivityOperations")
     - At the top of a query results display.  These are for operations
       to be performed for a list of query results.  Normally these are
       spreadsheet operations of type "background_process" with the
       query results serving as input to the background subprocess. They
       could, however, serve as input to a foreground (possibly interactive)
       process (like an SR Viewer).
     - At the beginning of a row in query display.  Currently these
       buttons are "chained queries".  They use the contents of the
       selected row as input to a second query.  They could also use
       the contents of the current row as input to a "background_process",
       or "interactive_viewer".
     - In a cell of a query display.  In this case, currently, it invokes
       an interactive viewer.  Somethimes this interactive viewer is a
       separate program (like Quince or Kaleidoscope), sometimes a Posda
       sub-program (like Dicom Compare).  In practice, it is probably
       best to treat both cases as a Posda sub-program (see the
       ActivityBasedCuration::Quince module)
 - How to display the button: the caption, and the style (perhaps other
   attributes TBD.
 - An operation to be invoked.  In many cases this is a "spreadsheet_operation"
   to be run in the background.  In some cases, it may invoke another query.
   It may call up a separate mode of application operation.
 - Potentially, a mode of operation invocation (i.e. popup or in-line).

Generally, all of the information is contained in a single hash:
%ElementOccurances = (
  <element_occurance_id> => <element_descriptor>,
  ...
);
The id musy be unique, and is an alpha_numeric string (with underscores).

A element descriptor is itself a hash, which captures the attributes of the
element:
{
  class => <class>,
  type => <type>,
  [caption => <caption>,]
  occurance => <occurance_descriptor>
};
EOF

%ElementOccurance = (
  "div-navbar" => {
    class => "container-fluid",
    tag => "div",
    description => "container for top bar",
    occurance => "top of page",
  },
  "div-logo" =>{
    class => "navbar-header",
    tag => "div",
    description => "contains posda logo",
    occurance => {
      where => "div-navbar",
      index => 0,
    },
  },
  "div-app-layout" => {
    class => "container-fluid",
    tag => "div",
    description => "contains app header, menu and content",
    occurance => {
      where => "following navbar",
    },
  },
  "header" => {
    class => "page-header",
    tag => "div",
    description => "contains page title (status)",
    occurance => {
      where => "div-app-layout"
    }
  },
  "div-menu-content" => {
    class => "row",
    tag => "div",
    description => "contains menu and content",
    occurance => {
      where => "div-app-layout",
    }
  },
  "menu" => {
    class => "col-md-2",
    tag => "div",
    description => "contains menu",
    occurance => {
      where => "div-menu-content",
      index => 0,
    }
  },
  "div-main-menu" => {
    class => "btn-group-vertical spacer-bottom",
    tag => "div",
    description => "contains button palette for main menu",
    occurance => {
      where => "menu",
      index => 1,
      is_posda_button_palette =>1,
    },
  },
  "div-main-menu_0" => {
    class => [cond => [[unread_inbox => "user"], [quote => "btn btn-danger"]], [quote => "btn btn-default"]],
    tag => "a",
    caption => [cond => [[unread_inbox => "user"], [concat => [quote => "Inbox"], [quote => "{"]], [[unread_inbox => "user"], [quote => "}"]]], [quote => "Inbox"]],
    occurance => {
      where => "div-main-menu",
      index => 0,
    },
    is_posda_button => 1,
    action => [set_main_mode => [quote => "Inbox"]],
  },
  "div-main-menu_1" => {
    class => "btn btn-default",
    caption => "Upload",
    tag => "a",
    occurance => {
      where => "div-main-menu",
      index => 1,
    },
    is_posda_button => 1,
    action => [set_main_mode => [quote => "Upload"]],
  },
  "div-main-menu_2" => {
    class => "btn btn-default",
    caption => "Activity",
    tag => "a",
    occurance => {
      where => "div-main-menu",
      index => 2,
    },
    is_posda_button => 1,
    action => [set_main_mode => [quote => "Activity"]],
  },
  "div-main-menu_3" => {
    class => "btn btn-default",
    caption => "Download",
    tag => "a",
    occurance => {
      where => "div-main-menu",
      index => 3,
    },
    is_posda_button => 1,
    action => [set_main_mode => [quote => "Download"]],
  },
  "div-main-menu_4" => {
    class => "btn btn-default",
    caption => "ShowBackground",
    tag => "a",
    occurance => {
      where => "div-main-menu",
      index => 4,
    },
    is_posda_button => 1,
    action => [set_main_mode => [quote => "ShowBackground"]],
  },
  "div-main-menu_5" => {
    class => "btn btn-default",
    caption => "Files",
    tag => "a",
    occurance => {
      where => "div-main-menu",
      index => 5,
    },
    is_posda_button => 1,
    action => [set_main_mode => [quote => "Files"]],
  },
  "div-main-menu_6" => {
    class => "btn btn-default",
    caption => "Tables",
    tag => "a",
    occurance => {
      where => "div-main-menu",
      index => 6,
    },
    is_posda_button => 1,
    action => [set_main_mode => [quote => "Tables"]],
  },
  "content" => {
    class => "col-md-2",
    tag => "div",
    description => "contains content",
    occurance => {
      where => "div-menu-content",
      index => 1,
    },
  },
  SelectActivityDropdown => {
    class => "form-control",
    tag => "select",
    description => "dropdown for selecting an activity",
    occurance => {
      where => "content",
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivitySelected", [quote => "<none>"]]],
    },
    action => [set => [quote => "ActivitySelected"], [value => "self" ]],
  },
  ActivityFilterEntryBox => {
    class => "form-control",
    name => "Filter",
    tag => "input",
    type => "text",
    description => "filter for options in dropdown for selecting an activity",
    occurance => {
      where => "content",
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivitySelected", [quote => "<none>"]]],
    },
    action => [set => [quote => "ActivityFilter"], [value => "self" ]],
  },
  newActivity => {
    class => "form-control",
    tag => "input",
    description => "new activity goes here",
    occurance => {
      where => "content",
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivitySelected", [quote => "<none>"]]],
    },
  },
  SaveNewActivity => {
    class => "btn btn-primary",
    tag => "input",
    type => "submit",
    caption => "Save",
    description => "Create new activity button",
    occurance => {
      where => "content",
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivitySelected", [quote => "<none>"]]],
    },
    action => [create_activity => [value => "newActivity" ]],
  },
  "selected_activity" => {
    tag => "div",
    description => "Show Selected Activity at top of content page",
    occurance => {
      where => "div-content",
      index => 1,
      condition => [eq => "Mode", [quote => "Activities"]],
    },
  },
  "IsThirdPartyYes" => {
    tag => "input",
    type => "radio",
    group => "IsThirdParty",
    description => "Select that timepoint is for third-party analysis",
    occurance => {
      where => "div-content",
      index => 1,
      condition => [eq => "Mode", [quote => "Activities"]],
    },
  },
  "IsThirdPartyNo" => {
    tag => "input",
    type => "radio",
    class => "form-control",
    description => "Select that timepoint is not for third-party analysis",
    occurance => {
      where => "div-content",
      index => 1,
      condition => [eq => "Mode", [quote => "Activities"]],
    },
  },
  "ThirdPartyEntry" => {
    tag => "input",
    type => "text",
    group => "IsThirdParty",
    description => "Allow entry of url for third party analysis",
    occurance => {
      where => "div-content",
      index => 1,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "is_third_party", [quote => "yes"]]],
    },
  },
  "ClearCurrentActivity" => {
    tag => "input",
    type => "button",
    caption => "Choose Another Activity",
    description => "Clear the currently selected activity (to select another)",
    occurance => {
      where => "div-content",
      index => 1,
      condition => [eq => "Mode", [quote => "Activities"]],
    },
  },
  "activitytaskstatus" => {
    tag => "div",
    description => "Show activity task status messages for currently selected activity1",
    occurance => {
      where => "selected-activity",
      index => 1,
      condition => [eq => "Mode", [quote => "Activities"]],
    },
  },
  "DismissActivityTaskStatus_<task>" => {
    tag => "input",
    type => "button",
    caption => "dismiss",
    description => "Dismiss activity_task_status row by subprocess_invocation_id",
    substitute_in_id => {
      task => subprocess_invocation_id,
    },
    occurance => {
      where => "activitytaskstatus",
      index => 1,
      condition => [eq => "Mode", [quote => "Activities"]],
    },
  },
  "div_ShowActivityTimeline" => {
    tag => "div",
    description => "Activity Timeline is inner HTML",
    occurance => {
      where => "content",
      index => 1,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ShowActivityTimeline"]]],
    },
  },
  "btnCompareTimepoints" => {
    tag => "input",
    type => "button",
    class => "btn btn-default",
    description => "Button to compare timepoints",
    caption => "cmp",
    occurance => {
      where => "div_ShowActivityTimeline",
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ShowActivityTimeline"]]],
    },
  },
  "fromActivityTimepoint_<tp_id>" => {
    tag => "input",
    type => "radio",
    group => "from",
    description => "Select that timepoint is from timepoint in compare",
    substitute_in_id => {
      tp_id => activity_timepoint_id,
    },
    occurance => {
      where => "div_ShowActivityTimeline",
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ShowActivityTimeline"]]],
    },
  },
  "toActivityTimepoint_<tp_id>" => {
    tag => "input",
    type => "radio",
    group => "to",
    description => "Select that timepoint is to timepoint in compare",
    substitute_in_id => {
      tp_id => activity_timepoint_id,
    },
    occurance => {
      where => "div_ShowActivityTimeline",
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ShowActivityTimeline"]]],
    },
  },
  "tl_show_email_<sub_id>" => {
    tag => "input",
    type => "button",
    class => "btn btn-default",
    description => "show email for subprocess",
    substitute_in_id => {
      sub_id => subprocess_invocation_id,
    },
    occurance => {
      where => "div_ShowActivityTimeline",
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ShowActivityTimeline"]]],
    },
  },
  "tl_show_resp_<sub_id>" => {
    tag => "input",
    type => "button",
    class => "btn btn-default",
    description => "show response for subprocess",
    substitute_in_id => {
      sub_id => subprocess_invocation_id,
    },
    occurance => {
      where => "div_ShowActivityTimeline",
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ShowActivityTimeline"]]],
    },
  },
  "tl_show_input_<sub_id>" => {
    tag => "input",
    type => "button",
    class => "btn btn-default",
    description => "show input for subprocess",
    substitute_in_id => {
      sub_id => subprocess_invocation_id,
    },
    occurance => {
      where => "div_ShowActivityTimeline",
      condition => [and =>
        [eq => "Mode", [quote => "Activities"]],
        [eq => "ActivityMode", [quote => "ShowActivityTimeline"]],
        [has => [subprocess_invocation => "sub_id"], [quote => "spreadsheet_id"]],
      ],
    },
  },
  "div_ActivityOperations" => {
    tag => "div",
    description => "Activity Operations Pallete is inner HTML",
    occurance => {
      where => "content",
      index => 1,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
  },
  "tbl_ActivityOperations" => {
    tag => "table",
    class => "table table-striped table-condensed",
    description => "Activity Operations Button Palette",
    occurance => {
      where => "div_ActivityOperations",
      is_inner_html => "true",
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
      is_posda_button_palette => 1,
    },
  },
  btn_activity_op_CreateActivityTimepointFromImportName =>{
    caption => "Create Activity Timepoint from Import Name",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      row => 0, col => 0,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "CreateActivityTimepointFromImportName"]],
  },
  btn_activity_op_CreateActivityTimepointFromCollectionSite => {
    caption => "Create Activity Timepoint",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 0, row => 1,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "CreateActivityTimepointFromCollectionSite"]],
  },
  btn_activity_op_VisualReviewFromTimepoint => {
    caption => "Schedule Visual Review",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 0, row => 2,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "VisualReviewFromTimepoint"]],
  },
  btn_activity_op_PhiReviewFromTimepoint => {
    caption => "Schedule PHI Scan",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 0, row => 3,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "PhiReviewFromTimepoint"]],
  },
  btn_activity_op_ConsistencyFromTimePoint => {
    caption => "Check Consistency",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 0, row => 4,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "ConsistencyFromTimePoint"]],
  },
  btn_activity_op_LinkRtFromTimepoint => {
    caption => "Link RT Data for ItcTools",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 0, row => 5,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "LinkRtFromTimepoint"]],
  },
  btn_activity_op_CheckStructLinkagesTp => {
    caption => "Check Structure Set Linkages",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 0, row => 6,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "CheckStructLinkagesTp"]],
  },
  btn_activity_op_MakeDownloadableDirectoryTp => {
    caption => "Make a Downloadable Directory",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 0, row => 7,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "MakeDownloadableDirectoryTp"]],
  },
  btn_activity_op_PhiPublicScanTp => {
    caption => "Public Phi Scan Based on Current TP by Activity",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 1, row => 0,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "PhiPublicScanTp"]],
  },
  btn_activity_op_SuggestPatientMappings => {
    caption => "Suggest Patient Mapping for Timepoint",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 1, row => 1,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "SuggestPatientMappings"]],
  },
  btn_activity_op_BackgroundDciodvfyTp => {
    caption => "Run Dciodvfy for Time Point",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 1, row => 2,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "BackgroundDciodvfyTp"]],
  },
  btn_activity_op_CondensedActivityTimepointReport => {
    caption => "Produce Condensed Activity Timepoint Report",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 1, row => 3,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "CondensedActivityTimepointReport"]],
  },
  btn_activity_op_AnalyzeSeriesDuplicates => {
    caption => "Analyze Series With Duplicates",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 1, row => 4,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "AnalyzeSeriesDuplicates"]],
  },
  btn_activity_op_FilesInTpNotInPublic => {
    caption => "Find Files in Tp, not in Public",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 1, row => 5,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "FilesInTpNotInPublic"]],
  },
  btn_activity_op_CompareSopsInTpToPublic => {
    caption => "Compare Corresponding SOPs in Time Point to Public",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 1, row => 6,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "CompareSopsInTpToPublic"]],
  },
  btn_activity_op_HelloWorldPerl => {
    caption => "Perl Hello World Background",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 1, row => 7,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "HelloWorldPerl"]],
  },
  btn_activity_op_AnalyzeSeriesDuplicatesForTimepoint => {
    caption => "Analyze Series In Time Point with Duplicates",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 2, row => 0,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "AnalyzeSeriesDuplicatesForTimepoint"]],
  },
  btn_activity_op_CompareSopsTpPosdaPublic => {
    caption => "Compare Sops in Timepoint, Posda, and Public",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 2, row => 1,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "CompareSopsTpPosdaPublic"]],
  },
  btn_activity_op_BackgroundPrivateDispositionsTp => {
    caption => "Apply Background Dispositions To Timepoint (non baseline date)",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 2, row => 2,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "BackgroundPrivateDispositionsTp"]],
  },
  btn_activity_op_BackgroundPrivateDispositionsTpBaseline => {
    caption => "Apply Background Dispositions To Timepoint (baseline date)",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 2, row => 3,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "BackgroundPrivateDispositionsTpBaseline"]],
  },
  btn_activity_op_CompareSopsTpPosdaPublicLike => {
    caption => "Compare Sops in Timepoint, Posda, and Public like Collection",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 2, row => 4,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "CompareSopsTpPosdaPublicLike"]],
  },
  btn_activity_op_UpdateActivityTimepoint => {
    caption => "Update Activity Timepoint",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 2, row => 5,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "UpdateActivityTimepoint"]],
  },
  btn_activity_op_InitialAnonymizerCommandsTp => {
    caption => "Produce Initial Anonymizer For Timepoint",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 2, row => 6,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "InitialAnonymizerCommandsTp"]],
  },
  btn_activity_op_UpdateTimepointAfterEdit => {
    caption => "Update Timepoint After Edit",
    class => "btn btn-default",
    occurance => {
      where =>"tbl_ActivityOperations",
      col => 2, row => 7,
      condition => [and => [eq => "Mode", [quote => "Activities"]], [eq => "ActivityMode", [quote => "ActivityOperations"]]],
    },
    tag => "input",
    type => "button",
    is_posda_button => 1,
    action => [invoke_operation => [quote => "UpdateTimepointAfterEdit"]],
  },
);

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
  popup_1 => {
    query_name => "%EditResults%",
    object_class => "Posda::PopupCompareFilesPath",
    caption => "Compare Files",
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
    obj_class => "Posda::NewProcessPopup",
    queries => {
      DistinctVisibleSeriesByCollectionSite => 1,
      DistinctSeriesByPatientId => 1,
      SeriesByMatchingImportEventsWithEventInfo => 1,
      SeriesByMatchingImportEventsWithEventInfoAndFileCount => 1,
    },
  },
);
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


print "ElementOccurance: ";
Debug::GenPrint($dbg, \%ElementOccurance, 1);
print "\n";
print "PaletteOccurance: ";
Debug::GenPrint($dbg, \%PaletteOccurance, 1);
print "\n";
print "ButtonOccurance: ";
Debug::GenPrint($dbg, \%ButtonOccurance, 1);
print "\n";
