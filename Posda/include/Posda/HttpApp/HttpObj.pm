#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Dispatch::NamedObject;
package Posda::HttpObj;
use Socket;
use JSON::PP;
use File::Path;
use Storable qw( store retrieve store_fd fd_retrieve );
#################################################
##  Login stuff goes here
use Debug;
#my $dbg = sub { print STDERR @_ };
use Cwd;
use vars qw( @ISA );
@ISA = qw( Dispatch::NamedObject );
my $login_one = <<EOF;
<!DOCTYPE html
        PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>
EOF
my $login_one_one = <<EOF;
</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf8" />
</head><body onLoad="self.focus();document.LoginForm.user.focus();">
<table width="100%">
<tr><td>
EOF
my $login_one_5 = <<EOF;
</td><td valign="top" align="left">
EOF
my $login_two = <<EOF;
<form method=POST name="LoginForm"
EOF
my $login_three = <<EOF;
<h1>Welcome to
EOF
my $login_four =<<EOF;
<p>You are not logged in.  Please login below:</p>
<table><tr><td align="right" valign="top">User:</td>
<td align="left" valign="top"><input type="text" name="user"></td></tr>
<tr><td align="right" valign="top">Password:</td>
<td align="left" valign="top"><input type="password" name="passwd"></td></tr>
</table>
<input type="submit" name="login" value="Login">
<input type="submit" name="cancel" value="Cancel">
</form>
</td></tr></table>
</body></html>
EOF
my $shutdown_screen = <<EOF;
HTTP/1.0 200 Created
Content-Type: text/html

<!DOCTYPE html
PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html><head><title>Close Me Please</title></head>
<body onLoad="if(window.opener) try { window.opener.focus() } catch (e) {};
try { self.close() } catch (e) {};">
<h1>Goodbye</h1><p>This window should be closed.
If it didn't close, please close it.</p>
</body></html>
EOF
sub Login {
  my($this, $http, $app) = @_;
  my $app_name = $main::HTTP_APP_CONFIG->{dir};
  $0 = $Dispatch::Http::App::Server::ServerPort .
     " AppController ($app_name)" .
     " awaiting login";
  unless($http->{method} eq "POST"){
    my $session = $this->NewSession();
    my $sess = $this->GetSession($session);
    my $LoginTitle = 
      $main::HTTP_APP_CONFIG->{config}->{Identity}->{LoginTitle};
    $http->HtmlHeader();
    $http->queue($login_one);
    $http->queue($LoginTitle);
    $http->queue($login_one_one);
    my $image = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoImage};
    my $height = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoHeight};
    my $width = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
    my $alt = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoAlt};
    $http->queue("<img src=\"$image\" height=\"$height\" " .
      "width=\"$width\" alt=\"$alt\"");
    $http->queue($login_one_5 .
      $login_two .
      "action=\"login\">" .
      "<input type=\"hidden\" name=\"session\" " .
      "value=\"$session\">"
    );
    if(defined $http->{header}->{http_referer}){
      $http->queue("<input type=\"hidden\" name=\"referrer\" " .
        "value=\"$http->{header}->{http_referer}\">" .
        $login_three);
    } else {
      $http->queue($login_three);
    }
    Posda::HttpObj->HostName($http, {});
    $http->queue("</h1><h4>$LoginTitle</h4>");
    $http->queue($login_four);
    return;
  }
  $http->ParseIncomingForm();
  if(exists($http->{form}->{cancel})){
    return CancelLogin($this, $http, $app);
  }
  my $session = $http->{form}->{session};
  my $sess = $this->GetSession($session);
  unless(defined $sess){
    $http->queue($shutdown_screen);
    return;
  }
  my($real_user, $auth_user);
  if($http->{form}->{user} =~ /^(.*)\/(.*)$/){
    $real_user = $1;
    $auth_user = $2;
  } else {
    $real_user = $http->{form}->{user};
    $auth_user = $http->{form}->{user};
  }
 if(ValidateLogin($this, $real_user, $auth_user, $http->{form}->{passwd})){
    LoginSuccessful($this,
      $http, $app, $sess, $session, $auth_user, $real_user);
  } else {
    LoginFailed($this, $http, $app, $session);
  }
}
sub ValidateLogin{
  my($this, $real_user, $auth_user, $password) = @_;
  my $db_type =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{AuthenticationDbType};
  if(defined($db_type) && $db_type eq "File"){
    my $file =
      $main::HTTP_APP_CONFIG->{config}->{Environment}
        ->{AuthenticationDbFileName};
    return ValidateDbFileLogin(
      $this, $real_user, $auth_user, $password, $file);
  } else {
    return ValidateDbLogin($this, $real_user, $auth_user, $password);
  }
}
sub ValidateDbFileLogin{
  my($this, $real_user, $auth_user, $password, $file) = @_;
  open my $fh, "<$file" or return undef;
  my %logins;
  while(my $l = <$fh>){
    chomp $l;
    my($usr, $pwd, $is_sup) = split(/\|/, $l);
    $logins{$usr} = $pwd;
  }
  close $fh;
  unless(exists $logins{$auth_user}) { return undef }
  unless(
    crypt($password, $logins{$auth_user}) eq $logins{$auth_user}
  ){ return undef }
  return 1;
}
sub ValidateDbLogin{
  my($this, $real_user, $auth_user, $password) = @_;
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
  if($db) {
    my $q = $db->prepare(
      "select enc_passwd, is_super from users where user_id = ?");
    $q->execute($real_user);
    my $h = $q->fetchrow_hashref;
    $q->finish;
    my $enc_passwd = $h->{enc_passwd};
    if(
      !defined($h) ||
      !defined($enc_passwd) ||
      ($real_user ne $auth_user && !$h->{is_super}) ||
      $enc_passwd eq "" ||
      crypt($password, $enc_passwd) ne $enc_passwd
    ){
      $db->disconnect();
      return undef;
    }
    ##### Here for successful DB Login
    ##### refresh password cache
    if(defined $db_cache_file){
      my $passwords;
      my $random = int rand(10000);
      my $new_cache_file = $db_cache_file . "_$random";
      $q = $db->prepare("select user_id, enc_passwd, is_super from users");
      $q->execute;
      while(my $h = $q->fetchrow_hashref){
        $passwords->{$h->{user_id}} = {
          enc_passwd => $h->{enc_passwd},
          is_super => $h->{is_super}
        };
      }
      open my $fh, ">$new_cache_file" or die "can't open $new_cache_file";
      store_fd $passwords, $fh;
      close($fh);
      if(-e $db_cache_file){
        unless(unlink $db_cache_file){
          print STDERR "Can't unlink $db_cache_file: $!\n"
        }
      }
      unless(link $new_cache_file, $db_cache_file) {
        print STDERR "Can't link $new_cache_file to $db_cache_file: $!\n";
      }
      unlink $new_cache_file;
    }
    $db->disconnect();
    return 1;
  } else {
    ##### Here if DB down
    ##### use login cache
    my $passwords;
    if(-r $db_cache_file){
      open my $fh, "<$db_cache_file" or die "Can't open $db_cache_file";
      $passwords = fd_retrieve($fh);
    } else {
      die "Database down and no cache file for passwords";
    }
    if(
      !defined($passwords->{$auth_user}->{enc_passwd}) ||
      $passwords->{$auth_user} eq "" ||
      ($real_user ne $auth_user && !$passwords->{auth_user}->{is_super}) ||
      crypt($password, $passwords->{$auth_user}->{enc_passwd}) ne 
      $passwords->{$auth_user}->{enc_passwd}
    ){
      return undef;
    } else {
      return 1;
    }
  }
}
sub LoginSuccessful{
  my($this, $http, $app, $sess, $session, $auth_user, $real_user) = @_;
  $sess->{logged_in} = 1;
  $sess->{AuthUser} = $auth_user;
  $sess->{real_user} = $real_user;
  my $app_name = $main::HTTP_APP_CONFIG->{dir};
  $0 = $Dispatch::Http::App::Server::ServerPort .
    " AppController ($app_name)" .
    " with login: $auth_user $real_user";
  print "Logged in $auth_user $real_user\n";
  $sess->{DieOnTimeout} = 1;
#    my $color = Posda::BgColor::GetUnusedColor;
#    $sess->{bgcolor} = "$color";
  StartLogin($this, $http, $app, $session);
}
sub LoginFailed{
  my($this, $http, $app, $session) = @_;
  $http->HtmlHeader();
  my $LoginTitle = 
    $main::HTTP_APP_CONFIG->{config}->{Identity}->{LoginTitle};
  $http->queue($login_one);
  $http->queue($LoginTitle);
  $http->queue($login_one_one);
  my $image = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoImage};
  my $height = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoHeight};
  my $width = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
  my $alt = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoAlt};
  $http->queue("<img src=\"$image\" height=\"$height\" " .
    "width=\"$width\" alt=\"$alt\"");
  $http->queue($login_one_5 .
    "Failed to login - bad password??" .
    $login_two .
    "action=\"login\">" .
    "<input type=\"hidden\" name=\"session\" " .
    "value=\"$session\">");
  if(defined $http->{header}->{http_referer}){
    $http->queue("<input type=\"hidden\" name=\"referrer\" " .
    "value=\"$http->{header}->{http_referer}\">");
  }
  $http->queue($login_three);
  Posda::HttpObj->HostName($http, {});
  $http->queue("</h1><h4>$LoginTitle</h4>");
  $http->queue($login_four);
}
# Null Login
sub NullLogin {
  my($this, $http, $app) = @_;
  my $session = $this->NewSession();
  my $sess = $this->GetSession($session);
  $sess->{DieOnTimeout} = 1;
  my $app_name = $main::HTTP_APP_CONFIG->{dir};
  $0 = $Dispatch::Http::App::Server::ServerPort .
    " AppController ($app_name)" .
    " with null login";
  StartLogin($this, $http, $app, $session);
}
sub StartLogin{
  my($this, $http, $app, $session) = @_;
  &{$this->{app_root}->{app_init}}($this, $session);
  my $url = "http://$http->{header}->{host}/$session/" .
           "Refresh?obj_path=$this->{app_root}->{app_name}";
  # print "Logins::LoginScreen::Login: dest_obj: $dest_obj, url: $url.\n";
  $http->HeaderSent;
  $http->queue("HTTP/1.0 201 Created\n" .
    "Location: $url\n" .
    "Content-Type: text/html\n\n" .
    "<!DOCTYPE html " .
    "PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" " .
    "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">" .
    "\n<html><head>" .
    "<meta http-equiv=\"refresh\" content=\"0;" .
    "URL=$url\" />" .
    "\n<script>" .
    " CNTLrefresh=window.setTimeout(function(){window.location.href=\"$url\"},1000);" .
    "\n</script>" .
    "</head>\n<body>logged in OK, redirecting...." .
    "\n<a href=\"$url\">$url</a>\n" .
    "</body></html>");
}
sub InitApp{
  my($class, $sess, $app_name) = @_;
  my $obj = $class->new($sess, $app_name);
  return $obj;
}
my $close = <<EOF;
HTTP/1.0 201 Created
Location: <?dyn="echo" field="url"?>
Content-Type: text/html

