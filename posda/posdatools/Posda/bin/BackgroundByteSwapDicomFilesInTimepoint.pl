#!/usr/bin/perl -w
use strict;
use Cwd;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::File::Import 'insert_file';
use File::Temp qw/ tempfile /;
my $usage = <<EOF;
BackgroundByteSwapDicomFilesInTimepoint.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id>- activity
  <notify> - user to notify

Expects nothing on <STDIN>

Finds all DICOM files in latest timeoint for activity, and attempt to byte swap the pixel data for each.
Every file which successfully converts will be imported into Posda.
The files will all be related to an import_event with a comment like:
"Import of ByteSwapped files in activity <activity_id> subprocess <invoc_id>"

Uses named queries:
   FileIdTypePathFromActivity
   InsertEditImportEvent
   GetImportEventId
   CompleteImportEvent

Uses script ByteSwapDicomPixelData.pl to get Swap Pixel Data

Produces a report of files for which it successfully swapped bytes with the following columns:
<original_file_id>, <modified_file_id>

Produces a report of files which failed to successfully swap with the following columns:
<file_id>, <error>

EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 3). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $notify) = @ARGV;

print "Going to background\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;

my @FilesToTry;
Query('FileIdTypePathFromActivity')->RunQuery(sub {
  my($row) = @_;
  push @FilesToTry, $row;
}, sub{}, $activity_id);
my $num_files = @FilesToTry;
unless ($num_files > 0){
  die "No files to swap";
}
my $comment = "Import of ByteSwapped files in activity $activity_id subprocess $invoc_id";
$back->WriteToEmail("$comment\nFound $num_files files to attempt to swap\n");
############################################################
# Create import_event 
Query('InsertEditImportEvent')->RunQuery(
  sub{}, sub{}, "BackgroundSwapPixelBytes.pl", $comment);
####GetImportEventId
my $ie_id;
Query('GetImportEventId')->RunQuery(sub{
  my($row) = @_;
    $ie_id = $row->[0];
  }, sub {});
my %FileErrors;
my %ConvertedFiles;
############################################################
# Process files on STDIN
my $num_done = 0;
file:
for my $i (@FilesToTry){
  $num_done += 1;
  $back->SetActivityStatus("ByteSwapping $num_done of $num_files");
#  $back->WriteToEmail("ByteSwapping $num_done of $num_files:\n");
  my($file_id, $type, $path) = @$i;
#  $back->WriteToEmail("file_id: $file_id, type: $type, path: $path\n");
  my $dest_file = File::Temp::tempnam("/tmp", "New_$num_done");
  my $cmd = "ByteSwapDicomPixelData.pl \"$path\" \"$dest_file\"";
  open SUB, "$cmd|" or die "Can't open $cmd as pipe";
  my @lines;
  while(my $line = <SUB>){ chomp $line; push @lines, $line; }
  close SUB;
  if($lines[0] =~ /^Error: (.*)$/){
    $FileErrors{$file_id} = $1; 
    next file;
  }
  if($lines[0] eq "OK"){
    my $resp = Posda::File::Import::insert_file($dest_file, "", $ie_id);
    if ($resp->is_error){
      $FileErrors{$file_id} = "Failed to Import (" . $resp->error. ")";
    }else{
      $ConvertedFiles{$file_id} =  $resp->file_id;
    }
    unlink $dest_file;
  }
}
Query('CompleteImportEvent')->RunQuery(sub{},sub{}, $ie_id);
my $num_converted = keys %ConvertedFiles;
my $num_errored = keys %FileErrors;
my $finish = "Swapped $num_converted files; $num_errored failed to swap";
$back->WriteToEmail("$finish\n");
if($num_converted > 0){
  my $rpt1 = $back->CreateReport("FilesByteSwapped");
  $rpt1->print("original_file_id,modified_file_id\n");
  for my $orig(keys %ConvertedFiles){
    $rpt1->print("$orig,$ConvertedFiles{$orig}\n");
  }
}
if($num_errored > 0){
  my $rpt2 = $back->CreateReport("FilesWhichFailed");
  $rpt2->print("file_id,error\n");
  for my $f (keys %FileErrors){
    $rpt2->print("$f,$ConvertedFiles{$f}\n");
  }
}
$back->Finish($finish);
