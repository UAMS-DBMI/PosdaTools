#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::ActivityInfo;
use Debug;
my $dbg = sub { print @_ };

my $usage = <<EOF;
Usage:
CreateDownloadableDirectoryTpAll.pl <?bkgrnd_id?> <activity_id> <sub_dir> <notify>
  or
CreateMakeDownloadableDirectoryTpAll.pl -h

Expects no lines on STDIN:

EOF
my $start = time;

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 3) {
  die "wrong number of args\n$usage" }

my($invoc_id, $activity_id, $sub_dir, $notify) = @ARGV;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$background->Daemonize;

my %Files;
Query('FilePathsFromActivity')->RunQuery(sub{
  my($row) = @_;
  my($file_id, $root_path, $rel_path) = @$row;
  $Files{$file_id} = "$root_path/$rel_path";
}, sub{}, $activity_id);


my $cache_dir = $ENV{POSDA_CACHE_ROOT};
unless(-d $cache_dir){
  print STDERR "Error: Cache dir ($cache_dir) isn't a directory\n";
  exit;
}
unless(-d "$cache_dir/linked_for_download"){
  mkdir "$cache_dir/linked_for_download";
}
unless(-d "$cache_dir/linked_for_download"){
  print STDERR "Error: Cache dir ($cache_dir) isn't a directory\n";
  exit;
}

my $dir = "$cache_dir/linked_for_download/$sub_dir";
if(-d $dir) {
  print STDERR "Error: $dir already exists\n";
  exit;
}
unless(mkdir($dir) == 1) {
  print STDERR "Error ($!): couldn't mkdir $dir\n";
  exit;
}
### Linking files
my $files_linked = 0;
for my $fid (keys %Files){
  my $new_file = "$dir/$fid.file";
  my $file = $Files{$fid};
  symlink $file, $new_file;
  $files_linked += 1;
}
###
my $link_time = time - $start;
$background->WriteToEmail("Linked $files_linked files in $link_time seconds.\n");
$background->Finish("Linked $files_linked files in $link_time seconds.");
