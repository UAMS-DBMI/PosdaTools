#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/DicomProxyAnalysis/include/DicomProxyAnalysis/AssocDisplay.pm,v $
#$Date: 2014/10/27 12:39:33 $
#$Revision: 1.9 $
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use Dispatch::LineReader;
use DicomProxyAnalysis::ShowDataset;
use DicomProxyAnalysis::ShowCmd;
#use Dispatch::Acceptor;
my $header = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2><?dyn="title"?></h2>
      </td>
    <td valign="top" align="right" width="180" height="120">
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="100%" child_path="WindowButtons"?>
    </td>
  </tr>
</table><hr>
<?dyn="iframe" height="350" child_path="Content"?>
<hr>
EOF
my $bad_config = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2><?dyn="title"?></h2>
      </td>
    <td valign="top" align="right" width="180" height="120">
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="100%" child_path="WindowButtons"?>
    </td>
  </tr>
</table>
<table border="1"><hr><th colspan="2">Bad Configuration Files</th></tr>
<?dyn="BadConfigReport"?>
</table>
EOF
{
  package DicomProxyAnalysis::AssocDisplay;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path, $dir) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Dicom Proxy Analysis Application";
    bless $this, $class;
    $this->{w} = 1024;
    $this->{h} = 700;
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    DicomProxyAnalysis::AssocDisplay::Content->new(
        $this->{session}, $this->child_path("Content"), $dir);
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
    $this->ReOpenFile();
    return $this;
  }
  sub Logo{
    my($this, $http, $dyn) = @_;
    my $image = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoImage};
    my $height = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoHeight};
    my $width = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
    my $alt = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoAlt};
    $http->queue("<img src=\"$image\" height=\"$height\" width=\"$width\" " ,
      "alt=\"$alt\">");
  }
  sub Content {
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $header);
  }
  sub CleanUp{
    my($this) = @_;
    $this->delete_descendants;
  }
  sub DESTROY{
    my($this) = @_;
  }
}
{
  package DicomProxyAnalysis::AssocDisplay::Content;
  use Time::HiRes qw( gettimeofday tv_interval );
  use File::Path qw (remove_tree);
  use Posda::HttpApp::GenericIframe;
  use Storable qw( fd_retrieve );
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path, $dir) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    $this->{dir} = $dir;
    my $fh;
    if(open $fh, "<$dir/assoc_data"){
      $this->{AssocData} = fd_retrieve($fh);
    }
    if(open $fh, "<$dir/assoc_data"){
      $this->{AssocData} = fd_retrieve($fh);
    }
    if(open $fh, "<$dir/message_info"){
      $this->{MessageInfo} = fd_retrieve($fh);
    }
    if(open $fh, "<$dir/pdu_analysis"){
      $this->{PduAnalysis} = fd_retrieve($fh);
    }
    if(open $fh, "<$dir/time_line"){
      $this->{TimeLine} = fd_retrieve($fh);
    }
    if(open $fh, "<$dir/time_line_index"){
      $this->{TimeLineIndex} = fd_retrieve($fh);
    }
    $this->{seq} = 0;
    bless $this, $class;
    $this->FindMessageTimes;
    $this->{DisplayState} = "messages";
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->StateMenu($http, $dyn);
    if($this->{DisplayState} eq "messages"){
      return $this->DisplayMessages($http, $dyn);
    } elsif($this->{DisplayState} eq "association_negotiation"){
      return $this->DisplayAssociation($http, $dyn);
    }
    $http->queue("Unknown display state: $this->{DisplayState}");
  }
  sub StateMenu{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
      'Select Display Option: <?dyn="SelectNsByValue" op="SelectState"?>' .
      '<?dyn="ModeDropDown"?></select><hr>');
  }
  sub ModeDropDown{
    my($this, $http, $dyn) = @_;
    for my $i ("messages", "association_negotiation"){
      $http->queue("<option value=\"$i\"");
      if($i eq $this->{DisplayState}){ $http->queue(" selected") }
      $http->queue(">$i</option>\n");
    }
  }
  sub SelectState{
    my($this, $http, $dyn) = @_;
    $this->{DisplayState} = $dyn->{value};
    $this->AutoRefresh;
  }
  sub DisplayAssociation{
    my($this, $http, $dyn) = @_;
    $http->queue("More to come");
  }
  sub DisplayMessages{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, 
      '<table border>' .
      '<tr><th rowspan="2">id</th><th rowspan="2">Type</th>' .
      '<th colspan="3">Message</th>' .
      '<th colspan="4">Dataset</th>' .
      '<th colspan="3">Responses</th>' .
      '<th colspan="4">Resp Dataset</th>' .
      '</tr>' .
      '<tr><th>In</th><th>Out</th><th>Link</th> ' .
      '<th>In</th><th>Out</th><th>Link</th><th>Pc Id</th> ' .
      '<th>In</th><th>Out</th><th>Link</th> ' .
      '<th>In</th><th>Out</th><th>Link</th><th>Pc Id</th></tr> ' .
      '<?dyn="MessageRows"?>' .
      '</table>'
    );
  }
  sub MessageRows{
    my($this, $http, $dyn) = @_;
    for my $id (sort {$a <=> $b} keys %{$this->{MessageInfo}}){
      my $i = $this->{MessageInfo}->{$id};
      $this->MessageRow($http, $dyn, $id, $i);
    }
  }
  sub MessageRow{
    my($this, $http, $dyn, $id, $msg) = @_;
    my $num_responses = scalar @{$msg->{responses}};
    my $msg_type = $this->MsgType($msg);
    my $dataset;
    my $msg_d = $msg->{$msg_type};
    if(exists $msg->{$msg_type}->{dataset}){
      $dataset = $msg->{$msg_type}->{dataset};
    }
    $dyn->{rowspan} = $num_responses;
    $dyn->{index} = $id;
    $this->RefreshEngine($http, $dyn,
      '<tr><td<?dyn="Rowspan"?> valign="top">' . "$id</td>" .
      '<td<?dyn="Rowspan"?> valign="top">' . "$msg_type</td>" .
      '<td<?dyn="Rowspan"?> valign="top">' . "$msg_d->{entered_proxy}</td>" .
      '<td<?dyn="Rowspan"?> valign="top">' . "$msg_d->{cleared_proxy}</td>" .
      '<td<?dyn="Rowspan"?> valign="top">' . 
      '<?dyn="Button" caption="disp" op="DispMessage"?>' .
      '</td>'
    );
    if(defined $dataset) {
      $this->RefreshEngine($http, $dyn,
        '<td<?dyn="Rowspan"?> valign="top">' . 
        "$dataset->{entered_proxy}</td>" .
        '<td<?dyn="Rowspan"?> valign="top">' .
        "$dataset->{cleared_proxy}</td>" .
        '<td<?dyn="Rowspan"?> valign="top">' .
        '<?dyn="Button" caption="disp" op="DispMessageDs"?>' .
        '</td>' .
        '<td<?dyn="Rowspan"?> valign="top">' .
        "$dataset->{pc_id}</td>"
      );
    } else {
      $this->RefreshEngine($http, $dyn, 
        '<td></td><td></td><td></td><td></td>');
    }
    for my $ri (0 .. $#{$msg->{responses}}){
      my $rds;
      my $r = $msg->{responses}->[$ri];
      $dyn->{param} = $ri;
      if(exists $r->{dataset}) { $rds = $r->{dataset} }
      $this->RefreshEngine($http, $dyn,
        "<td>$r->{entered_proxy}</td>" .
        "<td>$r->{cleared_proxy}</td>" .
        '<td>' .
        '<?dyn="Button" caption="disp" op="DispResp"?>' .
        '</td>'
      );
      if($rds){
        $this->RefreshEngine($http, $dyn,
          "<td>$rds->{entered_proxy}</td>" .
          "<td>$rds->{cleared_proxy}</td>" .
          '<td>' .
          '<?dyn="Button" caption="disp" op="DispRespDs"?>' .
          '</td>' .
          "<td>$rds->{pc_id}</td>\n"
        );
        delete $dyn->{param};
      } else {
        $this->RefreshEngine($http, $dyn, 
          '<td></td><td></td><td></td><td></td>');
      }
      $this->RefreshEngine($http, $dyn, '</tr>');
    }
  }
  sub DispRespDs{
    my($this, $http, $dyn) = @_;
    my $minfo = $this->{MessageInfo}->{$dyn->{index}};
    my $file = $minfo->{responses}->[$dyn->{param}]->{dataset}->{ds_file};
    $this->{seq} += 1;
    my $child_name = $this->child_path("File_$this->{seq}");
    my $sel_obj = $this->child($child_name);
    if($sel_obj) {
      print STDERR "??? DatasetDisplayer already exists ???";
    } else {
      $sel_obj = DicomProxyAnalysis::ShowDataset->new($this->{session},
        $child_name, $file);
    }
    $sel_obj->ReOpenFile;
  }
  sub DispMessageDs{
    my($this, $http, $dyn) = @_;
    my $minfo = $this->{MessageInfo}->{$dyn->{index}};
    my $mtype = $this->MsgType($minfo);
    my $file = $minfo->{$mtype}->{dataset}->{ds_file};
    $this->{seq} += 1;
    my $child_name = $this->child_path("File_$this->{seq}");
    my $sel_obj = $this->child($child_name);
    if($sel_obj) {
      print STDERR "??? DatasetDisplayer already exists ???";
    } else {
      $sel_obj = DicomProxyAnalysis::ShowDataset->new($this->{session},
        $child_name, $file);
    }
    $sel_obj->ReOpenFile;
  }
  sub DispMessage{
    my($this, $http, $dyn) = @_;
    my $minfo = $this->{MessageInfo}->{$dyn->{index}};
    my $mtype = $this->MsgType($minfo);
    my $command = $minfo->{$mtype}->{parsed};
    $this->{seq} += 1;
    my $child_name = $this->child_path("Command_$this->{seq}");
    my $sel_obj = $this->child($child_name);
    if($sel_obj) {
      print STDERR "??? DatasetDisplayer already exists ???";
    } else {
      $sel_obj = DicomProxyAnalysis::ShowCmd->new($this->{session},
        $child_name, $command, "Command");
    }
    $sel_obj->ReOpenFile;
  }
  sub DispResp{
    my($this, $http, $dyn) = @_;
    my $minfo = $this->{MessageInfo}->{$dyn->{index}};
    my $command = $minfo->{responses}->[$dyn->{param}]->{parsed};
    $this->{seq} += 1;
    my $child_name = $this->child_path("Command_$this->{seq}");
    my $sel_obj = $this->child($child_name);
    if($sel_obj) {
      print STDERR "??? DatasetDisplayer already exists ???";
    } else {
      $sel_obj = DicomProxyAnalysis::ShowCmd->new($this->{session},
        $child_name, $command, "Response");
    }
  }
  sub Rowspan{
    my($this, $http, $dyn) = @_;
    if($dyn->{rowspan} > 1){
      $http->queue(" rowspan=\"$dyn->{rowspan}\"");
    }
  }
  sub MsgType{
    my($this, $i) = @_;
    my $msg_type;
    if(exists $i->{STORE}) { return "STORE" }
    elsif(exists $i->{GET}) { return "GET" }
    elsif(exists $i->{FIND}) { return "FIND" }
    elsif(exists $i->{MOVE}) { return "MOVE" }
    elsif(exists $i->{ECHO}) { return "ECHO" }
    elsif(exists $i->{N_EVENT_REPORT}) { return "N_EVENT_REPORT" }
    elsif(exists $i->{N_GET}) { return "N_GET" }
    elsif(exists $i->{N_SET}) { return "N_SET" }
    elsif(exists $i->{N_ACTION}) { return "N_ACTION" }
    elsif(exists $i->{N_CREATE}) { return "N_CREATE" }
    elsif(exists $i->{N_DELETE}) { return "N_DELETE" }
    else { return undef }
  }
  sub FindMessageTimes{
    my($this) = @_;
    for my $in (sort { $a <=> $b} keys %{$this->{MessageInfo}}){
      my $i = $this->{MessageInfo}->{$in};
      my $msg_type = $this->MsgType($i);
      unless(defined $msg_type) { print STDERR "no message type defined\n" }
      my $message = $i->{$msg_type};
      $this->GetRcvFwdTime($message);
      if(exists $message->{dataset}){
        $this->GetRcvFwdTime($message->{dataset})
      }
      if(exists $i->{responses}){
        for my $j (@{$i->{responses}}){
          $this->GetRcvFwdTime($j);
          if(exists $j->{dataset}){ $this->GetRcvFwdTime($j->{dataset}) }
        }
      }
      if(exists $i->{CANCEL}) { $this->GetRcvFwdTime($i->{CANCEL}) }
    }
  }
  sub GetRcvFwdTime{
    my($this, $h) = @_;
    my $pdvs = $h->{pdv_list};
    my $index;
    if($h->{trace_file} =~ /from_data$/){
      $index = $this->{TimeLineIndex}->{left};
    } elsif($h->{trace_file} =~ /to_data$/){
      $index = $this->{TimeLineIndex}->{right};
    }
    my $start_offset = $pdvs->[0]->{offset};
    my $end_offset = $pdvs->[$#{$pdvs}]->{offset} +
      $pdvs->[$#{$pdvs}]->{length} - 1;
    $h->{first_byte_at} = $start_offset;
    $h->{last_byte_at} = $end_offset;
    my($first_byte_in, $first_byte_out) = 
     $this->FindRcvFwdTime($index, $h->{first_byte_at});
    my($last_byte_in, $last_byte_out) = 
     $this->FindRcvFwdTime($index, $h->{last_byte_at});
    $h->{entered_proxy} = $first_byte_in;
    $h->{cleared_proxy} = $last_byte_out;
  }
  sub FindRcvFwdTime{
    my($this, $time_line_index, $offset) = @_;
    my($rcv_time, $fwd_time);
    for my $i (@$time_line_index) {
      if($i->[0] >= $offset){
        if(defined $i->[1]) { 
          unless(defined $rcv_time) { $rcv_time = $i->[1] }
        }
        if(defined $i->[2]) { 
          unless(defined $fwd_time) { $fwd_time = $i->[2] }
        }
        if(defined $rcv_time && defined  $fwd_time){
          return $rcv_time, $fwd_time;
        }
      }
    }
    print STDERR "no entry in time line\n";
    return undef;
  }
}
1;
