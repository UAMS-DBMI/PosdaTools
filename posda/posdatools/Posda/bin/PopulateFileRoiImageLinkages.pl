#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::Try;
use Posda::SimplerDicomAnalysis;
use Digest::MD5 qw( md5_hex );
use Debug;
my $dbg = sub {print @_};
my $usage = <<EOF;
  PopulateFileRoiImageLinkages.pl
or
  PopulateFileRoiImageLinkages.pl -h

Uses query "GetListOfUnprocessedStructureSets" to
get a list of structure sets which do not have entries in
the file_roi_image_linkages table, and processes them,
using queries "GetRoiIdFromFileIdRoiNum",
"AddNewDataToRoiTable", and "InsertIntoFileRoiImageLinkage".

EOF
sub ComputeDigest{
  my($file, $offset, $length) = @_;
  open FILE, "<$file" or die "can't open $file";
  seek FILE, $offset, 0;
  my $buff;
  read FILE, $buff, $length;
  my $digest = md5_hex($buff);
  return $digest;
}
my $StartTime = time;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print STDERR $usage;
  exit;
}
unless($#ARGV < 0) { die $usage }
my %StructureSetList;
my $get_list = PosdaDB::Queries->GetQueryInstance(
  "GetListOfUnprocessedStructureSets"
);
my $get_roi_id = PosdaDB::Queries->GetQueryInstance(
  "GetRoiIdFromFileIdRoiNum"
);
my $add_roi_data = PosdaDB::Queries->GetQueryInstance(
  "AddNewDataToRoiTable"
);
my $insert_linkage = PosdaDB::Queries->GetQueryInstance(
  "InsertIntoFileRoiImageLinkage"
);
$get_list->RunQuery(
  sub {
    my($row) = @_;
    my $file_id = $row->[0];
    my $path = $row->[1];
    if(exists $StructureSetList{$file_id}){
      print STDERR "$file_id has multiple paths\n";
      return;
    }
    $StructureSetList{$file_id} = $path;
  },
  sub {}
);
my $num_file = keys %StructureSetList;
print "$num_file Structure Sets to Process\n";
my $num_processed = 0;
for my $file_id (sort {$a <=> $b} keys %StructureSetList){
  my %roi_num_to_roi_id;
  my %roi_updated;
  $num_processed += 1;
  my $file = $StructureSetList{$file_id};
  my $try = Posda::Try->new($file);
  my $analysis = Posda::SimplerDicomAnalysis::Analyze($try, $file);
  print "file: $file_id\n";
  my $ds_start = 0;
  
  if(defined($analysis->{MetaHeader}->{DataSetStart})){
    $ds_start = $analysis->{MetaHeader}->{DataSetStart};
  }
  for my $roi_num (keys %{$analysis->{rois}}){
    my $roi = $analysis->{rois}->{$roi_num};
    print "\troi_num: $roi_num\n";
    unless(defined $roi_num_to_roi_id{$roi_num}){
      $get_roi_id->RunQuery(sub {
        my($row) = @_;
        $roi_num_to_roi_id{$roi_num} = $row->[0];
      }, sub {}, $file_id, $roi_num);
    }
    my $roi_id = $roi_num_to_roi_id{$roi_num};
    print "\troi_id: $roi_id\n";
    my($max_x, $max_y, $max_z, $min_x, $min_y, $min_z);
    my($roi_interpreted_type, $roi_obser_desc, $roi_obser_label);
    unless(exists $roi_updated{$roi_id}){
      $roi_updated{$roi_id} = 1;
      my $max_x = $roi->{max_x};
      my $max_y = $roi->{max_y};
      my $max_z = $roi->{max_z};
      my $min_x = $roi->{min_x};
      my $min_y = $roi->{min_y};
      my $min_z = $roi->{min_z};
      my $roi_interpreted_type = $roi->{roi_interpreted_type};
      my $roi_obser_desc = $roi->{roi_obser_desc};
      my $roi_obser_label = $roi->{roi_obser_label};
      $add_roi_data->RunQuery(sub{}, sub {},
        $max_x, $max_y, $max_z,
        $min_x, $min_y, $min_z,
        $roi_interpreted_type,
        $roi_obser_desc,
        $roi_obser_label,
        $roi_id);
      contour:
      for my $contour (@{$roi->{contours}}){
        unless(defined($contour->{ref})){ next contour }
        my($linked_sop_instance_uid, $linked_sop_class_uid);
        my($contour_file_offset, $contour_length, $contour_digest);
        my($num_points, $contour_type);
        $linked_sop_instance_uid = $contour->{ref};
        $linked_sop_class_uid = $contour->{ref_type};
        $num_points = $contour->{num_pts};
        $contour_file_offset = $contour->{ds_offset} + $ds_start;
        $contour_length = $contour->{length};
        $contour_type = $contour->{type};
        $contour_digest = ComputeDigest($file, $contour_file_offset, 
          $contour_length);
        $insert_linkage->RunQuery(sub {}, sub {},
          $file_id,
          $roi_id,
          $linked_sop_instance_uid,
          $linked_sop_class_uid,
          $contour_file_offset,
          $contour_length,
          $contour_digest,
          $num_points,
          $contour_type,);
      }
    }
  }
  
  my $now = time;
  my $elapsed = $now - $StartTime;
  print "$num_processed processed after $elapsed\n";
}
