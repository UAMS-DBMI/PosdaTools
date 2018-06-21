#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
RetryFailedProjections.pl <?bkgrd_id?> <notify>
or 
MakePassThru.pl -h

Expects line of form:
<image_equivalence_class_uid&<processing_status>&<review_status>
on STDIN

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my($invoc_id, $notify) = @ARGV;
my %EquivClasses;
my %dont_change;
while(my $line = <STDIN>){
  chomp $line;
  my($image_equivalence_class_id, $processing_status, $review_status) =
    split(/&/, $line);
  if($review_status eq "<undef>" && $processing_status eq "error") {
    $EquivClasses{$image_equivalence_class_id} = 1;
  } else {
    $dont_change{$image_equivalence_class_id} = 1;
  }
}
my $num_classes = keys %EquivClasses;
my $num_bad = keys %dont_change;
print "There are $num_classes equivalence classes to reschedule\n";
print "There are $num_bad equivalence classes which didn't qualify\n";
my $bg = Posda::BackgroundProcess->new($invoc_id, $notify);
$bg->Daemonize;
$bg->WriteToEmail("Rescheduling $num_classes equivalence classes for rendering" .
  " of projections\n");
my $q2 = Query('MsrkEquivalenceClassForRetry');
for my $i (keys %EquivClasses){
  $bg->WriteToEmail("\t$i\n");
  $q2->RunQuery(sub{}, sub {}, $i);
}
$bg->Finish;
