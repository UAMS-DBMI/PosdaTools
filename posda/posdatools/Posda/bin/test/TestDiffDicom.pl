#!/usr/bin/perl -w
use strict;
use Posda::DiffDicom;
use Posda::Try;
my $from = $ARGV[0];
my $to = $ARGV[1];
my $from_t = Posda::Try->new($from);
unless(exists $from_t->{dataset}){
  die "$from is not a DICOM file";
}
my $to_t = Posda::Try->new($to);
unless(exists $to_t->{dataset}){
  die "$to is not a DICOM file";
}
my $diff = Posda::DiffDicom->new($from_t->{dataset}, $to_t->{dataset});
my($short_rpt, $long_rpt) = $diff->DiffReport;
print "Short Report:\n############\n$short_rpt\n";
print "############\nLong Report:\n" .
      "############\n$long_rpt\n############\n";
