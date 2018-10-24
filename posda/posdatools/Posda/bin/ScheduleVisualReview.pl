#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
ScheduleVisualReview.pl <bkgrnd_id> <why> <notify>
or
ScheduleVisualReview.pl -h

Expects lines of the following form on STDIN:
<series_instance_uid>

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 2){
  die "$usage\n";
}
my ($invoc_id, $why, $notify) = @ARGV;
my $create_instance = Query("CreateVisualReviewInstance");
my $get_review_instance_id = Query("GetVisualReviewInstanceId");
my @series;
while(my $line = <STDIN>){
  chomp $line;
  push @series, $line;
}
my $num_series = @series;
$create_instance->RunQuery(sub{}, sub {},
  $why, $notify, $num_series);
my $visual_review_instance_id;
$get_review_instance_id->RunQuery(sub{
  my($row) = @_;
  $visual_review_instance_id = $row->[0];
},sub {});
print "Found $num_series to process on input\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
print "Entering background\n";
$background->Daemonize;
my $update_status = Query("UpdateStatusVisualReviewInstance");
my $finalize = Query("FinalizeVisualReviewScheduling");
my $tot_series = 0;
for my $s (@series){
  my $tot_equiv = 0;
  my $cmd = "NewCreateSeriesEquivalenceClasses.pl $s $visual_review_instance_id";
  open CMD, "$cmd|";
  while(my $line = <CMD>){
    if($line =~ /\s*(\d+)\s*classes for series\s*(.*)\s*$/){
      my $num_equiv = $1;
      $tot_equiv += $num_series;
      $tot_series += 1;
      $background->WriteToEmail("$line\n");
      $update_status->RunQuery(sub {}, sub{},
        $tot_series, $tot_equiv, $visual_review_instance_id);
    }
  }
  close CMD;
}
$finalize->RunQuery(sub{}, sub {}, $visual_review_instance_id);
$background->Finish;
