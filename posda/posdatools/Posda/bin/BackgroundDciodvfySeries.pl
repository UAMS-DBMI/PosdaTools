#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = <<EOF;
PhiBackgroundDciodvfySeries.pl <id> <description> <type> <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  description - description of scan
  type - type of dciodvfy scan
    "one_per_series" - scan one file per serits
    "all_per_series" - scan all files in series
    "per_sop" - sops are SOP instances - one file per SOP
  notify - email address for completion notification

Expects a list of series_uids (or sop_instance_uids) on STDIN

Uses the following script to do most of the work:
  ProcessDciodvfyScan.pl <type> <uid> <scan_id>

Queries used to implement background processor protocol:
  CreateBackgroundSubprocess
  GetBackgroundSubprocessId
  AddBackgroundTimeAndRowsToBackgroundProcess
  AddBackgroundError 
  CreateBackgroundSubprocessParam
  CreateBackgroundInputLine
  AddCompletionTimeToBackgroundSubprocess
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}

my $child_pid = $$;
my $command = $0;
my $script_start_time = time;
unless($#ARGV == 3){
  print "$usage\n";
  die "######################## subprocess failed to start:\n" .
      "$usage\n" .
      "#####################################################\n";
}
my($invoc_id, $description, $type_of_unit, $notify) = @ARGV;
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
my $line_no = 0;
my @Series;
while(my $line = <STDIN>){
  $line_no += 1;
  chomp $line;
  push @Series, $line;
  $q4->RunQuery(sub{}, sub{}, $bkgrnd_id, $line_no, $line);
}
my $num_series = @Series;
my $num_lines = $num_series;
print "Found list of $num_series series to scan\n" .
  "Forking background process\n";
PosdaDB::Queries->reset_db_handles();
close STDOUT;
close STDIN;
fork and exit;
my $grandchild_pid = $$;
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
unless(open EMAIL, "|mail -s \"Posda Job Complete\" $notify"){
  my $error = "can't open pipe ($!) to mail $notify";
  $add_bgrnd_sub_error->RunQuery(sub{},sub{},
    $error, $bkgrnd_id
  );
  die "Script errored with update to table ($@)";
}
$add_time_rows_to_bkgrnd->RunQuery(sub {}, sub{},
  $num_lines, $grandchild_pid, $bkgrnd_id
);
my $date = `date`;
print EMAIL "$date\nStarting Simple PHI Scan\n" .
  "Description: $description\n" .
  "type: $type_of_unit\n" .
  "background_subprocess_id: $bkgrnd_id\n";
#######################################################################
### Body of script
my $create_scan = PosdaDB::Queries->GetQueryInstance(
  "CreateDciodvfyScanInstance");
my $get_scan_id = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyScanInstanceId");
my $update_inst = PosdaDB::Queries->GetQueryInstance(
  "SetDciodvfyScanInstanceNumScanned");
my $finalize_inst = PosdaDB::Queries->GetQueryInstance(
  "FinalizeDciodvfyScanInstance");
$create_scan->RunQuery(sub {}, sub {}, 
  $type_of_unit, $description, $num_series);
my $scan_id;
$get_scan_id->RunQuery(sub {
  my($row) = @_;
  $scan_id = $row->[0];
}, sub {});
my $num_scanned = 0;
for my $uid (@Series){
  my $cmd = "ProcessDciodvfyScan.pl $type_of_unit $uid $scan_id";
print EMAIL "command: $cmd\n";
  `$cmd`;
  $num_scanned += 1;
  $update_inst->RunQuery(sub {}, sub {},
    $num_scanned, $scan_id);
}
$finalize_inst->RunQuery(sub{}, sub {}, $scan_id);

### Body of script
###################################################################
$add_comp_to_bgrnd_sub->RunQuery(sub{}, sub{}, $bkgrnd_id);
my $end = time;
my $duration = $end - $script_start_time;
print EMAIL "finished scan\n" .
  "num scanned $num_scanned\n" .
  "duration $duration seconds\n";
print EMAIL "id of PHI scan: $scan_id\n";
close EMAIL;
