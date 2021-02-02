#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
ImportDownloadableDirectory.pl <?bkgrnd_id?> <activity_id> "<comment>" "<sub_dir>" <notify>
  or
ImportDownloadableDirectory.pl -h
Expects no lines on STDIN:
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 4) { print $usage; exit }

my($invoc_id, $act_id, $comment, $sub_dir, $notify) = @ARGV;
my $import_description =
  "ImportBased on ImportDownloadableDirectory.pl $invoc_id $act_id '$comment' '$sub_dir' $notify";

my $cache_dir = $ENV{POSDA_CACHE_ROOT};
my $dir = "$cache_dir/linked_for_download/$sub_dir";
unless(-d $dir) {
  print "Error: $dir doesn't exist\n";
  exit;
}
open FIND, "find $dir -type f |";
my %FoundFiles;
while(my $line = <FIND>){
  chomp $line;
  $FoundFiles{$line} = 1;
}
close FIND;
my $num_files = keys %FoundFiles;
print "Found $num_files files in $dir\n";

open FIND, "find $dir -type l |";
my %FoundLinks;
while(my $line = <FIND>){
  chomp $line;
  $FoundLinks{$line} = 1;
}
close FIND;
my $num_links = keys %FoundLinks;
print "Found $num_links links in $dir\n";

unless($num_files > 0 || $num_links > 0){
  print "Nothing found to import\n";
  print "find $dir -type f\n";
  print "find $dir -type l\n";
  exit;
}
print "Going to background to import $num_files files and $num_links soft links\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;


#################
# Import Loop
$background->SetActivityStatus("Queuing files and links");
$background->WriteToEmail("Import comment: \"$import_description\"\n");
open IMPORT, "|ImportMultipleFilesIntoPosda.pl \"$import_description\"";
my $things_queued = 0;
for my $file (keys %FoundFiles){
  print IMPORT "$file\n";
  $things_queued += 1;
}
for my $link (keys %FoundLinks){
  print IMPORT "$link\n";
  $things_queued += 1;
}
$background->SetActivityStatus("Waiting for imports to clear");
close IMPORT;
$background->WriteToEmail("$num_files files and $num_links links imported\n");

$background->Finish("Done - see email for status");
