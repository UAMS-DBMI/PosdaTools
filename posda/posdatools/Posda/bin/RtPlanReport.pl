#!/usr/bin/perl -w
use strict;
use Posda::Try;

my $usage = <<EOF;
RtPlanReport.pl <file>
or
RtPlanReport.pl -h

Reads the plan set and produces a report on STDOUT

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
unless($sop_class eq "1.2.840.10008.5.1.4.1.1.481.5"){
  print "Error: $ARGV[0] is not an RTPLAN\n";
  exit;
}
my $list = $ds->Search("(300a,0070)[<0>](300a,0071)");
if(defined $list && ref($list) eq "ARRAY"){
  my $num_frac_grps = @$list;
  print "Num_frac_grps: $num_frac_grps\n";
} else {
  print "Error: No fraction groups found\n";
}
$list = $ds->Search("(300a,00b0)[<0>](300a,00c0)");
if(defined $list && ref($list) eq "ARRAY"){
  my $num_beams = @$list;
  print "Num_beams: $num_beams\n";
  exit;
} else {
  print "Error: No beams found\n";
}
