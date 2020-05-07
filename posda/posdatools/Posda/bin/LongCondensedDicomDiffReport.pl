#!/usr/bin/perl -w
use strict;
use Posda::Try;
use Posda::DiffDicom;
use Posda::Dataset;
my $usage = <<EOF;
LongCondensedDicomDiffReport.pl <from> <to>
 or
LongCondensedDicomDiffReport.pl -h

Prints on STDOUT a condensed DICOM difference report
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage; exit;
}
my($from, $to) = @ARGV;
unless(-f $from){
  print STDERR "$from is not a file\n";
  die $usage;
}
unless(-f $to){
  print STDERR "$to is not a file\n";
  die $usage;
}
my $from_t = Posda::Try->new($from);
my $to_t = Posda::Try->new($to);
unless(exists $from_t->{dataset}){
  print STDERR "$from is not a DICOM file\n";
}
unless(exists $to_t->{dataset}){
  print STDERR "$to is not a DICOM file\n";
}
my $diff = Posda::DiffDicom->new($from_t->{dataset}, $to_t->{dataset});
$diff->Analyze;
my($only_in_from, $only_in_to, $different) = $diff->SemiDiffReport;
my($s_rept, $l_rept) = $diff->ReportFromSemi($only_in_from, $only_in_to, $different);
print "##################\nDiff Report:\n$l_rept\n##################\n";
