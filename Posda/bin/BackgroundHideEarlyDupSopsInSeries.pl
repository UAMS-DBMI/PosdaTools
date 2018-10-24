#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
my $usage = <<EOF;
BackgroundHideEarlyDupSopsInSeries.pl <?bkgrnd_id?> <notify> "<reason>"
  reads a list of series from STDIN
  runs HideSeriesWithStatus.pl <series> <who> "<reason>"
    as a sub-process for each.
  prints "Hide status for series : <series>" on STDOUT for
    each series hidden

  Meant to be invoked as a table handler from DbIf
EOF
unless($#ARGV == 2) { die $usage }
my($invoc_id, $notify, $why) = @ARGV;
my @Series;
while(my $line = <STDIN>){
  chomp $line;
  push @Series, $line;
}
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
my $num_series = @Series;
print "found $num_series to hide\n";
print "Going to background\n";
$back->Daemonize;
for my $line (@Series){
  $back->WriteToEmail("Hide status for series : $line\n");
  my $cmd ="HideEarlySopDupsInSeries.pl $line $notify \"$why\"";
  open CMD, "$cmd|" or die "can't open $cmd|";
  while(my $line = <CMD>) { $back->WriteToEmail($line) }
}
$back->Finish;
