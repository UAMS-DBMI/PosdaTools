#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::BackgroundProcess;
use Posda::ActivityInfo;
use Posda::UUID;
use Posda::NBIASubmit;
use File::Basename;
use File::Path 'make_path';

our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}
my $usage = <<EOF;
BackgroundPrivateDispositionsTp.pl <?bkgrnd_id?> <activity_id> <uid_root> <offset> <notify>
  UID's not hashed if they begin with <uid_root>
  date's always offset with offset (days)
  email sent to <notify>

Expects nothing on <STDIN>

Constructs a destination file name as follows:
  <generated_unique_dir>/<patient_id>/<study_uid>/<series_uid>/<modality>_sop_inst_uid.dcm

Actually invokes ApplyPrivateDispositionUnconditionalDate.pl to do the edits
EOF





if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my $script_start_time = time;
unless($#ARGV == 4){
  print "$usage\n";
  die "######################## subprocess failed to start:\n" .
      "$usage\n" .
      "#####################################################\n";
}
my($invoc_id, $act_id, $uid_root, $offset, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

print "All processing in background\n";
$background->Daemonize;

my %Patients;
my @Series;


my $act_info = Posda::ActivityInfo->new($act_id);
my $tp_id = $act_info->LatestTimepoint;
my $FileInfo = $act_info->GetFileInfoForTp($tp_id);
for my $f (keys %$FileInfo){
  my $pat_id = $FileInfo->{$f}->{patient_id};
  my $series_uid = $FileInfo->{$f}->{series_instance_uid};
  my $study_uid = $FileInfo->{$f}->{study_instance_uid};
  $Patients{$pat_id}->{$study_uid}->{$series_uid} = 1;
}

for my $p (keys %Patients){
  for my $s (keys %{$Patients{$p}}){
    for my $se (keys %{$Patients{$p}->{$s}}){
      push @Series, $se;
    }
  }
}



my $g_ser_file_ids = PosdaDB::Queries->GetQueryInstance("FilesIdsVisibleInSeries");
my @tp_errors;
for my $s (@Series){
  $g_ser_file_ids->RunQuery(sub{
    my($row) = @_;
    my $f = $row->[0];
    unless(exists $FileInfo->{$f}){
      push(@tp_errors, [$s, $f]);
    }
  }, sub {}, $s);
}



my $num_errors = @tp_errors;
if($num_errors > 0){
  $background->WriteToEmail("There were $num_errors in tp series\n");
  my $rpt = $background->CreateReport("Series In Timepoint With Files Not In Timepoint");
  $rpt->print("series_instance_uid,file_id\n");
  for my $i (@tp_errors){
    $rpt->print("$i->[0], $i->[1]\n");
  }
  $background->Finish;
  exit;
}













































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
  $background->WriteToEmail("Error: there are new private tags which have no disposition\n");
  my $rpt = $background->CreateReport("Private Tags With No Disposition");
  $rpt->print("id,tag,vr,name,disp\n");
  for my $i (@new_tags){
    for my $j (0 .. $#{$i}){
      my $v = $i->[$j];
      if(defined $v) { $rpt->print("$v") } else {$rpt->print("<undef>") }
      if($j == $#{$i}){
        $rpt->print("\n");
      }
    }
    $rpt->print("\n");
  }
  $background->Finish;
  exit;
}


my @dispositions_needed;
$q2->RunQuery(sub {
  my($row) = @_;
  my($id, $ele_sig, $vr, $name) = @$row;
  push @dispositions_needed, [$id, $ele_sig, $vr, $name];
}, sub {});
if(@dispositions_needed > 0){
  my $num_disp_n = @dispositions_needed;
  $background->WriteToEmail("Error: $num_disp_n private tags have no disposition\n");
  my $rpt = $background->CreateReport("Private Tags With No Disposition");
  $rpt->print("id,tag,vr,name\n");
  for my $i (@dispositions_needed){
    for my $j ($#{$i}){
      my $v = $j->[$i];
      if(defined $v) { $rpt->print("$v") } else {$rpt->print("<undef>") }
      unless($j == $#{$i}){
        $rpt->print(",");
      }
    }
    $rpt->print("\n");
  }
  $background->Finish;
  exit;
}



