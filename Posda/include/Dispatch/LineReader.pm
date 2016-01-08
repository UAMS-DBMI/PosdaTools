#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/LineReader.pm,v $
#$Date: 2014/06/12 17:18:24 $
#$Revision: 1.7 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
package Dispatch::LineReader;
use Dispatch::Select;
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
