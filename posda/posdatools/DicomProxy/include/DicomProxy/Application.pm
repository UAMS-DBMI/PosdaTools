#!/usr/bin/perl -w
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use Dispatch::LineReader;
use DicomProxy::Proxy;
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
</table>
<table border="1"><tr><td>
<?dyn="iframe" height="200" width="500" child_path="Content"?>
</td><td>
<?dyn="iframe" height="200" width="500" child_path="InProcess"?>
</td></tr>
</table>
<?dyn="iframe" height="400" width="1000" child_path="Completed"?>
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
  package DicomProxy::Application;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Dicom Transparent Proxy Application";
    bless $this, $class;
    $this->{w} = 850;
    $this->{h} = 500;
    $this->{RoutesBelow}->{ExpertModeChanged} = 1;
    $this->{RoutesBelow}->{RefreshActiveProxies} = 1;
    $this->{RoutesBelow}->{ProxyInstances} = 1;
    $this->{RoutesBelow}->{FetchFinishedSessions} = 1;
    $this->{RoutesBelow}->{GetAnalysisRootDir} = 1;
    $this->{RoutesBelow}->{RefreshFinishedSessions} = 1;
    Posda::HttpApp::Controller->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    DicomProxy::Application::Content->new(
        $this->{session}, $this->child_path("Content"));
    DicomProxy::Application::InProcess->new(
        $this->{session}, $this->child_path("InProcess"));
    DicomProxy::Application::Completed->new(
        $this->{session}, $this->child_path("Completed"));
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
  package DicomProxy::Application::Content;
  use Time::HiRes qw( gettimeofday tv_interval );
  use File::Path qw (remove_tree);
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    $this->{env} = $main::HTTP_APP_CONFIG->{config}->{Environment};
    $this->{Exports}->{ProxyInstances} = 1;
    $this->{Exports}->{FetchFinishedSessions} = 1;
    $this->{Exports}->{GetAnalysisRootDir} = 1;
    $this->{Imports}->{RefreshActiveProxies} = 1;
    $this->{Imports}->{RefreshFinishedSessions} = 1;
    bless $this, $class;
    $this->{used_ports} = {};
    $this->{AvailablePorts} = {};
    for my $p (@{$this->{env}->{IncomingSocketPool}}){
      $this->{AvailablePorts}->{$p} = 1;
    }
    $this->AutoRefresh;
    my $temp_dir = "$this->{env}->{ConnectionRootDir}/$this->{session}";
    if(-d $temp_dir){
      print STDERR "!!!!!!!!!!!!\nSession dir already exists\n!!!!!!!!!!!\n";
    } else {
      unless(mkdir $temp_dir){
         die "Can't mkdir $temp_dir";
      }
    }
    $this->{temp_dir} = $temp_dir;
    $this->{ProxyId} = 0;
    $this->{sequence} = 1;
    return $this;
  }
  sub FetchFinishedSessions{
    my($this) = @_;
    return $this->{FinishedSessions};
  }
  sub GetAnalysisRootDir{
    my($this) = @_;
    return $this->{env}->{AnalysisRootDir};
  }
  sub ProxyInstances{
    my($this, $http, $dyn) = @_;
    return $this->{ProxyInstances};
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    if(scalar(keys %{$this->{AvailablePorts}}) > 0){
      $this->NewProxyMenu($http, $dyn);
    }
    $this->ExistingProxies($http, $dyn);
#    $this->ExistingProxyInstances($http, $dyn);
#    $this->FinishedSessions($http, $dyn);
#    $this->AnalyzedSessions($http, $dyn);
  }
  sub Error{
    my($this, $message) = @_;
    push(@{$this->{Errors}}, $message);
  }
  sub NewProxyMenu{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" caption="Start" op="StartProxy"?> ' .
      'a proxy on port: <?dyn="ProxyPortSelection"?> ' .
      'to destination <?dyn="DestinationSelection"?>');
  }
  sub ProxyPortSelection{
    my($this, $http, $dyn) = @_;
    my @ports = sort keys %{$this->{AvailablePorts}};
    $this->RefreshEngine($http, $dyn, 
      '<?dyn="SelectNsByValue" op="SetProxyPort"?>');
    unless(
      $this->{SelectedPort} &&
      exists $this->{AvailablePorts}->{$this->{SelectedPort}}
    ){ $this->{SelectedPort} = $ports[0] }
    for my $p (@ports){
      $http->queue("<option value=\"$p\"" .
        ($p == $this->{SelectedPort} ? " selected" : "" ) .
      ">$p</option>");
    }
    $http->queue("</select>");
  }
  sub DestinationSelection{
    my($this, $http, $dyn) = @_;
    my @destinations = sort keys %{$this->{env}->{ProxyDestinations}};
    $this->RefreshEngine($http, $dyn, 
      '<?dyn="SelectNsByValue" op="SetProxyDestination"?>');
    unless(
      $this->{SelectedDestination} &&
      exists $this->{env}->{ProxyDestinations}->{$this->{SelectedDestination}}
    ){ $this->{SelectedDestination} = $destinations[0] }
    for my $d (@destinations){
      $http->queue("<option value=\"$d\"" .
        ($d eq $this->{SelectedDestination} ? " selected" : "" ) .
      ">$d</option>");
    }
    $http->queue("</select>");
  }
  sub SetProxyPort{
    my($this, $http, $dyn) = @_;
    $this->{SelectedPort} = $dyn->{value};
  }
  sub SetProxyDestination{
    my($this, $http, $dyn) = @_;
    $this->{SelectedDestination} = $dyn->{value};
  }
  sub ExistingProxies{
    my($this, $http, $dyn) = @_;
    unless(scalar(keys %{$this->{ExistingProxies}}) > 0){ return }
    $http->queue("<hr>Existing Proxies<br>" .
      "<table border><tr><th>Port</th><th>Name</th><th># Conn</th>" .
      "<th>Dest IP addr</th><th>Dest prot</th></tr>");
    for my $i (sort keys %{$this->{ExistingProxies}}){
      my $p = $this->{ExistingProxies}->{$i};
      $dyn->{index} = $i;
      $this->RefreshEngine($http, $dyn, "<tr>" .
        "<td>$i</td><td>$p->{destination_name}</td>" .
        "<td>$p->{conn_count}</td><td>$p->{destination_host}</td>" .
        "<td>$p->{destination_port}</td>");
      if($p->{conn_count} <= 0){
        $this->RefreshEngine($http, $dyn,
        '<td><?dyn="Button" op="KillProxy" caption="kill"?></td>');
      }
      $http->queue( "</tr>");
    }
    $http->queue("</table>");
  }
  sub KillProxy{
    my($this, $http, $dyn) = @_;
    my $proxy_id = $dyn->{index};
    my $proxy = $this->{ExistingProxies}->{$proxy_id};
    delete $this->{ExistingProxies}->{$proxy_id};
    close $proxy->{socket};
    $this->{AvailablePorts}->{$proxy_id} = 1;
    $this->AutoRefresh;
  }
  sub StartProxy{
    my($this, $http, $dyn) = @_;
    my $port = $this->{SelectedPort};
    if(exists $this->{ExistingProxies}->{$port}) { return }
    my $destination = $this->{SelectedDestination};
    my $server_sock = IO::Socket::INET->new(
       Listen => 1024,
       LocalPort => $port,
       Proto => 'tcp',
       Blocking => 0,
       ReuseAddr => 1,
    );
    unless($server_sock) {
      return $this->Error("Can't start listener on $port");
    };
    Dispatch::Select::Socket->new($this->HandleConnection($port),
      $server_sock)->Add("reader");
    delete $this->{AvailablePorts}->{$port};
    $this->{ExistingProxies}->{$port} = {
      socket => $server_sock,
      port => $port,
      conn_count => 0,
      destination_name => $destination,
      destination_host => 
        $this->{env}->{ProxyDestinations}->{$destination}->{host},
      destination_port => 
        $this->{env}->{ProxyDestinations}->{$destination}->{port},
    };
    $this->AutoRefresh;
    ##$this->RouteAbove("RefreshActiveProxies");
  }
  sub HandleConnection{
    my($this, $port) = @_;
    my $sub = sub {
      my($disp, $server_sock) = @_;
      my $new_sock = $server_sock->accept;
      unless($new_sock) {
        return $this->Error(
          "Can't accept new socket from server on port $port: $!");
      }
      unless(exists $this->{ExistingProxies}->{$port}){
        print STDERR "Connection to Disconnected Proxy on port $port\n";
        $disp->Remove;
        return;
      }
      my $proxy = $this->{ExistingProxies}->{$port};
      my $to_sock = IO::Socket::INET->new(
        PeerAddr => $proxy->{destination_host},
        PeerPort => $proxy->{destination_port},
        Proto => 'tcp',
        Timeout => 1,
        Blocking => 0,
      );
      if($to_sock) {
        $this->StartAProxyInstance($port, $new_sock, $to_sock);
      } else {
        $this->Error("Proxy failed for port $port: $!");
      }
      #$this->AutoRefresh;
      $this->RouteAbove("RefreshActiveProxies");
    };
    return $sub;
  }
  sub StartAProxyInstance{
    my($this, $port, $from_sock, $to_sock) = @_;
    my $proxy = $this->{ExistingProxies}->{$port};
    $proxy->{conn_count} += 1;
    $this->{ProxyId} += 1;
    my $proxy_id = $this->{ProxyId};
    my $proxy_dir = "$this->{temp_dir}/$proxy_id";
    $this->{ProxyInstances}->{$proxy_id} = DicomProxy::Proxy->new_tracer(
      $proxy_id, $this->{ExistingProxies}->{$port}, 
      $from_sock, $to_sock, $proxy_dir, 16384, 65536, $this->ProxyChange
    );
   $this->AutoRefresh;
  }
  sub ProxyChange{
    my($this) = @_;
    my $sub = sub { 
      my($id) = @_;
      my $proxy = $this->{ProxyInstances}->{$id};
      if($proxy->{status} eq "Finished"){
        my $server_port = $proxy->{server_port};
        if(exists $this->{ExistingProxies}->{$server_port}) {
          $this->{ExistingProxies}->{$server_port}->{conn_count} -= 1;
        }
        delete $this->{ProxyInstances}->{$id};
        $this->{FinishedSessions}->{$id} = $proxy;
        $this->RouteAbove("RefreshFinishedSessions");
        $this->AutoRefresh;
      }
      $this->RouteAbove("RefreshActiveProxies");
    };
    return $sub;
  }
  sub DESTROY{
    my($this) = @_;
    if($this->{temp_dir} && -d $this->{temp_dir}){
      remove_tree($this->{temp_dir});
    }
  }
}
{
  package DicomProxy::Application::InProcess;
  use Time::HiRes qw( gettimeofday tv_interval );
  use File::Path qw (remove_tree);
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    $this->{ImportsFromAbove}->{ProxyInstances} = 1;
    $this->{Exports}->{RefreshActiveProxies} = 1;
    return bless $this, $class;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->ExistingProxyInstances($http, $dyn);
  }
  sub RefreshActiveProxies{
    my($this, $http, $dyn) = @_;
    $this->AutoRefresh;
  }
  sub ExistingProxyInstances{
    my($this, $http, $dyn) = @_;
    my $ProxyInstances = $this->RouteAbove("ProxyInstances");
    if($ProxyInstances eq "") { $ProxyInstances = {} }
    unless(scalar(keys %{$ProxyInstances}) > 0){ return };
    $http->queue("Current Proxied Connections<br><hr>" .
      "<table border><tr><th>From</th><th>Elapsed</th>" .
      "<th>Destination</th><th>Sent</th>" .
      "<th>Rcv</th></tr>");
    for my $i (sort keys %$ProxyInstances){
      my $pi = $ProxyInstances->{$i};
      my $elapsed = tv_interval($pi->{connection_time});
      my $bytes_sent;
      if(exists $pi->{left}) { $bytes_sent = $pi->{left}->{bytes_written} }
      my $bytes_rcvd;
      if(exists $pi->{right}) { $bytes_rcvd = $pi->{right}->{bytes_written} }
      $this->RefreshEngine($http, $dyn, "<tr>" .
        "<td>$pi->{from_addr}</td>" .
        "<td>$elapsed</td>" .
        "<td>$pi->{destination_name}</td>" .
        "<td>$bytes_sent</td>" .
        "<td>$bytes_rcvd</td>" .
        "</tr>");
    }
    $http->queue("</table>");
  }
}
{
  package DicomProxy::Application::Completed;
  use Time::HiRes qw( gettimeofday tv_interval );
  use File::Path qw (remove_tree);
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    $this->{ImportsFromAbove}->{FetchFinishedSessions} = 1;
    $this->{ImportsFromAbove}->{GetAnalysisRootDir} = 1;
    $this->{Exports}->{RefreshFinishedSessions} = 1;
    return bless $this, $class;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->FinishedSessions($http, $dyn);
  }
  sub RefreshFinishedSessions{
    my($this) = @_;
    $this->AutoRefresh;
  }
  sub FinishedSessions{
    my($this, $http, $dyn) = @_;
    if($this->{AnalysisSelected}){
      return $this->SelectionForm($http, $dyn);
    }
    if($this->{AnalysisInProgress}){
      return $this->AnalysisReport($http, $dyn);
    }
    my $FinishedSessions = $this->RouteAbove("FetchFinishedSessions");
    if($FinishedSessions eq "") { $FinishedSessions = {} }
    unless(scalar(keys %{$FinishedSessions}) > 0){ return };
    $this->RefreshEngine($http, $dyn, 
      "<hr>Completed Proxied Connections<br>" .
      '<table border><tr><th rowspan="2">At</th>' .
      '<th rowspan="2">From</th>' .
      '<th rowspan="2">To</th>' .
      '<th rowspan="2">Elapsed</th>' .
      '<th colspan="2">Left</th>' .
      '<th colspan="2">Right</th>' .
      '<th colspan="2" rowspan="2">' .
      '<?dyn="Button" op="AnalyzeSessions" caption="Analyze"?>' .
      '<?dyn="Button" op="AnalyzeAllSessions" caption="AnalyzeAll"?>' .
      '<?dyn="Button" op="DeleteAllSessions" caption="DeleteAll"?>' .
      '</th></tr><tr>' .
      '<th>read</th><th>write</th>' .
      '<th>read</th><th>write</th>' .
      "</tr>");
    for my $i (sort keys %{$FinishedSessions}){
      my $pi = $FinishedSessions->{$i};
      $dyn->{index} = $i;
      unless(exists $this->{SelectedSession}->{$i}){
        $this->{SelectedSession}->{$i} = "not_checked";
      }
      $this->RefreshEngine($http, $dyn, "<tr>" .
        "<td>$pi->{connection_time_text}</td>" .
        "<td>$pi->{from_addr} (via $pi->{server_port})</td>" .
        "<td>$pi->{destination_name} ($pi->{destination_host}:" .
        "$pi->{destination_port})</td>" .
        "<td>$pi->{elapsed}->{proxy}</td>" .
        "<td>$pi->{bytes_read}->{left}</td>" .
        "<td>$pi->{bytes_written}->{left}</td>" .
        "<td>$pi->{bytes_read}->{right}</td>" .
        "<td>$pi->{bytes_written}->{right}</td>" .
        '<td><?dyn="CheckBoxNs" name="SelectedSession"?>' .
        '<td><?dyn="Button" op="DeleteProxyDir" caption="delete"?></td>' .
        "</tr>");
    }
    $http->queue("</table>");
  }
  sub DeleteAllSessions{
    my($this, $http, $dyn) = @_;
    my $FinishedSessions = $this->RouteAbove("FetchFinishedSessions");
    if($FinishedSessions eq "") { $FinishedSessions = {} }
    unless(scalar(keys %{$FinishedSessions}) > 0){ return };
    for my $i (keys %$FinishedSessions){
      my $p = $FinishedSessions->{$i};
      delete $FinishedSessions->{$i};
      if(-d $p->{dir}){
        remove_tree($p->{dir});
      }
    }
    $this->AutoRefresh;
  }
  sub DeleteProxyDir{
    my($this, $http, $dyn) = @_;
    my $i = $dyn->{index};
    my $FinishedSessions = $this->RouteAbove("FetchFinishedSessions");
    if($FinishedSessions eq "") { $FinishedSessions = {} }
    unless(scalar(keys %{$FinishedSessions}) > 0){ return };
    my $p = $FinishedSessions->{$i};
    delete $FinishedSessions->{$i};
    if(-d $p->{dir}){
      remove_tree($p->{dir});
    }
    $this->AutoRefresh;
  }
  sub AnalyzeAllSessions{
    my($this, $http, $dyn) = @_;
    my $FinishedSessions = $this->RouteAbove("FetchFinishedSessions");
    if($FinishedSessions eq "") { $FinishedSessions = {} }
    for my $i (keys %$FinishedSessions){
      $this->{SelectedSession}->{$i} = "checked";
    }
    $this->{AnalysisSelected} = 1;
    $this->AutoRefresh;
  }
  sub AnalyzeSessions{
    my($this, $http, $dyn) = @_;
    $this->{AnalysisSelected} = 1;
    $this->AutoRefresh;
  }
  sub SelectionForm{
    my($this, $http, $dyn) = @_;
    $this->{Comment} = "Insert Comment here";
    delete $dyn->{index};
    $this->RefreshEngine($http, $dyn,
      "<hr>Analysis Selection:<ul>" .
      '<?dyn="SelectedSessions"?>' .
      "</ul>" .
      'Comment: <?dyn="InputChangeNoReload" field="Comment"?><br>' .
      '<?dyn="Button" op="DoAnalysis" caption="Analyze"?>' .
      '<?dyn="Button" op="AbortAnalysis" caption="Cancel"?>'
    );
  }
  sub SelectedSessions{
    my($this, $http, $dyn) = @_;
    my @selected;
    for my $i (keys %{$this->{SelectedSession}}){
      if($this->{SelectedSession}->{$i} eq "checked"){ push @selected, $i }
    }
    my $count = @selected;
    $http->queue("$count sessions selected<br>");
  }
  sub AbortAnalysis{
    my($this, $http, $dyn) = @_;
    delete $this->{AnalysisSelected};
    $this->AutoRefresh;
  }
  sub DoAnalysis{
    my($this, $http, $dyn) = @_;
    my $comment = $this->{Comment};
    my $user = $this->get_user;
    my $time = $this->now;
    my $root_dir = $this->RouteAbove("GetAnalysisRootDir");
    my $new_dir_name = "$root_dir/" .
      "$this->{session}-$this->{sequence}";
    $this->{sequence} += 1;
    unless(-d $new_dir_name) {
      unless(mkdir $new_dir_name){
        die "can't mkdir $new_dir_name";
      }
    }
    open INFO, ">$new_dir_name/AnalysisInfo" or
      die "can't open $new_dir_name/AnalysisInfo";
    print INFO "At: $time\n";
    print INFO "User: $user\n";
    print INFO "Comment: $comment\n";
    print INFO "Sessions:\n";
    my @commands;
    my $FinishedSessions = $this->RouteAbove("FetchFinishedSessions");
    if($FinishedSessions eq "") { $FinishedSessions = {} }
    session:
    for my $i (sort {$a <=> $b } keys %{$this->{SelectedSession}}){
      unless(-d $FinishedSessions->{$i}->{dir}){
        delete $this->{SelectedSession}->{$i};
        next session;
      }
      if($this->{SelectedSession}->{$i} eq "checked"){
        print INFO "\t$i\n";
        my $sub_dir = "$new_dir_name/$i";
        unless(mkdir $sub_dir) {
          die "can't mkdir $sub_dir";
        }
        push @commands, "CloneSessionInfo.pl \"" . 
          $FinishedSessions->{$i}->{dir} .
          "\" \"$sub_dir\"";
        push @commands, "BuildProxyForwardTimeLine.pl \"$sub_dir\"";
        push @commands, "TransmitTimesByBytes.pl \"$sub_dir\"";
        push @commands, "ProxyPduAnalysis.pl \"$sub_dir\"";
        push @commands, "ExtractAssocNegot.pl \"$sub_dir\"";
        push @commands, "ExtractMessageInfo.pl \"$sub_dir\"";
      }
    }
    close INFO;
    $this->{AnalysisCommands} = \@commands;
    delete $this->{AnalysisSelected};
    $this->{AnalysisInProgress} = 1;;
    $this->RunAnalysisCommands;
  }
  sub RunAnalysisCommands{
    my($this) = @_;
    if(scalar @{$this->{AnalysisCommands}} == 0){
      delete $this->{AnalysisInProgress};
      $this->AutoRefresh;
      return;
    }
    my $command = shift(@{$this->{AnalysisCommands}});
    open my $fh, "$command|";
    Dispatch::Select::Socket->new($this->CommandResult($command),
      $fh)->Add("reader");
  }
  sub CommandResult{
    my($this, $command) = @_;
    my $text = "";
    my $sub = sub {
      my($disp, $sock) = @_;
      my $count = sysread($sock, $text, 1024, length($text));
      unless(defined $count) {
        print STDERR "Error ($!) on command: $command\n";
        $count = 0;
      }
      if($count == 0){
        print STDERR "Command: $command\n" .
        "Result: \"$text\"\n";
        $disp->Remove;
        close $sock;
        $this->RunAnalysisCommands;
      }
      $this->AutoRefresh;
    };
    return $sub;
  }
  sub AnalysisReport{
    my($this, $http, $dyn) = @_;
    my $command_count = scalar @{$this->{AnalysisCommands}};
    $http->queue("Commands remaining: $command_count");
  }
}
1;
