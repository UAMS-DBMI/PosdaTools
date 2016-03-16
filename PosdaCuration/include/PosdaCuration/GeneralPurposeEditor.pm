#!/usr/bin/perl -w
#
use strict;
package PosdaCuration::GeneralPurposeEditor;
use Posda::HttpApp::JsController;
use Posda::HttpApp::HttpObj;
use Posda::UUID;
use Posda::ElementNames;
use PosdaCuration::InfoExpander;
use Posda::UidCollector;
use Dispatch::NamedObject;
use Dispatch::LineReader;
use Digest::MD5;
use JSON;
use Debug;
use Storable;
my $dbg = sub {print STDERR @_ };
use utf8;
use vars qw( @ISA );
my $expander = '<?dyn="Content"?>';
@ISA = ( "Posda::HttpApp::JsController", "Posda::UidCollector" ,
  "PosdaCuration::InfoExpander" );
sub new {
  my($class, $sess, $path, $display_info) = @_;
  my $this = Dispatch::NamedObject->new($sess, $path);
  $this->{expander} = $expander;
  $this->{DisplayInfoIn} = $display_info;
  bless $this, $class;
  $this->InitializeEdit;
  $this->{Mode} = "EnteringEdits";
  return $this;
}
sub Content{
  my($this, $http, $dyn) = @_;
  if($this->{Mode} eq "Error"){
    return $this->ErrorContent($http, $dyn);
  }
  $this->RefreshEngine($http, $dyn, 
    '<h3>General Purpose Edit for Collection: ' . 
    $this->{DisplayInfoIn}->{Collection} . ', Site: ' .
    $this->{DisplayInfoIn}->{Site} . ', Subject: ' .
    $this->{DisplayInfoIn}->{subj} . '</h3>' .
    '<table width="100%">' .
    '<tr><td align="left" valign="top" width="50%">' .
    '<?dyn="NotSoSimpleButton" caption="Go Back" op="Delegate" ' .
    'Delegator="' . $this->{path}. '" Delegated="GoBack" sync="Update();"?>' .
    '</td><td align="right" valign="top" width="50%">' .
    '<?dyn="NotSoSimpleButton" caption="Discard This Extraction" ' .
    'subj="' . $this->{DisplayInfoIn}->{subj} . '" ' .
    'collection="' . $this->{DisplayInfoIn}->{Collection} . '" ' .
    'site="' . $this->{DisplayInfoIn}->{Site} . '" ' .
    'op="DiscardExtraction" sync="Update();"?></td></tr></table>' .
    '<hr>' .
    '<?dyn="UidSubstitutions"?>' .
    '<table width="100%"><tr><td width="20%" valign="top" align="left">' .
    '<?dyn="EditConditions"?>' .
    '</td><td width="40%" valign="top" align="left">' .
    '<?dyn="EditRules"?>' .
    '</td><td width="40%" valign="top" align="left"><small>' .
    '<?dyn="RevisionHistory"?>' .
    '</small></td></tr></table>' .
    '<hr>' .
    '<table width="100%"><tr><td valign="top" align="left" width="50%">' .
    '<?dyn="CurrentEdits"?>' .
    '<?dyn="RenderEditConflicts"?>' .
    '</td><td valign="top" align="left" width="50%">' .
    '<?dyn="ErrorReport"?>' .
    '</td></tr></table>' .
    '<hr>' .
    '<?dyn="StudySeriesImageSelections"?>'
  );
}
sub ErrorReport{
  my($this, $http, $dyn) = @_;
  my $error_info = $this->{DisplayInfoIn}->{error_info};
  my $hierarchy = $this->{DisplayInfoIn}->{hierarchy};
  return $this->ErrorReportCommon($http, $dyn, $error_info, $hierarchy);
}
sub Error{
  my($this, $message) = @_;
  $this->{ErrorMessage} = $message;
  $this->{OldMode} = $this->{Mode};
  $this->{Mode} = "Error";
}
sub ErrorContent{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    "An error occured: $this->{ErrorMessage}<br>" .
    '<?dyn="DelegateButton" op="ClearError" ' .
    'caption="Clear Error" sync="Update();"?>');
}
sub ClearError{
  my($this, $http, $dyn) = @_;
  $this->{Mode} = $this->{OldMode};
  if($this->{Mode} eq "Error") {
    print STDERR "Multiple Errors\n";
    $this->{Mode} = "EnteringEdits";
  }
}
sub InitializeEdit{
  my($this) = @_;
  $this->{NickNames} = $this->parent->{NickNames};
  $this->{Modalities} = {};
  $this->CollectUids($this->{DisplayInfoIn}->{dicom_info});
  my $DicomInfo = {};
  for my $k (keys %{$this->{DisplayInfoIn}->{dicom_info}->{FilesToDigest}}){
    my $dig = $this->{DisplayInfoIn}->{dicom_info}->{FilesToDigest}->{$k};
    my $info = $this->{DisplayInfoIn}->{dicom_info}->{FilesByDigest}->{$dig};
    $DicomInfo->{$k} = $info;
  }
#  $this->{DicomInfo} = $DicomInfo;
  $this->{SortedFiles} = [
    sort {
      return $DicomInfo->{$a}->{patient_id}
        cmp $DicomInfo->{$b}->{patient_id}||
      $DicomInfo->{$a}->{study_uid}
        cmp $DicomInfo->{$b}->{study_uid}||
      $DicomInfo->{$a}->{series_uid}
        cmp $DicomInfo->{$b}->{series_uid}||
      $DicomInfo->{$a}->{norm_x}
        <=> $DicomInfo->{$b}->{norm_x} ||
      $DicomInfo->{$a}->{norm_y}
        <=> $DicomInfo->{$b}->{norm_y} ||
      $DicomInfo->{$a}->{norm_z}
        <=> $DicomInfo->{$b}->{norm_z};
    }
    keys %{$DicomInfo}
  ];
  for my $f (@{$this->{SortedFiles}}){
    my $d_nn =
      $this->{NickNames}->GetDicomNicknamesByFile($f, $DicomInfo->{$f});
    my $f_nn = $d_nn->[0];
    $this->{Nicknames}->{f_nn}->{$d_nn->[0]} = $f;
    $this->{Nicknames}->{r_f_nn}->{$f} = $d_nn->[0];
    my $uid_nn = $d_nn->[1];
    $this->{Nicknames}->{uid_nn}->{$d_nn->[1]} = $f;
    my $st_nn =
      $this->{NickNames}->GetEntityNicknameByEntityId(
        "Study", $DicomInfo->{$f}->{study_uid});
    $this->{Nicknames}->{study_nn}->{$st_nn} = 1;
    my $series_nn =
      $this->{NickNames}->GetEntityNicknameByEntityId(
        "Series", $DicomInfo->{$f}->{series_uid});
    my $modality = $DicomInfo->{$f}->{modality};
    $this->{Nicknames}->{series_nn}->{$series_nn}->{$modality} += 1;
    $this->{Modalities}->{$modality} = 1;
    $this->{Summary}->{$st_nn}->{$series_nn}->{modality}->{$modality} = 1;
    $this->{Summary}->{$st_nn}->{$series_nn}->{uids}->{$uid_nn}->{$f_nn} = 1;
    $this->{FileSummary}->{$st_nn}->{$series_nn}->{$modality}->{$f} = 1;
  }
}
sub GoBack{
  my($this, $http, $dyn) = @_;
  $this->parent->RestoreInfo;
  $this->DeleteSelf;
}
sub UidSubstitutions{
  my($this, $http, $dyn) = @_;
  if($this->{UidSubstitutions}){
    $this->RefreshEngine($http, $dyn,
      '<?dyn="NotSoSimpleButton" caption="Don' ."'" .
      't Change Uids" ' .
      'op="Delegate" ' .
      'Delegator="' . $this->{path} . '" ' .
      'Delegated="ClearUidSubstitutions" ' .
      'sync="Update();"?>' .
      '<br />');
  } else {
    $this->RefreshEngine($http, $dyn,
      '<?dyn="NotSoSimpleButton" caption="Change Uids" ' .
      'op="Delegate" ' .
      'Delegator="' . $this->{path} . '" ' .
      'Delegated="SetUidSubstitutions" ' .
      'sync="Update();"?>' .
      '<br />');
  }
}
sub SetUidSubstitutions{
  my($this, $http, $dyn) = @_;
  $this->{UidSubstitutions} = 1;
  for my $f (keys %{$this->{DisplayInfoIn}->{dicom_info}->{FilesToDigest}}){
    $this->{Edits}->{ChangeUids}->{affected_files}->{$f} = 1;
  }
  my $new_uid_root = Posda::UUID::GetUUID;
  my $seq = 1;
  my %uid_sub;
  for my $uid (keys %{$this->{CollectedUids}}){
    $uid_sub{$uid} = "$new_uid_root.$seq";
    $seq += 1;
  }
  $this->{Edits}->{ChangeUids}->{command} = [
    "uid_substitutions", \%uid_sub
  ];
}
sub ClearUidSubstitutions{
  my($this, $http, $dyn) = @_;
  $this->{UidSubstitutions} = 0;
  delete $this->{Edits}->{ChangeUids};
}
sub EditConditions{
  my($this, $http, $dyn) = @_;
  unless(defined $this->{CondSelector}) { $this->{CondSelector} = 0 }
  $this->RefreshEngine($http, $dyn,
    '<table><tr><th colspan="2">' .
    '<small>Select Condition for Rule:</small></th></tr>');
  for my $cond (0 .. 5){
    $http->queue('<tr><td valign="top">');
    $this->RefreshEngine($http, $dyn,
      $this->RadioButtonDelegate("CondSelector", $cond,
        ($this->{CondSelector} == $cond), {
          op => "ProcessRadioButton",
          sync => "Update();",
        }) . "</td><td><small><?dyn=\"Condition$cond\"?></small></td></tr>\n");
  }
  $http->queue("</table>");
}
sub Condition0{
  my($this, $http, $dyn) = @_;
  $http->queue("No Condition");
}
sub Condition1{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    'If Study Instance UID eq ' .
    '<?dyn="SelectDelegateByValue" op="ConditionSuid" index="1" ' .
    'sync="Update();"?>' .
    '<?dyn="StudyDD" cond="1"?>' .
    '</select>')
}
sub Condition2{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    'If Series Instance UID eq ' .
    '<?dyn="SelectDelegateByValue" op="ConditionSuid" index="2" ' .
    'sync="Update();"?>' .
    '<?dyn="SeriesDD" cond="2"?>' .
    '</select>')
}
sub Condition3{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    'If Modality eq ' .
    '<?dyn="SelectDelegateByValue" op="ConditionSuid" index="3" ' .
    'sync="Update();"?>' .
    '<?dyn="ModalityDD" cond="3"?>' .
    '</select>')
}
sub Condition4{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    'If ' .
    '<?dyn="SelectDelegateByValue" op="SelectElementMatch"' .
    'sync="Update();"?>' .
    '<?dyn="ElementMatchDropDown"?>' .
    '</select>' .
    'eq ' .
    '<?dyn="LinkedDelegateEntryBox" ' .
    'linked="EditParms" index="ElementRuleMatch"?>'
    )
}
sub Condition5{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    'If file is ' .
    '<?dyn="SelectDelegateByValue" op="SelectAFile"' .
    'sync="Update();"?>' .
    '<?dyn="FileDropDown"?>' .
    '</select>'
    )
}
sub ConditionSuid{
  my($this, $http, $dyn) = @_;
  $this->{ConditionSel}->[$dyn->{index}] = $dyn->{value};
}
sub ProcessRadioButton{
  my($this, $http, $dyn) = @_;
  $this->{$dyn->{group}} = $dyn->{value};
}
sub FileDropDown{
  my($this, $http, $dyn) = @_;
  my %files;
  for my $i (keys %{$this->{DisplayInfoIn}->{dicom_info}->{FilesToDigest}}){
    my $dig = $this->{DisplayInfoIn}->{dicom_info}->{FilesToDigest}->{$i};
    my $f_info = $this->{DisplayInfoIn}->{dicom_info}->{FilesByDigest}->{$dig};
    my $f_nns = $this->{NickNames}->GetDicomNicknamesByFile($i, $f_info);
    my $f_nn = $f_nns->[0];
    $files{$f_nn} = 1;
  }
  my @files = sort keys %files;
  unless(
    exists($this->{EditParms}->{SelectedFileForEdit}) &&
    exists($files{$this->{EditParms}->{SelectedFileForEdit}})
  ){
    $this->{EditParms}->{SelectedFileForEdit} = $files[0];
  }
  for my $f_nn (@files){
    $http->queue("<option value=\"$f_nn\"" .
      ($f_nn eq $this->{EditParms}->{SelectedFileForEdit} ?
        " selected" : "") .
      ">$f_nn</option>");
  }
}
sub SelectAFile {
  my($this, $http, $dyn) = @_;
  $this->{EditParms}->{SelectedFileForEdit} = $dyn->{value};
}
sub ElementMatchDropDown{
  my($this, $http, $dyn) = @_;
  my $elements = {
    "(0010,0010)" => "Patient's Name",
    "(0010,0020)" => "Patient's ID",
    "(0010,0030)" => "Patient's Birth Date",
    "(0010,1010)" => "Patient's Age",
    "(0010,1030)" => "Patient's Weight",
    "(0010,0040)" => "Patient's Sex",
    "(0010,2160)" => "Ethnic Group",
    "(0008,0020)" => "Study Date",
    "(0008,0030)" => "Study Time",
    "(0008,0090)" => "Referring Physician's Name",
    "(0020,0010)" => "Study ID",
    "(0008,0050)" => "Accession Number",
    "(0008,1030)" => "Study Description",
    "(0008,0060)" => "Modality",
    "(0020,000d)" => "Study Instance UID",
    "(0020,000e)" => "Series Instance UID",
    "(0020,0011)" => "Series Number",
    "(0020,0060)" => "Laterality",
    "(0008,0021)" => "Series Date",
    "(0008,0031)" => "Series Time",
    "(0018,0015)" => "Body Part Examined",
    "(0018,1030)" => "Protocol Name",
    "(0008,103e)" => "Series Description",
    "(0018,5100)" => "Patient Position",
    "(0008,0070)" => "Manufacturer",
    "(0008,0080)" => "Institution Name",
    "(0008,0081)" => "Institution Address",
    "(0008,1090)" => "Manufacturer's Model Name",
    "(0018,1020)" => "Software Version",
    "(0008,1080)" => "Admitting Diagnosis Description",
    "(0008,1010)" => "Station Name",
    "(0018,1000)" => "Device Serial Number",
    "(0020,0200)" => "Synchronization Frame of Reference UID",
  };
  unless($this->{EditParms}->{SelectedEleMatch}) {
    $this->{EditParms}->{SelectedEleMatch} = [sort keys %$elements]->[0];
  }
  for my $i (sort keys %{$elements}){
    $http->queue("<option value=\"$i\"" .
    ($i eq $this->{EditParms}->{SelectedEleMatch} ? "selected" : "" ) .
    ">$i $elements->{$i}</option>");
  }
}
sub SelectElementMatch{
  my($this, $http, $dyn) = @_;
  $this->{EditParms}->{SelectedEleMatch} = $dyn->{value};
}

