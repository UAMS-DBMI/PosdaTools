#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::ActivityInfo;
use Posda::BackgroundProcess;
use Posda::BackgroundComparePublicPosda;
use Debug;
my $dbg = sub { print STDERR @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
CompareSopsInTpToPublic.pl <?bkgrnd_id?> <activity_id> <notify>
  or
CompareSopsInTpToPublic.pl -h
Expects no lines on STDIN
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 2) { print $usage; exit }

#die "Not yet implemented";

my($invoc_id, $act_id, $notify) = @ARGV;

my $start;
#############################
# This is code which sets up the Background Process and Starts it
print "Going to background to do comparisons and generate report\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;
my $act = Posda::ActivityInfo->new($act_id);
unless(defined $act) { die "No activity $act_id" }
my $tp_id = $act->LatestTimepoint;
#print "Timepoint id: $tp_id\n";
my $FileInfo = $act->GetFileInfoForTp($tp_id);
$back->WriteToEmail("CompareSopsInTpToPublic.pl\n".
  "activity_id: $act_id\n" .
 "time_point_id: $tp_id\n"); 
my %SopsInPosda;
my $get_p = Query('FilePathByFileId');
for my $f (keys %$FileInfo){
  my $i = $FileInfo->{$f};
  if(exists $SopsInPosda{$i->{sop_instance_uid}}){
    $back->WriteToEmail("$i->{sop_instance_uid} is duplicated in Posda\n");
  }
  my $path;
  $get_p->RunQuery(sub{
    my($row) = @_;
    $path = $row->[0];
  }, sub {}, $f);
  $i->{path} = $path;
  $SopsInPosda{$i->{sop_instance_uid}} = $i;
}
my $PublicFileInfo;
my $sq = Query('GetFilePathPublic');
for my $s (keys %SopsInPosda){
  $sq->RunQuery(sub {
    my($row) = @_;
    my $path  = $row->[0];
    if($path =~ /(storage.*)$/){
      $path = "/nas/public/$1";
    }
    $SopsInPosda{$s}->{public_path} = $path;
  }, sub {}, $s);
}
my %FilesOnlyInPosda;
for my $s (keys %SopsInPosda){
  unless(exists $SopsInPosda{$s}->{public_path}){
    my $f = $SopsInPosda{$s}{file_id};
    $FilesOnlyInPosda{$f} = $SopsInPosda{$s};
  }
}
#print STDERR "SopsInPosda: ";
#Debug::GenPrint($dbg, \%SopsInPosda, 1);
#print STDERR "\n";
#exit;
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

my $num_sops = keys %SopsInPosda;
Query('CreateComparePublicToPosdaInstance')->RunQuery(
sub{ }, sub{}, $num_sops);
my $inst_id;
Query('GetComparePublicToPosdaInstanceId')->RunQuery(
sub {
  my($row) = @_;
  $inst_id = $row->[0];
}, sub {});

sub MakeEditor{
  my($sop_hash, $inst_id) = @_;
  my $sub = sub {
    my($disp) = @_;
    Posda::BackgroundComparePublicPosda->new(
      $sop_hash, $inst_id, $notify, $back);
  };
  return $sub;
}
{
  Dispatch::Select::Background->new(
    MakeEditor(\%SopsInPosda, $inst_id, $notify, $back))->queue;
}
Dispatch::Select::Dispatch();
