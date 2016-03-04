#!/usr/bin/perl -w
#
use strict;
package PosdaCuration::DuplicateSopResolution;
use Posda::HttpApp::JsController;
use Posda::HttpApp::HttpObj;
use Posda::UUID;
use Posda::ElementNames;
use PosdaCuration::InfoExpander;
use Posda::UidCollector;
use Dispatch::NamedObject;
use Dispatch::LineReader;
use Digest::MD5;
use JSON::PP;
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
    "GetDuplicateSopInfoBySops.pl posda_files");
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
    'sync="Update();"?>');
}
1;
