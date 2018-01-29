#!/usr/bin/env perl

use Modern::Perl;
use Posda::BackgroundProcess;
use Posda::UUID;
use Posda::Config 'Config';
use Posda::DB 'Query';
use Posda::DebugLog;

use List::Util 'max';
use Data::Dumper;

my $usage = <<EOF
Usage: ExtractAndImportZip.pl <background_id> <notify> <filename>

This is a Background Process script which extract a given tar file
to the POSDA_SUBMISSION_ROOT and then import the files in-place.

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

my $report = $background->CreateReport('main');

$background->WriteToEmail("Began extract and import operation..\n");
$background->WriteToEmail("$filename\n");

my $guid = Posda::UUID->GetGuid();
my $submission_root = Config('submission_root');
my $extract_dir = "$submission_root/$guid";

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
  DEBUG "Added file_id: $i";
}

my $max_file_id = max @file_ids;

$background->WriteToEmail("Files imported, waiting on import of file_id $max_file_id\n");

my $q_check_file = Query("IsFileProcessed");
my $continue = 1;

while ($continue) {
  DEBUG "Sleeping for 60 seconds, while we wait for $max_file_id to be ready.";
  sleep 60;
  my $val = $q_check_file->FetchOneHash($max_file_id);
  $continue = not $val->{processed};
}

$background->WriteToEmail("All files have been fully processed.\n");

DEBUG "Import complete";
$background->Finish;
