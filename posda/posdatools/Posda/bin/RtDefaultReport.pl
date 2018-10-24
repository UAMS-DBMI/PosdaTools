#!/usr/bin/perl -w
use strict;
use Posda::Try;

my $usage = <<EOF;
RtDefaultReport.pl <file>
or
RtDefaultReport.pl -h

Reads the structure set and produces a report on STDOUT

EOF
my $try = Posda::Try->new($ARGV[0]);
unless(exists $try->{dataset}) {
  print "Error: $ARGV[0] didn't parse as DICOM file\n";
  exit;
}
unless(-r $ARGV[0]){
  print "Error: $ARGV[0] is not readable\n";
  exit;
}
my $len = `wc \"$ARGV[0]\" | awk '{print \$3}'`;
chomp $len;
print "Length: $len\n";
my $ds = $try->{dataset};
my $sop_class = $ds->Get("(0008,0016)");
unless(defined $sop_class){
  print "Error: $ARGV[0] is not an DICOM IOD\n";
}
