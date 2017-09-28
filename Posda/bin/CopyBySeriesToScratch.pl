#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Time::Piece;
my $usage = <<EOF;
CopyBySeriesToScratch.pl <to_dir> <notify>
  Copies Files to a Scratch Directory base on a list supplied on <STDIN>
Expects the following list on <STDIN>
  <patient_id>&<study_uid>&<series_uid>
Constructs a destination file name as follows:
  <to_dir>/<patient_id>/<study_uid>/<series_uid>/<modality>_sop_inst_uid.dcm
Actually invokes cp to do the copy
EOF
unless($#ARGV == 1) { die $usage }
my $to_dir = $ARGV[0];
my $notify = $ARGV[1];
unless(-d $to_dir) { die "$to_dir is not a directory" }
my %Patients;
my $num_lines = 0;
while(my $line = <STDIN>){
  chomp $line;
  my($patient_id, $study_uid, $series_uid) =
    split /&/, $line;
  $Patients{$patient_id}->{$study_uid}->{$series_uid} = 1;
  $num_lines += 1;
}
print "$num_lines processed for edit files\n";
fork and exit;
close STDOUT;
close STDIN;
open EMAIL, "|mail -s \"Posda Copy To Scratch Complete\" $notify";
my @cmds;
my $q_inst = PosdaDB::Queries->GetQueryInstance("FilesInSeriesForApplicationOfPrivateDisposition");
for my $patient_id (sort keys %Patients){
  for my $study_uid (sort keys %{$Patients{$patient_id}}){
    for my $series_uid (sort keys %{$Patients{$patient_id}->{$study_uid}}){
      my $dir = "$to_dir/$patient_id";
      unless(-d $dir){
        unless(mkdir $dir){
          die "Can't mkdir $dir";
        }
      }
      $dir = "$dir/$study_uid";
      unless(-d $dir){
        unless(mkdir $dir){
          die "Can't mkdir $dir";
        }
      }
      $dir = "$dir/$series_uid";
      unless(-d $dir){
        unless(mkdir $dir){
          die "Can't mkdir $dir";
        }
      }
      $q_inst->RunQuery(sub {
        my($row) = @_;
        my $path = $row->[0];
        my $sop_instance_uid = $row->[1];
        my $modality = $row->[2];
        my $cmd = "cp $path \"$to_dir/$patient_id/" .
          "$study_uid/" .
          "$series_uid/$modality" . "_$sop_instance_uid.dcm\"";
        push @cmds, $cmd;
      }, sub{}, $series_uid);
    }
  }
}
my $num_copies = @cmds;
print EMAIL `date`;
print EMAIL "num_copies to copy\n";
#open SCRIPT, "|/bin/sh";
#for my $cmd (@cmds){
#  print STDERR "Running cmd: $cmd\n";
#  print SCRIPT "$cmd\n";
#}
open SCRIPT1, "|/bin/sh";
open SCRIPT2, "|/bin/sh";
open SCRIPT3, "|/bin/sh";
open SCRIPT4, "|/bin/sh";
open SCRIPT5, "|/bin/sh";
command:
while(1){
  my $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print STDERR "1. Running cmd: $cmd\n";
  print SCRIPT1 "$cmd\n";
  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print STDERR "2. Running cmd: $cmd\n";
  print SCRIPT2 "$cmd\n";
  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print STDERR "3. Running cmd: $cmd\n";
  print SCRIPT3 "$cmd\n";
  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print STDERR "4. Running cmd: $cmd\n";
  print SCRIPT4 "$cmd\n";
  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print STDERR "5. Running cmd: $cmd\n";
  print SCRIPT5 "$cmd\n";
}
print EMAIL `date`;
print EMAIL "All copies complete - closing shells\n";
close SCRIPT1;
close SCRIPT2;
close SCRIPT3;
close SCRIPT4;
close SCRIPT5;
print EMAIL `date`;
print EMAIL "All scripts closed\n";
