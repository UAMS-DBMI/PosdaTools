#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;

my $usage = <<EOF;
CheckStructLinkagesTpId.pl <?bkgrnd_id?> <activity_id> <notify>
or
CheckStructLinkagesTpId.pl -h

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

my ($invoc_id, $act_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

print "Going straight to background\n";

$background->ForkAndExit;

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting  PopulateFileRoiImageLinkages.pl at $start_time\n");
$background->WriteToEmail("##### This is a test version of this script #####\n");
close STDOUT;
close STDIN;
print STDERR "Starting  PopulateFileRoiImageLinkages.pl at $start_time\n";
open PIPE, "PopulateFileRoiImageLinkages.pl|";
$background->WriteToEmail("Running PopulateFileRoiImageLinkages.pl:\n");
while(my $line = <PIPE>){
  chomp $line;
  $background->WriteToEmail(">>>>$line\n");
}
my $now = `date`;
chomp $now;
$background->WriteToEmail("$now: finished PopulateFileRoiImageLinkages.pl:\n");

my $OldActTpId;
my $OldActTpComment;
my $OldActTpDate;
my %FilesInOldTp;
my %SeriesInOldTp;
Query('LatestActivityTimepointsForActivity')->RunQuery(sub{
  my($row) = @_;
  my($activity_id, $activity_created,
    $activity_description, $activity_timepoint_id,
    $timepoint_created, $comment, $creating_user) = @$row;
  $OldActTpId = $activity_timepoint_id;
  $OldActTpComment = $comment;
  $OldActTpDate = $timepoint_created;
}, sub {}, $act_id);
Query('FileIdsByActivityTimepointId')->RunQuery(sub {
  my($row) = @_;
  $FilesInOldTp{$row->[0]} = 1;
}, sub {}, $OldActTpId);
my $q = Query('SeriesForFile');
for my $file_id(keys %FilesInOldTp){
  $q->RunQuery(sub {
    my($row) = @_;
    $SeriesInOldTp{$row->[0]} = 1;
  }, sub {}, $file_id);
}
my @Rows;
my $get_structs = Query("GetSsByFileId");
for my $file_id (keys %FilesInOldTp){
  $get_structs->RunQuery(sub {
    my($row) = @_;
    my @copied = @$row;
    push @Rows, \@copied;
  }, sub {}, $file_id);
}

my @cols =  ("Collection", "Site", "Patient", "FileId",
  "NumRois", "SopsInVol", "SopsLinkedToRoi",
  "InternalLinkages", "FrameOfRefExternal", "VolumeFilesInPosda", "VolumeFilesInPublic",
  "RoiFilesInPosda", "RoiFilesInPublic", "FrameOfReferenceMatches",
  "UnlinkedClosedPlanar", "PointsWithinVolume", "Warnings");
my %ColHeaders = (
  "Collection" => "Collection",
  "Site" => "Site",
  "Patient" => "Patient",
  "FileId" => "File Id",
  "NumRois" => "Number Rois",
  "SopsInVol" => "Sops in Volume",
  "SopsLinkedToRoi" => "Sops Linked To Roi",
  "InternalLinkages" => "Internal Linkages Consistent",
  "FrameOfRefExternal" => "Files Linked in Ref FOR has proper FOR",
  "VolumeFilesInPosda" => "Volume Files In Posda",
  "VolumeFilesInPublic" => "Volume Files In Public",
  "RoiFilesInPosda" => "Roi Files In Posda",
  "RoiFilesInPublic" => "Roi Files In Public",
  "FrameOfReferenceMatches" => "Frame of Reference Matches",
  "UnlinkedClosedPlanar" => "Unlinked Closed Planar Contours",
  "PointsWithinVolume" => "Points Within Volume",
  "Warnings" => "Warnings"
);
my $num_rows = @Rows;
$background->WriteToEmail("$num_rows structure sets found\n");
my $rpt = $background->CreateReport("StructLinkages");
for my $i (0 .. $#cols){
  $rpt->print("\"$ColHeaders{$cols[$i]}\"");
  if($i == $#cols){
    $rpt->print("\r\n");
  } else {
    $rpt->print(",");
  }
}
my $get_rois = Query("RoiInfoByFileId");
my $get_contour_types = Query("ContourTypesByRoi");
my $get_struct_vol = Query("StructVolByFileId");
my $get_contour_links = Query("GetContourImageLinksByFileId");
my $get_unlinked_closed_p = Query("ClosedPlanarContoursWithoutLinksByFile");
my $file_in_posda = Query("FileWithInfoBySopInPosda");
my $file_in_public = Query("FileWithInfoBySopInPublic");
my $get_roi_linkages = Query("RoiLinkagesByFileId");
my $get_for_from_series = Query("ImageFrameOfReferenceBySeries");
my $start_loop = time;
for my $row(@Rows){
  my %RowInfo;
  $RowInfo{Collection} = $row->[0];
  $RowInfo{Site} = $row->[1];
  $RowInfo{Patient} = $row->[2];
  $RowInfo{FileId} = $row->[3];
  NumRois(\%RowInfo);
  SopsInVol(\%RowInfo);
  SopsLinkedToRoi(\%RowInfo);
  InternalLinkages(\%RowInfo);
  FrameOfRefExternal(\%RowInfo);
  VolumeFilesInPosda(\%RowInfo);
  VolumeFilesInPublic(\%RowInfo);
  RoiFilesInPosda(\%RowInfo);
  RoiFilesInPublic(\%RowInfo);
  FrameOfReferenceMatches(\%RowInfo);
  UnlinkedClosedPlanar(\%RowInfo);
  PointsWithinVolume(\%RowInfo);
  Warnings(\%RowInfo);
  for my $i (0 .. $#cols){
    $rpt->print("\"$RowInfo{$cols[$i]}\"");
    if($i == $#cols){
      $rpt->print("\r\n");
    } else {
      $rpt->print(",");
    }
  }
}
my $loop_elapsed = time - $start_loop;
$background->WriteToEmail("Loop finished after " .
   "$loop_elapsed seconds\n");
$background->Finish;
sub NumRois{
  #  $RowInfo->{Rois}->{$roi_id} = {
  #    for_uid => $for_uid,
  #    max => [$max_x, $max_y, $max_z],
  #    min => [$min_x, $min_y, $min_z],
  #    roi_name => <roi_name>,
  #    roi_description => <roi_description>,
  #    roi_interp_type => <roi_interp_type>,
  #    roi_num => <roi_num>
  #  };
  my($RowInfo) = @_;
  $get_rois->RunQuery(sub {
    my($row) = @_;
    my($roi_id, $for_uid, $max_x, $max_y, $max_z,
      $min_x, $min_y, $min_z, $roi_name, $roi_desc,
      $roi_interp_type, $roi_num) = @$row;
     $RowInfo->{Rois}->{$roi_id} = {
       for_uid => $for_uid,
       max => [$max_x, $max_y, $max_z],
       min => [$min_x, $min_y, $min_z],
       roi_name => $roi_name,
       roi_description => $roi_desc,
       roi_interp_type => $roi_interp_type,
       roi_num => $roi_num,
     };
  }, sub {}, $RowInfo->{FileId});
  for my $roi_id (keys %{$RowInfo->{Rois}}){
    my %ContourTypes;
    $get_contour_types->RunQuery(sub {
      my($row) = @_;
      my($geo_type, $num_contours, $total_points) = @$row;
      $ContourTypes{$geo_type} = [$num_contours, $total_points];
    }, sub {}, $roi_id);
    my $num_types = keys %ContourTypes;
    if($num_types > 1){
      my @ContourTypes = keys %ContourTypes;
      my $message = "Roi ($roi_id), named " .
        "$RowInfo->{Rois}->{$roi_id}->{roi_name} has contours with " .
        "more than one geometric type: ";
      for my $i (0 .. $#ContourTypes){
        $message .= "\"$ContourTypes[$i]\"";
        if($i <= $#ContourTypes){
          $message .= ", ";
        }
      }
      push @{$RowInfo->{WarningList}}, $message;
    }
    for my $i (keys %ContourTypes){
      $RowInfo->{RoiByContourType}->{$i}->{$roi_id} =
        $RowInfo->{Rois}->{$roi_id};
    }
  }
  $RowInfo->{NumRois} = keys %{$RowInfo->{Rois}};
}
sub SopsInVol{
  #  $RowInfo{SopsInVolStruct}->{$sop_inst_uid} = [
  #    $sop_class, $study_inst, $series_inst, $for_uid
  #  ];
  #  Warns for dup SOP inst
  my($RowInfo) = @_;
  my %Error;
  my %SopInst;
  my %SopClass;
  my %StudyInst;
  my %SeriesInst;
  my %ForUid;
  $get_struct_vol->RunQuery(sub {
    my($row) = @_;
    my($sop_inst, $sop_class, $study_inst, $series_inst, $for_uid) = @$row;
    if(exists $SopInst{$sop_inst}){
      $Error{"Warning: Sop Inst ($sop_inst) is duplicated in volume"} = 1;
    } else {
      $SopInst{$sop_inst} = [$sop_class, $study_inst, $series_inst, $for_uid];
    }
    $SopClass{$sop_class} = 1;
    $StudyInst{$study_inst} = 1;
    $SeriesInst{$series_inst} = 1;
    $ForUid{$for_uid} = 1;
    if(exists $SopInst{$for_uid}) {
      $Error{"Warning: Frame of Reference ($for_uid) matches SOP Instance"} = 1;
    }
    if(exists $StudyInst{$for_uid}) {
      $Error{"Warning: Frame of Reference ($for_uid) matches Study Instance"}
        = 1;
    }
    if(exists $SeriesInst{$for_uid}) {
      $Error{"Warning: Frame of Reference ($for_uid) matches Series Instance"}
        = 1;
    }
  }, sub{}, $RowInfo->{FileId});
  my $num_for = keys %ForUid;
  if($num_for > 1){
      $Error{"Warning: $num_for Frames of Reference"} = 1;
  }
  my $num_series = keys %SeriesInst;
  if($num_series > 1){
      $Error{"Warning: $num_series Series"} = 1;
  }
  my $num_study = keys %StudyInst;
  if($num_study > 1){
      $Error{"Warning: $num_study Series"} = 1;
  }
  my $num_sop_class = keys %SopClass;
  if($num_sop_class > 1){
      $Error{"Warning: $num_sop_class SOP Classes"} = 1;
  }
  my $num_sops = keys %SopInst;
  $RowInfo->{SopsInVolStruct} = \%SopInst;
  $RowInfo->{SopsInVol} = $num_sops;
  my $num_e = keys %Error;
  if($num_e > 0){
    for my $m (keys %Error){
      push @{$RowInfo->{WarningList}}, $m;
    }
  }
}
sub SopsLinkedToRoi{
  #  $RowInfo{RoisPerSopByContourType}->{<contour_type>}
  #    ->{<sop_inst_uid>}->{<sop_class_uid>} = 
  #  [ <num_contours>, <num_points> ];
  my($RowInfo) = @_;
  my %RoisPerSopByContourType;
  my %Error;
  $get_contour_links->RunQuery(sub {
    my($row) = @_;
    my($roi_id,$sop_inst_uid, $sop_class_uid, $contour_type,
      $num_contours, $num_points) = @$row;
    $RoisPerSopByContourType{$contour_type}->{$sop_inst_uid}
      ->{$sop_class_uid} = [$num_contours, $num_points];
  }, sub{}, $RowInfo->{FileId});
  $RowInfo->{RoisPerSopByContourType} = \%RoisPerSopByContourType;
  my $message = "";
  for my $i (keys %RoisPerSopByContourType){
    my $num_sops = keys %{$RoisPerSopByContourType{$i}};
    $message .= "$i: $num_sops\n";
  }
  $RowInfo->{SopsLinkedToRoi} = $message;
}
sub InternalLinkages{
  #  $RowInfo{RoisPerSopByContourType}->{<contour_type>}
  #    ->{<sop_inst_uid>}->{<sop_class_uid>} = 
  #  [ <num_contours>, <num_points> ];
  #  $RowInfo{SopsInVolStruct}->{$sop_inst_uid} = [
  #    $sop_class, $study_inst, $series_inst, $for_uid
  #  ];
  #  $RowInfo->{Rois}->{$roi_id} = {
  #    for_uid => $for_uid,
  #    max => [$max_x, $max_y, $max_z],
  #    min => [$min_x, $min_y, $min_z],
  #    roi_name => <roi_name>,
  #    roi_description => <roi_description>,
  #    roi_interp_type => <roi_interp_type>,
  #    roi_num => <roi_num>
  #  };
  #Adds:
  #  $RoiInfo{SopReferencesContourTypeAndRoiId}->{$contour_type} = {
  #    <roi_id> => {
  #      <sop_instance_uid> => 1,
  #      ...
  #    },
  #    ...
  #  };
  my($RowInfo) = @_;
  my $errors_logged = 0;
  my %Errors;
  $get_roi_linkages->RunQuery(sub {
    my($row) = @_;
    my($roi_id, $sop, $roi_type) = @$row;
    $RowInfo->{SopReferencesContourTypeAndRoiId}->{$roi_type}
      ->{$roi_id}->{$sop} = 1;
  }, sub {}, $RowInfo->{FileId});
  for my $type (keys %{$RowInfo->{RoisPerSopByContourType}}){
    my $tp = $RowInfo->{RoisPerSopByContourType}->{$type};
    for my $sop (keys %$tp){
      my $num_c = keys %{$tp->{$sop}};
      if($num_c > 1){
        my $mess = "Warning: sop instance ($sop) has more than one " .
          "sop_class in reference";
        $Errors{$mess} = 1;
        $errors_logged += 1;
      }
      my $l_class = [keys %{$tp->{$sop}}]->[0];
      unless(exists $RowInfo->{SopsInVolStruct}->{$sop}){
        my $mess = "Warning: referenced sop instance ($sop) not found " .
          "in volume";
        $Errors{$mess} = 1;
        $errors_logged += 1;
      } else {
        unless($l_class eq $RowInfo->{SopsInVolStruct}->{$sop}->[0]){
          my $mess = "Warning: referenced sop instance ($sop) has " .
            "different class in volume";
          $Errors{$mess} = 1;
          $errors_logged += 1;
        } 
      }
    }
  }
  my %rois;
  for my $t (keys %{$RowInfo->{SopReferencesContourTypeAndRoiId}}){
    for my $r (
      keys %{$RowInfo->{SopReferencesContourTypeAndRoiId}->{$t}}
    ){
      for my $s (
        keys %{$RowInfo->{SopReferencesContourTypeAndRoiId}->{$t}->{$r}}
      ){
        $rois{$r}->{$s} = 1;
      }
    }
  }
  for my $r (keys %rois){
    for my $s (keys %{$rois{$r}}){
      my $sop_for = $RowInfo->{SopsInVolStruct}->{$s}->[3];
      my $roi_for = $RowInfo->{Rois}->{$r}->{for_uid};
      if($sop_for ne $roi_for){
        my $mess = "roi_for ($roi_for) ne sop_for ($sop_for)";
        $Errors{$mess} = 1;
        $errors_logged += 1;
      }
    }
  }
  if($errors_logged > 0){
    $RowInfo->{InternalLinkages} = "$errors_logged errors logged";
  } else {
    $RowInfo->{InternalLinkages} = "Ok";
  }
  my $num_e = keys %Errors;
  if($num_e > 0){
    for my $m (keys %Errors){
      push @{$RowInfo->{WarningList}}, $m;
    }
  }
}
sub FrameOfRefExternal{
  #  $RowInfo{SopsInVolStruct}->{$sop_inst_uid} = [
  #    $sop_class, $study_inst, $series_inst, $for_uid
  #  ];
  #  Adds:
  #  $RowInfo{FrameOfRefBySeriesFromVolStruct} = {
  #    <series_instance_uid> => {
  #      <frame_of_ref_uid> => <num_files>,
  #      ...
  #    },
  #    ...
  #  };
  my($RowInfo) = @_;
  my $errors_logged = 0;
  my %Errors;
  $RowInfo->{FrameOfRefExternal} = "Not yet implemented";
  my %series;
  my %fors;
  for my $s(keys %{$RowInfo->{SopsInVolStruct}}){
    my $ser = $RowInfo->{SopsInVolStruct}->{$s}->[2];
    my $for = $RowInfo->{SopsInVolStruct}->{$s}->[3];
    $series{$ser}->{$for} = 1;
    $fors{$for} = 1;
  }
  my $num_series = keys %series;
  my $num_fors = keys %fors;
  if($num_series > 1){
    $Errors{"$num_series series in referenced frame of ref sequence"} = 1;
    $errors_logged += 1;
  }
  if($num_fors > 1){
    $Errors{"$num_fors frames of ref in referenced frame of ref sequence"} = 1;
    $errors_logged += 1;
  }
  for my $s (keys %series){
    my $num_fors = keys %{$series{$s}};
    if($num_fors > 1){
      $Errors{"series ($s) has more than one frame of ref"} = 1;
      $errors_logged += 1;
    }
  }
  for my $s (keys %series){
    $get_for_from_series->RunQuery(sub {
      my($row) = @_;
      my($for_uid, $num_files) = @$row;
      $RowInfo->{FrameOfRefBySeriesFromVolStruct}->{$s}->{$for_uid} = $num_files;
    }, sub{}, $s);
  }
  for my $s (keys %{$RowInfo->{SopsInVolStruct}}){
    my $ref_series = $RowInfo->{SopsInVolStruct}->{$s}->[2];
    my $ref_for = $RowInfo->{SopsInVolStruct}->{$s}->[3];
    unless(exists $RowInfo->{FrameOfRefBySeriesFromVolStruct}->{$ref_series}->{$ref_for}){
      $Errors{"For in ref for seq ($ref_for) doesn't match any file in series"} = 1;
      $errors_logged += 1;
    }
  }
  if($errors_logged > 0){
    $RowInfo->{FrameOfRefExternal} = "$errors_logged errors logged";
  } else {
    $RowInfo->{FrameOfRefExternal} = "Ok";
  }
  my $num_e = keys %Errors;
  if($num_e > 0){
    for my $m (keys %Errors){
      push @{$RowInfo->{WarningList}}, $m;
    }
  }
}
sub VolumeFilesInPosda{
  #  $RowInfo{SopsInVolStruct}->{$sop_inst_uid} = [
  #    $sop_class, $study_inst, $series_inst, $for_uid
  #  ];
  #  Adds:
  #  $RowInfo{SopInfoFoundInVolPosda}->{$sop_inst_uid} = [
  #    $frame_of_ref, $iop, $ipp, $pix_spacing,
  #    $pix_rows, $pix_cols ],
  #
  my($RowInfo) = @_;
  my $sops_found = 0;
  my $sops_not_found = 0;
  my %SopsFoundInVol;
  for my $sop (keys %{$RowInfo->{SopsInVolStruct}}){
    my $num_rows = 0;
    $file_in_posda->RunQuery(sub {
      my($row) = @_;
      my($frame_of_ref, $iop, $ipp, $pixel_spacing,
        $pixel_rows, $pixel_columns) = @$row;
      $SopsFoundInVol{$sop} = [
        $frame_of_ref, $iop, $ipp, $pixel_spacing, 
        $pixel_rows, $pixel_columns
      ];
      $num_rows += 1;
    }, sub {}, $sop);
    if($num_rows < 1) {$sops_not_found += 1}
    if($num_rows == 1) {$sops_found += 1}
  }
  $RowInfo->{SopInfoFoundInVolPosda} = \%SopsFoundInVol;
  $RowInfo->{VolumeFilesInPosda} = 
    "Found: $sops_found; Not found: $sops_not_found";
}
sub VolumeFilesInPublic{
  #  $RowInfo{SopsInVolStruct}->{$sop_inst_uid} = [
  #    $sop_class, $study_inst, $series_inst, $for_uid
  #  ];
  #  Adds:
  #  $RowInfo{SopInfoFoundInVolPosda}->{$sop_inst_uid} = [
  #    $frame_of_ref, $iop, $ipp, $pix_spacing,
  #    $pix_rows, $pix_cols ],
  #
  my($RowInfo) = @_;
  my $sops_found = 0;
  my $sops_not_found = 0;
  my %SopsFoundInVol;
  for my $sop (keys %{$RowInfo->{SopsInVolStruct}}){
    my $num_rows = 0;
    $file_in_public->RunQuery(sub {
      my($row) = @_;
      my($frame_of_ref, $iop, $ipp, $pixel_spacing,
        $pixel_rows, $pixel_columns) = @$row;
      $SopsFoundInVol{$sop} = [
        $frame_of_ref, $iop, $ipp, $pixel_spacing, 
        $pixel_rows, $pixel_columns
      ];
      $num_rows += 1;
    }, sub {}, $sop);
    if($num_rows < 1) { $sops_not_found += 1 }
    if($num_rows >= 1) {$sops_found += 1}
  }
  $RowInfo->{SopInfoFoundInVolPublic} = \%SopsFoundInVol;
  $RowInfo->{VolumeFilesInPublic} = 
    "Found: $sops_found; Not found: $sops_not_found";
}
sub RoiFilesInPosda{
  #  $RowInfo{RoisPerSopByContourType}->{<contour_type>}
  #    ->{<sop_inst_uid>}->{<sop_class_uid>} = 
  #  [ <num_contours>, <num_points> ];
  my($RowInfo) = @_;
  my %SopsFoundInRoi;
  my %RowsFoundByType;
  my %RowsNotFoundByType;
  for my $type (keys %{$RowInfo->{RoisPerSopByContourType}}){
    for my $sop (keys %{$RowInfo->{RoisPerSopByContourType}->{$type}}){
      my $num_rows = 0;
      $file_in_posda->RunQuery(sub {
        my($row) = @_;
        my($frame_of_ref, $iop, $ipp, $pixel_spacing,
          $pixel_rows, $pixel_columns) = @$row;
        $SopsFoundInRoi{$type}->{$sop} = [
          $frame_of_ref, $iop, $ipp, $pixel_spacing, 
          $pixel_rows, $pixel_columns
        ];
        $num_rows += 1;
      }, sub {}, $sop);
      if($num_rows < 1) {$RowsNotFoundByType{$type} += 1}
      if($num_rows >= 1) {$RowsFoundByType{$type} += 1}
    }
  }
  my $message = "";
  my $num_types_found = keys %RowsFoundByType;
  my $num_types_not_found = keys %RowsNotFoundByType;
  if($num_types_found > 0){
    $message .= "Found:";
    for my $type (keys %RowsFoundByType){
      $message .= " $type = $RowsFoundByType{$type}";
    }
    $message .= "   ";
  }
  if($num_types_not_found > 0){
    $message .= "Not Found:";
    for my $type (keys %RowsNotFoundByType){
      $message .= " $type = $RowsNotFoundByType{$type}";
    }
  }
  if($message eq ""){
    $RowInfo->{RoiFilesInPosda} = "???";
  } else {
    $RowInfo->{RoiFilesInPosda} = $message;
  }
}
sub RoiFilesInPublic{
  #  $RowInfo{RoisPerSopByContourType}->{<contour_type>}
  #    ->{<sop_inst_uid>}->{<sop_class_uid>} = 
  #  [ <num_contours>, <num_points> ];
  my($RowInfo) = @_;
  my %SopsFoundInRoi;
  my %RowsFoundByType;
  my %RowsNotFoundByType;
  for my $type (keys %{$RowInfo->{RoisPerSopByContourType}}){
    for my $sop (keys %{$RowInfo->{RoisPerSopByContourType}->{$type}}){
      my $num_rows = 0;
      $file_in_public->RunQuery(sub {
        my($row) = @_;
        my($frame_of_ref, $iop, $ipp, $pixel_spacing,
          $pixel_rows, $pixel_columns) = @$row;
        $SopsFoundInRoi{$type}->{$sop} = [
          $frame_of_ref, $iop, $ipp, $pixel_spacing, 
          $pixel_rows, $pixel_columns
        ];
        $num_rows += 1;
      }, sub {}, $sop);
      if($num_rows < 1) {$RowsNotFoundByType{$type} += 1}
      if($num_rows >= 1) {$RowsFoundByType{$type} += 1}
    }
  }
  my $message = "";
  my $num_types_found = keys %RowsFoundByType;
  my $num_types_not_found = keys %RowsNotFoundByType;
  if($num_types_found > 0){
    $message .= "Found:";
    for my $type (keys %RowsFoundByType){
      $message .= " $type = $RowsFoundByType{$type}";
    }
    $message .= "   ";
  }
  if($num_types_not_found > 0){
    $message .= "Not Found:";
    for my $type (keys %RowsNotFoundByType){
      $message .= " $type = $RowsNotFoundByType{$type}";
    }
  }
  if($message eq ""){
    $RowInfo->{RoiFilesInPublic} = "???";
  } else {
    $RowInfo->{RoiFilesInPublic} = $message;
  }
}
sub FrameOfReferenceMatches{
  #  $RowInfo->{Rois}->{$roi_id} = {
  #    for_uid => $for_uid,
  #    max => [$max_x, $max_y, $max_z],
  #    min => [$min_x, $min_y, $min_z],
  #    roi_name => <roi_name>,
  #    roi_description => <roi_description>,
  #    roi_interp_type => <roi_interp_type>,
  #    roi_num => <roi_num>
  #  };
  #  $RowInfo{SopInfoFoundInVolPosda}->{$sop_inst_uid} = [
  #    $frame_of_ref, $iop, $ipp, $pix_spacing,
  #    $pix_rows, $pix_cols
  #  ];
  #  $RoiInfo{SopReferencesContourTypeAndRoiId}->{$contour_type} = {
  #    <roi_id> => {
  #      <sop_instance_uid> => 1,
  #      ...
  #    },
  #    ...
  #  };
  my($RowInfo) = @_;
  my %ErrByContourTypeRoi;
  my $message = "";
  for my $typ (keys %{$RowInfo->{SopReferencesContourTypeAndRoiId}}){
    for my $roi (keys %{$RowInfo->{SopReferencesContourTypeAndRoiId}->{$typ}}){
      my $roi_for = $RowInfo->{Rois}->{$roi}->{for_uid};
      for my $sop (
        keys %{$RowInfo->{SopReferencesContourTypeAndRoiId}->{$typ}->{$roi}}
      ){
        my $sop_for = $RowInfo->{SopInfoFoundInVolPosda}->{$sop}->[0];
        unless($sop_for eq $roi_for){
          $ErrByContourTypeRoi{$typ}->{$roi} = 1;
          print STDERR "sop_for ($sop_for) doesn't match roi_for ($roi_for)\n";
        }
      }
    }
  }
  my @types = keys %ErrByContourTypeRoi;
  if(@types == 0) {
    $RowInfo->{FrameOfReferenceMatches} = "Matches";
    return;
  }
  for my $t (@types){
    my $num_rois = keys %{$ErrByContourTypeRoi{$t}};
    if($message) { $message .= "\n" }
    $message .= "$num_rois of type $t have none matching for";
  }
  $RowInfo->{FrameOfReferenceMatches} = $message;
}
sub UnlinkedClosedPlanar{
  my($RowInfo) = @_;
  my @Unlinked;
  $get_unlinked_closed_p->RunQuery(sub{
    my($row) = @_;
    push @Unlinked, $row->[1];
  }, sub {}, $RowInfo->{FileId});
  my $num_unlinked = @Unlinked;
  if($num_unlinked > 0){
    my $message = "ROIs with unlinked CLOSED_PLANAR Contours:\n";
    for my $i (0 .. $#Unlinked){
      $message .= "    $Unlinked[$i]";
      unless($i == $#Unlinked){ $message .= "\n" }
    }
    $RowInfo->{UnlinkedClosedPlanar} = $message;
  } else {
    $RowInfo->{UnlinkedClosedPlanar} = "None";
  }
}
sub PointsWithinVolume{
  my($RowInfo) = @_;
  $RowInfo->{PointsWithinVolume} = "Not Currently Implemented";
}
sub Warnings{
  my($RowInfo) = @_;
  if(
    exists($RowInfo->{WarningList}) && ref($RowInfo->{WarningList}) eq "ARRAY"
  ){
    my $Warning = "";
    for my $i (@{$RowInfo->{WarningList}}){
      $Warning .= "$i\n";
    }
    $Warning =~ s/"/""/g;
    $RowInfo->{Warnings} = $Warning;
  } else {
    $RowInfo->{Warnings} = "";
  }
}
