#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::ActivityInfo;
use Debug;
my $dbg = sub { print @_ };
sub MakeBackDeb{
  my($back) = @_;
  my $sub = sub { $back->WriteToEmail(@_) };
  return $sub;
}
$| = 1; # this should probably be at the top of the script, maybe in the lib?

#die "not finished implementation";
my $usage = <<EOF;
Usage:
ModifySeriesInActivityTimepoint.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>
  or
ModifySeriesInActivityTimepoint.pl -h

Expects lines on STDIN:
<series_instance_uid>&<function>

<function> is one of the following:
   HideEarlyDupSopsInSeries    - Hide earliest dup sops in series
   HideLateDupSopsInSeries     - Hide latest dup sops in series
   HideSeries                  - Hide all files in series
                                 (will also delete from timepoint)
   DeleteSeriesFromTp          - Delete the series from the timepoint
                                 (but don't hide it in Posda)
   AddSeriesToTp               - Add the series to the timepoint
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }
unless($#ARGV == 3) { print $usage; exit }
my($invoc_id, $act_id, $comment, $notify) = @ARGV;
my %SeriesToHideEarlyDupSops;
my %SeriesToHideLateDupSops;
my %SeriesToHide;
my %SeriesToDeleteFromTp;
my %SeriesToAddToTp;
my $errors = 0;
while(my $line = <STDIN>){
  chomp $line;
  my($series_uid, $function) = split(/&/, $line);
  if($function eq "HideEarlyDupSopsInSeries"){
    $SeriesToHideEarlyDupSops{$series_uid} = 1;
  }elsif($function eq "HideLateDupSopsInSeries"){
    $SeriesToHideLateDupSops{$series_uid} = 1;
  }elsif($function eq "HideSeries"){
    $SeriesToHide{$series_uid} = 1;
  }elsif($function eq "DeleteSeriesFromTp"){
    $SeriesToDeleteFromTp{$series_uid} = 1;
  }elsif($function eq "AddSeriesToTp"){
    $SeriesToAddToTp{$series_uid} = 1;
  }
}
for my $s (keys %SeriesToHideEarlyDupSops){
  if(exists $SeriesToHideLateDupSops{$s}){
    print "Error: series $s is in both HideEarlySops and HideLateSops\n";
    $errors += 1;
  }
  if(exists $SeriesToHide{$s}){
    print "Error: series $s is in both HideEarlySops and Hide\n";
    $errors += 1;
  }
  if(exists $SeriesToDeleteFromTp{$s}){
    print "Error: series $s is in both HideEarlySops and DeleteFromTimepoint\n";
    $errors += 1;
  }
  if(exists $SeriesToDeleteFromTp{$s}){
    print "Error: series $s is in both HideEarlySops and DeleteFromTimepoint\n";
    $errors += 1;
  }
  if(exists $SeriesToAddToTp{$s}){
    print "Error: series $s is in both HideEarlySops and AddToTimepoint\n";
    $errors += 1;
  }
}
for my $s (keys %SeriesToHideLateDupSops){
  if(exists $SeriesToHide{$s}){
    print "Error: series $s is in both HideLateSops and Hide\n";
    $errors += 1;
  }
  if(exists $SeriesToDeleteFromTp{$s}){
    print "Error: series $s is in both HideLateSops and DeleteFromTimepoint\n";
    $errors += 1;
  }
  if(exists $SeriesToDeleteFromTp{$s}){
    print "Error: series $s is in both HideLateSops and DeleteFromTimepoint\n";
    $errors += 1;
  }
  if(exists $SeriesToAddToTp{$s}){
    print "Error: series $s is in both HideLateSops and AddToTimepoint\n";
    $errors += 1;
  }
}
for my $s (keys %SeriesToHide){
  if(exists $SeriesToDeleteFromTp{$s}){
    print "Error: series $s is in both Hide and DeleteFromTimepoint\n";
    $errors += 1;
  }
  if(exists $SeriesToDeleteFromTp{$s}){
    print "Error: series $s is in both Hide and DeleteFromTimepoint\n";
    $errors += 1;
  }
  if(exists $SeriesToAddToTp{$s}){
    print "Error: series $s is in both Hide and AddToTimepoint\n";
    $errors += 1;
  }
}
for my $s (keys %SeriesToDeleteFromTp){
  if(exists $SeriesToAddToTp{$s}){
    print "Error: series $s is in both DeleteFromTimepoint and AddToTimepoint\n";
    $errors += 1;
  }
}
if($errors > 0){
  print "$errors errors prevent going to background\n";
}
print "Going to background\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
######################################################
my $backD = MakeBackDeb($background);
$background->WriteToEmail(
  "Starting script: ModifySeriesInActivityTimepoint.pl\n" .
  "Activity_id: $act_id\n" .
  "Comment: $comment\n" .
  "Notify: $notify\n");
my $start = time;
my $ActInfo = Posda::ActivityInfo->new($act_id);
my $current_tp_id = $ActInfo->LatestTimepoint;
my $CurrentTpFileInfo = $ActInfo->GetFileInfoForTp($current_tp_id);
my($CurrentTpSeriesWithDups, $CurrentTpDupReport) = $ActInfo->SeriesDupReport($CurrentTpFileInfo);

my %SeriesInCurrentTp;
for my $f (keys %{$CurrentTpFileInfo}){
  my $s = $CurrentTpFileInfo->{$f}->{series_instance_uid};
  $SeriesInCurrentTp{$s} = 1;
}
my $num_HideEarly = keys %SeriesToHideEarlyDupSops;
my $num_HideLate = keys %SeriesToHideLateDupSops;
my %SopDupReport;
if(
  $num_HideEarly > 0 ||
  $num_HideLate > 0
){
  for my $s (keys %$CurrentTpDupReport){
    my $s_DupR = $CurrentTpDupReport->{$s};
    # build s_rpt = {
    #   <sop> = [
    #     [$date, $file_id],
    #     ...
    #   ],
    #   ...
    # }
    my %s_rept;
    for my $d (sort keys %{$s_DupR}){
      my $sop_hash = $s_DupR->{$d}->{sops};
      for my $sop (keys %{$sop_hash}){
        unless(exists $s_rept{$sop}){
          $s_rept{$sop} = [];
        }
        for my $f (sort { $a <=> $b} keys %{$sop_hash->{$sop}}){
          push @{$s_rept{$sop}}, [$d, $f];
        }
      }
    }
    $SopDupReport{$s} = \%s_rept;
  }
}
my %FileIdsToHide;
######### Hide Early Dup Sops #########################
for my $s (keys %SeriesToHideEarlyDupSops){
$background->WriteToEmail("For Series $s:\n");
  if(exists $SopDupReport{$s}){
    my $s_rpt = $SopDupReport{$s};
    ######### Here is where hides are done  
    sop:
    for my $sop(keys %$s_rpt){
      my $nf = @{$s_rpt->{$sop}};
      if($nf < 2){
        $background->WriteToEmail(
         "problem in DupSop report - " .
         "$sop has no duplicates\n");
        next sop;
      }
      $background->WriteToEmail("$nf files for sop $sop\n");
      my $num_f = $#{$s_rpt->{$sop}};
      for my $i (0 .. $num_f - 1) {
        my $date = $s_rpt->{$sop}->[$i]->[0];
        my $f_id = $s_rpt->{$sop}->[$i]->[1];
        $FileIdsToHide{$f_id} = 1;
        $background->WriteToEmail("\tdelete $f_id ($date)\n");
      }
      my $date = $s_rpt->{$sop}->[$num_f]->[0];
      my $f_id = $s_rpt->{$sop}->[$num_f]->[1];
      $background->WriteToEmail("\tleave $f_id ($date)\n");
    }
  } else {
    $background->WriteToEmail("Series $s is specifed " .
      "for HideEarlyDupSop, but has no Dups in report\n");
  }
}
######### Hide Late Dup Sops #########################
for my $s (keys %SeriesToHideLateDupSops){
$background->WriteToEmail("For Series $s:\n");
  if(exists $SopDupReport{$s}){
    my $s_rpt = $SopDupReport{$s};
    ######### Here is where hides are done  
    sop:
    for my $sop(keys %$s_rpt){
      my $nf = @{$s_rpt->{$sop}};
      if($nf < 2){
        $background->WriteToEmail(
         "$sop has no duplicates\n");
        next sop;
      }
      $background->WriteToEmail("$nf files for sop $sop\n");
      my $num_f = $#{$s_rpt->{$sop}};
      for my $i (1 .. $num_f - 0) {
        my $date = $s_rpt->{$sop}->[$i]->[0];
        my $f_id = $s_rpt->{$sop}->[$i]->[1];
        $FileIdsToHide{$f_id} = 1;
        $background->WriteToEmail("\tdelete $f_id ($date)\n");
      }
      my $date = $s_rpt->{$sop}->[0]->[0];
      my $f_id = $s_rpt->{$sop}->[0]->[1];
      $background->WriteToEmail("\tleave $f_id ($date)\n");
    }
  } else {
    $background->WriteToEmail("Series $s is specifed " .
      "for HideLate, but has no Dups in report\n");
  }
}
######### Hide Sops in Series ########################
my $num_series_to_hide = keys %SeriesToHide;
$background->WriteToEmail("$num_series_to_hide series to hide\n");
if($num_series_to_hide > 0){
  for my $f (keys $CurrentTpFileInfo){
    my $series_uid = $CurrentTpFileInfo->{$f}->{series_instance_uid};   
    if(exists $SeriesToHide{$series_uid}){ 
      $FileIdsToHide{$f} = 1;
    }
  }
  my $num_files_to_hide = keys %FileIdsToHide;
  $background->WriteToEmail("$num_files_to_hide files_ids found for hiding\n");
} else {
  $background->WriteToEmail("No series specified for hiding.\n");
}
#########Actual Hides take place here################
my $num_files_to_hide = keys %FileIdsToHide;
if($num_files_to_hide > 0){
  my $start_hide = time;
  open HIDER, "|HideFilesWithStatus.pl $notify " .
    "\"see background invocation $invoc_id\"" or 
    die "Can't open pipe to HideFilesWithStatus";
  for my $f (keys %FileIdsToHide){
    print HIDER "$f&<undef>\n";
  }
  close HIDER;
  my $hide_time = time - $start_hide;
  $background->WriteToEmail( "Hide $num_files_to_hide in $hide_time seconds\n");
} else {
  $background->WriteToEmail("No files to hide\n");
}
#########Generate Old Tp Reports#######################
my $when = `date`;
chomp $when;
my $ModCurrentTpFileInfo = $ActInfo->GetFileInfoForTp($current_tp_id);
my $mod_cur_fh = $ActInfo->MakeFileHierarchyFromInfo(
  $ModCurrentTpFileInfo);
my $rpt1 = $background->CreateReport("Old Timepoint After Changes");
$rpt1->print("Timepoint Report after hides, " .
  "before new timepoint created\r\n");
$rpt1->print("key,value\r\n");
$rpt1->print("report,\"Timepoint Content Report\"\r\n");
$rpt1->print("script,\"$0\"\r\n");
$rpt1->print("old_tp_id,$current_tp_id\r\n");
$rpt1->print("activity_id,$act_id\r\n");
$rpt1->print("when,$when\r\n");
$rpt1->print("who,$notify\r\n");
$rpt1->print("\r\n");
$ActInfo->PrintHierarchyReport($rpt1, $mod_cur_fh);

my $mod_cur_cfh = $ActInfo->MakeCondensedHierarchyFromInfo(
  $ModCurrentTpFileInfo);
my $rpt2 = $background->CreateReport("Condensed Old Timepoint After Changes");
$rpt2->print("Condensed Timepoint Report after hides, " .
  "before new timepoint created\r\n");
$rpt2->print("key,value\r\n");
$rpt2->print("report,\"Condensed Timepoint Content Report\"\r\n");
$rpt2->print("script,\"$0\"\r\n");
$rpt2->print("old_tp_id,$current_tp_id\r\n");
$rpt2->print("activity_id,$act_id\r\n");
$rpt2->print("when,$when\r\n");
$rpt2->print("who,$notify\r\n");
$rpt2->print("\r\n");
$ActInfo->PrintCondensedHierarchyReport($rpt2, $mod_cur_cfh);
#########Delete Series for Creating new tp############
for my $s (keys %SeriesToDeleteFromTp){
  delete $SeriesInCurrentTp{$s};
}
#########Add Series for Creating new tp###############
for my $s (keys %SeriesToAddToTp){
  $SeriesInCurrentTp{$s} = 1;
}
#########Create new Tp from Series List###############
$ActInfo->CreateTpFromSeriesList(\%SeriesInCurrentTp, 
  $comment, $notify);
my $new_tp_id = $ActInfo->LatestTimepoint;
#########Generate New Tp Reports#######################
my $when1 = `date`;
chomp $when1;
my $ModNewTpFileInfo = $ActInfo->GetFileInfoForTp($new_tp_id);
my $mod_new_fh = $ActInfo->MakeFileHierarchyFromInfo(
  $ModNewTpFileInfo);
my $rpt3 = $background->CreateReport("New Timepoint After Changes");
$rpt3->print("Timepoint Creation Report\r\n");
$rpt3->print("key,value\r\n");
$rpt3->print("report,\"Timepoint Content Report\"\r\n");
$rpt3->print("script,\"$0\"\r\n");
$rpt3->print("new_tp_id,$new_tp_id\r\n");
$rpt3->print("activity_id,$act_id\r\n");
$rpt3->print("when,$when1\r\n");
$rpt3->print("who,$notify\r\n");
$rpt3->print("\r\n");
$ActInfo->PrintHierarchyReport($rpt3, $mod_new_fh);

my $mod_new_cfh = $ActInfo->MakeCondensedHierarchyFromInfo(
  $ModNewTpFileInfo);
my $rpt4 = $background->CreateReport("Condensed New Timepoint After Changes");
$rpt4->print("Condensed Timepoint Creation Report");
$rpt4->print("key,value\r\n");
$rpt4->print("report,\"Condensed Timepoint Content Report\"\r\n");
$rpt4->print("script,\"$0\"\r\n");
$rpt4->print("old_tp_id,$new_tp_id\r\n");
$rpt4->print("activity_id,$act_id\r\n");
$rpt4->print("when,$when1\r\n");
$rpt4->print("who,$notify\r\n");
$rpt4->print("\r\n");
$ActInfo->PrintCondensedHierarchyReport($rpt4, $mod_new_cfh);
######################################################

$background->Finish;
