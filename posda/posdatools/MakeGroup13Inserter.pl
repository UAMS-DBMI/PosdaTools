#!/usr/bin/perl -w 
use strict;
my $usage = "MakeGroup13Inserter.pl <dir> " .
  "<project_name> <site_name> <site_code>";
unless($#ARGV == 3 && -d $ARGV[0]){ die $usage }
while(my $line = <STDIN>){
  chomp $line;
  unless(-f $line) {
    print STDERR "$line is not a file\n";
    next;
  }
  my $f_part;
  unless($line =~ /\/([^\/]+)$/) {
    print STDERR "can't get file_part from $line\n";
    next;
  }
  $f_part = $1;
  my $new_file = "$ARGV[0]/$f_part";
  print "AddGroup13.pl \"$line\" \"$new_file\" \"$ARGV[1]\" \"$ARGV[2]\" " .
    "\"$ARGV[3]\"\n";
}

