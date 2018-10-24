#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;

use Posda::BackgroundProcess;
use Posda::DownloadableFile;

my $usage = <<EOF;
BackgroundCompareFromToFiles.pl <bkgrnd_id> <notify_email>
or
BackgroundCompareDupSopList.pl -h

Generates a csv report file
Sends email when done, which includes a link to the report
Expect input lines in following format:
<sop_instance_uid>&<from_file>&<to_file>
EOF

$|=1;

unless($#ARGV == 1 ){ die $usage }

my ($invoc_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);


my %data;
while(my $line = <STDIN>){
  chomp $line;
  $background->LogInputLine($line);
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
my $num_sops = keys %data;
print "$num_sops SOPs loaded\n";

$background->Daemonize;

$background->WriteToEmail("Comparing $num_sops sops.\n");

my $report = $background->CreateReport();

$report->print("\"Sop InstanceUID\"," .
  "\"File From\",\"File To\",\"Differences\"\r\n");

my @SopList = sort keys %data;

Sop:
for my $i (0 .. $#SopList){
  my $sop = $SopList[$i];
  my $file_f = $data{$sop}->{from};
  my $file_t = $data{$sop}->{to};
  my $dump_f = File::Temp::tempnam("/tmp", "one");
  my $dump_t = File::Temp::tempnam("/tmp", "two");
  my $cmd_f = "DumpDicom.pl $file_f > $dump_f";
  my $cmd_t = "DumpDicom.pl $file_t > $dump_t";

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
  $report->print("$sop,\"$file_f\",\"$file_t\",\"$diff\"\r\n");
}

$background->Finish;
