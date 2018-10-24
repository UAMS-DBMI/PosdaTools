#!/bin/perl -w
#
use strict;
package Posda::HttpApp::Controller;
my $content = <<EOF;
<?dyn="Header"?><body<?dyn="OnLoad"?>>
</body>
</html>
EOF
my $onload_refresh = " onLoad=\"" .
  "<?dyn=\"Alerts\"?>" .
  "<?dyn=\"OpenWindowList\"?>" .
  "<?dyn=\"RefreshFrameList\"?>" .
  "<?dyn=\"PositionFrameList\"?>" .
  "<?dyn=\"ReCheckOnLoad\"?>" .
  "\"";
#  "self.location.reload(true);" .
my $onload_wait = " onLoad=\"" .
  "<?dyn=\"ReloadCheck\"?>" .
  "\"";
use vars qw( @ISA );
@ISA = ( "Posda::HttpObj" );
sub new {
  my($class, $sess, $path) = @_;
  my $this = Posda::HttpObj->new($sess, $path);
  $this->{NumberChildWindows} = 0;
  $this->{LastNumberChildWindows} = 0;
  $this->{RefreshFrameList} = {};
  $this->{PositionFrameList} = {};
  $this->{OpenWindowList} = {};
  $this->{AlertQueue} = [ ];
  $this->set_expander($content);
  $this->{ImportFromAbove}->{WindowClosing} = 1;
  return bless $this, $class;
}
# <?dyn="Header"?><body onLoad="<?dyn="PositionFrameList"?><?dyn="RefreshFrameList"?><?dyn="OpenWindowList"?><?dyn="OnClose"?>">
my $closing_time_for_main_window = <<EOF;
<?dyn="Header"?><body onLoad="<?dyn="OnClose"?>">
Close this window if it does not close itself.  Thank you.
</body>
</html>
EOF
my $closing_time_for_sub_window = <<EOF;
<?dyn="FrameHeader"?><body onLoad="<?dyn="OnClose"?>">
Close this window if it does not close itself.  Thank you.
</body>
</html>
EOF
my $refresh_parent = <<EOF;
<?dyn="FrameHeader"?><body onLoad="if(self.parent) try { self.parent.location.reload(true) } catch (e) {};">
Refresh this window if it does not refresh itself.  Thank you.
</body>
</html>
EOF
sub Refresh{
  my($this, $http, $dyn) = @_;
  delete $this->{ReloadingWindow}; 
  if (exists $this->{ClosingTime}) {
##!!! Routing fix - All parents of Windows Buttons need to
##!!! add "WindowClosing to their "RoutesBelow" for us to 
##!!! change this to NotifyUp
    $this->parent->NotifyDown("WindowClosing");
    if (exists $this->{ThisIsASubWindow}) {
      $this->RefreshEngine($http, $dyn, $closing_time_for_sub_window);
    } else {
      # print "Controller:Refresh: $this->{path}, closing_time_for_main_window.\n";
      $this->RefreshEngine($http, $dyn, $closing_time_for_main_window);
    }
  } elsif (exists $this->{RefreshParent}) {
    # print "Refresh: obj: $this->{path} refreshing parent window of controller.\n";
    delete  $this->{RefreshParent};
    $this->RefreshEngine($http, $dyn, $refresh_parent);
  } else {
    $this->{NumberChildWindows} = 0;
    kid:
    for my $i (keys %{$this->{ChildWindows}}){
      if (defined $this->{HelpPath}  &&  $i eq $this->{HelpPath})
        { next kid; }
      my $obj = $this->get_obj($i);
      if(defined $obj){
        $this->{NumberChildWindows}++;
        next kid;
      }
      delete $this->{ChildWindows}->{$i};
    }
    if ($this->{LastNumberChildWindows} ne $this->{NumberChildWindows}) {
      my $wb_obj = $this->sibling("WindowButtons");
      if (defined $wb_obj) { $wb_obj->AutoRefresh; }
      $this->{LastNumberChildWindows} = $this->{NumberChildWindows};
    }
    $this->RefreshEngine($http, $dyn, $this->{expander});
  }
}
sub AutoRefresh{
  my($this) = @_;
  print STDERR "Request to refresh Controller $this->{path}\n";
}
sub RefreshParent{
  my($this) = @_;
  $this->{RefreshParent} = 1;
}
sub ClosingTime{
  my($this, $path) = @_;
  # print "ClosingTime: $this->{path}, path arg: $path.\n";
  if (exists $this->{ClosingTime}) { return; }
  $this->{ClosingTime} = $path;
  my $wb_obj = $this->sibling("WindowButtons");
  if (defined $wb_obj) { $wb_obj->ClosingTime($path); }
  # $this->RefreshFrame($this->iframe_name);
}
sub Busy{
  my($this) = @_;
  my $ret = 
    (
    scalar(keys %{$this->{RefreshFrameList}}) > 0 ||
    scalar(keys %{$this->{PositionFrameList}}) > 0 ||
    scalar(keys %{$this->{OpenWindowList}}) > 0 ||
    $#{$this->{AlertQueue}} >= 0 ||
    exists $this->{RefreshParent}  ||
    exists $this->{ClosingTime}
    ) ? 1 : 0;
   # print "Busy: Returning: $ret.\n";
  return $ret;
}
sub OnClose{
  my($this, $http, $dyn) = @_;
  if (exists $this->{ThisIsASubWindow}) {
    $http->queue(
      "self.parent.location='DeleteAndClose?" .
      "obj_path=$this->{ClosingTime}';");
   } else {
     # print "Controller:OnClose: $this->{path}, queueing parent shutdown.\n";
    $http->queue(
      "self.parent.location='Shutdown?" .
      "obj_path=" . $this->parent_path . "';");
  }
}
sub ReloadCheck{
  my($this, $http, $dyn) = @_;
   # print "Queueing: st('ReloadNeeded?obj_path=" . $this->{path} . "','','500');\n";
  $http->queue("st('ReloadNeeded?obj_path=" . $this->{path} . "','','500');");
}
sub ReCheckOnLoad{
  my($this, $http, $dyn) = @_;
   # print "Queueing: st('ReloadNeeded?obj_path=" . $this->{path} . "','','100');\n";
  $http->queue("st('ReloadNeeded?obj_path=" . $this->{path} . "','','100');");
}
sub ReloadNeeded{
  my($this, $http, $dyn) = @_;
  my $content_len = $http->{header}->{content_length};
  my $content;
  my $len = read($http->{socket}, $content, $content_len);

  $this->text_header($http, { content_length => 1 } );
  my $ret = 
    (
    scalar(keys %{$this->{RefreshFrameList}}) > 0 ||
    scalar(keys %{$this->{PositionFrameList}}) > 0 ||
    scalar(keys %{$this->{OpenWindowList}}) > 0 ||
    $#{$this->{AlertQueue}} >= 0  ||
    exists $this->{RefreshParent}  ||
    exists $this->{ClosingTime}
    ) ? "1" : "0";
     # print "ReloadNeeded: $this->{path}, returning: $ret.\n";
   # if (! defined $this->{last_ReloadNeeded_ret}  ||
       # $this->{last_ReloadNeeded_ret} ne $ret) {
     # print "ReloadNeeded: $this->{path}, returning: $ret.\n";
     # $this->{last_ReloadNeeded_ret} = $ret;
   # }
  $http->queue($ret);
}
sub OnLoad{
  my($this, $http, $dyn) = @_;
  if 
    (
    scalar(keys %{$this->{RefreshFrameList}}) > 0 ||
    scalar(keys %{$this->{PositionFrameList}}) > 0 ||
    scalar(keys %{$this->{OpenWindowList}}) > 0 ||
    $#{$this->{AlertQueue}} >= 0 
    ) {
       # print "OnLoad: queueing onload_refresh.\n";
      $this->RefreshEngine($http, $dyn, $onload_refresh);
    } else {
       # print "OnLoad: queueing onload_wait.\n";
      $this->RefreshEngine($http, $dyn, $onload_wait);
    }
}
sub RefreshFrameList{
  my($this, $http, $dyn) = @_;
  if (exists $this->{ClosingTime}) { return; }
  if(scalar(keys %{$this->{RefreshFrameList}}) > 0){
    for my $win (keys %{$this->{RefreshFrameList}}){
      my $parent_win =  $this->{RefreshFrameList}->{$win};
      delete $this->{RefreshFrameList}->{$win};
      my $url = "Refresh?obj_path=$win";
      $win =~ s/\//_/g;
      $parent_win =~ s/\//_/g;
      # $http->queue("rf('$win');");
      if ($parent_win eq $win) { 
        # print "Controller: $this->{path}, RefreshFrameList Queueing: " .
        #   "pf('$win','$url');\n";
        $http->queue("pf('$win','$url');");
      } else { 
        # print "Controller: $this->{path}, RefreshFrameList Queueing: " .
        #   "psf('$parent_win','$win','$url');\n";
        $http->queue("psf('$parent_win','$win','$url');");
      }
    }
  }
}
sub PositionFrameList{
  my($this, $http, $dyn) = @_;
  if (exists $this->{ClosingTime}) { return; }
  if(scalar(keys %{$this->{PositionFrameList}}) > 0){
    for my $win (keys %{$this->{PositionFrameList}}){
      my $url = "Refresh?obj_path=$win#$this->{PositionFrameList}->{$win}";
      delete $this->{PositionFrameList}->{$win};
      $win =~ s/\//_/g;
      # print "Controller: $this->{path}, PositionFrameList Queueing: " .
      #     "pf('$win','$url');\n";
       #   "self.parent.window.frames['$win'].location = '$url'; \n";
       # $http->queue("self.parent.window.frames['$win'].location = '$url';");
       $http->queue("pf('$win','$url');");
    }
  }
}
sub Alerts{
  my($this, $http, $dyn) = @_;
  if (exists $this->{ClosingTime}) { return; }
  # unless ($#{$this->{AlertQueue}} >= 0 ) { return; }
  alert:
  while (defined (my $a = shift @{$this->{AlertQueue}})) {
    # a->{msg} msg to display
    # a->{op} routine to call, if not supplied, msg is just displayed.
    # a->{parm} , ->{index} just returned in dyn to op
    # a->{value} value to request.
    # dyn->{value} returned from question.
    unless (exists ($a->{op})  &&  exists ($a->{obj})) {
      $http->queue("alert('$a->{msg}');");
      next alert;
    }
    my $url = "$a->{op}?obj_path=$a->{obj}" .
      (exists($a->{param}) ? "&param=$a->{param}" : "") .
      (exists($a->{index}) ? "&index=$a->{index}" : "");
    my $prompt;

    if (exists $a->{value}) {
      $prompt = "prompt('$a->{msg}','$a->{value}')";
    } else {
      $prompt = "confirm('$a->{msg}')";
    }
    my $line = "ns('" . $url . "&value='+" . $prompt. ");";
    # print "Controller::ALerts: prompt line: $line\n";
    $http->queue($line);

  }
}
sub OpenWindowList{
  my($this, $http, $dyn) = @_;
  if (exists $this->{ClosingTime}) { return; }
  if(scalar(keys %{$this->{OpenWindowList}}) > 0){
    win:
    for my $win (keys %{$this->{OpenWindowList}}){
      my $desc = $this->{OpenWindowList}->{$win};
      delete $this->{OpenWindowList}->{$win};
      my $obj = $this->get_obj($win);
      unless(defined $obj) { next win }
      my $url = "Refresh?obj_path=$win";
      my $w = 1204;
      my $h = 768;
      if($desc->{w}) { $w = $desc->{w} }
      if($desc->{h}) { $h = $desc->{h} }
      if($desc->{url}) { $url = $desc->{url} }
      $win =~ s/\//_/g;
      # print "Controller: $this->{path}, OpenWindowList Queueing: " .
      #     "rt('$win', '$url', $w, $h, 0); \n";
      $http->queue("rt('$win', '$url', $w, $h, 0);");
    }
  }
}
sub WbRefresh{
  my($this) = @_;
  my $wb_obj = $this->sibling("WindowButtons");
  if($wb_obj && $wb_obj->can("AutoRefresh")){ $wb_obj->AutoRefresh }
}
sub add_child_window{
  my($this, $win_name, $props) = @_;
  if (defined $this->{ReloadingWindow}) { return; }
   # print "add_child_window: Controller: $this->{path}, adding '$win_name' to list: ChildWindows, OpenWindowList.\n";
  $this->{ChildWindows}->{$win_name} = $props;
  $this->{OpenWindowList}->{$win_name} = $props;
}
sub AddChildWindow{
  my($this, $win_name, $props) = @_;
  #  print "AddChildWindow: adding '$win_name' to list: ChildWindows, OpenWindowList.\n";
  my $wb_obj = $this->sibling("WindowButtons");
  if (defined $wb_obj  &&
      exists $wb_obj->{HelpPath} && 
      $wb_obj->{HelpPath} eq $win_name &&
      ! exists $wb_obj->{HelpOpen})
    { return; }
  $this->add_child_window($win_name, $props);
}
sub OpenChildWindow{
  my($this, $win_name) = @_;
  if (defined $this->{ReloadingWindow}) { return; }
  if(exists $this->{ChildWindows}->{$win_name}){
   # print "OpenChildWindow: Controller: $this->{path}, adding '$win_name' to list: OpenWindowList.\n";
    $this->{OpenWindowList}->{$win_name} = $this->{ChildWindows}->{$win_name};
  } else {
   # print "OpenChildWindow: error, '$win_name' not is list ChildWindows.\n";
    print STDERR "Request to open non-existent child $win_name\n";
  }
}
sub OpenAllChildren{
  my($this) = @_;
  if (defined $this->{ReloadingWindow}) { return; }
  for my $i (keys %{$this->{ChildWindows}}){
     # print "OpenAllChildren: adding '$i' to list: OpenWindowList.\n";
    $this->{OpenWindowList}->{$i} = $this->{ChildWindows}->{$i};
  }
}
sub RefreshSubFrame{
  my($this, $parent_win, $win_name) = @_;
  if (defined $this->{ReloadingWindow}) { return; }
  if ($win_name eq $this->{path}) {
    print STDERR "Trying to refresh Controller $this->{path}\n";
    my ($package, $filename, $line);
    ( $package, $filename, $line ) = caller(1);
    print STDERR "  $package :: $filename line $line.\n";
    ( $package, $filename, $line ) = caller(2);
    print STDERR "  $package :: $filename line $line.\n";
    ( $package, $filename, $line ) = caller(3);
    print STDERR "  $package :: $filename line $line.\n";
    return;
  }
   # print "RefreshFrame: Controller: $this->{path}, window: $win_name.\n";
  $this->{RefreshFrameList}->{$win_name} = $parent_win;
}
sub RefreshFrame{
  my($this, $win_name) = @_;
  $this->RefreshSubFrame($win_name, $win_name);
}
sub CancelRefreshFrame{
  my($this, $win_name) = @_;
   # print "CancelRefreshFrame: Controller: $this->{path}, window: $win_name.\n";
  delete $this->{RefreshFrameList}->{$win_name};
}
sub PositionFrame{
  my($this, $win_name, $position) = @_;
  if (defined $this->{ReloadingWindow}) { return; }
  if ($win_name eq $this->{path}) {
    print STDERR "Trying to position frame of Controller $this->{path}\n";
    return;
  }
   # print "PositionFrame: Controller: $this->{path}, window: $win_name.\n";
  $this->{PositionFrameList}->{$win_name} = $position;
}
sub OpenWindow{
  my($this, $win_name, $props) = @_;
  if (defined $this->{ReloadingWindow}) { return; }
  if ($win_name eq $this->{path}) {
    print STDERR "Trying to open window of Controller $this->{path}\n";
    return;
  }
   # print "OpenWindow: window: $win_name.\n";
  $this->{OpenWindowList}->{$win_name} = $props;
}
sub QueueAlertMsg{
  my($this, $msg, $resp) = @_;
   # print "OpenWindow: window: $win_name.\n";
  unless (defined $resp) { $resp = { }; }
  if (defined $msg) { $resp->{msg} = $msg; }
  unless (exists ($resp->{msg})  &&  defined ($resp->{msg}))
    { print STDERR "obj: $this->{path}: Alert called with no msg or resp.";}
  push (@{$this->{AlertQueue}}, $resp);
}
sub ReloadWindow{
  my($this) = @_;
  unless (exists $this->{ThisIsASubWindow}) {
    die "Error: calling ReloadWindow on primary window controller";
  }
  $this->{ReloadingWindow} = 1;
  my $sub_window = $this->parent;
  $sub_window->parent->Controller->AddChildWindow($sub_window->{path}, {
    url => $sub_window->{url},
    w => $sub_window->{w},
    h => $sub_window->{h},
    });
  delete $this->{NumberChildWindows};
  delete $this->{NumberChildWindows};
  delete $this->{RefreshFrameList};
  delete $this->{PositionFrameList};
  delete $this->{OpenWindowList};
  $this->{NumberChildWindows} = 0;
  $this->{LastNumberChildWindows} = 0;
  $this->{RefreshFrameList} = {};
  $this->{PositionFrameList} = {};
  $this->{OpenWindowList} = {};
}
sub LogoutAndClose{
  my($this) = @_;
   # print "LogoutAndClose: $this->{path}.\n";
  $this->ClosingTime($this->parent_path);
}
1;
