#!/bin/perl -w
#
use strict;
package Posda::HttpApp::WindowButtons;
use Posda::HttpApp::GenericIframe;
use Posda::HttpApp::DebugWindow;
my $content = <<EOF;
<table border="0" style="width:100%;height:100%" summary="Window control">
<tr><td valign="top" align="right">
<small>
<?dyn="LogoutIfCan"?>
<?dyn="HelpIfCan"?>
<?dyn="debug"?>
</small>
</td></tr></table>
EOF
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericIframe" );
sub new {
  my($class, $sess, $path, $close_button_label, $main_window) = @_;
  my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
  if (defined $close_button_label) {
    $this->{CloseButtonLabel} = $close_button_label;
  } else {
    $this->{CloseButtonLabel} = "Close";
  }
  if (defined $main_window) {
    $this->{MainWindowFlag} = $main_window;
  } else {
    $this->{MainWindowFlag} = 1;
  }
  $this->{ImportsFromAbove}->{ExpertModeChanged} = 1;
  return bless $this, $class;
}
my $closing_time_for_main_window = <<EOF;
Close this window if it does not close itself.  Thank you.
EOF
my $closing_time_for_sub_window = <<EOF;
Close this window if it does not close itself.  Thank you.
EOF
sub Content{
  my($this, $http, $dyn) = @_;
  if (exists $this->{ClosingTime}) {
    if (exists $this->{ThisIsASubWindow}) {
      $this->RefreshEngine($http, $dyn, $closing_time_for_sub_window);
    } else {
      $this->RefreshEngine($http, $dyn, $closing_time_for_main_window);
    }
  } else {
    $this->CancelRefreshFrame;
    $this->RefreshEngine($http, $dyn, $content);
  }
}
sub AutoRefresh{
  my($this) = @_;
  $this->parent->Controller()->RefreshFrame($this->iframe_name);
}
sub ClosingTime{
  my($this, $path) = @_;
  if (exists $this->{ClosingTime}) { return; }
  $this->{ClosingTime} = $path;
  $this->AutoRefresh;
}
my $expert_mode_off_button = <<EOF;
 <br><?dyn="Button" op="ToggleExpertModeOff" caption="Expert Off"?>
EOF
my $expert_mode_on_button = <<EOF;
 <br><?dyn="Button" op="ToggleExpertModeOn" caption="Expert On"?>
EOF
my $debug_button_the_way_we_want = <<EOF;
 <br><?dyn="Button" op="OpenDebugWindow" caption="Debug"?>
