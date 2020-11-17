#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
ImportPatientMapping.pl <invoc_id> <notify>
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

unless($#ARGV == 1){
  die "$usage\n";
}
my($invoc_id,$notify) = @ARGV;
my @lines;
while (my $line = <STDIN>){
  chomp $line;
  push @lines, $line;
}
my $num_lines = @lines;
print "Going straight to background to process $num_lines lines\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify);

$back->Daemonize;
my $q = Query("InsertIntoPatientMappingNew");
$back->WriteToEmail("Processing input to Patient Mapping\n");
for my $line (@lines){
  my($from, $to_id, $to_name, $coll, $site, $batch,
    $date_shift, $diagnosis_date, $baseline_date, $uid_root) =
    split(/&/, $line);
  if($date_shift eq "<undef>"){ $date_shift = undef }
  if($batch eq "<undef>"){ $batch = undef }
  if($diagnosis_date eq "<undef>"){ $diagnosis_date = undef }
    elsif($diagnosis_date =~ /^<(.*)>$/) { $diagnosis_date = $1 }
  if($baseline_date eq "<undef>"){ $baseline_date = undef }
    elsif($baseline_date =~ /^<(.*)>$/) { $baseline_date = $1 }
  if($date_shift =~ /^<(.*)>$/) { $date_shift = $1 }
  if($from =~ /^<(.*)>$/) { $from = $1 }
  $from =~ s/^\s*//;
  $from =~ s/\s*$//;
  $q->RunQuery(sub {}, sub{},
    $from, $to_id, $to_name, $coll, $site, $batch, $date_shift,
    $diagnosis_date, $baseline_date, $uid_root);
}
$back->WriteToEmail("$num_lines Insertions done\n");
$back->Finish;
