#!/usr/bin/perl -w
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use Dispatch::LineReader;
use DicomProxyAnalysis::AssocDisplay;
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
  package DicomProxyAnalysis::Application;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Dicom Proxy Analysis Application";
    bless $this, $class;
    $this->{w} = 1024;
    $this->{h} = 700;
    $this->{RoutesBelow}->{ExpertModeChanged} = 1;
    Posda::HttpApp::Controller->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    DicomProxyAnalysis::Application::Content->new(
        $this->{session}, $this->child_path("Content"));
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
    $this->SetInitialExpertAndDebug;
    $this->ReOpenFile();
    if(exists $main::HTTP_APP_CONFIG->{BadJson}){
      $this->{BadConfigFiles} = $main::HTTP_APP_CONFIG->{BadJson};
    }
    my $session = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
    $session->{Privileges}->{capability}->{CanDebug} = 1;
    return $this;
  }
  sub BadConfigReport{
    my($this, $http, $dyn) = @_;
    for my $i (keys %{$this->{BadConfigFiles}}){
      $http->queue(
        "<tr><td>$i</td><td>$this->{BadConfigFiles}->{$i}</td></tr>");
    }
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
    if($this->{BadConfigFiles}){
      return $this->RefreshEngine($http, $dyn, $bad_config);
    }
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
  package DicomProxyAnalysis::Application::Content;
  use Time::HiRes qw( gettimeofday tv_interval );
  use File::Path qw (remove_tree);
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    $this->{env} = $main::HTTP_APP_CONFIG->{config}->{Environment};
    $this->{seq} = 1;
    bless $this, $class;
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    my $root_dir = $this->{env}->{AnalysisRootDir};
    unless(exists $this->{sessions}){ $this->{sessions} = {} }
    opendir SESSIONS, $root_dir or die "can't opendir $this->{sessions}";
    session:
    while(my $sub = readdir(SESSIONS)){
      unless(-d "$root_dir/$sub") { next session }
      unless(-f "$root_dir/$sub/AnalysisInfo") { next session }
      $this->InitializeSession("$root_dir/$sub");
    }
    closedir SESSIONS;
    unless(defined $this->{SelectedSession}){
      return $this->SessionSelection($http, $dyn);
    }
    $this->ShowSelectedSession($http, $dyn);
  }
  sub InitializeSession{
    my($this, $dir) = @_;
    open my $fh, "<$dir/AnalysisInfo" or die "can't open $dir/AnalysisInfo";
    my $session = {};
    while(my $line = <$fh>){
      if($line =~ /^(\w+): (.*)$/){
        my $key = $1;
        my $value = $2;
        $session->{$key} = $value;
      } elsif($line =~ /^\s*(\d+)\s*$/){
        $session->{assoc}->{$1} = 1;
      }
    }
    close $fh;
    $this->{Sessions}->{$dir} = $session;
  }
  sub SessionSelection{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, 
      '<table border><tr><th colspan="5">Analyzed Proxy Sessions' .
      '</th></tr>' .
      '<tr><th>At</th><th>Comment</th><th>User</th><th>Num Assoc</th></tr>'.
      '<?dyn="SessionRows"?></table>');
  }
  sub Deselect{
    my($this, $http, $dyn) = @_;
    delete $this->{SelectedSession};
    $this->AutoRefresh;
  }
  sub SessionRows{
    my($this, $http, $dyn) = @_;
    for my $i (
      sort 
      { $this->{Sessions}->{$a}->{At} cmp $this->{Sessions}->{$b}->{At} }
      keys %{$this->{Sessions}}
    ){
      my $sinfo = $this->{Sessions}->{$i};
      my $num_assoc = scalar keys %{$this->{Sessions}->{$i}->{assoc}};
      $dyn->{index} = $i;
      $this->RefreshEngine($http, $dyn,
        "<tr><td>$sinfo->{At}</td><td>$sinfo->{Comment}</td>" .
        "<td>$sinfo->{User}</td><td>$num_assoc</td><td>" .
        '<?dyn="Button" op="SelectSession" caption="select"?>' .
        '<?dyn="Button" op="DeleteSession" caption="delete"?>' .
        '</td></tr>');
    }
  }
  sub SelectSession{
    my($this, $http, $dyn) = @_;
    $this->{SelectedSession} = $dyn->{index};
    $this->AutoRefresh;
  }
  sub DeleteSession{
    my($this, $http, $dyn) = @_;
    delete $this->{Sessions}->{$dyn->{index}};
    remove_tree($dyn->{index});
    $this->AutoRefresh;
  }
  sub ShowSelectedSession{
    my($this, $http, $dyn) = @_;
    my $sinfo = $this->{Sessions}->{$this->{SelectedSession}};
    unless(defined $sinfo->{AssocInfo}){
      $this->ParseAssocInfo($sinfo);
    }
    $dyn->{sinfo} = $sinfo;
    $this->RefreshEngine($http, $dyn, 
      '<table><tr><th colspan=2>Proxy Session ' .
      '<?dyn="Button" caption="deselect" op="Deselect"?>' .
      '</th></tr>' .
      '<tr><td align="right">At:</td><td align="left">' .
      $sinfo->{At}. '</td></tr>' .
      '<tr><td align="right">Comment:</td>' .
      '<td align="left">' . $sinfo->{Comment}. '</td></tr>' .
      '<tr><td align="right">User:</td>' .
      '<td align="left">' . $sinfo->{User} . '</td></tr>' .
      '</table>');
    $this->RefreshEngine($http, $dyn,
      '<table border><tr><th colspan="7">Associations</th></tr>' .
      '<tr><th>At</th><th>For</th><th>From</th><th>To</th><th>Sent</th>' .
      '<th>Received</th><th>Op</th></tr>' .
      '<?dyn="AssocRows"?>' .
      '</table>');
  }
  sub AssocRows{
    my($this, $http, $dyn) = @_;
    my $sinfo = $dyn->{sinfo};
    for my $i (
      sort
      {
        $sinfo->{AssocInfo}->{$a}->{connection_time_text} cmp
        $sinfo->{AssocInfo}->{$b}->{connection_time_text}
      }
      keys %{$sinfo->{AssocInfo}}
    ){
      my $ainfo = $sinfo->{AssocInfo}->{$i};
      $this->RefreshEngine($http, { index => $i },
        "<tr><td>$ainfo->{connection_time_text}</td>" .
        "<td>$ainfo->{elapsed}</td><td>$ainfo->{from} " .
        "($ainfo->{server_port})</td><td>$ainfo->{destination_host}:" .
        "$ainfo->{destination_port} ($ainfo->{destination_name})</td>" .
        "<td>$ainfo->{from_received}</td><td>$ainfo->{to_received}</td>" .
        '<td><?dyn="Button" op="AssocInfo" caption="Info"?></td>' .
        "</tr>");
    }
  }
  sub ParseAssocInfo{
    my($this, $sinfo) = @_;
    session:
    for my $a (keys %{$sinfo->{assoc}}){
      my $fn = "$this->{SelectedSession}/$a/ProxySession.info";
      unless(-f $fn) { next session }
      open SESS, "<$fn" or die "can't open $fn";
      while(my $line = <SESS>){
        if($line =~ /^(.*): (.*)$/){
          my $key = $1;
          my $value = $2;
          $sinfo->{AssocInfo}->{$a}->{$key} = $value;
        }
      }
      close SESS;
    }
  }
  sub AssocInfo{
    my($this, $http, $dyn) = @_;
    my $dir = "$this->{SelectedSession}/$dyn->{index}";
    my $child_name = $this->child_path("AssocInfo" . "_$this->{seq}");
    $this->{seq} += 1;
    my $sel_obj = $this->child($child_name);
    if($sel_obj) {
      print STDERR "??? DirectorySelector already exists ???";
    } else {
      $sel_obj = DicomProxyAnalysis::AssocDisplay->new($this->{session},
        $child_name, $dir);
    }
    $sel_obj->ReOpenFile;
  }
  sub DESTROY{
    my($this) = @_;
    if($this->{temp_dir} && -d $this->{temp_dir}){
      remove_tree($this->{temp_dir});
    }
  }
}
1;
