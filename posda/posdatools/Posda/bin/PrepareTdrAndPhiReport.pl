#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
PrepareTdrAndPhiReport.pl 
  Prepare Tdr and Phi Report based on input on STDIN and notify user
  Expects the following list on <STDIN>:
    <scan_id>&<tdr_file_name>&<phi_file_name>&<notification_email_addr>
EOF
unless($#ARGV < 0) { die $usage }
my @Commands;
my $num_lines = 0;
while(my $line = <STDIN>){
  chomp $line;
  my($scan_id, $tdr_file, $phi_file, $email_addr) =
    split /&/, $line;
  push @Commands, "TagDispositionReport.pl $scan_id >$tdr_file";
  push @Commands, "PhiReport.pl $scan_id >$phi_file";
  push @Commands, "echo \"Subject: ReportsComplete\n$tdr_file\n$phi_file\"|mail -s \"Job Complete\" $email_addr\n";
  $num_lines += 1;
}
print "$num_lines lines processed for phi reports\n";
fork and exit;
close STDOUT;
close STDIN;
for my $c (@Commands){
  print STDERR "Command: $c\n\n";
  `$c`;
}