<!DOCTYPE html
PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html><head><title>Close Me Please</title></head>
<body onLoad="if(window.opener) try { window.opener.focus() } catch (e) {};
try { self.close() } catch (e) {};">
<h1>Goodbye</h1><p>This window should be closed.
If it didn't close, please close it.</p>
</body></html>
EOF
sub Shutdown{
  my($this, $http, $dyn) = @_;
  my $url = "http://$http->{header}->{host}/";
  print "Application Terminated Normally\n";
  $this->RefreshEngine($http, {url => $url}, $close);
  $this->shutdown($http, $dyn);
}
sub CancelLogin{
  my($this, $http, $app) = @_;
  $http->queue($close);
  my $exiter = Dispatch::EventHandler::MakeExit();
  my $bkg = Dispatch::Select::Background->new($exiter);
  $bkg = $bkg->timer(2);
}
sub new {
  my($class, $session, $name) = @_;
  my $this = Dispatch::NamedObject->new($session, $name);
  $this->{ImportsFromAbove}->{Controller} = 1;
  return bless $this, $class;
};
sub DeleteObjLink{
  my($this, $http, $dyn) = @_;
  if(exists $dyn->{delete}){
    $this->DeleteObj($dyn->{delete});
  }
  my $method = "Refresh";
  if(exists $dyn->{method}){
    $method = $dyn->{method};
  }
  my $obj = $this->{path};
  if(exists $dyn->{obj}) { $obj = $dyn->{obj} }
  $this->Redirect($http, { url => "$method?obj_path=$obj" });
}
sub echo{
  my($this, $http, $dyn) = @_;
  unless (exists $dyn->{$dyn->{field}}) {
    my $class = ref($this);
    print STDERR $class . "::RefreshEngine: obj: $this->{path} called.\n";
    print STDERR 
      "  echo of field: $dyn->{field} failed, not defined.\n";
    my($package, $filename, $line, $subroutine, $hasargs,
    $wantarray, $evaltext, $is_require, $hints, $bit_mask);
    for my $i (1 .. 20){
      ($package, $filename, $line, $subroutine, $hasargs,
      $wantarray, $evaltext, $is_require, $hints, $bit_mask) = caller($i);
      unless (defined $filename) { last; }
      print STDERR "\tfrom:$filename, $line\n";
    }
    return;
  }
  $http->queue($dyn->{$dyn->{field}});
}
sub echo_esc{
  my($this, $http, $dyn) = @_;
  unless (exists $dyn->{$dyn->{field}}) {
    my $class = ref($this);
    print STDERR $class . "::RefreshEngine: obj: $this->{path} called.\n";
    print STDERR 
      "  echo_esc of field: $dyn->{field} failed, not defined.\n";
    my($package, $filename, $line, $subroutine, $hasargs,
    $wantarray, $evaltext, $is_require, $hints, $bit_mask);
    for my $i (1 .. 20){
      ($package, $filename, $line, $subroutine, $hasargs,
      $wantarray, $evaltext, $is_require, $hints, $bit_mask) = caller($i);
      unless (defined $filename) { last; }
      print STDERR "\tfrom:$filename, $line\n";
    }
    return;
  }
  my $foo = $dyn->{$dyn->{field}};
  $foo =~ s/([^\w])/"%" . unpack("H2", $1)/eg;
  $http->queue($foo);
}
sub set_expander{
  my($this, $expander) = @_;
  $this->{expander} = $expander;
}
sub iframe_name{
  my($this) = @_;
  my $foo = $this->{path};
  # $foo =~ s/\//_/g;
  return $foo;
}
sub sibling_refresh{
  my($this, $name) = @_;
  my $obj = $this->sibling($name);
  if($obj && $obj->can("AutoRefresh")){
    $obj->AutoRefresh;
  }
}
sub RefreshEngine {
  my($this, $queue, $dyn, $template) = @_;
  my $remaining = $template;
  my $InSym = 0;
  my $command;
  unless (defined $queue) {
    my $class = ref($this);
    print STDERR $class . "::RefreshEngine: obj: $this->{path} called with undef queue.\n";
    my($package, $filename, $line, $subroutine, $hasargs,
    $wantarray, $evaltext, $is_require, $hints, $bit_mask);
    for my $i (1 .. 20){
      ($package, $filename, $line, $subroutine, $hasargs,
      $wantarray, $evaltext, $is_require, $hints, $bit_mask) = caller($i);
      unless (defined $filename) { last; }
      print STDERR "\tfrom:$filename, $line\n";
    }
    return;
  }
  outer:
  while($remaining){
    unless($InSym){
      if($remaining =~ /^([^<]+)(\<.*)/s){
        my $seen = $1;
        $remaining = $2;
        $queue->queue($seen);
        redo outer;
      } elsif($remaining =~ /^(\<[^\?])(.*)/s){
        my $seen = $1;
        $remaining = $2;
        $queue->queue($seen);
        redo outer;
      } elsif($remaining =~ /^\<\?(.*)/s){
        $remaining = $1;
        $InSym = 1;
        redo outer;
      } else {
        $queue->queue($remaining);
        $remaining = "";
        next outer;
      }
    }
    if($remaining =~ /^(.*?)\?\>(.*)/s){
      my $first = $1;
      my $second = $2;
      $command .= $first;
      $remaining = $second;
      $this->ExpandMethod($command, $queue, $dyn);
      $command = "";
      $InSym = 0;
      redo outer;
    } else {
      $command .= $remaining;
      $queue->queue("Error (here) in expanding command: \"$command\"\n");
      $remaining = "";
    }
  }
}
sub ExpandMethod{
  my($this, $command, $queue, $dyn) = @_;
  unless($command =~ /^dyn=\"(\w+)\"(.*)$/){
    print STDERR "Invalid command \"$command\"\n";
    return;
  }
  my $method = $1;
  my $nvp_text = $2;
  my %nvp;
  if(
    defined($dyn) &&
    ref($dyn) eq "HASH"
  ){
    for my $i (keys %$dyn){
      $nvp{$i} = $dyn->{$i};
    }
  }
  while($nvp_text =~ /^\s*(\w+)=\"([^\"]*)\"(.*)$/){
    my $key = $1;
    my $value = $2;
    $nvp_text = $3;
    $nvp{$key} = $value;
    if ($key eq "obj_path"  &&
        $this->{path} ne $value) {
      $this = $this->get_obj($value);
    }
  }
  unless($nvp_text =~ /^\s*$/){
    print STDERR "remaining foo at end of dyn: \"$nvp_text\"\n";
  }
  $this->$method($queue, \%nvp);
}
sub MakeLinkJavaDyn{
  my($this, $http, $dyn) = @_;
  my $url;
  if(exists $dyn->{obj}){
    $url = "$dyn->{method}?obj_path=$dyn->{obj}";
  } else {
    $url = "$dyn->{method}?obj_path=$this->{path}";
  }
  if(exists $dyn->{value}){
    my $value = $dyn->{value};
    $url .= "&amp;value=$value";
  }
  if(exists $dyn->{dir}){
    my $dir = $dyn->{dir};
    $dir =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $url .= "&amp;dir=$dir";
  }
  if(exists $dyn->{root}){
    my $root = $dyn->{root};
    $root =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $url .= "&amp;root=$root"
  }
  if(exists $dyn->{param}){
    my $param = $dyn->{param};
    $param =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $url .= "&amp;param=$param";
  }
  if(exists $dyn->{refresh}){
    my $refresh = $dyn->{refresh};
    $refresh =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $http->queue("&amp;refresh=$refresh");
    $url .= "&amp;refresh=$refresh";
  }
  $http->queue("<a href=\"#\" onClick=\"self.location = '$url';\">$dyn->{caption}</a>");
}
sub MakeLinkDyn{
  my($this, $http, $dyn) = @_;
  if(exists $dyn->{obj}){
    $http->queue("<a href=\"$dyn->{method}?obj_path=$dyn->{obj}");
  } else {
    $http->queue("<a href=\"$dyn->{method}?obj_path=$this->{path}");
  }
  if(exists $dyn->{value}){
    my $value = $dyn->{value};
    $http->queue("&amp;value=$value");
  }
  if(exists $dyn->{dir}){
    my $dir = $dyn->{dir};
    $dir =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $http->queue("&amp;dir=$dir");
  }
  if(exists $dyn->{root}){
    my $root = $dyn->{root};
    $root =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $http->queue("&amp;root=$root");
  }
  if(exists $dyn->{param}){
    my $param = $dyn->{param};
    $param =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $http->queue("&amp;param=$param");
  }
  if(exists $dyn->{refresh}){
    my $refresh = $dyn->{refresh};
    $refresh =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $http->queue("&amp;refresh=$refresh");
  }
  $http->queue("\"");
  if(exists $dyn->{target}){
    $http->queue(" target=\"$dyn->{target}\"");
  }
  $http->queue(">$dyn->{caption}</a>");
}
sub MakeLink{
  my($this, $http, $method, $caption, $target) = @_;
  $http->queue("<a href=\"$method?obj_path=$this->{path}\"");
  if(defined $target){
    $http->queue(" target=\"$target\"");
  }
  $http->queue(">$caption</a>");
}
sub MakeSetParamLink{
  my($this, $http, $name, $value, $caption, $target) = @_;
  $http->queue("<a href=\"SetParamLink?" .
    "obj_path=$this->{path}&amp;name=$name&amp;value=$value\"");
  if(defined $target){
    $http->queue(" target=\"$target\"");
  }
  $http->queue(">$caption</a>");
}
sub MakeSetParamLinkDyn{
  my($this, $http, $dyn) = @_;
  my $name = $dyn->{param};
  my $value = $dyn->{value};
  my $caption = $dyn->{caption};
  my $target = $dyn->{target};
  $http->queue("<a href=\"SetParamLink?" .
    "obj_path=$this->{path}&amp;name=$name&amp;value=$value\"");
  if(defined $target){
    $http->queue(" target=\"$target\"");
  }
  $http->queue(">$caption</a>");
}
sub MakeDeleteParamLink{
  my($this, $http, $name, $caption, $target) = @_;
  $http->queue("<a href=\"DeleteParamLink?" .
    "obj_path=$this->{path}&amp;param=$name\"");
  if(defined $target){
    $http->queue(" target=\"$target\"");
  }
  $http->queue(">$caption</a>");
}
#########################################################
# Standard Methods
sub CancelRefreshFrame {
  my($this) = @_;
  my $controller = $this->Controller;
  if (defined $controller) {
    $controller->CancelRefreshFrame($this->iframe_name);
  }
}
sub Refresh {
  my($this, $queue, $dyn) = @_;
  if (defined $this->{HttpObjTimeToCloseWindow}) {
#print STDERR "HttpObj::Refresh HttpObjTimeToCloseWindow set, called on obj: $this->{path}.\n";
    return $this->DeleteCloseWindow($queue, $dyn);
  }
  my $obj_name = $this->{path};
  if(
    exists($dyn->{delegate}) &&
    $this->{path} ne $dyn->{delegate}
  ){
    $obj_name = $dyn->{delegate};
    $this = $this->get_obj($dyn->{delegate});
  }
  if($obj_name ne $this->{path}){
    $this->Die("obj named $obj_name has path $this->{path}");
  }
  my $expander = "expander";
  if(exists $dyn->{expander}){
    if(exists $this->{$dyn->{expander}}){
      $expander = $dyn->{expander};
    } else {
      print STDERR 
        "Object named \"$obj_name\" has no expander \"$dyn->{expander}\"\n";
    }
  }
  $this->CancelRefreshFrame;
  $this->RefreshEngine($queue, $dyn, $this->{$expander});
}
sub HandleForm{
  my($this, $http, $dyn) = @_;
  $http->ParseIncomingForm();
  my @items;
  for my $i (keys %{$http->{form}}){
    my($obj, $method, $id, $order) = split(/\+/, $i);
    push(@items, {
      obj_name => $obj,
      method => $method,
      id => $id,
      order => $order,
      value => $http->{form}->{$i},
    });
  }
  my @worklist = sort {$a->{order} <=> $b->{order}} @items;
  for my $i (@worklist){
    my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
    my $obj = $sess->{root}->{$i->{obj_name}};
    my $method = $i->{method};
    unless(defined $obj) { $this->Die("no object named $i->{obj_name}"); }
    if($obj->can($i->{method})){
      $obj->$method($i->{id}, $i->{value});
    } else {
      print STDERR "Object named $i->{obj_name} " .
        "doesn't support $i->{method}($i->{id}, $i->{value})\n";
    }
  }
  my $obj = $this->get_obj($dyn->{refresh});
  if(defined $dyn->{refresh_method}){
    my $method = $dyn->{refresh_method};
    $obj->$method($http, $dyn);
  } else {
    $obj->Refresh($http, $dyn);
  }
}
sub SetParamLink{
  my($this, $http, $dyn) = @_;
  my $param_name = $dyn->{name};
  my $param_value = $dyn->{value};
  $this->{$param_name} = $param_value;
  $this->Refresh($http, $dyn);
}
sub MakeSetValue{
  my($this, $http, $dyn) = @_;
  my $path = $this->{path};
  if($dyn->{path}) { $path = $dyn->{path} }
  my $method = "Refresh";
  unless(exists($dyn->{param}) && exists($dyn->{value})){
    print STDERR "No param or value in MakeSetValue\n";
    return;
  }
  $http->queue("<a href=\"SetValue?obj_path=$path" .
    "&amp;name=$dyn->{param}&amp;value=$dyn->{value}");
  if(exists $dyn->{method}){ $http->queue("&amp;method=$dyn->{method}") }
  if(exists $dyn->{obj}){ $http->queue("&amp;obj=$dyn->{obj}") }
  $http->queue("\"");
  if(exists $dyn->{target}){ $http->queue(" target=\"$dyn->{target}\"")}
  if(exists $dyn->{title}){ $http->queue(" title=\"$dyn->{title}\"")}
  $http->queue(">$dyn->{caption}</a>");
}
sub SetValue{
  my($this, $http, $dyn) = @_;
  my $param = $dyn->{name};
  my $value = $dyn->{value};
  my $method = "Refresh";
  if(exists $dyn->{method}) {
    $method = $dyn->{method};
  }
  my $path = $this->{path};
  if(exists $dyn->{obj}){
    $path = $dyn->{obj};
  }
  $this->{$param} = $value;
  $dyn->{url} = "$method?obj_path=$path";
  $this->Redirect($http, $dyn);
}
sub SendFileByPath{
  my($this, $http, $dyn) = @_;
  my $file = $dyn->{file_name};
  $file =~ s/%(..)/pack("c",hex($1))/ge;
  if(
    (-f $file && $file =~ /\.([^\/\.]+)$/) ||
    exists $dyn->{mime_type}
  ){
    my $ext = $1;
    $ext = lc($ext);
    my $content_type;
    if(exists $dyn->{mime_type}){
      $content_type = $dyn->{mime_type};
    } else {
      $content_type = $Dispatch::Http::App::Server::ExtToMime->{$ext};
    }
    if(defined $content_type){
      $http->HeaderSent;
      $http->queue("HTTP/1.0 200 OK\n");
      $http->queue("Content-type: $content_type\n\n");
      open FILE, "<$file";
      while(1){
        my $buff;
        my $count = read(FILE, $buff, 1024);
        if($count <= 0) { last }
        $http->queue($buff);
      }
      close FILE;
      $http->finish();
    }
  }
}
sub RetrieveStaticContent{
  my($this, $http, $dyn) = @_;
  my $App = $main::HTTP_APP_SINGLETON;
  if(exists $App->{static}->{$dyn->{content_name}}){
    if($dyn->{content_name} =~ /\.([^\/\.]+)$/){
      my $ext = $1;
      if(exists $Dispatch::Http::App::Server::ExtToMime->{$ext}){
        my $content_type = $Dispatch::Http::App::Server::ExtToMime->{$ext};
        $http->HeaderSent;
        $http->queue("HTTP/1.0 200 OK\n");
        $http->queue("Content-type: $content_type\n\n");
        $http->queue($App->{static}->{$dyn->{content_name}});
        $http->finish();
      }
    }
  }
}
sub RetrieveTempFile{
  my($this, $http, $dyn) = @_;
  my $App = $main::HTTP_APP_SINGLETON;
  if(-f $dyn->{content_name}){
    if($dyn->{content_name} =~ /\.([^\/\.]+)$/){
      my $ext = $1;
      if(exists $Dispatch::Http::App::Server::ExtToMime->{$ext}){
        my $content_type = $Dispatch::Http::App::Server::ExtToMime->{$ext};
        open my $fh, "<$dyn->{content_name}" or 
          die "can't open $dyn->{content_name}";
        $this->SendContentFromFh($http, $fh, $content_type);
      } else {
        print STDERR "Unknown mime type\n";
        ### unknown mime_type
      }
    } else {
      ### can't get extension
    }
  } else {
    ### no content_name
  }
}
sub SendContentFromFh{
  my($this, $http, $fh, $content_type, $callback)= @_;
  $http->HeaderSent;
  $http->queue("HTTP/1.0 200 OK\n");
  $http->queue("Content-type: $content_type\n\n");
  Dispatch::Select::Socket->new($this->MakeFileFinisher($http, $callback),
     $fh)->Add("reader");
}
sub MakeFileFinisher{
  my($this, $http, $callback) = @_;
  my $sub = sub {
    my($disp, $sock) = @_;
    my $buff;
    my $count = sysread($sock, $buff, 65000);
    if($count <= 0){
       $http->finish();
#       close $sock;
       $disp->Remove;
       if(defined $callback && ref($callback) eq "CODE"){
         &$callback();
       }
    } else {
       $http->queue($buff);
    }
  };
  return $sub;
}
sub GetParamValue{
  my($this, $http, $dyn) = @_;
  my $value = "&lt;undef&gt;";
  if(defined $this->{$dyn->{param}}){
    $value = $this->{$dyn->{param}};
  }
  $http->queue($value);
}
sub DeleteParamLink{
  my($this, $http, $dyn) = @_;
  delete $this->{$dyn->{param}};
  $this->Refresh($http, $dyn);
}
sub TableFromHash{
  my($this, $http, $dyn) = @_;
  my $list = $this->{$dyn->{list}};
  my @indices = split(/\|/, $dyn->{elements});
  for my $index (0 .. $#{$list}){
    my $h = $list->[$index];
    $http->queue("<tr>");
    for my $i (@indices){
      if($i ne "dyn_op"){
        $http->queue("<td>$h->{$i}</td>");
      } else {
        my $method = $dyn->{dyn_op};
        if($this->can($method)){
          $this->$method($http, $dyn, $index);
        } else {
          print STDERR "$this->{path} can't $method\n";
        }
      }
    }
    $http->queue("<tr>");
  }
}
#########################################################
# Standard Expanders
sub MainImage{
  my($this, $http, $dyn) = @_;
  print STDERR "!!!!!MainImage called in $this->{path}\n";
  $http->queue($main::ImageName);
}
sub HostName{
  my($this, $http, $dyn) = @_;
  if(defined $main::HostName){
    $http->queue($main::HostName);
  } elsif (defined $ENV{HostName}){
    $http->queue($ENV{HostName});
  } else {
    my $foo = `hostname`;
    chomp $foo;
    if(defined $foo){
      $http->queue($foo);
    } else {
      $http->queue("Mysterious Undefined Host");
    }
  }
}
sub q_path {
  my($this, $queue, $dyn) = @_;
  $queue->queue($this->{path});
}
sub q_class {
  my($this, $queue, $dyn) = @_;
  my $class = ref($this);
  $queue->queue($class);
}
sub q_root {
  my($this, $queue, $dyn) = @_;
  if($this->{path} =~ /([^\/]+)\//){
    $queue->queue($1);
  } else {
    $queue->queue($this->{path});
  }
}
sub q_child{
  my($this, $queue, $dyn) = @_;
  $queue->queue("$this->{path}/$dyn->{name}");
}
sub q_obj_name{
  my($this, $queue, $dyn) = @_;
  $queue->queue("$this->{path}");
}
sub q_uncle {
  my($this, $queue, $dyn) = @_;
  my $uncle = $this->parent->sibling($dyn->{name});
  if(defined($uncle)){
    $queue->queue($uncle->{path});
  }
}
sub q_parent {
  my($this, $queue, $dyn) = @_;
  if($this->{path} =~ /^(.*)\/[^\/]*$/){
    $queue->queue($1);
  }
}
sub q_sibling {
  my($this, $queue, $dyn) = @_;
  if($this->{path} =~ /^(.*)\/[^\/]*$/){
    my $sib = $1 . "/$dyn->{name}";
    $queue->queue($sib);
  } else {
    $queue->queue($dyn->{name});
  }
}
sub html_header{
  my($this, $http, $dyn) = @_;
  $http->HtmlHeader($dyn);
}
sub text_header{
  my($this, $http, $dyn) = @_;
  $http->TextHeader($dyn);
}
sub q_title{
  my($this, $queue, $dyn) = @_;
  $queue->queue("Generic Title for Http Obj (you should override this method)");
}
sub q_http_head{
  my($this, $queue, $dyn) = @_;
  $queue->queue("<html><head><title>");
  $this->title($queue, $dyn);
  $queue->queue("</title></head><body");
  $this->_QueueBGColor($queue, $dyn);
  $queue->queue(">");
}
sub q_http_head_reload{
  my($this, $queue, $dyn) = @_;
  my $url = $dyn->{url};
  my $delay = $dyn->{delay};
  $queue->queue("<html><head>" .
    "<META HTTP-EQUIV=REFRESH CONTENT=\"$delay; URL=$url\" />" .
    "<title>");
  $this->title($queue, $dyn);
  $queue->queue("</title></head><body");
  $this->_QueueBGColor($queue, $dyn);
  $queue->queue(">");
}
sub q_http_tail{
  my($this, $queue, $dyn) = @_;
  $queue->queue("</body></html>");
}
sub sub_obj{
  my($this, $queue, $dyn) = @_;
  my $path = "$this->{path}/$dyn->{name}";
  my $root = $main::HTTP_APP_SINGLETON->{Inventory}->{$this->{session}}->{root};
  my $sub = $root->{$path};
  unless(defined($sub) && $sub->can("Refresh")){
    print STDERR "Error: Object ($sub) at $path can't Refresh\n";
    return;
  }
  $sub->Refresh($queue, $dyn);
}
#########################################################
# Form Builder
sub iframe{
  # will generate a iframe definition like:
  #   <iframe width="100%" height="135" frameborder="0" 
  #     name="State:Hdr" id="State:Hdr" src="Refresh?obj_path=State/Hdr">
  #     This program requires a Web Browser that supports iframes. 
  #   </iframe>
  # from a invocation like:
  #   <?dyn="iframe" width="100%" height="135" frameborder="0" obj_path="State/Hdr"?>
  my($this, $http, $dyn) = @_;
  my $path = $this->{path};
  if (exists  $dyn->{obj_path})
    { $path = $dyn->{obj_path}; }
  if (exists  $dyn->{child_path})
    { $path = $this->child_path($dyn->{child_path}) }
  my $class = $path;
  $class =~ s/\//_/g;
  $http->queue("<iframe " . $this->_BGStyleColor .
    " width=\"" . (defined($dyn->{width})?$dyn->{width}:"100%") . "\"" .
    " height=\"" . (defined($dyn->{height})?$dyn->{height}:"100%") . "\"" .
    " frameborder=\"" . 
       (defined($dyn->{frameborder})?$dyn->{frameborder}:"0") . "\"" .
    "\n name=\"$class\" id=\"$class\" src=\"Refresh?obj_path=$path\">\n" .
    "</iframe>");
}
sub FormHandleAction{
  my($this, $http, $dyn) = @_;
  $http->queue("<form method=\"POST\" " .
    "action=\"HandleForm?obj_path=$this->{path}");
  if(defined $dyn->{refresh}){
    $http->queue("&amp;refresh=$dyn->{refresh}");
  } else {
    $http->queue("&amp;refresh=$this->{path}");
  }
  if(defined $dyn->{refresh_method}){
    $http->queue("&amp;refresh_method=$dyn->{refresh_method}");
  }
  $http->queue("\"");
  if(defined $dyn->{target}){
    $http->queue(" target=\"$dyn->{target}\"");
  }
  $http->queue(">");
}
sub TextHandler{
  my($this, $http, $dyn) = @_;
  $http->queue(
    "<input type=\"text\" name=\"$this->{path}+$dyn->{name}+"
  );
  if(exists $dyn->{index}){
    $http->queue($dyn->{index});
  }
  $http->queue("+1\" value=\"");
  if(exists $this->{$dyn->{name}}){
    $http->queue($this->{$dyn->{name}});
  } elsif (exists $dyn->{default}){
    $http->queue($dyn->{default});
  }
  $http->queue("\"/>");
}
sub SelectionFromHash{
  my($this, $http, $op, $index, $hash) = @_;
  $http->queue("<select name=\"$this->{path}+$op+$index+0\">");
  for my $i (sort {$hash->{$a} cmp $hash->{$b}} keys %$hash){
    $http->queue("<option value=\"$i\">$hash->{$i}</option>\n");
  }
  $http->queue("</select>");
}
sub SelectionFromDyn{
  my($this, $http, $dyn) = @_;
  my $hash = $this->{$dyn->{hash_name}};
  my $param = $dyn->{param};
  my $cur_value = $this->{$param};
  $http->queue("<select name=\"$this->{path}+SetParam+$param+0\">");
  for my $i (sort {$hash->{$a} cmp $hash->{$b}} keys %$hash){
    $http->queue("<option value=\"$i\"");
    if($cur_value eq $i){ $http->queue(" selected")}
    $http->queue(">$hash->{$i}</option>");
  }
  $http->queue("</select>");
}
sub SubmitHandler{
  my($this, $http, $dyn) = @_;
  $http->queue(
    "<input type=\"submit\" name=\"$this->{path}+");
  if(exists $dyn->{op}){
   $http->queue($dyn->{op});
  } else {
   $http->queue("NoOp");
  }
  $http->queue("+");
  if(exists $dyn->{index}){
    $http->queue($dyn->{index});
  }
  $http->queue("+10\" value=\"$dyn->{caption}\"/>");
}
sub HiddenHandler{
  my($this, $http, $dyn) = @_;
  $http->queue("<input type=\"hidden\" " .
      "name=\"$this->{path}+$dyn->{name}+" .
      (defined($dyn->{index})?$dyn->{index}:"") .
      "+0\"" .
      (defined($dyn->{value})?" value=\"$dyn->{value}\"":"") .
      "/>");
}
sub CheckBoxHandler{
  my($this, $http, $dyn) = @_;
  $http->queue("<input type=\"checkbox\" " .
      "name=\"$this->{path}+$dyn->{name}+" .
      (defined($dyn->{index})?$dyn->{index}:"") .
      "+1\" " .
      "value=\"$dyn->{value}\"");
  if($this->{$dyn->{name}}){
    $http->queue(" checked");
  }
  $http->queue("/>");
}
sub Checkbox{
  my($this, $http, $dyn) = @_;
  $http->queue("<input type=\"hidden\" name=\"$this->{path}+" .
    "SetParam+$dyn->{index}+0\" value=\"off\">\n");
  $http->queue(
    "<input type=\"checkbox\" name=\"$this->{path}+$dyn->{name}+"
  );
  if(exists $dyn->{index}){
    $http->queue($dyn->{index});
  }
  $http->queue("+1\"\n");
  if(
    exists($this->{$dyn->{index}}) &&
    $this->{$dyn->{index}} eq "on"
  ){
    $http->queue(" checked");
  }
  if(exists $dyn->{auto_submit}){
    $http->queue(" onChange=\"this.form.submit();\"");
  }
  $http->queue("/>");
}
sub RadioNotify{
  my($this, $http, $dyn) = @_;
  $http->queue("<input type=\"radio\" " .
    "name=\"$dyn->{group}" .
    ((defined $dyn->{index}) ? "_$dyn->{index}\" " : "") .
    "\" value=\"$dyn->{value}\" " .
    "onClick=\"ns('$dyn->{Op}?obj_path=$this->{path}&amp;" .
    "group=$dyn->{group}&amp;" .
    ((defined $dyn->{index}) ? "index=$dyn->{index}&amp;" : "") .
    "value=$dyn->{value}');\"");
  if(defined $dyn->{index}){
    if($this->{$dyn->{group}}->{$dyn->{index}} eq $dyn->{value}){
      $http->queue(" checked");
    }
  } else {
    if($this->{$dyn->{group}} eq $dyn->{value}){
      $http->queue(" checked");
    }
  }
  $http->queue("/>");
}
sub RadioNewNotify{
  my($this, $http, $dyn) = @_;
  $http->queue("<input type=\"radio\" " .
    "name=\"$dyn->{group}\" " .
    "onClick=\"ns('$dyn->{Op}?obj_path=$this->{path}&amp;" .
    "group=$dyn->{group}&amp;" .
    ((defined $dyn->{index}) ? "index=$dyn->{index}&amp;" : "") .
    "value=$dyn->{value}');\"");
  if(defined $dyn->{index}){
    if($this->{$dyn->{group}}->{$dyn->{index}} eq $dyn->{value}){
      $http->queue(" checked");
    }
  } else {
    if($this->{$dyn->{group}} eq $dyn->{value}){
      $http->queue(" checked");
    }
  }
  $http->queue("/>");
}
sub Radio{
  my($this, $http, $dyn) = @_;
  $http->queue(
    "<input type=\"radio\" name=\"$this->{path}+$dyn->{name}+"
  );
  if(exists $dyn->{index}){
    $http->queue($dyn->{index});
  }
  $http->queue("+1\"");
  if(
    exists $this->{$dyn->{index}} &&
    $this->{$dyn->{index}} eq $dyn->{value}
  ){
    $http->queue(" checked");
  }
  if(exists $dyn->{value}){
    $http->queue(" value=\"$dyn->{value}\"");
  }
  $http->queue("/>");
}
sub Input{
  my($this, $http, $dyn) = @_;
  $http->queue(
    "<input type=\"text\" name=\"$this->{path}+$dyn->{name}+"
  );
  if(exists $dyn->{index}){
    $http->queue($dyn->{index});
  }
  $http->queue("+1\"");
  if(exists $this->{$dyn->{index}}){
    $http->queue(" value=\"$this->{$dyn->{index}}\"");
  }
  if(exists $dyn->{size}){
    $http->queue(" size=\"$dyn->{size}\"");
  }
  if(exists $dyn->{len}){
    $http->queue(" maxlength=\"$dyn->{len}\"");
  }
  $http->queue("/>");
}
sub MonSelect{
  my($this, $http, $dyn) = @_;
  $http->queue("<select name=\"$this->{path}+" .
    "SetParam+$dyn->{field}+1\" size=\"1\">");
  for my $i ( "", 
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ){
   $http->queue("<option value=\"$i\"");
   if(
     defined($this->{$dyn->{field}}) &&
     $i eq $this->{$dyn->{field}}
   ){$http->queue(" selected")}
   $http->queue(">$i</option>\n");
  }
}
sub DaySelect{
  my($this, $http, $dyn) = @_;
  $http->queue("<select name=\"$this->{path}+" .
    "SetParam+$dyn->{field}+1\" size=\"1\">");
  for my $i ( 1 .. 31){
    $http->queue("<option value=\"$i\"");
    if(
      defined($this->{$dyn->{field}}) &&
      $i eq $this->{$dyn->{field}}
    ){$http->queue(" selected")}
    $http->queue(">$i</option>\n");
  }
}
sub YearSelect{
  my($this, $http, $dyn) = @_;
  $http->queue("<select name=\"$this->{path}+" .
    "SetParam+$dyn->{field}+1\" size=\"1\">");
  for my $i ( $dyn->{start} .. $dyn->{end}){
    $http->queue("<option value=\"$i\"");
     if(
       defined($this->{$dyn->{field}}) &&
       $i eq $this->{$dyn->{field}}
     ){$http->queue(" selected")}
    $http->queue(">$i</option>\n");
  }
}
sub SetParamDyn{
  my($this, $http, $dyn) = @_;
  $this->{$dyn->{value}} = $dyn->{param};
}
#########################################################
# Form Items Expander
sub SetParam{
  my($this, $id, $value) = @_;
  $this->{$id} = $value;
}
sub DeleteParam{
  my($this, $id, $value) = @_;
  delete $this->{$id};
}

