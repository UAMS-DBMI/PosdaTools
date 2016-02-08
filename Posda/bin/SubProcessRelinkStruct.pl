#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Posda::FlipRotate;
use Debug;
my $dbg = sub { print STDERR @_ };
use Storable qw( store_fd fd_retrieve );
my $help = <<EOF;
 Structure Set relinker meant to run as a sub-process
 Receives parameters via fd_retrive from STDIN.
 Writes results to STDOUT via store_fd
 incoming data structure:
 \$in = {
   from_file => <path to from file>,
   to_file => <path to to file>,
   linked_files => {
     study_uid => <study_uid>,
     series_uid => <series_uid>,
     sop_class_uid => <sop_class_uid>,
     for_uid => <for_class_uid>,
     instances => {
       <file_name> => {
         sop_inst_uid => <sop_inst_uid>,
         ipp => [ <x>, <y>, <z> ],
         rows => <rows>,
         cols => <cols>,
         pix_sp => [ <row_w>, <col_w> ],
         iop => [ <dxdc>, <dydc>, <dzdc>, <dxdr>, <dydc>, <dzdc> ],
       },
       ...
     },
     min_dist => <min_dist>,
   },
 };

EOF
if($#ARGV >= 0){
  if($ARGV[0] eq "-h"){
    print STDERR $help;
    exit;
  }
  print STDERR $help;
  Error("Should not have a parameter (params received from STDIN)", $help);
}
my $results = {};
sub Error{
  my($message, $addl) = @_;
  $results->{Status} = "Error";
  $results->{message} = $message;
  if($addl){ $results->{additional_info} = $addl }
  store_fd($results, \*STDOUT);
  exit;
}
my $params;
eval { $params = fd_retrieve(\*STDIN) };
if($@){
  print STDERR
    "SubProcessRelinkStruct.pl: unable to fd_retrieve from STDIN ($@)\n";
  Error("unable to retrieve from STDIN", $@);
}
unless(exists $params->{from_file}){ Error("No from_file in params") }
unless(-f $params->{from_file}){ Error("file not found: $params->{from_file}") }
$results->{from_file} = $params->{from_file};
my $try = Posda::Try->new($params->{from_file});
unless(exists $try->{dataset}) { 
  Error("file $params->{from_file} didn't parse", $try);
}
my $ds = $try->{dataset};
####### Do relinking here
# Delete the Ref Frame of Ref Seq
$ds->Delete("(3006,0010)");
# Recreate the Ref Frame of Ref Seq
$ds->Insert("(3006,0010)[0](0020,0052)", $params->{linked_files}->{for_uid});
$ds->Insert("(3006,0010)[0](3006,0012)[0](0008,1150)", 
   "1.2.528.1.1007.189.1.32899.409826686.1");
$ds->Insert("(3006,0010)[0](3006,0012)[0](0008,1155)", 
   $params->{linked_files}->{study_uid});
$ds->Insert("(3006,0010)[0](3006,0012)[0](3006,0014)[0](0020,000e)", 
   $params->{linked_files}->{series_uid});
my $index = 0;
for my $file (keys %{$params->{linked_files}->{instances}}){
  $index += 1;
  $ds->Insert("(3006,0010)[0](3006,0012)[0](3006,0014)[0](3006,0016)" .
    "[$index](0008,1150)", 
    $params->{linked_files}->{sop_class_uid});
  $ds->Insert("(3006,0010)[0](3006,0012)[0](3006,0014)[0](3006,0016)" .
    "[$index](0008,1155)", 
    $params->{linked_files}->{instances}->{$file}->{sop_inst_uid});
}
# end Recreate the Ref Frame of Ref Seq
# Build the <z> to SOP_UID Table here (Assuming Axial Images)
my @z_slots;
my @unsorted;
for my $file (keys %{$params->{linked_files}->{instances}}){
  my $fd = $params->{linked_files}->{instances}->{$file};
  my($tlhc, $trhc, $blhc, $brhc) = Posda::FlipRotate::ToCorners(
   $fd->{rows}, $fd->{cols}, $fd->{iop}, $fd->{ipp}, $fd->{pix_sp});
  my($max_z, $min_z);
  for my $z ($tlhc->[2], $trhc->[2], $blhc->[2], $brhc->[2]){
    unless(defined $max_z) { $max_z = $z }
    unless(defined $min_z) { $min_z = $z }
    if($z < $min_z) { $min_z = $z }
    if($z > $max_z) { $max_z = $z }
  }
  my $avg = ($min_z + $max_z) / 2;
  $min_z = $avg - abs($params->{min_dist});
  $max_z = $avg + abs($params->{min_dist});
  push(@unsorted, [[$min_z, $max_z], $fd->{sop_inst_uid}]);
}
@z_slots = sort { $a->[0]->[0] <=> $b->[0]->[0] } @unsorted;
# end Build the <z> to SOP_UID Table here (Assuming Axial Images)
# Check the slice spacings for overlap
for my $i (0 .. $#z_slots - 2){
  unless($z_slots[$i]->[0]->[1] < $z_slots[$i+1]->[0]->[0]){
    Error("Overlap in image <z>:\n" .
      "\t$z_slots[$i]->[2]\n" .
      "\t$z_slots[$i+1]->[2]");
  }
}
# end Check the slice spacings
# Make a linkage to corresponding images for each Contour
my $matches = $ds->Search("(3006,0039)[<0>](3006,0040)[<0>](3006,0042)",
   "CLOSED_PLANAR");
