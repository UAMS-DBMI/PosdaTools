#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
my $usage = <<EOF;
BackgroundCompareDupSopList.pl <report_file_name> <notify_email>
or
BackgroundCompareDupSopList.pl -h

Generates a csv report file
Sends email when done
Expect input lines in following format:
<sop_instance_uid>&<file_id>&<path>&<first_loaded>
EOF
unless($#ARGV == 1 ){ die $usage }
my %data;
while(my $line = <STDIN>){
  chomp $line;
  my($sop_inst, $file_id, $path, $load_time) =
    split(/&/, $line);
  $data{$sop_inst}->{$file_id} = {
    path => $path,
    load_time => $load_time,
  };
}
my $num_sops = keys %data;
print "$num_sops SOPs loaded\n";
for my $sop (sort keys %data){
  my $num_files = keys %{$data{$sop}};
  print "$sop has $num_files files\n";
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
  "\"File_Id From\",\"File From\",\"Date To\"," .
  "\"File_Id To\",\"File To\",\"Date To\", \"Differences\"\r\n";
print STDERR "Opened children\n";
my @SopList = sort keys %data;
my $num_sops = @SopList;
print STDERR "$num_sops sops to process in child\n";
Sop:
for my $i (0 .. $#SopList){
  my $sop = $SopList[$i];
  my @files = sort 
    {
      $data{$sop}->{$a}->{load_time} cmp $data{$sop}->{$b}->{load_time}
    }
    keys %{$data{$sop}};
  my $num_files = @files;
  unless($#files > 0) {
    my $num_files = @files;
    print STDERR "Sop $sop has only $num_files files (skip)\n";
    print EMAIL "Sop $sop has only $num_files files (skip)\n";
    next Sop;
  }
  print STDERR "Sop $sop has $num_files files (process)\n";
  print EMAIL "Sop $sop has $num_files files (process)\n";
  for my $j (0 .. $#files-1){
    my $file_f = $data{$sop}->{$files[$j]}->{path};
    my $file_id_f = $files[$j];
    my $file_t = $data{$sop}->{$files[$j + 1]}->{path};
    my $file_id_t = $files[$j + 1];
    my $file_ult_f = $data{$sop}->{$files[$j]}->{load_time};
    my $file_ult_t = $data{$sop}->{$files[$j + 1]}->{load_time};
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
    unlink $dump_f;
    unlink $dump_t;
    if($j == 0){
      print REPORT "\"$SopList[$i]\",";
    } else {
      print REPORT ",";
    }
    print REPORT "\"$file_id_f\",\"$file_f\",\"$file_ult_f\"," .
      "\"$file_id_t\",\"$file_f\",\"$file_ult_t\"," .
      "\"$diff\"\r\n";
  }
}
close REPORT;
close EMAIL;
