#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
use Nifti::Parser;
use Posda::DB qw( Query );

my $usage = <<EOF;
BackgroundConvertDefacedNiftisToDicom.pl <?bkgrnd_id?> <activity_id> <notify>

Expects lines in the following format on STDIN:
<nifti_file_id>
...

Uses <posda_cache_root/WorkerTemp/<?bkgrnd_is> as a temp_dir
(creating directory if necessary)
For each nifti file, it does the following:
  - Unzip nifti file into the temp directory if necessary
  - Parse the nifti file to get the number of slices
  - For each slice in the nifti file invoke the script
     "ProduceDefacedDicom.pl <nifti_file> <slice_no> <temp_dir>
     and parse it's output.
     This script does the following:
       - It creates a new DICOM file in the temp dir with the
         following substitutions:
           - Hash series_instance_uid
           - Hash sop_instance_uid
           - Prepend series desciption with "Defaced: "
           - Replace the pixel data with the slice from the nifti
             (backing out any change in slope/intercept)
       - It creates a file containing a differenced pixel data abs(origpix - defaced pix)
  - When all the slices in the nifti file have been processed,
    it will construct a difference nifti, by using the existing nifti header,
    (resetting slope/intercept if necessary) and appending all of the
    difference pixels.  As it constructs the new nifti it will unlink the
    difference pixel files. The intent_name of this new nifti will be set
    to "from: <nifti_file_id>".
  - Then it will invoke the script:
    ImportMultipleTempFilesIntoPosda.pl "(<invoc_id>): Import of Defaced Dicom from <nifti_file_id>"
    (where <invoc_id> is a the subprocess_invocation_id of this process)
    It will supply all of the DICOM files and the difference_nifti.
    Importing them will cause them to be deleted from the temp directory.
  - If it had to unzip the nifti file, it will delete the unzipped version from
    temp directory
When all of the nifti files have been processed:
  - The temp dir should be empty, it does a rmdir on it. (which may fail if there is a bug)
  - It uses the query "FilesByImportNameLike"
    to find all of the files in the import events it created.  It will then create a new timepoint
    with the contents of the old timepoint plus these files.

Uses the following queries:
  (path, file_type) = GetFilePathAndType(file_id)
  (converted_file_id) = GetNiftiFromDefacedNifti(defaced_nifti_file_id)
  (series_instance_uid) = GetSeriesFromConvertedNifti(converted_file_id)
  (file_id) = FilesByImportNameLike(import_name_like)
  (file_id) = FilesInLatestTimepointByActivity(activity_id)
  (activity_timepoint_id) = LatestTimepoint(activity_id)
  (file_id, file_path, file_type, dicom_file_type) = FilesTypesDicomFileTypesInTimepoint (timepoint_id)
  ChangeFileType(file_type, file_id)
  (<row>) = FetchFileNifti(file_id)
  (import_event_comment) = DefacingImportCommentsLike(import_event_comment_like)
  (diff_nifti_id) = GetDifferenceNiftiByImportComment(import_comment)
  AddDiffNifti

EOF
if($#ARGV == 0 && $ARGV[0] eq -h){
  print $usage; exit;
}
my $num_args = @ARGV;
unless ($num_args == 3){
  die "Error: wrong number args ($num_args vs 3)";
}

