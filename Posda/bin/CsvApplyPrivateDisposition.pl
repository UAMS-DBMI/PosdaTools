#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Time::Piece;
my $usage = <<EOF;
CsvApplyPrivateDisposition.pl <to_dir> <uid_root> <offset> <low_date> <high_date>
  Applies private tag disposition from knowledge base to list of files on STDIN
  writes result into <to_dir>
  UID's not hashed if they begin with <uid_root>
  date's not offset unless result of offset leaves date between <low_date> and <high_date>
Expects the following list on <STDIN>
  <patient_id>&<study_uid>&<series_uid>
Constructs a destination file name as follows:
  <to_dir>/<patient_id>/<study_uid>/<series_uid>/<modality>_sop_inst_uid.dcm
Actually invokes ApplyPrivateDisposition.pl to do the edits
EOF
unless($#ARGV == 4) { die $usage }
my $to_dir = $ARGV[0];
my $uid_root = $ARGV[1];
my $offset = $ARGV[2];
my $low_date = $ARGV[3];
my $high_date = $ARGV[4];
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
        my $cmd = "ApplyPrivateDisposition.pl $path \"$to_dir/$patient_id/" .
          "$study_uid/" .
          "$series_uid/$modality" . "_$sop_instance_uid.dcm\" " .
          "$uid_root $offset $low_date $high_date";
        push @cmds, $cmd;
      }, sub{}, $series_uid);
    }
  }
}
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
