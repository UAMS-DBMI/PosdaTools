#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::ActivityInfo;
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print STDERR @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
FilesInLatestActivityNotInPublic.pl <?bkgrnd_id?> <activity_id> <notify>
  or
FilesInLatestActivityNotInPublic.pl -h
Expects no lines on STDIN
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 2) { print $usage; exit }

my($invoc_id, $act_id, $notify) = @ARGV;

my $start;
#############################
# This is code which sets up the Background Process and Starts it
print "Going to background to create report\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$back->Daemonize;

my $act = Posda::ActivityInfo->new($act_id);
unless(defined $act) { die "No activity $act_id" }
my $tp_id = $act->LatestTimepoint;
#print "Timepoint id: $tp_id\n";
my $FileInfo = $act->GetFileInfoForTp($tp_id);
my $TpHierarchy = $act->MakeFileHierarchyFromInfo($FileInfo);
#print "TpHierarchy\n";
#Debug::GenPrint($dbg, $TpHierarchy, 1, 3);
#print "\n";
$back->WriteToEmail("ScriptInLatestActivityNotInPublic.pl\n".
  "activity_id: $act_id\n" .
  "time_point_id: $tp_id\n");
my %SopsInPosda;
for my $f (keys %$FileInfo){
  my $i = $FileInfo->{$f};
  if(exists $SopsInPosda{$i->{sop_instance_uid}}){
    $back->WriteToEmail("$i->{sop_instance_uid} is duplicated in Posda\n");
  }
  $SopsInPosda{$i->{sop_instance_uid}} = $FileInfo->{$f};
  $SopsInPosda{$i->{sop_instance_uid}} = $FileInfo->{$f};
}
my $PublicFileInfo;
my $sq = Query('WhereSopSitsPublic');
for my $s (keys %SopsInPosda){
  $sq->RunQuery(sub {
    my($row) = @_;
    my($collection, $site, $patient_id,
      $study_instance_uid, $series_instance_uid) = @$row;
    $PublicFileInfo->{$s}->{collection} = $collection;
    $PublicFileInfo->{$s}->{site} = $site;
    $PublicFileInfo->{$s}->{patient_id} = $patient_id;
    $PublicFileInfo->{$s}->{study_instance_uid} = $study_instance_uid;
    $PublicFileInfo->{$s}->{series_instance_uid} = $series_instance_uid;
  }, sub {}, $s);
}
my %FilesOnlyInPosda;
for my $s (keys %SopsInPosda){
  unless(exists $PublicFileInfo->{$s}){
    my $f = $SopsInPosda{$s}->{file_id};
    $FilesOnlyInPosda{$f} = $SopsInPosda{$s};
  }
}
my $num_lost_files = keys %FilesOnlyInPosda;
if($num_lost_files > 0){
  my $HierarchyOnlyInPosda = $act->MakeFileHierarchyFromInfo(\%FilesOnlyInPosda);
#print STDERR "Hierarchy: ";
#Debug::GenPrint($dbg, $HierarchyOnlyInPosda, 1);
#print STDERR "\n";
  my $rpt = $back->CreateReport("Files in TP, but not in Public");
  $act->PrintHierarchyReport($rpt, $HierarchyOnlyInPosda);
} else {
  $back->WriteToEmail("All files in TP are in Public\n");
}
my $rpt1 = $back->CreateReport("List of FileIds");
$rpt1->print("file_id\n");
for my $f (keys %FilesOnlyInPosda){
  $rpt1->print("$f\n");
}
my $num_files = keys %FilesOnlyInPosda;

$back->Finish("$num_files found");
