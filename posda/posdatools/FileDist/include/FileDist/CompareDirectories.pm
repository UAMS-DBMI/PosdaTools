#!/usr/bin/perl -w
#
use strict;
use Posda::HttpApp::GenericIframe;
use Posda::HttpApp::DicomNicknames;
use FileDist::CompareFiles;
use Debug;
my $dbg = sub {print STDERR @_ };
package FileDist::CompareDirectories;
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericIframe" );
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
  $this->{compare_seq} = 0;
  return $this;
}
my $unknown_state = <<EOF;
Unknown state: <?dyn="State"?><br/>
<?dyn="Button" op="Reset" caption="Reset"?>
EOF
my $uninit_state = <<EOF;
<h3>Compare Directories</h3>
<?dyn="Button" op="ChooseFromDirectory" caption="Choose From Directory"?><br />
<?dyn="Button" op="ChooseToDirectory" caption="Choose To Directory"?><br />
EOF
my $initializing_from = <<EOF;
<h3>Compare Directories</h3>
<small>Initializing from directory (<?dyn="From"?>):</small><hr />
<?dyn="FromInitStatus"?>
EOF
my $initializing_to = <<EOF;
<h3>Compare Directories</h3>
<small>Initializing to directory (<?dyn="To"?>):</small><hr />
<?dyn="ToInitStatus"?>
EOF
my $from_only = <<EOF;
<h3>Compare Directories</h3>
<small>From directory: <?dyn="From"?>&nbsp;
<?dyn="Button" op="ClearFrom" caption="Clear"?><br />
<?dyn="Button" op="ChooseToDirectory" caption="Choose To Directory"?><br />
</small>
EOF
my $to_only = <<EOF;
<h3>Compare Directories</h3>
<small>
<?dyn="Button" op="ChooseFromDirectory" caption="Choose From Directory"?><br />
To directory: <?dyn="To"?>&nbsp;
<?dyn="Button" op="ClearTo" caption="Clear"?><br />
</small>
EOF
my $initializing_compare = <<EOF;
<h3>Compare Directories</h3>
<?dyn="Button" op="Reset" caption="Reset"?><br>
time to work on initializing compare
EOF
my $compare = <<EOF;
<h3>Compare Directories</h3>
<small>
<?dyn="Button" op="Reset" caption="Reset"?><hr />