sub UnlockWithReset{
  my($this, $name) = @_;
  unless(exists $this->{locker}) {
    $this->Die("$name is unlocking $this->{path} when it is not locked");
  }
  unless($this->{locker}->{name} eq $name){
    $this->Die("$name is unlocking $this->{path} when it is locked by " .
      "$this->{locker}->{name}");
  }
  $this->{locker} = {
    name => $this->{path},
    reason => "Resetting Self after UnlockWithReset by $name",
  };
  Dispatch::Iterator::Iterate($this, 
    "ResetInitiate", "ResetIterate", "ResetEndTest", 
    "ResetFinalize");
}
sub LockedReset{
  my($this, $name) = @_;
  if(exists($this->{locker})){
    print STDERR "$name tried to reset $this->{path} when it was locked " .
      "by $this->{locker}->{name}\n";
    return 0;
  }
  $this->{locker} = {
    name => $this->{path},
    reason => "Resetting Self",
  };
  Dispatch::Iterator::Iterate($this, 
    "ResetInitiate", "ResetIterate", "ResetEndTest", 
    "ResetFinalize");
}

# End Lock related functions
#########################################################
sub WindowCloser {
  my($this, $http, $dyn) = @_;
  $http->queue("<small><a href=\"javascript:");
   if($dyn->{refresh}){
    $http->queue("if(window.opener){window.opener.location.reload(true);};");
   }
   $http->queue("window.close();\">");
   if($dyn->{caption}){
     $http->queue($dyn->{caption});
   } else {
     $http->queue("close");
   }
   $http->queue("</a>");
}
sub AjaxObj{
  my($this, $http, $dyn) = @_;
  my $foo = <<EOF;
// Simple ajax object.  
// Public domain From Patrick Hunlock <patrick\@hunlock.com>
// http://www.hunlock.com/blogs/The_Ultimate_Ajax_Object
function ajaxObject(url, callbackFunction) {
  var that=this;      
  this.updating = false;
  this.abort = function() {
    if (that.updating) {
      that.updating=false;
      that.AJAX.abort();
      that.AJAX=null;
    }
  }
  this.update = function(passData,postMethod) { 
    if (postMethod==null) {
      postMethod = "POST";
    }
    if (that.updating) {
      console.error("update when updating");
      return false;
    }
    that.AJAX = null;                          
    if (window.XMLHttpRequest) {              
      that.AJAX=new XMLHttpRequest();              
    } else {                                  
      that.AJAX=new ActiveXObject("Microsoft.XMLHTTP");
    }                                             
    if (that.AJAX==null) {                             
      return false;                               
    } else {
      that.AJAX.onreadystatechange = function() {  
        if (that.AJAX.readyState==4) {             
          that.updating=false;                
          that.callback(that.AJAX.responseText,that.AJAX.status,that.AJAX.responseXML);        
          that.AJAX=null;                                         
        }                                                      
      }                                                        
      that.updating = new Date();                              
      if (/post/i.test(postMethod)) {
        var uri=urlCall+'&ts='+that.updating.getTime();
        //alert('ajaxObject::update POST called, url: '+uri);
        that.AJAX.open("POST", uri, true);
        that.AJAX.setRequestHeader(
          "Content-type", "text/plain");
          // "Content-type", "application/x-www-form-urlencoded");
        that.AJAX.send(passData);
      } else {
      var uri=urlCall+'?'+passData+'&timestamp='+(that.updating.getTime());
      // alert('ajaxObject::update GET called, url: '+uri);
        that.AJAX.open("GET", uri, true);                             
        that.AJAX.send(null);                                         
      }              
      return true;                                             
    }
  }
  var urlCall = url;        
  this.callback = callbackFunction || function () { };
}
function PosdaAjaxObj(r_obj, path, cb) {
  var that=this;      
  this.r_obj = r_obj;
  this.cb = cb || function () { };
  this.ajaxObj = 
    new ajaxObject("AjaxPosdaGet?obj_path="+path+"&obj="+r_obj,
      function(responseText) {
        // alert("PosdaAjaxObj::response: "+responseText);
        that.d = JSON.parse(responseText);
        that.cb(that.r_obj);
      }
    );
  this.update = function(passData,cb) {
    if (cb!=null) { this.cb = cb; }
    return this.ajaxObj.update(passData);
  }
  this.ajaxObj.update("");
}
function PosdaAjaxMethod(r_meth, path, cb) {
  var that=this;      
  this.r_meth = r_meth;
  this.cb = cb || function () { };
  this.ajaxObj = 
    new ajaxObject(r_meth + "?obj_path="+path,
      function(responseText) {
        // alert("PosdaAjaxObj::response: "+responseText);
        that.d = JSON.parse(responseText);
        that.cb(that.r_meth);
      }
    );
  this.update = function(passData,cb) {
    if (cb!=null) { this.cb = cb; }
    return this.ajaxObj.update(passData);
  }
  this.ajaxObj.update("");
}
function CloseThisWindow(){
  var that=this;
  PosdaAjaxMethod("JavascriptCloseWindow", ObjPath, 
    function(responseText){
      window.close();
    }
  );
}
EOF
  $this->RefreshEngine($http, $dyn, $foo);
}
sub WindowCtlJs {
  my($this, $http, $dyn) = @_;
  my $foo = <<EOF;
<script type="text/javascript"> 
var remote=null;
var children = new Array();;
var isIE = false;
</script>
<!--[if IE]>
<script type="text/javascript"> 
  isIE = true;
</script>
<![endif]-->
<script type="text/javascript"> 
function tr(m){
  // if (this.console &&  typeof console.log != "undefined") 
  //   try { console.log(m) } catch (e) {};
  ;
}
function nsieonly(d){
  if (isIE) {
    ns(d);
  }
}
function rs(n,u,w,h,x) {
  args="width="+w+",height="+h+",resizable=yes,scrollbars=yes,status=0,left=10,top=10";
  remote=window.open(u,n,args);
  if (remote != null) {
    if (remote.opener == null)
      remote.opener = self;
      remote.focus();
  }
  if (x == 1) { return remote; }
}
 
function rt(n,u,w,h,x) {
  args="width="+w+",height="+h+",resizable=yes,scrollbars=yes,status=0,left=10,top=10,location=yes";
  remote=window.open(u,n,args);
  if (remote != null) {
    remote.opener = self;
    if (isIE) {
      //remote.location.reload(true);
      remote.location.href = u;
    }
    remote.focus();
  }
  if (x == 1) { return remote; }
}
 
function rr(p, d, n, w, h, x) {
 u = window.prompt(p, d);
 if(u != null){
   return rt(n, u, w, h, x);
 }
}
 
function ru(n,u,w,h,x,l, t) {
  args="width="+w+",height="+h+",resizable=yes,scrollbars=yes,status=0,left="+l+",top="+t+"10";
  remote=window.open(u,n,args);
  if (remote != null) {
    if (remote.opener == null)
      remote.opener = self;
  }
  if (x == 1) { return remote; }
}
function sl(n,l) {
  remote=window.open(l, n);
}
function rl(n,l) {
  remote=window.open(l, n);
  remote.location.reload(true);
}
function rlp(n,l) {
  remote=window.parent;
  remote.location.reload(true);
}
function rm(n,u,w,h,x) {
  if(window.showModalDialog){
    args="dialogWidth:"+w+"px;dialogHeight:"+h+"px";
    remote=window.showModalDialog(u,'modalWindow',args);
  } else {
    args="width="+w+",height="+h+",modal=yes,resizable=yes,scrollbars=no,status=0,left=10,top=10,location=no";
    remote=window.open(u, n, args);
  }
  if (remote != null) {
    if (remote.opener == null)
      remote.opener = self;
  }
  if (x == 1) { return remote; }
}
function nxml(){
  var xmlhttp = null;
  try {
    xmlhttp = new XMLHttpRequest();
  } catch (e) {
    try {
      xmlhttp = new ActiveXObject("Microsoft.XMLHttp");
    }
    catch (e){
      alert(
        "Error creating XHLHttpRequest (or ActiveX) Object: "+e.description);
      xmlhttp=null;
    }
    if (xmlhttp == null)
      alert(
        "Error creating XHLHttpRequest (or ActiveX) Object: "+e.description);
  }
  return xmlhttp;
}
var q = [ ];
var a = null;
var l = null;
var t = null;
function lf(fl){
  l = fl;
}
function tc(){
      var t = q.shift();
      if (t != null) {
        tr('s: calling send: '+t);
        s(t);
      } else {
        a = null;
        if (l != null) {
          tr('s: delay done: setting my location to: '+l);
          self.window.location.href = l;
          l = null;
        }
      }
}
function s(d){
  a = d;
  tr('s: Called with: '+d);
  var xmlhttp = nxml();
  if (xmlhttp == null) return;
  xmlhttp.open("HEAD", d, true);
  // xmlhttp.setRequestHeader("Connection", "close");
  xmlhttp.onreadystatechange = function() {
    try {
      tr("ns resp: readyState:"+this.readyState);
    } catch (e) {}
    try {
      tr("ns resp: status:"+this.status);
    } catch (e) {}
    if (this.readyState == 4) {  
      t = setTimeout("tc()",0);
    } 
  }
  xmlhttp.send(null);
}
function nsc(p,d){
  if (confirm(p)) { ns(d) }
}
function nspr(p,v,d){
  ns(d+"&response="+prompt(p,v));
}
function ns(d){
  d = d+"&window="+window.name;
  if (a == null) {
    tr('ns: calling send: '+d);
    s(d);
  } else {
    tr('ns: queueing: '+d);
    q.push(d);
  }
}
function nsp(d, v){
  d = d+"&window="+window.name;
  var xmlhttp = nxml();
  if (xmlhttp == null) return;
  xmlhttp.open("POST", d, true);
  xmlhttp.setRequestHeader("Content-type", "text/plain");
  // xmlhttp.setRequestHeader("Content-length", v.length);
  // xmlhttp.setRequestHeader("Connection", "close");
  xmlhttp.send(v); 
}
function ns_cr(l, v, t){
  //alert(' l: '+l+', v: '+v+'.');
  var d = l+"&window="+window.name;
  if (v.length == 0) {
    var p = "parm=value";
  } else {
    var p = v+"&parm=value";
  }
  var xmlhttp = nxml();
  if (xmlhttp == null) return;
  xmlhttp.open("POST", d, true);
  xmlhttp.setRequestHeader("Content-type", "text/plain");
  // xmlhttp.setRequestHeader("Content-length", p.length);
  // xmlhttp.setRequestHeader("Connection", "close");
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 ) {
      if (this.status == 200) {
        if (this.responseText == "1") {
          window.location.reload(true);
        } else if  (this.responseText == "0") {
          var r = "ns_cr('"+l+"','"+v+"','"+t+"')";
          setTimeout(r,500);
        } else {
          alert('unexpected response text: "'+this.responseText+'"');
        }
      } else if (this.status == 0  || this.status == 12029) {
        alert('Server program is not responding.');
      }
    }
  }
  xmlhttp.send(p); 
}
function nsr(d){
  d = d+"&window="+window.name;
  var xmlhttp = nxml();
  if (xmlhttp == null) return;
  xmlhttp.open("HEAD", d, true);
  xmlhttp.onreadystatechange = function(){
    if(this.readyState != 4) { return; }
    window.location.reload(true);
  };
  xmlhttp.send(null);
}
function CheckAll(itype,checked) {
  len = document.slist.elements.length;
  var i=0;
  for( i=0; i<len; i++) {
    if (document.slist.elements[i].name==itype) {
      document.slist.elements[i].checked=checked;
    }
  }
}
function st(l, v, t){
  var r = "ns_cr('"+l+"','"+v+"','"+t+"')";
  setTimeout(r,t);
}
function pf(w, l){
  tr('pf w:'+w+'  l:'+l);
  try {
     var f = parent.document.getElementById(w);
     if (f == null) {
       tr('pf <<<<< getElementByID failed...');
       self.parent.window.frames[w].location = l;
       return;
     } 
    if (f.contentWindow.q != null  &&  f.contentWindow.q.length > 0) {
       tr('pf: Queue is active...');
      f.contentWindow.l = l;
    } else {
      tr('pf Queue not active, setting location.');
      //  f.contentWindow.location = l;
      self.parent.window.frames[w].location = l;
    }
  } catch (e) {
    tr('pf: <<<<< Error: '+e.description);
    // self.parent.window.frames[w].location = l;
  }
}
function psf(s, w, l){
  tr('psf s:'+s+' w:'+w+'  l:'+l);
  try {
     var f = parent.document.getElementById(s);
     if (f == null) {
       tr('pf <<<<< getElementByID failed...');
       self.parent.window.frames[s].window.frames[w].location = l;
       return;
     } 
    if (f.contentWindow.q != null  &&  f.contentWindow.q.length > 0) {
       tr('pf: Queue is active...');
      f.contentWindow.l = l;
    } else {
      tr('pf Queue not active, setting location.');
      //  f.contentWindow.location = l;
      self.parent.window.frames[s].window.frames[w].location = l;
    }
  } catch (e) {
    tr('pf: <<<<< Error: '+e.description);
    self.parent.window.frames[s].window.frames[w].location = l;
  }
}
<?dyn="AjaxObj"?>
</script>
EOF
#   setTimeout("ns_cr('"+l+"','"+v+"')",1000);
#   setTimeout('ns_cr(\''+l+'\',\''+v+'\')',1000);
#         var r = "ns_cr('"+l+"','"+v+"')";
#         setTimeout(r,1000);
  $this->RefreshEngine($http, $dyn, $foo);
}
sub BaseJsHeader{
  my($this, $http, $dyn) = @_;
my $foo = <<EOF;
<?dyn="BaseHeader"?>
<script type="text/javascript">
function nxml(){
  var xmlhttp = null;
  try {
    xmlhttp = new XMLHttpRequest();
  } catch (e) {
    try {
      xmlhttp = new ActiveXObject("Microsoft.XMLHttp");
    }
    catch (e){
      alert(
        "Error creating XHLHttpRequest (or ActiveX) Object: "+e.description);
      xmlhttp=null;
    }
    if (xmlhttp == null)
      alert(
        "Error creating XHLHttpRequest (or ActiveX) Object: "+e.description);
  }
  return xmlhttp;
}
function rt(n,u,w,h,x) {
  args="width="+w+",height="+h+",resizable=yes,scrollbars=yes,status=0,left=10,top=10,location=yes";
  remote=window.open(u,n,args);
  if (remote != null) {
    remote.opener = self;
    if (isIE) {
      //remote.location.reload(true);
      remote.location.href = u;
    }
    remote.focus();
  }
  if (x == 1) { return remote; }
}
</script>
EOF
  $this->RefreshEngine($http, $dyn, $foo);
}
################
# Act and  Reload Link
sub ActReloadLink{
  my($this, $http, $dyn) = @_;
  my $url;
  if(exists $dyn->{obj}){
    $url = "$dyn->{method}?obj_path=$dyn->{obj}";
  } else {
    $url = "$dyn->{method}?obj_path=$this->{path}";
  }
  if(exists $dyn->{value}){
    my $value = $dyn->{value};
    $url .= "&amp;value=$value";
  }
  if(exists $dyn->{dir}){
    my $dir = $dyn->{dir};
    $dir =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $url .= "&amp;dir=$dir";
  }
  if(exists $dyn->{root}){
    my $root = $dyn->{root};
    $root =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $url .= "&amp;root=$root"
  }
  if(exists $dyn->{param}){
    my $param = $dyn->{param};
    $param =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $url .= "&amp;param=$param";
  }
  $http->queue("<a href=\"#\" onClick=\"" .
    "nsr('$url');\">$dyn->{caption}</a>");
}
sub ActReloadButton{
  # do not use with new arch.
  # creates a button that reloads window to given url
  my($this, $http, $dyn) = @_;
  my $url;
  if(exists $dyn->{obj}){
    $url = "$dyn->{method}?obj_path=$dyn->{obj}";
  } else {
    $url = "$dyn->{method}?obj_path=$this->{path}";
  }
  if(exists $dyn->{value}){
    my $value = $dyn->{value};
    $url .= "&amp;value=$value";
  }
  if(exists $dyn->{dir}){
    my $dir = $dyn->{dir};
    $dir =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $url .= "&amp;dir=$dir";
  }
  if(exists $dyn->{root}){
    my $root = $dyn->{root};
    $root =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $url .= "&amp;root=$root"
  }
  if(exists $dyn->{param}){
    my $param = $dyn->{param};
    $param =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $url .= "&amp;param=$param";
  }
  $http->queue("<input type=\"button\" onClick=\"" .
    "nsr('$url');\" value=\"$dyn->{caption}\"/>");
}
sub ActNoReloadButton{
  # OK to use with new arch.
  # creates a button that reloads window to given url
  my($this, $http, $dyn) = @_;
  my $url;
  if(exists $dyn->{obj}){
    $url = "$dyn->{method}?obj_path=$dyn->{obj}";
  } else {
    $url = "$dyn->{method}?obj_path=$this->{path}";
  }
  if(exists $dyn->{value}){
    my $value = $dyn->{value};
    $url .= "&amp;value=$value";
  }
  if(exists $dyn->{dir}){
    my $dir = $dyn->{dir};
    $dir =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $url .= "&amp;dir=$dir";
  }
  if(exists $dyn->{root}){
    my $root = $dyn->{root};
    $root =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $url .= "&amp;root=$root"
  }
  if(exists $dyn->{param}){
    my $param = $dyn->{param};
    $param =~ s/(=)/"%" . unpack("H2", $1)/eg;
    $url .= "&amp;param=$param";
  }
  $http->queue("<input type=\"button\" onClick=\"" .
    "ns('$url');\" value=\"$dyn->{caption}\"/>");
}
sub SelectNsrByIndex{
  my($this, $http, $dyn) = @_;
  $http->queue("<select onChange=\"nsr('" .
    (defined($dyn->{op}) ? "$dyn->{op}" : "SetNsrParamByIndex") .
    "?obj_path=$this->{path}&amp;" .
    (defined($dyn->{param}) ? "param=$dyn->{param}&amp;" : "") .
    "index='+this.selectedIndex);\">");
}
sub SelectNsByIndex{
  my($this, $http, $dyn) = @_;
  $http->queue("<select onChange=\"ns('" .
    (defined($dyn->{op}) ? "$dyn->{op}" : "SetNsParamByIndex") .
    "?obj_path=$this->{path}&amp;" .
    (defined($dyn->{param}) ? "param=$dyn->{param}&amp;" : "") .
    "index='+this.selectedIndex);\">");
}
sub SetNsrParamByIndex{
  my($this, $http, $dyn) = @_;
  $this->{$dyn->{param}} = $dyn->{index};
}
sub SetNsParamByIndex{
  my($this, $http, $dyn) = @_;
  $this->{$dyn->{param}} = $dyn->{index};
  $this->AutoRefresh;
}
sub SelectNsrByValue{
  my($this, $http, $dyn) = @_;
  $http->queue("<select onChange=\"nsr('$dyn->{op}?obj_path=$this->{path}&amp;" .
    (defined($dyn->{param}) ? "param=$dyn->{param}&amp;" : "") .
    (defined($dyn->{index}) ? "index=$dyn->{index}&amp;" : "") .
    "value='+this.options[this.selectedIndex].value);\">");
}
sub SelectNsByValue{
  my($this, $http, $dyn) = @_;
  $http->queue("<select onChange=\"ns(" .
    (defined($dyn->{op})? "'$dyn->{op}" : "'SetSelectValue") .
    "?obj_path=$this->{path}&amp;" .
    (defined($dyn->{param}) ? "param=$dyn->{param}&amp;" : "") .
    (defined($dyn->{index}) ? "index=$dyn->{index}&amp;" : "") .
    "value='+this.options[this.selectedIndex].value);\"" .
    (defined($dyn->{style}) ? " style=\"$dyn->{style}\"" : "") .
    ">");
}
sub SetSelectValue{
  my($this, $http, $dyn) = @_;
  $this->{$dyn->{index}} = $dyn->{value};
}
sub CheckBoxMatrix{
  my($this, $http, $dyn) = @_;
  $http->queue("<input type=\"checkbox\" " .
    "name=\"$dyn->{name}\" value=\"$dyn->{index}\" " . 
    ($this->{$dyn->{matrix}}->{$dyn->{name}}->{$dyn->{index}} eq "checked" ?
      " checked=\"yes\"" :
      ""
    ) .
    "onClick=\"ns('" .
    (defined($dyn->{op})? "$dyn->{op}" : "SetCheckBoxValue") .
    "?obj_path=$this->{path}&amp;" .
    "value='+(this.checked ? 'checked' : 'not_checked')+" .
    "'&amp;name=$dyn->{name}&amp;index=$dyn->{index}&amp;" .
    "matrix=$dyn->{matrix}');\"/>");
}
sub CheckBoxNs{
  my($this, $http, $dyn) = @_;
  $http->queue("<input type=\"checkbox\" " .
    "name=\"$dyn->{name}\" value=\"$dyn->{index}\" " . 
    ($this->{$dyn->{name}}->{$dyn->{index}} eq "checked" ?
      "checked=\"yes\" " :
      ""
    ) .
    "onClick=\"ns('" .
    (defined($dyn->{op})? "$dyn->{op}" : "SetCheckBoxValue") .
    "?obj_path=$this->{path}&amp;" .
    "value='+(this.checked ? 'checked' : 'not_checked')+" .
    "'&amp;name=$dyn->{name}&amp;index=$dyn->{index}');\"/>");
}
sub SetCheckBoxValue{
  my($this, $http, $dyn) = @_;
  $this->{$dyn->{name}}->{$dyn->{index}} = $dyn->{value};
}
sub InputNsr{
  my($this, $http, $dyn) = @_;
}
sub InputReload{
  my($this, $http, $dyn) = @_;
  $http->queue("<input type=\"text\" " .
    "onBlur=\"nsr('" .
    (defined($dyn->{op}) ? $dyn->{op} : "SetInputReload") .
    "?obj_path=$this->{path}&amp;" .
    (defined($dyn->{field}) ? "field=$dyn->{field}&amp;" : "") .
    (defined($dyn->{index}) ? "index=$dyn->{index}&amp;" : "") .
    "value='+this.value);\"" .
    (defined($dyn->{size}) ? " size=\"$dyn->{size}\"" : "") .
    (defined($dyn->{len}) ? " maxlen=\"$dyn->{len}\"" : "") .
    ( 
       defined($dyn->{field}) && defined($this->{$dyn->{field}})
       ?
         " value=\"$this->{$dyn->{field}}\"" 
       : 
         ""
    ) .
    "/>");
}
sub InputChangeNoReload{
  my($this, $http, $dyn) = @_;
  my $op = "('" .
    (defined($dyn->{op}) ? $dyn->{op} : "SetInputReload") .
    "?obj_path=$this->{path}&amp;" .
    (defined($dyn->{param}) ? "param=$dyn->{param}&amp;" : "") .
    (defined($dyn->{field}) ? "field=$dyn->{field}&amp;" : "") .
    (defined($dyn->{index}) ? "index=$dyn->{index}&amp;" : "") .
    "value='+this.value);";
  my $value = "";
  if(defined($dyn->{size})){ $value.= " size=\"$dyn->{size}\"" }
  if(defined($dyn->{len})){ $value .= " maxlen=\"$dyn->{len}\"" }
  if(
    defined($dyn->{field})  && 
    defined($this->{$dyn->{field}})  && 
    defined($dyn->{index}) &&
    defined($this->{$dyn->{field}}->{$dyn->{index}})
  ){
    $value .= " value=\"$this->{$dyn->{field}}->{$dyn->{index}}\"";
  } elsif(defined $dyn->{field} && defined($this->{$dyn->{field}})){
    $value .= " value=\"$this->{$dyn->{field}}\"";
  }
  $http->queue("<input type=\"text\"$value " .
    "onchange=\"ns$op\" onkeyup=\"nsieonly$op\"" .
    "/>");
}
sub InputChangeNoReloadAllEvents{
  my($this, $http, $dyn) = @_;
  my $op = "ns('" .
    (defined($dyn->{op}) ? $dyn->{op} : "SetInputReload") .
    "?obj_path=$this->{path}&amp;" .
    (defined($dyn->{field}) ? "field=$dyn->{field}&amp;" : "") .
    (defined($dyn->{index}) ? "index=$dyn->{index}&amp;" : "") .
    "";
  my $value = "";
  if(defined($dyn->{size})){ $value.= " size=\"$dyn->{size}\"" }
  if(defined($dyn->{len})){ $value .= " maxlen=\"$dyn->{len}\"" }
  if(
    defined($dyn->{field})  && 
    defined($this->{$dyn->{field}})  && 
    defined($dyn->{index}) &&
    defined($this->{$dyn->{field}}->{$dyn->{index}})
  ){
    $value .= " value=\"$this->{$dyn->{field}}->{$dyn->{index}}\"";
  } elsif(defined $dyn->{field} && defined($this->{$dyn->{field}})){
    $value .= " value=\"$this->{$dyn->{field}}\"";
  }
  $http->queue("<input type=\"text\"$value " .
    "onblur=\"" . $op . "event=onblur&amp;value='+this.value);\" " .
    "onchange=\"" . $op . "event=onchange&amp;value='+this.value);\" " .
    "onclick=\"" . $op . "event=onclick&amp;value='+this.value);\" " .
    "ondblclick=\"" . $op . "event=ondblclick&amp;value='+this.value);\" " .
    "onfocus=\"" . $op . "event=onfocus&amp;value='+this.value);\" " .
    "onmousedown=\"" . $op . "event=onmousedown&amp;value='+this.value);\" " .
    "onmousemove=\"" . $op . "event=onmousemove&amp;value='+this.value);\" " .
    "onmouseout=\"" . $op . "event=onmouseout&amp;value='+this.value);\" " .
    "onmouseover=\"" . $op . "event=onmouseover&amp;value='+this.value);\" " .
    "onmouseup=\"" . $op . "event=onmouseup&amp;value='+this.value);\" " .
    "onkeydown=\"" . $op . "event=onkeydown&amp;value='+this.value);\" " .
    "onkeypress=\"" . $op . "event=onkeypress&amp;value='+this.value);\" " .
    "onkeyup=\"" . $op . "event=onkeyup&amp;value='+this.value);\" " .
    "onselect=\"" . $op . "event=onselect&amp;value='+this.value);\" " .
    "/>");
}
sub SetInputReload{
  my($this, $http, $dyn) = @_;
  if( defined $dyn->{index}){
    $this->{$dyn->{field}}->{$dyn->{index}} = $dyn->{value};
  } else {
    $this->{$dyn->{field}} = $dyn->{value};
  }
}
sub Button{
  # Use in new arch - replaces SubmitReload...
  my($this, $http, $dyn) = @_;
  $this->button($http, $dyn, "ns");
}
sub CButton{
  # Use in new arch - Button with confirm alert...
  #   set dyn->{prompt} to be the confirm alert prompt.
  my($this, $http, $dyn) = @_;
  $this->button($http, $dyn, "nsc");
}
sub PButton{
  # Use in new arch - Button with prompt box alert...
  #   set dyn->{prompt} to be the prompt.
  #   set dyn->{default) to default value for response.
  my($this, $http, $dyn) = @_;
  $this->button($http, $dyn, "nspr");
}
sub ControllerButton{
  # Use in new arch - replaces SubmitReload...
  my($this, $http, $dyn) = @_;
  $this->button($http, $dyn, "nsr");
}
sub button{
  # Use in new arch - replaces SubmitReload...
  my($this, $http, $dyn, $type) = @_;
  my $param;
  if(defined($dyn->{field}) && defined($this->{$dyn->{field}})){
    $param = $this->{$dyn->{field}};
    $param =~ s/\\/\\\\/g;
  }
  my $style;
  if (exists $dyn->{size}) 
    { $style = "width:$dyn->{size}px"; }
  elsif (exists $dyn->{width}) {
    $style = "width:$dyn->{width}";
    if (exists $dyn->{height}) 
      { $style .=  ";height:$dyn->{height}"; }
  }
  $http->queue("<input type=\"button\" " .
    ((defined $style) ? "style=\"$style\" " : "") .
    "onClick=\"$type(" . 
    ($type eq 'nsc' ? "'$dyn->{prompt}'," : "") .
    ($type eq 'nspr' ? "'$dyn->{prompt}','$dyn->{default}'," : "") .
    "'$dyn->{op}?obj_path=$this->{path}&amp;" .
    (defined($dyn->{param}) ? "param=$dyn->{param}&amp;" : "") .
    (defined($dyn->{index}) ? "index=$dyn->{index}&amp;" : "") .
    ((defined($dyn->{field}) && defined($this->{$dyn->{field}})) ?
       "param=$param&amp;" : "") .
    "value='+this.value);\"" .
    " value=\"$dyn->{caption}\"" .
    "/>");
}
sub SubmitReload{
  # would normaly not use with new arch..
  my($this, $http, $dyn) = @_;
  my $param;
  if(defined($dyn->{field}) && defined($this->{$dyn->{field}})){
    $param = $this->{$dyn->{field}};
    $param =~ s/\\/\\\\/g;
  }
  $http->queue("<input type=\"button\" " .
    ((exists $dyn->{size}) ? "style=\"width:$dyn->{size}px\" " : "") .
    "onClick=\"nsr('$dyn->{op}?obj_path=$this->{path}&amp;" .
    (defined($dyn->{param}) ? "param=$dyn->{param}&amp;" : "") .
    ((defined($dyn->{field}) && defined($this->{$dyn->{field}})) ?
       "param=$param&amp;" : "") .
    "value='+this.value);\"" .
    " value=\"$dyn->{caption}\"" .
    "/>");
}
sub SubmitReloadButton{
  # would normaly not use with new arch..
  my($this, $http, $dyn) = @_;
  my $param;
  if(defined($dyn->{field}) && defined($this->{$dyn->{field}})){
    $param = $this->{$dyn->{field}};
    $param =~ s/\\/\\\\/g;
  }
  $http->queue(
	  "<a " .
    "onClick=\"nsr('$dyn->{op}?obj_path=$this->{path}&amp;" .
    (defined($dyn->{param}) ? "param=$dyn->{param}&amp;" : "") .
    ((defined($dyn->{field}) && defined($this->{$dyn->{field}})) ?
       "param=$param&amp;" : "") .
    "value='+this.value);\" >" .

	  "<img src=\"RetrieveStaticContent?obj_path=" . 
		$this->{path} . "&amp;content_name=/$dyn->{src}\" " .
		(defined($dyn->{width}) ? "width=$dyn->{width} " : "") .
		(defined($dyn->{height}) ? "height=$dyn->{height} " : "") .
		(defined($dyn->{border}) ? "border=$dyn->{border} " : "border=\"0\" ") .
		(defined($dyn->{alt}) ? "alt=\"$dyn->{alt}\" " : "") .
		(defined($dyn->{name}) ? "name=\"$dyn->{name}\" " : "") .
	  " > " .

	  "</a> " );
}
sub Increment{
  my($this, $http, $dyn) = @_;
  my $index = $dyn->{value};
  my $param = $dyn->{param};
  $this->{$index} += $param;
}
################
#  for testing only
sub MakeNotifier{
  my($this, $http, $dyn) = @_;
  $http->queue("<a onClick=\"javascript:ns(".
    "'BackGroundMessage?obj_path=$this->{path}&amp;" .
    "message=$dyn->{message}');\">$dyn->{caption}</a>");
}
sub BackGroundMessage{
  my($this, $http, $dyn) = @_;
  print "##### $this->{session}\n"; 
  for my $i (keys %$dyn){
    print "\tdyn{$i} = $dyn->{$i}\n";
  }
  print "##### end\n"; 
}
sub MakeChildLister{
  my($this, $http, $dyn) = @_;
  $http->queue("<a href=\"#\" onClick=\"javascript:childlist(".
    "'BackGroundMessage?obj_path=$this->{path}" .
    "');\">$dyn->{caption}</a>");
}
################