my($invoc_id, $activity_id, $notify) = @ARGV;
my $TempDir = "$ENV{POSDA_CACHE_ROOT}/WorkerTemp/$invoc_id";
unless(-d $TempDir) { mkdir $TempDir }
unless(-d $TempDir) { die "Can't mkdir $TempDir" }
my %NiftiFiles;
while(my $line = <STDIN>){
  chomp $line;
  $NiftiFiles{$line} = 1;
}
my $num_niftis = keys %NiftiFiles;
my $b = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$b->Daemonize;
my %SeriesConversion;
my $nifti_count = 0;
for my $DefacedNiftiFileId (sort keys %NiftiFiles){
  my $theFromSeries;
  my $theToSeries;
  $nifti_count += 1;
  my $nifti_mess = "Nifti file $DefacedNiftiFileId ($nifti_count of $num_niftis)";
  my $h = Query('GetFilePathAndType')->FetchOneHash($DefacedNiftiFileId);
  my $DefacedNiftiPath = $h->{path};
  my $DefacedNiftiFileType = $h->{file_type};
  my $ConvertedNiftiFileId = 
    Query('GetNiftiFromDefacedNifti')->FetchOneHash($DefacedNiftiFileId)->{converted_file_id};
  my $OriginalSeriesInstanceUid = 
    Query('GetSeriesFromConvertedNifti')->FetchOneHash($ConvertedNiftiFileId)->{series_instance_uid};
  my $UnzippedNiftiPath;
  if($DefacedNiftiFileType =~ /zip/){
    $UnzippedNiftiPath = "$TempDir/$DefacedNiftiFileId.nii";
    my $cmd = "gunzip -c $DefacedNiftiPath >$UnzippedNiftiPath";
    `$cmd`;
  }
  my $DefacedNifti;
  if(defined $UnzippedNiftiPath){
    $DefacedNifti = Nifti::Parser->new($UnzippedNiftiPath, $DefacedNiftiFileId);
    unless(defined $DefacedNifti){
      die "NiftiFile didn't parse";
    }
  } else {
    $DefacedNifti = Nifti::Parser->new($DefacedNiftiPath, $DefacedNiftiFileId);
  }
  my $DifferenceNiftiPath = "$TempDir/$DefacedNiftiFileId" ."_Diff.nii";
  $DefacedNifti->CopyHeaderToFile($DifferenceNiftiPath);
  unless(defined $DefacedNifti) { die "Defaced NIFTI file ($DefacedNiftiFileId) didn't parse" }
  my $num_slices = $DefacedNifti->{parsed}->{dim}->[3];
  my @DicomFiles;
  my @NiftiSlices;
  for my $i (0 .. $num_slices - 1){
    my $slice_num = $i + 1;
    $b->SetActivityStatus($nifti_mess . " slice $slice_num of $num_slices");
    my $converter = "ProduceDefacedDicom.pl $ConvertedNiftiFileId $i $TempDir $UnzippedNiftiPath";
    open CONVERTER, "$converter|";
    my %results;
    while (my $line = <CONVERTER>){
      chomp $line;
      if($line =~ /^([^:]+): (.*)$/){
        $results{$1} = $2;
      }
    }
    close CONVERTER;
    push @DicomFiles, $results{new_dicom_file};
    unless(defined $theFromSeries){
      $theFromSeries = $results{old_series_instance_uid};
    } unless($theFromSeries eq $results{old_series_instance_uid}){ die "Converted Nifti File ($ConvertedNiftiFileId) claims two source series:\n" .
        " $theFromSeries\n" .
        " $results{old_series_instance_uid}";
    }
    unless(defined $theToSeries){
      $theToSeries = $results{new_series_instance_uid};
    }
    unless($theToSeries eq $results{new_series_instance_uid}){
      print STDERR "theFromSeries: $theFromSeries\n";
      print STDERR "theToSeries: $theToSeries\n";
      print STDERR "results{new_series_instance_uid}: $results{new_series_instance_uid}\n";
      die "Converted Nifti File ($ConvertedNiftiFileId) claims two source series:\n" .
        " $theToSeries\n" .
        " $results{new_series_instance_uid}";
    }
    unless(defined $SeriesConversion{$theFromSeries}){
      $SeriesConversion{$theFromSeries} = $theToSeries;
    }
    if($SeriesConversion{$theFromSeries} ne $theToSeries){
      die "One series ($theFromSeries) converts to two series:\n" .
        "  $theToSeries\n" .
        "  $SeriesConversion{$theFromSeries}";
    }
    open NIFTIDIFF, ">>$DifferenceNiftiPath" or die "can't open $DifferenceNiftiPath for append";
    my($slice_start, $slice_size, $row_size) = $DefacedNifti->GetSliceOffsetLengthAndRowLength(0, $i);
    open SLICE, "<$results{difference_slice}";
    my $buff;
    my $len = read SLICE, $buff, $slice_size;
    unless($len == $slice_size){
      die "non matching read getting difference slice ($len vs $slice_size)";
    } 
    close SLICE;
    print NIFTIDIFF $buff;
    close NIFTIDIFF;
    unlink $results{difference_slice};
  }
  my $import_comment = "($invoc_id): Import of Defaced Dicom from $DefacedNiftiFileId";
  open IMPORTER, "|ImportMultipleTempFilesIntoPosda.pl \"$import_comment\"" or die "Can't open Importer";
  my $num_dicoms = @DicomFiles;
  $b->SetActivityStatus("Importing $num_dicoms and 1 nifti into Posda");
  print IMPORTER "$DifferenceNiftiPath\n";
  for my $f (@DicomFiles){
    print IMPORTER "$f\n";
  }
  $b->SetActivityStatus("Waiting for Import of $num_dicoms dicoms and 1 nifti to clear");
  close IMPORTER;
  Query('CreateDefacedDicomSeries')->RunQuery(sub{},sub{},
    $invoc_id, $ConvertedNiftiFileId, $DefacedNiftiFileId, $theFromSeries, $theToSeries, $num_dicoms, $import_comment);
  unlink $DifferenceNiftiPath;
  if(defined $UnzippedNiftiPath){ unlink $UnzippedNiftiPath }
} 
open CREATE, "|CreateActivityTimepoint.pl $activity_id " .
  "\"From BackgroundConvertDefacedNiftisToDicom.pl ($invoc_id)\" $notify" or die "Can't fork CreateActivityTimepoint";
