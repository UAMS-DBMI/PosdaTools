#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use Debug;
sub DebugToEmail{
  my($back) = @_;
  my $sub = sub {
    my($text) = @_;
    $back->WriteToEmail($text);
  };
  return $sub;
};

my $usage = <<EOF;
SummarizeStructLinkagesByFileId.pl <bkgrnd_id> <file_id> <notify>
or
SummarizeStructLinkagesByFileId.pl -h

The script doesn't expect lines on STDIN:

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 2){
  die "$usage\n";
}

my ($invoc_id, $file_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

print "Going straight to background\n";

$background->Daemonize;

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting SummarizeStructLinkagesByFileId.pl at $start_time\n");
$background->WriteToEmail("##### This is a test version of this script #####\n");

my %Rois;
my %Sops;
my %RoiNameToId;
my %ForUids;
my $DatasetStart;
my $FilePath;
my $Collection;
my $Site;
my $Patient;
my $Study;
my $Series;
my %SopsLookedUp;
my %CtSeriesSeen;

my $get_file_path = Query("GetFilePathWithCollSitePatientStudySeries");
$get_file_path->RunQuery(sub{
  my($row) = @_;
  $FilePath = $row->[0];
  $Collection = $row->[1];
  $Patient = $row->[2];
  $Site = $row->[3];
  $Study = $row->[4];
  $Series = $row->[5];
}, sub{}, $file_id);
my $get_dataset_start = Query("GetDatasetStart");
$get_dataset_start->RunQuery(sub{
  my($row) = @_;
  $DatasetStart = $row->[0];
}, sub{}, $file_id);
my $get_roi_info = Query("RoiInfoByFileIdWithCounts");
$get_roi_info->RunQuery(sub {
  my($row) = @_;
  my($roi_id, $for_uid, $linked_sop_instance_uid,
     $max_x, $max_y, $max_z, $min_x, $min_y,
     $min_z, $roi_name, $roi_description,
     $roi_interpreted_type, $contour_offset, $contour_length,
     $path) =
     @$row;
  $Rois{$roi_id}->{for_uid} = $for_uid;
  $ForUids{$for_uid}->{roi_ids}->{$roi_id} = 1;
  $Rois{$roi_id}->{max_x} = $max_x;
  $Rois{$roi_id}->{max_y} = $max_y;
  $Rois{$roi_id}->{max_z} = $max_z;
  $Rois{$roi_id}->{min_x} = $min_x;
  $Rois{$roi_id}->{min_y} = $min_y;
  $Rois{$roi_id}->{min_z} = $min_z;
  $Rois{$roi_id}->{roi_name} = $roi_name;
  $RoiNameToId{$roi_name} = $roi_id;
  $Rois{$roi_id}->{roi_description} = $roi_description;
  $Rois{$roi_id}->{roi_interpreted_type} = $roi_interpreted_type;
  $Rois{$roi_id}->{sop_links}->{$linked_sop_instance_uid} = $num_contours;
  $Sops{$linked_sop_instance_uid}->{has_roi_name}->{$roi_name} = 1;
}, sub {}, $file_id);
my $get_cont_info = Query('ContourInfoByRoiIdAndSopInst');
my $get_sop_geo = Query('GetImageGeoBySop1');
roi:
for my $roi_id (keys %Rois){
  for my $sop_uid (keys %{$Rois{$roi_id}->{sop_links}}){
    $get_cont_info->RunQuery(sub {
      my($row) = @_;
      my($contour_file_offset, $contour_length, $contour_digest,
        $num_points, $contour_type) = @$row;
      my $real_start = $DatasetStart + $contour_file_offset;
      my $cmd = "GetFilePart.pl \"$FilePath\" $real_start $contour_length";
      unless(open CONTOURS, "$cmd|"){
        $background->WriteToEmail("can't get contours");
        return;
      }
      my $contours;
      my $length = read CONTOURS, $contours, $contour_length;
      unless($length == $contour_length) {
        $background->WriteToEmail(
          "read wrong length $length vs $contour_length\n");
        return;
      }
## Digest check disabled - digests in DB are wrong!
#      my $ctx = Digest::MD5->new;
#      $ctx->add($contours);
#      my $dig = $ctx->hexdigest;
#      unless($dig eq $contour_digest){
#        $background->WriteToEmail(
#          "Non matching digests $dig vs $contour_digest\n");
#        $background->WriteToEmail(
#          "\troi_id: $roi_id, sop_inst: $sop_uid\n");
#      }
      my @nums = split /\\/, $contours;
      my $num_nums_read = @nums;
      my $nums_expected = $num_points * 3;
      unless($num_nums_read == $nums_expected){
        $background->WriteToEmail("Wrong number of numbers: " .
          "$num_nums_read vs $nums_expected " .
          "for $num_points points\n");
        return;
      }
      my @zs;
      for my $i (0 .. $num_points - 1){
        $zs[$i] = $nums[($i * 3) + 2];
      }
      unless(defined $Sops{$sop_uid}->{tot_z}){
        $Sops{$sop_uid}->{tot_z} = 0;
        $Sops{$sop_uid}->{num_z} = 0;
      }
      my $h = $Sops{$sop_uid};
      for my $z (@zs){
        unless(defined $h->{max_z}) { $h->{max_z} = $z } 
        unless(defined $h->{min_z}) { $h->{min_z} = $z }
        if($z < $h->{min_z}){ $h->{min_z} = $z }
        if($z > $h->{max_z}){ $h->{max_z} = $z }
        $h->{tot_z} += $z;
        $h->{num_z} += 1;
      }
      unless(exists $SopsLookedUp{$sop_uid}){
        $SopsLookedUp{$sop_uid} = 1;
        $get_sop_geo->RunQuery(sub {
          my($row) = @_;
          my($iop, $ipp, $for_uid, $series_instance_uid) = @$row;
          $h->{iop} = $iop;
          $h->{ipp} = $ipp;
          $h->{for_uid} = $for_uid;
          $CtSeriesSeen{$series_instance_uid} += 1;
          $ForUids{$for_uid}->{sop}->{$sop_uid} = 1;
        }, sub {}, $sop_uid);
      }
    }, sub{}, $sop_uid, $roi_id);
  }
}
my $rpt = $background->CreateReport("Structure Set Summary");
$rpt->print("key,value\r\n");
$rpt->print("Script,SummarizeStructLinkagesByFileId.pl\r\n");
$rpt->print("At,$start_time\r\n");
$rpt->print("By,$notify\r\n");
$rpt->print("File id,$file_id\r\n");
$rpt->print("Collection,$Collection\r\n");
$rpt->print("Site,$Site\r\n");
$rpt->print("Study,$Study\r\n");
$rpt->print("Series,$Series\r\n");
for my $series (keys %CtSeriesSeen){
  $rpt->print("Ct Series,$series ($CtSeriesSeen{$series})\r\n");
}
$rpt->print("\r\n");
for my $sop(keys %Sops){
  if($Sops{$sop}->{min_z} eq $Sops{$sop}->{max_z}){
    $Sops{$sop}->{contour_offset} = $Sops{$sop}->{min_z};
  } else {
    $Sops{$sop}->{contour_offset} =
      $Sops{$sop}->{tot_z} / $Sops{$sop}->{num_z};
  }
  if(exists $Sops{$sop}->{ipp}){
    my($x, $y, $z) = split(/\\/, $Sops{$sop}->{ipp});
    $Sops{$sop}->{file_present} = "yes";
    $Sops{$sop}->{ct_offset} = $z;
  } else {
    $Sops{$sop}->{file_present} = "no";
    $Sops{$sop}->{ct_offset} = "";
  }
}
my @cols = ("sop_instance_uid", "roi_offset", 
  "file_present", "file_offset");
for my $roi_name (sort keys %RoiNameToId){
  push @cols, $roi_name;
}
for my $i (0 .. $#cols){
  $rpt->print("$cols[$i]");
  if($i == $#cols){
    $rpt->print("\r\n");
  } else {
    $rpt->print(",");
  }
}
for my $sop (
  sort {
    $Sops{$a}->{contour_offset} <=>
    $Sops{$b}->{contour_offset}
  }
  keys %Sops
){
  for my $i (0 .. $#cols){
    my $col = $cols[$i];
    if($col eq "sop_instance_uid"){
      $rpt->print("$sop,");
    }elsif($col eq "roi_offset") {
      $rpt->print("$Sops{$sop}->{contour_offset},");
    }elsif($col eq "file_present"){
      $rpt->print("$Sops{$sop}->{file_present},");
    }elsif($col eq "file_offset"){
      $rpt->print("$Sops{$sop}->{ct_offset},");
    } else {
      if(exists $RoiNameToId{$col}){
        my$roi_id = $RoiNameToId{$col};
        if(exists $Rois{$roi_id}->{sop_links}->{$sop}){
          $rpt->print($Rois{$roi_id}->{sop_links}->{$sop});
        }
      }
      if($i == $#cols){
        $rpt->print("\r\n");
      } else {
        $rpt->print(",");
      }
    }
  }
} 
#my $bg = DebugToEmail($background);
#$background->WriteToEmail("Debug Info:\nRois ");
#Debug::GenPrint($bg, \%Rois, 1);
#$background->WriteToEmail("\nSops ");
#Debug::GenPrint($bg, \%Sops, 1);
#$background->WriteToEmail("\nRoiNameToId ");
#Debug::GenPrint($bg, \%RoiNameToId, 1);
#$background->WriteToEmail("\n");
$background->Finish;
