#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
# 9/6/11 Create RT Plans only if BEAM GEOMETRY is found in RTOG DE fileset
#
# !!!!!!!!!!!!!!!!!!!!!
# When changing this file, check to see if CnvRtogToDicom.pm in
#   ~Posda/include/Posda/ also needs changing...
# This script should be modified to call CnvRtogToDicom.pm
#

use Cwd;
use strict;
use Posda::Rtog;
use Posda::Dataset;
use Posda::UID;
use Posda::Transforms;
use VectorMath;
#use File::Temp qw/ :seekable /;
use Debug;
use Switch;
Posda::Dataset::InitDD();
my $dbg = sub {print @_};

$0 =~ s:.*/::;
my $cmd = $0;

sub usage {
  print "Usage: $cmd <RTOG dir> <DICOM dir> <pat_id> " .
	        "{-t <temp_dir>} {-d date YYYYMMDD}.\n";
	print "  This command converts a patient in RTOG format to DICOM.\n";
  exit -1;
}

unless($#ARGV >= 2) { &usage(); }
my $from_dir = $ARGV[0]; shift @ARGV; 
unless($from_dir =~ /^\//) {$from_dir = getcwd."/$from_dir"}
my $to_directory = $ARGV[0]; shift @ARGV; 
unless($to_directory =~ /^\//) {$to_directory = getcwd."/$to_directory"}
my $PatientId = $ARGV[0]; shift @ARGV;
my $temp_dir = ".";
my $dicomDate = "";

while (@ARGV) {
  switch ($ARGV[0]) {
	  case ("-t") { $temp_dir = $ARGV[1]; shift @ARGV; }
	  case ("-d") { $dicomDate =  $ARGV[1]; shift @ARGV; }
	  else        {  &usage(); }
	}
	shift @ARGV; 
}

unless(-d $temp_dir) { die "$temp_dir is not a directory" }
if ($dicomDate ne "") {
  unless ( $dicomDate =~ 
	  /((19|20)\d\d)(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])/) {
		die "Invalid date specified: $dicomDate, format should be YYYYMMDD";
	}
}

my $rtog_text_to_num_cmd;
open FOO, "which RtogTextToNum 2>/dev/null|";
my $line = <FOO>;
if($line) {
  $rtog_text_to_num_cmd = "RtogTextToNum";
} else {
  $rtog_text_to_num_cmd = "RtogTextToNum.pl";
}
close FOO;
# print STDERR "$0: using RtogTextToNum cmd: $rtog_text_to_num_cmd.\n";

my $rtog = Posda::Rtog->NewFromDir($from_dir);
 # print "Result: ";
 # Debug::GenPrint($dbg, $rtog, 1);
 # print "\n";
my $institution = $rtog->{fileset_attr}->{INSTITUTION};
########
#  DICOM generation stuff
########
my $user = `whoami`;
my $host = `hostname`;
chomp $host;
chomp $user;
my $uid_root = Posda::UID::GetPosdaRoot({
  app => $0,
  user => $user,
  host => $host,
  purpose => "RTOG Conversion",
});
#my $uid_root = '1.3.6.1.4.1.22213.2.14048';
my $uid_seq = 1;
my $study_uid = $uid_root;
my $for_uid = "$uid_root.1";
my $ct_series_uid = "$uid_root.2";
my $ss_series_uid = "$uid_root.3";
my $plan_series_uid = "$uid_root.4";
my $dose_series_uid = "$uid_root.5";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime;
$mon = $mon + 1;
$mon = "" . $mon;
if (length($mon) == 1) {$mon = "0".$mon;}
$year += 1900;
$mday = "" . $mday;
if (length($mday) == 1) {$mday = "0" . $mday;}
my $instance_creation_date = "$year$mon$mday";
my $instance_creation_time = "$hour$min$sec";
my $datecreated = $rtog->{fileset_attr}->{DATECREATED};
my $ddate = $instance_creation_date;
if ( $datecreated =~ 
    /(0[1-9]|[12][0-9]|3[01]).*,.*(0[1-9]|1[012]).*,.*((19|20)\d\d)/ ) {
  $ddate = "$3$2$1";
} elsif ( $datecreated =~ 
    /(0[1-9]|[12][0-9]|3[01]).*,.*(0[1-9]|1[012]).*,.*(\d\d)\s*$/ ) {
  print STDERR "RTOG dataset with invalid date: $datecreated. 2 digit year.\n";
  if ($3 > 50) 
    { $ddate = "19$3$2$1"; }
  else
    { $ddate = "20$3$2$1"; }
  print STDERR "\t Assuming: $ddate.\n";
}
print "Date found in RTOG data: $datecreated, DICOM date: $ddate.\n";
if ($dicomDate ne "") {
  $ddate = $dicomDate;
	print "Date given in arg list will overwrite: $ddate.\n";
}
my $ser_seq = 1;
##########
# Extract CTs
##########
my $study_keys = [
  "BYTESPERPIXEL", "CASENUMBER", "CT-AIR", "CT-WATER", "CTOFFSET",
  "GRID1UNITS", "GRID2UNITS", "HEADIN/OUT", "IMAGETYPE", "NUMBEROFDIMENSIONS",
  "NUMBERREPRESENTATION", "PATIENTNAME", "SCANTYPE", "SIZEOFDIMENSION1",
  "SIZEOFDIMENSION2"
];
my %Study;
my @Cts;
my @DicomCts;
my %CtByZ;
my %CtByImageNumber;
for my $i (
    sort {
      $rtog->{image_attr}->{$a}->{IMAGENUMBER} <=> 
      $rtog->{image_attr}->{$b}->{IMAGENUMBER}
    }
    keys %{$rtog->{image_attr}}
  ){
  my $ent = $rtog->{image_attr}->{$i};
  if(
    $ent->{IMAGETYPE} eq "CT SCAN" ||
    $ent->{IMAGETYPE} eq "CT Scan"
  ){
    push(@Cts, $ent);
    for my $k (@$study_keys){
      if(exists $ent->{$k}){
        if(exists($Study{$k}) && $ent->{$k} ne $Study{$k}){
          die "Inconsistent $k in CT Images";
        }
        $Study{$k} = $ent->{$k};
      }
    }
  } else { next;
  }
}
for my $k (@$study_keys){
  unless(exists $Study{$k}){
    print "$k not found\n";
  }
}
my $orientation;
if(!defined($Study{"HEADIN/OUT"}) || $Study{"HEADIN/OUT"} eq "IN"){
  $orientation = 'HF';
} elsif ($Study{"HEADIN/OUT"} eq "OUT"){
  $orientation = 'FF';
} else {
  die "I don't handle HEADIN/OUT = $Study{\"HEADIN/OUT\"}";
}
if(!defined($Study{POSITIONINSCAN}) || $Study{POSITIONINSCAN} eq "NOSE UP"){
  $orientation .= "S";
} elsif($Study{POSITIONINSCAN} eq "NOSE DOWN"){
  $orientation .= "P";
} else {
  die "I don't handle POSITIONINSCAN = $Study{POSITIONINSCAN}";
}
my $xform;
my $iop;
if($orientation eq "HFS"){
  $xform = [
    [ 1,  0,  0,  0],
    [ 0, -1,  0,  0],
    [ 0,  0, -1,  0],
    [ 0,  0,  0,  1],
  ];
  $iop = [1, 0, 0, 0, 1, 0];
} elsif($orientation eq "HFP"){
  $xform = [
    [-1,  0,  0,  0],
    [ 0,  1,  0,  0],
    [ 0,  0, -1,  0],
    [ 0,  0,  0,  1],
  ];
  $iop = [-1, 0, 0, 0, -1, 0];
} elsif($orientation eq "FFS"){
  $xform = [
    [-1,  0,  0,  0],
    [ 0, -1,  0,  0],
    [ 0,  0,  1,  0],
    [ 0,  0,  0,  1],
  ];
  $iop = [-1, 0, 0, 0, 1, 0];
} elsif($orientation eq "FFP"){
  $xform = [
    [ 1,  0,  0,  0],
    [ 0,  1,  0,  0],
    [ 0,  0,  1,  0],
    [ 0,  0,  0,  1],
  ];
  $iop = [1, 0, 0, 0, -1, 0];
} else { die "WTF?" }
my $rows = $Study{SIZEOFDIMENSION1};
my $cols = $Study{SIZEOFDIMENSION2};
my $pix_sp = [$Study{GRID1UNITS} * 10, $Study{GRID2UNITS} * 10];
my $intercept = -$Study{"CTOFFSET"};
my $slope = ($Study{"CT-WATER"} - $Study{"CT-AIR"}) / 1000;
my $window_center = 40;
my $window_width = 400;
unless($Study{BYTESPERPIXEL} == 2) {
  die "I only handle 16 bit CTs"
}
for my $ct (@Cts){
  my $x_offset = 0;
  my $y_offset = 0;
  if(defined $ct->{XOFFSET}) { $x_offset = $ct->{XOFFSET}};
  if(defined $ct->{YOFFSET}) { $y_offset = $ct->{YOFFSET}};
  my $center = Posda::Transforms::ApplyTransform($xform, 
    [ $x_offset * 10, $y_offset * 10, $ct->{ZVALUE} * 10]
  );
  my $ul_shift = [
     ((($cols - 1)/2) * $pix_sp->[0]) * $iop->[0],
     ((($rows - 1)/2) * $pix_sp->[1]) * $iop->[4],
     0
  ];
  my $ipp = VectorMath::Sub($center, $ul_shift);
  unless (exists ($ct->{SLICETHICKNESS})  &&
          defined ($ct->{SLICETHICKNESS})) 
    { $ct->{SLICETHICKNESS} = 3.1415; }
  my $CtDesc = {
    ImageType => ["DERIVED", "SECONDARY", "AXIAL"],
    ImageNumber => $ct->{IMAGENUMBER},
    StudyUid => $study_uid,
    StudyId => $ct->{CASENUMBER},
		StudyDate => $ddate,
    SeriesDate => $ddate,
    SeriesNum => $ser_seq,
    SeriesDescription => "CTs from rtog conversion",
    SeriesUid => $ct_series_uid,
    SopClassUid => "1.2.840.10008.5.1.4.1.1.2",
    ForUid => $for_uid,
    SopInstanceUid => "$ct_series_uid.$ct->{IMAGENUMBER}",
    PatientsName => $ct->{PATIENTNAME},
    PatientsId => $PatientId,
    PatientPosition => $orientation,
    PixelSpacing => $pix_sp,
    Modality => 'CT',
    Rows => $rows,
    Cols => $cols,
    Slope => $slope,
    Intercept => $intercept,
    Iop => $iop,
    Ipp => $ipp,
		SliceLocation => $ipp->[2],
		# SliceLocation => $ct->{ZVALUE} * 10,
		SliceThickness =>  $ct->{SLICETHICKNESS} * 10.0,
		PhotometricInterpretation => "MONOCHROME2",
    BitsAllocated => 16,
    BitsStored => 16,
    HighBit => 15,
    PixelRepresentation => 0,
    SamplesPerPixel => 1,
    PixelFile => $rtog->{image_file}->{$ct->{IMAGENUMBER}},
    FileName => "CT_$ct_series_uid.$ct->{IMAGENUMBER}.dcm",
    WindowWidth => $window_width,
    WindowCenter => $window_center,
  };
  push(@DicomCts, $CtDesc);
  $CtByZ{$CtDesc->{Ipp}->[2]} = $CtDesc;
  $CtByImageNumber{$ct->{IMAGENUMBER}} = $CtDesc;
  CreateDicomCt($to_directory, $CtDesc);
}
$ser_seq++;
##########
# Extract Structure's
##########
my %RGB = (
  aqua =>        "0,100,75",
  black =>       "0,0,0",
  blue =>        "0,0,255",
  brown =>       "200,100,70",
  cyan =>        "0,255,255",
  gray =>        "127,127,127",
  magenta =>     "255,0,255",
  olive =>       "50,100,0",
  orange =>      "255,128,0",
  purple =>      "128,0,255",
  red =>         "255,0,0",
  white =>       "255,255,255",
  yellow =>      "255,255,0",
  dk_blue =>     "0,0,128",
  dk_cyan =>     "0,128,128",
  dk_green =>    "0,128,0",
  dk_magenta =>  "128,0,128",
  dk_orange =>   "200,100,70",
  dk_purple =>   "150,50,150",
  dk_red =>      "128,0,0",
  dk_yellow =>   "185,185,0",
  green =>       "0,255,0",
  lt_blue =>     "0,175,255",
  lt_cyan =>     "128,255,255",
  lt_green =>    "128,255,128",
  lt_magenta =>  "255,128,255",
  lt_purple =>   "200,100,200",
  lt_red =>      "255,128,128"
);

my @EDSRGB = ( 
  "orange",
  "magenta",
  "cyan",
  "red",
  "blue",
  "green",
  "yellow",
  "purple"
);

# Organs/Volumes for protocols
my %COLOR = ( 
  BLADDER             => "yellow",
  BRACH_PLEX_CONTRA   => "lt_green",
  BRACH_PLEX_IPSI     => "dk_green",
  BRAIN_STEM          => "cyan",
  CEREBELLUM          => "orange",
  CEREBRUM_CONTRA     => "lt_green",
  CEREBRUM_IPSI       => "dk_green",
  CHIASMA             => "yellow",
  CTV                 => "dk_red",
  CTVLD               => "dk_red",
  CTVHD               => "red",
  ETV                 => "red",
  ESOPHAGUS           => "magenta",
  FEMUR_LEFT          => "dk_green",
  FEMUR_RIGHT         => "lt_green",
  GTV                 => "red",
  GTV1                => "orange",
  HEART               => "magenta",
  ITC_SKIN            =>"brown",
  LIVER               => "green",
  LUNG_CONTRA         => "yellow",
  LUNG_IPSI           => "dk_yellow",
  LUNG_TOTAL          => "orange",
  OPTIC_NERVE_CONTRA  => "lt_blue",
  OPTIC_NERVE_IPSI    => "dk_cyan",
  ORBIT_RETINA_CONTRA => "lt_magenta",
  ORBIT_RETINA_IPSI   => "dk_magenta",
  PTV                 => "purple",
  PTV1                => "blue",
  PTV2                => "purple",
  PTVHD               => "purple",
  PTVLD               => "blue",
  RECTUM              => "magenta",
  SKIN                => "brown",
  SPINAL_CORD         => "orange",
  # ACOSOG 0070  
  PROSTATE            => "red",
  # H-0022 TUMOR/TARGET VOLUMES
  PTV66               => "cyan",
  PTV54               => "yellow",
  PTV60               => "lt_green",
  CTV54               => "dk_red",
  CTV60               => "dk_magenta",
  CTV66               => "purple",
  # H-0022 OAR
  BRAIN_STEM          => "cyan",
  LARYNX              => "blue",
  MANDIBLE            => "dk_yellow",
  MANDIBLE_LT         => "dk_yellow",
  MANDIBLE_RT         => "dk_yellow",
  PAROTID_LT          => "dk_green",
  PAROTID_RT          => "cyan",
  SKIN                => "dk_orange",
  SPINAL_CORD         => "orange",
  SPINL_CRD_PRV       => "lt_blue",
  SUBMND_SALV         => "cyan",
  SUBMND_SALV_LT      => "cyan",
  SUBMND_SALV_RT      => "cyan",
  URETHRA             => "green",
  # supplementary colors
  PENILE_BULB         => "yellow",
);

my @Structs;
my %SS;
my $RoiByImageNumber;
my $SS_keys = [
  "CASENUMBER", "MAXIMUMNUMBERSCANS", "MAXIMUMPOINTSPERSEGMENT",
  "MAXIMUMSEGMENTSPERSCAN", "NUMBEROFSCANS", "NUMBERREPRESENTATION", 
  "PATIENTNAME", "STRUCTUREFORMAT"
];
for my $i (
    sort {
      $rtog->{image_attr}->{$a}->{IMAGENUMBER} <=> 
      $rtog->{image_attr}->{$b}->{IMAGENUMBER}
    }
    keys %{$rtog->{image_attr}}
  ){
  my $ent = $rtog->{image_attr}->{$i};
  if(
    $ent->{IMAGETYPE} eq "Structure" ||
    $ent->{IMAGETYPE} eq "STRUCTURE"
  ){
    push(@Structs, $ent);
    $RoiByImageNumber->{$ent->{IMAGENUMBER}} = $ent;
    for my $k (@$SS_keys){
      if(exists $ent->{$k}){
        if(exists($SS{$k}) && $ent->{$k} ne $SS{$k}){
          die "Inconsistent $k in Structures";
        }
        $SS{$k} = $ent->{$k};
      }
    }
  } else { 
    next;
  }
}
for my $k (@$SS_keys){
  unless(exists $SS{$k}){
    print "$k not found\n";
  }
}
my $DicomStruct = Posda::Dataset->new_blank();
$DicomStruct->Insert("(0008,0060)", "RTSTRUCT");
$DicomStruct->Insert("(0020,000d)", $study_uid);
$DicomStruct->Insert("(0020,0010)", $SS{CASENUMBER});
$DicomStruct->Insert("(0020,0011)", $ser_seq);
$ser_seq++;
$DicomStruct->Insert("(0020,000e)", $ss_series_uid);
$DicomStruct->Insert("(0008,103e)", "RTStruct from rtog conversion");
$DicomStruct->Insert("(0008,0016)", '1.2.840.10008.5.1.4.1.1.481.3');
$DicomStruct->Insert("(0008,0018)", "$ss_series_uid.1");
$DicomStruct->Insert("(0010,0010)", $SS{PATIENTNAME});
$DicomStruct->Insert("(0010,0020)", $PatientId);
$DicomStruct->Insert("(0010,0030)", "");
$DicomStruct->Insert("(0010,0040)", "");
$DicomStruct->Insert("(0008,0020)", $ddate);
$DicomStruct->Insert("(0008,0021)", $ddate);
$DicomStruct->Insert("(0008,0030)", "");
$DicomStruct->Insert("(0008,0050)", "");
$DicomStruct->Insert("(0008,0090)", "");
$DicomStruct->Insert("(0008,0070)", "Posda RTOG Converter");
$DicomStruct->Insert("(0008,1090)", $0);
$DicomStruct->Insert("(3006,0002)", "RTOG_CONV");
$DicomStruct->Insert("(3006,0008)", $ddate);
$DicomStruct->Insert("(3006,0009)", "");
$DicomStruct->Insert("(3006,0010)[0](0020,0052)",
  $for_uid);
$DicomStruct->Insert("(3006,0010)[0](3006,0012)[0](0008,1150)",
  "1.2.840.10008.3.1.2.3.1");
$DicomStruct->Insert("(3006,0010)[0](3006,0012)[0](0008,1155)",
  $study_uid);
$DicomStruct->Insert("(3006,0010)[0](3006,0012)[0](3006,0014)[0](0020,000e)",
  $ct_series_uid);
for my $i (0 .. $#DicomCts){
  $DicomStruct->Insert(
    "(3006,0010)[0](3006,0012)[0](3006,0014)[0](3006,0016)[$i](0008,1150)",
    $DicomCts[$i]->{SopClassUid});
  $DicomStruct->Insert(
    "(3006,0010)[0](3006,0012)[0](3006,0014)[0](3006,0016)[$i](0008,1155)",
    $DicomCts[$i]->{SopInstanceUid});
}
my $roi_num = 0;
my $color_index = 0;
for my $i (0 .. $#Structs){
  $roi_num += 1;
  # ROI sequence Entry:
  $DicomStruct->Insert( "(3006,0020)[$i](3006,0022)", $roi_num);
  $DicomStruct->Insert( "(3006,0020)[$i](3006,0024)", $for_uid);
  my $roi_name = $Structs[$i]->{STRUCTURENAME};
  $DicomStruct->Insert(
    "(3006,0020)[$i](3006,0026)", $roi_name);
  my $uc_roi_name = $roi_name;
  $uc_roi_name =~ tr/a-z/A-Z/;
  my $color;
  if(exists $COLOR{$uc_roi_name}){
    $color = $COLOR{$uc_roi_name};
  } else {
    $color = $EDSRGB[$color_index];
    $color_index += 1;
    if($color_index > $#EDSRGB){ $color_index = 0 };
  }
  unless(exists $RGB{$color}){ die "unknown color: $color" }
  my $rgb = [split(",", $RGB{$color})];
  $DicomStruct->Insert( "(3006,0020)[$i](3006,0036)", "MANUAL");
  # ROI obserations entry:
  $DicomStruct->Insert("(3006,0080)[$i](3006,0082)", $roi_num);
  $DicomStruct->Insert("(3006,0080)[$i](3006,0084)", $roi_num);
  $DicomStruct->Insert("(3006,0080)[$i](3006,00a4)", "");
  $DicomStruct->Insert("(3006,0080)[$i](3006,00a6)", "");
  # Now build contours:
  my $contours = ParseSegmentFile(
    $rtog->{image_file}->{$Structs[$i]->{IMAGENUMBER}});
  my $num_imgs = scalar @{$contours};
#  my $roi_name = 
#    $RoiByImageNumber->{$Structs[$i]->{IMAGENUMBER}}->{STRUCTURENAME};
  $DicomStruct->Insert("(3006,0039)[$i](3006,0084)", $roi_num);
  $DicomStruct->Insert("(3006,0039)[$i](3006,002a)", $rgb);
  my $contour_index = 0;
  for my $scan (0 .. $#{$contours}){
    my $num_segs = scalar @{$contours->[$scan]->{segments}};
    my $scan_num = $contours->[$scan]->{scan_number};
    my $ipp = $CtByImageNumber{$scan_num}->{Ipp};
    my $ref_sop_class = $CtByImageNumber{$scan_num}->{SopClassUid};
    my $ref_sop_inst = $CtByImageNumber{$scan_num}->{SopInstanceUid};
    segment:
    for my $seg_num (0 .. $#{$contours->[$scan]->{segments}}){
      my $seg = $contours->[$scan]->{segments}->[$seg_num];
      my $num_points = scalar @$seg;
      if($num_points == 0) { 
        next segment 
      }
      my $contour_data = [];
      for my $i (@$seg){
        my $xp = Posda::Transforms::ApplyTransform($xform, $i);
        my $x = $xp->[0] * 10;
        my $y = $xp->[1] * 10;
        my $z = $xp->[2] * 10;
        push(@$contour_data, $x);
        push(@$contour_data, $y);
        push(@$contour_data, $z);
      }
      $DicomStruct->Insert(
        "(3006,0039)[$i](3006,0040)[$contour_index](3006,0046)",
        $num_points
      );
      $DicomStruct->Insert(
        "(3006,0039)[$i](3006,0040)[$contour_index](3006,0042)",
        "CLOSED_PLANAR"
      );
      $DicomStruct->Insert(
        "(3006,0039)[$i](3006,0040)[$contour_index](3006,0016)[0](0008,1150)",
        $ref_sop_class
      );
      $DicomStruct->Insert(
        "(3006,0039)[$i](3006,0040)[$contour_index](3006,0016)[0](0008,1155)",
        $ref_sop_inst
      );
      $DicomStruct->Insert(
        "(3006,0039)[$i](3006,0040)[$contour_index](3006,0050)",
        $contour_data
      );
      $contour_index += 1;
    }
  }
}
my $filename = "$to_directory/SS_$ss_series_uid.1.dcm";
$DicomStruct->WritePart10($filename,  
    "1.2.840.10008.1.2", "RTOG_CONV", undef, undef);
##########
# Extract Dose's
##########
my $Doses = {};
# get dose information, save based on fraction group...
for my $i (
  sort {
    $rtog->{image_attr}->{$a}->{IMAGENUMBER} <=> 
    $rtog->{image_attr}->{$b}->{IMAGENUMBER}
  }
  keys %{$rtog->{image_attr}}
){
  unless($rtog->{image_attr}->{$i}->{IMAGETYPE} eq "DOSE") { next }
  my $obj = {};
	my $fgid;
  for my $j (keys %{$rtog->{image_attr}->{$i}}){
	  if ($j eq "FRACTIONGROUPID") {
		  $fgid = $rtog->{image_attr}->{$i}->{$j};
		}
    $obj->{$j} = $rtog->{image_attr}->{$i}->{$j};
  }
	$Doses->{$fgid} = $obj;
}
# Now get beam information, save by fraction group under dose obj...
for my $i (
  sort {
    $rtog->{image_attr}->{$a}->{IMAGENUMBER} <=> 
    $rtog->{image_attr}->{$b}->{IMAGENUMBER}
  }
  keys %{$rtog->{image_attr}}
){
  unless($rtog->{image_attr}->{$i}->{IMAGETYPE} eq "BEAM GEOMETRY") { next }
  my $obj = {};
	my $fgid;
	my $bn;
  for my $j (keys %{$rtog->{image_attr}->{$i}}){
	  if ($j eq "FRACTIONGROUPID") {
		  $fgid = $rtog->{image_attr}->{$i}->{$j};
		}
	  if ($j eq "BEAMNUMBER") {
		  $bn = $rtog->{image_attr}->{$i}->{$j};
		}
    $obj->{$j} = $rtog->{image_attr}->{$i}->{$j};
  }
	$Doses->{$fgid}->{beams}->{$bn} = $obj;
}
  # print "\nResult: ";
  # Debug::GenPrint($dbg, $Doses, 1);
  # print "\n";
  # Debug::GenPrint($dbg, $rtog, 4);
  # print "\n";
# 
# Generate DICOM RT Plan file from RTOG 'DOSE' file.
# Data in RTOG file: 
		# Required Keywords
		# 
		#     Image #                    :=   actual image (file) number (see 4.4)
		#     Image Type                 :=   DOSE
		#     Case #                     :=   1 for first patient, 2 for second
		#                                     patient, etc
		#     Patient Name               :=   patient identifier
		#    
		#     Dose Units                 :=   GRAYS, RADS, CGYS
		#     Orientation of Dose        :=   TRANSVERSE
		#     Number Representation      :=   CHARACTER
		#     Number of Dimensions       :=   3
		#     Size of dimension 1        :=   # horizontal points (>=1)
		#     Size of dimension 2        :=   # vertical points (>=1)
		#     Size of dimension 3        :=   # of planes (>=1)
		#     Coord 1 of first point     :=   x coord (cm) for transverse, etc.
		#     Coord 2 of first point     :=   y coord (cm) for transverse, etc.
		#     Horizontal grid interval   :=   delta-x (cm) for transverse (>0)
		#     Vertical grid interval     :=   delta-y (cm) for transverse (<0)
		# 
		# Optional Keywords
		# 
		#     Dose #                     :=   # identifying this distribution
		#     Dose Type                  :=   PHYSICAL, EFFECTIVE, LET, OER, ERROR
		#     Unit #                     :=
		#     Writer                     :=
		#     Date written               :=   date (DD, MM, YYYY)
		#     Dose description           :=   free text
		#     Dose edition               :=
		#     Plan # of origin           :=
		#     Plan edition of origin     :=
		#     Study # of origin          :=
		#     Version # of program       :=   planning program identification
		#     x coord of normalizn point :=   cm
		#     y coord of normalizn point :=   cm
		#     z coord of normalizn point :=   cm
		#     Dose at normalizn point    :=   should result in units specified
		#                                     above after being multiplied by
		#                                     the Dose Scale
		#     Dose error                 :=   NOMINAL, MINIMUM, or MAXIMUM
		#                                     (for dose range submissions)
		#     Fraction Group ID          :=   ID grouping beams of common
		#                                     fraction for the doses in this
		#                                     image file
		#     Number of Tx               :=   Number of times this fraction
		#                                     (Fraction Group ID) treated to
		#                                     achieve total doses in this file
		#     Dose Scale                 :=   Scale factor to convert doses in
		#                                     image file to absolute doses in
		#                                     the units specified in the Dose Units.
		#                                     (assumed to be 1.00 if not specified)
		#     Coord 3 of first point     :=   z coord (cm) for first transverse plane
		#     Depth grid interval        :=   delta-z (cm) between each subsequent
		#                                     transverse dose plane (>0)
		# 
		#     Plan ID of origin           :=  Plan ID of SEED GEOMETRY to required to tie
		#                                     DOSE file to SEED GEOMETRY file


# Required Keywords
# 
#     Image #                :=   actual image (file) number (see 4.4)
#     Image Type             :=   BEAM GEOMETRY
#     Case #                 :=   1 for first case, 2 for second case
#                                 in file set, etc.
#     Patient Name           :=   patient identifier
#     Beam #                 :=   Beam number in plan of origin (to
#                                 index with dose files later)
#     Beam Modality          :=   X-RAY, ELECTRON, PROTON, NEUTRON, OTHER
#     Beam Energy(MeV)       :=   Beam energy in MeV
#     Beam Description       :=   Text Description of beam (i.e. LPO,
#                                 AP Boost, etc.)
#     Rx Dose Per Tx (Gy)    :=   ICRU Reference point dose per treatment
#                                 (generally, isocenter dose)
#     Number of Tx           :=   Number of treatments using this field
#     Fraction Group ID      :=   ID to group beams of common fraction
#     Beam Type              :=   STATIC, ARC
#     Collimator Type        :=   SYMMETRIC, ASYMMETRIC, ASYMMETRIC_X,
#                                 ASYMMETRIC_Y
#     Aperture Type          :=   BLOCK, MLC_X, MLC_Y, MLC_XY, COLLIMATOR, or
#                                 TRANSMISSION MAP
#     Collimator Angle       :=   Collimator angle in degrees
#     Gantry Angle           :=   Gantry angle in degrees (also start
#                                 angle for an arc beam)
#     Couch Angle            :=   Couch angle in degrees
#     Nominal Isocenter Dist :=   Rotational source-isocenter distance
#                                 in cm or nominal treatment distance
#                                 (i.e. 80.0 cm for Co-60)
#     Number Representation  :=   CHARACTER
# 
# Optional Keywords
# 
#     Plan ID of Origin      :=   Plan ID of beam origin for grouping
#                                 beams and doses
#     Aperture Description   :=   Description of beam aperture
#     Aperture ID            :=   Identifier of Aperture for beam
#     Wedge Angle            :=   Wedge angle in degrees (required if
#                                 wedges are used for this beam)
#     Wedge Rotation Angle   :=   0, 90, 180, 270 ( required if wedges
#                                 are used for this beam) where:
#                                   0 - toe of wedge points toward +y beam axis
#                                  90 - toe of wedge points toward +x beam axis
#                                 180 - toe of wedge points toward -y beam axis
#                                 270 - toe of wedge points toward -x beam axis
#     Arc Angle              :=   Arc angle in degrees (Req'd of ARC
#                                 Beam Type) it's sign should reflect the
#                                 stopping gantry angle.
#     Machine ID             :=   text string uniquely identifying machine
#                                 parameter set used for dose calculation
#     Beam Weight            :=   numeric value specifying beam weight used
#                                 (or to be used) for dose calculation with
#                                 definition of this value driven by the
#                                 WEIGHT UNITS keyword
#     Weight Units           :=   MU, RELATIVE or PERCENT
#                                 MU is actual monitor unit (or time) setting
#                                   used for each treatment
#                                 RELATIVE is the fractional amount of total
#                                   beam on time for this beam versus the total
#                                   beam on time
#                                 PERCENT is the percentage amount of total
#                                   beam on time for this beam versus the total
#                                   beam on time
#                            BEAM WEIGHT and BEAM UNITS are both required
#                            if either one of them is used
#     Compensator            :=   NONE, 1D-X, 1D-Y, 2D, 3D where:
#                                 1D is a customized step wedge along
#                                    specified beam axis
#                                 2D is a topographic correcting compensator
#                                    (an Ellis type for instance)
#                                 3D corrects for topography and heterogeneity
#     Compensator Format     :=   THICKNESS, TRANSMISSION, TISSUE or NONE where:
#                                 THICKNESS indicates the compensator is
#                                   specified in ray thicknesses in cm
#                                 TRANSMISSION indicates the compensator is
#                                   specified in ray transmission values
#                                 TISSUE indicates the compensator is
#                                   specified in ray thicknesses in cm of tissue
#                                 NONE indicates the compensator's
#                                   construction is not specified (default if this
#                                   keyword not used for a compensator)
#     Head In/Out            :=   IN, OUT where:
#                                 IN specifies this beam treated with
#                                   the patient's head toward the gantry
#                                   (prior to any couch rotation), and
#                                 OUT specifies this beam treated with
#                                   the patient's head away from the gantry
#                                   (prior to any couch rotation).
#                                 NOTE: Orientation is assumed to be
#                                 head in unless otherwise specified.
#                                 This keyword is required for a foot
#                                 in treatment.
# 
#                 
# Example RTOG hash to use to make DICOM RT PLAN object: 
# 
# Result: {
#   "fx1hetero" => {
#     "CASENUMBER" => "921",
#     "COORD1OFFIRSTPOINT" => "-32.436",
#     "COORD2OFFIRSTPOINT" => "32.436",
#     "DOSEDESCRIPTION" => "Exchange Plan",
#     "DOSEEDITION" => "fx1hetero",
#     "DOSENUMBER" => "1",
#     "DOSESCALE" => "1.000",
#     "DOSETYPE" => "PHYSICAL",
#     "DOSEUNITS" => "GRAYS",
#     "FRACTIONGROUPID" => "fx1hetero",
#     "HORIZONTALGRIDINTERVAL" => "0.254",
#     "IMAGENUMBER" => "163",
#     "IMAGETYPE" => "DOSE",
#     "NUMBEROFDIMENSIONS" => "3",
#     "NUMBEROFTX" => "1",
#     "NUMBERREPRESENTATION" => "CHARACTER",
#     "ORIENTATIONOFDOSE" => "TRANSVERSE",
#     "PATIENTNAME" => "0921c0001",
#     "SIZEOFDIMENSION1" => "256",
#     "SIZEOFDIMENSION2" => "256",
#     "SIZEOFDIMENSION3" => "142",
#     "VERTICALGRIDINTERVAL" => "-0.254",
#     "beams" => {
#       "99" => {
#         "APERTURETYPE" => "COLLIMATOR",
#         "BEAMDESCRIPTION" => "Dummy Beam",
#         "BEAMENERGY(MEV)" => "18.000",
#         "BEAMMODALITY" => "X-RAY",
#         "BEAMNUMBER" => "99",
#         "BEAMTYPE" => "STATIC",
#         "CASENUMBER" => "921",
#         "COLLIMATORANGLE" => "0.000",
#         "COLLIMATORTYPE" => "SYMMETRIC",
#         "COUCHANGLE" => "-0.000",
#         "FRACTIONGROUPID" => "fx1hetero",
#         "GANTRYANGLE" => "-0.000",
#         "HEADIN/OUT" => "IN",
#         "IMAGENUMBER" => "162",
#         "IMAGETYPE" => "BEAM GEOMETRY",
#         "NOMINALISOCENTERDIST" => "100.000",
#         "NUMBEROFTX" => "1",
#         "NUMBERREPRESENTATION" => "CHARACTER",
#         "PATIENTNAME" => "0921c0001",
#         "PLANIDOFORIGIN" => "fx1hetero",
#         "RXDOSEPERTX(GY)" => "10.000"
#       }
#     }
#   }
# }
#      Beam Info: {
# 		 "APERTURETYPE" => "BLOCK",
# 		          "BEAMDESCRIPTION" => "2 Rt AISO (B2)",
# 		          "BEAMENERGY(MEV)" => "6.000",
# 		          "BEAMMODALITY" => "X-RAY",
# 		          "BEAMNUMBER" => "2",
# 		          "BEAMTYPE" => "STATIC",
# 		          "CASENUMBER" => "8019",
# 		          "COLLIMATORANGLE" => "0.000",
# 		          "COLLIMATORTYPE" => "ASYMMETRIC",
# 		          "COUCHANGLE" => "50.000",
# 		          "FRACTIONGROUPID" => "fx1hetero",
# 		          "GANTRYANGLE" => "310.000",
# 		          "HEADIN/OUT" => "IN",
# 		          "IMAGENUMBER" => "149",
# 		          "IMAGETYPE" => "BEAM GEOMETRY",
# 		          "NOMINALISOCENTERDIST" => "100.000",
# 		          "NUMBEROFTX" => "1",
# 		          "NUMBERREPRESENTATION" => "CHARACTER",
# 		          "PATIENTNAME" => "8019cPinT02",
# 		          "PLANIDOFORIGIN" => "fx1hetero",
# 		          "RXDOSEPERTX(GY)" => "10.000",
# 		          "WEDGEANGLE" => "30",
# 		          "WEDGEROTATIONANGLE" => "90"
#     WEDGEROTATIONANGLE may be null: ""
# 		        }

# create RT Plan if a BEAM GEOMETRY is present
my $process_plans = 0;
for my $i (
  sort {
    $rtog->{image_attr}->{$a}->{IMAGENUMBER} <=> 
    $rtog->{image_attr}->{$b}->{IMAGENUMBER}
  }
  keys %{$rtog->{image_attr}}
){
  if ($rtog->{image_attr}->{$i}->{IMAGETYPE} eq "BEAM GEOMETRY") { $process_plans = 1; }

}

my $seq = 0;
for my $fgid (sort keys %$Doses){
  $seq++;
  my $dose = $Doses->{$fgid};
	# print "Working on FG: $fgid, image file #: $dose->{IMAGENUMBER}.\n";

  if ($process_plans == 1) {
    # Make DICOM Plan file..
    # my $dose = $Doses[$i];
    my $NewPlan = Posda::Dataset->new_blank();

    my $rt = "";
    my @beams = keys %{$dose->{beams}};
    my $beamFirst = $beams[0];
    if ($dose->{beams}->{$beamFirst}->{BEAMMODALITY} eq "X-RAY") {
      $rt = "PHOTON";
    } elsif  ($dose->{beams}->{$beamFirst}->{BEAMMODALITY} eq "ELECTRON") {
      $rt = "ELECTRON";
    } elsif  ($dose->{beams}->{$beamFirst}->{BEAMMODALITY} eq "PROTON") {
      $rt = "PROTON";
    } elsif  ($dose->{beams}->{$beamFirst}->{BEAMMODALITY} eq "NEUTRON") {
      $rt = "NEUTRON";
    } 
    my $SrcAxisDist = 
      $dose->{beams}->{$beamFirst}->{NOMINALISOCENTERDIST} * 10;
    

  # Module: Patient, Ref C.7.1.1
    $NewPlan->Insert("(0010,0010)", $dose->{PATIENTNAME});
    $NewPlan->Insert("(0010,0020)", $PatientId);
    $NewPlan->Insert("(0010,0030)", "");
    $NewPlan->Insert("(0010,0040)", "");

  # Module: Clinical Trial Subject, Ref C.7.1.3
    #  Unknown... (0012,0010), (0012,0020)

  # Module: General Study, Ref C.7.2.1
    $NewPlan->Insert("(0020,000d)", $study_uid);
    $NewPlan->Insert("(0008,0020)",$ddate);
    $NewPlan->Insert("(0008,0021)",$ddate);
    $NewPlan->Insert("(0008,0030)", "");
    $NewPlan->Insert("(0008,0090)", "");       # Pat's ref phys
    $NewPlan->Insert("(0020,0010)", $dose->{CASENUMBER});
    $NewPlan->Insert("(0008,0050)", "");

  # Module: Patient Study, Ref C.7.2.2
    # Unknown...  All type 3...

  # Module: Clinical Trial Study, Ref C.7.2.3
    #  Unknown...
    # Some type 1... (0012,0085)

  # Module: RT Series, Ref C.8.8.1
    $NewPlan->Insert("(0008,0060)", "RTPLAN");
    $NewPlan->Insert("(0020,000e)", "$plan_series_uid.$seq");
    $NewPlan->Insert("(0020,0011)", $ser_seq); # SeriesNum
    $ser_seq++;
    $NewPlan->Insert("(0008,1070)", "");
    $NewPlan->Insert("(0008,103e)", "RT Plan (excerpt) - " . $fgid);

  # Module: Clinical Trial Series, Ref C.7.3.2
    # $NewPlan->Insert("(0012,0060)", "");

  # Module: Frame of Reference, Ref C.7.4.1
    $NewPlan->Insert("(0020,0052)", $for_uid);
    $NewPlan->Insert("(0020,1040)", "");

  # Module: General Equipment, Ref C.7.5.1
    $NewPlan->Insert("(0008,0070)", "Posda RTOG Converter");
    $NewPlan->Insert("(0008,1090)", $0);

  # Module: SOP Common, Ref C.12.1
    $NewPlan->Insert("(0008,0012)", $instance_creation_date);
    $NewPlan->Insert("(0008,0013)", $instance_creation_time);
    $NewPlan->Insert("(0008,0016)", "1.2.840.10008.5.1.4.1.1.481.5");
    $NewPlan->Insert("(0008,0018)", "$plan_series_uid.$seq.1");


  # Module: RT General Plan, Ref C.8.8.9
    $NewPlan->Insert("(300a,0002)",$fgid);
    $NewPlan->Insert("(300a,0003)",$fgid);
    $NewPlan->Insert("(300a,0004)",
      "RT Plan (excerpted from RTOG Data Exchange): " . $fgid);
    $NewPlan->Insert("(300a,0006)", "");
    $NewPlan->Insert("(300a,0007)", "");
    $NewPlan->Insert("(300a,000c)", "PATIENT");
  #  Need to find ss from above...
    # $NewPlan->Insert("(300a,0060)", "??????????????");

  # Module: RT Prescription, Ref C.8.8.10
  # Module: RT Tolerance Tables, Ref C.8.8.11
  # Module: RT Patient Setup, Ref C.8.8.12
  # Module: RT Fraction Scheme, Ref C.8.8.13
  # Module: RT Beams, Ref C.8.8.14
  # Module: RT Fraction Scheme Setups, Ref C.8.8.15
  # Module: Fraction Scheme, Ref C.8.8.16



    # $NewPlan->Insert("(300c,0002)[0](0008,1150)",
    #   "1.2.840.10008.5.1.4.1.1.481.5");
    # $NewPlan->Insert("(300c,0002)[0](0008,1155)", "$plan_series_uid.1");

  # We will NOT insert the Dose Reference Sequence: (300a,0010[....
  # We will also NOT instert the Tolerance Table Sequence: (300a,0040)[...

  # We will always have 1 Fraction Group.  
  # Insert fraction group information.  
    $NewPlan->Insert("(300a,0070)[0](300a,0071)", 0);
    $NewPlan->Insert("(300a,0070)[0](300a,0078)", "");
    $NewPlan->Insert("(300a,0070)[0](300a,0080)", int( keys %{$dose->{beams}}));
    $NewPlan->Insert("(300a,0070)[0](300a,00a0)", 0);
    # BEAMMODALITY is one of: X-RAY, ELECTRON, PROTON, NEUTRON, OTHER
    $NewPlan->Insert("(300a,0070)[0](300a,00C6)", $rt);
    $NewPlan->Insert("(300a,0070)[0](300c,006a)", "1");

    # Insert Patient Setup Module 
    $NewPlan->Insert("(300a,0180)[0](0018,5100)", $orientation);
    $NewPlan->Insert("(300a,0180)[0](300a,0182)", "1");

    # Insert Referenced Structure Set Sequence
    $NewPlan->Insert("(300c,0060)[0](0008,1150)", 
      "1.2.840.10008.5.1.4.1.1.481.3" );
    $NewPlan->Insert("(300c,0060)[0](0008,1155)", "$ss_series_uid.1");

    # Now get all beam information...
    # build beam sequence. 
    my $bi = 0;
    my $beamLast;
    for my $beam (sort keys %{$dose->{beams}}) {
      $beamLast = $beam;
      # print "\n\n  working on beam: $beam, beam index: $bi.\n";
      # print "    Beam Info: ";
      # Debug::GenPrint($dbg, $dose->{beams}->{$beam}, 3);
      # print "\n";
      # print "  working on beam: $beam, beam #: $dose->{beams}->{$beam}->{BEAMNUMBER}, beam index: $bi.\n";

      my $bt =  $dose->{beams}->{$beam}->{BEAMTYPE};
      if ($bt eq "ARC") {
        $bt = "DYNAMIC";
      } elsif ($bt ne "STATIC") {
        die(" beam: $beam, beam #: $dose->{beams}->{$beam}->{BEAMNUMBER}, inv beam type: $bt");
      }
      my $ga = $dose->{beams}->{$beam}->{GANTRYANGLE};
      if ($ga > 0 && $ga <= 360) { $ga = 360 - $ga; }
      if (abs($ga) < 0.01) { $ga = 0.0; }
      
      my $wa = "";
      my $wra = "";
      if (defined($dose->{beams}->{$beam}->{WEDGEANGLE})) {
        $wa = $dose->{beams}->{$beam}->{WEDGEANGLE};
        $wra = $dose->{beams}->{$beam}->{WEDGEROTATIONANGLE};
        # $wra = $dose->{beams}->{$beam}->{WEDGEROTATIONANGLE} + 180;
        # if ($wra > 360) {$wra = 360 - $wra }
      }

      # Insert Reference Beam Sequence info:
      #  or see c.8.8.13 RT Fraction Scheme Module...
      $NewPlan->Insert("(300a,0070)[0](300c,0004)[$bi](300c,0006)", 
        $dose->{beams}->{$beam}->{BEAMNUMBER});
      $NewPlan->Insert("(300a,0070)[0](300c,0004)[$bi](300a,0086)", 
        $dose->{beams}->{$beam}->{'RXDOSEPERTX(GY)'});

      # Instert Beam Sequence info:
      $NewPlan->Insert("(300a,00b0)[$bi](0008,0070)", "Posda RTOG Converter");
      $NewPlan->Insert(
        "(300a,00b0)[$bi](300a,00b6)[0](300a,00bc)", "1");
      if ($dose->{beams}->{$beam}->{COLLIMATORTYPE} eq "SYMMETRIC") {
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,00b6)[0](300a,00b8)", "X");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,00b6)[0](300a,011c)", '-40.0\40.0');
      } elsif ( $dose->{beams}->{$beam}->{COLLIMATORTYPE} eq "ASYMMETRIC") {
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,00b6)[0](300a,00b8)", "ASYMX");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,00b6)[0](300a,011c)", '-40.0\40.0');
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,00b6)[1](300a,00b8)", "ASYMY");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,00b6)[1](300a,011c)", '-40.0\40.0');
      } elsif ( $dose->{beams}->{$beam}->{COLLIMATORTYPE} eq "ASYMMETRIC_X"){
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,00b6)[0](300a,00b8)", "ASYMX");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,00b6)[0](300a,011c)", '-40.0\40.0');
      } elsif ( $dose->{beams}->{$beam}->{COLLIMATORTYPE} eq "ASYMMETRIC_Y"){
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,00b6)[0](300a,00b8)", "ASYMY");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,00b6)[0](300a,011c)", '-40.0\40.0');
      } else {
        die "Not handling case of beam COLLIMATORTYPE: " .
          $dose->{beams}->{$beam}->{COLLIMATORTYPE};
      }
      # Insert control point information 
      #   Insert 2 control points, setup & Cumulative Meterset Weight:"0"
      #   First control point:
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0110)", 2);
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[0](300a,0112)", 0);
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[0](300a,0114)", 
        $dose->{beams}->{$beam}->{'BEAMENERGY(MEV)'});
      if ($dose->{beams}->{$beam}->{COLLIMATORTYPE} eq "SYMMETRIC") {
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[0](300a,011a)[0](300a,00b8)", "X");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[0](300a,011a)[0](300a,011c)",
          '-40.0\40.0');
      } elsif ( $dose->{beams}->{$beam}->{COLLIMATORTYPE} eq "ASYMMETRIC") {
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[0](300a,011a)[0](300a,00b8)","ASYMX");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[0](300a,011a)[0](300a,011c)",
          '-40.0\40.0');
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[0](300a,011a)[1](300a,00b8)","ASYMY");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[0](300a,011a)[1](300a,011c)",
          '-40.0\40.0');
      } elsif ( $dose->{beams}->{$beam}->{COLLIMATORTYPE} eq "ASYMMETRIC_X"){
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[0](300a,011a)[0](300a,00b8)","ASYMX");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[0](300a,011a)[0](300a,011c)",
          '-40.0\40.0');
      } elsif ( $dose->{beams}->{$beam}->{COLLIMATORTYPE} eq "ASYMMETRIC_Y"){
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[0](300a,011a)[0](300a,00b8)","ASYMY");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[0](300a,011a)[0](300a,011c)",
          '-40.0\40.0');
      } else {
        die "Not handling case of beam COLLIMATORTYPE: " .
          $dose->{beams}->{$beam}->{COLLIMATORTYPE};
      }
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[0](300a,011e)", $ga);
      if ($dose->{beams}->{$beam}->{BEAMTYPE} eq "STATIC") {
        $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[0](300a,011f)","NONE");
      }
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[0](300a,0120)",
        $dose->{beams}->{$beam}->{COLLIMATORANGLE});
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[0](300a,0121)","NONE");
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[0](300a,0122)",
        $dose->{beams}->{$beam}->{COUCHANGLE});
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[0](300a,0125)", 0.0);
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[0](300a,0126)","NONE");
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[0](300a,012c)",
        '0.0\0.0\0.0');
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[0](300a,0130)",
        $dose->{beams}->{$beam}->{NOMINALISOCENTERDIST} * 10);
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[0](300a,0134)", 0);

      $NewPlan->Insert("(300a,00b0)[$bi](300a,00d0)", "0");
      if ($wa ne "") {
        $NewPlan->Insert("(300a,00b0)[$bi](300A,00D0)", "1");
        $NewPlan->Insert("(300a,00b0)[$bi](300A,00D1)[0](300a,00d2)", $bi);
        $NewPlan->Insert("(300a,00b0)[$bi](300A,00D1)[0](300a,00d3)", 
          "STANDARD");
        $NewPlan->Insert("(300a,00b0)[$bi](300A,00D1)[0](300a,00d5)", $wa);
        $NewPlan->Insert("(300a,00b0)[$bi](300A,00D1)[0](300a,00d8)", $wra);

      }

      #   Second control point:
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,0112)", 1);
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,0112)", 0);
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,0114)", 
        $dose->{beams}->{$beam}->{'BEAMENERGY(MEV)'});
      if ($dose->{beams}->{$beam}->{COLLIMATORTYPE} eq "SYMMETRIC") {
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[1](300a,011a)[0](300a,00b8)", 
          "X");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[1](300a,011a)[0](300a,011c)",
          '-40.0\40.0');
      } elsif ( $dose->{beams}->{$beam}->{COLLIMATORTYPE} eq "ASYMMETRIC") {
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[1](300a,011a)[0](300a,00b8)", 
          "ASYMX");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[1](300a,011a)[0](300a,011c)",
          '-40.0\40.0');
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[1](300a,011a)[1](300a,00b8)", 
          "ASYMY");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[1](300a,011a)[1](300a,011c)",
          '-40.0\40.0');
      } elsif ( $dose->{beams}->{$beam}->{COLLIMATORTYPE} eq "ASYMMETRIC_X"){
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[1](300a,011a)[0](300a,00b8)", 
          "ASYMX");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[1](300a,011a)[0](300a,011c)",
          '-40.0\40.0');
      } elsif ( $dose->{beams}->{$beam}->{COLLIMATORTYPE} eq "ASYMMETRIC_Y"){
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[1](300a,011a)[0](300a,00b8)", 
          "ASYMY");
        $NewPlan->Insert(
          "(300a,00b0)[$bi](300a,0111)[1](300a,011a)[0](300a,011c)",
          '-40.0\40.0');
      } else {
        die "Not handling case of beam COLLIMATORTYPE: " .
          $dose->{beams}->{$beam}->{COLLIMATORTYPE};
      }
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,011e)", $ga);
      if ($dose->{beams}->{$beam}->{BEAMTYPE} eq "STATIC") {
        $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,011f)","NONE");
      }
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,0120)",
        $dose->{beams}->{$beam}->{COLLIMATORANGLE});
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,0121)","NONE");
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,0122)",
        $dose->{beams}->{$beam}->{COUCHANGLE});
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,0125)", 0.0);
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,0126)","NONE");
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,012c)",
        '0.0\0.0\0.0');
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,0130)",
        $dose->{beams}->{$beam}->{NOMINALISOCENTERDIST} * 10);
      $NewPlan->Insert("(300a,00b0)[$bi](300a,0111)[1](300a,0134)", 100);

      #   ????? Need to add RT Beam Limiting Device Type...
      $NewPlan->Insert("(300a,00b0)[$bi](300a,00b4)", $SrcAxisDist);
      $NewPlan->Insert("(300a,00b0)[$bi](300a,00c0)", 
        $dose->{beams}->{$beam}->{BEAMNUMBER});
      $NewPlan->Insert("(300a,00b0)[$bi](300a,00c2)", 
        $dose->{beams}->{$beam}->{BEAMNUMBER});
      $NewPlan->Insert("(300a,00b0)[$bi](300a,00c3)", 
        $dose->{beams}->{$beam}->{BEAMDESCRIPTION});
      $NewPlan->Insert("(300a,00b0)[$bi](300a,00c4)", $bt);
      $NewPlan->Insert("(300a,00b0)[$bi](300a,00c6)", $rt);
      $NewPlan->Insert("(300a,00b0)[$bi](300a,00ce)", "TREATMENT");
      $NewPlan->Insert("(300a,00b0)[$bi](300a,00e0)", "0");
      $NewPlan->Insert("(300a,00b0)[$bi](300a,00ed)", "0");
      $NewPlan->Insert("(300a,00b0)[$bi](300a,00f0)", "0");
      $NewPlan->Insert("(300a,00b0)[$bi](300a,010e)", 100);

  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,0070)","Posda RTOG Converter");
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,0080)",$institution);
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00b2)","?????");
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00b3)","?????");
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00b4)","?????");
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00b6)","?????");
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00b2)","?????");
  # 		# need to add (300a,00b0[?](300a,00b6)....
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00c0)",$beam);  # beam number
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00c2)",$beam);  # beam name
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00c3)",$dose->{beams}->{$beam}->{BEAMDESCRIPTION});
  # 		my $bt = $dose->{beams}->{$beam}->{BEAMTYPE};
  # 		my $dbt = $bt;
  # 		if ($bt  eq "STATIC" ) { $dbt = $bt }
  # 		elsif  ($bt  eq "ARC" ) { $dbt = "DYNAMIC"; }
  # 		else { die "Invalid beam type: $bt"};
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00c4)",$dbt);
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00b2)","?????");
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00b2)","?????");
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00b2)","?????");
  # 		$NewPlan->Insert("(300a,00b0)[$bi](0008,00b2)","?????");
      $bi++;
    }
    $bi--;

    $filename = "$to_directory/RTP_$plan_series_uid.$seq.dcm";
    $NewPlan->WritePart10($filename,  
      "1.2.840.10008.1.2", "RTOG_CONV", undef, undef);
  }

  # Make DICOM Dose file..
  $rows = $dose->{SIZEOFDIMENSION2};
  $cols = $dose->{SIZEOFDIMENSION1};
  my $NewDose = Posda::Dataset->new_blank();
  $NewDose->Insert("(0008,0016)", "1.2.840.10008.5.1.4.1.1.481.2");
  $NewDose->Insert("(0008,0018)", "$dose_series_uid.$seq.1");
  $NewDose->Insert("(0008,103e)", "RT Dose - " .
    "$dose->{FRACTIONGROUPID}");
  $NewDose->Insert("(0008,0020)", $ddate);
  $NewDose->Insert("(0008,0021)", $ddate);
  $NewDose->Insert("(0008,0030)", "");
  $NewDose->Insert("(0008,0060)", "RTDOSE");
  $NewDose->Insert("(0020,000d)", $study_uid);
  $NewDose->Insert("(0020,0010)", $dose->{CASENUMBER});
  $NewDose->Insert("(0020,0011)", $ser_seq);
  $ser_seq++;
  $NewDose->Insert("(0020,000e)", "$dose_series_uid.$seq");
  $NewDose->Insert("(0010,0010)", $dose->{PATIENTNAME});
  $NewDose->Insert("(0010,0020)", $PatientId);
  $NewDose->Insert("(0028,0004)", "MONOCHROME2");
  $NewDose->Insert("(0028,0009)", 0x0c3004);
  $NewDose->Insert("(3004,000a)", "PLAN");
  $NewDose->Insert("(300c,0002)[0](0008,1150)",
    "1.2.840.10008.5.1.4.1.1.481.5");
  $NewDose->Insert("(300c,0002)[0](0008,1155)", "$plan_series_uid.1");
  $NewDose->Insert("(0020,0052)", $for_uid);
  my $DoseFile = $rtog->{image_file}->{$dose->{IMAGENUMBER}};
  my($iop, $ipp, $gfov, $pix_sp, $pix, $dose_scaling) = 
    GetDoseDescrip($dose, $DoseFile);

  $NewDose->Insert("(0028,0030)",$pix_sp);
  $NewDose->Insert("(0028,0010)",$rows);
  $NewDose->Insert("(0028,0011)",$cols);
  $NewDose->Insert("(0020,0037)",$iop);
  $NewDose->Insert("(0020,0032)",$ipp);
  $NewDose->Insert("(0028,0100)",16);
  $NewDose->Insert("(0028,0101)",16);
  $NewDose->Insert("(0028,0102)",15);
  $NewDose->Insert("(0028,0002)",1);
  $NewDose->Insert("(0028,0103)",0);
  $NewDose->Insert("(3004,0002)", "GY");
  $NewDose->Insert("(3004,0004)", $dose->{DOSETYPE});
  $NewDose->Insert("(3004,000c)", $gfov);
  $NewDose->Insert("(0028,0008)",scalar @$gfov);
  $NewDose->Insert("(3004,000e)", $dose_scaling);
  $NewDose->Insert("(300c,0002)[0](0008,1150)", 
	  "1.2.840.10008.5.1.4.1.1.481.5");
  $NewDose->Insert("(300c,0002)[0](0008,1155)", "$plan_series_uid.$seq.1");

  $NewDose->Insert("(7fe0,0010)", $pix);

  my $filename = "$to_directory/RTD_$dose_series_uid.$seq.dcm";
  $NewDose->WritePart10($filename,  
    "1.2.840.10008.1.2", "RTOG_CONV", undef, undef);
}
exit 0;
###############################
# Sub's
###############################
sub GetDoseDescrip{
  my($dose, $DoseFile) = @_;
  unless($dose->{ORIENTATIONOFDOSE} eq "TRANSVERSE") {
    die "Can't handle \"$dose->{ORIENTATIONOFDOSE}\" dose";
  }
  my($ipp, $iop, $gfov, $rows, $cols, $pix_sp, $pix, $dose_scaling);
  $pix_sp = [
    -($dose->{VERTICALGRIDINTERVAL} * 10),
    $dose->{HORIZONTALGRIDINTERVAL} * 10,
  ];
  $iop = [1,0,0,0,1,0];
    
  if($dose->{NUMBERREPRESENTATION} eq "TWO'S COMPLEMENT INTEGER"){
    die "binary dose not yet supported";
  }elsif($dose->{NUMBERREPRESENTATION} eq "CHARACTER"){
    ($gfov, $ipp, $pix, $dose_scaling) = ReadSillyDoseFile($DoseFile, $dose);
    return($iop, $ipp, $gfov, $pix_sp, $pix, $dose_scaling);
  }else{
    die "Can't handle dose number representation of \"" .
      $dose->{NUMBERREPRESENTATION}. "\"";
  }
}
sub ReadSillyDoseFile{
  my($file_name, $dose) = @_;
  open FILE, "cat $file_name|$rtog_text_to_num_cmd|";
  my $max_num;
  while(my $num = <FILE>){
    chomp $num;
    unless(defined $max_num){ $max_num = $num }
    if($num > $max_num) { $max_num = $num }
  }
  my $scaling = 65535/$max_num;
  close FILE;
  open FILE, "cat $file_name|$rtog_text_to_num_cmd|";
  my $construct_file = "$temp_dir/.Rtog_dose_construct_$$.temp";
  open CONSTRUCT, ">$construct_file" or 
    die "can't open temp file ($construct_file) for contruction of dose";
  my $planes_remaining;
  my $rows_remaining;
  my $cols_remaining;
  my @gfp;
  my $dose_scaling;
  my $dose_mult;
  if($dose->{DOSEUNITS} eq "CGYS"){
    $dose_mult = $scaling;
    $dose_scaling = 1 / (100 * $scaling);
  } elsif($dose->{DOSEUNITS} eq "GRAYS"){
    $dose_mult = $scaling;
    $dose_scaling = 1 / $scaling;
  } else {
    close CONSTRUCT;
    unlink "$construct_file";
    die "Don't know how to scale dose units of \"$dose->{DOSEUNITS}\"";
  }
  line:
  while (my $line = <FILE>){
    chomp $line;
    unless(defined $planes_remaining) {
      $planes_remaining = $line;
      $rows_remaining = 0;
      $cols_remaining = $cols;
      next line;
    }
    if($rows_remaining == 0){
      push(@gfp, 
        Posda::Transforms::ApplyTransform($xform, [
          $dose->{COORD1OFFIRSTPOINT} * 10,
          $dose->{COORD2OFFIRSTPOINT} * 10, 
          $line * 10
        ])
      );
      $rows_remaining = $rows;
      next line;
    }
    if($cols_remaining > 0){
      my $pixel = int(($line * $dose_mult) + 0.5);

      print CONSTRUCT pack("v", $pixel);
      $cols_remaining -= 1;
      if($cols_remaining == 0){
        $rows_remaining -= 1;
        $cols_remaining = $cols;
        if($rows_remaining == 0) {
           $planes_remaining -= 1;
           if($planes_remaining == 0){ last line }
           next line;
        }
      }
    }
  }
  close FILE;
  close CONSTRUCT;
  unless (open CONSTRUCT, "<$construct_file") {
    unlink "$construct_file";
    die "can't reopen temp file ($construct_file) in which dose constructed";
  }
  my $num_planes = scalar @gfp;
  my $pix_size = $rows * $cols * $num_planes * 2;
  seek(CONSTRUCT, 0, 0);
  my $pixels;
  my $len = read(CONSTRUCT, $pixels, $pix_size);
  if($len != $pix_size) {
    unlink "$construct_file";
    die "read wrong length for Dose Pixel data: $len vs $pix_size";
  }
  close CONSTRUCT;
  unlink "$construct_file";
  my $ipp = [$gfp[0]->[0], $gfp[0]->[1], $gfp[0]->[2]];
  my @gfov;
  my $first_z = $gfp[0]->[2];
  for my $i (@gfp){
    push @gfov, ($i->[2] - $first_z);
  }
  return (\@gfov, $ipp, $pixels, $dose_scaling);
}
sub CreateDicomCt{
  my($dir, $desc) = @_;
  my $ToSig = {
    ImageType => "(0008,0008)",
    SopInstanceUid => "(0008,0018)",
    StudyDate => "(0008,0020)",
    SeriesDate => "(0008,0021)",
    StudyUid => "(0020,000d)",
    Modality => "(0008,0060)",
    SeriesUid => "(0020,000e)",
    SeriesDescription => "(0008,103e)",
    SopClassUid => "(0008,0016)",
    ForUid => "(0020,0052)",
    StudyId => "(0020,0010)",
    SeriesNum => "(0020,0011)",
    ImageNumber => "(0020,0013)",
    PatientsName => "(0010,0010)",
    PatientsId => "(0010,0020)",
    PatientPosition => "(0018,5100)",
    PixelSpacing => "(0028,0030)",
		PhotometricInterpretation => "(0028,0004)",
    Rows => "(0028,0010)",
    Cols => "(0028,0011)",
    Slope => "(0028,1053)",
    Intercept => "(0028,1052)",
    Iop => "(0020,0037)",
    Ipp => "(0020,0032)",
		SliceLocation => "(0020,1041)",
		SliceThickness => "(0018,0050)",
    BitsAllocated => "(0028,0100)",
    BitsStored => "(0028,0101)",
    HighBit => "(0028,0102)",
    PixelRepresentation => "(0028,0103)",
    SamplesPerPixel => "(0028,0002)",
    WindowCenter => "(0028,1050)",
    WindowWidth => "(0028,1051)",
  };
  my $dcm = Posda::Dataset->new_blank();
  for my $i (keys %{$ToSig}){
    if(exists $desc->{$i}){
      $dcm->Insert($ToSig->{$i}, $desc->{$i});
    }
  }
  my $pix_data;
  my $num_bytes = 2;
  if($desc->{BitsAllocated} == 8){
    $num_bytes = 1;
  }elsif($desc->{BitsAllocated} != 16){
    die "CT with $desc->{BitsAllocated} bits Allocated";
  }

  
  my $pix_size = $desc->{Rows} * $desc->{Cols} * $num_bytes;
  open FILE, "<$desc->{PixelFile}" or die "can't open $desc->{PixelFile}";
  unless((my $len = read(FILE, $pix_data, $pix_size + 10)) == $pix_size){
    die "read wrong length for CT Pixel data: $len vs $pix_size";
  }
  my $swapped_pix = pack("v*", unpack("n*", $pix_data));
  $dcm->Insert("(7fe0,0010)", $swapped_pix);
  $dcm->WritePart10("$dir/$desc->{FileName}",  
    "1.2.840.10008.1.2", "RTOG_CONV", undef, undef);
}
sub ParseSegmentFile{
  my($file_name) = @_;
  my $num_scans;
  my $scan_number;
  my $num_points;
  my $num_segs;
  my $segments;
  my $points;
  my $expect;
  my $x;
  my $y;
  my @contours;
  open FILE, "cat $file_name|$rtog_text_to_num_cmd|";
  line:
  while(my $line = <FILE>){
    chomp $line;
    unless(defined $num_scans){
      $num_scans = $line;
      $expect = "scan_number";
      next line;
    }
    if($expect eq "scan_number"){
      $scan_number = $line;
      $expect = "num_segs";
      next line;
    }
    if($expect eq "num_segs"){
      $num_segs = $line;
      if($num_segs > 0){
        $expect = "num_points";
        $points = [];
        $segments = [];
        next line;
      }
      $num_scans -= 1;
      if($num_scans > 0){
        $expect = "scan_number";
        next line;
      }
      $expect = "nothing";
      next line;
    }
    if($expect eq "num_points"){
      $num_points = $line;
      if($num_points > 0){
         $expect = "pointx";
         $points = [];
         next line;
      }
      $num_scans -= 1;
      if($num_scans == 0){
        $expect = "nothing";
      } else {
        $expect = "scan_number";
      }
      next line;
    }
    if($expect eq "pointx"){
      $x = $line;
      $expect = "pointy";
      next line;
    }
    if($expect eq "pointy"){
      $y = $line;
      $expect = "pointz";
      next line;
    }
    if($expect eq "pointz"){
      my $z = $line;
      push(@$points, [$x, $y, $z]);
      $num_points -= 1;
      if($num_points > 0) {
        $expect = "pointx";
        next line;
      }
      push(@$segments, $points);
      $points = [];
      $num_segs -= 1;
      if($num_segs > 0){
        $expect = "num_points";
         next line;
      }
      push(@contours, {
        scan_number => $scan_number,
        segments => $segments,
      });
      $num_scans -= 1;
      if($num_scans > 0){
        $expect = "scan_number";
        next line;
      }
      $expect = "nothing";
      next line;
    }
    if($expect eq "nothing"){
      die "unexpected line at end of $file_name";
    }
  }
  close FILE;
  unless ($expect eq "nothing") {
    die "EOD when expecting $expect in $file_name";
  }
  return \@contours;
}