$b->SetActivityStatus("Finding imported file_ids and queueing for creation of activity_timepoint");
my $files_queued = 0;
my $files_queued_from_import = 0;
my $files_queued_from_old_timepoint = 0;
Query('FilesByImportNameLike')->RunQuery(sub{
  my($row) = @_;
  $files_queued += 1;
  $files_queued_from_import += 1;
  print CREATE "$row->[0]\n";
}, sub{}, "($invoc_id): Import of Defaced Dicom from%");
Query('FilesInLatestTimepointByActivity')->RunQuery(sub{
  my($row) = @_;
  $files_queued += 1;
  $files_queued_from_old_timepoint += 1;
  print CREATE "$row->[0]\n";
}, sub{}, $activity_id);
$b->SetActivityStatus("Waiting for new timepoint creation with $files_queued_from_old_timepoint " .
  "old and $files_queued_from_import new files to clear");
close CREATE;
my $activity_timepoint_id = Query('LatestTimepoint')->FetchOneHash($activity_id)->{activity_timepoint_id};
$b->WriteToEmail("Created new activity timepoint ($activity_timepoint_id}:\n" .
  "  $files_queued_from_old_timepoint files from old timepoint\n" .
  "  $files_queued_from_old_timepoint files from conversion\n");

#  (file_id, file_path, file_type, dicom_file_type) = FilesTypesDicomFileTypesInTimepoint (timepoint_id)
$b->SetActivityStatus("Scanning new timepoint($activity_timepoint_id) for file types");
my %DicomFileTypes;
my %NonDicomFileTypes;
my %PngFiles;
my %KnownNiftiFiles;
my %SuspectedMislabeledNiftis;
Query('FilesTypesDicomFileTypesInTimepoint')->RunQuery(sub{
  my($row) = @_;
  my($file_id, $file_path, $file_type, $dicom_file_type) = @$row;
  if($file_type eq "parsed dicom file"){
    if($dicom_file_type ne ""){
      $DicomFileTypes{$file_type}->{$file_id} = 1;
      return;
    }
    $SuspectedMislabeledNiftis{$file_type}->{$file_id} =  $file_path;
    return;
  }
  if($file_type =~ /PNG/){
    $PngFiles{$file_id} = 1;
    return;
  }
  if($file_type eq "Nifti Image"){
    $KnownNiftiFiles{$file_id} = 1;
    return;
  }
  if($file_type eq "Nifti Image (gzipped)"){
    $KnownNiftiFiles{$file_id} = 1;
    return;
  }
  $SuspectedMislabeledNiftis{$file_type}->{$file_id} = $file_path;
}, sub{}, $activity_timepoint_id);
$b->WriteToEmail("Completed Analysis of timepoint:\n\tDicom File Types:\n");
for my $i (keys %DicomFileTypes){
  my $num_files = keys %{$DicomFileTypes{$i}};
  $b->WriteToEmail("\t\t$i: $num_files\n");
}
my $num_pngs = keys %PngFiles;
$b->WriteToEmail("\tPng files: $num_pngs\n");
my $num_known_niftis = keys %KnownNiftiFiles;
$b->WriteToEmail("\tKnown Nifti files: $num_pngs\n");
$b->WriteToEmail("\tOther file_types: (to check to see if they are really Nifti)\n");
for my $i (keys %SuspectedMislabeledNiftis){
  my $num_files = keys %{$SuspectedMislabeledNiftis{$i}};
  if($i eq "parsed dicom file"){
    $b->WriteToEmail("\t\tparsed dicom file (no dicom file type): ");
  } else {
    $b->WriteToEmail("\t\t$i: ");
  }
  $b->WriteToEmail("$num_files\n");
}
$b->SetActivityStatus("Looking for mislabled Nifti files");
file:
for my $file_type (keys %SuspectedMislabeledNiftis){
  for my $file_id (keys %{$SuspectedMislabeledNiftis{$file_type}}){
    my $nifti_file_type;
    my $nifti;
    my $file = $SuspectedMislabeledNiftis{$file_type}->{$file_id};
    if($nifti = Nifti::Parser->new($file, $file_id)){
      $nifti_file_type = "Nifti Image";
    } elsif($nifti = Nifti::Parser->new_from_zip($file, $file_id, $TempDir)){
      $nifti_file_type = "Nifti Image (gzipped)";
    } else {
      next file;
    }
    Query('ChangeFileType')->RunQuery(sub{}, sub{}, $nifti_file_type, $file_id);
    $b->WriteToEmail("Changed file type of $file_id : \"$file_type\" => " .
      "\"$nifti_file_type\"\n");
    my $existing_row;
    Query('GetFileNifti')->RunQuery(sub{
      my($row) = @_;
      $existing_row = $row;
    }, sub{}, $file_id);
    if(defined $existing_row){
      $b->WriteToEmail("File $file_id had existing file_nifti row\n");
    } else {
      my @parms = SetInsertParms($nifti, $file_id);
      Query('CreateFileNifti')->RunQuery(sub{}, sub{}, @parms);
      $b->WriteToEmail("Created file_nifti row for file $file_id\n");
    }
  }
}
# to do:  Find Imported nifti by import_comment and add file_id to
#         defaced_dicom_series in new column "difference_nifti"
my $diff_niftis_added;
print STDERR "Making query: DefacingImportCommentsLike(\n";
Query('DefacingImportCommentsLike')->RunQuery(sub{
  my($row) = @_;
print STDERR "Got a row from: DefacingImportCommentsLike\n";
  my $import_comment = $row->[0];
  my $diff_nifti = 
    Query('GetDifferenceNiftiByImportComment')
    ->FetchOneHash($import_comment)->{difference_nifti_file_id};
  unless(defined $diff_nifti){
    print STDERR "Query: GetDifferenceNiftiByImportComment failed to find file\n";
  }
  Query('AddDiffNifti')->RunQuery(sub{}, sub{},
    $diff_nifti, $import_comment);
  $diff_niftis_added += 1;
}, sub{},"($invoc_id): Import of Defaced Dicom from%");
$b->WriteToEmail("Added $diff_niftis_added\n");

