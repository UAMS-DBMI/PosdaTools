#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
#use Time::Piece;
my $usage = <<EOF;
CsvApplyPrivateDisposition.pl <notify email>
  Creates image_equivalence_class rows for series listed on STDIN
EOF
unless($#ARGV == 0) { die $usage }
my $email_addr = $ARGV[0];
my @cmds;
my $num_lines = 0;
my $series_list = "Series list:\n";
while(my $line = <STDIN>){
  chomp $line;
  push @cmds, "CreateSeriesEquivalenceClasses.pl $line\n";
  $series_list .= "$line\n";
  $num_lines += 1;
}
print "$num_lines processed for series_list\n";
fork and exit;
close STDOUT;
close STDIN;
open COMMANDS, "|/bin/sh" or die "Can't open shell";
for my $i (@cmds) {
  print COMMANDS $i;
}
print COMMANDS "echo \"$series_list\"|mail -s \"Job Complete\" $email_addr\n";
close COMMANDS;
