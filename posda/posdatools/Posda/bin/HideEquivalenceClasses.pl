#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
HideEquivalenceClasses.pl <?bkgrd_id?> <notify>
or 
HideEquivalenceClasses.pl -h

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
  }elsif($review_status eq "Bad" && $processing_status eq "Reviewed") {
    $EquivClasses{$image_equivalence_class_id} = 1;
  }elsif($review_status eq "Blank" && $processing_status eq "Reviewed") {
    $EquivClasses{$image_equivalence_class_id} = 1;
  } else {
    $dont_change{$image_equivalence_class_id} = 1;
  }
}
my $num_classes = keys %EquivClasses;
my $num_bad = keys %dont_change;
print "There are $num_classes equivalence classes to hide\n";
print "There are $num_bad equivalence classes which didn't qualify\n";
my $bg = Posda::BackgroundProcess->new($invoc_id, $notify);
$bg->Daemonize;
$bg->WriteToEmail("Hiding visible files in $num_classes equivalence\n");
my $q2 = Query('GetVisibleFilesByEquivalenceClass');
for my $i (keys %EquivClasses){
  my %FilesToHide;
  $q2->RunQuery(sub {
    my($row) = @_;
    my($file_id, $visibility) = @$row;
    $FilesToHide{$file_id} = $visibility;
  }, sub {}, $i);
  my $num_files = keys %FilesToHide;
  $bg->WriteToEmail("$num_files in equivalence class $i to hide\n");
  if($num_files > 0){
    open SUB, "|HideFilesWithStatus.pl $notify \"Hiding image_equivalence_class_id $i\"";
    for my $i (keys %FilesToHide){
      print SUB "$i&<undef>\n";
    }
    close SUB;
  }
}
$bg->Finish;
