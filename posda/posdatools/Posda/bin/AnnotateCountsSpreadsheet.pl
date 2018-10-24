#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::BackgroundProcess;

my $usage = <<EOF;
AnnotateCountsSpreadsheet.pl <id>  <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  notify - email of party to notify

Expects the following list on <STDIN>
  <PID>|<ImageType>|<Modality>|<Images>|<StudyDate|<StudyDescription>|<SeriesDescription>|<SeriesNumber>|<StudyInstanceUID>|<Mfr>|<Model>|<software_versions|

Adds the following columns
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
if($#ARGV != 1){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my $num_lines = 0;
my @AllHeaders = (
  "PID",
  "ImageType",
  "Modality",
  "Images",
  "StudyDate",
  "StudyDescription",
  "SeriesDescription",
  "SeriesNumber",
  "StudyInstanceUID",
  "SeriesInstanceUID",
  "Mfr",
  "Model",
  "software_versions"
);
my @PtHeaders = (
  "radiopharmaceutical", 
  "total_dose",
  "half_life",
  "positron_fraction", 
  "fov_shape",
  "fov_dim",
  "coll_type",
  "recon_diam");
my @CtHeaders = (
  "kvp",
  "scan_options",
  "data_collection_diameter",
  "reconstruction_diameter",
  "dist_source_to_detect",
  "dist_source_to_pat",
  "gantry_tilt",
  "rotation_dir",
  "exposure_time",
  "filter_type",
  "generator_power", 
  "convolution_kernal",
  "table_feed_per_rot"
);
my @Lines;
while(my $line = <STDIN>){
  $num_lines += 1;
  $background->LogInputLine($line);
  chomp $line;
  my @fields = split /\|/, $line;
  my $h;
  for my $i (0 .. $#AllHeaders){
    $fields[$i] =~ s/^\s*//;
    $fields[$i] =~ s/\s*$//;
    $h->{$AllHeaders[$i]} = $fields[$i];
  }
  push @Lines, $h;
}
print "$num_lines lines read for processing\n";
my $info = $Lines[0];
print "Background processing beginning\n";
$background->Daemonize;
my $rept = $background->CreateReport("AnnotatedCountsSpreadsheet");
my $get_dicom_obj_type = PosdaDB::Queries->GetQueryInstance(
  "GetDicomObjectTypeBySeries");
my $get_pt_info = PosdaDB::Queries->GetQueryInstance(
  "GetPtInfoBySeries");
my $get_ct_info = PosdaDB::Queries->GetQueryInstance(
  "GetCtInfoBySeries");
$background->WriteToEmail("Starting annotation of spreadsheet\n");
for my $i (@AllHeaders){
  $rept->print("\"$i\",");
}
$rept->print("\"DicomObjectType\",");
for my $i (@CtHeaders){
  $rept->print("\"$i\",");
}
for my $i (@PtHeaders){
  $rept->print("\"$i\",");
}
$rept->print("\n");
line:
for my $i (0 .. $#Lines){
  my $info = $Lines[$i];
  my $obj_type;
  $get_dicom_obj_type->RunQuery(sub {
    my($row) = @_;
    $obj_type = $row->[0];
  }, sub {}, $info->{SeriesInstanceUID});
  $info->{DicomObjectType} = $obj_type;
  if($obj_type eq "CT Image Storage"){
    $get_ct_info->RunQuery(sub{
      my($row) = @_;
      for my $i (0 .. $#CtHeaders){
         $info->{$CtHeaders[$i]} = $row->[$i];
      }
    }, sub{}, $info->{SeriesInstanceUID});
  }
  if($obj_type eq "Positron Emission Tomography Image Storage"){
    $get_pt_info->RunQuery(sub{
      my($row) = @_;
      for my $i (0 .. $#PtHeaders){
         $info->{$PtHeaders[$i]} = $row->[$i];
      }
    }, sub{}, $info->{SeriesInstanceUID});
  }
  for my $i (@AllHeaders){
    $rept->print ("\"$info->{$i}\",");
  }
  $rept->print("\"$info->{DicomObjectType}\",");
  for my $i (@CtHeaders){
    if(defined $info->{$i}){
      $rept->print("\"$info->{$i}\",");
    } else {
      $rept->print(",");
    }
  }
  for my $i (@PtHeaders){
    if(defined $info->{$i}){
      $rept->print("\"$info->{$i}\",");
    } else {
      $rept->print(",");
    }
  }
  $rept->print("\n");
}
$background->WriteToEmail("We're finished\n");
$background->Finish;
