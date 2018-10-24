#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::Try;
my @Elements = (
"(0018,1060)", # pti_trigger_time
"(0018,1063)", # pti_frame_time
"(0018,1083)", # pti_intervals_acquired
"(0018,1084)", # pti_intervals_rejected
"(0018,1100)", # pti_reconstruction_diameter
"(0018,1120)", # pti_gantry_detector_tilt
"(0018,1130)", # pti_table_height
"(0018,1147)", # pti_fov_shape
"(0018,1149)", # pti_fov_dimensions
"(0018,1181)", # pti_collimator_type
"(0018,1210)", # pti_convoution_kernal
"(0018,1242)", # pti_actual_frame_duration
"(0054,0013)[0](0054,0014)", # pti_energy_range_lower_limit
"(0054,0013)[0](0054,0015)", # pti_energy_range_upper_limit
"(0054,0016)[0](0018,0031)", # pti_radiopharmaceutical
"(0054,0016)[0](0018,1071)", # pti_radiopharmaceutical_volume
"(0054,0016)[0](0018,1072)", # pti_radiopharmaceutical_start_time
"(0054,0016)[0](0018,1073)", # pti_radiopharmaceutical_stop_time
"(0054,0016)[0](0018,1074)", # pti_radionuclide_total_dose
"(0054,0016)[0](0018,1075)", # pti_radionuclide_half_life
"(0054,0016)[0](0018,1076)", # pti_radionuclide_positron_fraction
"(0054,0081)", # pti_number_of_slices
"(0054,0101)", # pti_number_of_time_slices
"(0054,0202)", # pti_type_of_detector_motion
"(0054,0400)", # pti_image_id
"(0054,1000)", # pti_series_type
"(0054,1001)", # pti_units
"(0054,1002)", # pti_counts_source
"(0054,1004)", # pti_reprojection_method
"(0054,1100)", # pti_randoms_correction_method
"(0054,1101)", # pti_attenuation_correction_method
"(0054,1102)", # pti_decay_correction
"(0054,1103)", # pti_reconstruction_method
"(0054,1104)", # pti_detector_lines_of_response_used
"(0054,1105)", # pti_scatter_correction_method
"(0054,1201)", # pti_axial_mash
"(0054,1202)", # pti_transverse_mash
"(0054,1210)", # pti_coincidence_window_width
"(0054,1220)", # pti_secondary_counts_type
"(0054,1300)", # pti_frame_reference_time
"(0054,1310)", # pti_primary_counts_accumulated
"(0054,1311)", # pti_secondary_counts_accumulated
"(0054,1320)", # pti_slice_sensitivity_factor
"(0054,1321)", # pti_decay_factor
"(0054,1322)", # pti_dose_calibration_factor
"(0054,1323)", # pti_scatter_fraction_factor
"(0054,1324)", # pti_dead_time_factor
"(0054,1330)", # pti_image_index
);

my $get_pets = PosdaDB::Queries->GetQueryInstance(
  "FindUnpopulatedPetsWithCount");
my $insert_pet = PosdaDB::Queries->GetQueryInstance("PopulateFilePtImageRow");
my $count = 1;
while ($count > 0){
  my @files;
  $get_pets->RunQuery(sub {
    my($row) = @_;
    push @files, [$row->[0], $row->[1]];
  }, sub {}, $ARGV[0]
  );
  $count = @files;
  my $start_time = time;
  file:
  for my $i (@files){
    my $file_id = $i->[0];
    my $file = $i->[1];
    my $try = Posda::Try->new($file);
    unless(exists $try->{dataset}) {
      print STDERR "$file is not a DICOM dataset\n";
      next file;
    }
    my @params;
    push(@params, $file_id);
    for my $ele (@Elements){
      my $v = $try->{dataset}->Get($ele);
      push(@params, $v);
    }
    for my $i (0 .. $#params) {
      if(ref($params[$i]) eq "ARRAY"){
        my @fields = @{$params[$i]};
        my $text = "";
        for my $j (0 .. $#fields){
          $text .= $fields[$j];
          unless($j == $#fields){
            $text .= "\\";
          }
        }
        $params[$i] = $text;
      }
    }
    $insert_pet->RunQuery(sub{}, sub{}, @params);
  }
  my $end_time = time;
  my $elapsed = $end_time - $start_time;
  print "Imported $count files in $elapsed seconds\n";
  unless($ARGV[1] eq "continue") { exit }
}
