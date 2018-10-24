#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;

use Posda::BackgroundProcess;
use Posda::DownloadableFile;

my $usage = <<EOF;
TestNewDicomCompare.pl <bkgrnd_id> <edit_id> <notify_email>
or
TestNewDicomCompare.pl -h

Populates dicom_edit_compare table
Expect input lines in following format:
<sop_instance_uid>&<from_file>&<to_file>
EOF

$|=1;

unless($#ARGV == 2 ){ die $usage }

my ($invoc_id, $edit_id, $notify) = @ARGV;

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

$background->ForkAndExit;
$background->LogInputCount($num_sops);

print STDERR "In child\n";

close STDOUT;
close STDIN;
my @SopList = sort keys %data;
$background->WriteToEmail("$num_sops sops to process in child\n");
print STDERR "$num_sops sops to process in child\n";
my $start_time = time;
my $done = 0;
my $num_ok = 0;
my $num_bad = 0;
Sop:
for my $i (0 .. $#SopList){
  my $sop = $SopList[$i];
  my $file_f = $data{$sop}->{from};
  my $file_t = $data{$sop}->{to};
  my $cmd = "CompareFilesAndPopulateDicomEditCompare.pl $edit_id " .
    "\"$file_f\" \"$file_t\"";
#  print STDERR "command: $cmd\n";
  open RESP, "$cmd|";
  my $ok;
  while(my $line = <RESP>){ if($line =~ /^Ok:/) {$ok = 1} }
  close RESP;
  $done += 1;
  if($ok){ $num_ok += 1} else {$num_bad += 1}
}
my $elapsed = time - $start_time;
$background->WriteToEmail("Finished after $elapsed seconds\n");
$background->WriteToEmail("$done done\n$num_ok Ok\n$num_bad bad\n");
$background->LogCompletionTime;
