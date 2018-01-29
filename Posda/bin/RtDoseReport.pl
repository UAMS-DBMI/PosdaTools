#!/usr/bin/perl -w
use strict;
use Posda::Try;

my $usage = <<EOF;
RtDoseReport.pl <file>
or
RtDoseReport.pl -h

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
unless($sop_class eq "1.2.840.10008.5.1.4.1.1.481.2"){
  print "Error: $ARGV[0] is not an RTDOSE\n";
  exit;
}
my $list = $ds->Search("(3004,0050)[0](3004,0001)");
if(defined $list && ref($list) eq "ARRAY"){
  my $num_dvh = @$list;
  print "Num_dvh: $num_dvh\n";
  exit;
}
print "Error: No dvh found\n";
