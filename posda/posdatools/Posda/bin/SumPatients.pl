#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::DownloadableFile;
my $usage = <<EOF;
SumPatients.pl <id> <report_path> <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  report_path - file name of report_file

Expects the following list on <STDIN>
  <id>&<study>&<series>&<num files>
Input should be sorted by <id>
Adds a total column with total by id when id changes

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
unless($#ARGV == 2){
  print "$usage\n";
  die "######################## subprocess failed to start:\n" .
      "$usage\n" .
      "#####################################################\n";
}
my($invoc_id, $report_path, $notify) = @ARGV;
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

my $num_lines = 0;
my @Rows;
while(my $line = <STDIN>){
  chomp $line;
  my($id, $study, $series, $num_files) =
    split /&/, $line;
  push(@Rows, [$id, $study, $series, $num_files]);
}

my $num_rows = @Rows;
print "Found list of $num_rows rows to total\n" .
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
print EMAIL "$date\nRunning /SumPatients.pl\n" .
  "Report Path: $report_path\n" .
  "background_subprocess_id: $bkgrnd_id\n";
unless(open REPORT, ">$report_path"){
  print EMAIL "Unable to open report_file: $report_path\n";
  exit;
}
#######################################################################
### Body of script
print REPORT "\"id\",\"study\",\"series\",\"num files\",\"subtotal\"\n";
my $report_file_id;
my $sub_total = 0;
my $current_id;
my %SubTotals;
my $last_row;
# row = [$id, $study, $series, $num_files]
my $report_rows = 0;;
for my $row (@Rows){
  unless(defined $current_id) {
    $current_id = $row->[0];
  }
  if($current_id eq $row->[0]){
    $sub_total += $row->[3];
    print REPORT "\"$last_row->[0]\",\"$last_row->[1]\"," .
      "\"$last_row->[2]\",\"$last_row->[3]\",\"\"\n";
    $last_row = $row;
  } else {
    $SubTotals{$current_id} = $sub_total;
    print REPORT "\"$last_row->[0]\",\"$last_row->[1]\"," .
      "\"$last_row->[2]\",\"$last_row->[3]\",\"$sub_total\"\n";
    $sub_total = $row->[3];
    $last_row = $row;
    $current_id = $row->[0];
  }
  $report_rows += 1;
}
print REPORT "\"$last_row->[0]\",\"$last_row->[1]\"," .
  "\"$last_row->[2]\",\"$last_row->[3]\",\"$sub_total\"\n";
$report_rows += 1;
print REPORT "\n\n\n\"id\",\"total\"\n";
for my $id (sort keys %SubTotals){
  print REPORT "\"$id\",\"$SubTotals{$id}\"\n";
$report_rows += 1;
}
close REPORT;
if(open GETID, "ImportSingleFileIntoPosdaAndReturnId.pl \"$report_path\" \"Script: Posda/bin/SumPatients.pl\"|"){
  while (my $line = <GETID>){
    chomp $line;
    if($line =~ /^File id:\s*(\d+)\s*$/){
      $report_file_id = $1;
    }
  }
  print EMAIL "Report file $report_path\n" .
    "\timported into Posda with id: $report_file_id\n";
  my $insert_report = PosdaDB::Queries->GetQueryInstance(
    "RecordReportInsertion");
  $insert_report->RunQuery(sub {}, sub {},
    $report_file_id, $report_rows, $bkgrnd_id);
  my $url = Posda::DownloadableFile::make_csv($report_file_id);
  print STDERR  "Download url: $url\n";
  print EMAIL "Download url: $url\n";
} else {
  print EMAIL "Unable to import report_file ($report_path) into Posda\n";
}

### Body of script
###################################################################
$add_comp_to_bgrnd_sub->RunQuery(sub{}, sub{}, $bkgrnd_id);
my $end = time;
my $duration = $end - $script_start_time;
print EMAIL "finished conversion in $duration seconds\n";
close EMAIL;