unless(defined $matches && ref($matches) eq "ARRAY" && $#{$matches} >= 0){
  Error("no contours to relink");
}
for my $m (@$matches){
  my $i = $m->[0];
  my $j = $m->[1];
  my $contour_data_index = "(3006,0039)[$i](3006,0040)[$j](3006,0050)";
  my $contour_data = $ds->Get($contour_data_index);
  my $z = GetContourZ($contour_data, $contour_data_index);
  my $sop_inst = GetLinkedSop($z, \@z_slots, $contour_data_index);
  my $sop_class_index = "(3006,0039)[$i](3006,0040)[$j](3006,0016)" .
    "[0](0008,1150)";
  $ds->Insert($sop_class_index, $params->{linked_files}->{sop_class_uid});
  my $sop_inst_index = "(3006,0039)[$i](3006,0040)[$j](3006,0016)" .
    "[0](0008,1155)";
  $ds->Insert($sop_inst_index, $sop_inst);
  my $ref_roi = $ds->Get("(3006,0039)[$i](3006,0084)");
  my $roi_ref_list = $ds->Search("(3006,0020)[<0>](3006,0022)", $ref_roi);
  unless(
    defined $roi_ref_list && 
    ref($roi_ref_list) eq "ARRAY" &&
    $#{$roi_ref_list} == 0
  ){
    Error("no referenced ROI in (3006,0039)[$i](3006,0040)[$j](3006,0048)\n" .
      " value $ref_roi");
  }
  my $for_index = "(3006,0020)[$roi_ref_list->[0]->[0]](3006,0024)";
  $ds->Insert($for_index, $params->{linked_files}->{for_uid});
}
# end Make a linkage to corresponding images for each Contour
#print STDERR "Parameters to Relinker: ";
#Debug::GenPrint($dbg, $params, 1);
#print STDERR "\n";
#Error("Relinking not implemented yet");
#######
eval {
  $ds->WritePart10($params->{to_file}, $try->{xfr_stx}, "POSDA", undef, undef);
};
if($@){
  print STDERR "Can't write $params->{to_file} ($@)\n";
  Error("Can't write $params->{to_file}", $@);
}
$results->{to_file} = $params->{to_file};
$results->{Status} = "OK";
store_fd($results, \*STDOUT);
sub GetContourZ{
  my($contour_data, $index) = @_;
  unless(defined $contour_data && ref($contour_data) eq "ARRAY"){
    Error("Bad contour data in $index");
  }
  my $num_count = scalar @{$contour_data};
  unless($num_count % 3 == 0 && $num_count > 2){
    Error("$index does not contain at least 3 3d points");
  }
  my $num_points = (scalar @{$contour_data}) / 3;
  my $tot_z = 0;
  for my $i (0 .. $num_points - 1){
    my $index = ($i * 3) + 2;
    $tot_z += $contour_data->[$index];
  }
  return($tot_z/$num_points);
}
sub GetLinkedSop{
  my($z, $z_slots, $index) = @_;
  for my $i (0 .. $#{$z_slots}){
    if(
      $z > $z_slots->[$i]->[0]->[0] &&
      $z < $z_slots->[$i]->[0]->[1]
    ){
      return $z_slots->[$i]->[1];
    }
#    if(
#      $z > $z_slots->[$i]->[0]->[0] &&
#      $z < $z_slots->[$i]->[0]->[1]
#    ){
#      Error("Missed Slot for z = $z at $i ($z_slots->[$i]->[0]->[0]:" .
#        "$z_slots->[$i]->[0]->[1])");
#    }
  }
  my $message ="";
  for my $i (0 .. $#{$z_slots}){
    $message .= "\t$i - ($z_slots->[$i]->[0]->[0]:$z_slots->[$i]->[0]->[1])\n";
  }
  Error("Linked slot for z = $z ($index) not found:\n$message");
}