EOF
my $debug_button = <<EOF;
<br><a href="javascript:<?dyn="SetDebugOptions"?>;rt('DebugWindow','Refresh?obj_path=Debug',1600,1200,0);" style="line-height:16px">debug</a>&nbsp;
EOF
sub debug{
  my($this, $http, $dyn) = @_;
  if(exists $this->GetPrivileges->{capability}->{CanDebug}){
    if ($this->IsExpert()) {
      $this->RefreshEngine($http, $dyn, $expert_mode_off_button);
    } else {
      $this->RefreshEngine($http, $dyn, $expert_mode_on_button);
    }
    $this->RefreshEngine($http, $dyn, $debug_button);
  } elsif(exists $this->GetPrivileges->{capability}->{NewDebug}) {
    $this->RefreshEngine($http, $dyn, $debug_button_the_way_we_want);
  }
}
sub SetDebugOptions{
  my($this, $http, $dyn) = @_;
  my $p = $this->parent;
  if(defined $p){
    my $parent_path = $p->{path};
    $http->queue("ns('CheckBoxInDebug?obj_path=$this->{path}&" .
      "debug=$p->{path}')");
      "debug=$p->{path}')";
  } else {
    print STDERR "Parent of $this->{path} undefined\n";
  }
}
sub CheckBoxInDebug{
  my($this, $http, $dyn) = @_;
  my $d = $this->get_obj("Debug");
  if(defined $d) {
    $d->{OpenYesNo}->{$dyn->{debug}} = "checked";
  }
}
sub OpenDebugWindow{
  my($this, $http, $dyn) = @_;
  my $obj = $this->get_obj("Debug");
  if (defined $obj) { $obj->ReOpenFile() } else {
    Posda::HttpApp::DebugWindow->new($this->{session}, "Debug");
  }
}
sub ToggleExpertModeOn{
  my($this, $http, $dyn) = @_;
  $this->Expert($http, $dyn);
  $this->AutoRefresh;
  $this->NotifyUp("ExpertModeChanged");
}
sub ToggleExpertModeOff{
  my($this, $http, $dyn) = @_;
  $this->NoExpert($http, $dyn);
  $this->AutoRefresh;
  $this->NotifyUp("ExpertModeChanged");
}
sub OpenHelp{
  my($this) = @_;
  unless (exists $this->{HelpPath})  {
    print STDERR "Help requested but no help object path.\n";
    return;
  }
  my $hobj = $this->get_obj($this->{HelpPath});
  unless (defined $hobj) {
    print STDERR "Help requested but no help object.\n";
    return;
  }
  $hobj->ClearCloseWindow;
  unless ($hobj->can("DisplayHelp")) {
    print STDERR "Help requested but invalid help object.\n";
    return;
  }
  $hobj->DisplayHelp;
  $this->AutoRefresh;
}
sub CloseHelp{
  my($this) = @_;
  my $hobj = $this->get_obj($this->{HelpPath});
  unless (defined $hobj) {
    print STDERR "Close Help requested but no help object.\n";
    return;
  }
  $hobj->SetCloseWindow;
  # $this->parent->Controller->AddChildWindow(
  #   $this->{HelpPath},  {
  #   url => "Refresh?obj_path=$this->{HelpPath}",
  #   w => 1204,
  #   h => 768,
  #   }  );
  $this->AutoRefresh;
}
my $open_help = <<EOF;
<?dyn="Button" caption="Help" op="OpenHelp"?>
EOF
my $close_help = <<EOF;
<?dyn="Button" caption="Close Help" op="CloseHelp"?>
EOF
sub HelpIfCan{
  my($this, $http, $dyn) = @_;
  if (exists $this->{HelpPath}) {
    my $hobj = $this->get_obj($this->{HelpPath});
    if (defined $hobj  &&
        $hobj->IsWindowOpen()) {
      $this->RefreshEngine($http, $dyn, $close_help);
    } else {
      $this->RefreshEngine($http, $dyn, $open_help);
    }
  }
}
sub WindowsButtonsClose{
  my($this, $http, $dyn) = @_;
  if (exists $this->{HelpPath}) {
    my $hobj = $this->get_obj($this->{HelpPath});
    if (defined $hobj  &&
        $hobj->IsWindowOpen()) {
      $this->CloseHelp;
    }
  }
  if ($this->{MainWindowFlag}) {
    $this->Controller->ClosingTime($this->parent->{path});
  } else {
    $this->CloseWindow;
  }
  $this->AutoRefresh;
}
sub OpenAllChildren{
  my($this) = @_;
  $this->Controller->OpenAllChildren;
}
sub LogoutIfCan{
  my($this, $http, $dyn) = @_;
  if(exists $this->{Abort}){
    return $this->AbortButton($http, $dyn);
  }
  my $count = $this->Controller->{NumberChildWindows};
  unless (defined $count) { $count = 0; }
  if($count < 1){
    if ($this->{CloseButtonLabel} eq "") { return; }
    $this->RefreshEngine($http, $dyn, 
      "<?dyn=\"Button\" caption=\"" . $this->{CloseButtonLabel} . 
      "\" op=\"WindowsButtonsClose\"?>");
    return;
  }
  if (
    exists $this->GetPrivileges->{capability}->{CanDebug} ||
    exists $this->GetPrivileges->{capability}->{NewDebug}
  ){
    $this->RefreshEngine($http, $dyn, 
      "<?dyn=\"Button\" caption=\"Show " . $count . " kids\" " . 
      "op=\"OpenAllChildren\" size=\"80\"" .
      "?>");
  } else {
    $this->RefreshEngine($http, $dyn, 
      "<?dyn=\"Button\" caption=\"Show other windows\" " . 
      "op=\"OpenAllChildren\" size=\"130\"" .
      "?>");
  }
}
sub AbortButton{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    '<?dyn="Button" caption="' .
    $this->{Abort}->{Caption} .
    '" op="Abort"?>');
}
sub Abort{
  my($this, $http, $dyn) = @_;
  unless(exists $this->{Abort}) { return }
  my $obj = $this->get_obj($this->{Abort}->{Obj});
  if(defined($obj) && $obj->can($this->{Abort}->{Method})){
    my $meth = $this->{Abort}->{Method};
    $obj->$meth($http, $dyn);
  }
}
sub SetAbort{
  my($this, $obj_name, $method, $caption) = @_;
  $this->{Abort}->{Obj} = $obj_name;
  $this->{Abort}->{Method} = $method;
  $this->{Abort}->{Caption} = $caption;
  $this->AutoRefresh;
}
sub ClearAbort{
  my($this) = @_;
  delete $this->{Abort};
  $this->AutoRefresh;
}
1;
