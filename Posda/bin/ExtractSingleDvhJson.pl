#!/usr/bin/perl -w
#
use strict;
use Fcntl qw(:seek);
use JSON;
use Storable qw( store_fd fd_retrieve );
#
# Data structure sent in on STDIN
#
# $ds = {
#   file => <file_name>,
#   dose_file_digest => <digest>,
#   dvh_index => <dvh_index>,
#   dose_file_min_dose => <min_dose in file>,
#   dose_file_max_dose => <max_dose in file>,
#   dose_type => "PHYSICAL",
#   normalization => null,
#   type => "DIFFERENTIAL" | "CUMMULATIVE",
#   dose_units => "GY", #others unsupported
#   dose_scaling => <dose_scaling_factor>,
#   vol_units => "PERCENT" | "CM3",
#   file_pos => <position in file of dvh data>,
#   file_len => <length of dvh data>,
# };
#
# During processing, the following items will be added to this
# hash:
# $ds = {
#   Status => "OK",
#   num_bins => <number of bins>,
#   data => [
#     [<bin_width>, <vol>], ...
#   ],
# };
#
# DVH file created will be a JSON formated file.
#   dose values will be Cumulative.
#   with var bin size.
#
my $dvh = fd_retrieve(\*STDIN);
my $dose_file =  $dvh->{file};
my $result = {};
my $dvh_index = $dvh->{dvh_index};
## Make these be numbers
$dvh->{dose_file_min_dose} += 0;
$dvh->{dose_file_max_dose} += 0;
##
######
sub dvh_error{
  my ($msg) = @_;
  my $err = {
    dose_file_digest => $dvh->{digest},
    dvh_index => $dvh_index,
    Status => 'Error',
    Error => $msg,
  };
  print encode_json $err;
}
######
my $buff;
unless (open (FILE, "<", $dose_file)) {
  print STDERR 
    "ExtractSingleDvhJson: Could not open Dose file $dose_file, error $!\n";
  exit 1;
}
my $diff;
if ($dvh->{type} eq "DIFFERENTIAL") {
  $diff = 1;
} elsif  ($dvh->{type} eq "CUMULATIVE") {
  $diff = 0;
} else {
  print STDERR 
    "ExtractSingleDvhJson: Unsupported DVH type: $dvh->{type}, " .
    "file: $dose_file, DVH index: $dvh_index.\n";
  dvh_error("Unsupported DVH type: $dvh->{type}");
  exit 1;
}
if ($dvh->{dose_units} eq "GY") {
# } elsif  ($dvh->{dose_units} eq "RELATIVE") {
} else {
  print STDERR 
    "ExtractSingleDvhJson: Unsupported DVH dose units: $dvh->{dose_units}, " .
    "file: $dose_file, DVH index: $dvh_index.\n";
  dvh_error("Unsupported DVH dose units: $dvh->{dose_units}");
  exit 1;
}
# check DVH type: (3004,0001)
# check DVH Dose units: (3004,0002)
# Dose Type is ignored... (3004,0004)
# Setup DVH Dose Scaling (3004,0052)
my $scaling = 1;
if (exists $dvh->{dose_scaling}) { $scaling =  $dvh->{dose_scaling}; }
# check DVH Volume Units (3004,0054)
my $vol_scaling;
if ($dvh->{vol_units} eq "PERCENT") {
  $vol_scaling = 1;
} elsif  ($dvh->{vol_units} eq "CM3") {
  $vol_scaling = 0;
} else {
  print STDERR 
    "ExtractSingleDvhJson: Unsupported DVH Volume Units: $dvh->{vol_units}, " .
    "file: $dose_file, DVH index: $dvh_index.\n";
  dvh_error("Unsupported DVH Volume Units: $dvh->{vol_units}");
  next dvh;
}
if (seek (FILE, $dvh->{file_pos}, SEEK_SET) != 1) {
  print STDERR "ExtractSingleDvhJson.pl: Error on seek, DVH index: $dvh_index.\n";
  dvh_error("Error on seek");
  next dvh;
}
if (read (FILE, $buff, $dvh->{file_len}) != $dvh->{file_len}) {
  print STDERR "ExtractSingleDvhJson.pl: Error on read, DVH index: $dvh_index.\n";
  dvh_error("Error on read");
  next dvh;
}
$dvh->{data} = [ ];
my @data = split(/\\/, $buff);
my $num_values = scalar @data;
unless(($num_values & 1) == 0){ 
  print STDERR 
    "ExtractSingleDvhJson: Odd number of DVH entries, " .
    "Dose file $dose_file, index: $dvh_index\n";
  $num_values--;
}
### bin data
my $max_volume_units;
my $num_points = $num_values / 2;
$max_volume_units = $data[1];
my $cur_volume_units = $data[1];
my $i = 0;
my $bin_width = 0;
bin:
while($i < $num_points){
  if(
    $i < ($num_points - 1) &&
    $cur_volume_units == $data[(2 * ($i+1)) + 1]
  ){
    $i++;
    $bin_width += $data[2 * $i];
    next bin;
  }
  if($diff){
    $cur_volume_units += $data[(2 * $i) + 1];
  } else {
    $cur_volume_units = $data[(2 * $i) + 1];
  }
  push(@{$dvh->{data}}, [$bin_width, $cur_volume_units]);
  $bin_width = $data[2 * $i];
  $i++;
}
### data binned
if ($dvh->{vol_units} eq "CM3") {
  my $cumulative_dose = 0;
  $dvh->{max_volume} = 1.0 * $max_volume_units;
  for my $p (@{$dvh->{data}}) {
    $cumulative_dose += $p->[0];
    $p->[0] = $cumulative_dose;
    if ($max_volume_units > 0) {
      $p->[1] = (($p->[1] /  $max_volume_units) * 100.0);
    }
    else { $p->[1] = ($p->[1]  * 100.0); }
    if ($diff) {
      $p->[1] = 100.0 - $p->[1];
    }
  }
} else {
  $dvh->{max_volume} = 0;
}
for my $p (@{$dvh->{data}}) {
  $p->[1] = (0.0 + sprintf("%.2f",$p->[1]));
}
$dvh->{min_dose} = $dvh->{data}->[0]->[0];
$dvh->{max_dose} = $dvh->{data}->[$#{$dvh->{data}}]->[0];
$dvh->{Status} = "OK";
my $json = JSON->new();
print $json->encode($dvh);
