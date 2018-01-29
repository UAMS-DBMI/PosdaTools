#!/usr/bin/perl -w
use strict;
use Posda::Try;

my $usage = <<EOF;
RtStructReport.pl <file>
or
RtStructReport.pl -h

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
unless($sop_class eq "1.2.840.10008.5.1.4.1.1.481.3"){
  print "Error: $ARGV[0] is not an RTSTRUCT\n";
  exit;
}
my $list = $ds->Search("(3006,0020)[<0>](3006,0022)");
if(defined $list && ref($list) eq "ARRAY"){
  my $num_rois = @$list;
  print "Num_rois: $num_rois\n";
} else {
  print "Error: No rois found\n";
}
$list = $ds->Search("(3006,0010)[0](3006,0012)[0](3006,0014)" .
  "[0](3006,0016)[<0>](0008,1150)");
if(defined $list && ref($list) eq "ARRAY"){
  my $num_links = @$list;
  print "Num_links: $num_links\n";
} else {
  print "Error: No links found\n";
}
my $linked_study = $ds->Get("(3006,0010)[0](3006,0012)[0](0008,1155)");
my $linked_series = $ds->Get("(3006,0010)[0](3006,0012)[0](3006,0014)[0](0020,000e)");
print "Linked_study: $linked_study\n";
print "Linked_series: $linked_series\n";
