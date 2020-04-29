#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::Dataset;
use Posda::BackgroundProcess;
use Data::Dumper;
use File::Temp qw/ tempfile /;
my $usage = <<EOF;
TomosynthesisConverterTP.pl <?bkgrnd_id?> <activity_id> <activity_timepoint_id> <notify>
  <activity_id>> - activity
  <activity_timepoint_id>> - activity_timepoint_id
  <notify> - user to notify

Expects nothing on <STDIN>

---
In progress converter to make invalid DICOM Tomosynthesis files valid.
Created for the Duke collection.

Currently just a skeleton based on FixReallyBadDicomFilesInTimepoint and ApplyPrivateDispositionUnconditionalDate2

--
Uses named queries:
   GetPathsForActivity
   FileIdsByActivityTimepointId
   CreateActivityTimepoint
   InsertActivityTimepointFile

Uses script ChangeDicomElements.pl to update tags to make the file valid
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 3){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 4). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $activity_timepoint_id, $notify) = @ARGV;

print "Going to background\n";

# $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
#$back->Daemonize;
my $oq = Query("GetPathsForActivity");
my $i = 0;
#$back->WriteToEmail("Initial line written to email\n");
my $start = time;
my %Files;
my %Conversions;
#$back->SetActivityStatus("Querying for Files");
# $oq->RunQuery(sub{
#   my($row) = @_;
#   my $f = $row->[0];
#   %Files{$f} = 1;
# }, sub{}, $activity_timepoint_id);
$oq->RunQuery(sub{
  my($row) = @_;
  my($file_id, $path) = @$row;
  $Files{$file_id} = $path;
}, sub {}, $activity_timepoint_id);
my $num_files = keys %Files;
my $num_done = 0;
my $num_failed = 0;
my $num_converted = 0;

