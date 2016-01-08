#!/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/AppController/Login.pm,v $
#$Date: 2013/10/20 13:10:59 $
#$Revision: 1.6 $
#
use strict;
package AppController::Login;
use Posda::HttpApp::GenericIframe;
use Posda::HttpApp::DebugWindow;
use Storable qw( store retrieve store_fd fd_retrieve );
my $content = <<EOF;
<table border="0" style="width:100%;height:100%" summary="Window control">
<tr><td valign="top" align="right">
<small>
<?dyn="CurrentUser"?>
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
    $this->{CloseButtonLabel} = "Logout";
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
sub CurrentUser{
  my($this, $http, $dyn) = @_;
  my $user = $this->get_user;
  if($user) {
    $http->queue("Logged in: $user<br />");
  } else {
    $this->RefreshEngine($http, $dyn,
      '<form onSubmit="' .
      "ns('Login?obj_path=$this->{path}" .
      "&amp;name='+this.elements['UserName'].value+'&amp;" .
      "password='+this.elements['UserEnteredPassword'].value);" .
      ' return false;">' . "\n" .
      '<table><tr><td align="right">Username:</td>' .
      '<td align="left">' .
      '<input name="UserName">' .
      '</td></tr><tr>'. "\n" . '<td align="right">Password:</td>' .
      '<td align="left">' .
      '<input type="password" name="UserEnteredPassword">' .
      '</td></tr>'. "\n" . '<tr><td></td><td>' .
      '<input type="submit" name="Submit" value="Login">' .
      '</td><tr></table></form>'
    );
  }
}
sub Login{
  my($this, $http, $dyn) = @_;
  my $passwd = $dyn->{password};
  my $user = $dyn->{name};
  my $db_type = 
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{AuthenticationDbType};
  if($db_type eq "File"){
    my $file = 
      $main::HTTP_APP_CONFIG->{config}->{Environment}
        ->{AuthenticationDbFileName};
    if($this->DbFileValidation($user, $passwd, $file)){
      $this->SetPrivs($user);
      $this->parent->AutoRefresh;
    }
  } else {
    if($this->DbValidation($user, $passwd)){
      $this->SetPrivs($user);
      $this->parent->AutoRefresh;
    }
  }
}
sub DbFileValidation{
  my($this, $user, $password, $file) = @_;
  open my $fh, "<$file" or return undef;
  my %logins;
  while(my $l = <$fh>){
    chomp $l;
    my($usr, $pwd, $is_sup, $name) = split(/\|/, $l);
    $logins{$usr} = $pwd;
  }
  close $fh;
  unless(exists $logins{$user}) { return undef }
  unless(
    crypt($password, $logins{$user}) eq $logins{$user}
  ){ return undef }
  return 1;
}
sub SetPrivs{
  my($this, $user) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  $sess->{AuthUser} = $user;
  my $cap_config = $main::HTTP_APP_CONFIG->{config}->{Capabilities};
  $sess->{Privileges}->{capability} = $cap_config->{$user};
  $this->{capability} = $cap_config->{$user};
}
sub DbValidation{
  my($this, $user, $passwd) = @_;
  my $db_host = 
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{AuthenticationDbHost};
  my $db_name = 
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{AuthenticationDbName};
  my $db_user = 
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{AuthenticationDbUser};
  my $db_cache_file = 
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{CachedEncryptedLogins};
  my $db = DBI->connect(
    "dbi:Pg:dbname=$db_name;host=$db_host;user=$db_user", "", "");
  if($db){
    my $q = $db->prepare(
      "select enc_passwd, is_super from users where user_id = ?");
    $q->execute($user);
    my $h = $q->fetchrow_hashref;
    $q->finish;
    my $enc_passwd = $h->{enc_passwd};
    if(
      !defined($h) ||
      !defined($enc_passwd) ||
      $enc_passwd eq "" ||
      crypt($passwd, $enc_passwd) ne $enc_passwd
    ){
      print STDERR "Login failed for user: $user\n";
      return undef;
    }
    ###########  Here  -- successful login from database
    ###########  if cache file defined cache encrypted passwords in it
    my $random = int rand(10000);
    my $new_cache_file = $db_cache_file . "_$random";
    my $passwords;
    $q = $db->prepare("select user_id, enc_passwd, is_super from users");
    $q->execute;
    while(my $h = $q->fetchrow_hashref){
      $passwords->{$h->{user_id}} = {
        enc_passwd => $h->{enc_passwd},
        is_super => $h->{is_super}
      };
    }
    $db->disconnect;
    open my $fh, ">$new_cache_file" or die "can't open $new_cache_file";
    store_fd $passwords, $fh;
    close($fh);
    if(-e $db_cache_file){
      unless(unlink $db_cache_file){
        print STDERR  "Can't unlink $db_cache_file: $!\n"
      }
    }
    unless(link $new_cache_file, $db_cache_file) {
      print STDERR "Can't link $new_cache_file to $db_cache_file: $!\n";
    }
    unlink $new_cache_file;
    return 1;
  } else {
    ###########  Here -- database down, use cached encrypted passwords
    my $passwords;
    if(-r $db_cache_file){
      open my $fh, "<$db_cache_file" or die "Can't open $db_cache_file";
      $passwords = fd_retrieve($fh);
    } else {
      die "Database down and no cache file for passwords";
    }
    if(
      !defined($passwords->{$user}) ||
      $passwords->{$user} eq "" ||
      crypt($passwd, $passwords->{$user}->{enc_passwd}) ne 
      $passwords->{$user}->{enc_passwd}
    ){
      print STDERR "Login failed for user: $user\n";
      return 0;
    }
  }
  return 1;
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
<br><a href="javascript:rt('DebugWindow','Refresh?obj_path=Debug',1600,1200,0);" style="line-height:16px">debug</a>&nbsp;
EOF
sub debug{
  my($this, $http, $dyn) = @_;
  unless($this->get_user) { return }
  if(exists $this->GetPrivileges->{capability}->{CanDebug}){
    if ($this->IsExpert()) {
      $this->RefreshEngine($http, $dyn, $expert_mode_off_button);
    } else {
      $this->RefreshEngine($http, $dyn, $expert_mode_on_button);
    }
    $this->RefreshEngine($http, $dyn, $debug_button);
  } elsif(exists $this->GetPrivileges->{capability}->{NewDebug}) {
    $this->RefreshEngine($http, $dyn, $debug_button_the_way_we_want);
  } else {
    #print STDERR "No debug for you\n";
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
  my $user = $this->get_user;
  unless($user) { return }
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
