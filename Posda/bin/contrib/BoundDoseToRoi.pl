#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/BoundDoseToRoi.pl,v $
#$Date: 2012/02/08 21:05:04 $
#$Revision: 1.1 $
#
use strict;
use Cwd;
use Posda::Transforms;
use PipeChildren;
use Posda::UUID;
use Storable qw( store_fd fd_retrieve );
use Debug;
my $dbg = sub {print @_};
my $usage = "$0 <dose_file> <struct_file> <new_dir> <roi_name>";
unless($#ARGV == 3){ die "usage: $usage\n"; }
my $dose_file = $ARGV[0];
my $struct_file = $ARGV[1];
my $new_dir = $ARGV[2];
my $roi_name = $ARGV[3];
my $dir = getcwd;
unless($dose_file =~ /^\//) { $dose_file = "$dir/$dose_file" }
unless($struct_file =~ /^\//) { $struct_file = "$dir/$struct_file" }
unless($new_dir =~ /^\//) { $new_dir = "$dir/$new_dir" }
unless(-f $dose_file) { die "$dose_file is not a file" }
unless(-f $struct_file) { die "$struct_file is not a file" }
unless(-d $new_dir) { die "$new_dir is not a directory" }
my $contour_dir = "$new_dir/contours";
my $dvh_dir = "$new_dir/dvh";
unless(-d $contour_dir) {
  unless(mkdir($contour_dir)){
    die "couldn't make dir $contour_dir $!";
  }
}
CreateCacheSubDirs($contour_dir);
unless(-d $dvh_dir) {
  unless(mkdir($dvh_dir)){
    die "couldn't make dir $dvh_dir $!";
  }
}
CreateCacheSubDirs($dvh_dir);
my $struct_info = GetFileInfo($struct_file);
my $dose_info = GetFileInfo($dose_file);
#print "DoseInfo: ";
#Debug::GenPrint($dbg, $dose_info, 1, 3);
#print "\nStructInfo: ";
#Debug::GenPrint($dbg, $struct_info, 1, 3);
#print "\n";
my @iop = split(/\\/, $dose_info->{"(0020,0037)"});
my @ipp = split(/\\/, $dose_info->{"(0020,0032)"});
my $norm_xform = Posda::Transforms::NormalizingVolume(\@iop, \@ipp);
my $unnorm_xform = Posda::Transforms::InvertTransform($norm_xform);
my $dose_bb = Posda::Transforms::TransformBoundingBox(
  $norm_xform, $dose_info->{DoseBoundingBox});
my $roi_info;
for my $i (keys %{$struct_info->{rois}}){
  if($struct_info->{rois}->{$i}->{roi_name} eq $roi_name){
    if(defined $roi_info) { die "more than one roi named $roi_name" }
    $roi_info = $struct_info->{rois}->{$i};
  }
}
unless(defined $roi_info) { die "no roi named $roi_name" }
my $roi_bb = [
  [$roi_info->{min_x}, $roi_info->{min_y}, $roi_info->{min_z}],
  [$roi_info->{max_x}, $roi_info->{max_y}, $roi_info->{max_z}]];
my $norm_roi_bb = Posda::Transforms::TransformBoundingBox($norm_xform,
  $roi_bb);
print "DoseBB:\n" .
  "\t$dose_bb->[0]->[0], $dose_bb->[0]->[1], $dose_bb->[0]->[2]]\n" .
  "\t$dose_bb->[1]->[0], $dose_bb->[1]->[1], $dose_bb->[1]->[2]]\n" .
  "StructBB:\n" .
  "\t$norm_roi_bb->[0]->[0], $norm_roi_bb->[0]->[1], $norm_roi_bb->[0]->[2]]\n" .
  "\t$norm_roi_bb->[1]->[0], $norm_roi_bb->[1]->[1], $norm_roi_bb->[1]->[2]]\n";

my @gfov = split(/\\/, $dose_info->{"(3004,000c)"});
my $slice_spc = $gfov[$#gfov] / $#gfov;
my ($row_spc, $col_spc) = split(/\\/, $dose_info->{"(0028,0030)"});
my $new_num_slices = int(
  (($norm_roi_bb->[1]->[2] - $norm_roi_bb->[0]->[2]) / $slice_spc) +
  ($slice_spc / 2));
my $resamp_rows = int (
  (($norm_roi_bb->[1]->[1] - $norm_roi_bb->[0]->[1]) / $row_spc) +
  ($row_spc /2));
my $resamp_cols = int (
  (($norm_roi_bb->[1]->[0] - $norm_roi_bb->[0]->[0]) / $col_spc) +
  ($col_spc /2));
my $resamp_args = {
  source_dose_file_name => $dose_file,
  source_rows => $dose_info->{"(0028,0010)"},
  source_cols => $dose_info->{"(0028,0011)"},
  source_rowspc => $row_spc,
  source_colspc => $col_spc,
  source_pixel_offset =>$dose_info->{pix_pos},
  source_gfov_offset =>$dose_info->{gfov_pos},
  source_gfov_length =>$dose_info->{gfov_len},
  source_bits_alloc => $dose_info->{'(0028,0100)'},
  source_dose_scaling => $dose_info->{'(3004,000e)'},
  source_dose_units => 
        ( $dose_info->{'(3004,0002)'} eq "GY" ||
          $dose_info->{'(3004,0002)'} eq "GRAY"
        ) ?
          "GRAY"
        :
          "CGRAY",
  resamp_ulx => $roi_bb->[0]->[0],
  resamp_uly => $roi_bb->[0]->[1],
  resamp_ulz => $roi_bb->[0]->[2],
  r_spc_x => $row_spc,
  r_spc_y => $col_spc,
  r_spc_z => $slice_spc,
  resamp_rows => $resamp_rows,
  resamp_cols => $resamp_cols,
  resamp_frames => $new_num_slices,
  resamp_bits_alloc => 16,
  resamp_dose_units => "CGRAY",
  resamp_dose_scaling => '0.1',
};
for my $i (sort keys %$resamp_args){
  print "$i => $resamp_args->{$i}\n";
}
my $resamp_pipe = PipeChildren::GetSocketPair(my $to_r, my $from_r);
my $r_stat_pipe = PipeChildren::GetSocketPair(my $to_r_s, my $from_r_s);
my $dose_pipe = PipeChildren::GetSocketPair(my $to_d, my $from_d);
my $d_stat_pipe = PipeChildren::GetSocketPair(my $to_d_s, my $from_d_s);
my $new_uid = Posda::UUID->GetUUID;
my $new_series = "$new_uid.1";
my $new_sop = "$new_uid.2";
my $new_dose_file = "$new_dir/RTD_$new_sop.dcm";
my $r_fds = {
  out => $resamp_pipe->{to},
  status => $r_stat_pipe->{to},
};
my $d_fds = {
  in2 => $resamp_pipe->{from},
  in1 => $dose_pipe->{from},
  status => $d_stat_pipe->{to},
};
my $d_args =  {
  file => $new_dose_file,
  bytes => $resamp_rows * $resamp_cols * $new_num_slices * 2,
};
my $r_pid = PipeChildren::Spawn("DoseResampler", $r_fds, $resamp_args);
my $d_pid = PipeChildren::Spawn("BuildDose.pl",  $d_fds, $d_args);
my $new_dicom = {
    "(0008,0008)" => "DERIVED\\SECONDARY\\DOSE",
    "(0008,0060)" => "RTDOSE",
    "(0008,0070)" => "Itc/Wustl",
    "(0008,1090)" => "NewItcTools/BoundDoseToRoi.pl",
    "(0018,1020)" => '$Revision: 1.1 $', #No interpolation in this string
                                         #RCS does version substitution
    "(0008,0018)" => $new_sop,
    "(0020,000e)" => $new_series,
    "(0008,103e)" => "Dose Bounded by $roi_name contours",
    "(0008,0016)" => "1.2.840.10008.5.1.4.1.1.481.2",
    "(0020,1040)" => undef,
    "(0028,0004)" => "MONOCHROME2",
    "(0028,0009)" => 0x0000c3004,
    "(0028,0100)" => 16,
    "(0028,0101)" => 16,
    "(0028,0102)" => 15,
    "(0028,0103)" => 0,
    "(3004,0002)" => "GY",
    "(3004,000e)" => "0.1",
};
my @to_copy = (
    "(0008,0020)",
    "(0008,0030)",
    "(0008,0050)",
    "(0008,0090)",
    "(0008,1030)",
    "(0010,0010)",
    "(0010,0020)",
    "(0010,0030)",
    "(0010,0040)",
    "(0020,0010)",
    "(0012,0010)",
    "(0012,0020)",
    "(0012,0021)",
    "(0012,0030)",
    "(0012,0031)",
    "(0012,0040)",
    "(0012,0050)",
    "(0012,0060)",
    "(0020,000d)",
    "(0020,0052)", 
    "(3004,000a)"
 );
my $rows = $resamp_rows;
my $cols = $resamp_cols;
my $frames = $new_num_slices;
my $new_ipp = Posda::Transforms::ApplyTransform(
  $unnorm_xform, $roi_bb->[0]);
my $ipp_txt = join("\\", @$new_ipp);
my $iop = $dose_info->{"(0020,0037)"};
my $pix_sp = "$row_spc\\$col_spc";
my $new_gfov = 0;
my $new_offset = 0;
for my $i (1 .. $frames - 1){
  $new_offset += $slice_spc;
  $new_gfov .= "\\$new_offset";
}
my $to_dicom_builder = $dose_pipe->{to};
for my $i (@to_copy){
  print $to_dicom_builder "$i:$dose_info->{$i}\n";
  print "To_dicom_builder: $i:$dose_info->{$i}\n";
}
for my $i (keys %$new_dicom){
  my $value = $new_dicom->{$i};
  unless(defined $value){ $value = "<undef>" }
  print $to_dicom_builder "$i:$value\n";
  print "To_dicom_builder: $i:$value\n";
}
print $to_dicom_builder "(0028,0010):$rows\n";
print "To_dicom_builder: (0028,0010):$rows\n";
print $to_dicom_builder "(0028,0011):$cols\n";
print "to_dicom_builder: (0028,0011):$cols\n";
print $to_dicom_builder "(0028,0030):$pix_sp\n";
print "to_dicom_builder: (0028,0030):$pix_sp\n";
print $to_dicom_builder "(0028,0008):$frames\n";
print "to_dicom_builder: (0028,0008):$frames\n";
print $to_dicom_builder "(0020,0032):$ipp_txt\n";
print "to_dicom_builder: (0020,0032):$ipp_txt\n";
print $to_dicom_builder "(0020,0037):$iop\n";
print "to_dicom_builder: (0020,0037):$iop\n";
print $to_dicom_builder "(3004,000c):$new_gfov\n";
print "to_dicom_builder: (3004,000c):new_gfov\n";
close $to_dicom_builder;
my $dose_stat = $d_stat_pipe->{from};
my $resamp_stat = $r_stat_pipe->{from};
while(my $line = <$resamp_stat>){
  print "resamp: $line";
}
while(my $line = <$dose_stat>){
  print "dose: $line";
}

sub GetFileInfo{
  my($file) = @_;
  open my $foo, "DicomAnalyzer.pl \"$file\" \"$contour_dir\" \"$dvh_dir\"|";
  my $ret = fd_retrieve($foo);
}
sub CreateCacheSubDirs{
  my($dir) = @_;
  my @dirs_needed = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                     'a', 'b', 'c', 'd', 'e', 'f');
  foreach my $lev1 (@dirs_needed) {
    unless(-d "$dir/$lev1"){
      mkdir("$dir/$lev1",0775) || die "Error $! on mkdir $dir/$lev1";
    }
    unless(-d "$dir/$lev1")
      { die "bad contour dir, error making dir: $dir/$lev1" }
    foreach my $lev2 (@dirs_needed) {
      unless(-d "$dir/$lev1/$lev2"){
        mkdir("$dir/$lev1/$lev2",0775) ||
          die "Error $! on mkdir $dir/$lev1/$lev2";
      }
      unless(-d "$dir/$lev1/$lev2")
        { die "bad contour dir, error making dir: $dir/$lev1/$lev2" }
    }
  }
}

