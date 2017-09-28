#!/usr/bin/perl -w
#
use strict;
use POSIX 'strftime';
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::JsController;
use AppController::DetachedChild;
use Posda::BgColor;
use PipeChildren;
use IO::Socket::INET;
use Debug;
my $dbg = sub { print @_ };
package AppController::JsChildProcess;
use Fcntl;
use vars qw( @ISA );
@ISA = ("Posda::HttpApp::JsController");
my $expander = <<EOF;
<?dyn="BaseHeader"?>
<script type="text/javascript">
<?dyn="JsController"?>
<?dyn="JsContent"?>
</script>
</head>
<body>
<?dyn="Content"?>
<?dyn="Footer"?>
EOF
sub new{
  my($class, $sess, $path, $process_desc, $host) = @_;
  my $this = Posda::HttpApp::JsController->new($sess, $path);
  $this->{title} = "SubProcessHandler";
  $this->{color} = Posda::BgColor::GetUnusedColor;
  $this->{Status} = "Not Logged In";
  $this->{AuthUser} = $this->get_user;
  $this->{RealUser} = $this->{AuthUser};
  $this->{ImportsFromAbove}->{GetSocketList} = 1;
  $this->{expander} = $expander;
  bless $this, $class;
  $this->{host} = $host;
  if($this->{host} =~ /^(.*):(.*)$/){
    $this->{host} = $1;
    $this->{parent_port} = $2;
  }
  $this->{process_desc} = $process_desc;
  $this->{h} = $this->{process_desc}->{h};
  $this->{w} = $this->{process_desc}->{w};
  $this->{menu_width} =
    $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
  $this->{login_width} =
    $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
  $this->{content_width} = $this->{w} - $this->{menu_width};
  $this->{top} = $this->{process_desc}->{top};
  $this->{left} = $this->{process_desc}->{left};
  $this->{socket_list} = $this->FetchFromAbove("GetAvailableSockets");
  $this->{StartTime} = time;
  $this->TryNextSocket;
  return $this;
}
my $content = <<EOF;
<div id="container" style="width:<?dyn="width"?>px">
<div id="header" style="background-color:#E0E0FF;">
<table width="100%"><tr width="100%"><td width="<?dyn="menu_width"?>">
<?dyn="Logo"?>
</td><td align="left" valign="top">
<div id="title_and_info" style="background-color:#E0E0FF; width:100%; float:left;">foo</div>
</td><td valign="top" align="right" width="<?dyn="menu_width"?>">
<span onClick="javascript:CloseThisWindow();">close</span><br>
</td></tr></table></div>
<div id="content" style="background-color:#F8F8F8;height:<?dyn="height"?>px;width:100%"?>px;float:left;">
Content goes here</div>
<div id="footer" style="background-color:#E8E8FF;clear:both;text-align:center;">
Posda.com</div>
</div>
EOF
my $javascript = <<EOF;
function ContentResponseReturned(text, status, xml){
  document.getElementById('content').innerHTML = text;
}
function TitleAndInfoResponseReturned(text, status, xml){
  document.getElementById('title_and_info').innerHTML = text;
}
function UpdateTitleAndInfo(){
  PosdaGetRemoteMethod("TitleAndInfoResponse", "" ,
    TitleAndInfoResponseReturned);
}
function UpdateContent(){
  PosdaGetRemoteMethod("ContentResponse", "" , ContentResponseReturned);
}
function Update(){
  UpdateTitleAndInfo();
  UpdateContent();
}
EOF
sub Refresh {
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $this->{expander});
}
sub Content {
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $content);
}
sub JsContent {
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $javascript);
}
sub height{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{h});
}
sub width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{w} + 20);
}
sub menu_width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{menu_width});
}
sub content_width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{menu_width});
}
sub Logo{
  my($this, $http, $dyn) = @_;
    my $image = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoImage};
    my $height = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoHeight};
    my $width = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
    my $alt = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoAlt};
    $http->queue("<img src=\"$image\" height=\"$height\" width=\"$width\" " .
      "alt=\"$alt\">");
}
sub TitleAndInfoResponse{
  my($this, $http, $dyn) = @_;
  $http->queue("Title goes here");
}
sub ContentResponse{
  my($this, $http, $dyn) = @_;
  if(
    exists($this->{ContentState}) &&
    defined($this->{ContentState}) &&
    $this->{ContentState} eq "CompileError"
  ){
    $http->queue("<small><pre>");
    for my $i (@{$this->{CompileErrorLines}}){
      $http->queue("$i\n");
    }
    $http->queue("</pre></small>");
  } elsif(
    exists($this->{ContentState}) &&
    defined($this->{ContentState})
  ){
    $http->queue("ContentState: $this->{ContentState}");
  } else {
    $http->queue("Gimme some Content");
  }
}
sub TryNextSocket{
  my($this) = @_;
  my $now = time;
  if($now - $this->{StartTime} > 20){
    $this->{ErrorMessage} = "Hmmm.  Long time before I noticed " .
      "this failure. Better give up.";
    $this->{State} = "Error";
    print STDERR $this->{ErrorMessage};
    my $user = $this->{AuthUser};
    print STDERR "#########################\n" .
      "This user: $user\n" .
      "probably has a browser which blocks popups from this site\n" .
      "and hasn't figured it out yet.\n" .
      "perhaps someone should clue him in\n" .
      "#########################\n";
    $this->AutoRefresh;
    delete $AppController::RunningApps{$this->{TryingSocket}};
    return;
  }
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
    $this->{Command} =~ s/<user>/"$this->{AuthUser}"/;
    my $p_stdout = PipeChildren::GetSocketPair(my $to_stdout, my $from_stdout);
    my $p_stderr = PipeChildren::GetSocketPair(my $to_stderr, my $from_stderr);
    $this->{child_pid} = fork();
    unless(defined $this->{child_pid}){
      $this->{ErrorMessage} = "unable to fork ($!)";
      delete $this->{sock};
      $this->{State} = "Error";
    }
    if($this->{child_pid} != 0){  # in the parent
      close($p_stdout->{to});
      close($p_stderr->{to});
      $this->{State} = "ManagingChild";
      $this->{ChildRunning} = 1;
      $this->{stdout_reader} = Dispatch::LineReader->new_fh(
        $p_stdout->{from}, 
        $this->StdoutLine($this->{TryingSocket}),
        $this->StdoutEof($this->{TryingSocket}));
      $this->{stderr_reader} = Dispatch::LineReader->new_fh(
        $p_stderr->{from}, 
        $this->StderrLine($this->{TryingSocket}),
        $this->StderrEof($this->{TryingSocket}));
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
sub StderrLine{
  my($this, $child_port) = @_;
  my $sub = sub {
    my($line) = @_;
    print STDERR "child($child_port):STDERR:$line\n";
  };
  return $sub;
}
sub StderrEof{
  my($this, $child_port) = @_;
  my $sub = sub {
    print "child($child_port):STDERR:EOF\n";
    delete $this->{stderr_reader};
    $this->CheckDone;
  };
  return $sub;
}
sub StdoutLine{
  my($this, $child_port) = @_;
  my $sub = sub {
    my($line) = @_;
    if($line =~ /^Redirect to (.*)$/){
      $this->RedirectToNewApp($child_port, $1);
    } elsif($line =~ /^Failed to compile: (.*)$/){
      $this->{CompileErrorLines} = [];
      $this->{stdout_reader}->replace_handlers(
        $this->CompileErrorReader($1),
        $this->StdoutEof($child_port));
    }
    print STDERR "child($child_port):STDOUT:$line\n";
  };
  return $sub;
}
sub StdoutEof{
  my($this, $child_port) = @_;
  my $sub = sub {
    print "child($child_port):STDOUT:EOF\n";
    delete $this->{stdout_reader};
    $this->CheckDone;
  };
  return $sub;
}
sub CheckDone{
  my($this) = @_;
  $this->AutoRefresh;
  if(exists $this->{stdout_reader}) { return }
  if(exists $this->{stderr_reader}) { return }
  if(exists $this->{child_pid}) {
    $this->HarvestPid($this->{child_pid});
    delete $this->{child_pid};
  }
  if(
    exists($this->{ContentState}) &&
    defined($this->{ContentState}) &&
    $this->{ContentState} eq "CompileError"
  ){ return }
  $this->TryNextSocket;
}
sub CompileErrorReader{
  my($this, $marker) = @_;
  my $sub = sub {
    my($line) = @_;
    if($line eq $marker){
      $this->{ContentState} = "CompileError";
    } else { push @{$this->{CompileErrorLines}}, $line }
  };
  return $sub;
}
sub RedirectToNewApp{
  my($this, $port, $url) = @_;
  my $cmd = "DetachAndRedirect('$url');";
  $this->QueueJsCmd($cmd);
  $AppController::RunningApps{$port} = $this;
}
sub Detach{
  my($this, $http, $dyn) = @_;
  $this->DeleteSelf;
  $http->queue("Detached OK");
  AppController::DetachedChild->Transform($this);
}
sub CleanUp{
  my($this) = @_;
  print STDERR "Calling cleanup for $this->{path}\n";
}
sub DESTROY{
  my($this) = @_;
  print "Destroying ChildProcess\n";
  $this->delete_children();
}
1;
