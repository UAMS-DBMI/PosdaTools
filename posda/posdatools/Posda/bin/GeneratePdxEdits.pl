#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;

my $usage = <<EOF;
Usage:
GeneratePdxEdits.pl <bkgrnd_id> <rel_dest_root> <notify>
or
GeneratePdxEdits.pl -h

Expects lines of the form:
<patient_id>&<new_patient_id>&<new_study_desc>&<new_series_desc>

Produces a new spreadsheet to edit the changes into the files.
EOF
my @PatientsToEdit;
if($#ARGV == 0 && $ARGV[0] eq "-h") { print "$usage\n\n" ; die $usage; }
if($#ARGV != 2){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $rel_dest_root, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

while(my $line = <STDIN>){
  chomp $line;
  $background->LogInputLine($line);
  my($pat_id, $new_pat_id, $new_study_desc, $new_series_desc) =
   split /&/, $line;
  push @PatientsToEdit,
   [$pat_id, $new_pat_id, $new_study_desc, $new_series_desc];
}

my $num_pats = @PatientsToEdit;
print "Found list of $num_pats patients to edit\nForking background process\n";

$background->Daemonize;
$background->WriteToEmail("Starting edits on $num_pats patients\n" .
  "Description: Generating edits to split PDX-Pilot\n");
my $rpt_pipe = $background->CreateReport("EditCommandsSpreadsheet");
$rpt_pipe->print("\"command\",\"arg1\",\"arg2\",\"arg3\",\"arg4\"," .
  "\"Operation\",\"rel_dest_root\",\"who\",\"edit_description\"," .
  "\"notify\"\r\n");

for my $i (0 .. $#PatientsToEdit){
  my($pat_id, $new_pat_id, $new_study_desc, $new_series_desc) = 
    @{$PatientsToEdit[$i]};
  $rpt_pipe->print("AddSopsByPatient,\"$pat_id\",,,");
  if($i == 0){
    $rpt_pipe->print(",BackgroundEditBySop,\"$rel_dest_root\"," .
      "\"bbennett\",\"Splitting PDX-Pilot\",\"wcbennett\@uams.edu\"");
  }
  $rpt_pipe->print("\r\n");
  $rpt_pipe->print("AccumulateEdits\r\n");
  $rpt_pipe->print("edit,full_ele_addition,\"<(0010,0020)>\"," .
    "\"$new_pat_id\"\r\n");
  $rpt_pipe->print("edit,full_ele_addition,\"<(0008,1030)>\"," .
    "\"$new_study_desc\"\r\n");
  $rpt_pipe->print("edit,full_ele_addition,\"<(0008,103e)>\"," .
    "\"$new_series_desc\"\r\n");
  $rpt_pipe->print("ProcessFiles\r\n");
}


my $at_text = `date`;
chomp $at_text;
$background->WriteToEmail("Ending at: $at_text\n");
$background->Finish;
