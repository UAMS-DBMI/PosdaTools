#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
package Dispatch::TopHalfAsyncQuery;
use Socket;
use Fcntl qw( :flock :DEFAULT F_GETFL F_SETFL O_NONBLOCK );
use Dispatch::Select;
sub new_serialized_cmd{
  my($class, $cmd_struct, $line_h, $end_h) = @_;
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
    exec "BottomHalfAsyncQuery.pl";
    die "exec failed: $!";
  } else {
    close $parent;
    my $flags = fcntl($child, F_GETFL, 0);
    $flags = fcntl($child, F_SETFL, $flags | O_NONBLOCK);
  }
  my $this = new_fh($class, $child, $line_h, $end_h, $child_pid);
  $this->pause;
  my $serialized_args = &Storable::freeze($cmd_struct);
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
sub new_fh{
  my($class, $fh, $line_h, $end_h, $pid) = @_;
  my $this = {
    fh => $fh,
    line_h => $line_h,
    end_h => $end_h,
    paused => 1,
  };
  if(defined $pid) { $this->{pid} = $pid }
  bless $this, $class;
  $this->{reader} = Dispatch::Select::Socket->new(
    $this->Frag_reader($line_h), $fh);
  $this->resume;
  return $this;
}
sub Frag_reader{
  my($this, $line_h) = @_;
  my $txt = "";
  my $status = "";
  my $in_error = 0;
  my $in_results = 0;
  my $get_lines = sub{
    while($txt =~ /^([^\n]+)\n(.*)$/s){
      my $line = $1;
      my $remain = $2;
      if($in_error || $in_results){
        $status .= "$line\n";
        $txt = $remain;
        next;
      }
      my @array; 
      if($line =~ /^ROW:(.*)$/){
        my @fields = split(/\|/, $1);
        for my $v (@fields){
          $v =~ s/%(..)/pack("c",hex($1))/ge;
          push(@array, $v);
        }
        &{$this->{line_h}}(\@array);
        $txt = $remain;
      } elsif($line =~ /ERROR:/){
        $in_error = 1;
        $status .= "$line\n";
        $txt = $remain;
      } elsif($line =~ /RESULT:/){
        $in_results = 1;
        $status .= "$line\n";
        $txt = $remain;
      }
    }
  };
  my $clos = sub{
    my($disp, $fh) = @_;
    if($this->{paused}){
      $disp->Remove("reader");
      return;
    }
    my $count = sysread($fh, $txt, 1000, length($txt));
    if((!defined($count)) || $count <= 0){
      $disp->Remove;
      close $fh;
      if($this->{pid}){
        waitpid $this->{pid}, 0;
      }
      delete $this->{reader};
      delete $this->{fh};
      delete $this->{pid};
      delete $this->{line_h};
      my $end_h = $this->{end_h};
      delete $this->{end_h};
      &{$get_lines}();
      &$end_h($status);
      return;
    }
    &{$get_lines}();
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
    delete $this->{line_h};
    if($this->{end_h} && ref $this->{end_h} eq "CODE"){
      my $end_h = $this->{end_h};
      delete $this->{end_h};
      &$end_h();
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
