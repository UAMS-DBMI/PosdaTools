#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
use Posda::DB 'Query';
my $usage = <<EOF;
HideVisibleFilesInBadIecs.pl <?bkgrnd_id?> <visual_review_id> <notify>
  reads a list of series from STDIN
  runs HideSeriesWithStatus.pl <series> <who> "<reason>"
    as a sub-process for each.
  prints "Hide status for series : <series>" on STDOUT for
    each series hidden

  Meant to be invoked as a table handler from DbIf
EOF
unless($#ARGV == 2) { die $usage }
my($invoc_id, $visual_review_id, $notify) = @ARGV;
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
print "All background processing\n";
$back->Daemonize;
$back->WriteToEmail("Script: HideVisibleFilesInBadIecs.pl $invoc_id $visual_review_id $notify\n");
my @files;
Query("FilesRemainingToBeHiddenByScanInstance")->RunQuery(sub {
  my($row) = @_;
  push(@files, $row->[0]);
}, sub{}, $visual_review_id);
my(%collections,%sites,%patients,%series,%modalities,%file_types);
my $sum_files = 0;
my $tot_files = @files;
my $rpt = $back->CreateReport("Series Summary for Hiding");
$rpt->print("collection, site, patient, series, modality, file type, num files\r\n");
Query("SummaryOfSeriesInUnhiddenBadEquivalenceClasses")->RunQuery(sub {
  my($row) = @_;
  my($coll,$site,$pat,$series,$modality,$type,$files) = @$row;
  $rpt->print("$coll,$site,$pat,$series,$modality,$type,$files\n");
  $collections{$coll} = 1;
  $sites{$site} = 1;
  $patients{$pat} = 1;
  $series{$series} = 1;
  $modalities{$modality} = 1;
  $file_types{$type} = 1;
  $sum_files += $files;
}, sub{}, $visual_review_id);
unless($tot_files == $sum_files){
  $back->WriteToEmail("Total files ($tot_files) doesn't match " .
    "sum of files ($sum_files) from report\n");
  $back->WriteToEmail("Not deleting\n");
  $back->Finish;
  exit;
}
my $tot_collections = keys %collections;
my $tot_sites = keys %sites;
my $tot_patients = keys %patients;
my $tot_series = keys %series;
my $tot_modalities = keys %modalities;
my $tot_file_types = keys %file_types;
$back->WriteToEmail("$tot_files to delete:\n" .
  "$tot_collections collections\n" .
  "$tot_sites sites\n" .
  "$tot_patients patients\n" .
  "$tot_series series\n" .
  "$tot_modalities modalities\n" .
  "$tot_file_types file types\n");
$back->WriteToEmail("hiding $tot_files files\n");
unless(open HIDE, "|HideFilesWithStatus.pl $notify \"Hiding Bad files from visual review $visual_review_id\""){
  $back->WriteToEmail("Opening pipe to HideFilesWithStatus.pl failed ($!)\n");
  $back->Finish;
  exit;
}
for my $f (@files){
  print HIDE "$f&<undef>\n";
}
close HIDE;
$back->WriteToEmail("Finished Hiding\n");
$back->Finish;
