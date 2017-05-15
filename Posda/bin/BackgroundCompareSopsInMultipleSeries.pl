#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
my $usage = <<EOF;
BackgroundCompareSopsInMultipleSeries.pl <report_file_name> <notify_email>
or
BackgroundCompareSopsInMultipleSeries.pl -h

Generates a csv report file
Sends email when done
Expect input lines in following format:
<series_instance_uid>&<sop_instance_uid>&<file_id>&<path>
EOF
unless($#ARGV == 1 ){ die $usage }
my %data;
while(my $line = <STDIN>){
  chomp $line;
  my($series_inst, $sop_inst, $file_id, $path) =
    split(/&/, $line);
  $data{$sop_inst}->{$series_inst}->{$file_id} =  $path;
}
my $num_sops = keys %data;
print "$num_sops SOPs loaded\n";
for my $sop (sort keys %data){
  my $num_series = keys %{$data{$sop}};
  print "$sop occurs in  $num_series series\n";
}
my $report_file_name = $ARGV[0];
my $email = $ARGV[1];
fork and exit;
close STDOUT;
close STDIN;
print STDERR "In child\n";
open REPORT, ">$report_file_name" or die "Can't open $report_file_name";
open EMAIL, "|mail -s \"Posda Job Complete\" $email" or die 
  "can't open pipe ($!) to mail $email";
print REPORT "\"Sop InstanceUID\"," .
  "\"File_Id From\",\"File From\",\"Series From\"," .
  "\"File_Id To\",\"File To\",\"Series To\", \"Differences\"\r\n";
print STDERR "Opened children\n";
my @SopList = sort keys %data;
$num_sops = @SopList;
print STDERR "$num_sops sops to process in child\n";
Sop:
for my $i (0 .. $#SopList){
  my $sop = $SopList[$i];
  my @series = sort keys %{$data{$sop}};
  my $num_series = @series;
  unless($#series > 0) {
    my $num_series = @series;
    print STDERR "Sop $sop only occurs in $num_series series (skip)\n";
    print EMAIL "Sop $sop only occurs in $num_series series (skip)\n";
    next Sop;
  }
  print STDERR "Sop $sop occurs in  $num_series series (process)\n";
  print EMAIL "Sop $sop occurs in  $num_series series (process)\n";
  my @check_series;
  series:
  for my $si (0 .. $#series){
    my $s = $series[$si];
    my @files = keys %{$data{$sop}->{$s}};
    if(@files > 1) {
      print STDERR "Series $s has duplicate sops (skip)\n";
      print EMAIL "Series $s has duplicate sops (skip)\n";
      last series;
    }
    my $file_id = $files[0];
    my $path = $data{$sop}->{$s}->{$file_id};
    push(@check_series, [$s, $file_id, $path]);
  }
  for my $j (0 .. $#check_series-1){
    my $series_f = $check_series[$j]->[0];
    my $file_id_f = $check_series[$j]->[1];
    my $file_path_f = $check_series[$j]->[2];
    my $series_t = $check_series[$#check_series]->[0];
    my $file_id_t = $check_series[$#check_series]->[1];
    my $file_path_t = $check_series[$#check_series]->[2];
    my $dump_f = File::Temp::tempnam("/tmp", "one");
    my $dump_t = File::Temp::tempnam("/tmp", "two");
    my $cmd_f = "DumpDicom.pl $file_path_f > $dump_f";
    my $cmd_t = "DumpDicom.pl $file_path_t > $dump_t";
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
    unlink $dump_f;
    unlink $dump_t;
    if($j == 0){
      print REPORT "\"$sop\",";
    } else {
      print REPORT ",";
    }
    print REPORT "\"$file_id_f\",\"$file_path_f\",\"$series_f\"," .
      "\"$file_id_t\",\"$file_path_f\",\"$series_t\"," .
      "\"$diff\"\r\n";
  }
}
close REPORT;
close EMAIL;
