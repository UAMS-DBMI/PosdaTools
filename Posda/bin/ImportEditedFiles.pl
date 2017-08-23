#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Digest::MD5;
my $usage = <<EOF;
ImportEditedFiles.pl <report_file_path> <import_report_path> <comment> <notify>
or
ImportEditedFiles.pl -h

The script expects lines in the following format on STDIN:
<sop_instance_uid>&<from_digest>&<to_file>&<to_digest>&<status>

Assuming all of the parameters look good,  all of the input lines are slurped
and counted.  Then a background process is forked, and the status is returned
to DbIf. All processing is done in the background process.


<report_file_path> is a path to the file which specified the edits performed.
It is stored in the posda_files Database, and the file_id retrieved, using 
the script "ImportSingleFileIntoPosdaAndReturnId.pl".

A new row is then created in the dicom_edit_event table, initialized with
  edit_desc_file = file_id of <report_file>,
  edit_comment = <comment>,
  time_started = <now>,
  num_files = count of lines in input which specify edits (status = "OK"), and
  process_id = the pid of this process.

A number of pipes are opened to subprocesses:
  REPORT is the file handle of a a file created at <import_report_path>. A
    csv format file will be written to this pipe as the data is processed. In
    the beginning a header is written to the file with the following columns:
      - From file_digest
      - To file_digest
      - Import Status
  MAIL is the file handle of a pipe to:
    'mail -s "Posda File Edit Report" <notify>'
    An initial message is written to the file recording the file_id of the
    report_file, and the current time.
  HIDE is a pipe to
    'HideFilesWithStatus.pl <notify> "Import Edited File"'
  ADD is a pipe to
    'FileImportIntoPosdaWithEditEvent.pl <id> "EditResults" "Edit Event"'

For every file line processed, the following actions are taken:
  - The from_file's id and current visiblity are retrieved from the posda_files
    database (using its digest) and the file is hidden using the HIDE pipe.
    If the file is not found in the posda_files_database, then an error
    report is written to REPORT, a message is written to MAIL, and processing
    is aborted.
  - The to_file is imported into the database using ADD. The underlying
    script will create an adverse_file_event row if anything goes wrong.
  - A row is created in the dicom_file_edit table with the id of the current
    dicom_edit_event row (created at beginning of procesing), the digest of the
    from_file and the digest of the to_file.
  - A row is written to REPORT.
  - The edits_done column in the current dicom_edit_event row is incremented.
When processing is done:
  - Write message to MAIL with the current time indicating that processing
    complete and synchronization with sub-processes is taking place.
  - Close HIDE, and ADD.  These close operations will not complete until the
    subprocesses have terminated.
  - query the posda_file database adverse_file_event table to see if any
    adverse_file_events are related to this dicom_edit_event.  If there are,
    then:
    - Add them to the REPORT, and
    - Indicate the number of adverse events in MAIL
  - Write a message, with the current time to MAIL.  The wait time for 
    the close complete will give us an indicator of how backed up the
    processing gets.
  - REPORT is closed, the corresponding file is stored in the posda_files
    database, and its id is retrieved
  - A print to MAIL indicates that the import is complete, with a count of
    the number of files imported, the current time, and the duration.
  - MAIL is closed (sending the file)
  - The following fields are updated in the current dicom_edit_event row:
    - time_completed (now)
    - report_file (file_id)
    - notification_sent (email address)
Then we are finally done, and can exit.

Queries used:
  - InsertEditEventRow(report_file_id, comment, num_files, pid)
  - GetCurrentEditEventRowId()
  - GetFileIdAndVisibilityByDigest(digest)
  - CreateDicomFileEditRow(edit_event_id, from_digest, to_digest)
  - IncrementEditsDone(edit_event_id)
  - GetAdverseFileEventsByEditEventId(dicom_edit_event_id)
  - CloseDicomFileEditEvent(report_file_id, notify, dicom_edit_event_id)
  - InsertAdverseFileEvent(file_id, event_description)
  - GetCurrentAdverseFileEventId()
  - LinkAFEtoEditEvent(adverse_file_event_id, dicom_edit_event_id)

Sub Process Scripts Required:
  - HideFilesWithStatus.pl
  - FileImportIntoPosdaWithEditEvent.pl
  - ImportSingleFileIntoPosdaAndReturnId.pl
