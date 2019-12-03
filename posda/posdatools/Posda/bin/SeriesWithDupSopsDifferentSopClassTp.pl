#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
#use Debug;
#sub MakeDebug{
#  my($back) = @_;
#  my $sub = sub{
#    my($str) = @_;
#    $back->WriteToEmail($str);
#  };
#  return $sub;
#}
my $usage = <<EOF;
SeriesWithDupSopsDifferentSopClassTp.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id>> - activity
  <notify> - user to notify

Expects nothing on <STDIN>

Constructs a spreadsheet with the following columns for all series:

Uses named queries:
   "DupSopsLatestTpByActivity"
   "DupSopsLatestTpBySopInstance"

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 3). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $notify) = @ARGV;

my %DupSops;;
Query("DupSopsLatestTpByActivity")->RunQuery(sub{
  my($row) = @_;
  $DupSops{$row->[0]} = 1;
}, sub {}, $activity_id);
my $num_dups = keys %DupSops;

print "Going to background to process $num_dups duplicate sops\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
#
#my $dbg = MakeDebug($back);
#
my $i = 0;
$back->WriteToEmail("Starting Duplicate SOP Report\n");
my $start = time;
my $q = Query("DupSopsLatestTpBySopInstance");
my $max_dups = 0;
my %DupDesc;
for my $sop (keys %DupSops){
  $i += 1;
  $back->SetActivityStatus("Processing $i of $num_dups");
  my $num_rows = 0;
  $q->RunQuery(sub{
    my($row) = @_;
    my $num_rows += 1;
    my($series_instance_uid, $sop_instance_uid,
       $dicom_file_type, $modality, $file_id) = @$row;
    $DupDesc{$sop_instance_uid}->{$series_instance_uid}->{$dicom_file_type}
      ->{$modality}->{$file_id} = 1;
  }, sub {}, $activity_id, $sop);
  if($num_rows > $max_dups) { $max_dups = $num_rows }
}
my $so_far = time - $start;
$back->WriteToEmail("Finished Processing after $so_far seconds\n");
$back->SetActivityStatus("Analyzing Results");
my %Analysis;
for my $sop (keys %DupDesc){
  for my $series (keys %{$DupDesc{$sop}}){
    for my $dft (keys %{$DupDesc{$sop}->{$series}}){
      for my $mod(keys %{$DupDesc{$sop}->{$series}->{$dft}}){
        my $num_files = keys %{$DupDesc{$sop}->{$series}->{$dft}->{$mod}};
        my $msg = "$series:$dft:$mod";
        unless(exists $Analysis{$msg}){
          $Analysis{$msg} = 0;
        }
        $Analysis{$msg} += $num_files;
      }
    }
  }
}
#$back->WriteToEmail("Analysis: ");
#Debug::GenPrint($dbg, \%Analysis, 1);
#$back->WriteToEmail("\n");
my %SecondaryAnalysis;
for my $msg (sort keys %Analysis){
  my $num_files = $Analysis{$msg};
  my($series, $dft, $mod) = split(/:/, $msg);
  $SecondaryAnalysis{$series}->{$dft}->{$mod} = $num_files;
}
my $rpt = $back->CreateReport("Duplicate Sop Report");
$rpt->print("Duplicate SOP Report\n");
$rpt->print("activity_id:,$activity_id\n");
$rpt->print("number of dup SOPS:,$num_dups\n");
my $time_tag = `date`;
chomp $time_tag;
$rpt->print("when:,$time_tag\n\n");
$rpt->print("series_instance_uid,dicom_file_type,modality,num_files\n");
for my $series (sort keys %SecondaryAnalysis){
  my $h1 = $SecondaryAnalysis{$series};
  for my $dft (sort keys %$h1){
    my $h2 = $h1->{$dft};
    for my $mod (sort keys %$h2){
      my $num_files = $h2->{$mod};
      $rpt->print("$series,$dft,$mod,$num_files\n");
    }
  }
}
my $rpt1 = $back->CreateReport("HideDupSopsSkeleton");
$rpt1->print("series_instance_uid,descriminator,value,Operation,activity_id,comment,notify\n");
my @Series = sort keys %SecondaryAnalysis;
for my $i (0 .. $#Series){
  my $series = $Series[$i];
  $rpt1->print("$series");
  if($i == 0){
    $rpt1->print(",,,KeepOnlyFilesDupFilesInTimepointAndSeriesWithMatchingDescriminator," .
      "$activity_id,From analysis in $invoc_id,$notify");
  }
  $rpt1->print("\n");
}
my $elapsed = time - $start;
$back->WriteToEmail("Finished in $elapsed seconds\n");
$back->Finish("Processed $num_dups duplicates in $elapsed seconds");;
