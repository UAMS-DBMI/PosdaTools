#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::DownloadableFile;
use Debug;
my $usage = <<EOF;
PhiBackgroundDciodvfySeriesReport.pl <id> <description> <scan_id> <report_file_path> <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  description - description of scan
  scan_id - id of scan
  report_file_path - path to where report file should be written
  notify - email address for completion notification

Expects a list of series_uids on STDIN

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
unless($#ARGV == 4){
  print "$usage\n";
  die "######################## subprocess failed to start:\n" .
      "$usage\n" .
      "#####################################################\n";
}
my($invoc_id, $description, $dciodvfy_scan_id, $report_path, $notify) = @ARGV;
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
unless(open REPORT, ">$report_path"){
  my $error = "can't open ($!) $report_path for writing";
  $add_bgrnd_sub_error->RunQuery(sub{},sub{},
    $error, $bkgrnd_id
  );
  print EMAIL "Error: $error\n";
  die $error;
}
$add_time_rows_to_bkgrnd->RunQuery(sub {}, sub{},
  $num_lines, $grandchild_pid, $bkgrnd_id
);
my $date = `date`;
#my($invoc_id, $description, $dciodvfy_scan_id, $report_path, $notify) = @ARGV;
print EMAIL "$date\nStarting Dciodvfy Series Report\n" .
  "Description: $description\n" .
  "dciodvfy_scan_id: $dciodvfy_scan_id\n" .
  "report_path: $report_path\n" .
  "background_subprocess_id: $bkgrnd_id\n";
#######################################################################
### Body of script
my $report_id;
my %SeriesErrorClasses;
my $get_error_ids = PosdaDB::Queries->GetQueryInstance(
  "DciodvfyErrorIdsBySeriesAndScanInstance"
);
my $get_error_string= PosdaDB::Queries->GetQueryInstance(
  "DciodvfyErrorsStringByErrorId"
);
for my $series(@Series){
  my $sig = "";
  $get_error_ids->RunQuery(sub {
    my($row) = @_;
    my $id = $row->[0];
    if($sig) { $sig .= "-$id";
    } else { $sig = $id }
  }, sub {}, $dciodvfy_scan_id, $series);
  $SeriesErrorClasses{$sig}->{$series} = 1;
}
print EMAIL "This is a test version of this script\n";
my $dbg = sub { print EMAIL @_ };
print EMAIL "SeriesErrorClasses: ";
Debug::GenPrint($dbg, \%SeriesErrorClasses, 1);
print EMAIL "\n";
print REPORT "Series,Errors\n";
my $report_rows = 0;
for my $error_str (sort keys %SeriesErrorClasses){
  my @ids = split(/-/, $error_str);
  my @series = sort keys %{$SeriesErrorClasses{$error_str}};
  print REPORT '"';
  for my $i (0 .. $#series){
    print REPORT "$series[$i]";
    unless($i == $#series) {print REPORT "\n"}
  }
  print REPORT '","';
  if($#ids >= 0){
    for my $i (0 .. $#ids){
      my $string;
      $get_error_string->RunQuery(sub {
        my($row) = @_;
        $string = $row->[0];
      }, sub {}, $ids[$i]);
      my $converted_string = ConvertString($string);
      print REPORT "$converted_string";
      unless($i == $#ids) { print REPORT "\n" }
    }
  } else {
    print REPORT 'none';
  }
  print REPORT '"' . "\r\n";
  $report_rows += 1;
}
close REPORT;
my $report_file_id;
if(open GETID, "ImportSingleFileIntoPosdaAndReturnId.pl \"$report_path\" \"Script: BackgroundDciodvfySeriesReport.pl\"|"){
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
print EMAIL "finished scan\n" .
  "duration $duration seconds\n";
print EMAIL "id of report: $report_file_id\n";
exit;
sub ConvertString{
  my($string) = @_;
  my($dciodvfy_error_id, $error_type,
    $error_tag, $error_value,
    $error_subtype, $error_module,
    $error_reason, $error_index,
    $error_text) = split(/\|/, $string);
  if($error_type eq 'Uncategorized'){
    $error_text =~ s/"/""/g;
    return $error_text;
  } elsif($error_type eq 'MayNotBePresent'){
    return "Tag: $error_tag : May not be present because $error_reason";
  } elsif($error_type eq 'UnrecognizedEnumeratedValue'){
    return "Tag: $error_tag : has an unrecognized enumerated value ($error_value) in index $error_index";
  } elsif($error_type eq 'AttributeSpecificError'){
    return "Tag: $error_tag : $error_subtype";
  } elsif($error_type eq 'AttributeSpecificErrorWithIndex'){
    return "Tag: $error_tag : $error_subtype for index $error_index";
  } elsif($error_type eq 'MissingAttributes'){
    return "Tag: $error_tag : Missing Tag : $error_subtype : $error_module";
  } elsif($error_type eq 'BadValueMultiplicity'){
    return "Tag: $error_tag : has bad value multiplicity : $error_value vs $error_index : per $error_module";
  } elsif($error_type eq 'CantBeNegative'){
    return "Tag: $error_tag : has illegal negative value: $error_value\n";
  } elsif($error_type eq 'AttributesPresentWhenConditionNotSatisfied'){ 
    return "Tag: $error_tag : is conditional and is present when condition not satisfied : per $error_module module";
  } elsif($error_type eq 'InvalidElementLength'){
    return "Tag: $error_tag : has value ($error_value) with invalid length ($error_index vs $error_reason)";                     
  } elsif($error_type eq 'UnrecognizedPublicTag'){
    return "Unrecognized public tag: $error_tag";
  } elsif($error_type eq 'InvalidValueForVr'){
    return "Tag: $error_tag : Invalid Value for VR : $error_value : $error_reason : $error_subtype";
  } else {
    return $string;
  }
  return $string;
}