my $q5 = PosdaDB::Queries->GetQueryInstance(
  "AreVisibleFilesMarkedAsBadOrUnreviewedInSeries");
my $q6 = PosdaDB::Queries->GetQueryInstance(
  "IsThisSeriesNotVisuallyReviewed");
for my $series (@Series){
  $q6->RunQuery(sub {
    my($row) = @_;
    $background->WriteToEmail("Warning: series $series not submitted for visual review\n");
  }, sub {}, $series);
  $q5->RunQuery(sub{
    my($row) = @_;
    $background->WriteToEmail("Error series $series has unreviewed or bad files\n");
    $error += 1;
  }, sub {}, $series);
}
if($error){
  $background->WriteToEmail("Terminating because of errors\n");
  $background->Finish;
  exit;
}

my $num_series = @Series;
$background->WriteToEmail("Found list of $num_series series to send\n");

# Abort if we found nothing to do
if($num_series <= 0) {
  $background->Finish;
  exit;
}

my $date = `date`;
chomp $date;

#############################
## Compute the Destination Dir (and die if it already exists)
#
my $sub_dir = get_uuid();

my $BaseDir = $ENV{NBIA_STORAGE_ROOT}
  or die "NBIA_STORAGE_ROOT env var is undefined! cannot continue";

unless(-d $BaseDir){
  print "Error: Base dir ($BaseDir) isn't a directory\n";
}

$background->WriteToEmail("$date\nStarting ApplyPrivateDispositions\n");

#######################################################################
### Body of script

my @cmds;
my $q_inst = PosdaDB::Queries->GetQueryInstance("FilesInSeriesForApplicationOfPrivateDisposition2");
for my $patient_id (sort keys %Patients){


  $background->WriteToEmail("Patient: $patient_id\n");
  for my $study_uid (sort keys %{$Patients{$patient_id}}){
    $background->WriteToEmail("Study $study_uid\n");
    for my $series_uid (sort keys %{$Patients{$patient_id}->{$study_uid}}){
      $background->WriteToEmail("Series \"$series_uid\"\n");
      my $num_files = 0;
      $q_inst->RunQuery(sub {
        my ($row) = @_;
        my ($path, $sop_instance_uid, $modality, $file_id) = @$row;

        my $f_filename = Posda::NBIASubmit::GenerateFilename($sop_instance_uid);

				my $full_filename = "$BaseDir/$f_filename";
				my $dirname = dirname($full_filename);
				make_path($dirname);

        # input_path output_path uid_root offset collection_name site_name site_id batch
        my $cmd = qq{ApplyPrivateDispositionUnconditionalDate2.pl $invoc_id } .
                  qq{$file_id $path "$full_filename" $uid_root $offset } .
                  qq{"OPC-Radiomics" "UHN" 86663098 0};

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
open SCRIPT6, "|/bin/sh";
open SCRIPT7, "|/bin/sh";
open SCRIPT8, "|/bin/sh";
open SCRIPT9, "|/bin/sh";
open SCRIPT0, "|/bin/sh";
command:
while(1){
  my $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT1 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT2 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT3 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT4 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT5 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT6 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT7 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT8 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT9 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT0 "$cmd\n";

}
$background->WriteToEmail(`date`);
$background->WriteToEmail("All commands queued\n");
close SCRIPT1;
close SCRIPT2;
close SCRIPT3;
close SCRIPT4;
close SCRIPT5;
close SCRIPT6;
close SCRIPT7;
close SCRIPT8;
close SCRIPT9;
close SCRIPT0;
$background->WriteToEmail(`date`);
$background->WriteToEmail("All subshells complete\n");
### Body of script
###################################################################
my $end = time;
my $duration = $end - $script_start_time;
$background->WriteToEmail( "finished conversion in $duration seconds\n");
$background->Finish;
