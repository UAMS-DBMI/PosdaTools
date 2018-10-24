#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
MakeRtReport1.pl <invoc_id> <notify_email>
or
MakeRtReport1.pl -h

Generates a csv report file
Sends email when done
Expect input lines in following format:
<coll>&<site>&<patient_id>&<study_id>&<series_id>&<file_type>&<modality>&<num_files>
EOF
unless($#ARGV == 1 ){ print "$usage\n"; die $usage }
my @Lines;
while(my $line = <STDIN>){
  chomp $line;
  my($coll, $site, $pat_id, $study_uid, 
    $series_uid, $ft, $modality, $num_files) = split(/&/, $line);
  push(@Lines, [$coll, $site, $pat_id, $study_uid,
    $series_uid, $ft, $modality, $num_files]);
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
my $q = Query("FilesInSeries");
my $rpt = $background->CreateReport("RtReport");
$rpt->print("collection,site,patient_id,study_instance_uid," .
  "series_instance_uid,file_type,modality,num_files,num_rois," .
  "num_links,linked_study,linked_series," .
  "error\n");
row:
for my $row (@Lines){
  my($coll, $site, $pat_id, $study_uid, $series_uid, 
    $ft, $modality, $num_files) = @$row;
  if($ft ne "RT Structure Set Storage"){
    $rpt->print("\"$coll\",\"$site\",\"$pat_id\"," .
      "\"$study_uid\",\"$series_uid\"," .
      "\"$ft\",\"$modality\",\"$num_files\",,,,,\n");
    next row;
  }
  my @files;
  $q->RunQuery(sub{
    my($row) = @_;
    my $path = $row->[0];
#    if($path =~ /^.*storage(.*)$/){
#      my $convert_path = "/nas/public/storage$1";
    push @files, $path;
#    }
  }, sub {}, $series_uid);
  my $files_found = @files;
  $rpt->print("\"$coll\",\"$site\",\"$pat_id\",\"$study_uid\"," .
    "\"$series_uid\",\"$ft\",\"$modality\"," .
    "\"$num_files\",");
  if($files_found ne $num_files){
    $rpt->print(",,,,\"wrong num files found: $files_found vs $num_files\"\n");
    next row;
  }
  my $size = "<not_found>";
  my $num_rois = "<not_found>";
  my $num_links = "<not_found>";
  my $linked_study = "<not_found>";
  my $linked_series = "<not_found>";
  my $error = "";
  open TASK, "RtStructReport.pl \"$files[0]\"|";
  while(my $line = <TASK>){
    chomp $line; 
    if($line =~ /^Length:\s*(\d+)\s*$/){
      $size = $1;
    }elsif($line =~/^Num_rois:\s*(\d+)\s*$/){
      $num_rois = $1;
    }elsif($line =~/^Num_links:\s*(\d+)\s*$/){
      $num_links = $1;
    }elsif($line =~/^Linked_study:\s*(.+)\s*$/){
      $linked_study = $1;
    }elsif($line =~/^Linked_series:\s*(.+)\s*$/){
      $linked_series = $1;
    }elsif($line =~/^Error:\s*(.+)\s*$/){
      my $err = $1;
      if($error){
        $error .= ";";
      }
      $error .= $err;
    }
  }
  close TASK;
  $error =~ s/""/"/g;
  $rpt->print("\"$num_rois\",\"$num_links\",\"$linked_study\",\"" .
    "$linked_series\",\"$error\"\n");
}
my $elapsed = time - $start;
$background->WriteToEmail("Finished after $elapsed seconds\n");
$background->Finish;
