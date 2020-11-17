#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
AddFilesToTimepoint.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>
or
AddFilesToTimepoint1.pl -h

The script expects lines in the following format on STDIN:
<file_id>

Assuming all of the parameters look good, all of the input lines are slurped
and counted.  Then a background process is forked, and the status is returned
on STDOUT. All processing is done in the background process.

EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  die "$usage\n";
}

my ($invoc_id, $activity_id, $comment, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);

my %FilesToAdd;
my $line_count = 0;
line:
while(my $line = <STDIN>){
  chomp $line;
  $line_count += 1;
  $FilesToAdd{$line} = 1;
}
my $num_files = keys %FilesToAdd;
print "Number of files to add: $num_files\n";
print "  Number of lines read: $line_count\n";

#  Get latest timepoint in activity
my $old_timepoint;
Query('LatestActivityTimepointForActivity')->RunQuery(sub{
  my($row) = @_;
  $old_timepoint = $row->[0];
}, sub{}, $activity_id);
unless(defined($old_timepoint)){
  print "Can't get latest activity_timepoint\n";
  exit;
}
print "Current activity_timepoint: $old_timepoint\n";
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
