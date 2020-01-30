#!/usr/bin/env perl

use Modern::Perl;
use Posda::BackgroundProcess;
use Posda::UUID;
use Posda::Config 'Config';
use Posda::DB 'Query';

use List::Util 'max';
use Data::Dumper;

my $usage = <<EOF
Usage: ExtractAndImportZip.pl <background_id> <notify> <filename>

This is a Background Process script which extract a given tar file
to the "imports from browser" file_storage_root and then 
imports the files in-place.

Once the files have been imported and processed, an email report is
sent to <notify>.
EOF
;

say "ExtractAndImportZip.pl";
if ($#ARGV < 2) { 
  die $usage;
}

my ($invoc_id, $notify, $filename) = @ARGV;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);


$background->Daemonize;
# don't write to stdout after this, or it will crash!

my $get_root = Query("GetFileStorageRootByStorageClass");
my $submission_root;
$get_root->RunQuery(sub {
  my($row) = @_;
  $submission_root = $row->[0];
}, sub {}, "imports from browser");

my $report = $background->CreateReport('main');

$background->WriteToEmail("Began extract and import operation..\n");
$background->WriteToEmail("$filename\n");

my $guid = Posda::UUID->GetGuid();
#my $submission_root = Config('submission_root');
my($sec,$min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = 
  localtime(time);
$year += 1900;
my $date_dir = "$year-$mon-$mday";
unless(-d "$submission_root/$date_dir"){
  unless(mkdir "$submission_root/$date_dir"){
     die "Could not create date directory: $submission_root/$date_dir";
  }
}
my $extract_dir = "$submission_root/$date_dir/$guid";

DEBUG "Extracting to: $extract_dir";

unless (mkdir($extract_dir)) {
  die "Could not create extraction directory: $extract_dir";
}

DEBUG "Successfully created extract dir";

# determine filetype; tar or zip?
# if it doesn't end with .zip, assume it's some kind of tar (so we
# can easily support all types of tar files 'tar' can handle)
my $extract_command;

if ($filename =~ /zip$/i) {
  # looks like a zip file
  $extract_command = "unzip \"$filename\" -d \"$extract_dir\"";
} else {
  $extract_command = "tar xvf \"$filename\" -C \"$extract_dir\"";
}

my $results = `$extract_command`;

DEBUG "Extract results: ", Dumper($results);

# Now scan the dir for files and import them into posda
my $import_command = "find \"$extract_dir\" -type f | ImportFilesInPlace.pl - 'zip'";
my $import_return = `$import_command`;

DEBUG "Import results: ", Dumper($import_return);

my @import_return_lines = split('\n', $import_return);


my @import_ids = map {
  /Import id: (.*)/;
} @import_return_lines;
my $import_id = $import_ids[0];

my @file_ids = map {
  /File id: (.*)/;
} @import_return_lines;

my @errors = map {
  /Error: (.*)/;
} @import_return_lines;

# report errors 
for my $error (@errors) {
  $background->WriteToEmail("$error\n");
  $report->print("$error\n");
  say STDERR "Error: $error";
}

for my $i (@file_ids) {
  $report->print("Added file_id: $i\n");
}

my $max_file_id = max @file_ids;

$background->WriteToEmail("Files imported, waiting on import of file_id $max_file_id\n");

my $q_check_file = Query("IsFileProcessed");
my $continue = 1;

while ($continue) {
  sleep 60;
  my $val = $q_check_file->FetchOneHash($max_file_id);
  $continue = not $val->{processed};
}

$background->WriteToEmail("All files have been fully processed.\n");

$background->PrepareBackgroundReportBasedOnQuery(
  'DicomFileSummaryByImportEvent',
  'Import Event Summary',
  200,
  $import_id
);

DEBUG "Import complete";
$background->Finish;
