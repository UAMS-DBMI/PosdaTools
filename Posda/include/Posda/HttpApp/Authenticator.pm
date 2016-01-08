#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/HttpApp/Authenticator.pm,v $
#$Date: 2014/11/03 13:52:17 $
#$Revision: 1.3 $
#
use strict;
use Debug;
{
  package Posda::HttpApp::Authenticator;
  use Storable qw( store retrieve store_fd fd_retrieve );
  sub LoginResponse{
    my($this, $http, $dyn) = @_;
    my $user = $this->get_user;
    if($user) {
      if($this->{ExitOnLogout}){
        my $resp =
         '<span onClick="javascript:CloseThisWindow();">close' .
         '</span><br><?dyn="DebugButton"?>';
        $this->RefreshEngine($http, $dyn, $resp);
      } else {
        $this->RefreshEngine($http, $dyn, "Logged in: $user<br />" .
          '<span onClick="javascript:' .
          "PosdaGetRemoteMethod('AppControllerLogout', ''," .
          'function(){});">logout</span><br />' .
          '<?dyn="DebugButton"?>');
      }
    } else {
      $this->RefreshEngine($http, $dyn,
        '<form onSubmit="' .
        "PosdaGetRemoteMethod('AppControllerLogin'," .
        "'name='+this.elements['UserName'].value+'&amp;" .
        "password='+this.elements['UserEnteredPassword'].value, null);" .
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
  sub AppControllerLogout{
    my($this, $http, $dyn) = @_;
    $this->RevokeLogin;
    $this->AutoRefresh;
  }
  sub AppControllerLogin{
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
        $this->SetUserPrivs($user);
        $this->AutoRefresh;
      }
    } else {
      if($this->DbValidation($user, $passwd)){
        $this->SetPrivs($user);
        $this->AutoRefresh;
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
  sub SetUserPrivs{
    my($this, $user) = @_;
    my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
    $sess->{AuthUser} = $user;
    my $cap_config = $main::HTTP_APP_CONFIG->{config}->{Capabilities};
    $sess->{Privileges}->{capability} = $cap_config->{$user};
    $this->{capability} = $cap_config->{$user};
  }
  sub RevokeLogin{
    my($this) = @_;
    my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
    delete $sess->{AuthUser};
    delete $sess->{Privileges}->{capability};
    my $cap_config = $main::HTTP_APP_CONFIG->{config}->{Capabilities};
    delete $this->{capability};
    if(exists $cap_config->{Default}) {
      $this->{capability} = $cap_config->{Default};
    }
    $this->AutoRefresh;
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
}
1;
