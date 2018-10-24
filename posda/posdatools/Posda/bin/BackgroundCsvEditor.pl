#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::UUID;
use Posda::DownloadableFile; use Dispatch::Select;
use Dispatch::EventHandler;
use Dispatch::LineReader;
use Digest::MD5;
use FileHandle;
use Storable qw( store retrieve fd_retrieve store_fd );
use Data::UUID;
our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}

use Debug;
my $dbg = sub { print STDERR @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
BackgroundCsvEditor.pl <?bkgrnd_id?> <edit_desciption> <notify>
or
BackgroundCsvEditor.pl -h
Expects lines of the form:
<file_id>&<op>&<path>&<val1>&<val2>&<val3>

Lines specify the following things:
 - file edits:
   An line with a value in <file_id> specifies a file to be edited.
   Such a line is not allowed to have anything in the <operation>, <tag>,
   <val1>, <val2>, or <val3> fields.  Generally, there will be some lines with values
   in <file_id> followed by some lines with values in these other
   <file_id>.  The edits specified in lines following these series specifications
   are specified in lines which have values in for <operation> and <tag>, and 
   may also have values in <val1> and <val2> (if the operation has parameters).
   The first line with a value in series_instance_uid following a list of 
   operations resets the list of series (e.g.):
     <file1>
     <file2>
               <op1> <path1>
               <op2> <path2>
     <file3>
     <file4>
               <op3> <path3>

      <op1> <path1> and <op2> <tag2> are applied to <file1> and <file2>
      <op3> <path3> is applied to <file3> and <file4>
  
Paths are specified in as follows
  [<row>][<col]

The contents of the fields <path>, <val1>, <val2>, and <vale2> may by enclosed in 
  "meta-quotes" (i.e. "<(0010,0010)>" for "(0010,0010)".  This is to prevent
  Excel from doing unnatural things to the values contained within.  If you
  want to specify a value which is actually includes meta-quotes, you have
  to double up the metaquotes. e.g."<<placeholder>>".  This script will strip
  only one level of metaquotes. caveat usor.
  Further complicating this, is an additional bit of extradorinary Excel
  madness which causes it to be (sometimes) almost impossible to delete a
  leading single quote in a cell. (I have no idea why or how they implemented
  this, but it must have been hard).
  So sometimes, metaquotes effectively look like "'<[0001][0001]>".
  A lone single quote before the left metaquote will be deleted along with
  the metaquotes.

Edited files will be stored underneath the specified \$ENV{POSDA_CACHE_ROOT} in the 
following hierarchy:
  <posda_cache_root>/<uuid>/<file_id>_edited.dcm

where "<posda_cache_root>" is the value in the environment variable POSDA_CACHE_ROOT,
"<uuid>" is a uuid generated for a temp directory, and "<file_id>" is the 
"from" file_id (in posda).
Again caveat usor.

As in all things, if you don't know what you are doing, you should:
  1) Ask yourself why you are doing it, or
  2) Ask someone to help, so you have some idea what you're doing, and
  3) Be very careful doing it.
I'm not sure about the whether the above is ((1 or 2) and 3) or 
  (1 or (2 and 3)) or whether it matters.

On the other hand, this script can't do a lot of damage, all it does is create
new files in the <posda_cache_root> directory.  
Edit operations currently supported:
  insert_and_map_id(<path>, <id_to_map>)
  fix_and_map_id(<path>, <id_to_map>)
  map_id(<path>) 
  fix_and_map_date(<path>, <new_date_yyyy/mm/dd>)
  map_date(<path>) should contain date in yyyy/mm/dd format
  delete_path(<path>)
  hash_unhashed_uid(<path>, <uid_root>);
  set_and_map_id(<path>, <id_to_map>)
  shift_date_time(<path>) should contain date in yyyy/mm/dd format
  shift_date_yyyy-mm-dd(<path>)
  delete_value(<path>)
  shift_date_mm-dd-yy(<path>)
  set_value(<path>,<value)

This script uses the "NewSubprocessCsvEditor.pl" as a subprocess to apply the
edits in parallel to individual files.

