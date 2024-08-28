#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;

my $usage = <<EOF;
TempMakeAxialInterpolationWorksheet.pl <?bkgrnd_id?> <activity_id> <notify>
or
TempMakeAxialInterpolationWorksheet.pl -h

This script resamples an AXIAL (stictly axial) set of images which have
isotropic pixel data.  Into a set of images on specified z-offsets.
It is used to construct an isotropic volume (the subsampling offsets are 
to be calculated elewhere.

The script expects lines in the following format on STDIN:
<file_id>&<offset>&<resampled_offset>&<pos_x>&<pos_y>&<rows>&<cols>

Where <file_id> is an integer containing the file_id<offset> and <resampled_offset> are signed numbers

There will (presumably) be many rows which have only <resampled_offset>
All of the <resampled_offset>s must have values which are between the
smallest and largest values of the collection of <offset>s

When all of the input has been read, a table of input files is constructed
as follows:

[
  [<offset>, file_id],
  ...
]

This table is sorted numerically by offset.  It is used to construct the output
which is a spreadsheet with the following rows:
  resampled_offset
  preceding_file_id
  distance_to_preceding
  following_file_id
  distance_to_following

This table can be used to construct the interpolated slices...

EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 2){
  die "$usage\n";
}

my ($invoc_id, $activity_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new(
  $invoc_id, $notify, $activity_id);

my %offset_to_file;
my @resampled_offsets;

line:
while(my $line = <STDIN>){
  chomp $line;
  my($file_id, $offset, $resamp_offset) = split(/&/, $line);
  if(defined($file_id) && $file_id ne ""){
    $offset_to_file{$offset} = $file_id;
  }
  if(defined($resampled_offset) && $resampled_offset ne ""){
    push @resampled_offsets, $resampled_offset;
  }
}
my $num_orig_slices = keys %offset_to_file;
my $num_to_resample = @resampled_offsets;
print "Number of slices in original volume: $num_orig_slices\n";
print "Number of slice to resample: $num_to_resample\n";

#  Get latest timepoint in activity
print "Entering background\n";

$background->Daemonize;

$background->SetActivityStatus("Gathering timepoint info");
my %FilesInOld;
Query('FilesInTimepoint')->RunQuery(sub{
  my($row) = @_;
  $FilesInOld{$row->[0]} = 1;
}, sub{}, $old_timepoint);
my $num_in_old = keys %FilesInOld;
my %FilesToBeInNew;
for my $i (keys %FilesInOld){
  $FilesToBeInNew{$i} = 1;
}
my $num_files_already_in_old = 0;
my $num_files_not_already_in_old = 0;
for my $i (keys %FilesToAdd){
  if(exists $FilesInOld{$i}){
    $num_files_already_in_old += 1;
  } else {
    $num_files_not_already_in_old += 1;
     $FilesToBeInNew{$i} = 1;
  }
}
my $num_files_in_new = keys %FilesToBeInNew;
$background->WriteToEmail("$num_in_old files in timepoint $old_timepoint\n");
$background->WriteToEmail("$num_files files to be added\n");
$background->WriteToEmail("$num_files_already_in_old of these are already in old timepoint\n");
$background->WriteToEmail("$num_files_not_already_in_old of these need to be added\n");
unless($num_files_not_already_in_old > 0){
  $background->WriteToEmail("Since all of the specified files are already in old timepoint,\n" .
    "there is no need to create a new timepoint\n");
  $background->Finish("Done: no need to create new timepoint");
  exit;
}

## Create new activity timepoint
my $new_activity_timepoint_id;
Query("CreateActivityTimepoint")->RunQuery(sub{
  my($row) = @_;
}, sub{}, $activity_id, $notify, "AddFilesToTimepoint $invoc_id", $notify);
Query("GetActivityTimepointId")->RunQuery(sub{
  my($row) = @_;
  $new_activity_timepoint_id = $row->[0];
},sub{});
$background->WriteToEmail("created activity_timepoint: $new_activity_timepoint_id\n");

## Load up the new timepoint from %FilesToBeInNew
my $q1 = Query("InsertActivityTimepointFile");
$num_files = keys %FilesToBeInNew;
my $num_copied = 0;

for my $file_id (keys %FilesToBeInNew){
  $num_copied += 1;
  $q1->RunQuery(sub {}, sub {}, $new_activity_timepoint_id, $file_id);
  $background->SetActivityStatus("Populating new timepoint: $num_copied of $num_files");
}
$background->Finish("Done: copied $num_files_not_already_in_old files to new timepoint");