print STDERR "\n Do I have any files? I see $num_files \n";
print STDERR Dumper(\%Files);
file:
for my $file (keys %Files){
  $num_done += 1;
  #$back->SetActivityStatus("Processing File $num_done of $num_files ($num_failed failures)");
  my $path = $Files{$file};
  my($sop_class, $sop_inst);
  my $cmd = "GetSopInfoFromMeta.pl $path";

  open FILE, "$cmd|";
  while (my $line = <FILE>){
    chomp $line;
    if($line =~ /^SOP Class:\s*(.*)\s*$/){
      $sop_class = $1;
    }
    if($line =~ /^SOP Instance:\s*(.*)\s*$/){
      $sop_inst = $1;
    }

  }
  close FILE;


  my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($path);
  unless($ds) { die "$path didn't parse into a dataset"; }

  my $bodypartthickness = $ds->GetEle("(0018,11a0)")->{value};
  my $rescale_intercept = $ds->GetEle("(0028,1052)")->{value};
  my $rescale_slope = $ds->GetEle("(0028,1053)")->{value};
  my $rescale_type = $ds->GetEle("(0028,1054)")->{value};
  #my $window_center = $ds->GetEle("(0028,1050)")->{value};
  #my $window_width = $ds->GetEle("(0028,1051)")->{value};
  #my $image_type1  = $ds->GetEle("(0008,0008)")->{value};

  print STDERR "\n body part thickness $bodypartthickness \n rescale_intercept $rescale_intercept \n rescale_slope $rescale_slope \n rescale_type $rescale_type ";
  # \n window_center $window_center[0] \n window_width $window_width[0] \n image_type1 $image_type1[0]";

  my $laterality;
  if (index(substr($path, -15), 'r') != -1) {
    $laterality = 'R';
   }else{
     $laterality = 'L';
   }



  print STDERR "\n SOP STUFF  $sop_class  $sop_inst  \n";
  my $dest_file = File::Temp::tempnam("/tmp", "New_$num_done");
  $cmd = "ChangeDicomElements.pl $path $dest_file " .
    "\"(0018,1000)\" 12345 " .
    "\"(0018,1020)\" 12345 " .
    "\"(0018,9004)\" RESEARCH " .
    "\"(0008,9205)\" MONOCHROME " .
    "\"(0008,9206)\" SAMPLED " .
    "\"(0008,9207)\" TOMOSYNTHESIS " .
    "\"(0054,0220)\" 399368009 " .
    "\"(5200,9230)[0](0018,0050)\" $bodypartthickness " .
    "\"(5200,9230)[0](0020,9111)\"  1 " .
    "\"(5200,9230)[0](0020,9113)\"  1 " .
    "\"(5200,9230)[2](0020,9116)\"  1 " .
    "\"(5200,9229)[0](0020,9071)[0](0020,9072)\" $laterality " .
    "\"(5200,9229)[0](0020,9071)[0](0008,2218)[0](0008,0100)\" 76752008 " .
    "\"(5200,9229)[0](0020,9071)[0](0008,2218)[0](0008,0102)\" SCT " .
    "\"(5200,9229)[0](0020,9071)[0](0008,2218)[0](0008,0104)\" Breast " .
    "\"(0008,2220)\" $laterality " .
    "\"(5200,9230)[0](0028,9145)[0](0028,1052)\" $rescale_intercept " .
    "\"(5200,9230)[0](0028,9145)[0](0028,1053)\" $rescale_slope " .
    "\"(5200,9230)[0](0028,9145)[0](0028,1054)\" $rescale_type " .
    "\"(0008,0016)\" $sop_class " .
    "\"(0008,0018)\" $sop_inst ";

    #"\"(5200,9230)[1](0028,9132)[0](0028,1050)\" $window_center[0] " .
    #"\"(5200,9230)[1](0028,9132)[0](0028,1051)\" $window_width[0] " .
    #"\"(0018,9504)[0](0008,9007)[0](0008,0008)\" $image_type1\"\"TOMOSYNTHESIS\"\"NONE " ..

  my $result = `$cmd`;
  print STDERR "\n Result STUFF  $result ";
  $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl $dest_file \"Changing tags to make valid Tomosynthesis\"";
  $result = `$cmd`;
  print STDERR "\n Result STUFF  $result ";  my $new_file_id;
  if($result =~ /File id: (.*)/){
    $new_file_id = $1;
  }
  unlink $dest_file;
  unless(defined($new_file_id)){
    print STDERR "\n Unable to import file $dest_file\n($result) \n";
  }
  if($new_file_id != $file){
    $Conversions{$file} = $new_file_id;
    $num_converted += 1;
  } else {
    print STDERR "Meet the new file, same as the old file ($new_file_id)\n";
  }
}
print STDERR "Processed $num_done files\n Failed to get meta for $num_failed\n Converted $num_converted\n";
if($num_converted > 0){
  my %FilesInNewTp;
  my $comment = "New Timepoint for ImportedEdits $invoc_id";
  Query("CreateActivityTimepoint")->RunQuery(sub {}, sub {},
    $activity_id, $0, $comment, $notify);
  my $new_tp;
  Query("GetActivityTimepointId")->RunQuery(sub {
    my($row) = @_;
    $new_tp = $row->[0];
  }, sub{});
  unless(defined $new_tp){
    #$back->WriteToEmail("ERROR: Unable to get new activity timepoint id.\n");
    #$back->Finish("Failed - check report");
    exit;
  }

  #$back->WriteToEmail("Activity Timepoint Ids: old = $activity_timepoint_id, new = $new_tp\n");
  my $num_copied = 0;
  my $num_replaced = 0;
  my $ins = Query('InsertActivityTimepointFile');
  for my $old_file (keys %Files){
    my $new_file;
    if(exists $Conversions{$old_file}){
      $new_file = $Conversions{$old_file};
      $num_replaced += 1;
    } else {
      $num_copied += 1;
      $new_file = $old_file;
    }
    #$back->WriteToEmail("Inserting $new_file into activity_timepoint $new_tp\n");
    $ins->RunQuery(sub{}, sub{}, $new_tp, $new_file);
    $FilesInNewTp{$new_file} = 1;
  }
}
my $elapsed = time - $start;
#$back->WriteToEmail("Processed $num_done files in $elapsed seconds");
#$back->Finish("Processed $num_done files in $elapsed seconds");
