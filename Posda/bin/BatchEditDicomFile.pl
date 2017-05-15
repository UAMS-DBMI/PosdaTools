#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::UUID;
use Dispatch::Select;
use Dispatch::EventHandler;
use Digest::MD5;
use FileHandle;
use Storable qw( store retrieve fd_retrieve store_fd );
use Debug;
my $dbg = sub { print @_ };
my $usage = <<EOF;
Usage:
BatchEditDicomFile.pl <report_path> <dest_root> <who> <edit_desciption> <notify>
or
BatchEditDicomFile.pl -h


Expects lines of the formh:
<command>&<arg1>&<arg2>&<arg3>&<arg4>

Each line is a command.  A command may be either a control command, an
edit accumulation command, or a ProcessFiles command.

Generally, edits files specifed by list of commands, into hierarchy
based on collection, site, patient, study, and series underneath the <dest_root>
also records information about the edits performed in the database
also imports the new files into the database.
also prepares a spreadsheet summarizing the edits and stores it into
<report_path>

When invoked, processes STDIN and writes to STDOUT a summary of the operations
it will perform.  Then forks a sub-process and exits (after closing
both STDIN and STDOUT, so parent will get result).

When the sub-process completes, it sends a notification email.

NOTE: you shouldn't run this for duplicate SOPs (its bad practice).  In general
  only one file will be edited per affected SOP Instance UID.

BatchEditDicomFile may run for a long time.

Control Commands:
  AddFile <arg1> = <file_name>, <arg2> = <modality>, <arg3> =
    SOP Instance UID.
    Starts the accumulation of edit commands to apply a single file.
    This accumulation terminates when the ProcessFiles command is 
    encountered.
  AddSop <arg1> = <sop_instance_uid>
    Same as AddFile except it does so by sop_instance_uid.  The file
    will be selected using the query named "FirstFileForSopPosda".
  AddSopsInSeries <arg1> = <series_instance_uid> like AddFile or
    AddSop, except that the edits accumulated will be applied to
    all the files in the specified series. Uses the query named
    "FilesInSeriesForApplicationOfPrivateDisposition" to get list of
    files, and Sops.
  AccumulateEdits - Start accumulating edits in following lines.
Accumulation Commands:
  The <command> is always 'edit',  <arg1> specifies the type of edit:
    uid_substitution - <arg2> = <from_uid>, <arg3> = <to_uid>
    hash_unhashed_uid - <arg2> = <leaf element>, <arg3> = <uid_root>
    short_ele_substitution - <arg2> = <leaf element>, <arg3> = <old_value>,
       <arg4> = <new_value>
    short_ele_replacement - <arg2> = <leaf element>, <arg3> = <new_value>
    full_ele_substitution - <arg2> = <full element>, <arg3> = <old_value>,
       <arg4> = <new_value>
    full_ele_replacement - <arg2> = <full element>, <arg3> = <new_value>
    full_ele_delete - <arg2> = <full element>
    full_ele_addition - <arg2> = <full element>, <arg3> = <new_value>
    leaf_delete - <arg2> = <leaf element>
ProcessFiles command:
   Applies all of the accumulated edits to the file[s] set in the active
   control command. Clear list of SOPs.  Expect Control Commands to follow.
