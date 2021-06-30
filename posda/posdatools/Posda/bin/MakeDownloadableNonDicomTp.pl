#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print @_ };

my $usage = <<EOF;
Usage:
MakeDownloadableNonDicomTp.pl <?bkgrnd_id?> <activity_id> <sub_dir> <notify>
  or
MakeDownloadableNonDicomTp.pl -h

Expects no lines on STDIN:

EOF


if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 3) { print $usage; exit }


my($invoc_id, $activity_id, $sub_dir, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$background->Daemonize;
my $start = time;

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
my %Files;
Query('FileIdTypePathFromActivity')->RunQuery(sub {
  my($row) = @_;
  my($file_id, $file_type, $path) = @$row;
  $Files{$file_id} = {
    new_file => "$dir/$file_id",
    to_path => $path,
    type => $file_type
  };
}, sub{}, $activity_id);
my $num_links;
for my $f (keys %Files){
  symlink $Files{$f}->{to_path}, $Files{$f}->{new_file};
  $num_links += 1;
}
my $link_time = time - $start;
$background->WriteToEmail("Linked $num_links files in $link_time seconds.\n");
$background->Finish;
