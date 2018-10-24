#!/usr/bin/perl -w
#
use strict;
use Storable qw( store_fd );
my $usage = "QuickConsolidatedReport.pl <report_file>\n";
unless($#ARGV == 0){ die $usage }
my $ConsolidatedReport = Storable::retrieve($ARGV[0]);
for my $value (sort keys %$ConsolidatedReport){
  print "\"$value\"\t";
  my @tags = keys %{$ConsolidatedReport->{$value}};
  my $num_files = 0;
  for my $i (0 .. $#tags){
    my $tag = $tags[$i];
    print "$tag($ConsolidatedReport->{$value}->{$tag}->{vr})";
    if($i == $#tags) { print "\t" } else { print " " }
    $num_files += keys %{$ConsolidatedReport->{$value}->{$tag}->{files}};
    
  }
  print "$num_files\n";
}
