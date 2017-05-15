#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
my $usage = <<EOF;
BackgroundCompareFromToFiles.pl <report_file_name> <notify_email>
or
BackgroundCompareDupSopList.pl -h

Generates a csv report file
Sends email when done
Expect input lines in following format:
<sop_instance_uid>&<from_file>&<to_file>
EOF
unless($#ARGV == 1 ){ die $usage }
my %data;
while(my $line = <STDIN>){
  chomp $line;
  my($sop_inst, $from_file, $to_file) =
    split(/&/, $line);
  if(
    defined($sop_inst) &&
    defined($from_file) &&
    defined($to_file) &&
    $sop_inst ne "" &&
    $from_file ne "" &&
    $to_file ne ""
  ){
    $data{$sop_inst} = {
      from => $from_file,
      to => $to_file,
    };
  }
}
$|=1;
my $num_sops = keys %data;
print "$num_sops SOPs loaded\n";
shutdown STDOUT, 1;
my $report_file_name = $ARGV[0];
my $email = $ARGV[1];
fork and exit;
print STDERR "In child\n";
open REPORT, ">$report_file_name" or die "Can't open $report_file_name";
open EMAIL, "|mail -s \"Posda Job Complete\" $email" or die 
  "can't open pipe ($!) to mail $email";
print REPORT "\"Sop InstanceUID\"," .
  "\"File From\",\"File To\",\"Differences\"\r\n";
close STDOUT;
close STDIN;
my @SopList = sort keys %data;
print STDERR "$num_sops sops to process in child\n";
Sop:
for my $i (0 .. $#SopList){
  my $sop = $SopList[$i];
  my $file_f = $data{$sop}->{from};
  my $file_t = $data{$sop}->{to};
  my $dump_f = File::Temp::tempnam("/tmp", "one");
  my $dump_t = File::Temp::tempnam("/tmp", "two");
  my $cmd_f = "DumpDicom.pl $file_f > $dump_f";
  my $cmd_t = "DumpDicom.pl $file_t > $dump_t";
  print STDERR "command: $cmd_f\n";
  print EMAIL "command: $cmd_f\n";
  `$cmd_f`;`$cmd_t`;
  my $diff = "";
  open FILE, "diff $dump_f $dump_t|";
  while(my $line = <FILE>){
    chomp $line;
    $line =~ s/"/""/g;
    $diff .= $line . "\r\n";
  }
  close FILE;
  unlink $dump_f;
  unlink $dump_t;
  print REPORT "$sop,\"$file_f\",\"$file_t\",\"$diff\"\r\n";
}
close REPORT;
close EMAIL;
