#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
SendSetOfSeriesToDestination.pl <dicom_host> <port> <called> <calling> <who> <why>
  expects list of series on stdin
EOF
unless($#ARGV == 5) { die $usage }
my($host, $port, $called, $calling, $who, $why) = @ARGV;
my @series_list;
while(my $line = <STDIN>){
  chomp $line;
  my($series) = $line;
  $series =~ s/^\s*//;
  $series =~ s/\s*$//;
  push(@series_list, $series);
}
my $num_series = @series_list;
print "Received list of $num_series series to scan\n";
print "Forking process to send these series\n";
print "\thost: $host\n";
print "\tport: $port\n";
print "\tcalled: $called\n";
print "\tcalling: $calling\n";
close STDOUT;
close STDIN;
fork and exit;
print STDERR "Survived fork with $num_series to process\n";
for my $series (@series_list){
  my $cmd = "SendSeriesFromDbAndRecord.pl $host $port $called $calling " .
    "$series $who \"$why\"";
  `$cmd`;
#  print STDERR "Command: $cmd\n";
}