$b->Finish("Done");

sub SetInsertParms{
  my($nifti, $file_id) = @_;
  my @parms;
  push @parms, $file_id;
  SetRemainingParms(\@parms, $nifti);
  return @parms;
}
sub SetRemainingParms{
  my($parms, $nifti) = @_;
  my $p = $nifti->{parsed};
  push @$parms, $p->{magic};
  my $is_from_zip;
  if(exists $nifti->{is_from_zip}){
    $is_from_zip = 1;
  } else {
    $is_from_zip = 0;
  }
  push @$parms, $is_from_zip;
  push @$parms, $p->{descrip};
  push @$parms, $p->{aux_file};
  push @$parms, $p->{bitpix};
  push @$parms, $p->{datatype};
  push @$parms, $p->{dim}->[0];
  push @$parms, $p->{dim}->[1];
  push @$parms, $p->{dim}->[2];
  push @$parms, $p->{dim}->[3];
  push @$parms, $p->{dim}->[4];
  push @$parms, $p->{dim}->[5];
  push @$parms, $p->{dim}->[6];
  push @$parms, $p->{dim}->[7];
  push @$parms, $p->{pixdim}->[0];
  push @$parms, $p->{pixdim}->[1];
  push @$parms, $p->{pixdim}->[2];
  push @$parms, $p->{pixdim}->[3];
  push @$parms, $p->{pixdim}->[4];
  push @$parms, $p->{pixdim}->[5];
  push @$parms, $p->{pixdim}->[6];
  push @$parms, $p->{pixdim}->[7];
  push @$parms, $p->{intent_code};
  push @$parms, $p->{intent_name};
  push @$parms, $p->{intent_p1};
  push @$parms, $p->{intent_p2};
  push @$parms, $p->{intent_p3};
  push @$parms, $p->{cal_max};
  push @$parms, $p->{cal_min};
  push @$parms, $p->{scl_slope};
  push @$parms, $p->{scl_inter};
  push @$parms, $p->{slice_start};
  push @$parms, $p->{slice_end};
  push @$parms, $p->{slice_code};
  push @$parms, $p->{sform_code};
  push @$parms, $p->{srow_x}->[0];
  push @$parms, $p->{srow_x}->[1];
  push @$parms, $p->{srow_x}->[2];
  push @$parms, $p->{srow_x}->[3];
  push @$parms, $p->{srow_y}->[0];
  push @$parms, $p->{srow_y}->[1];
  push @$parms, $p->{srow_y}->[2];
  push @$parms, $p->{srow_y}->[3];
  push @$parms, $p->{srow_z}->[0];
  push @$parms, $p->{srow_z}->[1];
  push @$parms, $p->{srow_z}->[2];
  push @$parms, $p->{srow_z}->[3];
  push @$parms, $p->{xyzt_units};
  push @$parms, $p->{qform_code};
  push @$parms, $p->{quatern_b};
  push @$parms, $p->{quatern_c};
  push @$parms, $p->{quatern_d};
  push @$parms, $p->{q_offset_x};
  push @$parms, $p->{q_offset_y};
  push @$parms, $p->{q_offset_z};
  push @$parms, $p->{vox_offset};
};

