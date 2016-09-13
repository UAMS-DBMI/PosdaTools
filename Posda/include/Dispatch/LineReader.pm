#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
package Dispatch::LineReader;
use Socket;
use Fcntl qw( :flock :DEFAULT F_GETFL F_SETFL O_NONBLOCK );
use Dispatch::Select;
sub new_serialized_cmd{
  my($class, $cmd, $struct, $lh, $eh) = @_;
  my($child, $parent, $oldfh);
  socketpair($parent, $child, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or
    die("socketpair: $!");
  my $child_pid = fork;
  unless(defined $child_pid) { die "Couldn't fork in new_serialized_cmd" }
print STDERR "Child Pid: $child_pid\n";
  $oldfh = select($parent); $| = 1; select($oldfh);
  $oldfh = select($child); $| = 1; select($oldfh);
  if($child_pid == 0){
    close $child;
    unless(open STDIN, "<&", $parent){die "Redirect of STDIN failed: $!"}
    unless(open STDOUT, ">&", $parent){die "Redirect of STDOUT failed: $!"}
    exec $cmd;
    die "exec failed: $!";
  } else {
    close $parent;
    my $flags = fcntl($child, F_GETFL, 0);
    $flags = fcntl($child, F_SETFL, $flags | O_NONBLOCK);
  }
  my $this = new_fh($class, $child, $lh, $eh, $child_pid);
  $this->pause;
  my $serialized_args = &Storable::freeze($struct);
  $serialized_args = "pst0" . $serialized_args;
  Dispatch::Select::Socket->new(
    $this->EncodeStruct($serialized_args), $child)->Add("writer");
  return $this;
}
sub EncodeStruct{
  my($this, $data) = @_;
  my $written = 0;
  my $length = length($data);
  my $sub = sub {
    my($disp, $sock) = @_;
    if($written >= $length){
      $disp->Remove("writer");
      $this->resume;
    } else {
      my $c = syswrite $sock, $data,
        $length - $written, $written;
      unless(defined $c){
        print STDERR "Dispatch::LineReader::EncodeStruct: " .
          "write failed ($!)\n";
        die "No point trying to continue";
      }
      if($c >= 0){
        $written += $c;
        return;
      }
    }
  };
  return $sub;
}
sub new_cmd{
  my($class, $cmd, $lh, $eh) = @_;
  my $pid = open my $fh, "-|", $cmd
    or die "can't open pipe from \"$cmd\": $!";
  my $this = new_fh($class, $fh, $lh, $eh, $pid);
  return $this;
}
sub new_file{
  my($class, $file, $lh, $eh) = @_;
  my $fh;
  open $fh, "<$file" or die "can't open $file";
  return new_fh($class, $fh, $lh, $eh);
  
}
sub new_fh{
  my($class, $fh, $lh, $eh, $pid) = @_;
  my $this = {
    fh => $fh,
    lh => $lh,
    eh => $eh,
    paused => 1,
  };
  if(defined $pid) { $this->{pid} = $pid }
  bless $this, $class;
  $this->{reader} = Dispatch::Select::Socket->new(
    $this->LR_line_reader, $fh);
  $this->resume;
  return $this;
}
sub replace_handlers{
  my($this, $lh, $eh) = @_;
  $this->{lh} = $lh;
  $this->{eh} = $eh;
}
sub LR_line_reader{
  my($this) = @_;
  my $txt = "";
  my $clos = sub{
    my($disp, $fh) = @_;
    if($this->{paused}){
      $disp->Remove("reader");
      return;
    }
    my $count = sysread($fh, $txt, 100, length($txt));
    if((!defined($count)) || $count <= 0){
      $disp->Remove;
      close $fh;
      if($this->{pid}){
        waitpid $this->{pid}, 0;
      }
      delete $this->{reader};
      delete $this->{fh};
      delete $this->{pid};
      delete $this->{lh};
      my $eh = $this->{eh};
      delete $this->{eh};
      &$eh();
    }
    while($txt =~ /^([^\n]*)\n(.*)/s){
      my $line = $1;
      $txt = $2;
      &{$this->{lh}}($line);
    }
  };
  return $clos;
}
sub Abort{
  my($this) = @_;
  $this->TearDown;
}
sub paused{
  my($this) = @_;
  return $this->{paused};
}
sub resume{
  my($this) = @_;
  unless($this->{paused}) {
    print STDERR "not paused in resume";
  }
  $this->{paused} = 0;
  $this->{reader}->Add("reader");
}
sub pause{
  my($this) = @_;
  if($this->{paused}) {
    print STDERR "paused in pause";
  }
  $this->{paused} = 1;
  $this->{reader}->Remove("reader");
}
sub TearDown{
  my($this) = @_;
  if($this->{reader} && $this->{reader}->can("Remove")){
    $this->{reader}->Remove;
    delete $this->{reader};
    delete $this->{lh};
    if($this->{eh} && ref $this->{eh} eq "CODE"){
      my $eh = $this->{eh};
      delete $this->{eh};
      &$eh();
    }
  }
  if($this->{pid}){
    kill 1, $this->{pid};
    waitpid $this->{pid}, 0;
    delete $this->{pid};
  }
}
sub DESTROY{
  my($this) = @_;
  if($ENV->{POSDA_DEBUG}){
    print STDERR "Destroying $this\n";
  }
}
1;
