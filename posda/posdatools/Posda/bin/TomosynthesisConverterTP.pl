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

Based on FixReallyBadDicomFilesInTimepoint

--
Uses named queries:
   GetPathsForActivityTP
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

my $oq = Query("GetPathsForActivityTP");
my $i = 0;
my $start = time;
my %Files;
my %Conversions;

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
  my $path = $Files{$file};
  my($sop_class, $sop_inst);
  my $cmd = "GetSopInfoFromMeta.pl $path";

  #Find values in header
  open FILE, "$cmd|";
  while (my $line = <FILE>){
    chomp $line;
    if($line =~ /^SOP Instance:\s*(.*)\s*$/){
      $sop_inst = $1;
    }
  }
  close FILE;

  #Find values at top level that should be moved to lower levels
  my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($path);
  unless($ds) { die "$path didn't parse into a dataset"; }
  my $numframes  = $ds->GetEle("(0028,0008)")->{value};
  my $bodypartthickness = $ds->GetEle("(0018,11a0)")->{value};
  my $rescale_intercept = $ds->GetEle("(0028,1052)")->{value};
  my $rescale_slope = $ds->GetEle("(0028,1053)")->{value};
  my $rescale_type = $ds->GetEle("(0028,1054)")->{value};
  my @window_center = $ds->GetEle("(0028,1050)")->{value};
  my @window_width = $ds->GetEle("(0028,1051)")->{value};
  my @image_type  = $ds->GetEle("(0008,0008)")->{value};
  my @frame_type = { $image_type[0][0],  $image_type[0][1], "TOMOSYNTHESIS" , "NONE"};
  my $ppa  = $ds->GetEle("(0018,1510)")->{value};
  my $empty = [];


  my $laterality;
  if (index(substr($path, -15), 'r') != -1) {
    $laterality = 'R';
   }else{
     $laterality = 'L';
   }

  $sop_class = "1.2.840.10008.5.1.4.1.1.13.1.3"; #TOMOSYNTHESIS

  my $dest_file = File::Temp::tempnam("/tmp", "New_$num_done");

  #Top level attributes
  $ds->Insert("(0018,1000)", "12345");              #Device Serial Number
  $ds->Insert("(0018,1020)", "12345");              #Software Version(s)
  $ds->Insert("(0020,0013)", "1");                  #Instance Number
  $ds->Insert("(0018,9004)", "RESEARCH");           #Content Qualification
  $ds->Insert("(0008,9205)", "MONOCHROME");         #Pixel Presentation
  $ds->Insert("(0008,9206)", "SAMPLED");            #Volumetric Properties
  $ds->Insert("(0008,9207)", "TOMOSYNTHESIS");      #Volume Based Calculation Technique
  $ds->Insert("(0054,0220)", "399368009");          #View Code Sequence
  $ds->Insert("(0008,0016)", $sop_class);           #SOP Class
  $ds->Insert("(0008,0018)", $sop_inst);            #SOP Instance
  $ds->Insert("(0018,9507)[0](0018,1510)", $ppa);   #X-Ray 3D Acquisition Sequence -  Positioner Primary Angle

  #Shared functional groups
  $ds->Insert("(5200,9229)[0](0028,9110)[0](0018,0050)", $bodypartthickness);              #Slice Thickness
  $ds->Insert("(5200,9229)[0](0028,9145)[0](0028,1053)", $rescale_slope);                  #Rescale Slope
  $ds->Insert("(5200,9229)[0](0028,9145)[0](0028,1054)", $rescale_type);                   #Rescale Type
  $ds->Insert("(5200,9229)[0](0028,9145)[0](0028,1052)", $rescale_intercept);              #Rescale Intercept
  $ds->Insert("(5200,9229)[0](0020,9071)[0](0020,9072)", $laterality);                     #Frame Laterality
  $ds->Insert("(5200,9229)[0](0020,9071)[0](0008,2218)[0](0008,0100)", "76752008");        #Frame Anatomy Sequence - Anatomic Region Sequence - Code Value
  $ds->Insert("(5200,9229)[0](0020,9071)[0](0008,2218)[0](0008,0102)", "SCT");             #Frame Anatomy Sequence - Anatomic Region Sequence - Coding Scheme Designator
  $ds->Insert("(5200,9229)[0](0020,9071)[0](0008,2218)[0](0008,0104)", "Breast");          #Frame Anatomy Sequence - Anatomic Region Sequence - Code Meaning
  $ds->Insert("(5200,9229)[0](0028,9132)[0](0028,1050)", $window_center[0][0]);            #Frame VOI LUT Sequence - Window Center
  $ds->Insert("(5200,9229)[0](0028,9132)[0](0028,1051)",  $window_width[0][0]);            #Frame VOI LUT Sequence - Window Width

  #Per frame functional groups
  for my $i (0..($numframes-1)){
    $ds->Insert("(5200,9230)[$i](0018,9504)[0](0008,9007)[0]", $image_type[0][0]);           #X-Ray 3D Frame Type Sequence - Frame Type
    $ds->Insert("(5200,9230)[$i](0018,9504)[0](0008,9007)[1]",  $image_type[0][1]);          #X-Ray 3D Frame Type Sequence - Frame Type
    $ds->Insert("(5200,9230)[$i](0018,9504)[0](0008,9007)[2]", "TOMOSYNTHESIS");             #X-Ray 3D Frame Type Sequence - Frame Type
    $ds->Insert("(5200,9230)[$i](0018,9504)[0](0008,9007)[3]", "NONE");                      #X-Ray 3D Frame Type Sequence - Frame Type

    $ds->Insert("(5200,9230)[$i](0018,9504)[0](0008,9205)", $empty);                         #X-Ray 3D Frame Type Sequence - Pixel Presentation
    $ds->Insert("(5200,9230)[$i](0018,9504)[0](0008,9206)", $empty);                         #X-Ray 3D Frame Type Sequence - Volumetric Properties
    $ds->Insert("(5200,9230)[$i](0018,9504)[0](0008,9207)", $empty);                         #X-Ray 3D Frame Type Sequence - Volume Based Calculation Technique

    $ds->Insert("(5200,9230)[$i](0020,9111)[0](0020,9156)", $empty);                         #Frame Content Sequence - Frame Acquisition Number
    $ds->Insert("(5200,9230)[$i](0020,9113)[0](0020,0032)", $empty);                         #Plane Position Sequence - Image Position Patient
    $ds->Insert("(5200,9230)[$i](0020,9116)[0](0020,0037)", $empty);                         #Plane Orientation Sequence - Image Orientation Patient
  }

  #Remove values from top level
  $ds->DeleteElementBySig("(0028,1050)");
  $ds->DeleteElementBySig("(0028,1051)");
  $ds->DeleteElementBySig("(0028,1052)");
  $ds->DeleteElementBySig("(0028,1053)");
  $ds->DeleteElementBySig("(0028,1054)");
  $ds->DeleteElementBySig("(0018,1510)");

  if($df){
    $ds->WritePart10($dest_file, $xfr_stx, "POSDA", undef, undef);
  } else {
    $ds->WriteRawDicom($dest_file, $xfr_stx);
  }


  $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl $dest_file \"Changing tags to make valid Tomosynthesis\"";
  my $result = `$cmd`;
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
    exit;
  }

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
    $ins->RunQuery(sub{}, sub{}, $new_tp, $new_file);
    $FilesInNewTp{$new_file} = 1;
  }
}
my $elapsed = time - $start;