Maintainers:
Be careful that the version of this file is compatable with the version of
"NewSubprocessCsvEditor.pl".  Why would it not be?  If you have changed one but
not the other...
EOF
#Inputs will be parsed into these data structures
my %Files;
# $SopsToEdit = {
#   <file> => {
#     from_file => <from_file>,
#     to_file => <to_file>,
#     edits => [
#       {
#         op => <op>,
#         path => <path>,
#         value1 => <value1>,
#         value2 => <value2>
#         value3 => <value3>
#       },
#       ...
#     ]
#   },
#   ...
# };
#

#############################
## This code process parameters
##
#
#

if($#ARGV == 0) { die "$usage\n\n" }
if($#ARGV != 2){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $description, $notify) = @ARGV;


#############################
## This code parses the input and populates the hashes
## %SopsToEdit and %UidMapping
#
my $SupportedEdits = {
  insert_and_map_id => 1,
  fix_and_map_id => 1,
  map_id => 2,
  fix_and_map_date => 3,
  map_date => 4,
  delete_path =>5,
  hash_unhashed_uid => 6,
  map_id => 7,
  set_and_map_id => 8,
  shift_date_time => 9,
  "shift_date_yyyy-mm-dd" => 10,
  delete_value => 11,
  "shift_date_mm-dd-yy" => 12,
  set_value => 13,
};


my $last_line_was_file = 0;
my $last_line_was_edit = 0;
my $accumulating_files = [];
my $current_files = [];
my $accumulating_edits = [];
my %EditsByFile;
line:
while(my $line = <STDIN>){
  chomp $line;
  my($file_id, $op, $path, $v1, $v2, $v3) =
    split(/&/, $line);
  if($file_id){
    if($op) {
      print "Error: operation ($op) on same line as file ($file_id)\n";
      exit;
    }
    if($last_line_was_edit){
      ProcessEndOfEdits();
    }
    push @$accumulating_files, $file_id;
    $last_line_was_file = 1;
    next line;
  }
  if($op){
    if($last_line_was_file) {
      $current_files = $accumulating_files;
      $accumulating_files = [];
      unless($#{$current_files} >= 0){
        print "Error: operation($op) applies to no files\n";
        exit;
      }
    }
    push(@{$accumulating_edits}, [$op, $path, $v1, $v2, $v3]);
    $last_line_was_file = 0;
    $last_line_was_edit = 1;
  } elsif ($last_line_was_edit){
    ProcessEndOfEdits();
    $last_line_was_edit = 0;
  }
}
if($last_line_was_edit) { ProcessEndOfEdits(); }

#############################
## Process a list of Edits with series list
#

sub ProcessEndOfEdits{
  my @files_for_edits;
  file:
  for my $file_id(@$current_files){
    my $errors = 0;
    if(exists($EditsByFile{$file_id})){
      print "Error: file_id ($file_id) is edited twice\n";
      $errors += 1;
      next file;
    }
    push @files_for_edits, $file_id;
    for my $edit (@$accumulating_edits){
      my $processed_edit = ProcessIndividualEdit($edit);
      unless(exists $EditsByFile{$file_id}->{edits}){
        $EditsByFile{$file_id}->{edits} = [];
      }
      push(@{$EditsByFile{$file_id}->{edits}}, $processed_edit);
    }
  }
  $current_files = [];
  $accumulating_edits = [];
}

#############################
## Process an Individual Edit

sub ProcessIndividualEdit{
  my($edit) = @_;
  my($op, $path, $v1, $v2, $v3) = @$edit;
  unless(exists $SupportedEdits->{$op}){
    print "Operation ($op) not supported\n";
    exit;
  }
  $path = unmetaquote($path);
  $v1 = unmetaquote($v1);
  $v2 = unmetaquote($v2);
  return {op => $op, path =>$path, arg1 => $v1,
    arg2 =>  $v2, arg3 => $v3};
}

sub unmetaquote{
  my($v) = @_;
  if($v =~ /^<(.*)>$/) { $v = $1 }
  elsif($v =~ /^'<(.*)>$/) { $v = $1 }
  return $v;
}

my $sub_dir = get_uuid();
my $CacheDir = $ENV{POSDA_CACHE_ROOT};
unless(-d $CacheDir){
  print "Error: Cache dir ($CacheDir) isn't a directory\n";
}
my $EditDir = "$CacheDir/edits";
unless(-d $EditDir){
  unless(mkdir($EditDir) == 1){
    print "Error: can't mkdir $EditDir ($!)";
    exit;
  }
}
my $DestDir = "$EditDir/$sub_dir";
if(-e $DestDir) {
  print "Error: Destination dir ($DestDir) already exists\n";
  exit;
}
unless(mkdir($DestDir) == 1){
  print "Error: can't mkdir $DestDir ($!)";
  exit;
}

my $get_path = Query("GetFilePath");
my $index = 0;
my $num_files= keys %EditsByFile;
for my $file_id (keys %EditsByFile){
  my $path;
  $get_path->RunQuery(sub {
    my($row) = @_;
    $path = $row->[0];
  }, sub {}, $file_id);
  $EditsByFile{$file_id}->{from_file} = $path;
  $EditsByFile{$file_id}->{to_file} = "$DestDir/" . sprintf("%04d", $index) . ".csv";
  $index += 1;
}

print "Found list of $num_files to edit\n";
print "Directory: $DestDir\n";
print "Subprocess_invocation_id: $invoc_id\n";
#############################
## Uncomment these lines when testing just the processing of
## input
## Only do this for small test cases - it generates a lot of 
## rows in subprocess_lines and chews up a lot of time, etc.
#print "EditsByFile ";
#Debug::GenPrint($dbg, \%EditsByFile, 1);
#print "\n";
#exit;
#############################
# Compute the Destination Dir (and die if it already exists)
print "Forking background process\n";
#############################
# This is code which sets up the Background Process and Starts it
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $BackgroundPid = $$;
# now in the background...
$background->WriteToEmail("Starting edits on $num_files files\n" .
  "Description: $description\n" .
  "Results dir: $DestDir\n" .
  "Subprocess_invocation_id: $invoc_id\n");
$background->WriteToEmail("About to enter Dispatch Environment\n");
my $rpt_pipe = $background->CreateReport("EditDifferences");
$rpt_pipe->print("\"Report\"," .
  "\"report_file_id\",\"num_files\"\r\n");

# Create row in dicom_edit_compare_disposition
my $ins = Query("CreateNonDicomEditCompareDisposition");
$ins->RunQuery(sub {}, sub{}, $invoc_id, $BackgroundPid, $DestDir);

# skip to after editor definition to enter dispatch

##############  This is the editor object which handles events


{
  package Editor;
  use Posda::DB 'Query';
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new{
    my($class, $list, $hash, $invoc_id) = @_;
    my $this = {
     list_of_files => $list,
      file_hash => $hash,
      files_in_process => {},
      files_completed => {},
      compare_requests => {},
      comparing => {},
      compares_complete => {},
      compares_failed => {},
      start_time => time(),
      invoc_id => $invoc_id,
    };
    bless($this, $class);
    my $at_text = $this->now;
    $background->WriteToEmail("Starting at: $at_text\n");
    delete $this->{process_pending};
    $this->InvokeAfterDelay("RestartProcessing", 0);
    $this->{CompareSubprocess} = Dispatch::LineReader->NewWithTrickleWrite(
#      "StreamingNonDicomEditCompare.pl $invoc_id 2>/dev/null",
      "StreamingNonDicomEditCompare.pl $invoc_id",
      $this->FeedDifferencer,
      $this->HandleInputFromCompare,
      $this->HandleEndOfInputFromCompare
    );
    Dispatch::Select::Background->new($this->CountPrinter)->timer(10);
    return $this;
  }

  sub CountPrinter{
    my($this) = @_;
#    my $int_count = 360;      # 360 10 second intervals (1 hour)
    my $int_count = 6;      # 6 10 second intervals (1 minute)
    my $count = $int_count;
    my $sub = sub {
      my($disp) = @_;
      $count -= 1;
      my $at_text = $this->now;
      my($num_in_process, $num_waiting, $num_queued_for_compare,
        $num_comparing, $num_compares_complete, $num_compares_failed,
        $total_to_process);
      if(
        exists $this->{file_hash} &&
        ref($this->{file_hash}) eq "HASH"
      ){
        $total_to_process = keys %{$this->{file_hash}};
      } else { $total_to_process = 0 }
      if(
        exists $this->{files_in_process} &&
        ref($this->{files_in_process}) eq "HASH"
      ){
        $num_in_process = keys %{$this->{files_in_process}};
      } else { $num_in_process = 0 }
      if(
        exists $this->{list_of_files} &&
        ref($this->{list_of_files}) eq "ARRAY"
      ){
        $num_waiting = keys @{$this->{list_of_files}};
      } else { $num_waiting = 0 }
      if(
        exists $this->{compare_requests} &&
        ref($this->{compare_requests}) eq "HASH"
      ){
        $num_queued_for_compare = keys %{$this->{compare_requests}};
      } else { $num_queued_for_compare = 0 }
      if(
        exists $this->{comparing} &&
        ref($this->{comparing}) eq "HASH"
      ){
        $num_comparing = keys %{$this->{comparing}};
      } else { $num_comparing = 0 }
      if(
        exists $this->{compares_complete} &&
        ref($this->{compares_complete}) eq "HASH"
      ){
        $num_compares_complete = keys %{$this->{compares_complete}};
      } else { $num_comparing = 0 }
      if(
        exists $this->{compares_failed} &&
        ref($this->{compares_failed}) eq "HASH"
      ){
        $num_compares_failed = keys %{$this->{compares_failed}};
      } else { $num_compares_failed = 0 }
      unless(defined $this->{update_q}){
        $this->{update_q} = Query("UpdateNonDicomEditCompareDisposition");
      }
      $this->{update_q}->RunQuery(sub {}, sub {}, 
      $total_to_process, $num_compares_complete,
      $num_compares_failed, $invoc_id);
      if($this->{WeAreDone}) {
        my $finalize = Query("FinalizeNonDicomEditCompareDisposition");
        $finalize->RunQuery(sub{},sub{}, $invoc_id);
      }
      if($count <= 0 || $this->{WeAreDone}){
        $count = $int_count;
        my $elapsed = time - $this->{start_time};
        my $report =
          "#############################\n" .
          "BackgroundEditNonDicomFile.pl running report\n" .
          "After $elapsed seconds ($at_text):\n" .
          "\tTotal to process:   $total_to_process\n" .
          "\tIn process:         $num_in_process\n" .
          "\tWaiting:            $num_waiting\n" .
          "\tQueued for compare: $num_queued_for_compare\n" .
          "\tComparing           $num_comparing\n" .
          "\tCompares complete:  $num_compares_complete\n" .
          "\tCompares failed:    $num_compares_failed\n";
        if($this->{WeAreDone}) {
          $report .= "We are done\n";
        }
        $report .= "#############################\n";
        $background->WriteToEmail($report);
        print STDERR $report;
        if($this->{WeAreDone}) { exit };
      }
      unless($this->{WeAreDone}){
        $disp->timer(10);
      }
    };
    return $sub;
  }

  sub StartProcessing{
    my($this) = @_;
    delete $this->{process_pending};
    my $num_simul = 8;
    my $num_in_process = keys %{$this->{files_in_process}};
    my $num_waiting = @{$this->{list_of_files}};
    my $num_comparing = keys %{$this->{comparing}};
    my $num_queued_for_compare = keys %{$this->{compare_requests}};
    while(
      $num_in_process < $num_simul && $num_waiting > 0
    ){
      my $next_file = shift @{$this->{list_of_files}};
      my $next_struct = $this->{file_hash}->{$next_file};
      $this->{files_in_process}->{$next_file} = $next_struct;
      $this->SerializedSubProcess($next_struct,
#        "NewSubprocessCsvEditor.pl 2>/dev/null",
        "NewSubprocessCsvEditor.pl",
        $this->WhenEditDone($next_file, $next_struct));
      $num_in_process = keys %{$this->{files_in_process}};
      $num_waiting = @{$this->{list_of_files}};
    }
    if(
      $num_waiting == 0 &&
      $num_in_process == 0 &&
      $num_comparing == 0 &&
      $num_queued_for_compare == 0
    ){
      $this->AtTheEnd;
    }
  }

  sub WhenEditDone{
    my($this, $file_id, $struct) = @_;
    my $sub = sub {
      my($status, $ret_struct) = @_;
      my $from_file = $struct->{from_file};
      my $to_file = $struct->{to_file};
      if($status eq "Succeeded" && $ret_struct->{Status} eq "OK"){
        my $c_struct = {
          subprocess_invocation_id => $this->{invoc_id},
          from_file_path => $from_file,
          to_file_path => $to_file,
        };
        $this->QueueCompareRequest($file_id, $c_struct);
      } else {
        $this->{compares_failed}->{$file_id} = {
          edits => $struct,
          status => $status,
          report => $ret_struct,
        };
        if($status eq "Succeeded"){
          print STDERR "$file_id: $ret_struct->{Status}: $ret_struct->{message}\n";
        }
#print STDERR "Failure ($file_id): ";
#Debug::GenPrint($dbg, $this->{compares_failed}->{$file_id}, 1);
#print STDERR "\n";
      }
      delete $this->{files_in_process}->{$file_id};
      $this->RestartProcessing;
    };
  }
  sub RestartProcessing{
    my($this) = @_;
    unless(exists $this->{process_pending}){
      $this->{process_pending} = 1;
      $this->InvokeAfterDelay("StartProcessing", 0);
    }
  }

  sub HandleInputFromCompare{
    my($this) = @_;
    my $sub = sub{
      my($line) = @_;
      if($line =~ /Completed:\s*(.*)$/){
        my $remain = $1;
        my($file_id, $from_file, $to_file,$rept_id) = split(/\|/, $remain);
        delete $this->{comparing}->{$file_id};
        $this->{compares_complete}->{$file_id} = 1;
      } elsif($line =~ /Failed:\s*(.*)$/){
        my $remain = $1;
        my($file_id, $mess) = split(/\|/, $remain);
        delete $this->{comparing}->{$file_id};
        $this->{compares_failed}->{$file_id} = $mess;
        $background->WriteToEmail("Compare failed:\n\tfrom_file_id: $file_id\n" .
          "\tmessage: $mess\n");
      } else {
        print STDERR
          "!!!!!!!!!!!!!!!!!!!!!!!!!!!!  Auuuuugh!!   !!!!!!!!!!!!!!!!!\n" .
          "!!!!!!!  You idiot!  !!!!!!!!!!!!" .
          "Bad line: \"$line\"\n" .
          "!!!!!!!!! Always have default case !!!!!!!!";
        $background->WriteToEmail(
          "!!!!!!!!!!!!!!!!!!!!!!!!!!!!  Auuuuugh!!!!!!!!!!!!!!!!!!!\n" .
          "!!!!!!!  You idiot !!!!!!!!!!!!" .
          "Bad line: \"$line\"\n" .
          "!!!!!!!!! Always have default case !!!!!!!!\n");
        exit;
      }
      # here is where we check from being done
      my $num_in_process = keys %{$this->{files_in_process}};
      my $num_waiting = @{$this->{list_of_files}};
      my $num_comparing = keys %{$this->{comparing}};
      my $num_queued_for_compare = keys %{$this->{compare_requests}};
      if(
         $num_waiting == 0 &&
         $num_in_process == 0 &&
         $num_comparing == 0 &&
         $num_queued_for_compare == 0
      ){
        # if so, shutdown writer (after returning undef)
        my $writer = $this->{CompareSubprocess};
        Dispatch::Select::Background->new(sub {
          my($disp) = @_;
          $writer->ShutdownWriter;
        })->queue;
        delete $this->{CompareSubprocess};
      }
    };
    return $sub;
  }
  sub HandleEndOfInputFromCompare{
    my($this) = @_;
    my $sub = sub{
      $this->RestartProcessing;
    };
    return $sub;
  }

  sub FeedDifferencer{
    my($this) = @_;
    my $sub = sub {
      my $num_to_send = keys %{$this->{compare_requests}};
      if($num_to_send > 0){
        my $next_to_send = [keys %{$this->{compare_requests}}]->[0];
        my $next_struct = $this->{compare_requests}->{$next_to_send};
        my $from = $next_struct->{from_file_path};
        my $to = $next_struct->{to_file_path};
        my $id = $next_struct->{subprocess_invocation_id};
        delete $this->{compare_requests}->{$next_to_send};
        my $command = "$next_to_send|$from|$to";
        $this->{comparing}->{$next_to_send} = $command;
        return $command;
      } else {
        # Here we can't check to see if all have been queued
        # (We can't shutdown writer without losing contents
        # backed up in pipes);
        return undef;
      }
    };
    return $sub;
  }
  sub QueueCompareRequest{
    my($this, $key, $value) = @_;
    my $existing_request_count  = keys %{$this->{compare_requests}};
    $this->{compare_requests}->{$key} = $value;
    if($existing_request_count == 0){
      $this->{CompareSubprocess}->StartWriter;
    }
  }
  sub AtTheEnd{
    my($this) = @_;
###############
    my $elapsed  = time - $this->{start_time};
    my $num_edited = keys %{$this->{compares_complete}};
    my $num_failed = keys %{$this->{compares_failed}};
    my %data;
    my $num_rows = 0;
    my $get_list = Query("NonDicomDifferenceReportByEditId");
    $get_list->RunQuery(sub {
        my($row) = @_;
        my($report_file_id, $num_files) = @$row;
        $num_rows += 1;
        $data{$report_file_id} = $num_files;
      }, sub {}, $this->{invoc_id});
    my $num_rpts = keys %data;
    my $get_path = Query("GetFilePath");
    for my $rept_id (keys %data){
      my $rept = "";
      $get_path->RunQuery(sub{
        my($row) = @_;
        my $file = $row->[0];
        $rept = `cat $file`;
        chomp $rept;
      }, sub {}, $rept_id);
        $rept =~ s/"/""/g;
        $rpt_pipe->print("\"$rept\",$rept_id,$num_files\r\n");
    }
    my $op = "ScriptButton";
    my $caption = "Reject Edits and Delete Temporary Files";
    my $param_hash = {
      op => "OpenTableFreePopup",
      class_ => "Posda::ProcessPopup",
      cap_ => "RejectNonDicomEdits",
      subprocess_invoc_id => $this->{invoc_id},
      notify => $notify
    };
    $background->InsertEmailButton($caption, $op, $param_hash);
    $op = "ScriptButton";
    $caption = "Accept Edits, Import and Delete Temporary Files";
    $param_hash = {
      op => "OpenTableFreePopup",
      class_ => "Posda::ProcessPopup",
      cap_ => "ImportNonDicomEdits",
      subprocess_invoc_id => $this->{invoc_id},
      notify => $notify
    };
    $background->InsertEmailButton($caption, $op, $param_hash);
###############
    my $at_text = $this->now;
    $background->WriteToEmail("Ending at: $at_text\n");
    $background->WriteToEmail("$num_edited edited, $num_failed failed in " .
      "$elapsed seconds\n");
    $background->WriteToEmail("Invocation Id: $this->{invoc_id}\n");
    $background->Finish;
    $this->{WeAreDone} = 1;
  }
}
##############  This is the end of editor object which handles events

# 
# The code which follows is used to create an instance of this object
# and turn it over to the Dispatcher
#

sub MakeEditor{
  my($file_list, $file_hash, $invoc_id) = @_;
  my $sub = sub {
    my($disp) = @_;
    Editor->new($file_list, $file_hash, $invoc_id);
  };
  return $sub;
}
{
  my @files = sort keys %EditsByFile;
  my $num_files = @files;
  print STDERR "##############\n";
  print STDERR "$num_files files to edit\n";
  print STDERR "##############\n";
  Dispatch::Select::Background->new(
    MakeEditor(\@files, \%EditsByFile, $invoc_id))->queue;
}
Dispatch::Select::Dispatch();
