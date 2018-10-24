#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::BackgroundProcess;
use Time::Piece;
my $usage = <<EOF;
CsvFixAcrin.pl <invoc_id> <to_dir> <uid_root> <low_date> <high_date> <notify>
  For each file in specified patient list in ACRIN_FLT_Breast collection
  Changes Patient_id and Patient name based on existing Patient id:
    "1" => "ACRIN_FLT_Breast_001", 
    "2" => "ACRIN_FLT_Breast_002", 
    ...
  Then applies private tag disposition from knowledge base
  writes result into <to_dir>
  UID's not hashed if they begin with <uid_root>
  date's not offset unless result of offset leaves date between <low_date> and <high_date>
Expects the following list on <STDIN>
  <patient_id>&<study_uid>&<series_uid>&<offset_pat_id>&<offset>
Note that this encodes two arrays:
  lines with <series_uid> must have <patient_id>, <study_uid>; these specify
    a list of series to be transferred
  lines with <offset> must have <offset_pat_id> (which need not be the same
    as <patient_id> on the same line.  These line specify a mapping from 
    <patient_id> (specified in <offset_pat_id>) to <offset>
Each line with a <series_uid> specifies a series for which private
dispositions should be applied to each file in the series.  The path to the 
resulting file is constructed as follows:
  <to_dir>/<patient_id>/<study_uid>/<series_uid>/<modality>_sop_inst_uid.dcm
Actually invokes NewerFixAcrin.pl to do the edits

Conforms to background protocol.  Notifies user when finished.
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 5) { 
  my $num_args = $#ARGV;
  print "Command: $0";
  for my $i (@ARGV){
    print " \"$i\"";
  }
  print "\n";
  print "Wrong number of args: $num_args vs 5\n";
  print "$usage\n";
  die $usage;
}
my $invoc_id = $ARGV[0];
my $to_dir = $ARGV[1];
my $uid_root = $ARGV[2];
my $low_date = $ARGV[3];
my $high_date = $ARGV[4];
my $notify = $ARGV[5];
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
unless(-d $to_dir) { die "$to_dir is not a directory" }
my %Patients;
my %Series;
my %Offsets;
my $num_lines = 0;
while(my $line = <STDIN>){
  chomp $line;
  my($patient_id, $study_uid, $series_uid, $offset_pat_id, $offset) =
    split /&/, $line;
  if(defined($series_uid) && $series_uid ne ""){
    $Patients{$patient_id}->{$study_uid}->{$series_uid} = 1;
    $Series{$series_uid} = 1;
  }
  if(defined($offset) && $offset ne ""){
    $Offsets{$offset_pat_id} = $offset;
  }
  $num_lines += 1;
}
my $q1 = PosdaDB::Queries->GetQueryInstance(
  "AreVisibleFilesMarkedAsBadOrUnreviewedInSeries");
my $q2 = PosdaDB::Queries->GetQueryInstance(
  "IsThisSeriesNotVisuallyReviewed");
my $q3 = PosdaDB::Queries->GetQueryInstance(
  "DispositonsNeededSimple");
my $error = 0;
for my $series (keys %Series){
  $q2->RunQuery(sub {
    my($row) = @_;
    print "Warning: series $series not submitted for visual review\n";
  }, sub {}, $series);
  $q1->RunQuery(sub{
    my($row) = @_;
    print "Error series $series has unreviewed or bad files\n";
    $error += 1;
  }, sub {}, $series);
}
my $num_disps_needed = 0;
$q3->RunQuery(sub {
  my($row) = @_;
  $num_disps_needed += 1;
},
sub {},
);
if($num_disps_needed > 0){
  print "Error $num_disps_needed private tags are " .
    "lacking private dispositions\n";
  $error += 1;
}
for my $pat_id (keys %Patients){
  unless(exists $Offsets{$pat_id}){
    print "Error patient_id $pat_id has no offset defined.\n";
    $error += 1;
  }
}

if($error){
  print "Not forking background because of errors\n";
  exit;
}

print "$num_lines series to convert\n";

$background->ForkAndExit;
my $date = `date`;
my $bkgrnd_id = $background->GetBackgroundID;
$background->WriteToEmail("$date\nStarting ACRIN fixup\n" .
  "To directory: $to_dir\n" .
  "background_subprocess_id: $bkgrnd_id\n");
my @cmds;
my $q_inst = PosdaDB::Queries->GetQueryInstance("FilesInSeriesForApplicationOfPrivateDisposition");
for my $patient_id (sort keys %Patients){
  for my $study_uid (sort keys %{$Patients{$patient_id}}){
    for my $series_uid (sort keys %{$Patients{$patient_id}->{$study_uid}}){
      my $offset = $Offsets{$patient_id};
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
        my $cmd = "NewerFixAcrin.pl $path \"$to_dir/$patient_id/" .
          "$study_uid/" .
          "$series_uid/$modality" . "_$sop_instance_uid.dcm\" " .
          "$uid_root $offset $low_date $high_date";
        push @cmds, $cmd;
      }, sub{}, $series_uid);
    }
  }
}
my $num_commands = @cmds;
$background->WriteToEmail(`date`);
$background->WriteToEmail(`about to execute $num_commands in 5 subshells\n`);
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
$background->WriteToEmail(`date`);
$background->WriteToEmail("All commands queued\n");
close SCRIPT1;
close SCRIPT2;
close SCRIPT3;
close SCRIPT4;
close SCRIPT5;
$background->LogCompletionTime;
$background->WriteToEmail(`date`);
$background->WriteToEmail("All subshells complete\n");
