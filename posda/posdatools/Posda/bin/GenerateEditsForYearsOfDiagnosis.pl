#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage  = <<EOF;
usage:
GenerateEditsForYearsOfDiagnosis.pl <bkgrnd_id> <notify>
or
GenerateEditsForYearsOfDiagnosis.pl -h
 
Expects Input of the form
<patient_id>&<year>

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 1){
  die "$usage\n";
}
my($invoc_id, $notify) = @ARGV;

my %YearByPat;
while(my $line = <STDIN>){
  chomp $line;
  my($pat, $year) = split(/\&/, $line);
  $YearByPat{$pat} = $year;
}
my $num_patients = keys %YearByPat;
print "Found $num_patients to add year of diagnosis to\n";
print "Entering background\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
print "Going to background\n";
$background->Daemonize;
my $start_time = time;
my $get_series = Query('GetSeriesByPatId');
$background->WriteToEmail("StartingGenerationOfSpreadsheet");
my $rpt = $background->CreateReport("EditsToAddYearOfDiagnosis");
$rpt->print("series_instance_uid,num_files,op,tag,val1,var2,Operation,description,notify\n");
my $commands_printed = 0;
for my $pat (keys %YearByPat){
  my $series_found = 0;
  $get_series->RunQuery(sub {
    my($row) = @_;
    my $series = $row->[0];
    my $num_files = $row->[1];
    if($commands_printed){
      $rpt->print("$series,$num_files\n");
    } else {
      $rpt->print("$series,$num_files,,,,,BackgroundEdit,\"Adding Year of Diagnosis\",bbennett\n");
      $commands_printed = 1;
    }
    $series_found += 1;
  }, sub {}, $pat);
  $background->WriteToEmail("Found $series_found series for patient $pat\n");
  if($series_found > 0){
    $rpt->print(",,set_tag,\"<(0013,\"\"CTP\"\",50)>\",<$YearByPat{$pat}>,<>\n");
  }
}
#$rpt->close;
my $elapsed = time - $start_time;
$background->WriteToEmail("finished in $elapsed seconds\n");
$background->Finish;
