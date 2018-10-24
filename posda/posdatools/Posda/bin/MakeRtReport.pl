#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
MakeRtReport.pl <invoc_id> <notify_email>
or
MakeRtReport.pl -h

Generates a csv report file
Sends email when done
Expect input lines in following format:
<patient_id>&<study_id>&<series_id>&<modality>&<num_files>
EOF
unless($#ARGV == 1 ){ print "$usage\n"; die $usage }
my @Lines;
while(my $line = <STDIN>){
  chomp $line;
  my($pat_id, $study_uid, $series_uid, $modality, $num_files) =
    split(/&/, $line);
  push(@Lines, [$pat_id, $study_uid, $series_uid, $modality, $num_files]);
}
my $num_lines = @Lines;
print "$num_lines elements loaded\n";
my $invoc_id = $ARGV[0];
my $notify = $ARGV[1];
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $start = time;
my $tt = `date`;
chomp $tt;
$background->WriteToEmail("At: $tt\n\t$0\n");
my $q = Query("PublicFilesInSeries");
my $rpt = $background->CreateReport("RtReport");
$rpt->print("patient_id,study_instance_uid,series_instance_uid," .
  "modality,num_files,size,num_rois,num_frac_groups,num_beams,num_dvhs," .
  "error\n");
row:
for my $row (@Lines){
  my($pat_id, $study_uid, $series_uid, $modality, $num_files) = @$row;
  my @files;
  $q->RunQuery(sub{
    my($row) = @_;
    my $path = $row->[0];
    if($path =~ /^.*storage(.*)$/){
      my $convert_path = "/nas/public/storage$1";
      push @files, $convert_path;
    }
  }, sub {}, $series_uid);
  my $files_found = @files;
  $rpt->print("\"$pat_id\",\"$study_uid\",\"$series_uid\",\"$modality\"," .
    "\"$num_files\",");
  if($modality eq 'RTSTRUCT'){
    if($files_found ne $num_files){
      $rpt->print(",,,,,\"More than one file for series in Public\"\n");
      next row;
    }
    my $size = "<not_found>";
    my $num_rois = "<not_found>";
    my $error = "";
    open TASK, "RtStructReport.pl \"$files[0]\"|";
    while(my $line = <TASK>){
      chomp $line; 
      if($line =~ /^Length:\s*(\d+)\s*$/){
        $size = $1;
      }elsif($line =~/^Num_rois:\s*(\d+)\s*$/){
        $num_rois = $1;
      }elsif($line =~/^Error:\s*(\d+)\s*$/){
        my $err = $1;
        if($error){
          $error .= ";";
        }
        $error .= $err;
      }
    }
    close TASK;
    $error =~ s/""/"/g;
    $rpt->print("\"$size\",\"$num_rois\",,,,\"$error\"\n");
    next row;
  }
#"patient_id,study_instance_uid,series_instance_uid," .
#  "modality,num_files,size,num_rois,num_frac_groups,num_beams,num_dvhs," .
#  "error\n");
  if($modality eq 'RTPLAN'){
    if($files_found ne $num_files){
      $rpt->print(",,,,,\"More than one file for series in Public\"\n");
      next row;
    }
    my $size = "<not_found>";
    my $num_frac_grps = "<not_found>";
    my $num_beams = "<not_found>";
    my $error = "";
    open TASK, "RtPlanReport.pl \"$files[0]\"|";
    while(my $line = <TASK>){
      chomp $line; 
      if($line =~ /^Length:\s*(\d+)\s*$/){
        $size = $1;
      }elsif($line =~/^Num_frac_grps:\s*(\d+)\s*$/){
        $num_frac_grps = $1;
      }elsif($line =~/^Num_beams:\s*(\d+)\s*$/){
        $num_beams = $1;
      }elsif($line =~/^Error:\s*(\d+)\s*$/){
        my $err = $1;
        if($error){
          $error .= ";";
        }
        $error .= $err;
      }
    }
    close TASK;
    $error =~ s/""/"/g;
    $rpt->print("\"$size\",,\"$num_frac_grps\",\"$num_beams\",,\"$error\"\n");
    next row;
  }
  if($modality eq 'RTDOSE'){
    if($files_found ne $num_files){
      $rpt->print(",,,,,\"More than one file for series in Public\"\n");
      next row;
    }
    my $size = "<not_found>";
    my $num_dvhs = "<not_found>";
    my $error = "";
    open TASK, "RtDoseReport.pl \"$files[0]\"|";
    while(my $line = <TASK>){
      chomp $line; 
      if($line =~ /^Length:\s*(\d+)\s*$/){
        $size = $1;
      }elsif($line =~/^Num_dvh:\s*(\d+)\s*$/){
        $num_dvhs = $1;
      }elsif($line =~/^Error:\s*(\d+)\s*$/){
        my $err = $1;
        if($error){
          $error .= ";";
        }
        $error .= $err;
      }
    }
    close TASK;
    $error =~ s/""/"/g;
    $rpt->print("\"$size\",,,,\"$num_dvhs\",\"$error\"\n");
    next row;
  }
  my $size = 0;
  my $error = "";
  for my $file(@files){
    open TASK, "RtDefaultReport.pl \"$file\"|";
    while(my $line = <TASK>){
      chomp $line;
      if($line =~ /^Length:\s*(\d+)\s*$/){
        $size += $1;
      }elsif($line =~/^Error:\s*(\d+)\s*$/){
        my $err = $1;
        if($error){
          $error .= ";";
        }
        $error .= $err;
      }
    }
    close TASK;
  }
  $error =~ s/""/"/g;
  $rpt->print("\"$size\",,,,,\"$error\"\n");
}
my $elapsed = time - $start;
$background->WriteToEmail("Finished after $elapsed seconds\n");
$background->Finish;
