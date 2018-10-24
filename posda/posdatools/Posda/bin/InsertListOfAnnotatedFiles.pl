#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::UUID;
use Posda::DownloadableFile;

use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
InsertListOfAnnotatedFiles.pl <bkgrnd_id> <comment> <notify>
or
InsertListOfAnnotatedFiles.pl -h

Expects lines of the form:
<file_id>&<file_name>&<mime_type>&<description>

EOF
my %Files;

#############################
## This code process parameters
##
#
#

if($#ARGV == 0) { die "$usage\n\n" }
if($#ARGV != 2){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $description, $notify) = @ARGV;
while(my $line = <STDIN>){
  chomp $line;
  my($file_id, $file_name, $mime_type, $desc) = split(/&/, $line);
  $Files{$file_id} = [$file_name, $mime_type, $desc];
}

my $num_files = keys %Files;
print "Found list of $num_files to annotate\n";
print "Subprocess_invocation_id: $invoc_id\n";
print "Forking background process\n";
#############################
# This is code which sets up the Background Process and Starts it
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
# now in the background...
$background->WriteToEmail(
  "Starting annotation on $num_files sop_instance_uids\n" .
  "Description: $description\n" .
  "Subprocess_invocation_id: $invoc_id\n");
for my $id (keys %Files){
  my($file_name, $mime_type, $desc) = @{$Files{$id}};
  $background->WriteToEmail("###############\n");
  $background->WriteToEmail("File id: $id\n");
  $background->WriteToEmail("File name: $file_name\n");
  $background->WriteToEmail("Mime type: $mime_type\n");
  $background->WriteToEmail("Description: $desc\n");
  my $op = "ScriptButton";
  my $caption = "Download file $id ($file_name)";
  my $param_hash = {
    op => "OpenTableFreePopup",
    class_ => "DbIf::AnnotatedFile",
    cap_ => "DownloadFile",
    file_id => $id,
    targ_name => $file_name,
    mime_type => $mime_type,
    subprocess_invoc_id => $invoc_id,
    notify => $notify
  };
  $background->InsertEmailButton($caption, $op, $param_hash);
}
$background->WriteToEmail("###############\n");
$background->Finish;
