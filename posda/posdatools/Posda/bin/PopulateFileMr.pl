#!/usr/bin/perl -w
use strict;
use Posda::Try;
use Posda::DB "Query";

my $TagList = [
["(0018,0020)", "Scanning Sequence", "mr_scanning_seq"],
["(0018,0021)", "Sequence Variant", "mr_scanning_var"],
["(0018,0022)", "Scan Options", "mr_scan_options"],
["(0018,0023)", "MR Acquisition Type", "mr_acq_type"],
["(0018,0050)", "Slice Thickness", "mr_slice_thickness"],
["(0018,0080)", "Repetition Time", "mr_repetition_time"],
["(0018,0081)", "Echo Time", "mr_echo_time"],
["(0018,0087)", "Magnetic Field Strength", "mr_magnetic_field_strength"],
["(0018,0088)", "Spacing Between Slices", "mr_spacing_between_slices"],
["(0018,0091)", "Echo Train Length", "mr_echo_train_length"],
["(0018,1020)", "Software Version(s)", "mr_software_version"],
["(0018,1314)", "Flip Angle", "mr_flip_angle"],
["(0018,2010)", "Nominal Scanned Pixel Spacing", "mr_nominal_pixel_spacing"],
["(0018,5100)", "Patient Position", "mr_patient_position"],
["(0020,0012)", "Acquisition Number", "mr_acquisition_number"],
["(0020,0013)", "Instance Number", "mr_instance_number"],
["(0028,0106)", "Smallest Image Pixel Value", "mr_smallest_pixel"],
["(0028,0107)", "Largest Image Pixel Value", "mr_largest_value"],
["(0028,1050)", "Window Center", "mr_window_center"],
["(0028,1051)", "Window Width", "mr_window_width"],
["(0028,1052)", "Rescale Intercept", "mr_rescale_intercept"],
["(0028,1053)", "Rescale Slope", "mr_rescale_slope"],
["(0028,1054)", "Rescale Type", "mr_rescale_type"],
];
my %file_ids;
Query("GetUnpopulatedMrFilesInActivity")->RunQuery(sub {
  my($row) = @_;
  my($id, $path) = @$row;
  $file_ids{$id} = $path;
},sub {}, $ARGV[0]);
my $num_files = keys %file_ids;
print "$num_files found to update\n";
my $q = Query("InsertRowFileMr");
for my $file_id (keys %file_ids){
  my $path = $file_ids{$file_id};
  my $try = Posda::Try->new($path);
  print "parsing path: $path\n";
  unless(exists $try->{dataset}){ next }
  my $ds = $try->{dataset};
  my @values;
  for my $i (0 .. $#{$TagList}){
    my $tag = $TagList->[$i]->[0];  
    my $col = $TagList->[$i]->[2];  
    my $val = $ds->Get($tag);
    if(ref($val) eq "ARRAY"){ $val = join("\\", @$val) }
    $values[$i] = $val;
    $ds->Insert($tag, $val);
  }
  $values[$#{$TagList} + 1] = $file_id;
  print "doing insert for file_id: $file_id\n";
  $q->RunQuery(sub{}, sub{}, @values);
}
