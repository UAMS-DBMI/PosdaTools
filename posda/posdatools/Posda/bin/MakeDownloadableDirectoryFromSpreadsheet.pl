#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print @_ };

my $usage = <<EOF;
Usage:
MakeDownloadableDirectoryFromSpreadsheet.pl <?bkgrnd_id?> <activity_id> <sub_dir> <notify>
  or
MakeDownloadableDirectoryFromSpreadsheet.pl -h

Expects lines on STDIN:
<uploaded_file_name>&<stored_file_name>

EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 3) { print $usage; exit }

my($invoc_id, $activity_id, $sub_dir, $notify) = @ARGV;
my $start = time;

my %FileConversion;
while(my $line = <STDIN>){
  chomp $line;
  my($upd, $stored) = split /&/, $line;
  my $fname;
  if($upd =~ /\\(.*)$/){
    $fname = $1;
  }
  if(exists $FileConversion{$fname}){
    print "Error: file_name $fname is not unique\n";
    exit;
  }
  $FileConversion{$fname} = $stored;
}


my $cache_dir = $ENV{POSDA_CACHE_ROOT};
unless(-d $cache_dir){
  print "Error: Cache dir ($cache_dir) isn't a directory\n";
  exit;
}
unless(-d "$cache_dir/linked_for_download"){
  mkdir "$cache_dir/linked_for_download";
}
unless(-d "$cache_dir/linked_for_download"){
  print "Error: Cache dir ($cache_dir) isn't a directory\n";
  exit;
}

my $dir = "$cache_dir/linked_for_download/$sub_dir";
if(-d $dir) {
  print "Error: $dir already exists\n";
  exit;
}
unless(mkdir($dir) == 1) {
  print "Error ($!): couldn't mkdir $dir\n";
  exit;
}
my $num_files = keys %FileConversion;
print "Found $num_files to link\n";

#############################
# This is code which sets up the Background Process and Starts it
my $forground_time = time - $start;
print "Going to background to link files after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$background->Daemonize;
my $start_creation = time;
### Linking Directories Here
my $file_seq = 0;
for my $file (keys %FileConversion){
  if(symlink $FileConversion{$file}, "$dir/$file"){
#    $background->WriteToEmail("symlink $FileConversion{$file}, \"$dir/$file\"\n");
    $file_seq += 1;
    $background->SetActivityStatus("Linked $file_seq files");
  } else {
    $background->WriteToEmail("Failed ($!): symlink $FileConversion{$file}, \"$dir/$file\"\n");
  }
}
###
my $link_time = time - $start_creation;
$background->WriteToEmail("Linked $file_seq files in $link_time seconds.\n");
$background->Finish("Linked $file_seq files");