################
###  Warning - Cannot be made to work with IE (what you get is horrible,
###            unworkable POS).  Doesn't work with Chrome (what you get
###            is almost as bad - wrong kind of modal which hides and 
###            disables main window in stealth mode).
sub ModalPopUpLink{
  my($this, $http, $dyn) = @_;
  my $url = "$dyn->{method}?obj_path=$this->{path}";
  if(exists $dyn->{param}){ $url .= "&amp;param=$dyn->{param}" }
  $http->queue("<a href=\"javascript:rm('$dyn->{target}'," .
    "'$url', $dyn->{x}, $dyn->{y}, 0);\"" .
    ">$dyn->{caption}</a>");
}
###  end Warning scope
sub PopUpLink{
  my($this, $http, $dyn) = @_;
  my $url;
  if(exists $dyn->{obj}){
    $url = "$dyn->{method}?obj_path=$dyn->{obj}";
  } else {
    $url = "$dyn->{method}?obj_path=$this->{path}";
  }
  if(exists $dyn->{param}){ $url .= "&amp;param=$dyn->{param}" }
  $url .= "&amp;target=$dyn->{target}";
  $http->queue("<a href=\"javascript:rs('$dyn->{target}'," .
    "'$url', $dyn->{x}, $dyn->{y}, 0);\"");
  if(exists $dyn->{title}){
    $http->queue(" title=\"$dyn->{title}\"");
  }
  $http->queue(">$dyn->{caption}</a>");
}
sub PopUpButton{
  my($this, $http, $dyn) = @_;
  my $url;
  if(exists $dyn->{obj}){
    $url = "$dyn->{method}?obj_path=$dyn->{obj}";
  } else {
    $url = "$dyn->{method}?obj_path=$this->{path}";
  }
  if(exists $dyn->{param}){ $url .= "&amp;param=$dyn->{param}" }
  if(exists $dyn->{index}){ $url .= "&amp;index=$dyn->{index}" }
  $url .= "&amp;target=$dyn->{target}";
  $http->queue("<input type=\"button\" ");
  if (exists $dyn->{size}) {
    $http->queue("style=\"width:$dyn->{size}px\" ");
  }
  $http->queue(
    "onClick=\"javascript:rs('$dyn->{target}'," .
    "'$url', $dyn->{x}, $dyn->{y}, 0);" .
    "window.location.reload(true);\"");
  $http->queue(" value=\"$dyn->{caption}\"/>");
}
sub PopUpLinkAndRefresh{
  my($this, $http, $dyn) = @_;
  my $url;
  if(exists $dyn->{obj}){
    $url = "$dyn->{method}?obj_path=$dyn->{obj}";
  } else {
    $url = "$dyn->{method}?obj_path=$this->{path}";
  }
  if(exists $dyn->{param}){ $url .= "&amp;param=$dyn->{param}" }
  if(exists $dyn->{index}){ $url .= "&amp;index=$dyn->{index}" }
  $url .= "&amp;target=$dyn->{target}";
  $http->queue("<a href=\"javascript:rs('$dyn->{target}'," .
    "'$url', $dyn->{x}, $dyn->{y}, 0);" .
    "window.location.reload(true);\"");
  if(exists $dyn->{title}){
    $http->queue(" title=\"$dyn->{title}\"");
  }
  $http->queue(">$dyn->{caption}</a>");
}
my $css_style_header = <<EOF;
<style type="text/css"> 
<!-- 
#content {
  padding: 20px;
}
--> 
</style> 
EOF
sub CssStyle{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $css_style_header);
}
my $base_header = <<EOF;
<?dyn="html_header"?><!DOCTYPE html
        PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<meta http-equiv="Content-Type" content="text/html; charset=utf8" />
