#!/usr/bin/perl -w use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
ChangeReviewStatus.pl <?bkgrd_id?> <activity_id> <review_status> <processing_status> <notify>
or 
ChangeReviewStatus.pl -h

Expects line of form:
<image_equivalence_class_uid&<processing_status>&<review_status>
on STDIN

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my($invoc_id, $activity_id, $new_review_status, $new_processing_status, $notify) = @ARGV;
my %EquivClasses;
while(my $line = <STDIN>){
  chomp $line;
  my($image_equivalence_class_id, $processing_status, $review_status) =
    split(/&/, $line);
  $EquivClasses{$image_equivalence_class_id} = 1;
}
my $num_classes = keys %EquivClasses;
print "Changing status for $num_classes equivalence classes to " .
  "$new_review_status, $new_processing_status\n";
my $bg = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$bg->Daemonize;
$bg->WriteToEmail("Changing status for $num_classes equivalence classes to \n" .
  "$new_processing_status, $new_review_status");
my $q2 = Query('ChangeEquivalenceClassStatus');
for my $i (keys %EquivClasses){
  $bg->WriteToEmail("\tid: $i\n");
  $q2->RunQuery(sub{}, sub {},
    $new_review_status, $new_processing_status, $i);
}
$bg->Finish;
