#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/TciaCuration/bin/DirMenu.pl,v $
#$Date: 2014/11/06 18:04:08 $
#$Revision: 1.2 $
#
use strict;
my $dir = $ARGV[0];
my $meth = $ARGV[1];
my $obj_path = $ARGV[2];
unless(opendir DIR, $dir){
  print "Error: Can't opendir $dir ($!)";
  exit;
}
my @sub_dirs;
file:
while(my $f = readdir(DIR)){
  if($f =~ /^\./) { next file }
  unless(-d "$dir/$f") {
    print "Error: found file $f\n";
    next file;
  }
  push(@sub_dirs, $f);
}
my %sub_dir_counts;
count:
for my $i (@sub_dirs){
  my $count = 0;
  my $find_cmd = "find \"$dir/$i\" -type f |";
  unless(open SUBDIR, "find \"$dir/$i\" -type f |"){
    print "Can't find -type \"$dir/$i\"\n";
    next count;
  }
  found:
  while(my $line = <SUBDIR>) {
    chomp $line;
    if($line =~ /\.lg$/) { next found }
    if($line =~ /\.db$/) { next found }
    $count += 1;
  }
  $sub_dir_counts{$i} = $count;
}
print "Subdirectories<ul>\n";
for my $i (sort keys %sub_dir_counts){
  if($sub_dir_counts{$i} > 0){
    print "<li>$i - ($sub_dir_counts{$i})</li>\n";
  }
}
print "</ul>\n";
