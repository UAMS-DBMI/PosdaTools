#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::SparseDicomFileSender;
use Posda::Dataset;
use Posda::Parser;
use Dispatch::Select;
use Debug;
#Posda::Dataset::InitDD();
my $dbg = sub {print @_ };

unless($#ARGV == 4){ die "usage: $0 <host> <port> <called_ae> <calling_ae> <file>" }
my $host = $ARGV[0];
my $port = $ARGV[1];
my $called = $ARGV[2];
my $calling = $ARGV[3];
my $file = $ARGV[4];
my @files;
my $fh;
open($fh, "<$file") or die "Can't open $file";
my $mh = eval{Posda::Parser::ReadMetaHeader($fh)};
close($fh);
if($@){
  die "$@";
}
push(@files, {
  file => $file,
  abs_stx => $mh->{metaheader}->{"(0002,0002)"},
  xfr_stx => $mh->{metaheader}->{"(0002,0010)"},
  sop_cl => $mh->{metaheader}->{"(0002,0002)"},
  sop_inst => $mh->{metaheader}->{"(0002,0003)"},
  dataset_offset => $mh->{DataSetStart},
  dataset_size => $mh->{DataSetSize},
});
file:
{
  package ListSender;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new {
    my($class, $host, $port, $called, $calling, $FileList, $threads) = @_;
    my $this = {
      host => $host,
      port => $port,
      called => $called,
      calling => $calling,
      FileList => $FileList,
      ActiveAssociations => {},
      num_threads => $threads,
    };
    bless $this, $class;
    $this->ProcessList;
  }
  sub ProcessList{
    my($this) = @_;
    my $threads = $this->{num_threads};
    my $in_process = keys %{$this->{ActiveAssociations}};
    my $waiting = @{$this->{FileList}};
    while($in_process < $threads && $waiting > 0){
      my $next_file = shift @{$this->{FileList}};
      my $fname = $next_file->{file};
      my $Dicom = Posda::SparseDicomFileSender->new(
        $this->{host}, $this->{port}, $this->{calling}, $this->{called},
        [$next_file], $this->WhenFinished($fname)
      );
      unless($Dicom) { die "Couldn't create a sender" }
      $this->{ActiveAssociations}->{$fname} = $Dicom;
      $in_process = keys %{$this->{ActiveAssociations}};
      $waiting = @{$this->{FileList}};
    }
  }
  sub WhenFinished{
    my($this, $file) = @_;
    my $sub = sub {
      my($status) = @_;
      my $start = $status->{start_time};
      my $elapsed = $status->{elapsed};
      my $sent = 0;
      if(
        exists $status->{files_sent} &&
        ref($status->{files_sent}) eq "ARRAY"
      ){
        $sent = @{$status->{files_sent}};
      }
      my $not_sent = 0;
      if(
        exists $status->{files_not_sent} &&
        ref($status->{files_not_sent}) eq "ARRAY"
      ){
        $not_sent = @{$status->{files_not_sent}};
      }
      my $with_errors;
      if(
        exists $status->{files_with_errors} &&
        ref($status->{files_with_errors}) eq "ARRAY"
      ){
        $with_errors = @{$status->{files_with_errors}};
      }
      print "$start|$elapsed|$sent|$not_sent|$with_errors\n";
      delete $this->{ActiveAssociations}->{$file};
      $this->InvokeAfterDelay("ProcessList", 0);
    };
    return $sub;
  }
}
sub MakeDoIt{
  my($host, $port, $called, $calling, $FileList, $threads) = @_;
  my %ActiveAssociations;
  my $foo = sub {
    my($back) = @_;
    ListSender->new(
      $host, $port, $called, $calling, $FileList, $threads);
  };
  return $foo;
}
Dispatch::Select::Background->new(MakeDoIt($host, $port, $called, $calling,
  \@files, 1))->queue;
Dispatch::Select::Dispatch();
