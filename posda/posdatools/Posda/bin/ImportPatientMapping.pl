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
my $p = Query("PatientIdMappingByFromPatientId");
$back->WriteToEmail("Processing input to Patient Mapping\n");

my $i = 0;
my $j = 0;
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

  my %RepeatedPatientMapping;
  $p->RunQuery(sub{
    my($row) = @_;
    my($from_patient_id_e, $to_patient_id_e, $to_patient_name_e, $collection_name_e,
        $site_name_e, $batch_number_e, $diagnosis_date_e, $baseline_date_e, $date_shift_e,
        $uid_root_e, $site_code_e) = @$row;
        %RepeatedPatientMapping{$line}->{$from_patient_id_e} = {
          from_patient_id => $from_patient_id_e,
          to_patient_id => $to_patient_id_e,
          to_patient_name => $to_patient_name_e,
          collection_name => $collection_name_e,
          site_name => $site_name_e,
          batch_number => $batch_number_e,
          diagnosis_date => $diagnosis_date_e,
          baseline_date => $baseline_date,
          date_shift => $date_shift_e,
          uid_root => $uid_root_e,
          site_code => $site_code_e
        }
}, sub {}, $from);

  if (%RepeatedPatientMapping{$line}){
    if ($collection_name_e == $coll and $site_name_e == $site){
        $back->WriteToEmail("$from_patient_id_e  was skipped. \n Requested:[$from , $to_id ,$coll ,$site, $date_shift, $baseline_date]\n Existing[%RepeatedPatientMapping{$line}->{$from_patient_id_e} , %RepeatedPatientMapping{$line}->{$to_patient_id_e} , %RepeatedPatientMapping{$line}->{$collection_name_e} ,%RepeatedPatientMapping{$line}->{$site_name_e}, %RepeatedPatientMapping{$line}->{$date_shift_e}, %RepeatedPatientMapping{$line}->{$baseline_date_e}\n]");
        $j++;
      }
  }else{
    $q->RunQuery(sub {}, sub{},
      $from, $to_id, $to_name, $coll, $site, $batch, $date_shift,
      $diagnosis_date, $baseline_date, $uid_root);
      $i++;
  }
}

$back->WriteToEmail("$num_lines lines read. $i insertions done and $j conflicts skipped.\n");

# create and display overwrite report
$back->Finish;
