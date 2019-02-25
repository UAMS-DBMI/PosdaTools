#!/usr/bin/perl -w
use strict;
use Posda::Try;
use Posda::DiffDicom;
use Posda::Dataset;

my $usage = <<EOF;
ShortLongDicomCompare.pl <from_file> <to_file>
or
ShortLongDicomCompare.pl -h

EOF

$|=1;

if($#ARGV == 0 && $ARGV[0] eq "-h" ){ die $usage }
unless($#ARGV == 1 ){ die $usage }

my ($from, $to) = @ARGV;
my $f_try = Posda::Try->new($from);
unless(exists $f_try->{dataset}){
  print "Failed: $from is not a dicom file\n";
  exit;
}
my $t_try = Posda::Try->new($to);
unless(exists $t_try->{dataset}){
  print "Failed: $to is not a dicom file\n";
  exit;
}
my $fds = $f_try->{dataset};
my $tds = $t_try->{dataset};
my $f_dig = $f_try->{digest};
my $t_dig = $t_try->{digest};
my $diff = Posda::DiffDicom->new($fds, $tds);
$diff->Analyze;
my($only_in_from, $only_in_to, $different) = 
  $diff->SemiDiffReport;
my($s_rept, $l_rept) = 
  $diff->ReportFromSemi($only_in_from, $only_in_to, $different);
if(length($s_rept) <= 0){
  print "Failed: no lines in short_rept\n";
  exit;
}
if(length($l_rept) <= 0){
  print "Failed: no lines in long_rept\n";
  exit;
}
print "short_rept:\n" . $s_rept . "-----------------------------\n";
print "long_rept:\n" . $l_rept . "-----------------------------\n";
