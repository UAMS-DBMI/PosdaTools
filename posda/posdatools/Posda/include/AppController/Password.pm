#!/usr/bin/perl -w
#
use strict;
use POSIX 'strftime';
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::Controller;
use Posda::HttpApp::DebugWindow;
use AppController::Login;
use Debug;
my $dbg = sub {print @_};
{
  package AppController::Password;
  use vars qw( @ISA );
  @ISA = ("Posda::HttpApp::GenericMfWindow");
  my $base_content = <<EOF;
  <table style="width:100%" summary="window header">
    <tr>
      <td valign="top">
      <?dyn="Logo"?>
      </td>
      <td valign="top" align="left">
      <h2><?dyn="title"?></h2>
      </td>
      <td valign="top" align="right">
  <?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
  <?dyn="iframe" frameborder="0" child_path="WindowButtons"?>
      </td>
      <tr>
  </table>
  <?dyn="iframe" height="300" width="100%" child_path="Content"?>
  <hr>
EOF
#  <?dyn="iframe" height="1024" width="100%" child_path="Content"?>
  sub new{
    my($class, $sess, $path_name) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path_name);
    $this->{title} = "Password Maintenence";
    bless $this, $class;
    $this->{h} = 550;
    $this->{w} = 800;
    Posda::HttpApp::Controller->new($sess, $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($sess,
      $this->child_path("WindowButtons"), "Close", 0);
    AppController::Password::Content->new(
      $this->{session},$this->child_path("Content"));
    $this->{user} = $this->get_user;
    my $db_type = 
      $main::HTTP_APP_CONFIG->{config}->{Environment} ->{AuthenticationDbType};
    if($db_type && $db_type eq "File"){
      $this->{db_type} = "File";
      $this->{db_file} = $main::HTTP_APP_CONFIG->{config}->{Environment}
        ->{AuthenticationDbFileName};
    } else {
      $this->{db_type} = "Database";
      my $db_host =
        $main::HTTP_APP_CONFIG->{config}->{Environment}->{AuthenticationDbHost};
      my $db_name =
        $main::HTTP_APP_CONFIG->{config}->{Environment}->{AuthenticationDbName};
      my $db_user =
        $main::HTTP_APP_CONFIG->{config}->{Environment}->{AuthenticationDbUser};
      $this->{connect_string} = 
        "dbi:Pg:dbname=$db_name;host=$db_host;user=$db_user";
    }
    $this->SetUsers;
    return $this;
  }
  sub SetUsers{
    my($this) = @_;
    if($this->{db_type} eq "File"){
      open my $fh, "<$this->{db_file}" or die "Can't open $this->{db_file}";
      while(my $l = <$fh>){
        chomp $l;
        my($usr, $pwd, $is_cur, $name) = split(/\|/, $l);
        if($is_cur){
          $this->{users}->{$usr} = $name;
          $this->{enc_passwd}->{$usr} = $pwd;
        } else {
          delete $this->{users}->{$usr};
          delete $this->{enc_passwd}->{$usr};
        }
      }
    } else {
      my $db = DBI->connect(
        $this->{connect_string}, "", "");
      unless($db) {die "can't connect to db"}
      my $user_q = $db->prepare(
        "select distinct user_id, real_name, enc_passwd from users");
      $user_q->execute;
      $this->{users} = {};
      while(my $h = $user_q->fetchrow_hashref){
        $this->{users}->{$h->{user_id}} = $h->{real_name};
        $this->{enc_passwd}->{$h->{user_id}} = $h->{enc_passwd};
      }
    }
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $base_content);
  }
  sub ControlForm{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, 
      'Show <?dyn="NoLines"?> Lines <?dyn="DisplayPosition"?> of' .
      ' <?dyn="DisplaySource"?>'
    );
  }
  sub DESTROY{
    my($this) = @_;
    $this->delete_children();
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
}
{
  package AppController::Password::Content;
  use vars qw( @ISA );
  @ISA = ("Posda::HttpApp::GenericIframe");
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe::new($class, $sess, $path);
    $this->{State} = "Initial";
    return bless $this, $class;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->{users} = $this->parent->{users};
    $this->{user} = $this->get_user;
    $this->{IsExpert} = $this->IsExpert;
    $this->{IsAdmin} = $this->HasPrivilege("IsAdmin");
    $this->RefreshEngine($http, $dyn, '<hr>');
    if($this->{IsAdmin} && $this->{IsExpert}) {
      return $this->AdminContent($http, $dyn);
    }
    $this->ChangeOwnPasswordForm($http, $dyn);
  }
  sub AdminContent{
    my($this, $http, $dyn) = @_;
    my $admin_menu = '<?dyn="Button" op="AddUser" caption="Add User"?>' .
      '<?dyn="Button" op="ChangeOwnPassword" caption="Change Own Password"?>' .
      '<?dyn="Button" op="ChangeUserPw" caption="Change Users Password"?>' .
      '<?dyn="Button" op="DeleteUser" caption="DeleteUser"?>';
    if($this->{State} eq "Initial"){
      $this->RefreshEngine($http, $dyn, $admin_menu);
    } elsif($this->{State} eq "AddUser"){
      $this->AddUserForm($http, $dyn);
    } elsif($this->{State} eq "ChangeOwnPassword"){
      $this->ChangeOwnPasswordForm($http, $dyn);
    } elsif($this->{State} eq "ChangeUserPassword"){
      $this->ChangeUserPasswordForm($http, $dyn);
    } elsif($this->{State} eq "DeleteUser"){
      $this->DeleteUserForm($http, $dyn);
    }
  }
  sub AddUser{
    my($this, $http, $dyn) = @_;
    delete $this->{message};
    $this->{State} = "AddUser";
    $this->AutoRefresh;
  }
  sub ChangeOwnPassword{
    my($this, $http, $dyn) = @_;
    delete $this->{message};
    $this->{State} = "ChangeOwnPassword";
    $this->AutoRefresh;
  }
  sub ChangeUserPw{
    my($this, $http, $dyn) = @_;
    delete $this->{message};
    $this->{State} = "ChangeUserPassword";
    $this->AutoRefresh;
  }
  sub DeleteUser{
    my($this, $http, $dyn) = @_;
    delete $this->{message};
    $this->{State} = "DeleteUser";
    $this->AutoRefresh;
  }
  sub AddUserForm{
    my($this, $http, $dyn) = @_;
    my $form = 
      '<?dyn="Message"?><br>' .
      '<form method="POST" ' .
      'action="CreateUser?obj_path=' .
      '<?dyn="q_path"?>">' .
      '<table><tr><th colspan=2>Create a new user</th></tr>' .
      '<tr>' .
      '<td align="right"><small>User Login Id:</td>' .
      '<td align="left">' .
      '<input type=text name="UserId"' .
      'value="<?dyn="GetParm" parm="UserId"?>">' .
      '</td>' .
      '</tr>' .
      '<tr>' .
      '<td align="right"><small>User Name:</small></td>' .
      '<td align="left">' .
      '<input type=text name="UserName"' .
      'value="<?dyn="GetParm" parm="UserName"?>">' .
      '</td>' .
      '</tr>' .
      '<tr>' .
      '<td align="right"><small>Initial (User) Password:</small></td>' .
      '<td align="left">' .
      '<input type=password name="Pass1"</td>' .
      '</tr>' .
      '<tr>' .
      '<td align="right"><small>Repeat (User) Password:</small></td>' .
      '<td align="left">' .
      '<input type=password name="Pass2"</td>' .
      '</tr>' .
      '<tr>' .
      '<td align="right"><small>Your Password:</small></td>' .
      '<td align="left">' .
      '<input type=password name="AdminPass"</td>' .
      '</tr>' .
      '<tr>' .
      '<td align="left">' .
      '<input type="submit" name="CreateUser"' .
      'value="CreateUser">' . 
      '<input type="submit" name="Done" value="Done">' .
      '</td>' .
      '</tr>' .
      '</table></form>';
    $this->RefreshEngine($http, $dyn, $form);
  }
  sub GetParm{
    my($this, $http, $dyn) = @_;
    $http->queue($this->{$dyn->{parm}});
  }
  sub CreateUser{
    my($this, $http, $dyn) = @_;
    $http->ParseIncomingForm;
    my($user_id, $user_name, $Pass1, $Pass2, $Op, $AdminPass);
    for my $i (keys %{$http->{form}}){
      if($i eq "Done"){ $Op = $i }
      elsif($i eq "UserId") { $user_id = $http->{form}->{$i} }
      elsif($i eq "UserName"){ $user_name = $http->{form}->{$i} }
      elsif($i eq "Pass1") { $Pass1 = $http->{form}->{$i} }
      elsif($i eq "Pass2") { $Pass2 = $http->{form}->{$i} }
      elsif($i eq "AdminPass") { $AdminPass = $http->{form}->{$i} }
      elsif($i eq "CreateUser") { $Op = $i }
    }
    if($Op eq "Done") {
      delete $this->{message};
      $this->{State} = "Initial";
      $this->AutoRefresh;
      return;
    }
    if($this->BadPw($this->{user}, $AdminPass)){
      $this->{message} = "Error: Bad Admin Password";
      $this->AutoRefresh;
      return;
    }
    if($this->parent->{db_type} && $this->parent->{db_type} eq "File"){
      my $users = $this->parent->{users};
      my $passwd = $this->parent->{enc_passwd};
      my $file = $this->parent->{db_file};
      if(exists $this->{users}->{$user_id}){
        $this->{message} = "Error: a user with an id of \"$user_id\" already " .
           "exists";
        $this->AutoRefresh;
        return;
      }
      unless($Pass1 eq $Pass2){
        $this->{message} = "Error: New Passwords don't match";
        $this->AutoRefresh;
        return;
      }
      unless(length($Pass1) > 6){
        $this->{message} = "Error: Try a longer password";
        $this->AutoRefresh;
        return;
      }
      my $crypted = crypt($Pass1,
        join '', ('.', '/', 0..9, 'A'..'Z', 'a'..'z')[rand 64, rand 64] );
      open my $fh, ">>$file" or die "Can't open $file for append";
      print $fh "$user_id|$crypted|1|$user_name\n";
      close $fh;
      $this->{message} = "Created user $user_id";
      $this->parent->SetUsers;
      $this->AutoRefresh;
    } else {
      my $db = DBI->connect($this->parent->{connect_string}, "", "");
      my $q = $db->prepare("select * from users where user_id = ?");
      $q->execute($user_id);
      my $h = $q->fetchrow_hashref();
      $q->finish();
      if(defined $h){
        $this->{message} = "Error: a user with an id of \"$user_id\" already " .
           "exists";
        $db->disconnect();
        $this->AutoRefresh;
        return;
      }
      unless($Pass1 eq $Pass2){
        $this->{message} = "Error: New Passwords don't match";
        $db->disconnect();
        $this->AutoRefresh;
        return;
      }
      unless(length($Pass1) > 6){
        $this->{message} = "Error: Try a longer password";
        $db->disconnect();
        $this->AutoRefresh;
        return;
      }
      my $crypted = crypt($Pass1,
        join '', ('.', '/', 0..9, 'A'..'Z', 'a'..'z')[rand 64, rand 64] );
      my $in = $db->prepare(
        "insert into users (\n" .
        "  user_id, real_name, enc_passwd)\n" .
        "values (\n" .
        "  ?, ?, ?)"
      );
      $in->execute($user_id, $user_name, $crypted);
      $db->disconnect();
      $this->{message} = "Created user $user_id";
      $this->parent->SetUsers;
      $this->AutoRefresh;
    }
  }
  sub ChangeOwnPasswordForm{
    my($this, $http, $dyn) = @_;
    my $form = 
      '<?dyn="Message"?><br>' .
      '<form method="POST" ' .
      'action="ChangeOwnPasswordAction?obj_path=' .
      '<?dyn="q_path"?>">' .
      '<table><tr><th colspan=2>Change Password for ' .
      '<?dyn="GetParm" parm="user"?> ' .
      '</th></tr>' .
      '<tr>' .
      '<td align="right"><small>Old Password:</small></td>' .
      '<td align="left">' .
      '<input type=password name="OldPass"</td>' .
      '</tr>' .
      '<tr>' .
      '<td align="right"><small>New Password:</small></td>' .
      '<td align="left">' .
      '<input type=password name="Pass1"</td>' .
      '</tr>' .
      '<tr>' .
      '<td align="right"><small>Repeat New Password:</small></td>' .
      '<td align="left">' .
      '<input type=password name="Pass2"</td>' .
      '</tr>' .
      '<tr>' .
      '<td align="left">' .
      '<input type="submit" name="ChangePassword"' .
      'value="Change Password">' . 
      '<input type="submit" name="Done" value="Done">' .
      '</td>' .
      '</tr>' .
      '</table></form>';
    $this->RefreshEngine($http, $dyn, $form);
  }
  sub ChangeOwnPasswordAction{
    my($this, $http, $dyn) = @_;
    $http->ParseIncomingForm;
    my($user_id, $OldPass, $Pass1, $Pass2, $Op);
    for my $i (keys %{$http->{form}}){
      if($i eq "Done"){ $Op = $i }
      elsif($i eq "OldPass") { $OldPass = $http->{form}->{$i} }
      elsif($i eq "Pass1") { $Pass1 = $http->{form}->{$i} }
      elsif($i eq "Pass2") { $Pass2 = $http->{form}->{$i} }
      elsif($i eq "ChangePassword") { $Op = $i }
    }
    if($Op eq "Done") {
      if($this->{IsAdmin} && $this->{IsExpert}){
        delete $this->{message};
        $this->{State} = "Initial";
        $this->AutoRefresh;
      } else {
        $this->sibling("WindowButtons")->WindowsButtonsClose($http, $dyn);
      }
      return;
    }
    if($this->BadPw($this->{user}, $OldPass)){
      $this->{message} = "Error: Bad Password for $this->{user}";
      $this->AutoRefresh;
      return;
    }
    $this->DoPasswordChange($this->{user}, $Pass1);
    $this->{message} = "Changed password for user $this->{user}";
    $this->AutoRefresh;
  }
  sub ChangeUserPasswordForm{
    my($this, $http, $dyn) = @_;
    my $form = 
      '<?dyn="Message"?><br>' .
      '<form method="POST" ' .
      'action="ChangeUserPasswordAction?obj_path=' .
      '<?dyn="q_path"?>">' .
      '<table><tr><th colspan=2>Change Password for ' .
      '<?dyn="UserSelect"?> ' .
      '</th></tr>' .
      '<tr>' .
      '<td align="right"><small>Your Password:</small></td>' .
      '<td align="left">' .
      '<input type=password name="AdminPass"</td>' .
      '</tr>' .
      '<tr>' .
      '<td align="right"><small>New (Users) Password:</small></td>' .
      '<td align="left">' .
      '<input type=password name="Pass1"</td>' .
      '</tr>' .
      '<tr>' .
      '<td align="right"><small>Repeat New (Users) Password:</small></td>' .
      '<td align="left">' .
      '<input type=password name="Pass2"</td>' .
      '</tr>' .
      '<tr>' .
      '<td align="left">' .
      '<input type="submit" name="ChangePassword"' .
      'value="Change Password">' . 
      '<input type="submit" name="Done" value="Done">' .
      '</td>' .
      '</tr>' .
      '</table></form>';
    $this->RefreshEngine($http, $dyn, $form);
  }
  sub UserSelect{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, 
      '<select name="UserForPassword">' .
      '<?dyn="UserList"?>' .
      '</select>');
  }
  sub UserList{
    my($this, $http, $dyn) = @_;
    for my $i (sort keys %{$this->{users}}){
      $http->queue("<option value=\"$i\">$i - $this->{users}->{$i}</option>");
    }
  }
  sub ChangeUserPasswordAction{
    my($this, $http, $dyn) = @_;
    $http->ParseIncomingForm;
    my($user_id, $Pass1, $Pass2, $Op, $AdminPass);
    for my $i (keys %{$http->{form}}){
      if($i eq "Done"){ $Op = $i }
      elsif($i eq "UserForPassword") { $user_id = $http->{form}->{$i} }
      elsif($i eq "AdminPass") { $AdminPass = $http->{form}->{$i} }
      elsif($i eq "Pass1") { $Pass1 = $http->{form}->{$i} }
      elsif($i eq "Pass2") { $Pass2 = $http->{form}->{$i} }
      elsif($i eq "ChangePassword") { $Op = $i }
    }
    if($Op eq "Done") {
      delete $this->{message};
      $this->{State} = "Initial";
      $this->AutoRefresh;
      return;
    }
    if($this->BadPw($this->{user}, $AdminPass)){
      $this->{message} = "Error: Bad Admin Password";
      return $this->AutoRefresh;
    }
    unless($Pass1 eq $Pass2){
      $this->{message} = "Error: Passwords Don't match";
      return $this->AutoRefresh;
    }
    $this->DoPasswordChange($user_id, $Pass1);
    $this->{message} = "Changed Password for user $user_id";
    $this->AutoRefresh;
  }
  sub DoPasswordChange{
    my($this, $user, $passwd) = @_;
    if($this->parent->{db_type} && $this->parent->{db_type} eq "File"){
      my $users = $this->parent->{users};
      my $name = $users->{$user};
      my $file = $this->parent->{db_file};
      my $crypted = crypt($passwd,
        join '', ('.', '/', 0..9, 'A'..'Z', 'a'..'z')[rand 64, rand 64] );
      open my $fh, ">>$file" or die "Can't open $file for append";
      print $fh "$user|$crypted|1|$name\n";
      close $fh;
      $this->parent->SetUsers;
    } else {
      my $db = DBI->connect($this->parent->{connect_string}, "", "");
      my $crypted = crypt($passwd,
        join '', ('.', '/', 0..9, 'A'..'Z', 'a'..'z')[rand 64, rand 64] );
      my $in = $db->prepare(
        "update users\n" .
        "  set enc_passwd = ?\n" .
        "where\n" .
        "  user_id = ?"
      );
      $in->execute($crypted, $user);
      $db->disconnect();
    }
  }
  sub DeleteUserForm{
    my($this, $http, $dyn) = @_;
    my $form = 
      '<?dyn="Message"?><br>' .
      '<form method="POST" ' .
      'action="DeleteUserAction?obj_path=' .
      '<?dyn="q_path"?>">' .
      '<table><tr><th colspan=2>DeleteUser ' .
      '<?dyn="UserSelect"?> ' .
      '</th></tr>' .
      '<tr>' .
      '<td align="right"><small>Your Password:</small></td>' .
      '<td align="left">' .
      '<input type=password name="AdminPass"</td>' .
      '</tr>' .
      '<tr>' .
      '<td align="left">' .
      '<input type="submit" name="DeleteUser"' .
      'value="Delete User">' . 
      '<input type="submit" name="Done" value="Done">' .
      '</td>' .
      '</tr>' .
      '</table></form>';
    $this->RefreshEngine($http, $dyn, $form);
  }
  sub DeleteUserAction{
    my($this, $http, $dyn) = @_;
    $http->ParseIncomingForm;
    my($user_id, $AdminPass, $Op);
    for my $i (keys %{$http->{form}}){
      if($i eq "Done"){ $Op = $i }
      elsif($i eq "AdminPass") { $AdminPass = $http->{form}->{$i} }
      elsif($i eq "UserForPassword") { $user_id = $http->{form}->{$i} }
      elsif($i eq "DeleteUser") { $Op = $i }
    }
    if($Op eq "Done") {
      delete $this->{message};
      $this->{State} = "Initial";
      $this->AutoRefresh;
      return;
    }
    if($this->BadPw($this->{user}, $AdminPass)){
      $this->{message} = "Error: Wrong admin password";
      $this->AutoRefresh;
      return;
    }
    if($this->parent->{db_type} && $this->parent->{db_type} eq "File"){
      my $users = $this->parent->{users};
      my $passwds = $this->parent->{enc_passwd};
      my $file = $this->parent->{db_file};
      open my $fh, ">>$file" or die "Can't open $file";
      my $enc_passwd = $passwds->{$user_id};
      my $name = $users->{$user_id};
      print $fh "$user_id|$enc_passwd|0|$name\n";
      close $fh;
    } else {
      my $db = DBI->connect($this->parent->{connect_string}, "", "");
      my $q = $db->prepare("delete from users where user_id = ?");
      $q->execute($user_id);
    }
    $this->parent->SetUsers;
    $this->{message} = "Deleted user $user_id";
    $this->AutoRefresh;
  }
  sub BadPw{
    my($this, $user, $Pass1) = @_;
    if($this->parent->{db_type} && $this->parent->{db_type} eq "File"){
      my $users = $this->parent->{users};
      my $passwds = $this->parent->{enc_passwd};
      my $enc_passwd = $passwds->{$user};
      my $crypted = crypt($Pass1, $enc_passwd);
      if($crypted eq $enc_passwd) { return 0 } else { return 1 }
    } else {
      my $db = DBI->connect($this->parent->{connect_string}, "", "");
      my $q = $db->prepare("select enc_passwd from users where user_id = ?");
      $q->execute($user);
      my $h = $q->fetchrow_hashref;
      $q->finish;
      my $crypted = crypt($Pass1, $h->{enc_passwd});
      if($crypted eq $h->{enc_passwd}) { return 0 } else { return 1 }
    }
  }
  sub Message{
    my($this, $http, $dyn) = @_;
    unless($this->{message}) { return }
    $http->queue("<h3>$this->{message}</h3>");
  }
  sub DESTROY{
    my($this) = @_;
  }
}
1;
