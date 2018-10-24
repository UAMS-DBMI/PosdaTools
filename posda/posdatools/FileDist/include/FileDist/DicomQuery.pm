#!/usr/bin/perl -w
#
use strict;
use Posda::HttpApp::GenericIframe;
use Posda::Dataset;
use Dispatch::Dicom;
use Dispatch::Dicom::Dataset;
use Dispatch::Dicom::Message;
use Dispatch::Dicom::MessageAssembler;
use Dispatch::Dicom::Finder;
use Dispatch::Dicom::Verification;
use Posda::Command;
package FileDist::DicomQuery;
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericIframe" );
{
  package FileDist::DicomQuery::StudyRootFind;
  use vars qw( @ISA );
  @ISA = qw( Dispatch::Dicom::Finder );
}
sub new{
  my($class, $sess, $path) = @_;
  my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
  bless $this, $class;
  $this->{command_id} = 0;
  $this->{RoutesAbove}->{TempDir} = 1;
  $this->{RunningQueries} = [];
  $this->{FinishedQueries} = [];
  $this->{DestList} = $main::HTTP_APP_CONFIG->{config}->{Participants}
    ->{QueryDest};
  $this->{PCList} = $main::HTTP_APP_CONFIG->{config}->{Participants}
    ->{ProposedQueryPresentationContexts};
  $this->{MsgHandlers} = $main::HTTP_APP_CONFIG->{config}->{Participants}
    ->{IncomingMessageHandlers};
  $this->{MsgHandlers}->{"1.2.840.10008.5.1.4.1.2.2.1"} = 
    "FileDist::DicomQuery::StudyRootFind";
  $this->{temp_dir} = $this->FetchFromAbove("TempDir");
  return $this;
}
sub AutoRefresh{
  my($this) = @_;
  $this->parent->AutoRefresh;
}
sub Initialize{
  my($this) = @_;
}
sub FindCommand{
  my($this, $http, $dyn) = @_;
  my $cmd = Posda::Command->new_find_command("1.2.840.10008.5.1.4.1.2.2.1", 1);
  my $ds = Posda::Dataset->new_blank;
  $ds->Insert("(0008,0005)", "ISO_IR 100");
  $ds->Insert("(0008,0020)", undef);
  $ds->Insert("(0008,0030)", undef);
  $ds->Insert("(0008,0050)", undef);
  $ds->Insert("(0008,0052)", "STUDY");
  $ds->Insert("(0008,0061)", undef);
  $ds->Insert("(0008,1030)", undef);
  $ds->Insert("(0010,0010)", undef);
  $ds->Insert("(0010,0020)", undef);
  $ds->Insert("(0010,0030)", undef);
  $ds->Insert("(0020,000d)", undef);
  $ds->Insert("(0020,1208)", undef);
  my $command_id = $this->{command_id};
  $this->{command_id} += 1;
  my $find_file = "$this->{temp_dir}/find_$command_id.find";
  my $fh;
  unless(open $fh, ">$find_file"){
    die "Can't open $fh";
  }
  $ds->WriteDataset($fh, "1.2.840.10008.1.2");
  close $fh;
  my $len =  $this->{Association}->{max_length};
  my $pc_id = $this->{Association}->{sopcl}->{"1.2.840.10008.5.1.4.1.2.2.1"}
    ->{"1.2.840.10008.1.2"};
  my $new_ds = Dispatch::Dicom::Dataset->new_new($find_file,
    "1.2.840.10008.1.2",
    "1.2.840.10008.1.2",
    0, $len);
  my $ma = Dispatch::Dicom::MessageAssembler->new($pc_id,
    $cmd, $new_ds, $this->FindResponse);
  $this->{Association}->QueueMessage($ma);
}
sub FindResponse{
  my($this) = @_;
  my $sub = sub {
    my($obj, $status) = @_;
print STDERR "Find Response\n";
  };
  return $sub;
}
sub Content{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, 
    '<hr><?dyn="Assoc"?>' . '<?dyn="FindAvailable"?>' .
    '<?dyn="ActiveFinds"?>' . '<?dyn="CompletedFinds"?>');
}
sub Assoc{
  my($this, $http, $dyn) = @_;
  if($this->{Association}){
    $this->RefreshEngine($http, $dyn,
      '<small>' .
      '<?dyn="AssocInfo"?>' .
      '<?dyn="ReleaseAbortClear"?>' .
      '<?dyn="EchoButton"?>' .
      '<br /><?dyn="AssocReport"?>' .
      '</small>'
    );
  } else {
    $this->RefreshEngine($http, $dyn,
      '<small>' .
      'Select Query ae: ' .
      '<?dyn="SelectNsByValue" op="SelectDestination"?>' .
      '<?dyn="DestinationDropDown"?></select><br/>' .
      'Select Presentation Context List: ' .
      '<?dyn="SelectNsByValue" op="SelectPresCtxList"?><br/>' .
      '<?dyn="PresCtxDropDown"?></select><br/>' .
      '<?dyn="Button" caption="Request Association" op="AssocReq"?>' .
      '</small>');
  }
}
sub AssocInfo{
  my($this, $http, $dyn) = @_;
  $http->queue("In association with: $this->{SelectedDestination}<br>");
}
sub ReleaseAbortClear{
  my($this, $http, $dyn) = @_;
  if(defined $this->{Association}){
    $this->RefreshEngine($http, $dyn, 
      '<?dyn="Button" caption="Release" op="ReleaseAssociation"?>' .
      '<?dyn="Button" caption="Abort" op="AbortAssociation"?>'
    );
  } else {
    $this->RefreshEngine($http, $dyn, 
      '<?dyn="Button" op="Abort" caption="Clear"?>');
  }
};
sub FindAvailable{
  my($this, $http, $dyn) = @_;
  if(
    exists $this->{Association} && 
      $this->{Association}->{outstanding} < 
      $this->{Association}->{max_outstanding}
  ){
    $this->RefreshEngine($http, $dyn, 
    '<hr><?dyn="FindCommandGenerator"?>');
  }
}
sub FindCommandGenerator{
  my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, 
    '<?dyn="Button" op="FindCommand" caption="Find"?>');
}
sub ActiveFinds{
  my($this, $http, $dyn) = @_;
}
sub CompletedFinds{
  my($this, $http, $dyn) = @_;
}
sub SelectDestination{
  my($this, $http, $dyn) = @_;
  $this->{SelectedDestination} = $dyn->{value};
  $this->AutoRefresh;
}
sub DestinationDropDown{
  my($this, $http, $dyn) = @_;
  my @Destinations = sort keys %{$this->{DestList}};
  unless(
    defined($this->{SelectedDestination}) &&
    exists $this->{DestList}->{$this->{SelectedDestination}}
  ){ $this->{SelectedDestination} = $Destinations[0] }
  for my $i (@Destinations){
    $http->queue("<option value=\"$i\"" .
      ($this->{SelectedDestination} eq $i ? " selected" : "") .
      ">$i</option>")
  }
}
sub SelectPresCtxList{
  my($this, $http, $dyn) = @_;
  $this->{SelectedPCs} = $dyn->{value};
  $this->AutoRefresh;
}
sub PresCtxDropDown{
  my($this, $http, $dyn) = @_;
  my @PCs = sort keys %{$this->{PCList}};
  unless(
    defined($this->{SelectedPCs}) &&
    exists $this->{PCList}->{$this->{SelectedPCs}}
  ){ $this->{SelectedPCs} = $PCs[0] }
  for my $i (@PCs){
    $http->queue("<option value=\"$i\"" .
      ($this->{SelectedPCs} eq $i ? " selected" : "") .
      ">$i</option>")
  }
}
sub AssocReq{
  my($this, $http, $dyn) = @_;
  ## Set up $host, $port, $new_assoc_descrip, $con_config,
  ##   $debug
  my $dest = $this->{DestList}->{$this->{SelectedDestination}};
  my $host = $dest->{host};
  my $port = $dest->{port};
  my $calling = $dest->{Calling};
  my $called = $dest->{Called};
  my $pcs = $this->{PCList}->{$this->{SelectedPCs}};
  my $con_config = {
   "incoming_message_handler" => $this->{MsgHandlers}
  };
  my $debug = 0;
  my $new_assoc_descrip = {
    ver => 1,
    calling => $calling,
    called => $called,
    app_context => "1.2.840.10008.3.1.1.1",
    imp_class_uid => "1.3.6.1.4.1.22213.1.69",
    imp_ver_name => "posda_file_dist",
    max_length => "16384",
    max_i => "1",
    max_p => "1",
  };
  my $pc_id = 1;
  for my $ent (@$pcs){
    $new_assoc_descrip->{presentation_contexts}->{$pc_id} = {
      abstract_syntax => $ent->[0],
      transfer_syntax => $ent->[1],
    };
    $pc_id += 2;
    if($pc_id > 255) { die "Too many proposed presentation contexts" }
  }
  my $connection;
  eval {
    $connection = Dispatch::Dicom::Connection->new_connect(
      $host, $port, $new_assoc_descrip, $con_config,
      $this->ConnectionCallback,
      $debug
    );
  };
  if($@){
    print STDERR "Unable to connect: $@\n";
    return;
  }
  $connection->SetDisconnectCallback($this->DisconnectCallback);
  $connection->SetReleaseCallback($this->ReleaseCallback);
  $this->{Association} = $connection;
  $this->AutoRefresh;
}
sub AssocReport{
  my($this, $http, $dyn) = @_;
  $http->queue("<table border=\"1\">" .
    "<tr><th>id</th><th>Accept</th><th>Abstract Syntax</th>" .
    "<th>Proposed Xfer Syntaxes</th><th>Accepted XferSyntax</th>" .
    "</tr>");
  my $dd = $Posda::Dataset::DD;
  for my $i (sort {$a <=> $b} keys %{$this->{Association}->{pres_cntx}}){
    my $item = $this->{Association}->{pres_cntx}->{$i};
    my $proposed = 
      $this->{Association}->{assoc_rq}->{presentation_contexts}->{$i};
    my $accepted;
    if($item->{accepted}) { $accepted = "Yes" }
    else {
      if($item->{reason} == 1){
        $accepted = "user-rejection";
      } elsif ($item->{reason} == 2){
        $accepted = "no-reason (provider rejection)";
      } elsif ($item->{reason} == 3){
        $accepted = "abstract-syntax-not-supported (provider rejection)";
      } elsif ($item->{reason} == 4){
        $accepted = "transfer-syntaxes-not-supported (provider rejection)";
      }
    }
    my $abs_stx = $dd->GetSopClName($proposed->{abstract_syntax});
    my $xfr_stx = "";
    if(exists $item->{xfr_stx}){
      $xfr_stx = $dd->GetXferStxName($item->{xfr_stx});
    }
    $http->queue("<tr><td>$i</td><td>$accepted</td>" .
      "<td>$abs_stx</td><td>");
    for my $i (0 .. $#{$proposed->{transfer_syntax}}){
      my $xfr_stx = $dd->GetXferStxName($proposed->{transfer_syntax}->[$i]);
      $http->queue($xfr_stx);
      unless($i == $#{$proposed->{transfer_syntax}}) {
        $http->queue("<br/>");
      }
    }
    $http->queue("</td><td>$xfr_stx</td><tr>");
  }
  $http->queue("</table>");
}
sub EchoButton{
  my($this, $http, $dyn) = @_;
  if(
    exists($this->{Association}) &&
    exists($this->{Association}->{sopcl}->{"1.2.840.10008.1.1"})
  ){
    $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" op="EchoRequest" caption="Echo"?>');
  }
}
sub EchoRequest{
  my($this) = @_;
  unless(
    defined($this->{Association}) &&
    $this->{Association}->can("Echo")
  ){
    $this->Message("No open connection to send echo.");
    return;
  }
  $this->{Association}->Echo($this->EchoResponse);
}
sub EchoResponse{
  my($this) = @_;
  my $sub = sub {
    my($con) = @_;
    $this->RouteAbove("ShowAlert", "Echo response received");
    $this->AutoRefresh;
  };
  return $sub;
}
########################################
sub AbortAssociation{
  my($this) = @_;
  if(exists $this->{Association} && $this->{Association}->can("Abort")){
    $this->{Association}->Abort("Operator requested abort");
  } else {
    print STDERR "No Association to Abort\n";
  }
  $this->{AutoRefresh};
}
sub ReleaseAssociation{
  my($this) = @_;
  if(exists $this->{Association} && $this->{Association}->can("ReleaseOK")){
    if($this->{Association}->ReleaseOK){
      $this->{Association}->Release;
      $this->AutoRefresh;
    } else {
      print STDERR "Can't release - busy\n";
    }
  }
}
sub Release{
  my($this) = @_;
  print STDERR "In Release (Means peer requested release)\n";
  $this->AutoRefresh;
}
sub Disconnect{
  my($this, $con) = @_;
  my $status;
  if(exists $con->{Abort}){
    $status = $con->{Abort}->{mess};
  } else {
    $status = $con->{close_status};
  }
  print STDERR "In Disconnect ($status)\n";
  delete $this->{Association};
  $this->AutoRefresh;
}
### Association Callbacks
sub ConnectionCallback{
  my($this) = @_;
  my $sub = sub {
    my($con) = @_;
    $this->AutoRefresh;
  };
  return $sub;
}
sub DisconnectCallback{
  my($this) = @_;
  my $sub = sub {
    my($con) = @_;
    $this->Disconnect($con);
  };
  return $sub;
}
sub ReleaseCallback{
  my($this) = @_;
  my $sub = sub {
    my($con) = @_;
print STDERR "In release callback\n";
    $this->Release;
  };
  return $sub;
}
1;
