#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/FileDist/include/FileDist/DicomEdit.pm,v $
#$Date: 2014/12/19 21:38:53 $
#$Revision: 1.13 $
#
use strict;
use Posda::HttpApp::GenericIframe;
use Posda::HttpApp::DicomNicknames;
use Posda::UUID;
use FileDist::DirectorySelector;
use FileDist::EditDestinationCreator;
use FileDist::UidCollector;
use FileDist::ShowStudy;
use FileDist::ShowSeries;
use FileDist::DirectorySummarizer;
use Debug;
my $dbg = sub {print STDERR @_ };
package FileDist::DicomEdit;
use Storable qw( store_fd fd_retrieve store );
$Storable::interwork_56_64bit = 1;
use File::Path qw(remove_tree);
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericIframe", "FileDist::UidCollector",
  "FileDist::DirectorySummarizer" );
sub new{
  my($class, $sess, $path) = @_;
  my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
  bless $this, $class;
  $this->{RoutesBelow}->{GetDicomNicknamesByFile} = 1;
  $this->{RoutesBelow}->{GetFilesByFileNickname} = 1;
  $this->{RoutesBelow}->{GetFilesByUidNickname} = 1;
  $this->{RoutesBelow}->{GetEntityNicknameByEntityId} = 1;
  $this->{RoutesBelow}->{GetEntityIdByNickname} = 1;
  $this->{ImportsFromAbove}->{GetDicomNicknamesByFile} = 1;
  $this->{ImportsFromAbove}->{GetFilesByFileNickname} = 1;
  $this->{ImportsFromAbove}->{GetFilesByUidNickname} = 1;
  $this->{ImportsFromAbove}->{GetEntityNicknameByEntityId} = 1;
  $this->{ImportsFromAbove}->{GetEntityIdByNickname} = 1;
  $this->{State} = "Uninitialized";
  $this->{RuleIndex} = 0;
  $this->{compare_seq} = 0;
  return $this;
}
my $unknown_state = <<EOF;
Unknown state: <?dyn="State"?><br />
<?dyn="Button" op="Reset" caption="Reset"?>
EOF
my $uninit_state = <<EOF;
<h3>Dicom Edit</h3>
<?dyn="Button" op="ChooseFromDirectory" caption="Choose From Directory"?><br />
EOF
my $initializing_from = <<EOF;
<h3>Dicom Edit</h3>
<small>Initializing from directory (<?dyn="From"?>):</small><hr />
<?dyn="FromInitStatus"?>
EOF
my $from_only = <<EOF;
<h3>Dicom Edit</h3>
<small>From directory: <?dyn="From"?>&nbsp;
<?dyn="Button" op="AbandonEdits" caption="Clear"?><br />
<?dyn="Button" op="CreateDestination" caption="Create Destination"?><br />
</small>
EOF
my $edit = <<EOF;
<h3>Dicom Edit</h3>
<small>From directory: <?dyn="From"?><br />
Destination directory: <?dyn="DestinationDir"?>&nbsp;
<?dyn="Button" op="AbandonEdits" caption="Abandon Edits"?><br />
</small>
<hr>
<?dyn="UidSubstitutions"?>
<?dyn="EditConditions"?>
<?dyn="EditRules"?>
<hr>
<?dyn="CurrentEdits"?>
<hr>
<?dyn="StudySeriesImageSelections"?>
EOF
my $edit_error = <<EOF;
Error: <?dyn="EditError"?> 
<?dyn="Button" op="ClearEditError" caption="Clear"?>
EOF
#<?dyn="Button" op="ClearFrom" caption="Clear"?><br />
my $edits_analyzed = <<EOF;
<h3>Dicom Edit</h3>
<small>From directory: <?dyn="From"?><br />
Destination directory: <?dyn="DestinationDir"?>&nbsp;
</small><hr>
<?dyn="EditAnalysisSummary"?>
EOF
my $performing_edit = <<EOF;
<h3>Dicom Edit</h3>
<small>From directory: <?dyn="From"?><br />
Destination directory: <?dyn="DestinationDir"?>&nbsp;
</small><hr>
<?dyn="PerformingEdits"?>
EOF
my $editing_committed = <<EOF;
<h3>Dicom Edit</h3>
<small>From directory: <?dyn="From"?><br />
Destination directory: <?dyn="DestinationDir"?>&nbsp;
</small><hr>
<?dyn="EditingCommitted"?>
EOF
sub Content{
  my($this, $http, $dyn) = @_;
  if($this->{State} eq "Uninitialized"){
    return $this->RefreshEngine($http, $dyn, $uninit_state);
  } elsif($this->{State} eq "InitializingFrom"){
    return $this->RefreshEngine($http, $dyn, $initializing_from);
  } elsif($this->{State} eq "FromOnly"){
    return $this->RefreshEngine($http, $dyn, $from_only);
  } elsif($this->{State} eq "Edit"){
    return $this->RefreshEngine($http, $dyn, $edit);
  } elsif($this->{State} eq "EditError"){
    return $this->RefreshEngine($http, $dyn, $edit_error);
  } elsif($this->{State} eq "EditsAnalyzed"){
    return $this->RefreshEngine($http, $dyn, $edits_analyzed);
  } elsif($this->{State} eq "PerformingEdits"){
    $this->RefreshEngine($http, $dyn, $performing_edit);
  } elsif($this->{State} eq "EditingCommitted"){
    $this->RefreshEngine($http, $dyn, $editing_committed);
  } else {
    $this->RefreshEngine($http, $dyn, $unknown_state);
  }
}
sub Reset{
  my($this, $http, $dyn) = @_;
  if($this->{State} eq "Creating Destination"){
    my $child_name = $this->child_path("DestinationCreator");
    my $child_obj = $this->get_obj($child_name);
    if($child_obj){
      my $content_child_name = $child_obj->child_path("Content");
      my $c_child = $this->get_obj($content_child_name);
      if($c_child) { $c_child->CloseWindow }
    }
  }
  $this->InvokeAfterDelay("ClearJunk", 1);
}
sub AbandonEdits{
  my($this) = @_;
  if($this->{DestinationDescriptor}){
    print STDERR "remove_tree: $this->{DestinationDescriptor}->{directory}\n";
    remove_tree($this->{DestinationDescriptor}->{directory});
    delete $this->{DestinationDescriptor};
  }
  $this->ClearJunk;
}
sub ClearJunk{
  my($this) = @_;
  if($this->{FromAnalyzer}) {
    $this->{FromAnalyzer}->Abort;
  }
  delete $this->{FromAnalyzer};
  delete $this->{FromDirectory};
  delete $this->{From};
  delete $this->{CollectedUids};
  delete $this->{DicomInfo};
  delete $this->{Edits};
  delete $this->{FilesAffectedByEdits};
  delete $this->{FilesToLink};
  delete $this->{Modalities};
  delete $this->{Nicknames};
  delete $this->{SortedFiles};
  delete $this->{Summary};
  delete $this->{CommitErrors};
  delete $this->{EditApplyResults};
  $this->{RuleIndex} = 0;
  delete $this->{FileEditWarnings};
  delete $this->{FileEdits};
  delete $this->{CommitErrors};
  delete $this->{EditApplyResults};
  delete $this->{EditApplyErrors};
  delete $this->{DestinationDescriptor};
  $this->{State} = "Uninitialized";
  $this->AutoRefresh;
}
sub AutoRefresh{
  my($this) = @_;
  $this->parent->AutoRefresh;
}
sub State{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{State});
}
sub From{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{FromDirectory});
}
sub DestinationDir{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{DestinationDescriptor}->{directory});
}
sub ClearFrom{
  my($this, $http, $dyn) = @_;
  delete $this->{FromDirectory};
  delete $this->{FromAnalyzer};
  if(exists $this->{ToDirectory}){
    $this->{State} = "ToOnly";
  } else {
    $this->{State} = "Uninitialized";
  }
  $this->AutoRefresh;
}
sub ChooseFromDirectory{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("DirectorySelector");
  my $sel_obj = $this->child($child_name);
  if($sel_obj) {
    print STDERR "??? DirectorySelector already exists ???";
  } else {
    $sel_obj = FileDist::DirectorySelector->new($this->{session},
      $child_name, $this->FromCallback);
  }
  $sel_obj->ReOpenFile;
}
sub FromCallback{
  my($this) = @_;
  my $sub = sub {
    my($dir) = @_;
    $this->{FromDirectory} = $dir;
    if(exists $this->{FromAnalyzer}){
      die "FromAnalyzer already exists";
    }
    $this->{FromAnalyzer} = 
      FileDist::DirectoryAnalyzer->new($dir, 
        $this->get_obj("FileManager"),
        $this->AnalyzeComplete("From"));
    $this->{State} = "InitializingFrom";
    $this->AutoRefresh;
  };
  return $sub;
}
sub AnalyzeComplete{
  my($this, $type) = @_;
  my $sub = sub {
    unless($this->{State} eq "InitializingFrom") {
      die "Analysis of From complete in state $this->{State}";
    }
    $this->{State} = "FromOnly";
    $this->AutoRefresh;
  };
  return $sub;
}
sub FromInitStatus{
  my($this, $http, $dyn) = @_;
  my $da = $this->{FromAnalyzer};
  $http->queue("<small>Analyzing Dicom files in From directory (" .
    "$this->{FromDirectory}):<br />");
  if($da->InitializingState($http, $dyn)){
    $this->RefreshAfter(1);
  }
}
sub CreateDestination{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("DestinationCreator");
  my $sel_obj = $this->child($child_name);
  if($sel_obj) {
    print STDERR "??? DestinationCreator already exists ???";
  } else {
    $sel_obj = FileDist::EditDestinationCreator->new($this->{session},
      $child_name, $this->CreateCallback, $this->{FromDirectory});
  }
  $this->{State} = "Creating Destination";
  $sel_obj->ReOpenFile;
  $this->AutoRefresh;
}
sub CreateCallback{
  my($this) = @_;
  my $sub = sub {
    my($dest_descriptor) = @_;
    $this->{DestinationDescriptor} = $dest_descriptor;
    $this->{State} = "Edit";
    $this->InitializeEdit;
    $this->AutoRefresh;
  };
  return $sub;
}
sub InitializeEdit{
  my($this) = @_;
  my $child_name = $this->child_path("Nicknames");
  Posda::HttpApp::DicomNicknames->new($this->{session}, $child_name);
  $this->{Nicknames} = {};
  $this->{Modalities} = {};
  $this->CollectUids($this->{FromAnalyzer}->{DirectoryManager}->{Processed});
  $this->{SortedFiles} = [
    sort {
      return $this->{DicomInfo}->{$a}->{patient_id} 
        cmp $this->{DicomInfo}->{$b}->{patient_id}||
      $this->{DicomInfo}->{$a}->{study_uid} 
        cmp $this->{DicomInfo}->{$b}->{study_uid}||
      $this->{DicomInfo}->{$a}->{series_uid} 
        cmp $this->{DicomInfo}->{$b}->{series_uid}||
      $this->{DicomInfo}->{$a}->{norm_x} 
        <=> $this->{DicomInfo}->{$b}->{norm_x} ||
      $this->{DicomInfo}->{$a}->{norm_y} 
        <=> $this->{DicomInfo}->{$b}->{norm_y} ||
      $this->{DicomInfo}->{$a}->{norm_z} 
        <=> $this->{DicomInfo}->{$b}->{norm_z};
    }
    keys %{$this->{DicomInfo}}
  ];
  for my $f (@{$this->{SortedFiles}}){
    my $d_nn = 
      $this->FetchFromAbove("GetDicomNicknamesByFile", $f);
    my $f_nn = $d_nn->[0];
    $this->{Nicknames}->{f_nn}->{$d_nn->[0]} = 1;
    my $uid_nn = $d_nn->[1];
    $this->{Nicknames}->{uid_nn}->{$d_nn->[1]} = 1;
    my $st_nn = 
      $this->FetchFromAbove("GetEntityNicknameByEntityId",
        "Study", $this->{DicomInfo}->{$f}->{study_uid});
    $this->{Nicknames}->{study_nn}->{$st_nn} = 1;
    my $series_nn = 
      $this->FetchFromAbove("GetEntityNicknameByEntityId",
        "Series", $this->{DicomInfo}->{$f}->{series_uid});
    my $modality = $this->{DicomInfo}->{$f}->{modality};
    $this->{Nicknames}->{series_nn}->{$series_nn}->{$modality} += 1;
    $this->{Modalities}->{$modality} = 1;
    $this->{Summary}->{$st_nn}->{$series_nn}->{modality}->{$modality} = 1;
    $this->{Summary}->{$st_nn}->{$series_nn}->{uids}->{$uid_nn}->{$f_nn} = 1;
  }
}
sub UidSubstitutions{
  my($this, $http, $dyn) = @_;
  if($this->{UidSubstitutions}){
    $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" caption="Don' ."'" .
      't Change Uids" op="ClearUidSubstitutions"?><br />');
  } else {
    $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" caption="Change Uids" op="SetUidSubstitutions"?><br />');
  }
}
sub SetUidSubstitutions{
  my($this, $http, $dyn) = @_;
  $this->{UidSubstitutions} = 1;
  for my $f (keys %{$this->{DicomInfo}}){
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
  $this->AutoRefresh;
}
sub ClearUidSubstitutions{
  my($this, $http, $dyn) = @_;
  $this->{UidSubstitutions} = 0;
  delete $this->{Edits}->{ChangeUids};
  $this->AutoRefresh;
}
sub RecalcEdits{
  my($this) = @_;
  $this->{FilesAffectedByEdits} = {};
  for my $f (keys %{$this->{DicomInfo}}){
    for my $e (keys %{$this->{Edits}}){
      if(exists $this->{Edits}->{$e}->{affected_files}->{$f}){
        $this->{FilesAffectedByEdits}->{$f} = 1;
      }
    }
  }
  $this->{FilesToLink} = {};
  for my $f (keys %{$this->{DicomInfo}}){
    unless(exists $this->{FilesAffectedByEdits}->{$f}){
      $this->{FilesToLink}->{$f} = 1;
    }
  }
}
sub EditConditions{
  my($this, $http, $dyn) = @_;
  unless(defined $this->{CondSelector}) { $this->{CondSelector} = 0 }
  $this->RefreshEngine($http, $dyn, 
    '<small>Select Condition for Rule:<br />' . "\n" .
    '<?dyn="RadioNotify" group="CondSelector" value="0"' .
    ' Op="ProcessRadioButton"?> No Condition<br />' . "\n" .
    '<?dyn="RadioNotify" group="CondSelector" value="1"' .
    ' Op="ProcessRadioButton"?> <?dyn="Condition1"?><br />' . "\n" .
    '<?dyn="RadioNotify" group="CondSelector" value="2"' .
    ' Op="ProcessRadioButton"?> <?dyn="Condition2"?><br />' . "\n" .
    '<?dyn="RadioNotify" group="CondSelector" value="3"' .
    ' Op="ProcessRadioButton"?> <?dyn="Condition3"?><br />' . "\n" .
    '</small>'
  );
}
sub Condition1{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    'If Study Instance UID eq ' .
    '<?dyn="SelectNsByValue" op="ConditionSuid" index="1"?>' .
    '<?dyn="StudyDD" cond="1"?>' .
    '</select>')
}
sub Condition2{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    'If Series Instance UID eq ' .
    '<?dyn="SelectNsByValue" op="ConditionSuid" index="2"?>' .
    '<?dyn="SeriesDD" cond="2"?>' .
    '</select>')
}
sub Condition3{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    'If Modality eq ' .
    '<?dyn="SelectNsByValue" op="ConditionSuid" index="3"?>' .
    '<?dyn="ModalityDD" cond="3"?>' .
    '</select>')
}
#sub Condition4{
#  my($this, $http, $dyn) = @_;
#}
sub ConditionSuid{
  my($this, $http, $dyn) = @_;
  $this->{ConditionSel}->[$dyn->{index}] = $dyn->{value};
}
sub ProcessRadioButton{
  my($this, $http, $dyn) = @_;
  $this->{$dyn->{group}} = $dyn->{value};
}
sub EditRules{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, 
    '<small>' .
    "\n" .
    '<?dyn="Button" op="ShortReplaceEle" caption="AddRule"?>' .
    'For all existing ' .
    '<?dyn="SelectNsByValue" op="SelectedElement" index="ShortReplaceEle"?>' .
    '<?dyn="EleDropDown" rule="ShortReplaceEle"?></select> ' .
    'elements ' .
    ', set to <?dyn="InputChangeNoReload" field="ShortReplaceValue"?><br />' .
    '' .
    "\n" .
    '<?dyn="Button" op="ShortReplaceEle1" caption="AddRule"?>' .
    'For all existing ' .
    '<?dyn="InputChangeNoReload" field="ShortReplaceEle1"?> ' .
    'elements ' .
    ', set to <?dyn="InputChangeNoReload" field="ShortReplaceValue1"?><br />' .
    '' .
    "\n" .
    '<?dyn="Button" op="DeleteElement" caption="AddRule"?>' .
    'Delete the element ' .
    '<?dyn="InputChangeNoReload" ' .
    'field="FullDeleteEle" index="1"?><br />' .
    "\n" .
    '<?dyn="Button" op="InsertElement" caption="AddRule"?>' .
    'Insert the element ' .
    '<?dyn="InputChangeNoReload" field="InsertElement" index="1"?> ' .
    'with value ' .
    '<?dyn="InputChangeNoReload" field="InsertElementValue"?><br />' .
    "\n" .
    '<?dyn="Button" op="HashUid" caption="AddRule"?>' .
    'For all existing ' .
    '<?dyn="InputChangeNoReload" field="UidElements"?> ' .
    'elements, hash unhashed UIDs using base ' .
    '<?dyn="InputChangeNoReload" field="UidBase" index="1" length="30"?> ' .
    "<br />\n" .
    '<?dyn="Button" op="SplitSeries" caption="AddRules"?>' .
    'Split Series based on element ' .
    '<?dyn="InputChangeNoReload" field="SplitEle" index="1" length="30"?> ' .
    '</small>'
  );
}
sub SelectedElement{
  my($this, $http, $dyn) = @_;
  $this->{$dyn->{index}} = $dyn->{value};
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
  unless($this->{$dyn->{rule}}) {
    $this->{$dyn->{rule}} = "(0010,0010)";
  }
  for my $i (sort keys %{$elements}){
    $http->queue("<option value=\"$i\"" .
    ($i eq $this->{$dyn->{rule}} ? "selected" : "" ) .
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
sub CurrentEdits{
  my($this, $http, $dyn) = @_;
  $this->RecalcEdits;
  my $num_edits = scalar keys %{$this->{Edits}};
  unless($num_edits){
    $this->RefreshEngine($http, $dyn,
      "No edits selected<br>");
    my $to_copy = scalar keys %{$this->{FilesToLink}};
    $http->queue("<small>$to_copy files unaffected by edits<br /></small>");
    return;
  }
  my $to_copy = scalar keys %{$this->{FilesToLink}};
  $http->queue("<small>$to_copy files unaffected by edits<br /></small>");
  $http->queue("Edits:<br><table border><tr><th>key</th><th>Condition</th>" .
    "<th>Op</th><th>Substitution</th><th>Files Affected</th></tr>");
    my @keys = sort keys %{$this->{Edits}};
    for my $i (@keys){ $this->EditRow($http, $dyn, $i) };
    $http->queue("</table>");
  $this->RefreshEngine($http, $dyn,
    '<?dyn="Button" op="ApplyEdits" caption="Apply Edits"?>');
}
sub DeleteEdit{
  my($this, $http, $dyn) = @_;
  delete $this->{Edits}->{$dyn->{index}};
  if($dyn->{index} eq "ChangeUids"){ $this->{UidSubstitutions} = 0 }
  $this->AutoRefresh;
}
sub EditRow{
  my($this, $http, $dyn, $i) = @_;
  my $files_affected = scalar keys %{$this->{Edits}->{$i}->{affected_files}};
  $http->queue("<tr><td><small>$i</small></td><td><small>" .
    ($this->{Edits}->{$i}->{condition} ? $this->{Edits}->{$i}->{condition} :
     "None") .
    "</small></td><td><small>" .
    "$this->{Edits}->{$i}->{command}->[0]</small></td>" .
    "<td><small>");
  if($this->{Edits}->{$i}->{command}->[0] eq "uid_substitutions"){
    my $subs = scalar keys %{$this->{Edits}->{$i}->{command}->[1]};
    $http->queue("$subs uids to change");
  } elsif($this->{Edits}->{$i}->{command}->[0] eq "short_ele_replacements"){
    my @subs = sort keys %{$this->{Edits}->{$i}->{command}->[1]};
    for my $ei (0 .. $#subs){
      my $e = $subs[$ei];
      $http->queue("set existing $e elements to \"" .
        $this->{Edits}->{$i}->{command}->[1]->{$e} . '"');
      unless($ei == $#subs){ $http->queue("<br />") }
    }
  } elsif($this->{Edits}->{$i}->{command}->[0] eq "full_ele_deletes"){
    my @subs = sort keys %{$this->{Edits}->{$i}->{command}->[1]};
    for my $ei (0 .. $#subs){
      my $e = $subs[$ei];
      $http->queue($e);
      unless($ei == $#subs){ $http->queue("<br />") }
    }
  } elsif($this->{Edits}->{$i}->{command}->[0] eq "full_ele_additions"){
    my @subs = sort keys %{$this->{Edits}->{$i}->{command}->[1]};
    for my $ei (0 .. $#subs){
      my $e = $subs[$ei];
      $http->queue("$e => $this->{Edits}->{$i}->{command}->[1]->{$e}");
      unless($ei == $#subs){ $http->queue("<br />") }
    }
  } elsif($this->{Edits}->{$i}->{command}->[0] eq "hash_unhashed_uid"){
    unless(keys %{$this->{Edits}->{$i}->{command}->[1]} == 1){
      die "Malformed rule";
    }
    my $e = [keys %{$this->{Edits}->{$i}->{command}->[1]}]->[0];
    $http->queue("Hash unhashed UIDs in element " .
      "$e using base " .
      $this->{Edits}->{$i}->{command}->[1]->{$e});
  }
  $this->RefreshEngine($http, $dyn, 
    "</small></td><td><small>$files_affected</small></td><td><small>" .
    '<?dyn="Button" op="DeleteEdit" caption="del" index="' . $i .
    '"?></small></td></tr>'
  );
}
#sub StudySeriesImageSelections{
#  my($this, $http, $dyn) = @_;
#  $http->queue("\n\n\n<small>Summary of Directory Contents:<ul>\n");
#  for my $study (sort keys %{$this->{Summary}}){
#    $http->queue("<li>$study ( " . 
#      "<a href=\"#\" onClick=\"ns('ExamineStudy?" .
#      "obj_path=$this->{path}&study=$study')\">view</a>):" .
#      "<ul>\n");
#      for my $series (sort keys %{$this->{Summary}->{$study}}){
#        my($num_uids, $num_files) = $this->CountFilesAndUids($study, $series);
#        $http->queue("<li>$series, $num_files files, " .
#          " $num_uids uids " .
#          "<a href=\"#\", onClick=\"ns('ExamineSeries?obj_path=$this->{path}" .
#          "&series=$series')\">(view)</a>\n");
#        if(
#          (scalar keys %{$this->{Summary}->{$study}->{$series}->{modality}})
#          > 1
#        ){
#          $http->queue("<ul>\n");
#          $http->queue("<li>modalities:<ul>\n");
#          $http->queue("</ul></li>\n");
#          $http->queue("</ul>\n");
#        } else {
#          my @modalities = keys 
#            %{$this->{Summary}->{$study}->{$series}->{modality}};
#          my $modality = $modalities[0];
#          $http->queue(" modality: $modality");
#        }
#        $http->queue("</li>\n");
#      }
#    $http->queue("</ul></li>\n");
#  }
#  $http->queue("</ul></small>\n");
#}
#sub CountFilesAndUids{
#  my($this, $study, $series) = @_;
#  my $num_files = 0;
#  my $num_uids = 0;
#  my $foo = $this->{Summary}->{$study}->{$series}->{uids};
#  for my $uid (keys %$foo){
#    $num_uids += 1;
#    for my $f (keys %{$foo->{$uid}}){
#      $num_files += 1;
#    }
#  }
#  return $num_uids, $num_files;
#}
#sub ExamineStudy{
#  my($this, $http, $dyn) = @_;
#  my $child_name = $this->child_path("Examine_$dyn->{study}");
#  my $cmp_obj = $this->child($child_name);
#  if($cmp_obj) {
#    print STDERR "???  already exists ???";
#  } else {
#    $cmp_obj = FileDist::ShowStudy->new($this->{session},
#      $child_name, $dyn->{study}, $this->{DicomInfo}, $this->{Summary});
#  }
#  $cmp_obj->ReOpenFile;
#}
#sub ExamineSeries{
#  my($this, $http, $dyn) = @_;
#  my $child_name = $this->child_path("Examine_$dyn->{series}");
#  my $cmp_obj = $this->child($child_name);
#  if($cmp_obj) {
#    print STDERR "???  already exists ???";
#  } else {
#    $cmp_obj = FileDist::ShowSeries->new($this->{session},
#      $child_name, $dyn->{series}, $this->{DicomInfo}, $this->{Summary});
#  }
#  $cmp_obj->ReOpenFile;
#}
my $CondDescriptor = [
  "none",
  "Study",
  "Series",
  "Modality",
];
sub ShortReplaceEle{
  my($this, $http, $dyn) = @_;
  my $cond = $this->{CondSelector};
  my $match_type = $CondDescriptor->[$this->{CondSelector}];
  my $match_value = $this->{ConditionSel}->[$this->{CondSelector}];
  my $operation = "short_ele_replacements";
  my $ele = $this->{ShortReplaceEle};
  my $value = $this->{ShortReplaceValue};
  my $edit_descrip = {
    match_type => $match_type,
    match_value => $match_value,
    operation => $operation,
    ele => $ele,
    value => $value,
  };
  $this->EnterShortReplaceEdit($edit_descrip);
}
sub ShortReplaceEle1{
  my($this, $http, $dyn) = @_;
  my $cond = $this->{CondSelector};
  my $match_type = $CondDescriptor->[$this->{CondSelector}];
  my $match_value = $this->{ConditionSel}->[$this->{CondSelector}];
  my $operation = "short_ele_replacements";
  my $ele = $this->{ShortReplaceEle1};
  my $value = $this->{ShortReplaceValue1};
  unless($ele =~ /^\([\d0-9a-f]{4},[\d0-9a-f]{4}\)$/){
    $this->{State} = "EditError";
    $this->{EditError} = "Illegal Element Specification: $ele";
    $this->AutoRefresh;
    return;
  }
  my $edit_descrip = {
    match_type => $match_type,
    match_value => $match_value,
    operation => $operation,
    ele => $ele,
    value => $value,
  };
  $this->EnterShortReplaceEdit($edit_descrip);
}
sub EnterShortReplaceEdit{
  my($this, $des) = @_;
  my $flist =
    $this->GetAffectedFileList($des->{match_type}, $des->{match_value});
  my @command_value;
  $command_value[0] = $des->{operation};
  $command_value[1] = { $des->{ele} => $des->{value} };
  my $ri = "Rule_$this->{RuleIndex}";
  $this->{RuleIndex} += 1;
  $this->{Edits}->{$ri} = {
    affected_files => $flist,
    command => \@command_value,
  };
  if($des->{match_type} ne "none"){
    $this->{Edits}->{$ri}->{condition} = 
      "If $des->{match_type} eq $des->{match_value}";
  }
  $this->AutoRefresh;
}
sub GetAffectedFileList{
  my($this, $m_type, $m_v) = @_;
  my %affected_files;
  file:
  for my $i (keys %{$this->{DicomInfo}}){
    my $c_value;
    if($m_type eq "Study") {
      $c_value = $this->RouteAbove("GetEntityNicknameByEntityId",
      "Study", $this->{DicomInfo}->{$i}->{study_uid});
    } elsif ($m_type eq "Series"){
      $c_value = $this->RouteAbove("GetEntityNicknameByEntityId",
      "Series", $this->{DicomInfo}->{$i}->{series_uid});
    } elsif ($m_type eq "Modality"){
      $c_value = $this->{DicomInfo}->{$i}->{modality};
    } elsif ($m_type eq "none"){
      $affected_files{$i} = 1;
      next file;
    }
    if($c_value eq $m_v){
      $affected_files{$i} = 1
    }
  }
  return \%affected_files;
}
sub InsertElement{
  my($this, $http, $dyn) = @_;
  my $cond = $this->{CondSelector};
  my $match_type = $CondDescriptor->[$this->{CondSelector}];
  my $match_value = $this->{ConditionSel}->[$this->{CondSelector}];
  my $operation = "full_ele_additions";
  my $ele = $this->{InsertElement}->{1};
  my $value = $this->{InsertElementValue};
  unless(Posda::Dataset->ValidateSig($ele)){
    $this->{State} = "EditError";
    $this->{EditError} = "Illegal Element Specification: $ele";
    $this->AutoRefresh;
    return;
  }
  my $flist = $this->GetAffectedFileList($match_type, $match_value);
  my $ri = "Rule_$this->{RuleIndex}";
  $this->{RuleIndex} += 1;
  $this->{Edits}->{$ri} = {
    affected_files => $flist,
    command => [ $operation, { $ele => $value }, ],
  };
  if($match_type ne "none"){
    $this->{Edits}->{$ri}->{condition} = "If $match_type eq $match_value";
  }
  $this->AutoRefresh;
}
sub HashUid{
  my($this, $http, $dyn) = @_;
  my $cond = $this->{CondSelector};
  my $match_type = $CondDescriptor->[$this->{CondSelector}];
  my $match_value = $this->{ConditionSel}->[$this->{CondSelector}];
  my $operation = "hash_unhashed_uid";
  my $ele = $this->{UidElements};
  my $value = $this->{UidBase}->{1};
  unless($ele =~ /^\([\d0-9a-f]{4},[\d0-9a-f]{4}\)$/){
    $this->{State} = "EditError";
    $this->{EditError} = "Illegal Element Specification: $ele";
    $this->AutoRefresh;
    return;
  }
  my $flist = $this->GetAffectedFileList($match_type, $match_value);
  my $ri = "Rule_$this->{RuleIndex}";
  $this->{RuleIndex} += 1;
  $this->{Edits}->{$ri} = {
    affected_files => $flist,
    command => [ $operation, { $ele => $value } ],
  };
  if($match_type ne "none"){
    $this->{Edits}->{$ri}->{condition} = "If $match_type eq $match_value";
  }
  $this->AutoRefresh;
}
sub SplitSeries{
  my($this, $http, $dyn) = @_;
  my $new_uuid = Posda::UUID::GetUUID;
  my $seq = 1;
  unless($this->{CondSelector} == 2){
    $this->{State} = "EditError";
    $this->{EditError} = "Rule must be conditional on series";
    $this->AutoRefresh;
    return;
  }
  my $series_to_split = $this->FetchFromAbove("GetEntityIdByNickname",
    $this->{ConditionSel}->[2]);
  my $ele_to_split = $this->{SplitEle}->{1};
#  print STDERR "Split $series_to_split\n\ton$ele_to_split\n";
  my %Equivs;
  file:
  for my $file (keys %{$this->{DicomInfo}}){
    unless(
      $this->{DicomInfo}->{$file}->{series_uid} eq $series_to_split
    ){ next file }
print "File $file\n\tin series $series_to_split\n";
    my $v = $this->{DicomInfo}->{$file}->{$ele_to_split};
    if(exists $Equivs{$v}){
      $Equivs{$v}->{files}->{$file} = 1;
    } else {
      my $new_uid = $new_uuid . ".$seq";
      $seq++;
      $Equivs{$v} = {
        new_uid => $new_uid,
        files => {
          $file => 1,
        },
      }
    }
  }
  unless(keys %Equivs > 1){
    $this->{State} = "EditError";
    $this->{EditError} = "$ele_to_split doesn't split series " .
      "$this->{ConditionSel}->[2]\n";
    $this->AutoRefresh;
    return;
  }
  my @rules;
  for my $e (keys %Equivs){
    push @rules,  {
      command => [
        "short_ele_replacements",
        { "(0020,000e)" => $Equivs{$e}->{new_uid} },
      ],
      affected_files => $Equivs{$e}->{files},
      condition => "Split Series $this->{ConditionSel}->[2]",
    };
  }
  for my $r (@rules){
    my $ri = "Rule_$this->{RuleIndex}";
    $this->{RuleIndex}++;
    $this->{Edits}->{$ri} = $r;
  }
  $this->AutoRefresh;
}
#    '<?dyn="InputChangeNoReload" field="UidElements"?> ' .
#    'elements, hash unhashed UIDs using base ' .
#    '<?dyn="InputChangeNoReload" field="UidBase" index="1" length="30"?> ' .
sub DeleteElement{
  my($this, $http, $dyn) = @_;
  my $cond = $this->{CondSelector};
  my $match_type = $CondDescriptor->[$this->{CondSelector}];
  my $match_value = $this->{ConditionSel}->[$this->{CondSelector}];
  my $operation = "full_ele_deletes";
  my $ele = $this->{FullDeleteEle}->{1};
  unless(Posda::Dataset->ValidateSig($ele)){
    $this->{State} = "EditError";
    $this->{EditError} = "Illegal Element Specification: $ele";
    $this->AutoRefresh;
    return;
  }
  my $flist = $this->GetAffectedFileList($match_type, $match_value);
  my $ri = "Rule_$this->{RuleIndex}";
  $this->{RuleIndex} += 1;
  $this->{Edits}->{$ri} = {
    affected_files => $flist,
    command => [ $operation, { $ele => 1 }, ],
  };
  if($match_type ne "none"){
    $this->{Edits}->{$ri}->{condition} = "If $match_type eq $match_value";
  }
  $this->AutoRefresh;
}
sub EditError{
  my($this, $http, $dyn) = @_;
  $http->queue("$this->{EditError}");
}
sub ClearEditError{
  my($this, $http, $dyn) = @_;
  $this->{State} = "Edit";
  delete $this->{EditError};
  $this->AutoRefresh;
}
sub ApplyEdits{
  my($this, $http, $dyn) = @_;
  $this->{FileEdits} = {};
  $this->{FileEditWarnings} = {};
  for my $r (sort keys %{$this->{Edits}}){
    my $rule = $this->{Edits}->{$r};
    for my $f (keys %{$rule->{affected_files}}){
      $this->{FileEdits}->{$f}->{from_file} = $f;
      for my $s (keys %{$rule->{command}->[1]}){
        if(
          exists($this->{FileEdits}->{$f}->{$rule->{command}->[0]}->{$s}) &&
          $this->{FileEdits}->{$f}->{$rule->{command}->[0]}->{$s}
            ne
          $rule->{command}->[1]->{$s}
        ){
          unless(exists $this->{FileEditWarnings}->{$f}){
            $this->{FileEditWarnings}->{$f} = [];
          }
          push(@{$this->{FileEditWarnings}->{$f}},
            "conflict found in $r, $rule->{command}->[0]:" .
            " $s - " .
            "(\"$this->{FileEdits}->{$f}->{$rule->{command}->[0]}->{$s}\"" .
            " vs \"$rule->{command}->[1]->{$s}\")"
          );
        }
        $this->{FileEdits}->{$f}->{$rule->{command}->[0]}->{$s} =
          $rule->{command}->[1]->{$s};
      }
    }
  }
  for my $f (keys %{$this->{FileEdits}}){
    my $sop_class = $this->{DicomInfo}->{$f}->{sop_class_uid};
    my $sop_inst = $this->{DicomInfo}->{$f}->{sop_inst_uid};
    my $new_sop_inst = $sop_inst;
    my $prefix = Posda::DataDict::GetSopClassPrefix($sop_class);
    if(exists $this->{FileEdits}->{$f}->{uid_substitutions}){
      my $new_sop_inst = 
        $this->{FileEdits}->{$f}->{uid_substitutions}->{$sop_inst};
    }
    my $new_file_name = $this->{DestinationDescriptor}->{directory} .
      "/$prefix" . "_$new_sop_inst.dcm";
    $this->{FileEdits}->{$f}->{to_file} = $new_file_name;
  }
  $this->{State} = "EditsAnalyzed";
  $this->AutoRefresh;
}
sub EditAnalysisSummary{
  my($this, $http, $dyn) = @_;
  my $number_of_copies = scalar keys %{$this->{FilesToLink}};
  my $number_of_files_to_edit = scalar keys %{$this->{FileEdits}};
  my $number_of_file_warnings = scalar keys %{$this->{FileEditWarnings}};
  $http->queue("<small>Files to copy without changes: $number_of_copies<br />" .
    "Files to edit: $number_of_files_to_edit<br />" .
    "File edits with warnings: $number_of_file_warnings<br />"
  );
  $this->RefreshEngine($http, $dyn, 
    'Enter a short description of Edits: ' .
    '<?dyn="InputChangeNoReload" field="EditDescription"?><br />' .
    '<?dyn="Button" op="CommitEdits" ' .
    'caption="Commit these Edits"?><br />' .
    '<?dyn="Button" op="ChangeEdits" caption="Change Edits"?>');
}
sub ChangeEdits{
  my($this, $http, $dyn) = @_;
  $this->{State} = "Edit";
  $this->AutoRefresh;
}
sub CommitEdits{
  my($this, $http, $dyn) = @_;
  $this->{State} = "PerformingEdits";
  $this->{CommitErrors} = [];
  $this->{EditApplyResults} = [];
  $this->{EditApplyErrors} = [];
  $this->{DestinationDescriptor}->{Description} = $this->{EditDescription};
  my $fm = $this->get_obj("FileManager");
  my %links;
  for my $i (keys %{$this->{FilesToLink}}){
    my $sop_class = $this->{DicomInfo}->{$i}->{sop_class_uid};
    my $sop_inst = $this->{DicomInfo}->{$i}->{sop_inst_uid};
    my $prefix = Posda::DataDict::GetSopClassPrefix($sop_class);
    my $new_file_name = $this->{DestinationDescriptor}->{directory} .
      "/$prefix" . "_$sop_inst.dcm";
    if(link $i, $new_file_name){
      $links{$i} = $new_file_name;
      $fm->QueueFile($new_file_name, 3);
    } else {
      push(@{$this->{CommitErrors}}, 
        "unable to link $new_file_name to $i ($!)");
    }
  }
  push(@{$this->{EditApplyResults}}, { linked_files => \%links } );
  $this->PerformEdits;
}
sub PerformEdits{
  my($this) = @_;
  unless(defined $this->{PerformEdits}) { $this->{PerformEdits} = {} }
  my $num_performing = scalar keys %{$this->{PerformEdits}};
  my $num_waiting = scalar keys %{$this->{FileEdits}};
  if($num_waiting == 0 && $num_performing == 0){
    return $this->EditingFinished;
  }
  while($num_performing < 5 && $num_waiting > 0){
    $this->StartAnEdit;
    $num_performing = scalar keys %{$this->{PerformEdits}};
    $num_waiting = scalar keys %{$this->{FileEdits}};
  }
  $this->AutoRefresh;
}
sub StartAnEdit{
  my($this) = @_;
    my @wait_queue = keys %{$this->{FileEdits}};
    my $next_edit = shift @wait_queue;
    my $edit_def = $this->{FileEdits}->{$next_edit};
    delete $this->{FileEdits}->{$next_edit};
    $this->{PerformEdits}->{$next_edit} = $edit_def;
    $this->SerializedSubProcess($edit_def, "SubProcessEditor.pl",
      $this->EditResults($edit_def, $next_edit));
}
sub EditResults{
  my($this, $op, $file) = @_;
  my $fm = $this->get_obj("FileManager");
  my $sub = sub {
    my($status, $result) = @_;
    if($status eq "Failed"){
      $result->{op} = $op;
      $this->{OpFailed}->{$op->{to_file}} = $result;
    } else {
      $op->{result} = $result;
      push(@{$this->{EditApplyResults}}, $op);
    }
    $fm->QueueFile($op->{to_file}, 3);
    delete $this->{PerformEdits}->{$file};
    $this->PerformEdits;
  };
  return $sub;
}
sub EditingFinished{
  my($this) = @_;
  my $results_file = "$this->{DestinationDescriptor}->{directory}/Edit.Results";
  $this->{DestinationDescriptor}->{source} = $this->{FromDirectory};
  $this->{DestinationDescriptor}->{EditApplyResults} = 
    $this->{EditApplyResults};
  $this->{DestinationDescriptor}->{EditApplyErrors} = 
    $this->{EditApplyErrors};
  $this->{DestinationDescriptor}->{CommitErrors} = 
    $this->{CommitErrors};
  store $this->{DestinationDescriptor}, $results_file;
  $this->{State} = "EditingCommitted";
  $this->AutoRefresh;
}
sub PerformingEdits{
  my($this, $http, $dyn) = @_;
  my $num_performing = scalar keys %{$this->{PerformEdits}};
  my $num_waiting = scalar keys %{$this->{FileEdits}};
  $http->queue("Performing Edits<ul>" .
    "<li>Num in Process: $num_performing</li>".
    "<li>Num Waiting: $num_waiting</li></ul>");
}
sub EditingCommitted{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    'Editing Committed <?dyn="Button" op="AcknowledgeEditing" caption="OK"?>');
}
sub AcknowledgeEditing{
  my($this, $http, $dyn) = @_;
  $this->{State} = "Uninitialized";
  $this->ClearJunk;
}
sub DESTROY{
  my($this) = @_;
  if($this->{State} eq "Edit") { $this->AbandonEdits }
}
1;
