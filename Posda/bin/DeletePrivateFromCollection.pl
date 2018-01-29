#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Digest::MD5;
my $usage = <<EOF;
DeletePrivateFromCollection.pl.pl <id> <collection> <to_dir> <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  collection - collection to copy
  notify - who to notify when complete
  writes result into <to_dir>

Expects nothing on STDIN

For all the visible files in the collection, edit the file to delete
all private tags except the following:
(0013,"CTP",10)
(0013,"CTP",11)
(0013,"CTP",12)

The files are stored under the <to_dir> in the following directory 
hierarchy:
<patient>/<study_instance_uid>/<series_instance_uid>/<file_id>.dcm

Note: this allows the script to be run without eliminating duplicate
sop_instance_uids.

Uses Query "GetFileHierarchyByCollection" to get the files to edit.
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 3){
  print "Invalid number of args\n$usage";
  exit;
}
my($invoc_id, $collection, $to_dir, $notify) = @ARGV;
unless(-d $to_dir) {
  print "$to_dir is not a directory\n";
  exit;
}
my $directories_created = 0;
my $get_files = Query("GetFileHierarchyByCollection");
my @command_list;
$get_files->RunQuery(sub {
  my($row) = @_;
  my($path, $patient_id, $study_instance_uid, $series_instance_uid, $file_id) = 
    @$row;
  my $cmd = "DeletePrivateExceptCtp.pl \"$path\" " .
    "\"$to_dir/$patient_id/$study_instance_uid/$series_instance_uid/$file_id.dcm\"";
  push(@command_list, $cmd);
  unless(-d "$to_dir/$patient_id"){
    unless((mkdir "$to_dir/$patient_id") == 1){
      print "Unable to make dir $to_dir/$patient_id\n";
      die "Unable to make dir $to_dir/$patient_id\n";
    }
    $directories_created += 1;
  }
  unless(-d "$to_dir/$patient_id/$study_instance_uid"){
    unless((mkdir "$to_dir/$patient_id/$study_instance_uid") == 1){
      print "Unable to make dir $to_dir/$patient_id/$study_instance_uid\n";
      die "Unable to make dir $to_dir/$patient_id/$study_instance_uid\n";
    }
    $directories_created += 1;
  }
  unless(-d "$to_dir/$patient_id/$study_instance_uid/$series_instance_uid"){
    unless((mkdir "$to_dir/$patient_id/$study_instance_uid/$series_instance_uid") == 1){
      print "Unable to make dir $to_dir/$patient_id/$study_instance_uid/$series_instance_uid\n";
      die "Unable to make dir $to_dir/$patient_id/$study_instance_uid/$series_instance_uid\n";
    }
    $directories_created += 1;
  }
}, sub {}, $collection);
my $files_to_edit = @command_list;
print "$files_to_edit files to edit\n";
print "$directories_created directories created\n";
print "entering background\n";

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

$background->ForkAndExit;
my $tt = `date`;
chomp $tt;
$background->WriteToEmail("$tt starting copy of $files_to_edit files\n");
$background->WriteToEmail(
  "about to execute $files_to_edit in 5 subshells\n");
open SCRIPT1, "|/bin/sh";
open SCRIPT2, "|/bin/sh";
open SCRIPT3, "|/bin/sh";
open SCRIPT4, "|/bin/sh";
open SCRIPT5, "|/bin/sh";
command:
while(1){
  my $cmd = shift @command_list;
  unless(defined $cmd){ last command }
  print STDERR "1. Running cmd: $cmd\n";
  print SCRIPT1 "$cmd\n";
  $cmd = shift @command_list;
  unless(defined $cmd){ last command }
  print STDERR "2. Running cmd: $cmd\n";
  print SCRIPT2 "$cmd\n";
  $cmd = shift @command_list;
  unless(defined $cmd){ last command }
  print STDERR "3. Running cmd: $cmd\n";
  print SCRIPT3 "$cmd\n";
  $cmd = shift @command_list;
  unless(defined $cmd){ last command }
  print STDERR "4. Running cmd: $cmd\n";
  print SCRIPT4 "$cmd\n";
  $cmd = shift @command_list;
  unless(defined $cmd){ last command }
  print STDERR "5. Running cmd: $cmd\n";
  print SCRIPT5 "$cmd\n";
}
$tt = `date`;
chomp $tt;
$background->WriteToEmail("$tt Queued All commands\n");
close SCRIPT1;
close SCRIPT2;
close SCRIPT3;
close SCRIPT4;
close SCRIPT5;
chomp $tt;
$background->WriteToEmail("$tt All subshells complete\n");
$background->Finish;
