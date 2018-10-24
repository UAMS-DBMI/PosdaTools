#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
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

Uses the following queries (in addition to file_query_name):
  CreateSimplePhiScanRow(description, num_series, file_query_name)
  GetSimplePhiScanId()
  CreateSimpleSeriesScanInstance(scan_instance_id, series_instance_uid)
  GetSimpleSeriesScanId()
  GetSimpleElementSeen(tag, vr)
  CreateSimpleElementSeen(tag, vr)
  GetSimpleElementSeenIndex()
  GetSimpleValueSeen(value)
  CreateSimpleValueSeen(value)
  GetSimpleValueSeenId()
  CreateSimpleElementValueOccurance(element_seen_id, value_seen_id,
    series_scan_instance_id, phi_scan_instance_id)
  FinalizeSimpleSeriesScan(num_files, id)
  IncrementSimpleSeriesScanned(id)
  FinalizeSimpleScanInstance()  

Queries used to implement background processor protocol:
  CreateBackgroundSubprocess
  GetBackgroundSubprocessId
  AddBackgroundTimeAndRowsToBackgroundProcess
  AddBackgroundError 
  CreateBackgroundSubprocessParam
  CreateBackgroundInputLine
  AddCompletionTimeToBackgroundSubprocess
EOF
print "This script is obsolete.  Use \"BackgroundPrivateDispositions(.pl)\" instead\n";
exit;
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
my $q1 = PosdaDB::Queries->GetQueryInstance(
  "CreateBackgroundSubprocess");
$q1->RunQuery(sub{}, sub{},
  $invoc_id, $command, $child_pid, $notify);
my $q2 = PosdaDB::Queries->GetQueryInstance(
  "GetBackgroundSubprocessId");
my $bkgrnd_id;
$q2->RunQuery(sub{my($row) = @_;  $bkgrnd_id = $row->[0];}, sub{});
unless(defined $bkgrnd_id){
  my $error = "Error: unable to create row in background_subprocess";
  print "$error\n";
  die $error;
}
my $q3 = PosdaDB::Queries->GetQueryInstance(
  "CreateBackgroundSubprocessParam");
for my $i (0 .. $#ARGV){
  $q3->RunQuery(sub {}, sub {}, $bkgrnd_id, $i, $ARGV[$i]);
}
my $q4 = PosdaDB::Queries->GetQueryInstance(
  "CreateBackgroundInputLine");

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
  $q4->RunQuery(sub{}, sub{}, $bkgrnd_id, $num_lines, $line);
}
my $q5 = PosdaDB::Queries->GetQueryInstance(
  "AreVisibleFilesMarkedAsBadOrUnreviewedInSeries");
my $q6 = PosdaDB::Queries->GetQueryInstance(
  "IsThisSeriesNotVisuallyReviewed");
my $error = 0;
for my $series (@Series){
  $q5->RunQuery(sub {
  }, sub {}, $series);
  $q6->RunQuery(sub {
    my($row) = @_;
    print "Warning: series $series not submitted for visual review\n";
  }, sub {}, $series);
  $q6->RunQuery(sub{
    my($row) = @_;
    print "Error series $series has unreviewed or bad files\n";
    $error += 1;
  }, sub {}, $series);
}

if($error){
  print "Not forking background because of errors\n";
  exit;
}
my $num_series = @Series;
print "Found list of $num_series series to send\n" .
  "Forking background process\n";
print STDERR "Calling PosdaDB::Queries->reset_db_handles()\n";
PosdaDB::Queries->reset_db_handles();
print STDERR "Back from PosdaDB::Queries->reset_db_handles()\n";
close STDOUT;
close STDIN;
fork and exit;
my $grandchild_pid = $$;
print STDERR "Running in background, pid = $grandchild_pid\n";
my($add_time_rows_to_bkgrnd, $create_bgrnd_sub_param,
  $add_bgrnd_sub_error, $add_comp_to_bgrnd_sub);
eval {
  $add_bgrnd_sub_error = PosdaDB::Queries->GetQueryInstance(
    "AddErrorToBackgroundProcess");
};
if($@){
  die "############ Subprocess die-ing silently\n" .
      "Can't get query to record error:\n" .
      "\tCreateBackgroundSubprocessError\n" .
      "($@)\n" .
      "#######################################\n";
}
eval {
  $add_time_rows_to_bkgrnd = PosdaDB::Queries->GetQueryInstance(
    "AddBackgroundTimeAndRowsToBackgroundProcess");
  $add_comp_to_bgrnd_sub = PosdaDB::Queries->GetQueryInstance(
    "AddCompletionTimeToBackgroundProcess");
};
if($@){
  print STDERR "#######################################\n";
  print STDERR "Error: $@\n";
  print STDERR "#######################################\n";
  $add_bgrnd_sub_error->RunQuery(sub{},sub{},
    $@, $bkgrnd_id
  );
  die "Script errored with update to table ($@)";
}
print STDERR "Opening Mail\n";
unless(open EMAIL, "|mail -s \"Posda Job Complete\" $notify"){
  my $error = "can't open pipe ($!) to mail $notify";
  $add_bgrnd_sub_error->RunQuery(sub{},sub{},
    $error, $bkgrnd_id
  );
  die "Script errored with update to table ($@)";
}
print STDERR "Mail is open\n";
$add_time_rows_to_bkgrnd->RunQuery(sub {}, sub{},
  $num_lines, $grandchild_pid, $bkgrnd_id
);
my $date = `date`;
print EMAIL "$date\nStarting ApplyPrivateDispositions\n" .
  "To directory: $to_dir\n" .
  "background_subprocess_id: $bkgrnd_id\n";
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
print EMAIL `date`;
print EMAIL "about to execute $num_commands in 5 subshells\n";
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
print EMAIL "All commands queued\n";
close SCRIPT1;
close SCRIPT2;
close SCRIPT3;
close SCRIPT4;
close SCRIPT5;
print EMAIL `date`;
print "All subshells complete\n";
### Body of script
###################################################################
$add_comp_to_bgrnd_sub->RunQuery(sub{}, sub{}, $bkgrnd_id);
my $end = time;
my $duration = $end - $script_start_time;
print EMAIL "finished conversion in $duration seconds\n";
close EMAIL;
