#!/usr/bin/perl -w
#
use strict;
package PosdaCuration::DuplicateSopResolution;
use Posda::HttpApp::JsController;
use Posda::HttpApp::HttpObj;
use Posda::UUID;
use Posda::ElementNames;
use PosdaCuration::InfoExpander;
use PosdaCuration::CompareFiles;
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
  my($class, $sess, $path, $display_info, $sop_list) = @_;
  my $this = Dispatch::NamedObject->new($sess, $path);
  $this->{expander} = $expander;
  $this->{DisplayInfoIn} = $display_info;
  $this->{DisplayInfoIn} = $display_info;
  bless $this, $class;
  $this->InitializeSopList($sop_list);
  $this->{Mode} = "FetchingSopInfo";
  return $this;
}
sub Content{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, 
    '<h3>Resolving Duplicate SOP Instance UIDs: ' . 
    $this->{DisplayInfoIn}->{Collection} . ', Site: ' .
    $this->{DisplayInfoIn}->{Site} . ', Subject: ' .
    $this->{DisplayInfoIn}->{subj} . '</h3><hr>');
  my $mode = $this->{Mode};
  if($this->can($mode)){ $this->$mode($http, $dyn) }
}
sub InitializeSopList{
  my($this, $sop_list) = @_;
  my($child, $child_pid) = $this->ReadWriteChild(
    "GetDuplicateSopInfoBySops.pl posda_files_test");
  for my $sop (@$sop_list){
    print $child "$sop\n";
  }
  shutdown($child, 1);
  Dispatch::Select::Socket->new(
    $this->ReadSerializedResponse($this->SaveDupSopInfo, $child_pid),
    $child
  )->Add("reader");
}
sub SaveDupSopInfo{
  my($this) = @_;
  my $sub = sub {
    my($stat, $results) = @_;
    if($stat eq "Succeeded"){
      $this->{DupSopInfo} = $results;
      $this->InitOtherStructs;
      $this->{Mode} = "DataFetched";
      $this->parent->AutoRefresh;
    } else {
      die "GetDuplicateSopInfoBySops.pl posda_files returned $stat";
    }
  };
  return $sub;
}
sub GoBack{
  my($this, $http, $dyn) = @_;
  $this->parent->RestoreInfo;
  $this->DeleteSelf;
}
sub InitOtherStructs{
  my($this) = @_;
  my %file_receipt;
  for my $sop (keys %{$this->{DupSopInfo}}){
    for my $file (keys %{$this->{DupSopInfo}->{$sop}}){
      my $file_info = $this->{DupSopInfo}->{$sop}->{$file};
      my $file_id = $file_info->{file_id};
      $this->{FileIdToFile}->{$file_id} = $file;
      my @times = sort { $a cmp $b } keys %{$file_info->{import_time}};
      my $first = $times[0];
      my $last = $times[$#times];
      $file_receipt{$sop}->{$file_id}->{first} = $first;
      $file_receipt{$sop}->{$file_id}->{last} = $last;
    }
  }
  $this->{FileReceipts} = \%file_receipt;
}
###################
# Modes:
sub FetchingSopInfo{
  my($this, $http, $dyn) = @_;
  $http->queue("FetchingSopInfo");
}
sub DataFetched{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    '<?dyn="DelegateButton" op="GoBack" caption="Go Back" ' .
    'sync="Update();"?>' .
    '<?dyn="DelegateButton" op="KeepLatestFirst" ' .
    'caption="Keep Latest First Receipt" ' .
    'sync="Update();"?>' .
    '<?dyn="DelegateButton" op="KeepLatestLast" ' .
    'caption="Keep Latest Last Receipt" ' .
    'sync="Update();"?>' .
    '<?dyn="DelegateButton" op="KeepEarliestFirst" ' .
    'caption="Keep Earliest First Receipt" ' .
    'sync="Update();"?>' .
    '<?dyn="DelegateButton" op="KeepEarliestLast" ' .
    'caption="Keep Earliest Last Receipt" ' .
    'sync="Update();"?>' .
    '<hr><table border><tr>' .
    '<th rowspan="2">SOP</th>' .
    '<th colspan="5">Received Dates</th><th rowspan="2">' .
    '<?dyn="KeepButton"?>' .
    '</th></tr>' .
    '<tr><th>first</th><th>last</th><th>from</th><th>to</th>' .
    '<th>compare</th></tr>'
  );
  for my $sop (keys %{$this->{DupSopInfo}}){
    unless(defined $this->{CompareFromSelections}->{$sop}){
      $this->{CompareFromSelections}->{$sop} = 0;
    }
    unless(defined $this->{CompareToSelections}->{$sop}){
      $this->{CompareToSelections}->{$sop} = 0;
    }
    unless(defined $this->{KeepSelections}->{$sop}){
      $this->{KeepSelections}->{$sop} = 0;
    }
    my @files = sort
      {
        $this->{DupSopInfo}->{$sop}->{$a}->{file_id}
          <=>
        $this->{DupSopInfo}->{$sop}->{$b}->{file_id}
      }
      keys %{$this->{DupSopInfo}->{$sop}};
    my $num_files = @files;
    my $file_info = $this->{DupSopInfo}->{$sop}->{$files[0]};
    my $file_id = $file_info->{file_id};
    my @dates = sort keys %{$file_info->{import_time}};
    $http->queue("<tr>" .
      '<td colspan="7"></td></tr>' .
      '<tr>' .
      '<td rowspan="' . $num_files . '" valign="center">' . "$sop</td>" .
      '<td>' . $dates[0] . '</td><td>' . $dates[$#dates] . '</td>' .
      '<td>' . 
      $this->RadioButtonDelegate("Compare_from_$sop", $file_id,
        $this->{CompareFromSelections}->{$sop} == $file_id, 
          {
            op => "SelectFileForFromComparison",
            sop => $sop,
            sync => "Update();",
          }
        ) .
      '</td><td>' .
      $this->RadioButtonDelegate("Compare_to_$sop", $file_id,
        $this->{CompareToSelections}->{$sop} == $file_id, 
          {
            op => "SelectFileForToComparison",
            sop => $sop,
            sync => "Update();",
          }
        ) .
      '</td>' .
      '<td rowspan="' . $num_files . '">'
    );
    $this->NotSoSimpleButton($http, {
      caption => "Compare",
      op => "CompareSopInstances",
      sop => $sop,
    });
    $http->queue('</td><td>' .
      $this->RadioButtonDelegate("Keep_$sop", $file_id,
        $this->{KeepSelections}->{$sop} == $file_id, 
          {
            op => "SelectKeepFile",
            sop => $sop,
            sync => "Update();",
          }
        ) .
     '</td></tr>');
    for my $i (1 .. $#files){
      $file_info = $this->{DupSopInfo}->{$sop}->{$files[$i]};
      $file_id = $file_info->{file_id};
      @dates = sort keys %{$file_info->{import_time}};
      $http->queue(
        '<td>' . $dates[0] . '</td><td>' . $dates[$#dates] . '</td>' .
        '<td>' .
        $this->RadioButtonDelegate("Compare_from_$sop", $file_id,
          $this->{CompareFromSelections}->{$sop} == $file_id, 
            {
              op => "SelectFileForFromComparison",
              sop => $sop,
              sync => "Update();",
            }
          ) .
        '</td><td>' .
        $this->RadioButtonDelegate("Compare_to_$sop", $file_id,
          $this->{CompareToSelections}->{$sop} == $file_id, 
            {
              op => "SelectFileForToComparison",
              sop => $sop,
              sync => "Update();",
            }
          ) .
        '</td><td>' .
        $this->RadioButtonDelegate("Keep_$sop", $file_id,
          $this->{KeepSelections}->{$sop} == $file_id, 
            {
              op => "SelectKeepFile",
              sop => $sop,
              sync => "Update();",
            }
          ) .
        '</td></tr>');
    }
  }
  $this->RefreshEngine($http, $dyn,
    '</table>');
}
sub SelectFileForFromComparison{
  my($this, $http, $dyn) = @_;
  $this->{CompareFromSelections}->{$dyn->{sop}} = $dyn->{value};
}
sub SelectFileForToComparison{
  my($this, $http, $dyn) = @_;
  $this->{CompareToSelections}->{$dyn->{sop}} = $dyn->{value};
}
sub SelectKeepFile{
  my($this, $http, $dyn) = @_;
  $this->{KeepSelections}->{$dyn->{sop}} = $dyn->{value};
}
sub KeepEarliestFirst{
  my($this, $http, $dyn) = @_;
  for my $sop(keys %{$this->{FileReceipts}}){
    my $file_hash = $this->{FileReceipts}->{$sop};
    my @file_ids = sort 
      { $file_hash->{$a}->{first} cmp $file_hash->{$b}->{first} }
      keys %$file_hash;
    $this->{KeepSelections}->{$sop} = $file_ids[0];
  }
}
sub KeepEarliestLast{
  my($this, $http, $dyn) = @_;
  for my $sop(keys %{$this->{FileReceipts}}){
    my $file_hash = $this->{FileReceipts}->{$sop};
    my @file_ids = sort 
      { $file_hash->{$a}->{last} cmp $file_hash->{$b}->{last} }
      keys %$file_hash;
    $this->{KeepSelections}->{$sop} = $file_ids[0];
  }
}
sub KeepLatestFirst{
  my($this, $http, $dyn) = @_;
  for my $sop(keys %{$this->{FileReceipts}}){
    my $file_hash = $this->{FileReceipts}->{$sop};
    my @file_ids = sort 
      { $file_hash->{$a}->{first} cmp $file_hash->{$b}->{first} }
      keys %$file_hash;
    $this->{KeepSelections}->{$sop} = $file_ids[$#file_ids];
  }
}
sub KeepLatestLast{
  my($this, $http, $dyn) = @_;
  for my $sop(keys %{$this->{FileReceipts}}){
    my $file_hash = $this->{FileReceipts}->{$sop};
    my @file_ids = sort 
      { $file_hash->{$a}->{last} cmp $file_hash->{$b}->{last} }
      keys %$file_hash;
    $this->{KeepSelections}->{$sop} = $file_ids[$#file_ids];
  }
}
sub KeepButton{
  my($this, $http, $dyn) = @_;
  my $all_sops_have_selection = 1;
  for my $sop (keys %{$this->{DupSopInfo}}){
    unless(
      exists($this->{KeepSelections}->{$sop}) &&
      $this->{KeepSelections}->{$sop} > 0
    ){
      $all_sops_have_selection = 0;
    }
  }
  if($all_sops_have_selection){
    $this->NotSoSimpleButton($http, {
      caption => "Keep",
      op => "SetStatus",
      sync => "Update();",
    });
  } else {
    $http->queue("---");
  }
}
sub CompareSopInstances{
  my($this, $http, $dyn) = @_;
  my $sop = $dyn->{sop};
  ##  Stuff here
  return; #remove when stuff above appears
  print STDERR "Here's where we compare $from_file to $to_file\n";
  my $child_path = $this->child_path("compare_${from_file_nn}_$to_file_nn");
  my $child_obj = $this->get_obj($child_path);
  unless(defined $child_obj){
    $child_obj = PosdaCuration::CompareFiles->new($this->{session},
      $child_path, $from_file_nn, $from_file, $to_file_nn, $to_file);
    if($child_obj){
      $this->InvokeAbove("StartChildDisplayer", $child_obj);
    } else {
      print STDERR 'PosdaCuration::CompareFiles->new failed!!!' . "\n";
    }
  }
}
1;
