#!/usr/bin/perl -w
#
use strict;
use POSIX 'strftime';
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::Controller;
use Posda::HttpApp::WindowButtons;
use Posda::BgColor;
use PipeChildren;
use IO::Socket::INET;
use Debug;
my $dbg = sub { print @_ };
package AppController::ChildProcess;
use Fcntl;
use vars qw( @ISA );
@ISA = ("Posda::HttpApp::GenericWindow");
sub new{
  my($class, $sess, $path, $process_desc, $host) = @_;
  my $this = Posda::HttpApp::GenericWindow->new($sess, $path);
  $this->{title} = "SubProcessHandler";
  $this->{color} = Posda::BgColor::GetUnusedColor;
  $this->{Status} = "Not Logged In";
  $this->{AuthUser} = "";
  $this->{RealUser} = "";
  $this->{ImportsFromAbove}->{GetSocketList} = 1;
  bless $this, $class;
  $this->{host} = $host;
  if($this->{host} =~ /^(.*):(.*)$/){
    $this->{host} = $1;
    $this->{parent_port} = $2;
  }
  $this->{process_desc} = $process_desc;
  $this->{h} = $this->{process_desc}->{h};
  $this->{w} = $this->{process_desc}->{w};
  $this->{top} = $this->{process_desc}->{top};
  $this->{left} = $this->{process_desc}->{left};
  $this->{socket_list} = [ @{$this->FetchFromAbove("GetSocketList")} ];
  $this->TryNextSocket;
  $this->ReOpenFile;
  return $this;
}
sub TryNextSocket{
  my($this) = @_;
  my $next_socket = shift(@{$this->{socket_list}});
  unless($next_socket) {
    $this->{State} = "Error";
    $this->{ErrorMessage} = "none of the available sockets worked";
    $this->AutoRefresh;
  } else {
    $this->{State} = "TryingSocket";
    $this->{TryingSocket} = $next_socket;
    $this->{Command} = $this->{process_desc}->{Application};
    my $dir = $this->{process_desc}->{Directory};
    $this->{Command} =~ s/<host>/$this->{host}/;
    $this->{Command} =~ s/<port>/$next_socket/;
    $this->{Command} =~ s/<dir>/$dir/;
    $this->{Command} =~ s/<color>/"$this->{color}"/;
    my $p_stdout = PipeChildren::GetSocketPair(my $to_stdout, my $from_stdout);
    my $p_stderr = PipeChildren::GetSocketPair(my $to_stderr, my $from_stderr);
    my $child_pid = fork();
    unless(defined $child_pid){
      delete $this->{sock};
      $this->{State} = "Error";
      $this->{ErrorMessage} = "unable to fork";
    }
    if($child_pid != 0){  # in the parent
      close($p_stdout->{to});
      close($p_stderr->{to});
      $this->{child_pid} = $child_pid;
      $this->{State} = "ManagingChild";
      $this->{ChildRunning} = 1;
      Dispatch::Select::Socket->new(
        $this->SocketReader("StdoutLine", "SocketClosed"),
        $p_stdout->{from})->Add("reader");
      Dispatch::Select::Socket->new(
        $this->SocketReader("StderrLine", "SocketClosed"),
        $p_stderr->{from})->Add("reader");
      $this->{sockets_open} = 2;
    } else {  #  in the child
      close STDOUT;
      close STDERR;
      my $fn_stdout = fileno $p_stdout->{to};
      my $fn_stderr = fileno $p_stderr->{to};
      open STDOUT, ">&$fn_stdout" or die "can't redirect stdout";
      open STDERR, ">&$fn_stderr" or die "can't redirect stderr";
      exec $this->{Command};
      die "exec failed: $!";
    }
  }
}
sub SocketReader{
  my($this, $line_handler, $close_handler) = @_;
  my $text = "";
  my $foo = sub {
    my($disp, $sock) = @_;
    my $count = sysread($sock, $text, 1024, length($text));
    while($text =~ /^([^\n]*)\n(.*)/s){
      my $line = $1;
      $text = $2;
      $this->$line_handler($line);
    }
    if($count <= 0){
      print "Remove: $line_handler, $close_handler\n";
      $disp->Remove;
      $sock->close;
      $this->$close_handler;
    }
  };
  return $foo;
}
sub StdoutLine{
  my($this, $line) = @_;
print "STDOUT: $line\n";
  push(@{$this->{STDOUT}}, $line);
  if($line =~ /^Redirect to\s*(.*)\s*$/){
    $this->{State} = "AwaitingRedirect";
    $this->{redirect_url} = $1;
    $this->AutoRefresh;
  } elsif($line =~ /^Logged in\s*([^\s]+)\s*([^\s]+)\s*$/){
    $this->{AuthUser} = $1;
    $this->{RealUser} = $2;
    $this->{Status} = "Logged In";
  } elsif($line =~ /^Logged in\s*([^\s]+)\s*$/){
    $this->{AuthUser} = $1;
    $this->{RealUser} = $this->{AuthUser};
    $this->{Status} = "Logged In";
  } elsif($line =~ /^Time Out:/){
    $this->{Status} = "Timed Out";
    $this->AutoRefresh;
  } elsif($line =~ /^Application Terminated Normally$/){
    $this->{Status} = "Application Terminated Normally";
    $this->AutoRefresh;
  }
  if(
    exists($this->{BeingManagedBy}) && 
    $this->{BeingManagedBy}->can("AutoRefresh")
  ){
    $this->{BeingManagedBy}->AutoRefresh;
  }
}
sub StderrLine{
  my($this, $line) = @_;
print "STDERR: $line\n";
  push(@{$this->{STDERR}}, $line);
  if(
    exists($this->{BeingManagedBy}) && 
    $this->{BeingManagedBy}->can("AutoRefresh")
  ){
    $this->{BeingManagedBy}->AutoRefresh;
  }
}
sub SocketClosed{
  my($this) = @_;
  $this->{sockets_open} -= 1;
  if($this->{sockets_open} == 0){
    my $kid = waitpid($this->{child_pid}, 0);
    if($kid == $this->{child_pid}){
      if($this->{State} eq "ManagingChild"){
        $this->TryNextSocket;
      } else {
        $this->ChildFinished;
      }
    }
  }
}
sub ChildFinished{
  my($this) = @_;
  if($this->{Status} eq "Application Terminated Normally"){
    delete $AppController::RunningApps{$this->{TryingSocket}};
  } elsif($this->{Status} eq "Timed Out"){
    delete $AppController::RunningApps{$this->{TryingSocket}};
  } elsif($this->{KillIssued}){
    $this->{Status} = "Application Killed and Harvested";
    delete $AppController::RunningApps{$this->{TryingSocket}};
  } else {
    $this->{Status} = "Application Died Mysteriously";
    push(@AppController::HarvestedApps,
      $AppController::RunningApps{$this->{TryingSocket}});
    delete $AppController::RunningApps{$this->{TryingSocket}};
  }
}
sub ParentListContent{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{path});
}
sub Refresh{
  my($this, $http, $dyn) = @_;
  if($this->{State} eq "RedirectedWindow}"){ return }
  if($this->{State} eq "AwaitingRedirect"){
    return $this->RedirectWindow($http, $dyn);
  }
  $this->RefreshEngine($http, $dyn, 
  '<?dyn="Header"?>' .
  '<?dyn="Content"?>' .
  '<?dyn="Footer"?>');
}
sub Content{
  my($this, $http, $dyn) = @_;
  unless(defined $this->{State}) { $this->{State} = "&lt;undefined&gt;" }
  my $content = "Unknown state: $this->{State}";
  if($this->{State} eq "Error"){
    $content = 
      "Error: $this->{ErrorMessage}<br>" .
      '<a href="DeleteCloseWindow?obj_path=<?dyn="q_path"?>">close</a><br>';
  } elsif($this->{State} eq "TryingSocket"){
    $content = 
      "Trying socket: $this->{TryingSocket}";
  } elsif($this->{State} eq "ManagingChild"){
    $content = 
      "Waiting for child: $this->{child_pid} on $this->{TryingSocket}";
  } elsif($this->{State} eq "ChildComplete"){
    $content = 
      'Child Completed&nbsp;&nbsp;' .
      '<a href="DeleteCloseWindow?obj_path=<?dyn="q_path"?>">close</a>';
  } else {
    $this->RefreshEngine($http, $dyn, 
      'Unknown state: $this->{State}');
  }
  $this->RefreshEngine($http, $dyn, $content);
}
sub Header{
  my($this, $http, $dyn) = @_;
  $http->queue("<tr><th>Port</th><th>Pid</th>" .
    "<th>Description</th><th>Status</th><th>User</th>");
}
sub Describe{
  my($this, $http, $dyn) = @_;
  $http->queue("<tr bgcolr=\"$this->{color}\">");
  $http->queue("<td bgcolor=\"$this->{color}\">");
  $http->queue("$this->{TryingSocket}");
  $http->queue("</td><td bgcolor=\"$this->{color}\">");
  $http->queue("$this->{child_pid}");
  $http->queue("</td><td bgcolor=\"$this->{color}\">");
  $http->queue("$this->{process_desc}->{Description}");
  $http->queue("</td><td bgcolor=\"$this->{color}\">");
  $http->queue("$this->{Status}");
  $http->queue("</td><td bgcolor=\"$this->{color}\">");
  $http->queue("$this->{AuthUser}");
  $http->queue("</td>");
}
sub RedirectUrl{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{redirect_url});
}
my $redirect_content = <<EOF;
<?dyn="Header"?>
Redirect to <a href="<?dyn="RedirectUrl\"?>">application</a>
<?dyn="Footer"?>
EOF
sub RedirectWindow{
  my($this, $http, $dyn) = @_;
  $dyn->{url} = $this->{redirect_url};
  $this->Redirect($http, $dyn);
  $this->{State} = "RedirectedWindow";
  $this->parent->AutoRefresh;
  $AppController::RunningApps{$this->{TryingSocket}} = $this;
  $this->DeleteSelf;
}
sub AutoRefresh{
  my($this, $http, $dyn) = @_;
  if($this->{State} eq "RedirectedWindow") { return }
  Posda::HttpApp::GenericWindow::AutoRefresh($this);
}
sub CleanUp{
  my($this) = @_;
}
sub DESTROY{
  my($this) = @_;
  print "Destroying ChildProcess\n";
  $this->delete_children();
}
1;