sub EditRules{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    '<small><table><tr><td valign="top">' .
    ## For all existing (drop down), set to ...
    '<?dyn="DelegateButton" op="AddRule" ' .
    'rule_type="ShortReplaceEle" caption="Add Rule" '.
    'sync="Update();"?></td><td>' .
    'For all existing ' .
    '<?dyn="SelectDelegateByValue" op="SelectedElement" ' .
    'index="ShortReplaceEle" sync="Update"?>' .
    '<?dyn="EleDropDown" rule="ShortReplaceEle"?></select> ' .
    'elements ' .
    ', set to <?dyn="LinkedDelegateEntryBox" ' .
    'linked="EditParms" index="ShortReplaceValue"?></td></tr>' .
    ## For all existing, (entry) set to
    '<tr><td valign="top"><?dyn="DelegateButton" op="AddRule" ' .
    'rule_type="ShortReplaceEle1" caption="Add Rule" ' .
    'sync="Update();"?></td><td>' .
    'For all existing ' .
    '<?dyn="LinkedDelegateEntryBox" linked="EditParms" ' .
    'index="ShortReplaceEle1"?> ' .
    'elements ' .
    ', set to <?dyn="LinkedDelegateEntryBox" ' .
    'linked="EditParms" index="ShortReplaceValue1"?></td></tr>' .
    ## Delete element leafs
    '<tr><td valign="top"><?dyn="DelegateButton" op="AddRule" ' .
    'rule_type="DeleteLeafElement" caption="Add Rule" ' .
    'sync="Update();"?></td><td>' .
    'Delete all element leaves ' .
    '<?dyn="LinkedDelegateEntryBox" linked="EditParms" ' .
    'index="ElementLeafValue"?></td></tr>' .
    ## Delete full element
    '<tr><td valign="top"><?dyn="DelegateButton" op="AddRule" ' .
    'rule_type="DeleteElement" caption="Add Rule" ' .
    'sync="Update();"?></td><td>' .
    'Delete the element ' .
    '<?dyn="LinkedDelegateEntryBox" ' .
    'linked="EditParms" index="FullDeleteEle"?></td></tr>' .
    ## Insert full element
    '<tr><td valign="top"><?dyn="DelegateButton" op="AddRule" ' .
    'rule_type="InsertElement" caption="Add Rule" ' .
    'sync="Update();"?></td><td>' .
    'Insert the element ' .
    '<?dyn="LinkedDelegateEntryBox" linked="EditParms" ' .
    'index="InsertElement"?> ' .
    'with value ' .
    '<?dyn="LinkedDelegateEntryBox" linked="EditParms" ' .
    'index="InsertElementValue"?></td></tr>' .
    ## Hash unhashed UIDs
    '<tr><td valign="top"><?dyn="DelegateButton" op="AddRule" ' .
    'rule_type="HashUid" caption="Add Rule" ' .
    'sync="Update();"?></td><td>' .
    'For all existing ' .
    '<?dyn="LinkedDelegateEntryBox" linked="EditParms" index="UidElements"?> ' .
    'elements, hash unhashed UIDs using base ' .
    '<?dyn="LinkedDelegateEntryBox" linked="EditParms" ' .
    'index="UidBase" length="30"?> ' .
    "</td></tr>" .
    ## Split series based on element
    '<tr><td valign="top"><?dyn="DelegateButton" op="AddRule" ' .
    'rule_type="SplitSeries" caption="Add Rules" ' .
    'sync="Update();"?></td><td>' .
    'Split Series based on element ' .
    '<?dyn="LinkedDelegateEntryBox" linked="EditParms" index="SplitEle" ' .
    'length="30"?></td></tr></table>' .
    '</small>'
  );
}
sub SelectedElement{
  my($this, $http, $dyn) = @_;
  $this->{EditParms}->{$dyn->{index}} = $dyn->{value};
}
sub EleDropDown{
  my($this, $http, $dyn) = @_;
  my $elements = {
    "(0010,0010)" => "Patient Name",
    "(0010,0020)" => "Patient Id",
    "(0010,0021)" => "Issuer of Patient Id",
    "(0010,0030)" => "Patient's Birth Date",
    "(0010,0040)" => "Patient's Sex",
    "(0020,000d)" => "Study UID",
    "(0020,0010)" => "Study Id",
    "(0008,1030)" => "Study Description",
    "(0008,0020)" => "Study Date",
    "(0020,0011)" => "Series Number",
    "(0008,103e)" => "Series Description",
    "(0008,0021)" => "Series Date",
    "(0020,0052)" => "Frame of Reference",
  };
  unless($this->{EditParms}->{$dyn->{rule}}) {
    $this->{EditParms}->{$dyn->{rule}} = "(0010,0010)";
  }
  for my $i (sort keys %{$elements}){
    $http->queue("<option value=\"$i\"" .
    ($i eq $this->{EditParms}->{$dyn->{rule}} ? "selected" : "" ) .
    ">$i $elements->{$i}</option>");
  }
}
sub ModalityDD{
  my($this, $http, $dyn) = @_;
  my @modalities = sort keys %{$this->{Modalities}};
  unless(defined $this->{ConditionSel}->[$dyn->{cond}]){
    $this->{ConditionSel}->[$dyn->{cond}] = $modalities[0];
  }
  for my $modality (sort @modalities){
    $http->queue("<option value=\"$modality\"");
    if($modality eq $this->{ConditionSel}->[$dyn->{cond}]) {
      $http->queue(" selected")
    }
    $http->queue(">$modality</option>");
  }
}
sub StudyDD{
  my($this, $http, $dyn) = @_;
  my @study_nn = sort keys %{$this->{Nicknames}->{study_nn}};
  unless(defined $this->{ConditionSel}->[$dyn->{cond}]){
    $this->{ConditionSel}->[$dyn->{cond}] = $study_nn[0];
  }
  for my $study (sort @study_nn){
    $http->queue("<option value=\"$study\"");
    if($study eq $this->{ConditionSel}->[$dyn->{cond}]) {
      $http->queue(" selected")
    }
    $http->queue(">$study</option>");
  }
}
sub SeriesDD{
  my($this, $http, $dyn) = @_;
  my @series_nn = sort keys %{$this->{Nicknames}->{series_nn}};
  unless(defined $this->{ConditionSel}->[$dyn->{cond}]){
    $this->{ConditionSel}->[$dyn->{cond}] = $series_nn[0];
  }
  for my $series (sort @series_nn){
    $http->queue("<option value=\"$series\"");
    if($series eq $this->{ConditionSel}->[$dyn->{cond}]) {
      $http->queue(" selected")
    }
    $http->queue(">$series</option>");
  }
}
sub AddRule{
  my($this, $http, $dyn) = @_;
  my $condition;
  my $cond_type = $this->{CondSelector};
  if($cond_type < 4) {
    $condition = 
    [$this->{CondSelector}, $this->{ConditionSel}->[$this->{CondSelector}]];
  } elsif($cond_type == 4) {
    $condition = [4, $this->{EditParms}->{SelectedEleMatch},
       $this->{EditParms}->{ElementRuleMatch}];
  } elsif($cond_type == 5) {
    #  stuff for sop_instance check here
    $condition = [5, $this->{EditParms}->{SelectedFileForEdit}, undef ];
  } else {
    print STDERR "Unknown Condition type: $cond_type\n";
    return;
  }
  my $rule_type = $dyn->{rule_type};
  my $rule = {
    condition => $condition,
  };
  if($rule_type eq "ShortReplaceEle"){
    $rule->{rule_type} = "Replace Existing Element Value (Short)",
    $rule->{rule_code} = "ShortEle";
    $rule->{ShortEle} = $this->{EditParms}->{ShortReplaceEle};
    $rule->{Value} = $this->{EditParms}->{ShortReplaceValue};
  } elsif($rule_type eq "DeleteLeafElement"){
    $rule->{rule_type} = "Delete Element Leaf",
    $rule->{rule_code} = "ShortEle";
    $rule->{ShortEle} = $this->{EditParms}->{ElementLeafValue};
  } elsif($rule_type eq "ShortReplaceEle1"){
    $rule->{rule_type} = "Replace Existing Element Value (Short)",
    $rule->{rule_code} = "ShortEle";
    $rule->{ShortEle} = $this->{EditParms}->{ShortReplaceEle1};
    $rule->{Value} = $this->{EditParms}->{ShortReplaceValue};
  } elsif($rule_type eq "DeleteElement"){
    $rule->{rule_type} = "Delete Existing Element (Full)",
    $rule->{FullEle} = $this->{EditParms}->{FullDeleteEle};
    $rule->{rule_code} = "FullEle";
  } elsif($rule_type eq "InsertElement"){
    $rule->{rule_type} = "Insert/Overwrite Element (Full)",
    $rule->{rule_code} = "FullEle";
    $rule->{FullEle} = $this->{EditParms}->{InsertElement};
    $rule->{Value} = $this->{EditParms}->{InsertElementValue};
  } elsif($rule_type eq "HashUid"){
    $rule->{rule_type} = "Hash UIDs in Element (Short)",
    $rule->{rule_code} = "ShortEle";
    $rule->{ShortEle} = $this->{EditParms}->{UidElements};
    $rule->{Value} = $this->{EditParms}->{UidBase};
  } elsif($rule_type eq "SplitSeries"){
    unless($condition->[0] == 2){
      return $this->Error("Must select a \"Series Instance UID eq\" to Split");
    }
    $rule->{rule_code} = "SeriesUid";
    $rule->{rule_type} = "Split Series Based on Element (Full)",
    $rule->{FullEle} = $this->{EditParms}->{SplitEle}
  }
  push @{$this->{Edits}->{Rules}}, $rule;
}
sub RecalcEdits{
  my($this) = @_;
  my %AffectedFiles;
  for my $i (0 .. $#{$this->{Edits}->{Rules}}){
    my $rule = $this->{Edits}->{Rules}->[$i];
    $rule->{index} = $i;
    if($rule->{condition}->[0]){
      my @affected_files;
      if($rule->{condition}->[0] eq "1"){
        @affected_files = $this->GetStudyFiles($rule->{condition}->[1]);
      } elsif($rule->{condition}->[0] eq "2"){
        @affected_files = $this->GetSeriesFiles($rule->{condition}->[1]);
      } elsif($rule->{condition}->[0] eq "3"){
        @affected_files = $this->GetModalityFiles($rule->{condition}->[1]);
      } elsif($rule->{condition}->[0] eq "4"){
        @affected_files = $this->GetEleMatchingFiles($rule->{condition}->[1],
          $rule->{condition}->[2]);
      } elsif($rule->{condition}->[0] eq "5"){
        @affected_files = $this->GetMatchingFile($rule->{condition}->[1]);
      }
      $rule->{affected_files} = \@affected_files;
      for my $f (@affected_files){
        $AffectedFiles{$f} = 1;
      }
    } else {
      $rule->{affected_files} = $this->{SortedFiles};
      for my $f (@{$this->{SortedFiles}}){
        $AffectedFiles{$f} = 1;
      }
    }
  }
  if(exists $this->{Edits}->{ChangeUids}){
    for my $f (keys %{$this->{Edits}->{ChangeUids}->{affected_files}}){
      $AffectedFiles{$f} = 1;
    }
  }
  my %UnaffectedFiles;
  for my $f (@{$this->{SortedFiles}}){
    unless(exists $AffectedFiles{$f}){
      $UnaffectedFiles{$f} = 1;
    }
  }
  my $num_affected_files = keys %AffectedFiles;
  my $num_unaffected_files = keys %UnaffectedFiles;
  $this->{Edits}->{NumAffectedFiles} = $num_affected_files;
  $this->{Edits}->{NumUnaffectedFiles} = $num_unaffected_files;
  $this->{Edits}->{AffectedFiles} = \%AffectedFiles;
  $this->{Edits}->{UnaffectedFiles} = \%UnaffectedFiles;
  $this->EditConflicts;
}
sub EditConflicts{
  my($this) = @_;
  my @conflicts;
  my %bad_rule;
  my %files_edited;
  rule:
  for my $rn (0 .. $#{$this->{Edits}->{Rules}}){
    my $rule_desc = $this->{Edits}->{Rules}->[$rn];
    if($rule_desc->{rule_code} eq "ShortEle"){
      for my $f (@{$rule_desc->{affected_files}}){
        $files_edited{$f}->{$rule_desc->{ShortEle}}->{$rn} = 1;
      }
    } elsif($rule_desc->{rule_code} eq "FullEle"){
      my $ele = $rule_desc->{FullEle};
      my $short_ele;
      if($ele =~ /\(([0-9a-fA-F]{4}),([0-9a-fA-F]{4})\)$/){
        $short_ele = "($1,$2)";
      } elsif (
        $ele =~  /\(([0-9a-fA-F]{4}),\"([^\"]*)\",([0-9a-fA-F]{2})\)$/
      ){
        $short_ele = "($1,\"$2\",$3)";
      }
      unless(defined $short_ele) {
        $bad_rule{$rn} = "can't get leaf for $ele";
        next rule;
      }
      for my $f (@{$rule_desc->{affected_files}}){
        $files_edited{$f}->{$short_ele}->{$rn} = 1;
      }
    }
  }
  my %conflicts;
  $this->{files_edited} = \%files_edited;
  for my $f (keys %files_edited){
    for my $e (keys %{$files_edited{$f}}){
      my @rules = keys %{$files_edited{$f}->{$e}};
      if(@rules > 1){
        my $msg = "Rules:";
        for my $i (0 .. $#rules) {
          $msg .= " $rules[$i]";
          unless($i == $#rules)  { $msg .= "," }
        }
        $conflicts{$msg}->{$e}->{$f} = 1;
      }
    }
  }
  $this->{rule_conflicts} = \%conflicts;
}
sub RenderEditConflicts{
  my($this, $http, $dyn) = @_;
  unless(exists $this->{rule_conflicts}) { return }
  my @conflicts = keys %{$this->{rule_conflicts}};
  unless(@conflicts > 0) { return }
  $http->queue("<hr><small>Possible conflicting rules:<ul>");
  for my $c (@conflicts){
    $http->queue("<li>$c<ul>");
    for my $ele (keys %{$this->{rule_conflicts}->{$c}}){
      my $n_files = keys %{$this->{rule_conflicts}->{$c}->{$ele}};
      $http->queue("<li>$ele - $n_files files</li>");
    }
    $http->queue("</ul></li>");
  }
  $http->queue("</ul></small>");
}
sub GetStudyFiles{
  my($this, $study) = @_;
  my @list;
  if(exists $this->{FileSummary}->{$study}){
    for my $s (keys %{$this->{FileSummary}->{$study}}){
      for my $m (keys %{$this->{FileSummary}->{$study}->{$s}}){
        for my $f (keys %{$this->{FileSummary}->{$study}->{$s}->{$m}}){
          push @list, $f;
        }
      }
    }
  }
  return @list;
}
sub GetSeriesFiles{
  my($this, $series) = @_;
  my @list;
  for my $st (keys %{$this->{FileSummary}}){
    for my $se (keys %{$this->{FileSummary}->{$st}}){
      if($se eq $series){
        for my $m (keys %{$this->{FileSummary}->{$st}->{$se}}){
          for my $f (keys %{$this->{FileSummary}->{$st}->{$se}->{$m}}){
            push @list, $f;
          }
        }
      }
    }
  }
  return @list;
}
sub GetModalityFiles{
  my($this, $modality) = @_;
  my @list;
  for my $st (keys %{$this->{FileSummary}}){
    for my $se (keys %{$this->{FileSummary}->{$st}}){
      for my $m (keys %{$this->{FileSummary}->{$st}->{$se}}){
        if($m eq $modality){
          for my $f (keys %{$this->{FileSummary}->{$st}->{$se}->{$m}}){
            push @list, $f;
          }
        }
      }
    }
  }
  return @list;
}
sub GetEleMatchingFiles{
  my($this, $ele, $value) = @_;
  my $dicom_info = $this->{DisplayInfoIn}->{dicom_info};
  my @list;
  for my $st (keys %{$this->{FileSummary}}){
    for my $se (keys %{$this->{FileSummary}->{$st}}){
      for my $m (keys %{$this->{FileSummary}->{$st}->{$se}}){
        for my $f (keys %{$this->{FileSummary}->{$st}->{$se}->{$m}}){
          my $dig = $dicom_info->{FilesToDigest}->{$f};
          my $f_info = $dicom_info->{FilesByDigest}->{$dig};
          if(exists($f_info->{$ele}) && $f_info->{$ele} eq $value){
            push @list, $f;
          }
        }
      }
    }
  }
  return @list;
}
sub GetMatchingFile{
  my($this, $f_nn) = @_;
  my $files = $this->{NickNames}->GetFilesByFileNickname($f_nn);
  return @$files;
}
sub CurrentEdits{
  my($this, $http, $dyn) = @_;
  $this->RecalcEdits;
  my $num_edits = 0;
  if(exists $this->{Edits}->{ChangeUids}){
    $num_edits = 1;
  }
  $num_edits += @{$this->{Edits}->{Rules}};
  unless($num_edits){
    $this->RefreshEngine($http, $dyn,
      "No edits selected<br>");
    my $to_copy = $this->{Edits}->{NumUnaffectedFiles};
    $http->queue("$to_copy files unaffected by edits<br />");
    return;
  }
  my $to_copy = $this->{Edits}->{NumUnaffectedFiles};
  $http->queue("<small>$to_copy files unaffected by edits<br /></small>");
  $http->queue("Edits:" .
    (exists( $this->{Edits}->{ChangeUids}) ? 
      "(All UIDs in all files changed)" : "") .
    "<br><table border><tr><th>Rule #</th><th>Condition</th>" .
    "<th>Op</th><th>Element</th><th>Value</th><th>Files Affected</th></tr>");
    my @rules = @{$this->{Edits}->{Rules}};
    for my $rule (@{$this->{Edits}->{Rules}}){
       $this->EditRow($http, $dyn, $rule)
     };
    $http->queue("</table>");
  $this->RefreshEngine($http, $dyn,
    '<?dyn="DelegateButton" op="ApplyEdits" ' .
    'caption="Apply Edits" sync="Update();"?>');
}
sub DeleteEdit{
  my($this, $http, $dyn) = @_;
  splice @{$this->{Edits}->{Rules}}, $dyn->{index}, 1;
  $this->EditConflicts;
}
sub EditRow{
  my($this, $http, $dyn, $i) = @_;
  my $files_affected = "Error - not an array";
  if(exists $i->{affected_files}  && ref($i->{affected_files}) eq "ARRAY"){
    $files_affected = @{$i->{affected_files}};
  }
  my $index = $i->{index};
  my $condition = "none";
  if($i->{condition}->[0] == 1){
    $condition = "Study = $i->{condition}->[1]";
  }elsif($i->{condition}->[0] == 2){
    $condition = "Series = $i->{condition}->[1]";
  }elsif($i->{condition}->[0] == 3){
    $condition = "Modality = $i->{condition}->[1]";
  }elsif($i->{condition}->[0] == 4){
    $condition = "$i->{condition}->[1] eq $i->{condition}->[2]";
  }elsif($i->{condition}->[0] == 5){
    $condition = "file = $i->{condition}->[1]";
  }
  $http->queue("<tr><td><small>$index</small></td><td><small>" .
    "$condition</small></td><td><small>" .
    "$i->{rule_type}</small></td>" .
    "<td><small>");
  if(exists $i->{ShortEle}) {
    $http->queue($i->{ShortEle});
  } elsif(exists $i->{FullEle}){
    $http->queue($i->{FullEle});
  } else { $http->queue("--")}
  $http->queue("</small></td><td><small>");
  if(exists $i->{Value}){
    $http->queue($i->{Value});
  } else { $http->queue("--")}
  $this->RefreshEngine($http, $dyn,
    "</small></td><td><small>$files_affected</small></td><td><small>" .
    '<?dyn="DelegateButton" op="DeleteEdit" caption="del" index="' . $index .
    '" sync="Update();"?></small></td></tr>'
  );
}
sub StudySeriesImageSelections{
  my($this, $http, $dyn) = @_;
  $http->queue("<small>");
  $this->ExpandStudyHierarchyWithPatientInfo($http, $dyn, 
    $this->{DisplayInfoIn}->{hierarchy}->{studies});
  $http->queue("</small>");
}
sub ApplyEdits{
  my($this, $http, $dyn) = @_;
  $this->{Edits}->{Site} = $this->{DisplayInfoIn}->{Site};
  $this->{Edits}->{subj} = $this->{DisplayInfoIn}->{subj};
  $this->{Edits}->{Collection} = $this->{DisplayInfoIn}->{Collection};
  $this->{Edits}->{dicom_info} = $this->{DisplayInfoIn}->{dicom_info};
  $this->RouteAbove("ApplyGeneralEdits", $http, $dyn, $this->{Edits});
  $this->DeleteSelf;
}
1;
