#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::BackgroundProcess;
my $usage = <<EOF;
BackgroundPrivateDispositions.pl <id> <to_dir> <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  writes result into <to_dir>
  email sent to <notify>

<uid_root> and <offset> are obtained from patient_mapping table
  UID's not hashed if they begin with <uid_root>
  date's always offset with offset (days)

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
unless($#ARGV == 2){
  print "$usage\n";
  die "######################## subprocess failed to start:\n" .
      "$usage\n" .
      "#####################################################\n";
}
my($invoc_id, $to_dir, $notify) = @ARGV;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my %Patients;
my %PatientMapping;
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
my $q1 = PosdaDB::Queries->GetQueryInstance(
  "PrivateTagsWhichArentMarked");
my $error = 0;
my @new_tags;
$q1->RunQuery(sub{
  my($row) = @_;
  my($id, $ele_sig, $vr, $name, $disp) = @$row;
  push(@new_tags, [$id, $ele_sig, $vr, $name, $disp]);
}, sub {});
if(@new_tags > 0){
  print "Error: there are new private tags which have no disposition\n";
  print "<table border><tr><th>id</th><th>tag</th>" .
    "<th>vr</th><th>name</th><th>disp</th></tr>";
  for my $i (@new_tags){
    print "<tr>";
    for my $v (@$i){
      print "<td>";
      if(defined $v) { print "$v" } else {print "&lt;undef&gt;" }
      print "</td>";
    }
    print "</tr>";
  }
  print "</table>";
  print "Not forking background because of errors\n";
  exit;
}
my @dispositions_needed;
my $q2 = PosdaDB::Queries->GetQueryInstance(
  "DistinctDispositionsNeededSimple");
$q2->RunQuery(sub {
  my($row) = @_;
  my($id, $ele_sig, $vr, $name) = @$row;
  push @dispositions_needed, [$id, $ele_sig, $vr, $name];
}, sub {});
if(@dispositions_needed > 0){
  print "Error: the following private tags have no disposition\n";
  print "<table border><tr><th>id</th><th>tag</th>" .
    "<th>vr</th><th>name</th></tr>";
  for my $i (@dispositions_needed){
    print "<tr>";
    for my $v (@$i){
      print "<td>";
      if(defined $v) { print "$v" } else {print "&lt;undef&gt;" }
      print "</td>";
    }
    print "</tr>";
  }
  print "</table>";
  print "Not forking background because of errors\n";
  exit;
}
my $q3 = PosdaDB::Queries->GetQueryInstance(
  "GetPatientMappingByPatientId");
pat:
for my $pat (keys %Patients){
  my $error_seen = 0;
  $q3->RunQuery(sub{
    my($row) = @_;
    my($from_patient_id,
      $to_patient_id,
      $to_patient_name,
      $collection_name,
      $site_name,
      $batch_number,
      $uid_root,
      $diagnosis_date,
      $baseline_date,
      $date_shift,
      $computed_shift) = @$row;
    if(exists $PatientMapping{$to_patient_id}){
      unless($error_seen){
        print "There is more than one mapping for patient_id: $pat\n";
      }
      $error += 1;
      $error_seen = 1;
      return;
    }
    unless($computed_shift =~ /^([^\s]+)\s*days$/){
      unless($error_seen){
        print "Now computed shift for patient_id: $pat\n";
      }
      $error += 1;
      $error_seen = 1;
      return;
    }
    my $offset = $1;
    $PatientMapping{$pat}->{uid_root} = $uid_root;
    $PatientMapping{$pat}->{offset} = $offset;
  }, sub {}, $pat);
}
my $q5 = PosdaDB::Queries->GetQueryInstance(
  "AreVisibleFilesMarkedAsBadOrUnreviewedInSeries");
my $q6 = PosdaDB::Queries->GetQueryInstance(
  "IsThisSeriesNotVisuallyReviewed");
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
  my $offset = $PatientMapping{$patient_id}->{offset};
  my $uid_root = $PatientMapping{$patient_id}->{uid_root};
  $background->WriteToEmail("Patient: $patient_id\n");
  for my $study_uid (sort keys %{$Patients{$patient_id}}){
    $background->WriteToEmail("Study $study_uid\n");
    for my $series_uid (sort keys %{$Patients{$patient_id}->{$study_uid}}){
      $background->WriteToEmail("Series \"$series_uid\"\n");
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
      my $num_files = 0;
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
        $num_files += 1;
      }, sub{}, $series_uid);
      $background->WriteToEmail("Num_files $num_files\n");
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
#  print STDERR "1. Running cmd: $cmd\n";
 print SCRIPT1 "$cmd\n";
  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
# print STDERR "2. Running cmd: $cmd\n";
 print SCRIPT2 "$cmd\n";
  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
# print STDERR "3. Running cmd: $cmd\n";
 print SCRIPT3 "$cmd\n";
  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
# print STDERR "4. Running cmd: $cmd\n";
 print SCRIPT4 "$cmd\n";
  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
# print STDERR "5. Running cmd: $cmd\n";
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