EOF
my $short_usage = <<EOF;
ImportEditedFiles.pl <report_file_path> <import_report_path> <comment> <notify>
or
ImportEditedFiles.pl -h
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  die "$usage\n";
}
my $ReportFilePath = $ARGV[0];
unless(-f $ReportFilePath) { die "Not a file: $ReportFilePath" };
my $ImportReportPath = $ARGV[1];
my $EditComment = $ARGV[2];
my $Notify = $ARGV[3];
my %FilesToImport;
line:
while(my $line = <STDIN>){
  chomp $line;
  my($sop_inst, $from_dig, $to_file, $to_dig, $status) = split /&/, $line;
  line:
  unless(
    defined($sop_inst) && $sop_inst ne "" &&
    defined($from_dig) && $from_dig ne "" &&
    defined($to_dig) && $to_dig ne "" &&
    defined($to_file) && -f $to_file &&
    defined($status) && $status eq "OK"
  ){
    print "Problem with line: \"$line\"\n";
    next line; }
  my $ctx = Digest::MD5->new;
  open FILE, "<$to_file";
  $ctx->addfile(\*FILE);
  close FILE;
  my $dig = $ctx->hexdigest;
  unless($dig = $to_dig){
    print "Error: $to_file has non-matching digest:\n" .
      "   $dig (computed)\n" .
      "vs $to_dig (supplied)\n";
    die "bad input";
  }
  if(exists $FilesToImport{$sop_inst}){
    print "Error: SOP ($sop_inst) appears twice in list\n";
    die "Dup Sops";
  }
  if($from_dig eq $to_dig){
    print "Sop: $sop_inst unchanged\n";
    next line;
  }
  $FilesToImport{$sop_inst} = {
    from_dig => $from_dig,
    to_dig => $to_dig,
    to_file => $to_file,
  };
}
my $num_sops = keys %FilesToImport;
print "Number of files to import: $num_sops\n";
print "Entering background\n";
fork and exit;
close STDOUT;
close STDIN;
open EMAIL, "|mail -s \"Posda File Edit Complete\" $Notify" or die
  "can't open pipe ($!) to mail $Notify";
my $start_time = time;
print EMAIL "Starting ImportEditedFiles.pl in background\n";
print EMAIL "Number of Files to Import: $num_sops\n";
open IMPORT, "ImportSingleFileIntoPosdaAndReturnId.pl \"$ReportFilePath\" " .
  "\"Import of edit file in ImportEditedFiles.pl\"|";
my($import_file_id, $import_error);
while(my $line = <IMPORT>){
  chomp $line;
print STDERR "Line: $line\n";
  if($line =~ /^File id:\s*(.*)\s*$/){
    $import_file_id = $1;
  }
  if($line =~ /^Error:\s(.*)$/){
    $import_error = $1;
  }
}
unless(defined $import_file_id){
  print EMAIL "Failed to get file_id for report_file_path ($ReportFilePath)\n";
  if(defined $import_error){
    print EMAIL "Error: $import_error\n";
  }
  print EMAIL "Giving up\n";
  die "Can't insert $ReportFilePath";
}
my $pid = $$;
print EMAIL "File id of edit specification $import_file_id\n";
my $ins_edit_event = PosdaDB::Queries->GetQueryInstance("InsertEditEventRow");
my $get_edit_event_id = PosdaDB::Queries->GetQueryInstance(
  "GetCurrentEditEventRowId");
$ins_edit_event->RunQuery(sub {}, sub {},
  $import_file_id, $EditComment, $num_sops, $pid);
my $edit_event_id;
$get_edit_event_id->RunQuery(sub {
  my($row) = @_;
  $edit_event_id = $row->[0];
  }, sub { });
unless(defined $edit_event_id){
  print EMAIL "Failed to get edit_event_id\n";
  print EMAIL "Giving up\n";
  die "Can't create edit event";
}
print EMAIL "Created edit event: $edit_event_id\n";
unless(open REPORT, ">$ImportReportPath"){
  print EMAIL "Couldn't open Report File: $ImportReportPath\n";
  print EMAIL "Giving up\n";
  die "Can't open $ImportReportPath";
}
print REPORT "From file digest,To file digest, Import Status\n";
unless(open HIDE, "|HideFilesWithStatus.pl $Notify ImportEditedFile"){
  print EMAIL "Couldn't open Pipe to HideFilesWithStatus.pl ($!)\n";
  print EMAIL "Giving up\n";
  die "Can't open HideFiles Pipe";
}
unless(open ADD, "|FileImportIntoPosdaWithEditEvent.pl $edit_event_id " . 
  "ImportEditedFile \"Edit Event\""
){
  print EMAIL "Couldn't open Pipe to FileImport ($!)\n";
  print EMAIL "Giving up\n";
  die "Can't open AddFiles Pipe";
}
my $get_file_id_and_visibility = PosdaDB::Queries->GetQueryInstance(
  "GetFileIdAndVisibilityByDigest");
my $create_edit_row = PosdaDB::Queries->GetQueryInstance(
  "CreateDicomFileEditRow");
