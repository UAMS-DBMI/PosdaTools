#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::PrivateDispositions;

my $usage = <<EOF;
ProposeCsvEdits.pl <?bkgrnd_id?> <scan_id> <description> <notify>
  scan_id - id of scan to query
  description - well, description
  notify - email address for completion notification

Expects lines on STDIN:
<type>&<<path>>&<<q_value>>&<num_files>&<p_op>&<<q_arg1>>&<<q_arg2>>&<<q_arg3>>

Note:
  The double metaquotes in the line specification are not errors.
  Those fields are to be metaquoted themselves.

Uses the following query:
  NonDicomFileInPosdaByScanPathValue
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my @FileQueries;
  my $q = {
   type => $type,
   path => $path,
   value => $q_value,
   num_files => $num_files,
   op => $p_op,
   arg1 => $q_arg1,
   arg2 => $q_arg2,
   arg3 => $q_arg3,
  };
  push @FileQueries, $q;
}


$background->Daemonize;
#get all files in activity
#get their uids
# make a EditSpreadsheet with the edit syntax
# element, vr, q_value, edit_description, diso, num series, p_op, q_arg1, q_arg2, Operation, activity_id, scan_id, notify, sep_char

# element = find the uid dicom tags <(####),(####)>
# vr = find the VR for that tag,
# q_value , edit_description, diso, num series, p_op, q_arg1, q_arg2, Operation, activity_id, scan_id, notify, sep_char

my $rpt = $background->CreateReport("EditSpreadsheet");
my $num_edit_groups = keys %FilesByEditGroups;
$background->WriteToEmail("$num_edit_groups distinct edit groups found\n");
$rpt->print("file_id,subj," .
  "op,path,val1,val2,val3,Operation,description,notify\n");
my $first_line = 1;
for my $c (sort keys %FilesByEditGroups){
  for my $f (keys %{$FilesByEditGroups{$c}}){
    $rpt->print("$f,$FileToSubj{$f}");
    if($first_line){
      $rpt->print(",,,,,,BackgroundCsvEdit," .
        "\"From non-dicom PHI scan ($scan_id)\",\"$notify\"\n");
      $first_line = 0;
    } else {
      $rpt->print("\n");
    }
  }
#  $background->WriteToEmail("Command group: $c\n");
  my @edits = split /&/, $c;
  my @edit_h;
  for my $edit (@edits){
#  $background->WriteToEmail("Edit: $edit\n");
#   bucket => "$p_op|$type|$path|$q_arg1|$q_arg2|$q_arg3",
    my($op, $type, $path, $arg1, $arg2, $arg3) = split(/\|/, $edit);
    $op =~ s/"/""/g;
    $type =~ s/"/""/g;
    $path =~ s/"/""/g;
    $arg1 =~ s/"/""/g;
    $arg2 =~ s/"/""/g;
    $arg3 =~ s/"/""/g;
print STDERR "Op: $op\n";
    push @edit_h, {
      op => $op, type => $type, path => $path,
      arg1 => $arg1, arg2 => $arg2, arg3 => $arg3
    };
  }
  for my $e (
    sort
    {$edit_sort_order->{$a->{op}} cmp $edit_sort_order->{$b->{op}}}
    @edit_h
  ){
    $rpt->print(",,\"$e->{op}\",\"<$e->{path}>\",\"<$e->{arg1}>\"," .
      "\"<$e->{arg2}>\",<$e->{arg3}>\n");
  }
}
my $end = time;
my $duration = $end - $start_time;
$background->WriteToEmail("finished scan\nduration $duration seconds\n");
$background->Finish;
