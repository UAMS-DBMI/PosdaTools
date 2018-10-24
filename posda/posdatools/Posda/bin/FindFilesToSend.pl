#!/usr/bin/perl -w
use strict;
use POSIX qw(strftime);
use Digest::MD5;
my $usage = "$0 <root> <search_root>";
unless($#ARGV == 1) { die $usage }
my $search_root = $ARGV[1];
my $root = $ARGV[0];
unless($search_root =~ /^$root(.*)/){
  die "$root is not contained in $search_root";
}
open FILE, "find \"$search_root\" -type f|" or die;
while (my $file = <FILE>){
  #my $file = "$search_root/$f";
  chomp $file;
  unless(-f $file) { die "File ($file) doesn't exist" }
  my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
      $atime,$mtime,$ctime,$blksize,$blocks) = stat($file);
  my $now = time;
  my $ctx = Digest::MD5->new;
  open DIG, "<$file" or die "Can't open $file (for digest)";
  $ctx->addfile(*DIG);
  my $dig = $ctx->hexdigest;
  close DIG;
  my $time_tag = strftime '%Y/%m/%d %H:%M:%S', localtime $mtime;
  unless($file =~ /^$root\/(.*)$/){
    print STDERR "$file does not contain $root\n";
  }
  my $rel_path = $1;
  my @dirs = split(/\//, $rel_path);
  my $collection = $dirs[0];
  my $site = $dirs[1];
  my $subj = $dirs[2];
  print "SendLinkToPosda.pl localhost 6666 \"$rel_path\" $dig " .
    "\"$collection\" \"$site\" \"$subj\" \"$time_tag\"" .
    "\n";
}