From directory: <?dyn="From"?>&nbsp;<br />
To directory: <?dyn="To"?>&nbsp;<hr />
</small>
<?dyn="CompareSummary"?>
EOF
my $compare_files = <<EOF;
<h3>Compare Directories</h3>
<?dyn="Button" op="Reset" caption="Reset"?><br>
time to work on compare_files
EOF
sub Content{
  my($this, $http, $dyn) = @_;
  if($this->{State} eq "Uninitialized"){
    return $this->RefreshEngine($http, $dyn, $uninit_state);
  } elsif($this->{State} eq "InitializingFrom"){
    return $this->RefreshEngine($http, $dyn, $initializing_from);
  } elsif($this->{State} eq "InitializingTo"){
    return $this->RefreshEngine($http, $dyn, $initializing_to);
  } elsif($this->{State} eq "FromOnly"){
    return $this->RefreshEngine($http, $dyn, $from_only);
  } elsif($this->{State} eq "ToOnly"){
    return $this->RefreshEngine($http, $dyn, $to_only);
  } elsif($this->{State} eq "InitializingCompare"){
    return $this->RefreshEngine($http, $dyn, $initializing_compare);
  } elsif($this->{State} eq "Compare"){
    return $this->RefreshEngine($http, $dyn, $compare);
  } elsif($this->{State} eq "CompareOfFiles"){
    $this->RefreshEngine($http, $dyn, $compare_files);
  } else {
    $this->RefreshEngine($http, $dyn, $unknown_state);
  }
}
sub Reset{
  my($this) = @_;
  if($this->{FromAnalyzer}) {
    $this->{FromAnalyzer}->Abort;
    delete $this->{FromAnalyzer};
    delete $this->{FromDirectory};
    delete $this->{From};
  }
  if($this->{ToAnalyzer}) {
    $this->{ToAnalyzer}->Abort;
    delete $this->{ToAnalyzer};
    delete $this->{ToDirectory};
    delete $this->{To};
  }
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
sub To{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{ToDirectory});
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
sub ClearTo{
  my($this, $http, $dyn) = @_;
  delete $this->{ToDirectory};
  delete $this->{ToAnalyzer};
  if(exists $this->{FromDirectory}){
    $this->{State} = "FromOnly";
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
      $child_name, $this->DirCallback("From"));
  }
  $sel_obj->ReOpenFile;
}
sub ChooseToDirectory{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("DirectorySelector");
  my $sel_obj = $this->child($child_name);
  if($sel_obj) {
    print STDERR "??? DirectorySelector already exists ???";
  } else {
    $sel_obj = FileDist::DirectorySelector->new($this->{session},
      $child_name, $this->DirCallback("To"));
  }
  $sel_obj->ReOpenFile;
}
sub DirCallback{
  my($this, $type) = @_;
  my $sub = sub {
    my($dir) = @_;
    if($type eq "To") {
      $this->{ToDirectory} = $dir;
      if(exists $this->{ToAnalyzer}){
        die "ToAnalyzer already exists";
      }
      $this->{ToAnalyzer} = 
        FileDist::DirectoryAnalyzer->new($dir, 
          $this->get_obj("FileManager"),
          $this->AnalyzeComplete("To"));
      $this->{State} = "InitializingTo";
    } elsif($type eq "From") {
      $this->{FromDirectory} = $dir;
      if(exists $this->{FromAnalyzer}){
        die "FromAnalyzer already exists";
      }
      $this->{FromAnalyzer} = 
        FileDist::DirectoryAnalyzer->new($dir, 
          $this->get_obj("FileManager"),
          $this->AnalyzeComplete("From"));
      $this->{State} = "InitializingFrom";
    } else { die "In dir callback with unknown type: $type" }
    $this->AutoRefresh;
  };
  return $sub;
}
sub AnalyzeComplete{
  my($this, $type) = @_;
  my $sub = sub {
    if($type eq "From"){
      unless($this->{State} eq "InitializingFrom") {
        die "Analysis of From complete in state $this->{State}";
      }
      if(exists $this->{ToDirectory}){
        $this->{State} = "InitializingCompare";
        $this->InitializeCompare;
      } else {
        $this->{State} = "FromOnly";
      }
    } elsif($type eq "To"){
      unless($this->{State} eq "InitializingTo") {
        die "Analysis of To complete in state $this->{State}";
      }
      if(exists $this->{FromDirectory}){
        $this->{State} = "InitializingCompare";
        $this->InitializeCompare;
      } else {
        $this->{State} = "ToOnly";
      }
    } else { die "AnalyzeComplete with unknown type: $type" }
    $this->AutoRefresh;
  };
  return $sub;
}
sub ToInitStatus{
  my($this, $http, $dyn) = @_;
  my $da = $this->{ToAnalyzer};
  $http->queue("<small>Analyzing Dicom files in to directory (" .
    "$this->{ToDirectory}):<br />");
  if($da->InitializingState($http, $dyn)){
    $this->RefreshAfter(1);
  }
}
sub FromInitStatus{
  my($this, $http, $dyn) = @_;
  my $da = $this->{FromAnalyzer};
  $http->queue("<small>Analyzing Dicom files in from directory (" .
    "$this->{FromDirectory}):<br />");
  if($da->InitializingState($http, $dyn)){
    $this->RefreshAfter(1);
  }
}
sub InitializeCompare{
  my($this) = @_;
  $this->{From} = $this->ConstructIndices(
    $this->{FromAnalyzer}->{DirectoryManager},
    $this->{FromAnalyzer}->{FM});
  $this->{To} = $this->ConstructIndices(
    $this->{ToAnalyzer}->{DirectoryManager},
    $this->{ToAnalyzer}->{FM});
  $this->{Paired} = {};
print STDERR "Pairing by SopInst\n";
  $this->PairBySopInst;
  if($this->AllPairedBySopInst){
    print STDERR "Paired by SOP OK\n";
  } else {
    print STDERR "Paired by SOP not OK\n";
    delete $this->{PairedBySop};
    $this->{Paired} = {};
    $this->PairByIpp;
    $this->PairByPixelDigest;
    $this->PairRemainingByModality;
  }
  delete $this->{CompareModality};
  delete $this->{CompareType};
  $this->{State} = "Compare";
  $this->AutoRefresh;
}
sub PairBySopInst{
  my($this) = @_;
  delete $this->{PairedBySop};
  for my $si (keys %{$this->{From}->{BySop}}){
    for my $f (keys %{$this->{From}->{BySop}->{$si}}){
      $this->{PairedBySop}->{$si}->{From}->{$f} = 1;
      $this->{Paired}->{$f} = 1;
    }
  }
  for my $si (keys %{$this->{To}->{BySop}}){
    for my $f (keys %{$this->{To}->{BySop}->{$si}}){
      $this->{PairedBySop}->{$si}->{To}->{$f} = 1;
      $this->{Paired}->{$f} = 1;
    }
  }
}
sub AllPairedBySopInst{
  my($this) = @_;
  for my $si (keys %{$this->{From}->{BySop}}){
    unless(
      exists $this->{PairedBySop}->{$si} &&
      exists $this->{PairedBySop}->{$si}->{From} &&
      exists $this->{PairedBySop}->{$si}->{To}
    ){  return 0 }
  }
  for my $si (keys %{$this->{To}->{BySop}}){
    unless(
      exists $this->{PairedBySop}->{$si} &&
      exists $this->{PairedBySop}->{$si}->{From} &&
      exists $this->{PairedBySop}->{$si}->{To}
    ){  return 0 }
  }
  return 1;
}
sub ConstructIndices{
  my($this, $dm, $fm) = @_;
  my %Analysis;
  for my $f (keys %{$dm->{Processed}}){
    my $di = $fm->DicomInfo($f);
    unless($di) { next }
    my $sop_inst = $di->{sop_inst_uid};
    $Analysis{BySop}->{$sop_inst}->{$f} = 1;
    $Analysis{ByFile}->{$f} = $di;
    $Analysis{Modality}->{$di->{modality}}->{by_file}->{$f} = $di;
    if(exists $di->{pixel_digest}){
      $Analysis{Modality}->{$di->{modality}}->{pixel_digest}
        ->{$di->{pixel_digest}}->{$f} = 1;
    }
    if(exists $di->{norm_z} && exists $di->{norm_x} && exists $di->{norm_y}){
      my $norm_ipp = "$di->{norm_x}\\$di->{norm_y}\\$di->{norm_z}";
      $Analysis{Modality}->{$di->{modality}}->{norm_ipp}
        ->{$norm_ipp}->{$f} = 1;
    }
    if(exists $di->{pixel_digest}){
      $Analysis{Modality}->{$di->{modality}}->{pixel_digest}
        ->{$di->{pixel_digest}}->{$f} = 1;
    }
  }
  return \%Analysis;
}
sub PairByIpp{
  my($this) = @_;
  delete $this->{PairedByIpp};
  for my $mod (keys %{$this->{From}->{Modality}}){
    for my $z (keys %{$this->{From}->{Modality}->{$mod}->{norm_ipp}}){
      if(exists $this->{To}->{Modality}->{$mod}->{norm_ipp}->{$z}){
        for my $f (
          keys %{$this->{From}->{Modality}->{$mod}->{norm_ipp}->{$z}}
        ){
          $this->{Paired}->{$f} = 1;
          $this->{PairedByIpp}->{$mod}->{$z}->{"From"}->{$f} = 1;
        }
        for my $f (
          keys %{$this->{To}->{Modality}->{$mod}->{norm_ipp}->{$z}}
        ){
          $this->{Paired}->{$f} = 1;
          $this->{PairedByIpp}->{$mod}->{$z}->{"To"}->{$f} = 1;
        }
      }
    }
  }
}
sub PairByPixelDigest{
  my($this) = @_;
  delete $this->{PairedByPixelDigest};
  for my $mod (keys %{$this->{From}->{Modality}}){
    for my $z (keys 
      %{$this->{From}->{Modality}->{$mod}->{pixel_digest}}
    ){
      if(exists $this->{To}->{Modality}->{$mod}->{pixel_digest}->{$z}){
        for my $f (
          keys %{$this->{From}->{Modality}->{$mod}->{pixel_digest}->{$z}}
        ){
          $this->{Paired}->{$f} = 1;
          $this->{PairedByPixelDigest}->{$mod}
            ->{$z}->{"From"}->{$f} = 1;
        }
        for my $f (
          keys %{$this->{To}->{Modality}->{$mod}->{pixel_digest}->{$z}}
        ){
          $this->{Paired}->{$f} = 1;
          $this->{PairedByPixelDigest}->{$mod}
            ->{$z}->{"To"}->{$f} = 1;
        }
      }
    }
  }
}
sub PairRemainingByModality{
  my($this) = @_;
  $this->{UnpairedByModality} = {};
  my %files;
  for my $file (keys %{$this->{From}->{ByFile}}){
    $files{$file} = "From";
  }
  for my $file (keys %{$this->{To}->{ByFile}}){
    $files{$file} = "To" 
  }
  for my $file (keys %files){ unless(exists $this->{Paired}->{$file}){
      my $finfo = $this->{$files{$file}}->{ByFile}->{$file};
      my $modality = $finfo->{modality};
      $this->{UnpairedByModality}->{$modality}->{$files{$file}}->{$file} = 1;
    }
  }
}
sub CompareSummary{
  my($this, $http, $dyn) = @_;
  if(exists $this->{PairedBySop}){
    $this->RefreshEngine($http, $dyn,'<?dyn="PairedBySopReport"?>');
  } else {
    $this->RefreshEngine($http, $dyn,
      '<?dyn="PairedReport"?>' .
      '<?dyn="UnpairedReport"?><hr />' .
      '<?dyn="ComparisonModalityReport"?>');
  }
  
}
sub PairedBySopReport{
  my($this, $http, $dyn) = @_;
  $http->queue("<h3>All files paired by SOP Instance UID</h3>");
  my @pair_by_uid_blocks;
  my $child_name = $this->child_path("Nicknames");
  Posda::HttpApp::DicomNicknames->new($this->{session}, $child_name);
  for my $sop (keys %{$this->{PairedBySop}}){
    my %bi_hash;
    my @f_list;
    for my $f (keys %{$this->{PairedBySop}->{$sop}->{From}}){
      my %f_hash;
      my $info = $this->{FromAnalyzer}->{FM}->DicomInfo($f);
      $f_hash{type} = "From";
      $f_hash{info} = $info;
      $f_hash{file} = $f;
      $f_hash{modality} = $info->{modality};
      $bi_hash{modality} = $info->{modality};
      $f_hash{nicknames} = 
        $this->FetchFromAbove("GetDicomNicknamesByFile", $f);
      $bi_hash{sop} = $f_hash{nicknames}->[1];
      $f_hash{study_nick} = $this->FetchFromAbove(
          "GetEntityNicknameByEntityId", "Study", 
          $info->{study_uid});
      $bi_hash{study_nick} = $f_hash{study_nick};
      $f_hash{series_nick} = $this->FetchFromAbove(
          "GetEntityNicknameByEntityId", "Series", 
          $info->{series_uid});
      $bi_hash{series_nick} = $f_hash{series_nick};
      $f_hash{patient_id} = $info->{patient_id};
      $bi_hash{patient_id} = $info->{patient_id};
      $f_hash{patient_name} = $info->{patient_name};
      $bi_hash{patient_name} = $info->{patient_name};
      push @f_list, \%f_hash;
    }
    for my $f (keys %{$this->{PairedBySop}->{$sop}->{To}}){
      my %f_hash;
      my $info = $this->{FromAnalyzer}->{FM}->DicomInfo($f);
      $f_hash{type} = "To";
      $f_hash{info} = $info;
      $f_hash{file} = $f;
      $f_hash{modality} = $info->{modality};
      $bi_hash{modality} = $info->{modality};
      $f_hash{nicknames} = 
        $this->FetchFromAbove("GetDicomNicknamesByFile", $f);
      $bi_hash{sop} = $f_hash{nicknames}->[1];
      $f_hash{study_nick} = $this->FetchFromAbove(
          "GetEntityNicknameByEntityId", "Study", 
          $info->{study_uid});
      $bi_hash{study_nick} = $f_hash{study_nick};
      $f_hash{series_nick} = $this->FetchFromAbove(
          "GetEntityNicknameByEntityId", "Series", 
          $info->{series_uid});
      $bi_hash{series_nick} = $f_hash{series_nick};
      $f_hash{patient_id} = $info->{patient_id};
      $bi_hash{patient_id} = $info->{patient_id};
      $f_hash{patient_name} = $info->{patient_name};
      $bi_hash{patient_name} = $info->{patient_name};
      push @f_list, \%f_hash;
    }
    $bi_hash{f_list} = [
      sort
      {
        $a->{type} cmp $b->{type} ||
        $a->{patient_name} cmp $b->{patient_name} ||
        $a->{study_nick} cmp $b->{study_nick} ||
        $a->{series_nick} cmp $b->{series} ||
        $a->{modality} cmp $b->{modality}
      }
      @f_list
    ];
    push @pair_by_uid_blocks, \%bi_hash;
  }
  $this->{CompareBlocks} = [
    sort 
    {
      $a->{patient_name} cmp $b->{patient_name} ||
      $a->{study_nick} cmp $b->{study_nick} ||
      $a->{series_nick} cmp $b->{series_nick}
    }
    @pair_by_uid_blocks
 ];
  $this->RefreshEngine($http, $dyn,
    '<table><tr>' .
    '<th>i</th><th>UID</th><th>pat_id</th><th>pat_name</th>' .
    '<th>study</th><th>series</th>' .
    '<th>file/obj id</th>pp</th><th>dir<th>from</th><th>to</th>' .
    '</tr><tr><td colspan="11"><hr></td></tr>' .
    '<?dyn="CompareUidBlocksRows"?>' .
    '</table>'
  );
}
sub CompareUidBlocksRows{
  my($this, $http, $dyn) = @_;
  for my $i (0 .. $#{$this->{CompareBlocks}}){
    $dyn->{index} = $i;
    $this->CompareUidBlockRows($http, $dyn);
  }
}
sub CompareUidBlockRows{
  my($this, $http, $dyn) = @_;
  unless(defined $this->{CompareBlocks}->[$dyn->{index}]){
    print STDERR "this->{CompareBlocks}->[$dyn->{index} not defined\n";
    return;
  }
  my $block = $this->{CompareBlocks}->[$dyn->{index}];
  unless(ref($block->{f_list}) eq "ARRAY"){
    print STDERR "this->{CompareBlocks}->[$dyn->{index}]->{f_list} not array\n";
    return;
  }
  my $count = scalar @{$block->{f_list}};
  $this->RefreshEngine($http, $dyn, 
    '<tr><td rowspan="' . $count. '"><small>' . $dyn->{index} . '</small></td>'.
    '<td rowspan="' . $count . '"><small>&nbsp;&nbsp;'
  );
  if(defined $block->{sop}){
    $http->queue($block->{sop});
  } else {
    $http->queue("---");
  }
  $this->RefreshEngine($http, $dyn,
      '</small></td>' . '<?dyn="CompareUidBlockFiles"?>' .
    '</tr><tr><td colspan="11"><hr></td></tr>'
  );
}
sub CompareUidBlockFiles{
  my($this, $http, $dyn) = @_;
  my $block = $this->{CompareBlocks}->[$dyn->{index}];
  my $from_group = "RadioFilesFrom";
  my $to_group = "RadioFilesTo";
  for my $i (0 .. $#{$block->{f_list}}){
    unless(defined $this->{$from_group}->{$dyn->{index}}){
      $this->{$from_group}->{$dyn->{index}} = 0;
    }
    unless(defined $this->{$to_group}->{$dyn->{index}}){
      $this->{$to_group}->{$dyn->{index}} = 1;
    }
    $dyn->{value} = $i;
    $this->RefreshEngine($http, $dyn,
      "<td><small>" .
      "&nbsp;&nbsp;$block->{f_list}->[$i]->{patient_id}&nbsp;&nbsp;" .
      "</small></td>" .
      "<td>" .
      "<small>&nbsp;&nbsp;$block->{f_list}->[$i]->{patient_name}" .
      "&nbsp;&nbsp;</small>" .
      "</td>" .
      "<td>" .
      "<small>&nbsp;&nbsp;$block->{f_list}->[$i]->{study_nick}" .
      "&nbsp;&nbsp;</small></td>" .
      "<td><small>" .
      "&nbsp;&nbsp;$block->{f_list}->[$i]->{series_nick}" .
      "&nbsp;&nbsp;</small></td>" .
      "<td><small>&nbsp;&nbsp;$block->{f_list}->[$i]->{nicknames}->[0]" .
#      ";$block->{f_list}->[$i]->{nicknames}->[1]&nbsp;&nbsp;" .
      "</small></td>" .
      "<td><small>&nbsp;&nbsp;" .
      "$block->{f_list}->[$i]->{type}&nbsp;&nbsp;</small></td>" .
      "<td><small>" .
      '<?dyn="RadioNotify" group="' . $from_group .
      '" Op="ProcessRadioButton"?>' .
      '</small>' .
      '</td><td><small>' .
      '<?dyn="RadioNotify" group="' . $to_group .
      '" Op="ProcessRadioButton"?>' .
      '</small></td>' .
      ($i == 0 ? ('<td rowspan="2"><small>' .
        '<?dyn="Button" op="CompareUidFromAndTo" caption="Compare"?>' .
        '</small><td></tr>') : '</tr>')
    );
  }
}
sub CompareUidFromAndTo{
  my($this, $http, $dyn) = @_;
  my $block = $dyn->{index};
  my $from_file_index = $this->{RadioFilesFrom}->{$block};
  my $to_file_index = $this->{RadioFilesTo}->{$block};
  my $from = $this->{CompareBlocks}->[$block]->{f_list}
    ->[$from_file_index];
  my $to = $this->{CompareBlocks}->[$block]->{f_list}
    ->[$to_file_index];
  $this->{compare_seq} += 1;
  my $child_name = $this->child_path("Compare_$this->{compare_seq}");
  my $cmp_obj = $this->child($child_name);
  if($cmp_obj) {
    print STDERR "??? Compare_<seq> already exists ???";
  } else {
    $cmp_obj = FileDist::CompareFiles->new($this->{session},
      $child_name, $from, $to);
  }
  $cmp_obj->ReOpenFile;
}
sub PairedReport{
  my($this, $http, $dyn) = @_;
  my @mod_paired_by_z = sort 
#    {$a->{From}->{norm_ipp} cmp $b->{From}->{norm_ipp}}
    keys %{$this->{PairedByIpp}};
  if($#mod_paired_by_z >= 0){
    $http->queue("<small>" .
       "The following modalities have files paired by z-position:<ul>");
    for my $m (@mod_paired_by_z){
      my $count = scalar keys %{$this->{PairedByIpp}->{$m}};
      $dyn->{index} = $m;
      $this->RefreshEngine($http, $dyn,
        "<li>$m - $count pairs " .
        '<?dyn="Button" caption="View" op="ViewModalityPairs"?>' .
        "</li>");
    }
    $http->queue("</ul></small>");
  }
}
sub UnpairedReport{
  my($this, $http, $dyn) = @_;
  my @mod_unpaired = sort keys %{$this->{UnpairedByModality}};
  if(scalar @mod_unpaired){
    $http->queue("<small>" .
       "The following modalities have files which can't be paired:<ul>");
    for my $m (@mod_unpaired){
      my $count_from = scalar keys %{$this->{UnpairedByModality}->{$m}->{From}};
      my $count_to = scalar keys %{$this->{UnpairedByModality}->{$m}->{To}};
      $dyn->{index} = $m;
      $this->RefreshEngine($http, $dyn,
        "<li>$m - $count_from in from dir, $count_to in to_dir " .
        '<?dyn="Button" caption="View" op="ViewModalityUnpaired"?>' .
        "</li>");
    }
    $http->queue("</ul></small>");
  }
}
sub ViewModalityUnpaired{
  my($this, $http, $dyn) = @_;
  $this->{CompareModality} = $dyn->{index};
  $this->{CompareType} = "Unpaired";
  $this->AutoRefresh;
}
sub ViewModalityPairs{
  my($this, $http, $dyn) = @_;
  $this->{CompareModality} = $dyn->{index};
  $this->{CompareType} = "Paired";
  $this->AutoRefresh;
}
sub ComparisonModalityReport{
  my($this, $http, $dyn) = @_;
  unless(defined $this->{CompareModality}) {
    return $http->queue("<small>Select Comparison Above</small>");
  }
  if($this->{CompareType} eq "Paired"){
    $this->ComparePairedModalityReport($http, $dyn);
  } else {
    $this->CompareUnPairedModalityReport($http, $dyn);
  }
}
sub ComparePairedModalityReport{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("Nicknames");
  Posda::HttpApp::DicomNicknames->new($this->{session}, $child_name);
  my @CompareBlocks;
  for my $z (sort 
    keys %{$this->{PairedByIpp}->{$this->{CompareModality}}}
  ){
    my @CompareBlock;
    for my $f (
      keys %{$this->{PairedByIpp}->{$this->{CompareModality}}->{$z}
        ->{From}}
    ){
      push @CompareBlock, {
        type => "From",
        file => $f,
        info => $this->{From}->{ByFile}->{$f},
        nicknames => $this->FetchFromAbove("GetDicomNicknamesByFile", $f),
        study_nick => $this->FetchFromAbove(
          "GetEntityNicknameByEntityId", "Study", 
          $this->{From}->{ByFile}->{$f}->{study_uid}),
        series_nick => $this->FetchFromAbove(
          "GetEntityNicknameByEntityId", "Series", 
          $this->{From}->{ByFile}->{$f}->{series_uid}),
        patient_id => $this->{From}->{ByFile}->{$f}->{patient_id},
        patient_name => $this->{From}->{ByFile}->{$f}->{patient_name},
        norm_x => $this->{From}->{ByFile}->{$f}->{norm_x},
        norm_y => $this->{From}->{ByFile}->{$f}->{norm_y},
        norm_z => $this->{From}->{ByFile}->{$f}->{norm_z},
      };
    }
    for my $f (
      keys %{$this->{PairedByIpp}->{$this->{CompareModality}}->{$z}
        ->{To}}
    ){
      push @CompareBlock, {
        type => "To",
        file => $f,
        info => $this->{To}->{ByFile}->{$f},
        nicknames => $this->FetchFromAbove("GetDicomNicknamesByFile", $f),
        study_nick => $this->FetchFromAbove(
          "GetEntityNicknameByEntityId", "Study", 
          $this->{To}->{ByFile}->{$f}->{study_uid}),
        series_nick => $this->FetchFromAbove(
          "GetEntityNicknameByEntityId", "Series", 
          $this->{To}->{ByFile}->{$f}->{series_uid}),
        patient_id => $this->{To}->{ByFile}->{$f}->{patient_id},
        patient_name => $this->{To}->{ByFile}->{$f}->{patient_name},
        norm_x => $this->{To}->{ByFile}->{$f}->{norm_x},
        norm_y => $this->{To}->{ByFile}->{$f}->{norm_y},
        norm_z => $this->{To}->{ByFile}->{$f}->{norm_z},
      };
    }
    push @CompareBlocks, \@CompareBlock;
  }
  $this->{CompareBlocks} = [
    sort
    {
      return $a->[0]->{patient_id} cmp $b->[0]->{patient_id}||
      $a->[0]->{study_nick} cmp $b->[0]->{study_nick}||
      $a->[0]->{series_nick} cmp $b->[0]->{series_nick}||
      $a->[0]->{norm_x} <=> $b->[0]->{norm_x} ||
      $a->[0]->{norm_y} <=> $b->[0]->{norm_y} ||
      $a->[0]->{norm_z} <=> $b->[0]->{norm_z};
    }  
    @CompareBlocks ];
  $this->RefreshEngine($http, $dyn,
    'Compare <?dyn="CompareModality"?>, paired by Ipp:' .
    '<table><tr>' .
    '<th>i</th><th>ipp</th><th>pat_id</th><th>pat_name</th>' .
    '<th>study</th><th>series</th>' .
    '<th>file/obj id</th>pp</th><th>dir<th>from</th><th>to</th>' .
    '</tr><tr><td colspan="11"><hr></td></tr>' .
    '<?dyn="CompareBlocksRows"?>' .
    '</table>'
  );
}
sub CompareModality{
  my($this, $http, $dyn) = @_;
  $http->queue("$this->{CompareModality}");
}
sub CompareBlocksRows{
  my($this, $http, $dyn) = @_;
  for my $i (0 .. $#{$this->{CompareBlocks}}){
    $dyn->{index} = $i;
    $this->CompareBlockRows($http, $dyn);
  }
}
sub CompareBlockRows{
  my($this, $http, $dyn) = @_;
  unless(defined $this->{CompareBlocks}->[$dyn->{index}]){
    print STDERR "this->{CompareBlocks}->[$dyn->{index} not defined\n";
    return;
  }
  unless(ref($this->{CompareBlocks}->[$dyn->{index}]) eq "ARRAY"){
    print STDERR "this->{CompareBlocks}->[$dyn->{index} not array\n";
    return;
  }
  my $count = scalar @{$this->{CompareBlocks}->[$dyn->{index}]};
  $this->RefreshEngine($http, $dyn, 
    '<tr><td rowspan="' . $count. '"><small>' . $dyn->{index} . '</small></td>'.
    '<td rowspan="' . $count . '"><small>&nbsp;&nbsp;'
  );
  if(defined $this->{CompareBlocks}->[$dyn->{index}]->[0]->{norm_x}){
    $http->queue(
    "$this->{CompareBlocks}->[$dyn->{index}]->[0]->{norm_x}\\" .
    "$this->{CompareBlocks}->[$dyn->{index}]->[0]->{norm_y}\\" .
    "$this->{CompareBlocks}->[$dyn->{index}]->[0]->{norm_z}&nbsp;&nbsp;");
  } else {
    $http->queue("---");
  }
  $this->RefreshEngine($http, $dyn,
      '</small></td>' . '<?dyn="CompareBlockFiles"?>' .
    '</tr><tr><td colspan="11"><hr></td></tr>'
  );
}
sub CompareBlockFiles{
  my($this, $http, $dyn) = @_;
  my $block = $this->{CompareBlocks}->[$dyn->{index}];
  my $from_group = "RadioFilesFrom";
  my $to_group = "RadioFilesTo";
  for my $i (0 .. $#{$block}){
    unless(defined $this->{$from_group}->{$dyn->{index}}){
      $this->{$from_group}->{$dyn->{index}} = 0;
    }
    unless(defined $this->{$to_group}->{$dyn->{index}}){
      $this->{$to_group}->{$dyn->{index}} = 1;
    }
    $dyn->{value} = $i;
    $this->RefreshEngine($http, $dyn,
      "<td><small>" .
      "&nbsp;&nbsp;$block->[$i]->{patient_id}&nbsp;&nbsp;</small></td>" .
      "<td>" .
      "<small>&nbsp;&nbsp;$block->[$i]->{patient_name}&nbsp;&nbsp;</small>" .
      "</td>" .
      "<td>" .
      "<small>&nbsp;&nbsp;$block->[$i]->{study_nick}&nbsp;&nbsp;</small></td>" .
      "<td><small>" .
      "&nbsp;&nbsp;$block->[$i]->{series_nick}&nbsp;&nbsp;</small></td>" .
      "<td><small>&nbsp;&nbsp;$block->[$i]->{nicknames}->[0];" .
      "$block->[$i]->{nicknames}->[1]&nbsp;&nbsp;</small></td>" .
      "<td><small>&nbsp;&nbsp;$block->[$i]->{type}&nbsp;&nbsp;</small></td>" .
      "<td><small>" .
      '<?dyn="RadioNotify" group="' . $from_group .
      '" Op="ProcessRadioButton"?>' .
      '</small>' .
      '</td><td><small>' .
      '<?dyn="RadioNotify" group="' . $to_group .
      '" Op="ProcessRadioButton"?>' .
      '</small></td>' .
      ($i == 0 ? ('<td rowspan="2"><small>' .
        '<?dyn="Button" op="CompareFromAndTo" caption="Compare"?>' .
        '</small><td></tr>') : '</tr>')
    );
  }
}
sub CompareFromAndTo{
  my($this, $http, $dyn) = @_;
  my $block = $dyn->{index};
  my $from_file_index = $this->{RadioFilesFrom}->{$block};
  my $to_file_index = $this->{RadioFilesTo}->{$block};
  my $from = $this->{CompareBlocks}->[$block]->[$from_file_index];
  my $to = $this->{CompareBlocks}->[$block]->[$to_file_index];
  $this->{compare_seq} += 1;
  my $child_name = $this->child_path("Compare_$this->{compare_seq}");
  my $cmp_obj = $this->child($child_name);
  if($cmp_obj) {
    print STDERR "??? Compare_<seq> already exists ???";
  } else {
    $cmp_obj = FileDist::CompareFiles->new($this->{session},
      $child_name, $from, $to);
  }
  $cmp_obj->ReOpenFile;
}
sub ProcessRadioButton{
  my($this, $http, $dyn) = @_;
  my $group = $dyn->{group};
  my $index = $dyn->{index};
  my $value = $dyn->{value};
  $this->{$group}->{$index} = $value;
}

