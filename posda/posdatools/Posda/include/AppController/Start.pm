#!/usr/bin/perl -w
#
use strict;
die "Obsolete!!! Do not use!!!";
use POSIX 'strftime';
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::Controller;
use Posda::HttpApp::DebugWindow;
use AppController::Login;
use AppController::ChildProcess;
use AppController::ManageChildProcess;
use AppController::CheckBOM;
use AppController::Password;
use AppController::AppTracker;
use JSON;
use Dispatch::LineReader;
use Debug;
my $dbg = sub {print @_};
{
  package AppController;
  use vars qw( %RunningApps @HarvestedApps );
}
{
  package AppController::Start;
  use vars qw( @ISA );
  @ISA = ("Posda::HttpApp::GenericMfWindow");
my $redirect = <<EOF;
  HTTP/1.0 201 Created
  Location: <?dyn="echo" field="url"?>
  Content-Type: text/html
  
  <!DOCTYPE html
  PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
  <html><head>
    <meta http-equiv="refresh" content="0; URL=<?dyn="echo" field="url"?>" />
     <script>
      CNTLrefresh=window.setTimeout(function(){window.location.href="<?dyn="echo" field="url"?>"},1000);
      </script>
  </head>\n<body>logged out OK, redirecting....
    <a href="<dyn="echo" field="url"?>"><?dyn="echo" field="url"?></a>
  </body></html>
EOF
  sub Shutdown{
    my($this, $http, $dyn) = @_;
    my $url = "http://$http->{header}->{host}/";
    $this->DeleteMySession;
    $this->RefreshEngine($http, {url => $url}, $redirect);
  }
##################################################################
# From here down, A GenericMfWindow
#   except has controller, not sub-controller (no parent)
#
  my $base_content = <<EOF;
  <table style="width:100%" summary="window header">
    <tr>
      <td valign="top" height="82">
      <?dyn="Logo"?>
      <img src="/ITCLogoWeb.jpg" height="81" width="152">
      </td>
      <td valign="top" align="left">
      <h2>ITC Tools Status page.</h2>
      <?dyn="iframe" height="35" width="100%" child_path="DateTime"?>
      </td>
      <td valign="top" align="right">
  <?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
  <?dyn="iframe" frameborder="0" child_path="WindowButtons"?>
      </td>
      <tr>
  </table>
  <?dyn="iframe" height="1024" width="100%" child_path="Content"?>
  <hr>
EOF
#  <?dyn="iframe" height="1024" width="100%" child_path="Content"?>
  sub new{
    my($class, $sess, $path_name) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path_name);
    $this->{RoutesBelow}->{GetSocketList} = 1;
    $this->{title} = $main::HTTP_APP_CONFIG->{config}->{Identity}->{HostName};
    #$this->{HTTP_APP_SINGLETON} = $main::HTTP_APP_SINGLETON;
    $this->{HTTP_APP_CONFIG} = $main::HTTP_APP_CONFIG;
    $this->{base_content} = $base_content;
    bless $this, $class;
    $this->{Exports}->{CacheCleared} = 1;
    $this->SetPrivileges({capability => {NewDebug => 0}});
    Posda::HttpApp::Controller->new($sess, $this->child_path("Controller"));
    AppController::Login->new($sess, 
      $this->child_path("WindowButtons"), "Close", 1);
    AppController::Start::DateTime->new(
      $this->{session},$this->child_path("DateTime")); 
    AppController::Start::Content->new(
      $this->{session},$this->child_path("Content")); 
    $this->StartRefreshTimer;
    $this->{RunningApps} = \%AppController::RunningApps;
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
    $this->{Capabilities} = $main::HTTP_APP_CONFIG->{config}->{Capabilities};
    my $session = $this->get_session;
    $session->{NoTimeOut} = 1;
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
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $this->{base_content});
  }
  sub StartRefreshTimer{
    my($this) = @_;
    my $count = 0;
    my $foo = sub {
      my($self) = @_;
        # print STDERR "Refresh Timer: called.\n";
      unless($this->{KillTimer}){
        # print STDERR "Refresh Timer: calling AutoRefresh.\n";
        $this->child("DateTime")->AutoRefresh;
        $count += 2;
        if($count > 5){
          $count = 0;
          $this->child("Content")->AutoRefresh;
        }
        $self->timer(2);
      }
    };
    my $timer = Dispatch::Select::Background->new($foo);
    $timer->timer(2);
    # print STDERR "StartRefreshTimer: Setup timer.\n";
  }
  sub CleanUp{
    my($this) = @_;
    $this->{KillTimer} = 1;
  }
  sub DESTROY{
    my($this) = @_;
    $this->delete_children();
  }
}
{
  package AppController::Start::DateTime;
  use vars qw( @ISA );
  @ISA = ("Posda::HttpApp::GenericIframe");
  sub Content{
    my($this, $http, $dyn) = @_;
    $http->queue(POSIX::strftime("%a %b %e %H:%M:%S %Y", localtime));
  }
}
{
  package AppController::Start::Content;
  use vars qw( @ISA );
  @ISA = ("Posda::HttpApp::GenericIframe");

  use Posda::Config 'Config';

  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe::new($class, $sess, $path);
    $this->{SocketPool} = Config('port_pool');
    $this->{Apps} = 
      $main::HTTP_APP_CONFIG->{config}->{Applications}->{Apps};
    $this->{RunningApps} = {};
    $this->{UsedSockets} = {};
    $this->{child_index} = 1;
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    if($this->get_user) {
      $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" op="Password" caption="Password Maintenance"?>'
      );
    }
    if($this->IsExpert){
      $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" op="CheckBOM" caption="Check Bill of Materials"?>' .
      '<?dyn="CacheCheck"?>'
      );
    }
    $this->RefreshEngine($http, $dyn,
      '<hr>Applications Available:<table>' .
      '<tr><th>Name</th><th>Description</th><th>Login</th>' .
      '<?dyn="AvailableApps"?>' .
      '</table>' .
      '<hr>Applications Pending:<ul><?dyn="PendingApps"?></ul>' .
      '<hr>Applications Running:<ul><?dyn="RunningApps"?></ul>' .
      '<hr>Applications Harvested:<ul><?dyn="HarvestedApps"?></ul>' .
      '<?dyn="Zombies"?>');
  };
  sub CheckBOM{
    my($this, $http, $dyn) = @_;
    my $child_name = $this->child_path("BOM");
    my $child_obj = $this->get_obj($child_name);
    unless($child_obj){
      $child_obj = AppController::CheckBOM->new(
        $this->{session}, $child_name, $child_obj);
    }
    $child_obj->ReOpenFile;
  }
  sub Password{
    my($this, $http, $dyn) = @_;
    my $child_name = $this->child_path("Password");
    my $child_obj = $this->get_obj($child_name);
    unless($child_obj){
      $child_obj = AppController::Password->new(
        $this->{session}, $child_name, $child_obj);
    }
    $child_obj->ReOpenFile;
  }
  sub AvailableApps{
    my($this, $http, $dyn) = @_;
    for my $i (
      sort {
        $this->{Apps}->{$a}->{sort_order} <=> $this->{Apps}->{$b}->{sort_order}
      }
      keys %{$this->{Apps}}
    ){
      $this->RefreshEngine($http, $dyn, 
        "<tr><td>$i</td><td>$this->{Apps}->{$i}->{Description}</td>" .
        '<td><?dyn="AppEntry" key="' . $i . '"?></td></tr>' . "\n");
    }
  }
  sub PendingApps{
    my($this, $http, $dyn) = @_;
    for my $i ($this->children_names){
      if($i =~ /manager$/) { next }
      if($i =~ /\/BOM$/) { next }
      if($i =~ /\/Password$/) { next }
      if($i =~ /\/ReceiverStatus$/) { next }
      $http->queue("<li>$i</li>\n");
    }
  }
  sub RunningApps{
    my($this, $http, $dyn) = @_;
    my @list = sort keys %AppController::RunningApps;
    unless($#list >= 0){ return }
    $http->queue("<table>");
    AppController::ChildProcess->Header($http, $dyn);
    for my $i (@list){
      my $obj = $AppController::RunningApps{$i};
      if($obj->can("Describe")){
        $obj->Describe($http, $dyn);
      }
      $this->ChildMenu($http, $dyn, $obj);
      $http->queue("</tr>");
    }
    $http->queue("</table>");
  }
  sub ChildMenu{
    my($this, $http, $dyn, $child) = @_;
    if($this->{session} eq $child->{session}){
      $this->OwnedApps($http, $dyn, $child);
    } else {
      $this->UnownedApps($http, $dyn, $child);
    }
  }
  sub OwnedApps{
    my($this, $http, $dyn, $child) = @_;
    $dyn->{param} = $child->{child_pid};
    $dyn->{index} = $child->{TryingSocket};
    $this->RefreshEngine($http, $dyn,
      '<td><small><?dyn="Button" op="Kill" caption="kill"?>' .
      '<td><small><?dyn="Button" op="Kill_nine" caption="really kill"?>' .
      '<?dyn="Button" op="Manage" caption="info"?>' .
      '</small></td>');
  }
  sub UnownedApps{
    my($this, $http, $dyn, $child) = @_;
    if($this->IsExpert){
      $this->OwnedApps($http, $dyn, $child);
    }
  }
  sub Kill{
    my($this, $http, $dyn) = @_;
    unless(exists $AppController::RunningApps{$dyn->{index}}){
      print STDERR "lost race in Kill\n";
      $this->AutoRefresh;
      return;
    }
    my $child = $AppController::RunningApps{$dyn->{index}};
    unless($child->{ChildRunning} = 1){
      print STDERR "Kill non-running child ($dyn->{index})? (not now)\n";
      $this->AutoRefresh;
      return;
    }
    $child->{KillIssued} = 1;
    my $count = kill 1, $dyn->{param};
    $this->AutoRefresh;
  }
  sub Kill_nine{
    my($this, $http, $dyn) = @_;
    unless(exists $AppController::RunningApps{$dyn->{index}}){
      print STDERR "lost race in Kill\n";
      $this->AutoRefresh;
      return;
    }
    my $child = $AppController::RunningApps{$dyn->{index}};
    unless($child->{ChildRunning} = 1){
      print STDERR "Kill non-running child ($dyn->{index})? (not now)\n";
      $this->AutoRefresh;
      return;
    }
    $child->{KillIssued} = 0;
    $child->{HardKillIssued} = 1;
    my $count = kill 9, $dyn->{param};
    $this->AutoRefresh;
  }
  sub Manage{
    my($this, $http, $dyn) = @_;
    unless(exists $AppController::RunningApps{$dyn->{index}}){
      print STDERR "lost race in ManageChild\n";
      $this->AutoRefresh;
      return;
    }
    my $child = $AppController::RunningApps{$dyn->{index}};
    my $child_name = "$child->{path}_manager";
    my $child_obj = $this->get_obj($child_name);
    unless($child_obj){
      $child_obj = AppController::ManageChildProcess->new(
        $this->{session}, $child_name, $child);
    }
    $child_obj->ReOpenFile;
  }
  sub HarvestedApps{
    my($this, $http, $dyn) = @_;
    unless($#AppController::HarvestedApps >= 0){ return }
    $http->queue("<table>");
    AppController::ChildProcess->Header($http, $dyn);
    for my $obj (@AppController::HarvestedApps){
      if($obj && $obj->can("Describe")){
        $obj->Describe($http, $dyn);
      }
      $this->HarvestedMenu($http, $dyn, $obj);
      $http->queue("</tr>");
    }
    $http->queue("</table>");
  }
  sub HarvestedMenu{
    my($this, $http, $dyn, $child) = @_;
    unless($this->IsExpert){ return }
    unless($child){
      $http->queue("<td><small>Undefined entry</small></td>");
      return;
    }
    $dyn->{param} = $child->{child_pid};
    $dyn->{index} = $child->{TryingSocket};
    $this->RefreshEngine($http, $dyn,
      '<td><small><?dyn="Button" op="DeleteHarvested" caption="del"?>' .
      '<?dyn="Button" op="HarvestedInfo" caption="info"?>' .
      '</small></td>');
  }
  sub DeleteHarvested{
    my($this, $http, $dyn) = @_;
    my $port = $dyn->{index};
    my $pid = $dyn->{param};
    my @harvested;
    while(my $item = shift @AppController::HarvestedApps){
      unless($item->{TryingSocket} == $port && $item->{child_pid} == $pid){
        push @harvested, $item;
      }
    }
    @AppController::HarvestedApps = @harvested;
    $this->AutoRefresh;
  }
  sub HarvestedInfo{
    my($this, $http, $dyn) = @_;
    my $port = $dyn->{index};
    my $pid = $dyn->{param};
    for my $child (@AppController::HarvestedApps){
      if($child->{TryingSocket} == $port && $child->{child_pid} == $pid){
        my $child_name = "$child->{path}_manager";
        my $child_obj = $this->get_obj($child_name);
        unless($child_obj){
          $child_obj = AppController::ManageChildProcess->new(
            $this->{session}, $child_name, $child);
        }
        $child_obj->ReOpenFile;
        return;
      }
    }
  }
  sub Zombies{
    my($this, $http, $dyn) = @_;
    unless($this->IsExpert){ return }
    my @zombies;
    if(open my $fh, "-|", "ps axo pid,ppid,args |grep App|grep -v grep"){
      line:
      while(my $line = <$fh>){
        chomp $line;
        $line =~ s/^\s*//;
        unless($line =~/^\s*(\d+)\s*(\d+)\s*(\d+)\s*AppCont/){ next line }
        my $pid = $1;
        my $ppid = $2;
        my $port = $3;
        if($ppid == 1){
          my $mine = 0;
          for my $i (@{$this->{SocketPool}}){ if ($i eq $port) {$mine = 1 }}
          if($mine) { push @zombies, $line }
        }
      }
    }
    if($#zombies >= 0){
      $http->queue("<hr><pre>Zombies:\n");
      for my $i (@zombies) { $http->queue("$i\n") }
      $http->queue("<pre><hr>");
    }
  }
  sub AppEntry{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, {
       caption => "launch",
       op => "StartChildProcess",
       param => $dyn->{key},
     }, 
     '<?dyn="Button"?>')
  }
  sub StartChildProcess{
    my($this, $http, $dyn) = @_;
    my $host = $http->{header}->{host};
    my $child_path = $this->child_path("child_$this->{child_index}");
    $this->{child_index} += 1;
    AppController::ChildProcess->new($this->{session}, $child_path, 
      $this->{Apps}->{$dyn->{param}}, $host);
    $this->AutoRefresh;
  }
  sub GetSocketList{
    my($this) = @_;
    return $this->{SocketPool};
  }
  sub CacheCheck{
    my($this, $http, $dyn) = @_;
    unless($this->{ClearingCache}){
      if(
        exists($main::HTTP_APP_CONFIG->{config}->{Environment}->{CacheToClear})
        &&
        -d $main::HTTP_APP_CONFIG->{config}->{Environment}->{CacheToClear}
      ){
        my $cache_dir =
          $main::HTTP_APP_CONFIG->{config}->{Environment}->{CacheToClear};
        my @lines = `df $cache_dir`;
        chomp $lines[1];
        my ($fs, $blocks, $used, $avail, $percent, $mount) = 
          split(/\s+/, $lines[1]);
        $http->queue("&nbsp;<small>Cache usage: $percent</small>&nbsp;");
        $this->RefreshEngine($http, $dyn, 
          '<?dyn="Button" op="ClearCache" caption="Clear Cache"?>');
        return;
      }
    }
    $this->RefreshEngine($http, $dyn,
      '&nbsp;&nbsp;Cache is being cleared&nbsp;&nbsp;'.
      '<?dyn="CacheStatus"?>'
    );
  }
  sub ClearCache{
    my($this, $http, $dyn) = @_;
    $this->{ClearingCache} = 1;
    $this->{CacheClearingStatus} = [];
    my $cache_dir =
      $main::HTTP_APP_CONFIG->{config}->{Environment}->{CacheToClear};
    unless(opendir DIR, $cache_dir){
      print STDERR "Can't opendir $cache_dir";
      $this->{ClearingCache} = 0;
      return;
    }
    my $cmd = "echo Clearing Cache;";
    file:
    while (my $file = readdir DIR){
      if($file =~ /^\./) { next file }
      unless(-d "$cache_dir/$file") { next file }
      my $next_cmd .= "rm -rf \"$cache_dir/$file\"";
      $cmd .= "echo 'command: $next_cmd';$next_cmd;echo done;"
    }
    Dispatch::LineReader->new_cmd($cmd, 
      $this->LineIgnore, $this->CreateNotifierClosure("CacheCleared"));
    $this->AutoRefresh;
  }
  sub LineIgnore{
    my($this) = @_;
    my $sub = sub {
      my($line) = @_;
      push(@{$this->{CacheClearingStatus}}, $line);
      $this->AutoRefresh;
    };
    return $sub;
  }
  sub CacheCleared{
    my($this) = @_;
    print "CacheCleared\n";
    $this->{ClearingCache} = 0;
    $this->AutoRefresh;
  }
  sub CacheStatus{
    my($this, $http, $dyn) = @_;
    unless($this->{ClearingCache}) { return }
    $http->queue("<hr>Cache Status:<ul>");
    for my $i (@{$this->{CacheClearingStatus}}){
      $http->queue("<li>$i</li>");
    }
    $http->queue("</ul><hr>");
  }
}
1;
