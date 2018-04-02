#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';

my $usage = <<EOF;
ImportPatientMapping.pl <invoc_id>
or
ImportPatientMapping.pl -h

This script, although a "background script" merely executes in the
foreground and returns its results via STDOUT

It expects lines in the following format on STDIN:
<from_patient_id>&<to_patient_id>&<to_patient_name>&<collection_name>&<site_name>&
  <batch_number>&<date_shift>&<diagnosis_date>&<baseline_date>&<uid_root>

It uses the following queries:
  InsertIntoPatientMappingNew

Note: This script does very limited error checking.
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 0){
  die "$usage\n";
}
my $q = Query("InsertIntoPatientMappingNew");

while (my $line = <STDIN>){
  chomp $line;
  my($from, $to_id, $to_name, $coll, $site, $batch,
    $date_shift, $diagnosis_date, $baseline_date, $uid_root) =
    split(/&/, $line);
  if($date_shift eq "<undef>"){ $date_shift = undef }
  if($batch eq "<undef>"){ $batch = undef }
  if($diagnosis_date eq "<undef>"){ $diagnosis_date = undef }
  if($baseline_date eq "<undef>"){ $baseline_date = undef }
  $from =~ s/^\s*//;
  $from =~ s/\s*$//;
  $q->RunQuery(sub {}, sub{},
    $from, $to_id, $to_name, $coll, $site, $batch, $date_shift,
    $diagnosis_date, $baseline_date, $uid_root);
}

print "Insertions done\n";
