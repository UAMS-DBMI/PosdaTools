#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DirPerlStructToJson.pl,v $
#$Date: 2014/08/27 12:27:02 $
#$Revision: 1.1 $
use strict;
use Cwd;
my $usage = "DirPerlStructToJson.pl <from_dir> <to_dir>\n";
unless($#ARGV == 1) { die $usage }
my $from = $ARGV[0];
my $to = $ARGV[1];
my $cwd = getcwd;
unless($from =~ /^\//) { $from = $cwd . "/$from" }
unless($to =~ /^\//) { $to = $cwd . "/$to" }
unless(-d $from) { die "$from is not a directory" }
unless(-d $to) { die "$to is not a directory" }
opendir FROM, $from or die "can't opendir $from";
while(my $f = readdir(FROM)){
  if($f =~ /^\./) { next }
  unless(-f "$from/$f") { next }
  unless($f =~ /^(.*)\.perl$/){ next }
  my $nf = $1 . ".json";
  my $ff = "$from/$f";
  my $tf = "$to/$nf";
  my $cmd = "PerlStructToJson.pl \"$ff\" >\"$tf\"";
  print "$cmd\n";
}
