#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
BackgroundPrivateDispositions.pl <id> <to_dir> <uid_root> <offset> <notify>
  id - id of row in subprocess_invocation table created for th
    invocation of the script
  writes result into <to_dir>
  UID's not hashed if they begin with <uid_root>
  date's always offset with offset (days)
  email sent to <notify>

Expects the following list on <STDIN>
  <id>&<processing_status>&<review_status>&<dicom_file_type>
  where:
    <id> = visual review scan_instance
    <processing_status> = processing_status
    <review_status> = review_status
    <dicom_file_type> = dicom_file_type
  see Query "VisualReviewStatusById"

Constructs a destination file name as follows:
  <to_dir>/<patient_id>/<study_uid>/<series_uid>/<modality>_sop_inst_uid.dcm
  Gets this data from query "VisibleImagesWithDetailsByVisualIdAndTypeAndStatus"

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

my $q1 = PosdaDB::Queries->GetQueryInstance(
  "PrivateTagsWhichArentMarked");
my $q2 = PosdaDB::Queries->GetQueryInstance(
  "DistinctDispositionsNeededSimple");
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
#######################################################################
#Here is where we get list of commands to run
my $q = Query("VisibleImagesWithDetailsByVisualIdAndTypeAndStatus");
my @cmds;
while(my $line = <STDIN>){
  chomp $line;
  my($id, $processing_status, $review_status, $dicom_file_type) =
    split /&/, $line;
  $q->RunQuery(sub{
    my($row) = @_;
    my($patient_id, $study_uid, $series_uid, $sop_instance_uid, 
      $modality, $path) = @$row;
    my $dir = "$to_dir/$patient_id";
    unless(-d $dir){
      if(mkdir $dir){
         print "Created directory: $dir\n";
      } else {
        print "Can't mkdir $dir\n";
        exit;
      }
    }
    $dir = "$dir/$study_uid";
    unless(-d $dir){
      if(mkdir $dir){
         print "Created directory: $dir\n";
      } else {
        print "Can't mkdir $dir\n";
        exit;
      }
    }
    $dir = "$dir/$series_uid";
    unless(-d $dir){
      if(mkdir $dir){
         print "Created directory: $dir\n";
      } else {
        print "Can't mkdir $dir\n";
        exit;
      }
    }
    my $cmd = "ApplyPrivateDispositionUnconditionalDate.pl $path " .
      "\"$to_dir/$patient_id/" .
      "$study_uid/" .
      "$series_uid/$modality" . "_$sop_instance_uid.dcm\" " .
      "$uid_root $offset ";
    push @cmds, $cmd;
  }, sub {}, $id, $processing_status, $review_status, $dicom_file_type);
}
my $num_commands = @cmds;
print "$num_commands files to which dispositions will be applied\n" .
  "Forking background process\n";
$background->Daemonize;
my $date = `date`;
chomp $date;
$background->WriteToEmail("$date\nStarting ApplyPrivateDispositions\n" .
  "To directory: $to_dir\n");
#######################################################################
### Body of script
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
