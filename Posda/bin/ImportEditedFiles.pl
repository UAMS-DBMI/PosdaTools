#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;

# TODO: It looks like the report_file_path is simply inserted into
# posda and returned in the email. This can be removed entirely, I think.
# The report will have already been loaded into posda from the previous command
# Possibly discuss with Bill, though
# So that's not entirely true - the ID of the imported file is used for
# InsertEditEventRow query. Talk to bill for sure, maybe we can write the
# input file.. or better yet, the ID of the spreadsheet that was uploaded
# to initiate this?
# Bill suggests coming up with some other way to get the file_id of the 
# "previous step". Maybe just a parameter? But then the previous step
# would need to return that ID? 


my $usage = <<EOF;
ImportEditedFiles.pl <bkgrnd_id> <report_file_id> <import_report_path> <comment> <notify>
or
ImportEditedFiles.pl -h

The script expects lines in the following format on STDIN:
<sop_instance_uid>&<from_digest>&<to_file>&<to_digest>&<status>

Assuming all of the parameters look good, all of the input lines are slurped
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
ImportEditedFiles.pl <bkgrnd_id> <report_file_id> <import_report_path> <comment> <notify>
or
ImportEditedFiles.pl -h
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 4){
  die "$usage\n";
}

my ($invoc_id, $edit_desc_file_id, $ImportReportPath, $EditComment, $Notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $Notify);

my %FilesToImport;
line:
while(my $line = <STDIN>){
  chomp $line;
  $background->LogInputLine($line);
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
print STDERR "#### should have just ended??\n";


$background->ForkAndExit;
$background->LogInputCount($num_sops);


my $start_time = time;
$background->WriteToEmail("Starting ImportEditedFiles.pl in background\n");
$background->WriteToEmail("Number of Files to Import: $num_sops\n");
my $import_error;

my $pid = $$;
my $ins_edit_event = Query("InsertEditEventRow");
my $get_edit_event_id = Query("GetCurrentEditEventRowId");
$ins_edit_event->RunQuery(sub {}, sub {},
  $edit_desc_file_id, $EditComment, $num_sops, $pid);
my $edit_event_id;
$get_edit_event_id->RunQuery(sub {
  my($row) = @_;
  $edit_event_id = $row->[0];
  }, sub { });
unless(defined $edit_event_id){
  $background->WriteToEmail("Failed to get edit_event_id\n");
  $background->WriteToEmail("Giving up\n");
  die "Can't create edit event";
}
$background->WriteToEmail("Created edit event: $edit_event_id\n");
$background->WriteToReport("From file digest,To file digest, Import Status\n");
unless(open HIDE, "|HideFilesWithStatus.pl $Notify ImportEditedFile"){
  $background->WriteToEmail("Couldn't open Pipe to HideFilesWithStatus.pl ($!)\n");
  $background->WriteToEmail("Giving up\n");
  die "Can't open HideFiles Pipe";
}
unless(open ADD, "|FileImportIntoPosdaWithEditEvent.pl $edit_event_id " . 
  "ImportEditedFile \"Edit Event\""
){
  $background->WriteToEmail("Couldn't open Pipe to FileImport ($!)\n");
  $background->WriteToEmail("Giving up\n");
  die "Can't open AddFiles Pipe";
}
my $get_file_id_and_visibility = Query("GetFileIdAndVisibilityByDigest");
my $create_edit_row = Query("CreateDicomFileEditRow");
my $inc_edits = Query("IncrementEditsDone");
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
    $background->WriteToEmail("Error: unable to get visibility:\n" .
      "\t digest: $from_dig\n" .
      "\t file_id: $file_id\n" .
      "\t ctp_file_id: $ctp_file_id\n" .
      "\t visibility: $visibility\n" .
      "\t sop: $sop\n");
    $background->WriteToEmail("aborting processing\n");
    die "Bad digest: $from_dig";
  }
  unless(defined $visibility) { $visibility = "<undef>" }
  print HIDE "$file_id&$visibility\n";
  print ADD "$to_file\n";
  $background->WriteToReport("$from_dig,$to_dig,\"File replaced\"\n");
  $background->WriteToEmail("file_id: $file_id replaced by $to_file\n");
  $create_edit_row->RunQuery(sub{}, sub{}, $edit_event_id, $from_dig, $to_dig);
  $inc_edits->RunQuery(sub{}, sub{}, $edit_event_id);
}
my $loop_complete_time = time;
my $elapsed_till_end_of_loop = $loop_complete_time - $start_time;
$background->WriteToEmail("Loop complete after $elapsed_till_end_of_loop seconds\n");
close ADD;
close HIDE;
my $close_time = time;
my $close_elapsed_time = $close_time - $loop_complete_time;
my $total_elapsed_time = $close_time - $start_time;
$background->WriteToEmail("Subprocesses took $close_elapsed_time to complete\n");
$background->WriteToEmail("Total elapsed time so far: $total_elapsed_time\n");
my $get_adverse = Query("GetAdverseFileEventsByEditEventId");
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
$background->WriteToEmail("$adv_event_count adverse file events on import\n");
if($adv_event_count > 0){
  $background->WriteToReport("\n\n\n\"Adverse Events\"\n" .
  "\"file_id\",\"event description\",\"when\"\n");
  for my $i (
    sort { $Adverse{$a}->{when} cmp $Adverse{$b}->{when} } keys %Adverse
  ){
    $background->WriteToReport("$Adverse{$i}->{file_id},\"$Adverse{$i}->{event_descr}\"," .
      "\"$Adverse{$i}->{when}\"\n");
  }
}
my $final_time = time;
my $total_elapsed = $final_time - $start_time;
my $close_event = Query("CloseDicomFileEditEvent");
$close_event->RunQuery(sub {}, sub {},
  $edit_desc_file_id, $Notify, $edit_event_id);

my $link = $background->GetReportDownloadableURL;
$background->WriteToEmail("Report URL: $link\n");
$background->LogCompletionTime;