my $inc_edits = PosdaDB::Queries->GetQueryInstance(
  "IncrementEditsDone");
for my $sop(sort keys %FilesToImport){
  my $from_dig = $FilesToImport{$sop}->{from_dig};
  my $to_dig = $FilesToImport{$sop}->{to_dig};
  my $to_file = $FilesToImport{$sop}->{to_file};
  my ($file_id, $ctp_file_id, $visibility);
  $get_file_id_and_visibility->RunQuery(sub {
    my($row) = @_;
    $file_id = $row->[0];
    $ctp_file_id = $row->[1];
    $visibility = $row->[2];
  }, sub {}, $from_dig);
  unless(
    defined($file_id) &&
    defined($ctp_file_id) &&
    $ctp_file_id == $file_id
  ){
    unless(defined $file_id) { $file_id = "<undef>" }
    unless(defined $ctp_file_id) { $ctp_file_id = "<undef>" }
    print EMAIL "Error: unable to get visibility:\n" .
      "\t digest: $from_dig\n" .
      "\t file_id: $file_id\n" .
      "\t ctp_file_id: $ctp_file_id\n" .
      "\t visibility: $visibility\n" .
      "\t sop: $sop\n";
    print EMAIL "aborting processing\n";
    die "Bad digest: $from_dig";
  }
  unless(defined $visibility) { $visibility = "<undef>" }
  print HIDE "$file_id&$visibility\n";
  print ADD "$to_file\n";
  print REPORT "$from_dig,$to_dig,\"File replaced\"\n";
  print EMAIL "file_id: $file_id replaced by $to_file\n";
  $create_edit_row->RunQuery(sub{}, sub{}, $edit_event_id, $from_dig, $to_dig);
  $inc_edits->RunQuery(sub{}, sub{}, $edit_event_id);
}
my $loop_complete_time = time;
my $elapsed_till_end_of_loop = $loop_complete_time - $start_time;
print EMAIL "Loop complete after $elapsed_till_end_of_loop seconds\n";
close ADD;
close HIDE;
my $close_time = time;
my $close_elapsed_time = $close_time - $loop_complete_time;
my $total_elapsed_time = $close_time - $start_time;
print EMAIL "Subprocesses took $close_elapsed_time to complete\n";
print EMAIL "Total elapsed time so far: $total_elapsed_time\n";
my $get_adverse = PosdaDB::Queries->GetQueryInstance(
  "GetAdverseFileEventsByEditEventId");
my %Adverse;
$get_adverse->RunQuery(sub{
  my($row) = @_;
    $Adverse{$row->[0]} = {
      file_id => $row->[1],
      event_descr => $row->[2],
      when => $row->[3],
    };
  }, sub {},
  $edit_event_id
);
my $adv_event_count = keys %Adverse;
  print EMAIL "$adv_event_count adverse file events on import\n";
if($adv_event_count > 0){
  print REPORT "\n\n\n\"Adverse Events\"\n" .
  "\"file_id\",\"event description\",\"when\"\n";
  for my $i (
    sort { $Adverse{$a}->{when} cmp $Adverse{$b}->{when} } keys %Adverse
  ){
    print REPORT "$Adverse{$i}->{file_id},\"$Adverse{$i}->{event_descr}\"," .
      "\"$Adverse{$i}->{when}\"\n";
  }
}
close REPORT;
unless(open IMPORT, 
  "ImportSingleFileIntoPosdaAndReturnId.pl \"$ImportReportPath\" " .
  "\"Edit Report file for edit_id: $edit_event_id\"|"
){
  print EMAIL "Failed to import report file into Posda";
  die "Quitting after all this\n";
  die "Failed to import Report";
}
my $report_file_id;
while(my $line = <IMPORT>){
  chomp $line;
  if($line =~ /^File id:\s*(.*)\s*$/){
    $report_file_id = $1;
  }
  if($line =~ /^Error:\s*(.*)$/){
    $import_error = $1;
  }
}
unless(defined $report_file_id){
  print EMAIL "Failed to get file_id for report file\n";
  if(defined $import_error){
    print EMAIL "Import Error: $import_error\n";
  }
  print EMAIL "Giving up after all this\n";
  die "Couldn't get id of report file";
}
my $final_time = time;
my $total_elapsed = $final_time - $start_time;
print EMAIL "Report File Id: $report_file_id\n" .
  "Total elapsed seconds: $total_elapsed\n";
close EMAIL;
my $close_event = PosdaDB::Queries->GetQueryInstance(
  "CloseDicomFileEditEvent");
$close_event->RunQuery(sub {}, sub {},
  $report_file_id, $Notify, $edit_event_id);
