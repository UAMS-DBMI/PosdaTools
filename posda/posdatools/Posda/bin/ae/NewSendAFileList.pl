#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::NewDicomSender;
use Posda::Dataset;
use Posda::Parser;
use Dispatch::Select;
use Debug;
#Posda::Dataset::InitDD();
my $dbg = sub {print @_ };

unless($#ARGV == 3){ die "usage: $0 <host> <port> <called_ae> <calling_ae>" }
my $host = $ARGV[0];
my $port = $ARGV[1];
my $called = $ARGV[2];
my $calling = $ARGV[3];

my @files;
file:
while(my $line = <STDIN>){
  chomp $line;
  if(-f $line) {
    if(open FILE, "<$line"){
      my $mh = eval{Posda::Parser::ReadMetaHeader(*FILE)};
      if($@){
        print STDERR "No metaheader $line\n$@\n";
        close FILE;
        next file;
      }
      my $q = {
        file => $line,
        abs_stx => $mh->{metaheader}->{"(0002,0002)"},
        xfr_stx => $mh->{metaheader}->{"(0002,0010)"},
        sop_cl => $mh->{metaheader}->{"(0002,0002)"},
        sop_inst => $mh->{metaheader}->{"(0002,0003)"},
        dataset_offset => $mh->{DataSetStart},
        dataset_size => $mh->{DataSetSize},
      };
      push(@files, $q);
    }
  } else {
    print STDERR "Not found: $line\n";
  }
}
#print "Files: ";
#Debug::GenPrint($dbg, \@files, 1);
#print "\n";
#exit;

sub MakeDoIt{
  my($host, $port, $called, $calling, $FileList) = @_;
  my $foo = sub {
    my($back) = @_;
    my $Dicom = Posda::NewDicomSender->new(
      $host, $port, $called, $calling, $FileList);
    unless($Dicom) { die "Couldn't create a sender" }
  };
  return $foo;
}
Dispatch::Select::Background->new(MakeDoIt($host, $port, $called, $calling,
  \@files))->queue;
Dispatch::Select::Dispatch();
