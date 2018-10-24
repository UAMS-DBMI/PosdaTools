#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
use FileHandle;
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
BackgroundProcessModules.pl <bkgrnd_id> <description> <notify>
or
BackgroundProcessModules.pl -h
Expects lines of the form:
<file_id>

EOF
#Inputs will be parsed into these data structures
my %FileIds;
my @ListOfFiles;

#############################
## This code processes parameters
##
#

if($#ARGV == 0) { die "$usage\n\n" }
if($#ARGV != 2){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $description, $notify) = @ARGV;

#############################
## This code processes input
##
#
my $num_lines = 0;
while(my $line = <STDIN>){
  chomp $line;
  $FileIds{$line} = 1;
  $num_lines += 1;
}
@ListOfFiles = sort keys %FileIds;

my $num_files =  @ListOfFiles;
print "Found list of $num_files to process\n";
print "in $num_lines lines.\n";
print "Subprocess_invocation_id: $invoc_id\n";
print "Forking background process\n";
#############################
# This is code which sets up the Background Process and Starts it
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
# now in the background...
$background->WriteToEmail("Starting  on $num_files files\n" .
  "Description: $description\n" .
  "Subprocess_invocation_id: $invoc_id\n");
my $rpt_pipe = $background->CreateReport("FilesProcessed");
$rpt_pipe->print("file_id,file,is_dicom,has_patient,has_study,has_series," .
  "has_equip]\n");
for my $file_id (@ListOfFiles){
  my $cmd = "ProcessModules.pl $file_id";
  my $file;
  my $is_dicom = 1;
  my $has_patient;
  my $has_study;
  my $has_series;
  my $has_equip;
  my $proc_pat;
  my $proc_study;
  my $proc_series;
  my $proc_equip;
  open TMP, "$cmd|";
  while(my $line = <TMP>){
    chomp $line;
    if($line =~ /has file_patient/){
      $has_patient = 1;
    }
    if($line =~ /has no file_patient/){
      $has_patient = 0;
    }
    if($line =~ /has file_study/){
      $has_study = 1;
    }
    if($line =~ /has no file_study/){
      $has_study = 0;
    }
    if($line =~ /has file_series/){
      $has_series = 1;
    }
    if($line =~ /has no file_series/){
      $has_series = 0;
    }
    if($line =~ /has file_equipment/){
      $has_equip = 1;
    }
    if($line =~ /has no file_equipment/){
      $has_equip = 0;
    }
    if($line =~ /has file_series/){
      $has_series = 1;
    }
    if($line =~ /has no file_series/){
      $has_series = 0;
    }
    if($line =~ /has file_equipment/){
      $has_equip = 1;
    }
    if($line =~ /has no file_equipment/){
      $has_equip = 0;
    }
    if($line =~ /patient module imported/){
      $proc_pat = 1;
    }
    if($line =~ /study module imported/){
      $proc_study = 1;
    }
    if($line =~ /series module imported/){
      $proc_series = 1;
    }
    if($line =~ /equip module imported/){
      $proc_equip = 1;
    }
    if($line =~ /Not a DICOM IOD/){
      $is_dicom = 0;
    }
  }
  close TMP;
  $rpt_pipe->print("$file_id,$file,");
  if($is_dicom){
    $rpt_pipe->print("yes,");
  } else {
    $rpt_pipe->print("no,");
  }
  if($has_patient){
    $rpt_pipe->print("yes,");
  } else {
    if($proc_pat){
      $rpt_pipe->print("no - imported,");
    } else {
      $rpt_pipe->print("no,");
    }
  }
  if($has_study){
    $rpt_pipe->print("yes,");
  } else {
    if($proc_study){
      $rpt_pipe->print("no - imported,");
    } else {
      $rpt_pipe->print("no,");
    }
  }
  if($has_series){
    $rpt_pipe->print("yes,");
  } else {
    if($proc_series){
      $rpt_pipe->print("no - imported,");
    } else {
      $rpt_pipe->print("no,");
    }
  }
  if($has_equip){
    $rpt_pipe->print("yes,");
  } else {
    if($proc_equip){
      $rpt_pipe->print("no - imported,");
    } else {
      $rpt_pipe->print("no,");
    }
  }
}
$background->Finish;
