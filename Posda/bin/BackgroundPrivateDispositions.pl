#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::BackgroundProcess;
my $usage = <<EOF;
BackgroundApplyPrivateDispositions.pl <id> <to_dir> <uid_root> <offset> <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  writes result into <to_dir>
  UID's not hashed if they begin with <uid_root>
  date's always offset with offset (days)
  email sent to <notify>

Expects the following list on <STDIN>
  <patient_id>&<study_uid>&<series_uid>
Constructs a destination file name as follows:
  <to_dir>/<patient_id>/<study_uid>/<series_uid>/<modality>_sop_inst_uid.dcm
Actually invokes ApplyPrivateDispositionUnconditionalDate.pl to do the edits
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my $child_pid = $$;
my $command = $0;
my $script_start_time = time;
unless($#ARGV == 4){
  print "$usage\n";
  die "######################## subprocess failed to start:\n" .
      "$usage\n" .
      "#####################################################\n";
}
my($invoc_id, $to_dir, $uid_root, $offset, $notify) = @ARGV;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my %Patients;
my $num_lines = 0;
my @Series;
while(my $line = <STDIN>){
  chomp $line;
  my($patient_id, $study_uid, $series_uid) =
    split /&/, $line;
  push @Series, $series_uid;
  $Patients{$patient_id}->{$study_uid}->{$series_uid} = 1;
  $num_lines += 1;
  $background->LogInputLine($line);
}
my $q5 = PosdaDB::Queries->GetQueryInstance(
  "AreVisibleFilesMarkedAsBadOrUnreviewedInSeries");
my $q6 = PosdaDB::Queries->GetQueryInstance(
  "IsThisSeriesNotVisuallyReviewed");
my $error = 0;
for my $series (@Series){
#  $q5->RunQuery(sub {
#  }, sub {}, $series);
  $q6->RunQuery(sub {
    my($row) = @_;
    print "Warning: series $series not submitted for visual review\n";
  }, sub {}, $series);
  $q5->RunQuery(sub{
    my($row) = @_;
    print "Error series $series has unreviewed or bad files\n";
    $error += 1;
  }, sub {}, $series);
}

if($error){
  print "Not forking background because of errors\n";
  $background->LogError("Didn't enter background because of errors");
  exit;
}
my $num_series = @Series;
print "Found list of $num_series series to send\n" .
  "Forking background process\n";
$background->Daemonize;
my $date = `date`;
chomp $date;
$background->WriteToEmail("$date\nStarting ApplyPrivateDispositions\n" .
  "To directory: $to_dir\n");
#######################################################################
### Body of script
my @cmds;
my $q_inst = PosdaDB::Queries->GetQueryInstance("FilesInSeriesForApplicationOfPrivateDisposition");
for my $patient_id (sort keys %Patients){
  for my $study_uid (sort keys %{$Patients{$patient_id}}){
    for my $series_uid (sort keys %{$Patients{$patient_id}->{$study_uid}}){
      my $dir = "$to_dir/$patient_id";
      unless(-d $dir){
        unless(mkdir $dir){
          $background->WriteToEmail("Can't mkdir $dir");
          $background->Finish;
          exit;
        }
      }
      $dir = "$dir/$study_uid";
      unless(-d $dir){
        unless(mkdir $dir){
          $background->WriteToEmail("Can't mkdir $dir");
          $background->Finish;
          exit;
        }
      }
      $dir = "$dir/$series_uid";
      unless(-d $dir){
        unless(mkdir $dir){
          $background->WriteToEmail("Can't mkdir $dir");
          $background->Finish;
          exit;
        }
      }
      $q_inst->RunQuery(sub {
        my($row) = @_;
        my $path = $row->[0];
        my $sop_instance_uid = $row->[1];
        my $modality = $row->[2];
        my $cmd = "ApplyPrivateDispositionUnconditionalDate.pl $path " .
          "\"$to_dir/$patient_id/" .
          "$study_uid/" .
          "$series_uid/$modality" . "_$sop_instance_uid.dcm\" " .
          "$uid_root $offset ";
        push @cmds, $cmd;
      }, sub{}, $series_uid);
    }
  }
}
my $num_commands = @cmds;
$background->WriteToEmail(`date`);
$background->WriteToEmail("about to execute $num_commands in 5 subshells\n");
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
$background->WriteToEmail(`date`);
$background->WriteToEmail("All subshells complete\n");
### Body of script
###################################################################
my $end = time;
my $duration = $end - $script_start_time;
$background->WriteToEmail( "finished conversion in $duration seconds\n");
$background->Finish;