Uses SubProcessEditor.pl to perform edits
EOF
my %SopsToEdit;
sub CheckFiles{
  my($from_file, $to_file, $sop) = @_;
  unless(exists $SopsToEdit{$sop}){
    $SopsToEdit{$sop} = {
      from_file => $from_file,
      to_file => $to_file,
    };
  }
  my $sop_p = $SopsToEdit{$sop};
  unless(
    $sop_p->{from_file} eq $from_file &&
    $sop_p->{to_file} eq $to_file
  ){
    print "SOP vs file collision:\n" .
      "\tSOP: $sop\n" .
      "\tFrom:\n" .
      "\t\t$sop_p->{from_file}\n" .
      "\tvs\n" .
      "\t\t$from_file\n" .
      "\tTo:\n" .
      "\t\t$sop_p->{to_file}\n" .
      "\tvs\n" .
      "\t\t$to_file\n" .
      "Editing transaction aborted\n";
     die "abort";
  }
  return $sop_p;
}
if($#ARGV == 0) { die "$usage\n\n" }
if($#ARGV != 4){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my $getf = PosdaDB::Queries->GetQueryInstance('FirstFileForSopPosda');
my $getfs = PosdaDB::Queries->GetQueryInstance(
  'FilesInSeriesForApplicationOfPrivateDisposition');
my($ReportPath, $DestRoot, $who, $description, $notify) = @ARGV;
my $wdir = Posda::UUID::GetGuid;
my $WorkDir = "$DestRoot/$wdir";
unless(mkdir($WorkDir) == 1) {
  die "Couldn't mkdir $WorkDir ($!)";
}
my $pstate = "Search";
my $working_file_list = [];
line:
while(my $line = <STDIN>){
  chomp $line;
  my($command, $arg1, $arg2, $arg3, $arg4) = split /&/, $line;
  if($pstate eq "Search"){
    if($command eq "AddFile"){
      my $from_file = $arg1;
      my $modality = $arg2;
      my $sop = $arg3;
      my $to_file = "$WorkDir/$modality" . "_$sop.dcm";
      push @$working_file_list, [$from_file, $modality, $sop, $to_file];
    } elsif ($command eq "AddSop"){
      $getf->RunQuery(sub {
          my($row) = @_;
          my $from_file = $row->[0];
          my $modality = $row->[1];
          my $sop = $arg1;
          my $to_file = "$WorkDir/$modality" . "_$sop.dcm";
          push @$working_file_list, [$from_file, $modality, $sop, $to_file];
        }, sub {}, $arg1);
    } elsif ($command eq "AccumulateEdits"){
      $pstate = "AccumulateEdits";
    } elsif ($command eq "AddSopsInSeries"){
      $getfs->RunQuery(sub {
          my($row) = @_;
          my($from_file, $sop, $modality) = @$row;
          my $to_file = "$WorkDir/$modality" . "_$sop.dcm";
          push @$working_file_list, [$from_file, $modality, $sop, $to_file];
        }, sub {}, $arg1);
    } else {
      print "Invalid line: \"$line\" in state $pstate\n" .
        "Editing transaction aborted\n";
      die "abort";
    }
    next line;
  } elsif($pstate eq "AccumulateEdits"){
    if($command eq "ProcessFiles"){
      $working_file_list = [];
      $pstate = "Search";
      next line;
    } elsif($command eq "edit"){
      for my $f (@$working_file_list){
        my($from_file, $modality, $sop, $to_file) = @$f;
        unless(exists $SopsToEdit{$sop}){
          $SopsToEdit{$sop} = {
            from_file => $from_file,
            to_file => $to_file,
          };
        }
        my $sop_p = CheckFiles($from_file, $to_file, $sop);
        if($arg1 eq "uid_substitution"){
          my $from_uid = $arg2;
          my $to_uid = $arg3;
          unless(exists $sop_p->{uid_substitution}->{$from_uid}){
            $sop_p->{uid_substitution}->{$from_uid} = $to_uid;
          }
          unless($sop_p->{uid_substitution}->{$from_uid} eq $to_uid){
            print "Conflicting uid translation:\n" .
              "from: $from_uid to both:\n" .
              "\t$to_uid\n" .
              "\t$sop_p->{uid_substitution}->{$from_uid}\n" .
              "Editing transaction aborted\n";
            die "abort";
          }
        }elsif($arg1 eq "hash_unhashed_uid"){
          my $leaf_ele = $arg2;
          my $uid_root = $arg3;
          unless(exists $sop_p->{hash_unhashed_uid}->{$leaf_ele}){
            $sop_p->{hash_unhashed_uid}->{$leaf_ele} = $uid_root;
          }
          unless($sop_p->{hash_unhashed_uid}->{$leaf_ele} eq $uid_root){
            print "Conflicting uid hash:\n" .
              "ele: $leaf_ele to both:\n" .
              "\t$uid_root\n" .
              "\t$sop_p->{hash_unhashed_uid}->{$leaf_ele}\n" .
              "Editing transaction aborted\n";
            die "abort";
          }
        }elsif($arg1 eq "short_ele_substitution"){
          my $leaf_ele = $arg2;
          my $old_v = $arg3;
          my $new_v = $arg4;
          unless(
            exists $sop_p->{short_ele_substitutions}->{$old_v}
          ){
            $sop_p->{short_ele_substitutions}->{$old_v} = $new_v;
          }
          unless(
            $sop_p->{short_ele_substitutions}->{$old_v} eq $new_v
          ){
            print "Conflicting short_ele substitution:\n" .
              "ele: $leaf_ele from $old_v to both:\n" .
              "\t$sop_p->{sort_ele_substitutions}->{$leaf_ele}->{$old_v}\n" .
              "\t$new_v\n" .
              "Editing transaction aborted\n";
            die "abort";
          }
        }elsif($arg1 eq "short_ele_replacement"){
          my $leaf_ele = $arg2;
          my $new_v = $arg3;
        }elsif($arg1 eq "full_ele_substitution"){
          my $ele = $arg2;
          my $old_v = $arg3;
          my $new_v = $arg4;
          unless(
            exists $sop_p->{full_ele_substitutions}->{$ele}->{$old_v}
          ){
            $sop_p->{full_ele_substitutions}->{$ele}->{$old_v} = $new_v;
          }
          unless(
            $sop_p->{full_ele_substitutions}->{$ele}->{$old_v} eq $new_v
          ){
            print "Conflicting full_ele substitution:\n" .
              "ele: $ele from $old_v to both:\n" .
              "\t$sop_p->{full_ele_substitutions}->{$ele}->{$old_v}\n" .
              "\t$new_v\n" .
              "Editing transaction aborted\n";
            die "abort";
          }
        }elsif($arg1 eq "full_ele_replacement"){
          my $ele = $arg2;
          my $new_v = $arg3;
          unless(
            exists $sop_p->{full_ele_replacements}->{$ele}
          ){
            $sop_p->{full_ele_replacements}->{$ele} = $new_v;
          }
          unless(
            $sop_p->{full_ele_replacements}->{$ele} eq $new_v
          ){
            print "Conflicting full_ele_replacement:\n" .
              "ele: $ele to both:\n" .
              "\t$sop_p->{full_ele_replacements}->{$ele}\n" .
              "\t$new_v\n" .
              "Editing transaction aborted\n";
            die "abort";
          }
        }elsif($arg1 eq "full_ele_delete"){
          my $ele = $arg2;
          $sop_p->{full_ele_deletes}->{$ele} = 1;
        }elsif($arg1 eq "full_ele_addition"){
          my $ele = $arg2;
          my $new_v = $arg3;
          unless(
            exists $sop_p->{full_ele_additions}->{$ele}
          ){
            $sop_p->{full_ele_additions}->{$ele} = $new_v;
          }
          unless(
            $sop_p->{full_ele_additions}->{$ele} eq $new_v
          ){
            print "Conflicting full_ele_additions:\n" .
              "ele: $ele to both:\n" .
              "\t$sop_p->{full_ele_additions}->{$ele}\n" .
              "\t$new_v\n" .
              "Editing transaction aborted\n";
            die "abort";
          }
        }elsif($arg1 eq "leaf_delete"){
          my $leaf_ele = $arg2;
          $sop_p->{leaf_delete}->{$leaf_ele} = 1;
        }else{
          print "Unrecognized edit: \"$line\"\n" .
            "Editing transaction aborted\n";
          die "abort";
        }
      }
    } else {
      print "Non edit in $pstate: \"$line\"\n" .
        "Editing transaction aborted\n";
      die "abort";
    }
  } else {
    die "Invalid State $pstate";
  }
}
my $num_sops = keys %SopsToEdit;
print "$num_sops to edit\n";
$getf = undef;
$getfs = undef;
$| = 1;
shutdown STDOUT, 1;
if(my $pid = fork){
 close STDIN;
 close STDOUT;
 exit;
}
my $EmailHandle = FileHandle->new("|mail -s \"Posda Job Complete\" $notify");
unless($EmailHandle) { die "Couldn't open email handle ($!)" }
my $ReportHandle = FileHandle->new(">$ReportPath");
unless($ReportHandle) { die "Couldn't open ReportHandle handle ($!)" }
$ReportHandle->print(
  "sop_instance_uid,from_file,from_digest,to_file,to_digest," .
  "status,,report_file_path,Operation,edit_comment,notify\n");
$EmailHandle->print("Starting edits on $num_sops sop_instance_uids\n" .
  "Description: $description\n" .
  "Report file: $ReportPath\n" .
  "Results dir: $WorkDir\n");
$EmailHandle->print("About to enter Dispatch Environment\n");
my $rep_fileno = $ReportHandle->fileno;
my $email_fileno = $EmailHandle->fileno;
my $stdin = fileno(STDIN);
my $stdout = fileno(STDOUT);
$stdin = fileno(STDIN);
$stdout = fileno(STDOUT);
{
  package Editor;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new{
    my($class, $list, $hash, $email, $rpt) = @_;
    my $this = {
      list_of_sops => $list,
      sop_hash => $hash,
      sops_in_process => {},
      sops_completed => {},
      sops_failed => {},
      start_time => time(),
      email => $email,
      rpt => $rpt,
    };
    bless($this, $class);
    my $at_text = $this->now;
    $this->{email}->print("Starting at: $at_text\n");
    $this->{rpt}->print(",,,,,,,\"$ReportPath\",EditReport,\"$description\"," .
      "\"$notify\"\n");
    $this->{process_pending} = 1;
    $this->InvokeAfterDelay("StartProcessing", 0);
    return $this;
  }
  sub StartProcessing{
    my($this) = @_;
    delete $this->{process_pending};
    my $num_simul = 1;
    my $num_in_process = keys %{$this->{sops_in_process}};
    my $num_waiting = @{$this->{list_of_sops}};
    while(
      $num_in_process < $num_simul &&
      $num_waiting > 0
    ){
      my $next_sop = shift @{$this->{list_of_sops}};
      my $next_struct = $this->{sop_hash}->{$next_sop};
      $this->{sops_in_process}->{$next_sop} = $next_struct;
      delete $this->{sop_hash}->{$next_sop};
      $this->SerializedSubProcess($next_struct, "SubProcessEditor.pl",
        $this->WhenEditDone($next_sop, $next_struct));
      $num_in_process = keys %{$this->{sops_in_process}};
      $num_waiting = @{$this->{list_of_sops}};
    }
    if($num_waiting == 0 && $num_in_process == 0){
      my $elapsed  = time - $this->{start_time};
      my $num_edited = keys %{$this->{sops_completed}};
      my $num_failed = keys %{$this->{sops_failed}};
      my $at_text = $this->now;
      $this->{email}->print("Ending at: $at_text\n");
      $this->{email}->print("$num_edited edited, $num_failed failed in " .
        "$elapsed seconds\n");
    }
  }
  sub WhenEditDone{
    my($this, $sop, $struct) = @_;
    my $sub = sub {
      my($status, $ret_struct) = @_;
#print STDERR "Edit done: $sop\n";
#print STDERR "Status $status, return: ";
#Debug::GenPrint($dbg, $ret_struct, 1);
#print STDERR "\n";
      my $from_file = $struct->{from_file};
      my $to_file = $struct->{to_file};
      if($status eq "Succeeded" && $ret_struct->{Status} eq "OK"){
print STDERR "$sop succeded\n";
        $this->{sops_completed}->{$sop} = $struct;
        my $from_dig = $this->GetFileDig($from_file);
        my $to_dig = $this->GetFileDig($to_file);
        $this->{rpt}->print("$sop,\"$from_file\",$from_dig,\"$to_file\"," .
          "$to_dig,OK\n");
      } else {
print STDERR "$sop failed\n";
        $this->{sops_failed}->{$sop} = {
          edits => $struct,
          status => $status,
          report => $ret_struct,
        };
        $this->{rpt}->print("$sop,\"$from_file\",\"\",\"$to_file\",\"\"," .
          "$status,\"$ret_struct->{mess}\"\n");
      }
      delete $this->{sops_in_process}->{$sop};
      unless(exists $this->{process_pending}){
        $this->{process_pending} = 1;
        $this->InvokeAfterDelay("StartProcessing", 0);
      }
    };
    return $sub;
  }
  sub GetFileDig{
    my($this, $file) = @_;
    my $ctx = Digest::MD5->new();
    unless(open FILE, "<$file"){
      return "Unable to open file";
    }
    $ctx->addfile(*FILE);
    my $dig = $ctx->hexdigest;
    close FILE;
    return $dig;
  }
}
sub MakeEditor{
  my($sop_list, $sop_hash, $email, $report) = @_;
  my $sub = sub {
    my($disp) = @_;
    Editor->new($sop_list, $sop_hash, $email, $report);
  };
  return $sub;
}
{
  my @sops = sort keys %SopsToEdit;
  Dispatch::Select::Background->new(
    MakeEditor(\@sops, \%SopsToEdit, $EmailHandle, $ReportHandle))->queue;
}
Dispatch::Select::Dispatch();
