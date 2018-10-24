#!/usr/bin/perl -w
#
use strict;
use Posda::HttpApp::GenericIframe;
use FileDist::DirectorySelector;
use Posda::Dataset;
use Dispatch::Dicom;
use Dispatch::Dicom::Dataset;
use Dispatch::Dicom::Message;
use Dispatch::Dicom::Storage;
use Dispatch::Dicom::MessageAssembler;
use Posda::Command;
package FileDist::DicomSender;
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericIframe" );
sub new{
  my($class, $sess, $path) = @_;
  my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
  bless $this, $class;
  $this->{RoutesAbove}->{TempDir} = 1;
  $this->{ImportsFromAbove}->{ShowAlert} = 1;
  $this->{State} = "Initial";
  $this->{DestList} = $main::HTTP_APP_CONFIG->{config}->{Participants}
    ->{DicomDest};
  $this->{PCList} = $main::HTTP_APP_CONFIG->{config}->{Participants}
    ->{ProposedPresentationContexts};
  $this->{MsgHandlers} = $main::HTTP_APP_CONFIG->{config}->{Participants}
    ->{IncomingMessageHandlers};
  $this->{temp_dir} = $this->FetchFromAbove("TempDir");
  return $this;
}
sub AutoRefresh{
  my($this) = @_;
  $this->parent->AutoRefresh;
}
sub Initialize{
  my($this) = @_;
  $this->{directory} = undef;
  delete $this->{DirAnalyzer};
  $this->{State} = "AwaitingDirectorySelection";
}
sub Content{
  my($this, $http, $dyn) = @_;
  if($this->{State} eq "Initial"){ $this->Initialize }
  if($this->{State} eq "AnalyzingDirectory"){
    $this->DirectoryAnalysis($http, $dyn);
  } elsif($this->{State} eq "AwaitingDirectorySelection"){
    $this->RefreshEngine($http, $dyn, 
      'No directory selected<br>' .
      '<?dyn="Button" caption="Choose Directory" op="DirectorySelector"?>'
    );
  } elsif($this->{State} eq "AnalysisComplete"){
    $this->RefreshEngine($http, $dyn, 
      '<small>' .
      '<?dyn="Button" caption="Change Directory" op="ChangeDir"?><br/>' .
      'Select Send Destination: ' .
      '<?dyn="SelectNsByValue" op="SelectDestination"?>' .
      '<?dyn="DestinationDropDown"?></select><br/>' .
      'Select Presentation Context List: ' .
      '<?dyn="SelectNsByValue" op="SelectPresCtxList"?><br/>' .
      '<?dyn="PresCtxDropDown"?></select><br/>' .
      '<?dyn="Button" caption="Request Association" op="AssocReq"?>' .
      '</small>'
    );
  } elsif($this->{State} eq "Association Connected"){
    unless(defined $this->{Association}){
      return $this->Abort($http, $dyn);
    }
    if(exists $this->{Association}->{close_status}){
      $this->RefreshEngine($http, $dyn, 
        '<small>' .
        'Association closed by peer: ' .
        "$this->{Association}->{close_status}<br />" .
        '<?dyn="Button" op="Abort" caption="Clear"?>' .
        '<hr><?dyn="AssocReport"?>' .
        '</small>'
      );
    } else {
      $this->RefreshEngine($http, $dyn, 
        '<small>' .
        '<?dyn="AssocInfo"?>' .
        '<?dyn="ReleaseAbortClear"?>' .
        '<?dyn="EchoButton"?><br />' .
        '<?dyn="SendControl"?>' .
        '<hr><?dyn="AssocReport"?>' .
        '</small>'
      );
    }
  } elsif($this->{State} eq "Convert and/or Send in Progress"){
    $this->RefreshEngine($http, $dyn, 
      'Convert and/or Send in Progress<hr />' .
      '<?dyn="SendReport"?><hr />' .
      '<small><?dyn="Button" caption="Abort" op="AbortAssociation"?><br/>' .
      '</small>');
    $this->RefreshAfter(1);
  } elsif($this->{State} eq "Send Complete"){
    $this->RefreshEngine($http, $dyn, 
      'Send Complete<hr />' .
      '<?dyn="SendCompleteReport"?><hr />' .
      '<small><?dyn="ReleaseAbortClear"?><?dyn="EchoButton"?><br />' .
      '</small>');
  } else {
    $http->queue("Need processor for state: $this->{State}");
  }
}
sub AssocInfo{
  my($this, $http, $dyn) = @_;
  $http->queue("In association with: $this->{SelectedDestination}<br>" .
    "Sending Directory: $this->{directory}<br>");
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
sub SendReport{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,'<small><dyn="AssocInfo"?>');
  if($this->{SendInProgress}){
    $http->queue("Sending file: $this->{SendInProgress}->{file}<br />");
  }
  my $send_count = scalar @{$this->{SendList}};
  $http->queue("$send_count files in send queue.<br />");
  if($this->{ConversionInProgress}){
    $http->queue("Conversion in Progress:<ul>");
    $http->queue("<li>From: $this->{ConversionInProgress}->{from_file}</li>");
    $http->queue("<li>To: $this->{ConversionInProgress}->{to_file}</li>");
    $http->queue("</ul>");
  }
  my $conv_count = scalar @{$this->{MustConvertList}};
  $http->queue("$conv_count files in conversion queue.<br />");
  $http->queue("</small>");
}
sub SendCompleteReport{
  my($this, $http, $dyn) = @_;
  my $sent_ok = scalar @{$this->{SentListOk}};
  my $sent_not_ok = scalar @{$this->{SentListNotOk}};
  my $send_aborted = scalar @{$this->{SentListAborted}};
  my $conversion_aborted = scalar @{$this->{ConversionListAborted}};
  $this->RefreshEngine($http, $dyn,'<small><?dyn="AssocInfo"?>');
  if($sent_ok) {
    $http->queue("$sent_ok files sent with OK status<br />");
  }
  if($sent_not_ok) {
    $http->queue("$sent_not_ok files sent with bad status<br />");
  }
  if($send_aborted) {
    $http->queue("$send_aborted files not sent due to abort<br />");
  }
  if($conversion_aborted) {
    $http->queue("$conversion_aborted files not converted due to abort<br />");
  }
  $http->queue("</small>");
}
sub ChangeDir{
  my($this, $http, $dyn) = @_;
  $this->{State} = "Initial";
  $this->AutoRefresh;
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
  $this->{State} = "Association Pending";
  $this->{Association} = $connection;
  $this->AutoRefresh;
}
sub AssocReport{
  my($this, $http, $dyn) = @_;
  $http->queue("<table border=\"1\">" .
    "<tr><th>id</th><th>Accept</th><th>Abstract Syntax</th>" .
    "<th>Proposed Xfer Syntaxes</th><th>Accepted XferSyntax</th>" .
    "<th>Send Existing File</th><th>Send Converted File</th>" .
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
    $http->queue("</td><td>$xfr_stx</td><td>");
    if(exists $this->{SendAsIs}->{$i}){
      $http->queue($this->{SendAsIs}->{$i});
    }
    $http->queue("</td><td>");
    if(exists $this->{ConvertAndSend}->{$i}){
      $http->queue($this->{ConvertAndSend}->{$i});
    }
    $http->queue("</td></tr>");
  }
  $http->queue("</table>");
}
sub DirectoryAnalysis{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    '<?dyn="Button" caption="Abort" op="Abort"?>');
  my $da = $this->{DirAnalyzer};
  $http->queue("<small>Analyzing Dicom files in $this->{directory}:" .
    "</small><ul>");
  if($da->InitializingState($http, $dyn)){
    $this->RefreshAfter(1);
  }
}
sub DirectorySelector{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("DirectorySelector");
  my $dirobj = $this->child($child_name);
  unless($dirobj){
    $dirobj = FileDist::DirectorySelector->new($this->{session}, 
    $child_name, $this->DirectoryCallback);
  }
  $dirobj->ReOpenFile;
}
### Called when DirectorySelection is finished
sub DirectoryCallback{
  my($this) = @_;
  my $sub = sub {
    my($dir) = @_;
    $this->{directory} = $dir;
    $this->{State} = "AnalyzingDirectory";
    if(defined $this->{DirAnalyzer}){
      if($this->{DirAnalyzer}->{DirectoryManager}->{dir} eq $dir){ return }
      print STDERR "Aborting old DirAnalyzer\n";
      $this->{DirAnalyzer}->Abort;
    }
    $this->{DirAnalyzer} =
      FileDist::DirectoryAnalyzer->new($dir, $this->get_obj("FileManager"), 
        $this->AnalyzeComplete);
    $this->AutoRefresh;
  };
  return $sub;
}
sub AnalyzeComplete{
  my($this) = @_;
  my $sub = sub {
    $this->{State} = "AnalysisComplete";
    $this->AutoRefresh;
  };
}
sub Abort{
  my($this, $http, $dyn) = @_;
  if($this->{State} eq "AnalyzingDirectory"){
    if(exists $this->{DirectoryManager}){
      $this->{DirectoryManager}->Abort;
      $this->{DirectoryManager}->Delete;
    }
    $this->{State} = "Initial";
  } else {
    $this->{State} = "Initial";
    $this->AutoRefresh;
  }
}
sub AbortAssociation{
  my($this) = @_;
  if(exists $this->{Association} && $this->{Association}->can("Abort")){
    $this->{State} = "AbortPending";
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
      $this->{State} = "ReleasePending";
      $this->AutoRefresh;
    } else {
      print STDERR "Can't release - busy\n";
    }
  }
}
sub Release{
  my($this) = @_;
  print STDERR "In Release (Means peer requested release)\n";
  $this->{State} = "Initial";
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
  unless($this->{State} eq "Association Connected"){
    delete $this->{Association};
  }
  if($this->{State} eq "ReleasePending" || $this->{State} eq "AbortPending"){
    $this->{State} = "Initial";
  }
  $this->AutoRefresh;
}
sub BuildSendLists{
  my($this) = @_;
  $this->{SendList} = [];
  $this->{MustConvertList} = [];
  $this->{CantConvertList} = [];
  $this->{SendAsIs} = {};
  $this->{ConvertAndSend} = {};
  file:
  for my $f (keys %{$this->{DirAnalyzer}->{DirectoryManager}->{Processed}}){
    my $fi = $this->{DirAnalyzer}->{FM}->DicomInfo($f);
    my $fdi = $this->{DirAnalyzer}->{FM}->FileDigestInfo($f);
    unless($fi) {
      print STDERR "No dicom info for $f\n";
      next file;
    }
    my $sop_cl = $fi->{sop_class_uid};
    my $sop_inst = $fi->{sop_inst_uid};
    my $prefix = Posda::DataDict::GetSopClassPrefix($sop_cl);
    my $xfr_stx = $fdi->{xfr_stx};
    my $dso = $fdi->{dataset_start_offset};
    if(exists $this->{Association}->{sopcl}->{$sop_cl}->{$xfr_stx}){
      my $pc_id = $this->{Association}->{sopcl}->{$sop_cl}->{$xfr_stx};
      push(@{$this->{SendList}}, {
        file => $f,
        sop_cl => $sop_cl,
        sop_inst => $sop_inst,
        xfr_stx => $xfr_stx,
        pc_id => $pc_id,
        dso => $dso,
      });
      $this->{SendAsIs}->{$pc_id} += 1;
    } elsif(
      exists $this->{Association}->{sopcl}->{$sop_cl} &&
      scalar(keys %{$this->{Association}->{sopcl}->{$sop_cl}}) > 0
    ){
      my @sop_cls = keys %{$this->{Association}->{sopcl}->{$sop_cl}};
      my $new_xfr_stx = $sop_cls[0];
      my $pc_id = $this->{Association}->{sopcl}->{$sop_cl}->{$new_xfr_stx};
      push(@{$this->{MustConvertList}}, {
        from_file => $f,
        to_file => "$this->{temp_dir}/$prefix" . "_$sop_inst.dcm",
        sop_cl => $sop_cl,
        sop_inst => $sop_inst,
        old_xfr_stx => $xfr_stx,
        new_xfr_stx => $new_xfr_stx,
        pc_id => $pc_id,
      });
      $this->{ConvertAndSend}->{$pc_id} += 1;
    } else {
      push(@{$this->{CantConvertList}}, {
        file => $f,
        sop_cl => $sop_cl,
        sop_inst => $sop_inst,
        xfr_stx => $xfr_stx,
      });
    }
  }
}
sub SendControl{
  my($this, $http, $dyn) = @_;
  my $can_send = scalar(@{$this->{SendList}});
  my $can_convert_and_send = scalar(@{$this->{MustConvertList}});
  my $cant_send = scalar(@{$this->{CantConvertList}});
  if($can_send) {
    $http->queue("You can send $can_send files on this association.<br />");
  }
  if($can_convert_and_send) {
    $http->queue("You can convert $can_convert_and_send files to " .
      "files which you can send on this association.<br />");
  }
  if($cant_send) {
    $http->queue("There are $cant_send files which " .
      "you can't send on this association.<br />");
  }
  if($can_convert_and_send){
    $this->RefreshEngine($http, $dyn,
    '<?dyn="Button" op="ConvertAndSend"' .
    ' caption="Convert and Send All Files"?>')
  }
  if($can_send){
    $this->RefreshEngine($http, $dyn,
    '<?dyn="Button" op="ConvertAndSend"' .
    ' caption="Send All Files"?>')
  }
}
sub ConvertAndSend{
  my($this) = @_;
  $this->{State} = "Convert and/or Send in Progress";
  my $to_send = scalar($this->{SendList});
  my $must_convert = scalar($this->{MustConvertList});
  if($must_convert) { $this->StartConversion }
  $this->{SentListOk} = [];
  $this->{SentListNotOk} = [];
  $this->{SentListAborted} = [];
  $this->{ConversionListAborted} = [];
  if($to_send) { $this->StartSending }
  $this->AutoRefresh;
}
sub StartConversion{
  my($this) = @_;
  unless(defined $this->{Association}){
    while(my $r = shift @{$this->{MustConvertList}}){
      push(@{$this->{ConversionListAborted}}, $r);
    }
  }
  if($#{$this->{MustConvertList}} >= 0){
    $this->{ConversionInProgress} = shift(@{$this->{MustConvertList}});
    open my $fh, "ConvertToPart10.pl " .
      "\"$this->{ConversionInProgress}->{from_file}\" " .
      "\"$this->{ConversionInProgress}->{to_file}\" " .
      "\"$this->{ConversionInProgress}->{new_xfr_stx}\" |" or 
    die "Can't open conversion program";
    Dispatch::Select::Socket->new($this->HandleConversion, $fh)->Add("reader");
  } else {
    delete $this->{ConversionInProgress};
    $this->CheckComplete;
  }
}
sub HandleConversion{
  my($this) = @_;
  my $sub = sub {
    my($disp, $socket) = @_;
    my $buff;
    my $count = read($socket, $buff, 1024); 
    unless($buff =~ /^Dataset offset: (.*)$/) {
      print STDERR "ERROR in conversion unrecognizable offset: $buff\n";
      $disp->Remove;
      $this->StartConversion;
      return;
    }
    my $dso = $1;
    $disp->Remove;
    my $conv = $this->{ConversionInProgress};
    push(@{$this->{SendList}}, {
      file => $this->{ConversionInProgress}->{to_file},
      sop_cl  => $this->{ConversionInProgress}->{sop_cl},
      sop_inst  => $this->{ConversionInProgress}->{sop_inst},
      xfr_stx  => $this->{ConversionInProgress}->{new_xfr_stx},
      pc_id  => $this->{ConversionInProgress}->{pc_id},
      dso => $dso,
    });
    unless($this->{SendInProgress}){
      $this->StartSending;
    }
    $this->StartConversion;
  };
  return $sub;
}
sub StartSending{
  my($this) = @_;
  unless(defined $this->{Association}){
    while(my $r = shift @{$this->{SendList}}){
      push(@{$this->{SentListAborted}}, $r);
    }
  }
  if(exists $this->{Association}->{close_status}){
    while(my $r = shift @{$this->{SendList}}){
      push(@{$this->{SentListAborted}}, $r);
    }
  }
  if($#{$this->{SendList}} >= 0){
    $this->{SendInProgress} = shift(@{$this->{SendList}});
    my $pc_id = $this->{SendInProgress}->{pc_id};
    my $file = $this->{SendInProgress}->{file};
    my $sop_cl = $this->{SendInProgress}->{sop_cl};
    my $sop_inst = $this->{SendInProgress}->{sop_inst};
    my $dso = $this->{SendInProgress}->{dso};
    my $len = $this->{Association}->{max_length};
    my $cmd = Posda::Command->new_store_cmd($sop_cl, $sop_inst);
    my $ds = Dispatch::Dicom::Dataset->new_new($file,
      $this->{SendInProgress}->{xfr_stx},
      $this->{SendInProgress}->{xfr_stx},
      $this->{SendInProgress}->{dso},
      $len);
    my $ma = Dispatch::Dicom::MessageAssembler->new($pc_id,
      $cmd, $ds, $this->FileSent);
    $this->{Association}->QueueMessage($ma);
  } else {
    delete $this->{SendInProgress};
    $this->CheckComplete;
  }
}
sub FileSent{
  my($this) = @_;
  my $sub = sub {
    my($obj, $status) = @_;
    if($status eq "OK") {
      push(@{$this->{SentListOk}}, $this->{SendInProgress});
    } else {
      $this->{SendInProgress}->{SendStatus} = $status;
      push(@{$this->{SentListNotOk}}, $this->{SendInProgress});
    }
    # let disconnect stuff run before cranking StartSending
    $this->InvokeAfterDelay("StartSending", 0);
  };
  return $sub;
}
sub CheckComplete{
  my($this) = @_;
  if(exists $this->{SendInProgress}){ return }
  if(exists $this->{ConversionInProgress}){ return }
  if($#{$this->{SendList}} >= 0){ return }
  if($#{$this->{MustConvertList}} >= 0){ return }
  $this->{State} = "Send Complete";
  $this->AutoRefresh;
}
### Association Callbacks
sub ConnectionCallback{
  my($this) = @_;
  my $sub = sub {
    my($con) = @_;
    $this->{State} = "Association Connected";
    $this->BuildSendLists;
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
    $this->Release;
  };
  return $sub;
}
#####################
# Echo stuff
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

1;
