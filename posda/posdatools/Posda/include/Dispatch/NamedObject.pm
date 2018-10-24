#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Dispatch::NamedObject;
use Dispatch::EventHandler;
use Dispatch::Select;
use File::Path;
use Posda::Config 'Config';
use Posda::DebugLog;

use vars qw( @ISA );
my $RoutingDebug = "";
@ISA = qw( Dispatch::EventHandler );

sub new {
  my($class, $session, $name) = @_;
  my $this = {
    path => "$name",
    session => $session,
  };
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($session);
  unless(exists $sess->{root}){ $sess->{root} = {} }
  my $root = $sess->{root};
  $root->{$name} = $this;
  if(Config('debug')){
    print STDERR "NEW: $class\n";
  }
  return bless $this, $class;
};
sub AssignName{
  my($this, $session, $name) = @_;
  $this->{session} = $session;
  $this->{path} = $name;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($session);
  unless(exists $sess->{root}){ $sess->{root} = {} }
  my $root = $sess->{root};
  $root->{$name} = $this;
}
sub GetPrivs{
  my($this) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  return $sess->{Privileges};
}
sub SetPrivs{
  my($this, $privs) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  $sess->{Privileges} = $privs;
}
sub GetAppPrivs{
  my($this, $app) = @_;
  return $this->GetPrivs()->{app}->{$app};
}
sub delete_obj{
  my($this) = @_;
  $this->DeleteSelf();
}
sub DeleteSelf{
  my($this) = @_;
  $this->DeleteObj($this->{path});
}
sub DeleteObj{
  my($this, $path) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  my $obj = $sess->{root}->{$path};
  if($obj && $obj->can("CleanUp")){
    $obj->CleanUp();
  }
  delete $sess->{root}->{$path};
}
sub DeleteMySession{
  my($this) = @_;
  $main::HTTP_APP_SINGLETON->DeleteSession($this->{session});
}
sub get_session{
  my($this) = @_;
  return $main::HTTP_APP_SINGLETON->GetSession($this->{session});
}
sub get_user{
  my($this) = @_;
  my $sess =  $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  return $sess->{AuthUser};
}
sub obj_inventory{
  my($this) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  return sort keys %{$sess->{root}};
}
sub NotifySessionHeads{
  my $class = shift @_;
  my $method = shift @_;
  my @sessions = sort keys %{$main::HTTP_APP_SINGLETON->{Inventory}};
  for my $sess (@sessions){
    my %roots;
    my $session = $main::HTTP_APP_SINGLETON->GetSession($sess);
    for my $obj_name (keys %{$session->{root}}){
      my @root_names = split(/\//, $obj_name);
      $roots{$root_names[0]} = 1;
    }
    for my $root_name (keys %roots){
      if(
        exists($session->{root}->{$root_name}) &&
        ref($session->{root}->{$root_name}) &&
        $session->{root}->{$root_name}->can($method)
      ){
        print STDERR "$sess" . "::$root_name" . "::$method\n";
        $session->{root}->{$root_name}->$method(@_);
      } else {
        print STDERR "$sess" . "::$root_name can't $method\n";
      }
    }
  }
}

sub get_obj{
  my($this, $id) = @_;
  unless(defined $id) {
    print STDERR "get_obj called with undefined id\n";
    return undef;
  }
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  unless(exists $sess->{root}->{$id}) {
    return undef;
  }
  return $sess->{root}->{$id};
}
sub get_obj_session{
  my($class, $session, $id) = @_;
  unless(defined $id) {
    print STDERR "get_obj called with undefined id\n";
    return undef;
  }
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($session);
  unless(exists $sess->{root}->{$id}) {
    print STDERR "get_obj_session of unknown obj: $id\n";
    return undef;
  }
  return $sess->{root}->{$id};
}
sub child{
  my($this, $name) = @_;
  my $path = "$this->{path}/$name";
  unless(
    exists $main::HTTP_APP_SINGLETON->{Inventory}->{$this->{session}}->{root}
      ->{$path}
  ){
    return undef
  }
  my $ret = 
  $main::HTTP_APP_SINGLETON->{Inventory}->{$this->{session}}->{root}->{$path};
  return $ret;
}
sub child_path{
  my($this, $name) = @_;
  my $path = "$this->{path}/$name";
  return $path;
}
sub child_name{
  my($this, $path) = @_;
  return ($path =~ /^.*\/([^\/]*)$/) ? $1 : $path;
}
sub children{
  my($this) = @_;
  my @children;
  for my $name ($this->children_names){
    push(@children, $this->get_obj($name));
  }
  return \@children;
}
sub children_names{
  my($this) = @_;
  return $this->children_names_of_path($this->{path});
}
sub children_names_of_path{
  my($this, $path) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  my %children; 
  for my $i (sort keys %{$sess->{root}}){
    if( $i =~ /^($path\/[^\/]+)$/){
      my $child = $1;
      $children{$i} = 1;
    }
  }
  return keys %children;
}
sub children_nick_names{
  my($this) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  my %children; 
  for my $i (sort keys %{$sess->{root}}){
    if( $i =~ /^$this->{path}\/([^\/]+)$/){
      my $child = $1;
      $children{$i} = 1;
    }
  }
  return keys %children;
}
sub delete_children{
  my($this) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  my $list = $this->children();
  for my $obj(@$list){
    if(defined $obj && $obj->can("delete_obj")){
      $obj->delete_obj();
    }
  }
}
sub descendant_names{
  my($this) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  my %descendants; 
  for my $i (sort keys %{$sess->{root}}){
    if( $i =~ /^($this->{path}\/.*)$/){
      my $descendant = $1;
      $descendants{$i} = 1;
    }
  }
  return keys %descendants;
}
sub descendants{
  my($this) = @_;
  my @descendants;
  for my $name ($this->descendant_names){
    push(@descendants, $this->get_obj($name));
  }
  return \@descendants;
}
sub delete_descendants{
  my($this) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  my $list = $this->descendants();
  for my $obj(@$list){
    $obj->delete_obj();
  }
}
sub delete_child{
  my($this, $name) = @_;
  my $child_name = "$this->{path}/$name";
  my $obj = $this->get_obj($child_name);
  $obj->delete_obj();
}
sub parent {
  my($this) = @_;
  if($this->{path} =~ /^(.*)\/[^\/]*$/){
    my $parent = $1;
    return $main::HTTP_APP_SINGLETON->{Inventory}->{$this->{session}}->{root}
    ->{$parent};
  } else {
    return undef;
  }
}
sub parent_path {
  my($this) = @_;
  if($this->{path} =~ /^(.*)\/[^\/]*$/){
    my $parent = $1;
    return $parent;
  }
}
sub uncle {
  my($this, $name) = @_;
  my $p = $this->parent;
  unless($p) { return undef }
  my $uncle = $p->sibling($name);
  return $uncle;
}
sub uncle_path {
  my($this, $name) = @_;
  my $uncle = $this->uncle($name);
  return $uncle->{path};
}
sub sibling {
  my($this, $name) = @_;
  my $sib_name;
  if($this->{path} =~ /^(.*)\/[^\/]*$/){
    $sib_name = $1 . "/$name";
  } else {
    $sib_name = $name;
  }
  return $this->get_obj($sib_name);
}
sub sibling_path {
  my($this, $name) = @_;
  my $sib_name;
  if($this->{path} =~ /^(.*)\/[^\/]*$/){
    $sib_name = $1 . "/$name";
  } else {
    $sib_name = $name;
  }
  return $sib_name;
}
#########################################################
# Privilege Related Functions
sub GetSession{
  my($this) = @_;
  return $main::HTTP_APP_SINGLETON->{Inventory}->{$this->{session}};
}
sub GetPrivileges {
  my($this) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  return $sess->{Privileges};
}
sub SetPrivileges{
  my($this, $privileges) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  $sess->{Privileges} = $privileges;
}
sub GetEnvValue{
  my($this, $name) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  if (exists ($sess->{Privileges}->{env}->{$name}))
    { return $sess->{Privileges}->{env}->{$name}; }
  if ($ENV{$name}) { return $ENV{$name}; }
  return undef;
}
sub GetIdentityValue{
  my($this, $name) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  if (exists ($sess->{Privileges}->{identity}->{$name}))
    { return $sess->{Privileges}->{identity}->{$name}; }
  return undef;
}
# End Privilege related functions
sub CanDebug{
  my($this) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  if (defined $this->{Environment}->{ApplicationName} and defined $sess->{permissions}) {
    return $sess->{permissions}->has_permission($this->{Environment}->{ApplicationName},'debug');
  } else {
    DEBUG "CanDebug called before user logged in, or on object with no environment!";
    return 0;
  }
}
sub IsExpert{
  my($this) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  if(exists $sess->{Privileges}->{capability}->{IsExpert}){
    return 1;
  }
  return 0;
}
sub HasPrivilege{
  my($this, $priv) = @_;
  my $sess = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
  if(exists $sess->{Privileges}->{capability}->{$priv}){
    return 1;
  }
  return 0;
}
##########################
###  Messages ????????????
sub Message{
  my($this, $msg) = @_;
  my $msg_obj = $this->sibling("Messages");
  if (defined $msg_obj  &&  $msg_obj->can("Message")) {
    return ($msg_obj->Message($msg));
  }
  my $parent = $this->parent();
  if (defined($parent) && $parent->can("Message")){
    return ($parent->Message($msg));
  }
  my $class = ref($this);
  print STDERR 
    "Propagating undefined Message to $this->{path} ($class)\n";
  return undef;
}
sub Warning{
  my($this, $msg) = @_;
  my $msg_obj = $this->sibling("Messages");
  if (defined $msg_obj  &&  $msg_obj->can("Warning")) {
    return ($msg_obj->Warning($msg));
  }
  my $parent = $this->parent();
  if (defined($parent) && $parent->can("Warning")){
    return ($parent->Warning($msg));
  }
  my $class = ref($this);
  print STDERR 
    "Propagating undefined Warning to $this->{path} ($class)\n";
  return undef;
}
sub ClearMessages{
  my($this) = @_;
  my $msg_obj = $this->sibling("Messages");
  if (defined $msg_obj  &&  $msg_obj->can("ClearMessages")) {
    return ($msg_obj->ClearMessages);
  }
  my $parent = $this->parent();
  if (defined($parent) && $parent->can("ClearMessages")){
    return ($parent->ClearMessages);
  }
  my $class = ref($this);
  print STDERR 
    "Propagating undefined ClearMessages to $this->{path} ($class)\n";
  return undef;
}
sub ShowMessages{
  my($this) = @_;
  my $msg_obj = $this->sibling("Messages");
  if (defined $msg_obj  &&  $msg_obj->can("Show")) {
    return ($msg_obj->Show);
  }
  my $parent = $this->parent();
  if (defined($parent) && $parent->can("ShowMessages")){
    return ($parent->ShowMessages);
  }
  my $class = ref($this);
  print STDERR 
    "Propagating undefined ShowMessages to $this->{path} ($class)\n";
  return undef;
}
sub HideMessages{
  my($this) = @_;
  my $msg_obj = $this->sibling("Messages");
  if (defined $msg_obj  &&  $msg_obj->can("Hide")) {
    return ($msg_obj->Hide);
  }
  my $parent = $this->parent();
  if (defined($parent) && $parent->can("HideMessages")){
    return ($parent->HideMessages);
  }
  my $class = ref($this);
  print STDERR 
    "Propagating undefined HideMessages to $this->{path} ($class)\n";
  return undef;
}
###  Messages ????????????
###########################
##########################
### Routing
sub RoutingDebugState{
  my($this) = @_;
  return $RoutingDebug;
}
sub EnableRoutingDebug{
  my($this, $handler) = @_;
  $RoutingDebug = $handler;
}
sub DisableRoutingDebug{
  my($this) = @_;
  $RoutingDebug = "";
}
sub RoutingDebug{
  my($this, $type, $method, $message) = @_;
  my $obj = $this->get_obj($RoutingDebug);
  if($obj && $obj->can("ProcessRoutingDebug")){
    $obj->ProcessRoutingDebug($this->{path}, $type, $method, $message);
  } else {
    print STDERR "$this->{path}: Routing Debug Cancelled\n";
    $RoutingDebug = "";
  }
}
sub CollectFromAbove{
  my($this, $method) = @_;
  if($RoutingDebug){
    $this->RoutingDebug("Collection", $method, "Requesting");
  }
  return _CollectFromAbove(@_);
}
sub _CollectFromAbove{
  my $this = shift @_;
  my $method = shift @_;
  if(exists $this->{RoutesBelow}->{$method}){
    if($RoutingDebug){
      $this->RoutingDebug("Collection", $method, "Routing");
    }
    return $this->CollectFromBelow($method);
  } else {
    my $parent = $this->parent;
    if($parent && $parent->can("_CollectFromAbove")){
      return $parent->_CollectFromAbove($method);
    } else {
      print STDERR "CollectFromAbove($method) escaped into aether " .
        "from $this->{path}\n";
      return undef;
    }
  }
}
sub CollectFromBelow{
  my $this = shift @_;
  my $method = shift @_;
  my @collection;
  if($this->can($method)){
    unless(exists $this->{Exports}->{$method}){
      my $class = ref($this);
      print STDERR "Invoking non exported method $method:\n" .
        "\tclass: $class\n" .
        "\tobj: $this->{path}\n";
    }
    my $foo = $this->$method(@_);
    if($RoutingDebug){
      my $extra = "";
      if(defined($foo) && ref($foo) eq "ARRAY"){
        my $count = @$foo;
        $extra = " ($count)";
      }
      $this->RoutingDebug("Collection", $method, "Executing$extra");
    }
    if(defined($foo) && ref($foo) eq "ARRAY"){
      for my $i (@$foo) { push @collection, $i }
    }
  }
  my $kids = $this->children();
  kid:
  for my $i (@$kids) {
    if(exists $i->{RoutesBelow}->{$method}){
      if($RoutingDebug){
        $this->RoutingDebug("Collection", $method, "Blocking Entry From Above");
      }
      next kid;
    }
    my $foo = $i->CollectFromBelow($method, @_);
    if(defined($foo) && ref($foo) eq "ARRAY"){
      for my $i (@$foo) { push @collection, $i }
    }
  }
  return \@collection;
}
sub InvokeBelowDepth{
  my $this = shift @_;
  my $method = shift @_;
  my @args = @_;
  if($this->can($method)) {
    unless(exists $this->{Exports}->{$method}){
      my $class = ref($this);
      print STDERR "Invoking non exported method $method:\n" .
        "\tclass: $class\n" .
        "\tobj: $this->{path}\n";
    }
    if($RoutingDebug){
      $this->RoutingDebug("Invocation", $method, "Executing");
    }
    if(wantarray){
      my @foo = $this->$method(@args);
      return @foo;
    }
    my $ret = $this->$method(@args);
    return $ret;
  } else {
    my $kids = $this->children();
    kid:
    for my $i (@$kids){
      if(exists $i->{RoutesBelow}->{$method}){
        if($RoutingDebug){
          $this->RoutingDebug("Invocation", $method, 
            "Blocking Entry From Above");
        }
        next kid;
      }
      if(wantarray){
        my @foo = $i->InvokeBelowDepth($method, @args);
        if($#foo >= 0){
           return @foo
        }
      } else {
        my $ret = $i->InvokeBelowDepth($method, @args);
        if(defined $ret) { return $ret }
      }
    }
    return;
  }
  print STDERR "shouldn't ever get here\n";
  return 0;
}
#### May want to deprecate this???
sub FetchFromAboveByPath{
  my($class, $session, $path, $method) = @_;
  my $p;
  my $parent_path;
  if($path =~ /^(.*)\/[^\/]*$/){
    $parent_path = $1;
    $p =  $main::HTTP_APP_SINGLETON->{Inventory}->{$session}->{root}->{$parent_path};
  } else {
    print STDERR "FetchFromAboveByPath couldn't find parent path for ($session, $path)\n" .
      "\ttried $parent_path\n";
    return undef;
  }
  if(defined $p){
    if(wantarray){
      my @foo = $p->FetchFromAbove($method);
      return @foo;
    }
    return $p->FetchFromAbove($method);
  }
  print STDERR "FetchFromAboveByPath found undefined parent path for ($session, $path)\n" .
    "\ttried $parent_path\n";
  return undef;
}
####
sub FetchFromAbove{
  my($this, $method) = @_;
  if($RoutingDebug){
    $this->RoutingDebug("Invocation", $method,
      "Requesting");
  }
  if(wantarray){
    my @foo = _RouteAbove(@_);
    return @foo;
  } else {
    return _RouteAbove(@_);
  }
}
sub RouteAbove{
  my($this, $method) = @_;
  if($RoutingDebug){
    $this->RoutingDebug("Invocation", $method,
      "Requesting");
  }
  if(wantarray){
    my @foo = _RouteAbove(@_);
    return @foo;
  } else {
    return _RouteAbove(@_);
  }
}
sub _RouteAbove{
  my $this = shift @_;
  my $class = ref($this);
  my $method = shift @_;
#  Enable this if methods escaping into aether
#  lots of bogus errors... and ones for escaping methods...
#  if($this->can($method)){
#    unless(
#      exists $this->{RoutesBelow} &&
#      exists $this->{RoutesBelow}->{$method}
#    ){
#      print STDERR "Perhaps $this->{path} should Route $method below??\n";
#    }
#  }
  if(
    exists($this->{RoutesBelow}) &&
    exists($this->{RoutesBelow}->{$method})
  ) {
    if($RoutingDebug){
        $this->RoutingDebug("Invocation", $method,
          "Routing");
    }
    if(wantarray){
      my @foo = $this->InvokeBelowDepth($method, @_);
      if($#foo >= 0){
         return @foo
      }
    } else {
      my $ret = $this->InvokeBelowDepth($method, @_);
      if(defined $ret) { return $ret }
    }
  } else {
    my $p = $this->parent;
    if(defined $p){
      return $p->_RouteAbove($method, @_);
    } else {
      print STDERR "Route Above($method) escaped into aether " .
        "from $this->{path}\n";
    }
  }
}
sub InvokeAbove{
  my($this, $method) = @_;
  if($RoutingDebug){
    $this->RoutingDebug("Invocation", $method,
      "Requesting");
  }
  if(wantarray){
    my @foo = _RouteAbove(@_);
    return @foo;
  } else {
    return _RouteAbove(@_);
  }
}
sub NotifyUp{
  my($this, $method) = @_;
  if($RoutingDebug){
    $this->RoutingDebug("Notification", $method,
      "Requesting");
  }
  _NotifyUp(@_);
}
sub _NotifyUp{
  my $this = shift @_;
  my $method = shift @_;
  my @args = @_;
  my $debug = 0;
#  if($this->can($method)){
#    if($this->{RoutingDebug}){
#        $this->RoutingDebug("NotifyUp invoking $method");
#    }
#    $this->$method(@args);
#  } elsif (
   if(
    exists($this->{RoutesBelow}) &&
    exists($this->{RoutesBelow}->{$method})
  ){
    if($RoutingDebug){
      $this->RoutingDebug("Notification", $method,
        "Routing");
    }
    $this->NotifyDown($method, @args);
  } else {
    my $p = $this->parent;
    if(
      defined($p) && ref($p) && $p->can("_NotifyUp")
    ){
      $p->_NotifyUp($method, @args);
    } else {
      print STDERR "NotifyUp($method) escaped into aether " .
        " from $this->{path}\n";
    }
  }
}
sub NotifyDown{
  my $this = shift @_;
  my $method = shift @_;
  my @args = @_;
  my $debug = 0;
  if($this->can($method)){
    unless(exists $this->{Exports}->{$method}){
      my $class = ref($this);
      print STDERR "Invoking non exported method $method:\n" .
        "\tclass: $class\n" .
        "\tobj: $this->{path}\n";
    }
    if($RoutingDebug){
      $this->RoutingDebug("Notification", $method, "Executing");
    }
    $this->$method(@args);
  }
  my $kids = $this->children();
  kid:
  for my $i (@$kids) {
    if(exists $i->{RoutesBelow}->{$method}){
      if($RoutingDebug){
        $this->RoutingDebug("Notification", $method, 
          "Blocking Entry From Above");
      }
      next kid;
    }
    $i->NotifyDown($method, @args);
  }
}
sub NoOp{
}
##############
sub RegisterFinishCallback{
  my($this, $obj_path, $method) = @_;
  unless(exists $this->{FinishCallbacks}){
    $this->{FinishCallbacks} = [];
  }
  push(@{$this->{FinishCallbacks}}, {
    obj_path => $obj_path,
    method => $method,
  });
}
#####
# Deprecate FinishNotify? Not used anywhere anymore
sub FinishNotify{
  my($this) = @_;
  if(exists $this->{FinishCallbacks}){
    for my $i (@{$this->{FinishCallbacks}}){
      my $obj = $this->get_obj($i->{obj_path});
      my $ref = ref($obj);
      if(
        defined($obj) &&
        $ref &&
        $ref ne "ARRAY" &&
        $ref ne "HASH" &&
        $obj->can($i->{method})
      ){
        my $method = $i->{method};
        $obj->$method();
      }
    }
    delete $this->{FinishCallbacks};
  }
}
##############################
###  Whoa - lots of assumptions herein!!!
sub SafelyDelTempDir{
  my($this, $d) = @_;
  unless (defined $d) { return }
  my $s = $this->get_obj("Start");
  if (defined $s) {
    my $t = $s->TempDir();
    if ($d =~ m/^$t\/*$/) {
      $this->Alert("Obj: $this->{path}: trying to del main work dir: $d");
      my $class = ref($this);
      print STDERR $class . " SafelyDelTempDir: obj: $this->{path} trying to del main work dir: $d.\n";
      my($package, $filename, $line, $subroutine, $hasargs,
      $wantarray, $evaltext, $is_require, $hints, $bit_mask);
      for my $i (1 .. 20){
        ($package, $filename, $line, $subroutine, $hasargs,
        $wantarray, $evaltext, $is_require, $hints, $bit_mask) = caller($i);
        unless (defined $filename) { last }
        print STDERR "\tfrom:$filename, $line\n";
      }
      return;
    }
  }
  if (-d $d) { rmtree($d) }
}
###  Whoa - lots of assumptions herein!!!
##############################
sub DESTROY{
  my($this) = @_;
  if(Config('debug')){
    print STDERR "DESTROY: $this\n";
  }
}
1;