sub CompareUnPairedModalityReport{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("Nicknames");
  Posda::HttpApp::DicomNicknames->new($this->{session}, $child_name);
  my @CompareBlocks;
#  for my $z (sort 
#    keys %{$this->{PairedByIpp}->{$this->{CompareModality}}}
#  ){
    my @CompareBlock;
    for my $f (
      keys %{$this->{UnpairedByModality}->{$this->{CompareModality}}
        ->{From}}
    ){
      push @CompareBlock, {
        type => "From",
        file => $f,
        info => $this->{From}->{ByFile}->{$f},
        nicknames => $this->FetchFromAbove("GetDicomNicknamesByFile", $f),
        study_nick => $this->FetchFromAbove(
          "GetEntityNicknameByEntityId", "Study", 
          $this->{From}->{ByFile}->{$f}->{study_uid}),
        series_nick => $this->FetchFromAbove(
          "GetEntityNicknameByEntityId", "Series", 
          $this->{From}->{ByFile}->{$f}->{series_uid}),
        patient_id => $this->{From}->{ByFile}->{$f}->{patient_id},
        patient_name => $this->{From}->{ByFile}->{$f}->{patient_name},
        norm_x => $this->{From}->{ByFile}->{$f}->{norm_x},
        norm_y => $this->{From}->{ByFile}->{$f}->{norm_y},
        norm_z => $this->{From}->{ByFile}->{$f}->{norm_z},
      };
    }
    for my $f (
      keys %{$this->{UnpairedByModality}->{$this->{CompareModality}}
        ->{To}}
    ){
      push @CompareBlock, {
        type => "To",
        file => $f,
        info => $this->{To}->{ByFile}->{$f},
        nicknames => $this->FetchFromAbove("GetDicomNicknamesByFile", $f),
        study_nick => $this->FetchFromAbove(
          "GetEntityNicknameByEntityId", "Study", 
          $this->{To}->{ByFile}->{$f}->{study_uid}),
        series_nick => $this->FetchFromAbove(
          "GetEntityNicknameByEntityId", "Series", 
          $this->{To}->{ByFile}->{$f}->{series_uid}),
        patient_id => $this->{To}->{ByFile}->{$f}->{patient_id},
        patient_name => $this->{To}->{ByFile}->{$f}->{patient_name},
        norm_x => $this->{To}->{ByFile}->{$f}->{norm_x},
        norm_y => $this->{To}->{ByFile}->{$f}->{norm_y},
        norm_z => $this->{To}->{ByFile}->{$f}->{norm_z},
      };
    }
    push @CompareBlocks, \@CompareBlock;
#  }
  $this->{CompareBlocks} = [
    sort
    {
      return $a->[0]->{patient_id} cmp $b->[0]->{patient_id}||
      $a->[0]->{study_nick} cmp $b->[0]->{study_nick}||
      $a->[0]->{series_nick} cmp $b->[0]->{series_nick}||
      $a->[0]->{norm_x} <=> $b->[0]->{norm_x} ||
      $a->[0]->{norm_y} <=> $b->[0]->{norm_y} ||
      $a->[0]->{norm_z} <=> $b->[0]->{norm_z};
    }  
    @CompareBlocks ];
  $this->RefreshEngine($http, $dyn,
    'Compare <?dyn="CompareModality"?>, paired by Ipp:' .
    '<table><tr>' .
    '<th>i</th><th>--</th><th>pat_id</th><th>pat_name</th>' .
    '<th>study</th><th>series</th>' .
    '<th>file/obj id</th>pp</th><th>dir<th>from</th><th>to</th>' .
    '</tr><tr><td colspan="11"><hr></td></tr>' .
    '<?dyn="CompareBlocksRows"?>' .
    '</table>'
  );
}
1;