<head>
<!-- HttpApp::HttpObj line 2266 -->
<?dyn="CssStyle"?>
<title><?dyn="title"?></title>
EOF
my $std_header = <<EOF;
<?dyn="WindowCtlJs"?>
</head>
EOF
sub BaseHeader{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $base_header);
}
sub Header{
  my($this, $http, $dyn) = @_;
  $this->BaseHeader($http, $dyn);
  $this->RefreshEngine($http, $dyn, $std_header);
}
my $frame_header = <<EOF;
</head>
EOF
sub FrameHeader{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $base_header);
  $this->RefreshEngine($http, $dyn, $frame_header);
}
my $jquery_header = <<EOF;
<link rel="stylesheet" href="/jqueryui/jquery-ui.css">
<script class="include" language="javascript" type="text/javascript" src="/jquery.js"></script>
<script class="include" language="javascript" type="text/javascript" src="/jqueryui/jquery-ui.js"></script>
<?dyn="WindowCtlJs"?>
EOF
sub JqueryHeader{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $base_header);
  $this->RefreshEngine($http, $dyn, $jquery_header);
}
my $jquery_custom_header = <<EOF;
<?dyn="WindowCtlJs"?>
EOF
sub JqueryCustomHeader{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $base_header);
  $this->RefreshEngine($http, $dyn, $jquery_custom_header);
}
my $basic_footer = <<EOF;
</body></html>
EOF
my $frame_footer = <<EOF;
<noframes>
<body <?dyn="_QueueBGColor"?>>
<h1>Need Frames</h1>
<p>This document applications needs frames to display itself properly</p>
</body>
</noframes>
</html>
EOF
sub Footer{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $basic_footer);
}
sub FrameFooter{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $frame_footer);
}
sub Redirect{
  my($this, $http, $dyn) = @_;
  $this->html_header($http, $dyn);
  $http->queue(
    "<html><header>" .
    "<META HTTP-EQUIV=REFRESH CONTENT=\"0; URL=$dyn->{url}\" />" .
    "</head><body>Redirecting.... <a href=\"$dyn->{url}\">$dyn->{url}</a>" .
    "</body></html>");
}
sub title{
  my($this, $http, $dyn) = @_;
  if(defined $this->{title}){
    $http->queue($this->{title});
  } else {
    $http->queue("title not set");
  }
}
sub _BGColorHex{
  my($this, $http, $dyn) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  unless (exists ($sess->{bgcolor})) { return ""; }
  return "$sess->{bgcolor}";
}
sub _QueueBGColorHex{
  my($this, $http, $dyn) = @_;
  $http->queue($this->_BGColorHex($http, $dyn));
}
sub _BGColor{
  my($this, $http, $dyn) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  unless (exists ($sess->{bgcolor})) { return ""; }
  return " bgcolor=\"$sess->{bgcolor}\" ";
}
sub _QueueBGColor{
  my($this, $http, $dyn) = @_;
  $http->queue($this->_BGColor($http, $dyn));
}
sub _BGStyleColor{
  my($this, $http, $dyn) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  unless (exists ($sess->{bgcolor})) { return ""; }
  return " style=\"background-color:$sess->{bgcolor}\" ";
}
sub _QueueBGStyleColor{
  my($this, $http, $dyn) = @_;
  $http->queue($this->_BGStyleColor($http, $dyn));
}
sub InvChild{
  my($this, $http, $dyn) = @_;
  $this->InvokeChild($http, $dyn, $dyn->{name}, $dyn->{method});
}
sub InvokeChild{
  my($this, $http, $dyn, $child_name, $child_method) = @_;
  my $child = $this->child($child_name);
  unless(defined $child){
    print STDERR "Invoking non-existent child $child\n\t in $this->{path}:\n";
    print STDERR $this->TraceBack;
    return;
  }
  unless($child->can($child_method)){
    print STDERR "Child $child of\n\t in $this->{path}\n" .
      "/tCan't $child_method:\n";
    print STDERR $this->TraceBack;
    return;
  }
  $child->$child_method($http, $dyn);
}
# Moved here from App instances
# TODO: Go through every modern app and remove the DebugButton method
# "modern app" would be any that ISA Posda::HttpApp::HttpObj (or children)
sub DebugButton{
  my($this, $http, $dyn) = @_;
  if($this->CanDebug){
    $this->RefreshEngine($http, $dyn, qq{
      <span class="btn btn-sm btn-info" 
       onClick="javascript:rt('DebugWindow',
       'Refresh?obj_path=Debug',1600,1200,0);">Debug</span>
    });
  } else {
    print STDERR "Can't debug\n";
  }
}
sub Debug{
  my($this, $http, $dyn) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  $sess->{Privileges}->{capability}->{CanDebug} = 1;
  $this->Redirect($http, { url => "Refresh?obj_path=$dyn->{obj_path}" });
}
sub NoDebug{
  my($this, $http, $dyn) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  delete $sess->{Privileges}->{capability}->{CanDebug};
  $this->Redirect($http, { url => "Refresh?obj_path=$dyn->{obj_path}" });
}
sub Expert{
  my($this, $http, $dyn) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  $sess->{Privileges}->{capability}->{IsExpert} = 1;
  $this->Redirect($http, { url => "Refresh?obj_path=$dyn->{obj_path}" });
}
sub NoExpert{
  my($this, $http, $dyn) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  delete $sess->{Privileges}->{capability}->{IsExpert};
  $this->Redirect($http, { url => "Refresh?obj_path=$dyn->{obj_path}" });
}
sub SetInitialExpertAndDebug{
  my($this, $user) = @_;
  unless(defined $user){
    $user = $this->get_user;
  }
  my $can_debug =
    $main::HTTP_APP_CONFIG->{config}->{Capabilities}->{$user}->{CanDebug};
  my $is_expert =
    $main::HTTP_APP_CONFIG->{config}->{Capabilities}->{$user}->{CanDebug};
  if($can_debug) {
    my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
    $sess->{Privileges}->{capability}->{CanDebug} = 1;
  }
  if($is_expert) {
    my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
    $sess->{Privileges}->{capability}->{IsExpert} = 1;
  }
}
sub AutoRefresh{
  my($this) = @_;
  my $parent = $this->parent();
  my $ref = ref($parent);
  if(
     defined($parent) && 
     $ref &&
     $ref ne "ARRAY" &&
     $ref ne "HASH" &&
     $parent->can("AutoRefresh")
  ){
    $parent->AutoRefresh();
  }
}
sub RefreshAfter{
  my($this, $delay) = @_;
  my $foo = sub {
    my($self) = @_;
    $this->AutoRefresh;
  };
  my $event = Dispatch::Select::Background->new($foo);
  if($delay > 0){
    $event->timer($delay);
  } else {
    $event->queue;
  }
}
sub Close{
  my($this) = @_;
  my $parent = $this->parent();
  my $ref = ref($parent);
  if(
     defined($parent) && 
     $ref &&
     $ref ne "ARRAY" &&
     $ref ne "HASH" &&
     $parent->can("Close")
  ){
    $parent->Close();
  }
}
sub JavascriptCloseWindow{
  my($this, $http, $dyn) = @_;
  my $resp = {
    message => "close OK",
  };
  my $r = encode_json $resp;
  $http->HeaderSent;
  $http->queue("HTTP/1.0 200 OK\n");
  $http->queue("Content-type: application/json\n\n");
  $http->queue($r);
#  if($this->{path} eq "Start"){
#    print "Application Terminated Normally\n";
#    $this->shutdown($http, $dyn);
#  } else {
    $this->DeleteSelf();
#  }
}
sub Controller{
  my($this) = @_;
  my $parent = $this->parent();
  if(defined($parent) && $parent->can("Controller")){
    my $ret = $parent->Controller();
    unless(defined $ret){
      my $class = ref($this);
#      my $traceback = $this->TraceBack;
#      print STDERR 
#        "Propagating undefined Controller to $this->{path} ($class)\n" .
#        "$traceback\n\n";
    }
    return $ret;
  }
  return undef;
}
sub Alert{
  my $this = shift @_;
  my $msg = shift @_;
  my $resp = shift @_;
  my $time = $this->now;
  print STDERR "Alert: ($time) $msg\n";
  my $controller = $this->InvokeAbove("Controller");
  if (defined $controller) { 
    if (defined $resp) {
      unless (exists $resp->{obj}) 
        { $resp->{obj} = $this->{path}; }
    }
    $controller->QueueAlertMsg($msg, $resp, @_); return;
  }
  print STDERR "No controller to alert user...\n";
}
##############
sub AjaxPosdaGet{
  my($this, $http, $dyn) = @_;
  my $class = ref($this);
  unless (exists ($dyn->{obj})) {
    my $class = ref($this);
    print STDERR "$class AjaxPosdaGet: ERROR: No dyn obj defined.\n";
    return;
  }
  unless (exists ($this->{$dyn->{obj}})) {
    my $class = ref($this);
    print STDERR $class . 
      " AjaxPosdaGet: ERROR: No obj $dyn->{obj} defined.\n";
    return;
  }
  my $r;
  if(
    ref($this->{$dyn->{obj}}) eq "ARRAY" ||
    ref($this->{$dyn->{obj}}) eq "HASH"
  ){
    $r = encode_json $this->{$dyn->{obj}};
  } else{
    print STDERR "$this->{path} AjaxPosdaGet:\n" .
      "\tNot an ARRAY or HASH - $this->{$dyn->{obj}}\n";
    $http->HeaderSent;
    $http->queue("HTTP/1.0 401 NOT FOUND\n\n");
    return;
  }
  $http->HeaderSent;
  $http->queue("HTTP/1.0 200 OK\n");
  $http->queue("Content-type: application/json\n\n");
  $http->queue($r);
}
sub DeleteAndClose{
  my($this, $http, $dyn) = @_;
  my $class = ref($this);
#print "Posda::Httppp::DeleteAndClose called, $this->{path}, class: $class.\n";
  Posda::HttpObj::QueueCloseWindow($this, $http, $dyn);
}
sub QueueCloseWindow{
  my($this, $http, $dyn) = @_;
  $http->HtmlHeader();
  $http->queue("<html><head><title>Close Me Please</title></head>" .
    "<body");
  $this->_QueueBGColor($http, $dyn);
  $http->queue(" onLoad=\"".
    "if(window.opener) try { window.opener.focus() } catch (e) {};" .
    "try { self.close() } catch (e) {};" .
    "\">" .
    "<h1>Goodbye</h1><p>This window should be closed.  " .
    "If it didn't close, please close it.</p></body></html>");
# print STDERR "HttpObj::QueueCloseWindow queued close html, called on obj: $this->{path}.\n";
  # $this->DeleteSelf();
  # $this->DeleteSelfInBackground();
  Dispatch::Select::Background->new($this->DeleteSelfInBackground)->queue;
}
sub DeleteCloseWindow{
  my($this, $http, $dyn) = @_;
  if(
    defined($this->{notify}) &&
    defined($this->{notify_method})
  ){
    my $not_obj = $this->get_obj($this->{notify});
    my $not_method = $this->{notify_method};
    if(defined($not_obj) && $not_obj->can($not_method)){
      $not_obj->$not_method($this->{window_name});
    } else {
      #print STDERR "$this->{notify} can't $this->{notify_method}\n";
    }
  }
  my $parent = $this->parent();
  if (defined($parent)) {
    if ($parent->can("AutoRefresh"))
       { $parent->AutoRefresh; }
    if ($parent->can("Controller")){
      my $controller = $parent->Controller;
      if (defined $controller) {
        my $wb_obj = $controller->sibling("WindowButtons");
        if (defined $wb_obj  &&  $wb_obj->can("AutoRefresh"))
          { $wb_obj->AutoRefresh; }
      }
    }
  }
# print STDERR "HttpObj::DeleteCloseWindow queueing close html, called on obj: $this->{path}.\n";
  Posda::HttpObj::QueueCloseWindow($this, $http, $dyn);
}
my $shutdown_message = <<EOF;
<?dyn="Header"?>
<body <?dyn="_QueueBGColor"?>>
<center><b>Thank you</b><br />
<em>Please close this window.  It can't be closed from a script,
and the application to which it is connected has closed.</em>
</center>
</body></html>
<?dyn="shutdown"?>
EOF
#sub Shutdown{
#  my($this, $http, $dyn) = @_;
#  $this->{ShuttingDown} = 1;
#  $this->RefreshEngine($http, $dyn, $shutdown_message);
#}
sub MakeCleanUp{
  my $exiter = sub {
    if($ENV{POSDA_DEBUG}){
      my $dbg = sub { print STDERR @_ };
      print STDERR "main::HTTP_APP_SINGLETON = ";
      Debug::GenPrint($dbg, $main::HTTP_APP_SINGLETON, 1, 2);
      print STDERR "\n";
      print STDERR "Select Dump:\n";
      Dispatch::Select::Dump(\*STDERR);
      print STDERR "end select dump\n";
    }
    if($ENV{POSDA_DEBUG}){
      print STDERR "Clearing App Singleton->{socket_server}\n";
    }
    $main::HTTP_APP_SINGLETON->{socket_server}->Remove();
    for my $i (keys %{$main::HTTP_APP_SINGLETON->{Inventory}}){
      if($ENV{POSDA_DEBUG}){
        print STDERR "Clearing App Singleton->{Inventory}->{$i}\n";
      }
      delete $main::HTTP_APP_SINGLETON->{Inventory}->{$i};
    }
    if($ENV{POSDA_DEBUG}){
      print "Clearing Finishing App Singleton\n";
    }
    $main::HTTP_APP_SINGLETON = undef;
    if($ENV{POSDA_DEBUG}){
      print STDERR "Clearing all timers\n";
    }
    Dispatch::Select::Background::clear_all_timers();
    if($ENV{POSDA_DEBUG}){
      print STDERR "Creating Exiter\n";
    }
    my $exiter = Dispatch::EventHandler::MakeExit();
    if($ENV{POSDA_DEBUG}){
      print STDERR "Creating backgrounder for Exiter\n";
    }
    my $bkg = Dispatch::Select::Background->new($exiter);
    if($ENV{POSDA_DEBUG}){
      print STDERR "Queuing backgrounder for Exiter\n";
    }
    $bkg->timer(5);
  };
  return $exiter;
}
sub shutdown{
  my($this) = @_;
print STDERR "In shutdown\n";
$ENV{POSDA_DEBUG} = 1;
  my $exiter = $this->MakeCleanUp();
  my $bkg = Dispatch::Select::Background->new($exiter);
  $bkg->timer(1);
}
sub DESTROY{
  my($this) = @_;
  if($ENV{POSDA_DEBUG}){
    print STDERR "DESTROY: $this\n";
  }
}
sub NoOp{
}
1;
