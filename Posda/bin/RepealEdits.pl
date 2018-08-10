#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use File::Path 'rmtree';

my $usage = <<EOF;
RepealEdit.pl <bkgrnd_id> <sub_invoc_id> <notify>
or
RepealEdit.pl -h

The script doesn't expect lines on STDIN:

It doesn't enter background.

It just checks to see if the entries in a particular set of
dicom_edit_compare rows represent a "current" edit.

An edit is current if and only if:
  1) The number of "From" files and "To" files are equal
  2) All of the "From" files are hidden, and
  3) All of the "To" files are visible.
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 2){
  my $num_args = $#ARGV;
  print "Error: wrong number of args ($num_args) vs 2:\n";
  print "$usage\n";
  die "$usage\n";
}

my ($invoc_id, $subproc_invoc_id, $notify) = @ARGV;

my @UnImportedToFileList;
my %VisibleToFiles;
my %HiddenToFiles;
my $NumToFiles = 0;
my $get_to = Query("GetDicomEditCompareToFiles");
$get_to->RunQuery(sub {
  my($row) = @_;
  my($path, $file_id, $proj_name, $visibility) = @$row;
  $NumToFiles += 1;
  if(defined $file_id){
    if(defined $visibility) {
      $HiddenToFiles{$file_id} = $row;
    } else {
      $VisibleToFiles{$file_id} = $row;
    }
  } else {
    push @UnImportedToFileList, $path;
  }
}, sub {}, $subproc_invoc_id);
my %VisibleFromFiles;
my %HiddenFromFiles;
my $NumFromFiles = 0;
my $get_from = Query("GetDicomEditCompareFromFiles");
$get_from->RunQuery(sub {
  my($row) = @_;
  my($file_id, $proj_name, $visibility) = @$row;
  $NumFromFiles += 1;
  if(defined $visibility) {
    $HiddenFromFiles{$file_id} = $row;
  } else {
    $VisibleFromFiles{$file_id} = $row;
  }
}, sub {}, $subproc_invoc_id);
my $num_hidden_from_files = keys %HiddenFromFiles;
my $num_hidden_to_files = keys %HiddenToFiles;
my $num_visible_from_files = keys %VisibleFromFiles;
my $num_visible_to_files = keys %VisibleToFiles;
my $num_unimported_to_files = @UnImportedToFileList;
print "There are $NumFromFiles \"from\" files:\n" .
  "\t$num_hidden_from_files are hidden\n" .
  "\t$num_visible_from_files are visible\n" .
  "There are $NumToFiles \"to\" files:\n" .
  "\t$num_hidden_to_files are hidden\n" .
  "\t$num_visible_to_files are visible\n" .
  "\t$num_unimported_to_files have not been imported\n";
if(
  $NumFromFiles == $NumToFiles &&
  $num_visible_from_files == 0 &&
  $num_visible_to_files == $NumToFiles
){
  print "This set of edits is current\n";
  print "Entering background to Repeal edits\n";
} else {
  print "This is not a current set of edits\n";
  print "Therefore it is not eligible for Repeal\n";
  exit;
}
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
$background->WriteToEmail("About to unhide $NumFromFiles \"from\" files\n");
open UNHIDE, "|UnhideFilesWithStatus.pl $notify \"Repeal of edits " .
  "$subproc_invoc_id\"";
for my $file_id (keys %HiddenFromFiles){
  print UNHIDE "$file_id&$HiddenFromFiles{$file_id}->[2]\n";
} 
close UNHIDE;
$background->WriteToEmail("Unhides complete\n" .
  "About to hide $NumToFiles \"to\" files\n");
open HIDE, "|HideFilesWithStatus.pl $notify \"Repeal of edits " .
  "$subproc_invoc_id\"";
for my $file_id (keys %VisibleToFiles){
  print HIDE "$file_id&$VisibleToFiles{$file_id}->[2]\n";
} 
close HIDE;
$background->WriteToEmail("Hides complete\n");
my $upd = Query("UpdateDicomEditCompareDispositionStatus");
$upd->RunQuery(sub{}, sub{}, "Repealed",
   $subproc_invoc_id);
$background->Finish;
