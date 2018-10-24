#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
MakePassThru.pl <?bkgrd_id?> <visual_review_id> <notify>
or 
MakePassThru.pl -h

Expects line of form:
<processing_status>&<review_status>&<dicom_file_type>
on STDIN

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my($invoc_id, $vis_id, $notify) = @ARGV;
my $q = Query('VisualReviewSeriesByIdReviewStatusProcessingStatusAndDicomFileType');
my $q1 = Query('VisualReviewSeriesByIdProcessingStatusAndDicomFileTypeWhereReviewStatusIsNull');
my %EquivClasses;
my %Series;
while(my $line = <STDIN>){
  chomp $line;
  my($processing_status, $review_status, $dicom_type) = split(/&/, $line);
  if($review_status eq "<undef>") {
print "Query q1($vis_id, \"$processing_status\", \"$dicom_type\")\n";
    $q1->RunQuery(sub {
      my($row) = @_;
      my($eq_id, $series_uid) = @$row;
print "eq_id: $eq_id, series: $series_uid\n";
      $EquivClasses{$eq_id} = 1;
      $Series{$series_uid} = 1;
    }, sub {}, $vis_id, $processing_status, $dicom_type);
  } else {
    $q->RunQuery(sub {
      my($row) = @_;
      my($eq_id, $series_uid) = @$row;
      $EquivClasses{$eq_id} = 1;
      $Series{$series_uid} = 1;
    }, sub {}, $vis_id, $processing_status, $review_status, $dicom_type);
  }
}
my $num_classes = keys %EquivClasses;
my $num_series = keys %Series;
print "There are $num_classes equivalence classes to make PassThru\n";
my $bg = Posda::BackgroundProcess->new($invoc_id, $notify);
$bg->Daemonize;
$bg->WriteToEmail("Setting $num_classes equivalence classes to \"PassThru\" status\n");
$bg->WriteToEmail("for visual review_id: $vis_id:\n");
my $q2 = Query('MakeEquivClassPassThrough');
for my $i (keys %EquivClasses){
  $bg->WriteToEmail("\t$i\n");
  $q2->RunQuery(sub{}, sub {}, $i);
}
$bg->Finish;
