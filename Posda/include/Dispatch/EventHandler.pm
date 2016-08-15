#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Dispatch::EventHandler;
use Method::Signatures::Simple;
use Socket;
use Dispatch::Select;
use File::Path;
use Fcntl qw( :flock :DEFAULT F_GETFL F_SETFL O_NONBLOCK );
use Storable qw( store_fd fd_retrieve nfreeze thaw);
use JSON;

sub MakeExit{
  my $exiter = sub {
    my($disp) = @_;
    if($ENV{POSDA_DEBUG}){
      print STDERR "Select Dump:\n";
      Dispatch::Select::Dump(\*STDERR);
      print STDERR "end select dump\n";
      print STDERR "Calling exit (see what DESTROYS)\n";
    }
    exit();
    return;
  };
  return $exiter;
}
sub MakeInitializer{
  my($this) = @_;
  my $initializer = sub {
    unless ($this->can("Initialize")) {
      my $class = ref($this);
      print STDERR "${class}::MakeInitializer: obj: " .
        "$this->{path} has no Initialize routine.\n";
      print STDERR $this->TraceBack;
      return;
    }
    $this->Initialize;
  };
  return $initializer;
}

sub InvokeAfterDelay{
  my $this = shift @_;
  my $method = shift @_;
  my $delay = shift @_;
  my @args = @_;
  my $initializer = sub {
    $this->$method(@args);
  };
  my $back = Dispatch::Select::Background->new($initializer);
  if($delay){
    $initializer->timer($delay);
  } else {
    $initializer->queue;
  }
}
sub ReadWriteChild{
# execute $cmd in subprocess; returns bi-directional pipe and pid of child
  my($this, $cmd) = @_;
  my($child, $parent, $oldfh); 
  socketpair($parent, $child, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or 
    $this->Die("socketpair: $!");
  $oldfh = select($parent); $| = 1; select($oldfh);
  $oldfh = select($child); $| = 1; select($oldfh);
  my $child_pid = fork;
  unless(defined $child_pid) {
    $this->Die("couldn't fork: $!");
  }
  if($child_pid == 0){
    close $child;
    # these dies are not methods because they are in the child:
    unless(open STDIN, "<&", $parent){die "Redirect of STDIN failed: $!"}
    unless(open STDOUT, ">&", $parent){die "Redirect of STDOUT failed: $!"}
    exec $cmd;
    die "exec failed: $!";
  } else {
    $this->{child_pid} = $child_pid;
    my $flags = fcntl($child, F_GETFL, 0);
    $flags = fcntl($child, F_SETFL, $flags | O_NONBLOCK);
    close $parent;
  }
  return $child, $child_pid;
}
sub TraceBack{
  my($this) = @_;
  my $i = 1;
  my $traceback = "";
  while(caller($i)){
    my @foo = caller($i);
    $i++;
    my $file = $foo[1];
    my $line = $foo[2];
    $traceback .= "\n\tline $line of $file";
  }
  return $traceback;
}
sub Die{
  my($this, $message) = @_;
    my $traceback = $this->TraceBack;
    my $mem_percent = "<unknown>";
    if($this->can("get_obj")){
      my $mem_mon = $this->get_obj("Start/MemMonitor");
      if(
        #don't want to crash within a crash...
        $mem_mon && $mem_mon->isa("HASH") &&
        ref($mem_mon->{histogram}) eq "ARRAY" &&
        ref($mem_mon->{histogram}->[0]) eq "HASH"
      ){
        mem_entry:
        for my $i (0 .. $#{$mem_mon->{histogram}}){
          if(ref($mem_mon->{histogram}->[$i]) eq "HASH"){
            $mem_percent = "$mem_mon->{histogram}->[$i]->{pmem} ($i)";
            last mem_entry;
          }
        }
      }
    }
    my $objects = "";
    if($this->can("obj_inventory")){
      $objects = "\nObject Inventory:";
      my @obj_inventory = $this->obj_inventory;
      my $objects = "";
      for my $i (sort @obj_inventory){
        $objects .= "\n\t$i";
      }
    }
    my $user = "<unknown>";
    if($this->can("get_user")){ $user = $this->get_user }
    my $path = "<unknown>";
    if(
      ref($this) && $this->isa("HASH") &&
      defined($this->{path})
    ){ $path = $this->{path} }
    die "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n" .
        "Requiescat in pace: $$\n" .
        "Program: $0\n" .
        "User: " . $user .
        "\nObject: $path\n" .
        "Message: $message\n" .
        "Memory percentage: $mem_percent\n" .
        "$objects\n" .
        "\nTraceback: $traceback\n" .
        "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
}
sub now{
  my($this) = @_;
  my($sec, $min, $hr, $mday, $mon, $yr, $wday, $yday, $isdst) = 
    localtime(time);
  return sprintf("%04d-%02d-%02d:%02d:%02d:%02d", $yr+1900, $mon + 1,
    $mday, $hr, $min, $sec);
}
sub now_dir{
  my($this) = @_;
  my($sec, $min, $hr, $mday, $mon, $yr, $wday, $yday, $isdst) = 
    localtime(time);
  return sprintf("%04d-%02d-%02d_%02d_%02d_%02d", $yr+1900, $mon + 1,
    $mday, $hr, $min, $sec);
}
sub HarvestPid{
  my $this  = shift @_;
  my $pid = shift @_;
  my $status = waitpid($pid, 0);
  if($status != $pid){
    print STDERR "waitpid($pid, 0) = ";
    print STDERR "$status\n";
    print STDERR "\tHmmmm... ($!) ($?) \n";
  }
  return $status;
}
sub PidHarvester{
  my $this  = shift @_;
  my $pid = shift @_;
  my $sub = sub {
    $this->HarvestPid($pid);
  };
  return $sub;
}
sub CreateNotifierClosure{
  my $this  = shift @_;
  my $method = shift @_;
  my @args = @_;
  my $foo = sub {
    if($this->can($method)){
      $this->$method(@args);
    } else {
      print STDERR "Notifier can't $method\n";
    }
  };
  return $foo;
}
sub RegisterEventCallback{
  my $this = shift @_;
  my $event = shift @_;
  my $notified_name = shift @_;
  my $notifier = $this->CreateNotifierClosure(@_);
  unless(exists $this->{EventCallbacks}){
    $this->{EventCallbacks} = [];
  }
  push(@{$this->{EventCallbacks}}, {
    obj_path => $notified_name,
    notifier => $notifier,
    event => $event,
  });
}
sub NotifyEvent{
  my($this, $event) = @_;
  unless(exists $this->{EventCallbacks}){ return }
  unless(ref($this->{EventCallbacks}) eq "ARRAY"){ return }
  for my $i (@{$this->{EventCallbacks}}){
    if($i->{event} eq $event){
      &{$i->{notifier}}();
    }
  }
}
sub RemoveSpecificEventCallbacks{
  my($this, $event, $notified_name) = @_;
  unless(exists $this->{EventCallbacks}){ return }
  unless(ref($this->{EventCallbacks}) eq "ARRAY"){ return }
  my @remaining;
  for my $i (@{$this->{EventCallbacks}}){
    unless($i->{event} eq $event && $i->{obj_path} eq $notified_name){
      push(@remaining, $i);
    }
  }
  $this->{EventCallbacks} = \@remaining;
}
sub RemoveEventCallbacks{
  my($this, $event) = @_;
  unless(exists $this->{EventCallbacks}){ return }
  unless(ref($this->{EventCallbacks}) eq "ARRAY"){ return }
  my @remaining;
  for my $i (@{$this->{EventCallbacks}}){
    unless($i->{event} eq $event){
      push(@remaining, $i);
    }
  }
  $this->{EventCallbacks} = \@remaining;
}
sub RemoveAllEventCallbacks{
  my($this) = @_;
  $this->{EventCallbacks} = [];
}
sub KillProcessAndChildren{
  my($class, $pid) = @_;
  my @kill_list = $pid;
  my $cmd = "ps -a -o'ppid,pid'|awk '(\$1 == $pid){print \$2}'";
  open my($foo), "$cmd|";
  while(my $line = <$foo>){
    chomp $line;
    if($line =~ /^\s*(\d+)\s*$/){
      push(@kill_list, $1);
    }
  }
  my $count = kill 9, @kill_list;
}

func JSONSubProcess($command, $finished_callback) {
  # Execute the given command using Dispatch::LineReader
  # Assume the returned lines form a single JSON object
  # Decode that object and pass it to $finished_callback
  my @lines;
  Dispatch::LineReader->new_cmd($command,
    func ($line) {
      push @lines, $line;
    },
    func () {
      my $json = join(' ', @lines);
      my $obj = decode_json($json);

      &$finished_callback($obj);
    }
  );
}

sub SerializedSubProcess{
  my($this, $args, $command, $finished) = @_;
#  my $serialized_args = &Storable::nfreeze($args);
#  $serialized_args = "pst0" . $serialized_args;
  my $serialized_args = &Storable::freeze($args);
  $serialized_args = "pst0" . $serialized_args;
  my($fh, $pid) = $this->ReadWriteChild($command);
  Dispatch::Select::Socket->new($this->WriteSerializedData($serialized_args,
    $finished, $pid), $fh)->Add("writer");
}

# Parameters are normal, response will be a Serialized Response
sub SemiSerializedSubProcess {
  my($this, $command, $finished) = @_;

  my($fh, $pid) = $this->ReadWriteChild($command);
  Dispatch::Select::Socket->new(
    $this->ReadSerializedResponse($finished, $pid), $fh)->Add("reader");
}

sub WriteSerializedData{
  my($this, $data, $finished, $pid) = @_;
  my $length = length($data);
  my $bytes_written = 0;
  my $sub = sub {
    my($disp, $sock) = @_;
    if($bytes_written >= $length){
      $disp->Remove("writer");
      Dispatch::Select::Socket->new(
        $this->ReadSerializedResponse($finished, $pid),
        $sock
      )->Add("reader");
    } else {
      my $written = syswrite $sock, $data, 
        $length - $bytes_written, $bytes_written;
      unless(defined $written){
        print STDERR "write failed ($!)\n";
        die "No point going on now";
      }
      if($written >= 0) {
        $bytes_written += $written;
        return;
      }
    }
  };
  return $sub;
}
sub ReadSerializedResponse{
  my($this, $finished, $pid) = @_;
  my $text = "";
  my $sub = sub {
    my($disp, $sock) = @_;
    my $count = sysread($sock, $text, 1024, length($text));
    unless(defined $count) { die "read failed ($!)" }
    if($count <= 0){
      my $result;
      my $text_len = length $text;
#      print STDERR "text len: $text_len\n";
      my $res_text;
      if($text =~ /^pst0(.*)$/s){
#        print STDERR "Discarding a pst0 from result text\n";
        $res_text = $1;
      } else {
        $res_text = $text;
      }
      my $res_length = length $res_text;
#      print STDERR "Length of response text: $res_length\n";
      eval{
        $result = &Storable::thaw($res_text);
      };
      if($@) {
        &{$finished}("Failed", { mess => $@ });
      } else {
        &{$finished}("Succeeded", $result);
      }
      $disp->Remove;
      waitpid $pid, 0;
    } 
  };
  return $sub;
}
#########################################################
#  Lock related methods
sub PassiveLockCheck{
  my($this, $fn) = @_;
  my $result = $this->LockFile($fn);
  if($result->{status} eq "Error"){
    return $result->{content};
  }
  $this->UnLockFile($result);
  return undef;
}
sub LockFile{
  my($this, $fn)  = @_;
  my $session = $this->{session};
  my $user = $this->get_user;
  my $now = $this->now;
  my $lfh;
  my $content;
  unless (open $lfh,"+>>", "$fn") {
#    print STDERR "could not open lock file: $fn, error: $!.\n";
    return ({ status => "Error",
             error => "could not open lock file: $fn, error: $!"} ) ;
  }
  if (flock($lfh, LOCK_EX | LOCK_NB)) {
    # got lock
    seek $lfh, 0, 0;
    $lfh->autoflush(1);
    my $content = "Pid: " . $$ .
                ", Session: " . $session .
                ", User: " . $user .
                ", TimeStamp: " . $now;
    print $lfh $content;
    $lfh->autoflush(1);
    # print "Managed directory: dir: $dir now locked: $content.\n";
    return ({ status => "OK", lfh => $lfh , file => $fn} );
  } else {
    # don't have lock
    seek $lfh, 0, 0;
    $content = <$lfh>;
    chomp $content;
    close $lfh;
    # print "Managed directory: dir: $dir already locked by: $content.\n";
    return ({
      status => "Error",
      content => $content,
      error => "Managed directory: $fn already locked by: <br />" .
        "$content <br />" .
        "Kill the Pid if you know the session has been abandoned.<br />" .
        "But this will stop all sessions using this host:port"
    });
  }
}
sub UnLockFile{
  my($class, $h) = @_;
  my $fn = $h->{file};
  my $lfh = $h->{lfh};
  if (defined $lfh) {
    unlink $fn;
    flock($lfh, LOCK_UN);
    close $lfh;
    $lfh = undef;
  }
  return 0;
}
# End Lock related functions
#########################################################
sub DeleteSelfInBackground{
  my($this) = @_;
  my $deleater = sub {
# print STDERR "HttpObj::DeleteSelfInBackground called on obj: $this->{path}.\n";
    $this->DeleteSelf;
  };
  return $deleater;
}
sub DESTROY{
  my($this) = @_;
  if($ENV{POSDA_DEBUG}){
    print STDERR "DESTROY: $this\n";
  }
}
1;
