#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::DB::Modules;
use strict;
use Carp;
sub GetAttrs{
  my($ds, $parms, $mod, $errors) = @_;
  my %ret;
  for my $key (keys %$parms){
    my $value = $ds->ExtractElementBySig($parms->{$key});
    if(exists $mod->{$key}){
      my $dispatch = {
        Date => sub {
          my($text, $id) = @_;
          unless(defined $text) { return undef };
          if($text eq "<undef> ") { return undef };
          if(
            $text &&
            $text =~ /^(....)(..)(..)$/
          ){
            my $y = $1; my $m = $2; my $d = $3;
            if($y eq "    "){
              push(@$errors, "Bad date \"$text\" in $id");
              return undef;
            }
            if($y eq "????"){
              push(@$errors, "Bad date \"$text\" in $id");
              return undef;
            }
            if($m =~ /^ (\d)$/){
              $m = "0".$1;
            }
            if($d =~ /^ (\d)$/){
              $d = "0".$1;
            }
            unless($y >0 && $m > 0 && $m < 13 && $d > 0 && $d < 32 ){
              push(@$errors, "Bad date \"$text\" in $id");
              return undef;
            }
            $text = sprintf("%04d/%02d/%02d", $y, $m, $d);
            return $text;
          } else {
            push(@$errors, "Bad date \"$text\" in $id");
            return undef;
          }
        },
        Timetag => sub {
          my($time, $id) = @_;
          unless(defined $time) { return undef };
          if(
            $time &&
            $time =~ /^(\d\d)(\d\d)(\d\d)$/
          ){
            $time = "$1:$2:$3";
            return $time;
          } elsif (
            $time &&
            $time =~ /^(\d\d)(\d\d)(\d\d)\.(\d+)$/
          ){
            $time = "$1:$2:$3.$4";
            return $time;
          } else {
            push(@$errors, "Bad time \"$time\" in $id");
            return undef;
          }
        },
        MultiText => sub {
          my($text, $id) = @_;
          if(ref($text) eq "ARRAY"){
            $text = join("\\", @$text);
          }
          return $text;
        },
        UndefIfNotNumber => sub {
          my($text, $id) = @_;
          unless(defined $text){ return undef }
          unless($text =~ /^\s*[+-]?[0-9]+\s*$/){
            push(@$errors, "Bad number \"$text\" in $id");
            return undef;
          }
          return $text;
        },
        Integer => sub {
          my($text, $id) = @_;
          unless(defined $text) { return undef }
          my $int = int($text);
          unless($int == $text){
            push @$errors, "Error making $text an integer\n";
          }
          return $int;
        },
      };
      if(exists $dispatch->{$mod->{$key}}){
         $value = &{$dispatch->{$mod->{$key}}}($value, $key);
      }
    }
    $ret{$key} = $value;
  }
  return \%ret;
}
sub Patient{
  my($db, $ds, $id, $hist, $errors) = @_;
  my $patient_parms = {
   dob   => "(0010,0030)",
   tob   => "(0010,0032)",
   other_ids   => "(0008,1000)",
   other_names => "(0008,1001)",
   patient_name => "(0010,0010)",
   patient_id => "(0010,0020)",
   id_issuer => "(0010,0021)",
   ethnic_group => "(0010,2160)",
   comments => "(0010,4000)",
   sex => "(0010,0040)",
   patient_age => "(0010,1010)",
  };
  my $ModList = {
    dob => "Date",
    tob => "Timetag",
    other_ids => "MultiText",
    other_names => "MultiText",
  };
  my $parms = GetAttrs($ds, $patient_parms, $ModList, $errors);
  my $ins_file_pat = $db->prepare(
    "insert into file_patient\n" .
    "  (file_id, patient_name, patient_id,\n" .
    "   id_issuer, dob, sex,\n" .
    "   time_ob, other_ids, other_names,\n" .
    "   ethnic_group, comments, patient_age)" .
    "values\n" .
    "  (?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?)"
  );
  return $ins_file_pat->execute(
    $id,
    $parms->{patient_name},
    $parms->{patient_id},
    $parms->{id_issuer},
    $parms->{dob},
    $parms->{sex},
    $parms->{tob},
    $parms->{other_ids},
    $parms->{other_names},
    $parms->{ethnic_group},
    $parms->{comments},
    $parms->{patient_age},
  );
}
sub Study{
  my($db, $ds, $file_id, $hist, $errors) = @_;
  my $study_parms = {
    study_instance_uid => "(0020,000d)",
    study_date => "(0008,0020)",
    study_time => "(0008,0030)",
    referring_phy_name => "(0008,0090)",
    study_id => "(0020,0010)",
    accession_number => "(0008,0050)",
    study_description => "(0008,1030)",
    phys_of_record => "(0008,1048)",
    phys_reading => "(0008,1060)",
    admitting_diag => "(0008,1080)",
  };
  my $ModList = {
    study_date => "Date",
    study_time => "Timetag",
    phys_of_record => "MultiText",
    phys_reading => "MultiText",
    admitting_diag => "MultiText",
  };
  my $parms = GetAttrs($ds, $study_parms, $ModList, $errors);
  my $ins_study = $db->prepare(
    "insert into file_study\n" .
    "  (file_id, study_instance_uid, study_date,\n" .
    "   study_time, referring_phy_name, study_id,\n" .
    "   accession_number, study_description, phys_of_record,\n" .
    "   phys_reading, admitting_diag)\n" .
    "values\n" .
    "  (?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?)"
  );
  return $ins_study->execute(
    $file_id,
    $parms->{study_instance_uid},
    $parms->{study_date},
    $parms->{study_time},
    $parms->{referring_phy_name},
    $parms->{study_id},
    $parms->{accession_number},
    $parms->{study_description},
    $parms->{phys_of_record},
    $parms->{phys_reading},
    $parms->{admitting_diag},
  );
}
sub Series{
  my($db, $ds, $file_id, $hist, $errors) = @_;
  my $series_parms = {
    modality => "(0008,0060)",
    series_instance_uid => "(0020,000e)",
    series_number => "(0020,0011)",
    laterality => "(0020,0060)",
    series_date => "(0008,0021)",
    series_time => "(0008,0031)",
    performing_phys => "(0008,1050)",
    protocol_name => "(0018,1030)",
    series_description => "(0008,103e)",
    operators_name => "(0008,1070)",
    body_part_examined => "(0018,0015)",
    patient_position => "(0018,5100)",
    smallest_pixel_value => "(0028,0108)",
    largest_pixel_value => "(0028,0109)",
    performed_procedure_step_id => "(0040,0253)",
    performed_procedure_start_date => "(0040,0244)",
    performed_procedure_start_time => "(0040,0245)",
    performed_procedure_desc => "(0040,0254)",
    performed_procedure_comments => "(0040,0280)",
  };
  my $ModList = {
    series_number => "UndefIfNotNumber",
    series_date => "Date",
    series_time => "Timetag",
    performing_phys => "MultiText",
    operators_name => "MultiText",
    smallest_pixel_value => "UndefIfNotNumber",
    largest_pixel_value => "UndefIfNotNumber",
    performed_procedure_start_date => "Date",
    performed_procedure_start_time => "Timetag",
  };
  my $parms = GetAttrs($ds, $series_parms, $ModList, $errors);
  my $ins_series = $db->prepare(
    "insert into file_series\n" .
    "  (file_id, modality, series_instance_uid,\n" .
    "   series_number, laterality, series_date,\n" .
    "   series_time, performing_phys, protocol_name,\n" .
    "   series_description, operators_name, body_part_examined,\n" .
    "   patient_position, smallest_pixel_value, largest_pixel_value,\n" .
    "   performed_procedure_step_id, performed_procedure_step_start_date, \n" .
    "       performed_procedure_step_start_time,\n" .
    "   performed_procedure_step_desc, performed_procedure_step_comments)\n" .
    "values\n" .
    "  (?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?)"
  );
  unless(defined($parms->{series_instance_uid})){
    push(@$errors, "Series instance UID undefined");
    return;
  }
  return $ins_series->execute(
    $file_id,
    $parms->{modality},
    $parms->{series_instance_uid},
    $parms->{series_number},
    $parms->{laterality},
    $parms->{series_date},
    $parms->{series_time},
    $parms->{performing_phys},
    $parms->{protocol_name},
    $parms->{series_description},
    $parms->{operators_name},
    $parms->{body_part_examined},
    $parms->{patient_position},
    $parms->{smallest_pixel_value},
    $parms->{largest_pixel_value},
    $parms->{performed_procedure_step_id},
    $parms->{performed_procedure_start_date},
    $parms->{performed_procedure_start_time},
    $parms->{performed_procedure_desc},
    $parms->{performed_procedure_comments},
  );
}
sub Equipment{
  my($db, $ds, $file_id, $hist, $errors) = @_;
  my $equip_parms = {
    manufacturer => "(0008,0070)",
    institution_name => "(0008,0080)",
    institution_addr => "(0008,0081)",
    station_name => "(0008,1010)",
    inst_dept_name => "(0008,1040)",
    manuf_model_name => "(0008,1090)",
    dev_serial_num => "(0018,1000)",
    software_versions => "(0018,1020)",
    spatial_resolution => "(0018,1050)",
    last_calib_date => "(0018,1200)",
    last_calib_time => "(0018,1201)",
    pixel_pad => "(0028,0120)",
  };
  my $ModList = {
    software_versions => "MultiText",
    last_calib_date => "MultiText",
    last_calib_time => "MultiText",
  };
  my $parms = GetAttrs($ds, $equip_parms, $ModList, $errors);
  my $ins_equip = $db->prepare(
    "insert into file_equipment\n" .
    "  (file_id, manufacturer, institution_name,\n" .
    "   institution_addr, station_name, inst_dept_name,\n" .
    "   manuf_model_name, dev_serial_num, software_versions,\n" .
    "   spatial_resolution, last_calib_date, last_calib_time,\n" .
    "   pixel_pad)\n" .
    "values\n" .
    "  (?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?)"
  );
  return $ins_equip->execute(
    $file_id,
    $parms->{manufacturer},
    $parms->{institution_name},
    $parms->{institution_addr},
    $parms->{station_name},
    $parms->{inst_dept_name},
    $parms->{manuf_model_name},
    $parms->{dev_serial_num},
    $parms->{software_versions},
    $parms->{spatial_resolution},
    $parms->{last_calib_date},
    $parms->{last_calib_time},
    $parms->{pixel_pad},
  );
}

#ImagePixel
#
#Table to populate:
#CREATE TABLE image (
#    image_id serial NOT NULL,
#    image_type text,
#    samples_per_pixel integer,
#    photometric_interpretation text,
#    pixel_rows integer,
#    pixel_columns integer,
#    bits_allocated integer,
#    bits_stored integer,
#    high_bit integer,
#    pixel_representation integer,
#    planar_configuration integer,
#    number_of_frames integer,
#    unique_pixel_data_id integer
#);
#CREATE TABLE unique_pixel_data (
#    unique_pixel_data_id serial NOT NULL,
#    digest text NOT NULL,
#    size integer
#);
#CREATE TABLE pixel_location (
#    unique_pixel_data_id integer NOT NULL,
#    file_id integer NOT NULL,
#    file_offset integer NOT NULL
#);
#

sub ImagePixel{
  my($db, $ds, $file_id, $hist, $errors) = @_;
  unless(exists $ds->{0x7fe0}->{0x10}){
    push(@$errors, "No pixel data in ImagePixel");
    return 0;
  }
  my $check_pix = $db->prepare(
    "select * from unique_pixel_data where digest = ? and size = ?"
  );
  my $create_pix = $db->prepare(
    "insert into unique_pixel_data (digest, size) values (?, ?)"
  );
  my $get_pixel_id = $db->prepare(
    "select currval('unique_pixel_data_unique_pixel_data_id_seq') as\n" .
    "  unique_pixel_data_id"
  );
  my $check_image = $db->prepare(
    "select * from image where unique_pixel_data_id = ?"
  );
  my $insert_pix_loc = $db->prepare(
    "insert into pixel_location(unique_pixel_data_id, file_id, file_offset)\n" .
    "values (?, ?, ?)"
  );
  my $ins_image = $db->prepare(
    "insert into image\n" .
    "  (image_type, samples_per_pixel, photometric_interpretation,\n" .
    "   pixel_rows, pixel_columns, bits_allocated,\n" .
    "   bits_stored, high_bit, pixel_representation,\n" .
    "   planar_configuration, number_of_frames, unique_pixel_data_id,\n" .
    "   pixel_spacing\n" .
    "   )\n" .
    "values\n" .
    "  (?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?\n" .
    "   )\n"
  );
  my $get_image_id = $db->prepare(
    "select currval('image_image_id_seq') as image_id"
  );
  my $ins_file_image = $db->prepare(
    "insert into\n" .
    "   file_image (file_id, image_id, content_date, content_time)\n" .
    "values (?, ?, ?, ?)\n"
  );
  my $pix_root = $ds->{0x7fe0}->{0x10};
  my $unique_pixel_data_id;
  my $pixel_data;
  my $pixel_size;
  my $pix_offset;
  my $pixel_digest;
  if(
    exists($pix_root->{value}) &&
    $pix_root->{type} eq "raw" &&
    ref($pix_root->{value}) ne "ARRAY"
  ){
    $pixel_data = $pix_root->{value};
    $pixel_size = length($pixel_data);
    $pix_offset = $pix_root->{file_pos};
    my $ctx = Digest::MD5->new();
    $ctx->add($pixel_data);
    $pixel_digest = $ctx->hexdigest()
  }
  if(defined $pixel_data){
    $check_pix->execute($pixel_digest, $pixel_size);
    my $h = $check_pix->fetchrow_hashref();
    $check_pix->finish();
    if($h && ref($h) eq "HASH"){
      $unique_pixel_data_id = $h->{unique_pixel_data_id};
      $hist->{already_existing_pixel_data} = 1;
    }
    unless(defined $unique_pixel_data_id){
      $create_pix->execute($pixel_digest, $pixel_size);
      $get_pixel_id->execute();
      my $h = $get_pixel_id->fetchrow_hashref();
      $get_pixel_id->finish();
      if($h && ref($h) eq "HASH"){
        $unique_pixel_data_id = $h->{unique_pixel_data_id};
      }
    }
    if(defined $unique_pixel_data_id){
      $insert_pix_loc->execute($unique_pixel_data_id, $file_id, $pix_offset);
    }
  }
  $hist->{unique_pixel_data_id} = $unique_pixel_data_id;
  # Now we have a unique_pixel_data_id

  my $image_parms = {
    image_type => "(0008,0008)",
    samples_per_pixel => "(0028,0002)",
    pixel_spacing => "(0028,0030)",
    photometric_interpretation => "(0028,0004)",
    pixel_rows => "(0028,0010)",
    pixel_columns => "(0028,0011)",
    bits_allocated => "(0028,0100)",
    bits_stored => "(0028,0101)",
    high_bit => "(0028,0102)",
    pixel_representation => "(0028,0103)",
    planar_configuration => "(0028,0006)",
    number_of_frames => "(0028,0008)",
    content_date => "(0008,0023)",
    content_time => "(0008,0033)",
  };
  my $ModList = {
    image_type => "MultiText",
    pixel_spacing => "MultiText",
    content_date => "Date",
    content_time => "Timetag",
  };
  my $parms = GetAttrs($ds, $image_parms, $ModList, $errors);
  $check_image->execute($unique_pixel_data_id);
  my $image_id;
  image_row:
  while(my $h = $check_image->fetchrow_hashref()){
    my $same = 1;
    for my $i (keys %{$parms}){
      if($i eq "content_date" || $i eq "content_time") {next}
      if(
        (defined($parms->{$i}) && !defined($h->{$i})) ||
        (!defined($parms->{$i}) && defined($h->{$i})) ||
        (
          (defined($parms->{$i}) && defined($h->{$i})) &&
          $parms->{$i} ne $h->{$i}
        )
      ){
        my $old = $h->{$i};
        my $new = $parms->{$i};
        unless(defined($old)) { $old = "<undef>" }
        unless(defined($new)) { $new = "<undef>" }
        push(@$errors,  "Same pixel data with different $i: " .
          "\"$old\" vs \"$new\"\n" .
          "old_image_id: $h->{image_id}\n" .
          "file_id: $file_id");
        $same = 0;
      }
    }
    if($same) {
      $image_id = $h->{image_id};
      $hist->{already_existing_image} = 1;
      last image_row ;
    }
  }
  unless(defined $image_id){
    $ins_image->execute(
      $parms->{image_type},
      $parms->{samples_per_pixel},
      $parms->{photometric_interpretation},
      $parms->{pixel_rows},
      $parms->{pixel_columns},
      $parms->{bits_allocated},
      $parms->{bits_stored},
      $parms->{high_bit},
      $parms->{pixel_representation},
      $parms->{planar_configuration},
      $parms->{number_of_frames},
      $unique_pixel_data_id,
      $parms->{pixel_spacing},
    );
    $get_image_id->execute();
    my $h = $get_image_id->fetchrow_hashref();
    $get_image_id->finish();
    if($h && ref($h) eq "HASH"){
      $image_id = $h->{image_id};
    }
  }

  $ins_file_image->execute($file_id, $image_id,
    $parms->{content_date}, $parms->{content_time}
  );
  $hist->{image_id} = $image_id;
}
sub ImagePlane{
  my($db, $ds, $id, $hist, $errors) = @_;
  unless(defined $hist->{image_id}){
    push(@$errors, "no image_id in ImagePlane");
    return;
  }
  my $IP_parms = {
     iop => "(0020,0037)",
     ipp => "(0020,0032)",
     for_uid => "(0020,0052)",
  };
  my $ModList = {
    iop => "MultiText",
    ipp => "MultiText",
  };
  my $parms = GetAttrs($ds, $IP_parms, $ModList, $errors);
  my $get_image_geometry = $db->prepare(
    "select * from image_geometry where image_id = ? and " .
    "ipp = ? and iop = ? and for_uid = ?"
  );
  $get_image_geometry->execute($hist->{image_id},
    $parms->{ipp}, $parms->{iop}, $parms->{for_uid}
  );
  my $h = $get_image_geometry->fetchrow_hashref();
  $get_image_geometry->finish();
  my $image_geometry_id;
  if(
    $h && defined($h->{image_geometry_id})
  ){
    $image_geometry_id = $h->{image_geometry_id};
    $h->{already_existing_geometry} = 1;
  } else {
    my $ins_image_geometry = $db->prepare(
      "insert into image_geometry(image_id, iop, ipp, for_uid)" .
      " values(?, ?, ?, ?)"
    );
    $ins_image_geometry->execute(
      $hist->{image_id},
      $parms->{iop},
      $parms->{ipp},
      $parms->{for_uid}
    );
    my $get_image_geometry_id = $db->prepare(
      "select currval('image_geometry_image_geometry_id_seq') as" .
      "  image_geometry_id"
    );
    $get_image_geometry_id->execute();
    my $h = $get_image_geometry_id->fetchrow_hashref();
    $get_image_geometry_id->finish();
    if($h){
      $image_geometry_id = $h->{image_geometry_id};
    }
  }
  unless(defined $image_geometry_id){
    die "couldn't define an image geometry";
  }
  my $ins_file_image_geometry = $db->prepare(
    "insert into file_image_geometry(file_id, image_geometry_id)" .
    " values(?, ?)"
  );
  $ins_file_image_geometry->execute($id, $image_geometry_id);
  $h->{image_geometry_id} = $image_geometry_id;
}
sub FrameOfReference{
  my($db, $ds, $id, $hist, $errors) = @_;
  my $for_parms = {
    for_uid => "(0020,0052)",
    position_ref_indicator => "(0020,1040)",
  };
  my $ModList = { };
  my $parms = GetAttrs($ds, $for_parms, $ModList, $errors);
  my $ins_for = $db->prepare(
    "insert into file_for(file_id, for_uid, position_ref_indicator)" .
    "  values (?, ?, ?)"
  );
  $ins_for->execute($id, $parms->{for_uid}, $parms->{position_ref_indicator});
  $hist->{frame_of_reference} = $parms->{for_uid};
}
sub Synchronization{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "Synchronization Module not yet implemented\n";
}
sub SlopeIntercept{
  my($db, $ds, $id, $hist, $errors) = @_;
  unless(defined $hist->{image_id}){
    push(@$errors, "No image_id in SlopeIntercept");
    return;
  }
  my $g_si_w_units = $db->prepare(
    "select * from slope_intercept\n" .
    "where slope = ? and intercept = ? and si_units = ?"
  );
  my $g_si_wo_units = $db->prepare(
    "select * from slope_intercept\n" .
    "where slope = ? and intercept = ? and si_units is null"
  );
  my $slope = $ds->ExtractElementBySig("(0028,1053)");
  my $intercept = $ds->ExtractElementBySig("(0028,1052)");
  my $units = $ds->ExtractElementBySig("(0054,1001)");
  unless(defined($slope) && defined($intercept)){
    print STDERR "no slope intercept for file $id\n";
    push (@$errors, "no slope intercept for file $id");
    return;
  }
  my $h;
  if(defined($units)){
    $g_si_w_units->execute($slope, $intercept, $units);
    $h = $g_si_w_units->fetchrow_hashref();
    $g_si_w_units->finish();
  } else {
    $g_si_wo_units->execute($slope, $intercept);
    $h = $g_si_wo_units->fetchrow_hashref();
    $g_si_wo_units->finish();
  }
  my $si_id;
  if(defined($h) && ref($h) eq "HASH"){
    $si_id = $h->{slope_intercept_id};
  } else {
    my $in_sl = $db->prepare(
      "insert into slope_intercept(slope, intercept, si_units)\n" .
      "values(?, ?, ?)"
    );
    $in_sl->execute($slope, $intercept, $units);
    my $get_sl_id = $db->prepare(
      "select currval('slope_intercept_slope_intercept_id_seq') as\n" .
      "  slope_intercept_id"
    );
    $get_sl_id->execute();
    my $h = $get_sl_id->fetchrow_hashref();
    $get_sl_id->finish();
    $si_id = $h->{slope_intercept_id};
  }
  my $g_i_sl = $db->prepare(
    "select * from image_slope_intercept\n" .
    "where image_id = ? and slope_intercept_id = ?"
  );
  $g_i_sl->execute($hist->{image_id}, $si_id);
  $h = $g_i_sl->fetchrow_hashref();
  $g_i_sl->finish();
  unless(
    $h && ref($h) eq "HASH"
  ){
    my $ins_i_sl = $db->prepare(
      "insert into image_slope_intercept(slope_intercept_id, image_id)\n" .
      "values (?, ?)"
    );
    $ins_i_sl->execute($si_id, $hist->{image_id});
  }
  my $ins_f_sl = $db->prepare(
      "insert into file_slope_intercept(slope_intercept_id, file_id)\n" .
      "values (?, ?)"
  );
  $ins_f_sl->execute($si_id, $id);
}
sub WindowLevel{
  my($db, $ds, $id, $hist, $errors) = @_;
  unless(defined $hist->{image_id}){
    push(@$errors, "No image_id in WindowLevel");
    return;
  }
  my $window_cntr = $ds->ExtractElementBySig("(0028,1050)");
  my $window_wdth = $ds->ExtractElementBySig("(0028,1051)");
  my $window_exp = $ds->ExtractElementBySig("(0028,1055)");
  unless(defined($window_cntr) && defined($window_wdth)) { return }
  unless(ref($window_cntr) eq "ARRAY"){ return }
  unless(ref($window_wdth) eq "ARRAY"){ return }
  unless($#{$window_cntr} == $#{$window_wdth}){ return }
  if(defined($window_exp)){
    unless(
      ref($window_exp) eq "ARRAY" && $#{$window_exp} == $#{$window_wdth}
    ){ return }
    for my $i (0 .. $#{$window_exp}){
      #todo duplicate else(below), but with win_lev_desc
      my $get_win_level = $db->prepare(
        "select * from window_level where\n" .
        " window_width = ? and window_center = ? and win_lev_desc = ?"
      );
      my $ins_win_level = $db->prepare(
        "insert into window_level\n" .
        "  (window_width, window_center, win_lev_desc)\n" .
        "values(?, ?, ?)"
      );
      my $get_win_lev_id = $db->prepare(
        "select currval('window_level_window_level_id_seq') as\n" .
        "  window_level_id"
      );
      my $get_i_wl = $db->prepare(
        "select * from image_window_level\n" .
        "where window_level_id = ? and image_id = ?"
      );
      my $ins_i_wl = $db->prepare(
        "insert into image_window_level(window_level_id, image_id)\n" .
        "values(?, ?)"
      );
      my $ins_f_wl = $db->prepare(
        "insert into file_win_lev(window_level_id, file_id, wl_index)" .
        "values(?, ?, ?)"
      );
      for my $i (0 .. $#{$window_cntr}){
        $get_win_level->execute(
          $window_wdth->[$i], $window_cntr->[$i], $window_exp->[$i]
        );
        my $h = $get_win_level->fetchrow_hashref();
        $get_win_level->finish();
        my $win_lev_id;
        if($h && ref($h) eq "HASH"){
          $win_lev_id = $h->{window_level_id};
        } else {
          $ins_win_level->execute(
            $window_wdth->[$i], $window_cntr->[$i], $window_exp->[$i]
          );
          $get_win_lev_id->execute();
          my $h = $get_win_lev_id->fetchrow_hashref();
          $get_win_lev_id->finish();
          $win_lev_id = $h->{window_level_id};
        }
        $get_i_wl->execute($win_lev_id, $hist->{image_id});
        $h = $get_i_wl->fetchrow_hashref();
        $get_i_wl->finish();
        unless(defined($h) && ref($h) eq "HASH"){
          $ins_i_wl->execute($win_lev_id, $hist->{image_id});
        }
        $ins_f_wl->execute($win_lev_id, $id, $i);
      }
    }
  } else {
    my $get_win_level = $db->prepare(
      "select * from window_level where\n" .
      " window_width = ? and window_center = ? and win_lev_desc is null"
    );
    my $ins_win_level = $db->prepare(
      "insert into window_level(window_width, window_center)\n" .
      "values(?, ?)"
    );
    my $get_win_lev_id = $db->prepare(
      "select currval('window_level_window_level_id_seq') as\n" .
      "  window_level_id"
    );
    my $get_i_wl = $db->prepare(
      "select * from image_window_level\n" .
      "where window_level_id = ? and image_id = ?"
    );
    my $ins_i_wl = $db->prepare(
      "insert into image_window_level(window_level_id, image_id)\n" .
      "values(?, ?)"
    );
    my $ins_f_wl = $db->prepare(
      "insert into file_win_lev(window_level_id, file_id, wl_index)" .
      "values(?, ?, ?)"
    );
    for my $i (0 .. $#{$window_cntr}){
      $get_win_level->execute($window_wdth->[$i], $window_cntr->[$i]);
      my $h = $get_win_level->fetchrow_hashref();
      $get_win_level->finish();
      my $win_lev_id;
      if($h && ref($h) eq "HASH"){
        $win_lev_id = $h->{window_level_id};
      } else {
        $ins_win_level->execute($window_wdth->[$i], $window_cntr->[$i]);
        $get_win_lev_id->execute();
        my $h = $get_win_lev_id->fetchrow_hashref();
        $get_win_lev_id->finish();
        $win_lev_id = $h->{window_level_id};
      }
      $get_i_wl->execute($win_lev_id, $hist->{image_id});
      $h = $get_i_wl->fetchrow_hashref();
      $get_i_wl->finish();
      unless(defined($h) && ref($h) eq "HASH"){
        $ins_i_wl->execute($win_lev_id, $hist->{image_id});
      }
      $ins_f_wl->execute($win_lev_id, $id, $i);
    }
  }
}
sub StructureSet{
  my($db, $ds, $id, $hist, $errors) = @_;
  my $c_ss = $db->prepare(
    "insert\n" .
    "into structure_set\n" .
    "  (ss_label, ss_description, ss_date, ss_time, ss_name)\n" .
    "values\n" .
    "  (?, ?, ?, ?, ?)"
  );
  my $ss_parms = {
   ss_date   => "(3006,0008)",
   ss_time   => "(3006,0009)",
   ss_label   => "(3006,0002)",
   ss_name   => "(3006,0004)",
   ss_desc   => "(3006,0006)",
   ss_inst_num   => "(0020,0013)",
  };
  my $ModList = {
    ss_date => "Date",
    ss_time => "Timetag",
  };
  my $parms = GetAttrs($ds, $ss_parms, $ModList, $errors);
  $c_ss->execute(
    $parms->{ss_label},
    $parms->{ss_desc},
    $parms->{ss_date},
    $parms->{ss_time},
    $parms->{ss_name},
  );
  my $g_ss_id = $db->prepare(
    "select currval('structure_set_structure_set_id_seq') as ss_id"
  );
  $g_ss_id->execute();
  my $h = $g_ss_id->fetchrow_hashref();
  $g_ss_id->finish();
  unless(
    $h && ref($h) eq "HASH" && exists($h->{ss_id})
  ){
    push(@$errors, "couldn't create structure set row");
    return;
  }
  my $ss_id = $h->{ss_id};
  $hist->{structure_set_id} = $ss_id;
  my $c_f_ss = $db->prepare(
    "insert into file_structure_set\n" .
    "  (file_id, structure_set_id, instance_number)\n" .
    "values\n" .
    "  (?, ?, ?)"
  );
  $c_f_ss->execute($id, $ss_id, $parms->{ss_inst_num});

  my $mp = "(3006,0010)[<0>](3006,00c0)[<1>](3006,00c2)";
  my $rel_frames = $ds->Substitutions($mp);
  for my $m (@{$rel_frames->{list}}){
    my $for_item = $m->[0];
    my $rel_item = $m->[1];
    my $to_for = $ds->ExtractElementBySig("(3006,0010)[$for_item](0020,0052)");
    my $ss_for_id = CreateSsFor($db, $hist, $for_item, $to_for);
    my $XfParms = {
      from_for => "(3006,0010)[$for_item](3006,00c0)[$rel_item](3006,00c2)",
      xform_type => "(3006,0010)[$for_item](3006,00c0)[$rel_item](3006,00c4)",
      xform_mtx => "(3006,0010)[$for_item](3006,00c0)[$rel_item](3006,00c6)",
      xform_cmt => "(3006,0010)[$for_item](3006,00c0)[$rel_item](3006,00c8)",
    };
    my $ModList = {
      xform_mtx => "MultiText",
    };
    my $parms = GetAttrs($ds, $XfParms, $ModList, $errors);
    my $q = $db->prepare(
      "insert into for_registration\n" .
      "  (ss_for_id, from_for_uid, xform_type, xform, xform_comment)\n" .
      "values\n" .
      "  (?, ?, ?, ?, ?)"
    );
    $q->execute(
      $ss_for_id,
      $parms->{from_for},
      $parms->{xform_type},
      $parms->{xform_mtx},
      $parms->{xform_cmt}
    );
  }

  $mp = "(3006,0010)[<0>](3006,0012)[<1>]" .
    "(3006,0014)[<2>](3006,0016)[<3>](0008,1155)";
  my $matches = $ds->Substitutions($mp);
  file_in_volume:
  for my $match(@{$matches->{list}}){
    my $for_item = $match->[0];
    my $stdy_item = $match->[1];
    my $series_item = $match->[2];
    my $cntr_img_item = $match->[3];
    my $to_for = $ds->ExtractElementBySig("(3006,0010)[$for_item](0020,0052)");
    my $v_parms = {
      study_instance_uid =>
        "(3006,0010)[$for_item](3006,0012)[$stdy_item](0008,1155)",
      series_instance_uid =>
        "(3006,0010)[$for_item](3006,0012)[$stdy_item](3006,0014)" .
        "[$series_item](0020,000e)",
      sop_class =>
        "(3006,0010)[$for_item](3006,0012)[$stdy_item](3006,0014)" .
        "[$series_item](3006,0016)[$cntr_img_item](0008,1150)",
      sop_instance =>
        "(3006,0010)[$for_item](3006,0012)[$stdy_item](3006,0014)" .
        "[$series_item](3006,0016)[$cntr_img_item](0008,1155)",
    };
    my $err_id = "(3006,0010)[$for_item](3006,0012)[$stdy_item](3006,0014)" .
        "[$series_item](3006,0016)[$cntr_img_item]";
    my $ss_for_id = CreateSsFor($db, $hist, $for_item, $to_for);
    my $parms = GetAttrs($ds, $v_parms, {}, $errors);
    unless(defined($parms->{study_instance_uid})){
      push(@$errors, "undefined study_instance_uid in $err_id");
      next file_in_volume;
    }
    unless(defined($parms->{series_instance_uid})){
      push(@$errors, "undefined series_instance_uid in $err_id");
      next file_in_volume;
    }
    unless(defined($parms->{sop_class})){
      push(@$errors, "undefined sop_class in $err_id");
      next file_in_volume;
    }
    unless(defined($parms->{sop_instance})){
      push(@$errors, "undefined sop_instance in $err_id");
      next file_in_volume;
    }
    my $q = $db->prepare(
      "insert into\n" .
      "ss_volume\n" .
      "  (ss_for_id, study_instance_uid, series_instance_uid, sop_class,\n" .
      "  sop_instance)\n" .
      "values\n" .
      "  (?, ?, ?, ?, ?)"
    );
    $q->execute(
      $ss_for_id,
      $parms->{study_instance_uid},
      $parms->{series_instance_uid},
      $parms->{sop_class},
      $parms->{sop_instance}
    );
  }
  $matches = $ds->Substitutions("(3006,0020)[<0>](3006,0022)");
  for my $m (@{$matches->{list}}){
    my $ri = $m->[0];
    my $r_parms = {
      roi_num => "(3006,0020)[$ri](3006,0022)",
      ref_for => "(3006,0020)[$ri](3006,0024)",
      name => "(3006,0020)[$ri](3006,0026)",
      desc => "(3006,0020)[$ri](3006,0028)",
      vol => "(3006,0020)[$ri](3006,002c)",
      gen_alg => "(3006,0020)[$ri](3006,0036)",
      gen_alg_desc => "(3006,0020)[$ri](3006,0038)",
    };
    my $parms = GetAttrs($ds, $r_parms, {}, $errors);
    my $q = $db->prepare(
      "insert into roi(\n" .
      "  structure_set_id,\n" .
      "  for_uid,\n" .
      "  roi_num,\n" .
      "  roi_name,\n" .
      "  roi_description,\n" .
      "  roi_volume,\n" .
      "  gen_alg,\n" .
      "  gen_desc)\n" .
      "values (?, ?, ?, ?, ?, ?, ?, ?)"
    );
    $q->execute(
      $ss_id,
      $parms->{ref_for},
      $parms->{roi_num},
      $parms->{name},
      $parms->{desc},
      $parms->{vol},
      $parms->{gen_alg},
      $parms->{gen_alg_desc}
    );
    my $get_roi_id = $db->prepare(
      "select currval('roi_roi_id_seq') as roi_id"
    );
    $get_roi_id->execute();
    my $h = $get_roi_id->fetchrow_hashref();
    $get_roi_id->finish();
    unless(
      $h && ref($h) eq "HASH" && exists($h->{roi_id})
    ){
      push(@$errors, "couldn't create roi row");
      return;
    }
    my $roi_id = $h->{roi_id};
    $parms->{roi_id} = $roi_id;
    $hist->{roi}->{$parms->{roi_num}} = $parms;
  }
}
sub CreateSsFor{
  my($db, $hist, $for_item, $for_uid) = @_;
  if(exists $hist->{ss_for_by_item}->{$for_item}){
    return $hist->{ss_for_by_item}->{$for_item};
  }
  my $q = $db->prepare(
    "insert into ss_for(structure_set_id, for_uid) values (?,?)"
  );
  $q->execute($hist->{structure_set_id}, $for_uid);
  $q = $db->prepare("select currval('ss_for_ss_for_id_seq') as ss_for_id");
  $q->execute();
  my $h = $q->fetchrow_hashref();
  $q->finish();
  my $ss_for_id = $h->{ss_for_id};
  $hist->{ss_for_by_item}->{$for_item} = $ss_for_id;
  return $ss_for_id;
}
sub RoiContour{
  my($db, $ds, $id, $hist, $errors) = @_;
  my $matches = $ds->Substitutions("(3006,0039)[<0>](3006,0084)");
  rc_item:
  for my $m (@{$matches->{list}}){
    my $rci = $m->[0];
    my $ref_roi_num = $ds->ExtractElementBySig("(3006,0039)[$rci](3006,0084)");
    unless(exists($hist->{roi}->{$ref_roi_num})){
      push(@$errors,
        "ROI Contour item $rci references non-existent ROI $ref_roi_num");
      next rc_item;
    }
    my $roi_id = $hist->{roi}->{$ref_roi_num}->{roi_id};
    my $roi_color = $ds->ExtractElementBySig("(3006,0039)[$rci](3006,002a)");
    if(defined($roi_color) && ref($roi_color) eq "ARRAY"){
      my $color = "$roi_color->[0]\\$roi_color->[1]\\$roi_color->[2]";
      my $q = $db->prepare("update roi set roi_color = ? where roi_id = ?");
      $q->execute($color, $roi_id);
    }
    my $m1 = $ds->Substitutions("(3006,0039)[$rci](3006,0040)[<0>]");
    for my $m11 (@{$m1->{list}}){
      my $ci = $m11->[0];
      my $c_parms = {
        contour_num => "(3006,0039)[$rci](3006,0040)[$ci](3006,0048)",
        attached_contours => "(3006,0039)[$rci](3006,0040)[$ci](3006,0049)",
        geometric_type => "(3006,0039)[$rci](3006,0040)[$ci](3006,0042)",
        slab_thickness => "(3006,0039)[$rci](3006,0040)[$ci](3006,0044)",
        offset_vector => "(3006,0039)[$rci](3006,0040)[$ci](3006,0045)",
        number_points => "(3006,0039)[$rci](3006,0040)[$ci](3006,0046)",
#        data => "(3006,0039)[$rci](3006,0040)[$ci](3006,0050)",
      };
      my $ModList = {
        attached_contours => "MultiText",
        data => "MultiText",
        offset_vector => "MultiText",
      };
      my $parms = GetAttrs($ds, $c_parms, $ModList, $errors);
      my $q = $db->prepare(
        "insert into roi_contour(\n" .
        "  roi_id,\n" .
        "  contour_num,\n" .
        "  geometric_type,\n" .
        "  slab_thickness,\n" .
        "  offset_vector,\n" .
        "  number_of_points,\n" .
        "  roi_contour_attachment\n" .
#        "  roi_contour_attachment,\n" .
#        "  contour_data\n" .
        ") values (\n" .
        "  ?, ?, ?, ?, ?, ?, ?\n" .
#        "  ?, ?, ?, ?, ?, ?, ?, ?\n" .
        ")"
      );
      $q->execute(
        $roi_id,
        $parms->{contour_num},
        $parms->{geometric_type},
        $parms->{slab_thickness},
        $parms->{offset_vector},
        $parms->{number_points},
        $parms->{attached_contours}
#        $parms->{attached_contours},
#        $parms->{data},
      );
      my $m2 = $ds->Substitutions(
        "(3006,0039)[$rci](3006,0040)[$ci](3006,0016)[<0>]");
      contour_image:
      for my $m21 (@{$m2->{list}}){
        my $cii = $m21->[0];
        my $ci_parms = {
          sop_class =>
            "(3006,0039)[$rci](3006,0040)[$ci](3006,0016)[$cii](0008,1150)",
          sop_inst =>
            "(3006,0039)[$rci](3006,0040)[$ci](3006,0016)[$cii](0008,1155)",
          frame =>
            "(3006,0039)[$rci](3006,0040)[$ci](3006,0016)[$cii](0008,1160)",
        };
        my $parms = GetAttrs($ds, $ci_parms, {
          frame => "MultiText",
        }, $errors);
        unless($parms->{sop_inst}){
          push(@$errors, "Undefined sop_inst in " .
            "(3006,0039)[$rci](3006,0040)[$ci](3006,0016)[$cii]");
          next contour_image;
        }
        unless($parms->{sop_class}){
          push(@$errors, "Undefined sop_class in " .
            "(3006,0039)[$rci](3006,0040)[$ci](3006,0016)[$cii]");
          next contour_image;
        }
        my $q = $db->prepare(
          "insert into contour_image(\n" .
          "  roi_contour_id,\n" .
          "  sop_class,\n" .
          "  sop_instance,\n" .
          "  frame_number)\n" .
          "values(currval('roi_contour_roi_contour_id_seq'), ?, ?, ?)"
        );
        $q->execute($parms->{sop_class}, $parms->{sop_inst}, $parms->{frame});
      }
    }
  }
}
sub RtRoiObservations{
  my($db, $ds, $id, $hist, $errors) = @_;
  my $mp = $ds->Substitutions("(3006,0080)[<0>](3006,0082)");
  roi_obs:
  for my $m (@{$mp->{list}}){
    my $oi = $m->[0];
    my $op_parms = {
      ob_num => "(3006,0080)[$oi](3006,0082)",
      ref_roi_num => "(3006,0080)[$oi](3006,0084)",
      obs_label => "(3006,0080)[$oi](3006,0085)",
      obs_desc => "(3006,0080)[$oi](3006,0088)",
      int_type => "(3006,0080)[$oi](3006,00a4)",
      interpreter => "(3006,0080)[$oi](3006,00a6)",
      material_id => "(3006,0080)[$oi](3006,00e1)",
    };
    my $parms = GetAttrs($ds, $op_parms, {}, $errors);
    my $q = $db->prepare(
      "insert into roi_observation(\n" .
      "  roi_id,\n" .
      "  roi_obs_num,\n" .
      "  observation_label,\n" .
      "  observation_description,\n" .
      "  interpreted_type,\n" .
      "  interpreter,\n" .
      "  material_id)\n" .
      "values(?, ?, ?, ?, ?, ?, ?)\n"
    );
    unless(exists($hist->{roi}->{$parms->{ref_roi_num}})){
      push(@$errors,
        "ROI observation item $oi references non-existent " .
        "ROI $parms->{ref_roi_num}");
      next roi_obs;
    }
    my $roi_id = $hist->{roi}->{$parms->{ref_roi_num}}->{roi_id};
    $q->execute(
      $roi_id,
      $parms->{ob_num},
      $parms->{obs_label},
      $parms->{obs_desc},
      $parms->{int_type},
      $parms->{interpreter},
      $parms->{material_id},
    );
    $q = $db->prepare(
      "select currval('roi_observation_roi_observation_id_seq') " .
      "as roi_observation_id");
    $q->execute();
    my $h = $q->fetchrow_hashref();
    $q->finish();
    my $roi_observation_id = $h->{roi_observation_id};
    my $mr = $ds->Substitutions("(3006,0080)[$oi](3006,0030)[<0>]");
    rel_roi:
    for my $mrm (@{$mr->{list}}){
      my $mrmi = $mrm->[0];
      my $rel_roi_num = $ds->ExtractElementBySig(
        "(3006,0080)[$oi](3006,0030)[$mrmi](3006,0084)"
      );
      my $rel = $ds->ExtractElementBySig(
        "(3006,0080)[$oi](3006,0030)[$mrmi](3006,0033)"
      );
      unless(exists($hist->{roi}->{$rel_roi_num})){
        push(@$errors,
          "ROI $roi_id is related to undefined ROI number $rel_roi_num");
        next rel_roi;
      }
      my $rel_roi = $hist->{roi}->{$rel_roi_num}->{roi_id};
      my $q = $db->prepare(
        "insert into roi_related_roi(\n" .
        "  roi_id,\n" .
        "  related_roi_id,\n" .
        "  relationship)\n" .
        "values(?, ?, ?)"
      );
      $q->execute($roi_id, $rel_roi, $rel);
    }
    my $rom = $ds->Substitutions(
      "(3006,0080)[$oi](3006,00a0)[<0>](3006,0082)");
    for my $romm (@{$rom->{list}}){
      my $i = $romm->[0];
      my $rel_obs_num = $ds->ExtractElementBySig(
        "(3006,0080)[$oi](3006,00a0)[$i](3006,0082)"
      );
      my $q = $db->prepare(
        "insert into related_roi_observations(\n" .
        "  roi_observation_id,\n" .
        "  related_roi_observation_num)\n" .
        "values(?, ?)"
      );
      $q->execute($roi_observation_id, $rel_obs_num);
    }
    my $ppm = $ds->Substitutions("(3006,0080)[$oi](3006,00b0)[<0>]");
    for my $ppmi (@{$ppm->{list}}){
      my $i = $ppmi->[0];
      my $name = $ds->ExtractElementBySig(
        "(3006,0080)[$oi](3006,00b0)[$i](3006,00b2)");
      my $value = $ds->ExtractElementBySig(
        "(3006,0080)[$oi](3006,00b0)[$i](3006,00b4)");
      my $q = $db->prepare(
        "insert into roi_physical_properties(\n" .
        "  roi_observation_id,\n" .
        "  property,\n" .
        "  property_value)\n" .
        "values(?, ?, ?)\n"
      );
      $q->execute($roi_observation_id, $name, $value);
      my $elem = $ds->Substitutions(
        "(3006,0080)[$oi](3006,00a0)[$i](3006,00b6)[<0>]");
      for my $elemi (@{$elem->{list}}){
        my $j = $elemi->[0];
        my $atomic_num = $ds->ExtractElementBySig(
          "(3006,0080)[$oi](3006,00a0)[$i](3006,00b6)[$j](3006,00b7)");
        my $atomic_mass_fraction = $ds->ExtractElementBySig(
          "(3006,0080)[$oi](3006,00a0)[$i](3006,00b6)[$j](3006,00b8)");
        my $q = $db->prepare(
          "insert into roi_elemental_composition(\n" .
          "  roi_physical_properties_id,\n" .
          "  roi_elemental_composition_atomic_number,\n" .
          "  roi_elemental_composition_atomic_mass_fraction)\n" .
          "values(\n" .
          "  currval" .
             "('roi_physical_properties_roi_physical_properties_id_seq')," .
             " ?, ?)"
        );
        $q->execute($atomic_num, $atomic_mass_fraction);
      }
    }
  }
  #print "RtRoiObservations Module not yet implemented\n";
}
sub RtPlan{
  my($db, $ds, $id, $hist, $errors) = @_;
  # Set up following tables:
  #   plan
  #   file_plan
  #   dose_referenced_from_plan
  #   plan_related_plans
  my $pparm = {
    plan_label => "(300a,0002)",
    plan_name => "(300a,0003)",
    plan_description => "(300a,0004)",
    instance_number => "(0020,0013)",
    operators_name => "(0008,1070)",
    rt_plan_date => "(300a,0006)",
    rt_plan_time => "(300a,0007)",
    rt_treatment_protocols => "(300a,0009)",
    plan_intent => "(300a,000a)",
    treatment_sites => "(300a,000b)",
    rt_plan_geometry => "(300a,000c)",
    ss_referenced_from_plan => "(300c,0060)[0](0008,1155)",
  };
  my $ModList = {
    rt_plan_date => "Date",
    rt_plan_time => "Timetag",
    rt_treatment_protocols => "MultiText",
    operators_name => "MultiText",
    treatment_sites => "MultiText",
  };
  my $parms = GetAttrs($ds, $pparm, $ModList, $errors);
  unless(defined($parms->{plan_label})){
    push(@$errors, "plan label undefined");
    return;
  }
  unless(defined($parms->{rt_plan_geometry})){
    push(@$errors, "plan geometry undefined");
    return;
  }
  my $ins_plan = $db->prepare(
    "insert into plan(\n" .
    "  plan_label, plan_name, plan_description,\n" .
    "  instance_number, operators_name, rt_plan_date,\n" .
    "  rt_plan_time, rt_treatment_protocols, plan_intent,\n" .
    "  treatment_sites, rt_plan_geometry, ss_referenced_from_plan\n" .
    ")values(\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?, ?)"
  );
  $ins_plan->execute(
    $parms->{plan_label},
    $parms->{plan_name},
    $parms->{plan_description},

    $parms->{instance_number},
    $parms->{operators_name},
    $parms->{rt_plan_date},

    $parms->{rt_plan_time},
    $parms->{rt_treatment_protocols},
    $parms->{plan_intent},

    $parms->{treatment_sites},
    $parms->{rt_plan_geometry},
    $parms->{ss_referenced_from_plan},
  );
  my $get_plan_id = $db->prepare(
    "select currval('plan_plan_id_seq') as plan_id");
  $get_plan_id->execute();
  my $h = $get_plan_id->fetchrow_hashref();
  unless($h && ref($h) eq "HASH" && $h->{plan_id}){
    push(@$errors, "unable to get plan_id");
    return;
  }
  my $plan_id = $h->{plan_id};
  $hist->{plan_id} = $plan_id;
  my $ins_file_plan = $db->prepare(
    "insert into file_plan(\n" .
    "  plan_id, file_id\n" .
    ")values(\n" .
    "  ?, ?)"
  );
  $ins_file_plan->execute($plan_id, $id);
  my $ins_drfp = $db->prepare(
    "insert into dose_referenced_from_plan(\n" .
    "  plan_id, dose_sop_instance_uid\n" .
    ")values(\n" .
    "  ?, ?)"
  );
  my $m = $ds->Substitutions("(300c,0080)[<0>](0008,1155)");
  for my $p (@{$m->{list}}){
    my $i = $p->[0];
    my $sop_class = $ds->ExtractElementBySig("(300c,0080)[$i](0008,1150)");
    my $sop_inst= $ds->ExtractElementBySig("(300c,0080)[$i](0008,1155)");
    $ins_drfp->execute($plan_id, $sop_inst);
  }
  my $ins_prp = $db->prepare(
    "insert into plan_related_plans(\n" .
    "  plan_id, related_plan_instance_uid, plan_relationship\n" .
    ")values(\n" .
    "  ?, ?, ?)"
  );
  $m = $ds->Substitutions("(300c,0002)[<0>](0008,1155)");
  for my $p (@{$m->{list}}){
    my $i = $p->[0];
    my $sop_class = $ds->ExtractElementBySig("(300c,0002)[$i](0008,1150)");
    my $sop_inst= $ds->ExtractElementBySig("(300c,0002)[$i](0008,1155)");
    my $relationship= $ds->ExtractElementBySig("(300c,0002)[$i](300a,0055)");
    $ins_prp->execute($plan_id, $sop_inst, $relationship);
  }
}
sub RtPrescription{
  my($db, $ds, $id, $hist, $errors) = @_;
  #  Set up following tables:
  #    rt_prescription
  #    rt_prescription_dose_ref
  my $ins_rt_prescription = $db->prepare(
    "insert into rt_prescription(\n" .
    "  plan_id, rt_prescription_description\n" .
    ")values(\n" .
    "  ?, ?)"
  );
  my $pparms = {
    rt_prescription_desc => "(300a,000e)",
  };
  my $parms = GetAttrs($ds, $pparms, {}, $errors);
  unless($hist->{plan_id}){
    push(@$errors, "no plan (RtPrescription module)");
    return;
  }
  $ins_rt_prescription->execute(
     $hist->{plan_id},
     $parms->{rt_prescription_desc}
  );
  my $get_presc_id = $db->prepare(
    "select currval('rt_prescription_rt_prescription_id_seq') as presc_id");
  $get_presc_id->execute();
  my $h = $get_presc_id->fetchrow_hashref();
  unless($h && ref($h) eq "HASH" && $h->{presc_id}){
    push(@$errors, "unable to get presc_id");
    return;
  }
  my $presc_id = $h->{presc_id};
  my $ins_rt_prescription_dose_ref = $db->prepare(
    "insert into rt_prescription_dose_ref(\n" .
    "  rt_prescription_id, dose_reference_number, dose_reference_uid,\n" .
    "  referenced_roi_number, dose_reference_point, nominal_prior_dose,\n" .
    "  dose_reference_structure_type,\n" .
    "  dose_reference_type, constraint_weight, delivery_warning_dose,\n" .
    "  delivery_maximum_dose, target_minimum_dose,\n" .
    "   target_prescription_dose,\n" .
    "  target_maximum_dose, target_underdose_volume_fraction, \n" .
    "  organ_at_risk_full_volume_dose,\n" .
    "  organ_at_risk_limit_dose, organ_at_risk_maximum_dose, \n" .
    "  organ_at_overdose_volume_fraction\n" .
    ")values(\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?, ?,\n" .
    "  ?,\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?,\n" .
    "  ?,\n" .
    "  ?, ?,\n" .
    "  ?,\n" .
    "  ?, ?,\n" .
    "  ?)"
  );
  my $p = $ds->Substitutions("(300a,0010)[<0>](300a,0012)");
  dose_reference:
  for my $m (@{$p->{list}}){
    my $i = $m->[0];
    my $pparms = {
      dose_reference_number => "(300a,0010)[$i](300a,0012)",
      dose_reference_uid => "(300a,0010)[$i](300a,0013)",
      referenced_roi_number => "(300a,0010)[$i](300a,0084)",
      dose_reference_point => "(300a,0010)[$i](300a,0018)",
      nominal_prior_dose => "(300a,0010)[$i](300a,001a)",
      dose_reference_structure_type => "(300a,0010)[$i](300a,0014)",
      dose_reference_description => "(300a,0010)[$i](300a,0016)",
      dose_reference_type => "(300a,0010)[$i](300a,0020)",
      constraint_weight => "(300a,0010)[$i](300a,0021)",
      delivery_warning_dose => "(300a,0010)[$i](300a,0022)",
      delivery_maximum_dose => "(300a,0010)[$i](300a,0023)",
      target_minimum_dose => "(300a,0010)[$i](300a,0025)",
      target_prescription_dose => "(300a,0010)[$i](300a,0026)",
      target_maximum_dose => "(300a,0010)[$i](300a,0027)",
      target_underdose_volume_fraction => "(300a,0010)[$i](300a,0028)",
      organ_at_risk_full_volume_dose => "(300a,0010)[$i](300a,002a)",
      organ_at_risk_limit_dose => "(300a,0010)[$i](300a,002b)",
      organ_at_risk_maximum_dose => "(300a,0010)[$i](300a,002b)",
      organ_at_overdose_volume_fraction => "(300a,0010)[$i](300a,002b)",
    };
    my $ModList = {
      dose_reference_point => "MultiText",
    };
    my $parms = GetAttrs($ds, $pparms, $ModList, $errors);
    unless(
      exists $parms->{dose_reference_number} &&
      defined($parms->{dose_reference_number})
    ){
      push(@$errors, "dose reference missing dose_reference_number");
      next dose_reference;
    }
    unless(exists $parms->{dose_reference_structure_type}){
      push(@$errors, "dose reference missing dose_reference_structure_type");
      next dose_reference;
    }
    unless(exists $parms->{dose_reference_type}){
      push(@$errors, "dose reference missing dose_reference_type");
      next dose_reference;
    }
    $ins_rt_prescription_dose_ref->execute(
      $presc_id,
      $parms->{dose_reference_number},
      $parms->{dose_reference_uid},
      $parms->{referenced_roi_number},
      $parms->{dose_reference_point},
      $parms->{nominal_prior_dose},
      $parms->{dose_reference_structure_type},
      $parms->{dose_reference_type},
      $parms->{constraint_weight},
      $parms->{delivery_warning_dose},
      $parms->{delivery_maximum_dose},
      $parms->{target_minimum_dose},
      $parms->{target_prescription_dose},
      $parms->{target_maximum_dose},
      $parms->{target_underdose_volume_fraction},
      $parms->{organ_at_risk_full_volume_dose},
      $parms->{organ_at_risk_limit_dose},
      $parms->{organ_at_risk_maximum_dose},
      $parms->{organ_at_overdose_volume_fraction}
    );
  }
}
sub RtToleranceTables{
  my($db, $ds, $id, $hist, $errors) = @_;
  #  Set up following tables:
  #    rt_beam_tolerance_table
  #    rt_beam_limit_dev_tolerance
  my $ins_rt_beam_tolerance = $db->prepare(
    "insert into rt_beam_tolerance_table(\n" .
    "  plan_id,\n" .
    "  tolerance_table_number,\n" .
    "  tolerance_table_label,\n" .
    "  gantry_angle_tolerance,\n" .
    "  gantry_angle_pitch_tolerance,\n" .
    "  beam_limiting_device_angle_tolerance,\n" .
    "  patient_support_angle_tolerance,\n" .
    "  table_top_eccentric_angle_tolerance,\n" .
    "  table_top_pitch_angle_tolerance,\n" .
    "  table_top_roll_angle_tolerance,\n" .
    "  table_top_vert_pos_tolerance,\n" .
    "  table_top_log_pos_tolerance,\n" .
    "  table_top_lat_pos_tolerance\n" .
    ") values(\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?\n" .
    ")"
  );
  my $ins_rt_beam_limit_dev_tolerance = $db->prepare(
    "insert into rt_beam_limit_dev_tolerance(\n" .
    "  plan_id, tolerance_table_number,\n" .
    "  beam_limit_dev_type, beam_limit_dev_pos_tolerance\n" .
    ") values(\n" .
    "  ?, ?,\n" .
    "  ?, ?\n" .
    ")"
  );
  my $s = $ds->Substitutions("(300a,0040)[<0>](300a,0042)");
  tolerance_table:
  for my $m (@{$s->{list}}){
    my $i = $m->[0];
    my $rbt_parms = {
      tolerance_table_number => "(300a,0040)[$i](300a,0042)",
      tolerance_table_label => "(300a,0040)[$i](300a,0043)",
      gantry_angle_tolerance => "(300a,0040)[$i](300a,0044)",
      gantry_angle_pitch_tolerance => "(300a,0040)[$i](300a,014e)",
      beam_limiting_device_angle_tolerance => "(300a,0040)[$i](300a,0046)",
      patient_support_angle_tolerance => "(300a,0040)[$i](300a,004c)",
      table_top_eccentric_angle_tolerance => "(300a,0040)[$i](300a,004e)",
      table_top_pitch_angle_tolerance => "(300a,0040)[$i](300a,004f)",
      table_top_roll_angle_tolerance => "(300a,0040)[$i](300a,0050)",
      table_top_vert_pos_tolerance => "(300a,0040)[$i](300a,0051)",
      table_top_log_pos_tolerance => "(300a,0040)[$i](300a,0052)",
      table_top_lat_pos_tolerance => "(300a,0040)[$i](300a,0053)",
    };
    my $parms = GetAttrs($ds, $rbt_parms, {}, $errors);
    unless($parms->{tolerance_table_number}){
      push(@$errors, "no tolerance_table_number in item $i");
      next tolerance_table;
    }
    my $tolerance_table_number = $parms->{tolerance_table_number};
    $ins_rt_beam_tolerance->execute(
      $hist->{plan_id},
      $parms->{tolerance_table_number},
      $parms->{tolerance_table_label},
      $parms->{gantry_angle_tolerance},
      $parms->{gantry_angle_pitch_tolerance},
      $parms->{beam_limiting_device_angle_tolerance},
      $parms->{patient_support_angle_tolerance},
      $parms->{table_top_eccentric_angle_tolerance},
      $parms->{table_top_pitch_angle_tolerance},
      $parms->{table_top_roll_angle_tolerance},
      $parms->{table_top_vert_pos_tolerance},
      $parms->{table_top_log_pos_tolerance},
      $parms->{table_top_lat_pos_tolerance}
    );
    my $s1 = $ds->Substitutions("(300a,0040)[$i](300a,0048)[<0>](300a,00b8)");
    for my $mq (@{$s1->{list}}){
      my $j = $mq->[0];
      my $bldt_parms = {
        beam_limit_dev_type => "(300a,0040)[$i](300a,0048)[$j](300a,00b8)",
        beam_limit_dev_pos_tolerance =>
          "(300a,0040)[$i](300a,0048)[$j](300a,004a)",
      };
      my $parms = GetAttrs($ds, $bldt_parms, {}, $errors);
      $ins_rt_beam_limit_dev_tolerance->execute(
        $hist->{plan_id},
        $tolerance_table_number,
        $parms->{beam_limit_dev_type},
        $parms->{beam_limit_dev_pos_tolerance},
      );
    }
  }
}
sub RtPatientSetup{
  my($db, $ds, $id, $hist, $errors) = @_;
  #  Set up following tables:
  ##    rt_plan_patient_setup
  ##    rt_plan_setup_image
  ##    rt_plan_setup_fixation_device
  ##    rt_plan_setup_shielding_device
  ##    rt_plan_setup_device
  ##    rt_plan_respiratory_motion_comp

  #    rt_plan_patient_setup
  my $ins_rt_plan_patient_setup = $db->prepare(
    "insert into rt_plan_patient_setup(\n" .
    "  plan_id,\n" .
    "  patient_setup_num,\n" .
    "  patient_setup_label,\n" .
    "  patient_position,\n" .
    "  patient_addl_pos,\n" .
    "  setup_technique,\n" .
    "  setup_technique_description,\n" .
    "  table_top_vert_disp,\n" .
    "  table_top_long_disp,\n" .
    "  table_top_lat_disp\n" .
    ") values(\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?\n" .
    ")"
  );
  my $s = $ds->Substitutions("(300a,0180)[<0>](300a,0182)");
  patient_setup:
  for my $m (@{$s->{list}}){
    my $i = $m->[0];
    my $psu_parms = {
      patient_setup_num => "(300a,0180)[$i](300a,0182)",
      patient_setup_label => "(300a,0180)[$i](300a,0183)",
      patient_position => "(300a,0180)[$i](0018,5100)",
      patient_addl_pos => "(300a,0180)[$i](300a,0184)",
      setup_technique => "(300a,0180)[$i](300a,01b0)",
      setup_technique_description => "(300a,0180)[$i](300a,01b2)",
      table_top_vert_disp => "(300a,0180)[$i](300a,01d2)",
      table_top_long_disp => "(300a,0180)[$i](300a,01d4)",
      table_top_lat_disp => "(300a,0180)[$i](300a,01d6)",
    };
    my $parms = GetAttrs($ds, $psu_parms, {}, $errors);
    unless($parms->{patient_setup_num}){
      push(@$errors, "no patient_setup $i");
      next patient_setup;
    }
    my $patient_setup_num = $parms->{patient_setup_num};
    $ins_rt_plan_patient_setup->execute(
      $hist->{plan_id},
      $parms->{patient_setup_num},
      $parms->{patient_setup_label},
      $parms->{patient_position},
      $parms->{patient_addl_pos},
      $parms->{setup_technique},
      $parms->{setup_technique_description},
      $parms->{table_top_vert_disp},
      $parms->{table_top_long_disp},
      $parms->{table_top_lat_disp}
    );
    my $s1 = $ds->Substitutions("(300a,0180)[$i](300a,0401)[<0>](0008,1155)");
    for my $m1 (@{$s1->{list}}){
      my $in_rt_plan_setup_image = $db->prepare(
        "insert into rt_plan_setup_image(\n" .
        "  plan_id,\n" .
        "  patient_setup_num,\n" .
        "  setup_image_comment,\n" .
        "  image_sop_class_uid,\n" .
        "  image_sop_instance_uid\n" .
        ") values(\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $j = $m1->[0];
      my $psi_parms = {
        setup_image_comment => "(300a,0180)[$i](300a,0401)[$j](300a,0402)",
        image_sop_class_uid => "(300a,0180)[$i](300a,0401)[$j](0008,1150)",
        image_sop_instance_uid => "(300a,0180)[$i](300a,0401)[$j](0008,1155)",
      };
      my $parms = GetAttrs($ds, $psi_parms, {}, $errors);
      $in_rt_plan_setup_image->execute(
        $hist->{plan_id},
        $patient_setup_num,
        $parms->{setup_image_comment},
        $parms->{image_sop_class_uid},
        $parms->{image_sop_instance_uid},
      );
      #    rt_plan_setup_fixation_device
      my $s2 = $ds->Substitutions("(300a,0180)[$i](300a,0190)[<0>](300a,0192)");
      for my $m2 (@{$s2->{list}}){
        my $j = $m2->[0];
        my $ins_rt_plan_fixation_device = $ds->prepare(
          "insert inot rt_plan_fixation_device(\n" .
          "    plan_id,\n" .
          "    patient_setup_num,\n" .
          "    fixation_device_type,\n" .
          "    fixaction_device_label,\n" .
          "    fixation_device_description,\n" .
          "    fixation_device_position,\n" .
          "    fixation_device_pitch_angle,\n" .
          "    fixation_device_roll_angle,\n" .
          "    fixation_device_accessory_code\n" .
          ") values (\n" .
          "    ?,\n" .
          "    ?,\n" .
          "    ?,\n" .
          "    ?,\n" .
          "    ?,\n" .
          "    ?,\n" .
          "    ?,\n" .
          "    ?,\n" .
          "    ?\n" .
          ")"
        );
        my $psf_parms = {
          fixation_device_type => "(300a,0180)[$i](300a,0190[$j](300a,0192)",
          fixaction_device_label => "(300a,0180)[$i](300a,0190[$j](300a,0194)",
          fixation_device_description =>
            "(300a,0180)[$i](300a,0190[$j](300a,0196)",
          fixation_device_position =>
            "(300a,0180)[$i](300a,0190[$j](300a,0198)",
          fixation_device_pitch_angle =>
            "(300a,0180)[$i](300a,0190[$j](300a,0199)",
          fixation_device_roll_angle =>
            "(300a,0180)[$i](300a,0190[$j](300a,019A)",
          fixation_device_accessory_code =>
            "(300a,0180)[$i](300a,0190[$j](300a,01f9)",
        };
        my $parms = GetAttrs($ds, $psf_parms, {}, $errors);
        $ins_rt_plan_fixation_device->execute(
          $hist->{plan_id},
          $patient_setup_num,
          $parms->{fixation_device_type},
          $parms->{fixaction_device_label},
          $parms->{fixation_device_description},
          $parms->{fixation_device_position},
          $parms->{fixation_device_pitch_angle},
          $parms->{fixation_device_roll_angle},
          $parms->{fixation_device_accessory_code}
        );
      }
      #    rt_plan_setup_shielding_device
      my $s3 = $ds->Substitutions("(300a,0180)[$i](300a,01a0)[<0>](300a,01a2)");
      for my $m3 (@{$s3->{list}}){
        my $ins_rt_plan_setup_shielding_device = $db->prepare(
          "insert into rt_plan_setup_shielding_device(\n" .
          "  plan_id,\n" .
          "  patient_setup_num,\n" .
          "  shielding_device_type,\n" .
          "  shielding_device_label,\n" .
          "  shielding_device_description,\n" .
          "  shielding_device_accessory_code\n" .
          ") values (\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?\n" .
          ")"
        );
        my $j = $m3->[0];
        my $pss_parms = {
          shielding_device_type => "(300a,0180)[$i](300a,01a0)[$j](300a,01a2)",
          shielding_device_label =>
            "(300a,0180)[$i](300a,01a0)[$j](300a,01a4)",
          shielding_device_description =>
            "(300a,0180)[$i](300a,01a0)[$j](300a,01a6)",
          shielding_device_accessory_code =>
            "(300a,0180)[$i](300a,01a0)[$j](300a,01a8)",
        };
        my $parms = GetAttrs($ds, $pss_parms, {}, $errors);
        $ins_rt_plan_setup_shielding_device->execute(
          $hist->{plan_id},
          $patient_setup_num,
          $parms->{shielding_device_type},
          $parms->{shielding_device_label},
          $parms->{shielding_device_description},
          $parms->{shielding_device_accessory_code}
        );
      }
      #    rt_plan_setup_device
      my $s4 = $ds->Substitutions("(300a,0180)[$i](300a,01b4)[<0>](300a,01b6)");
      for my $m4 (@{$s4->{list}}){
        my $j = $m4->[0];
        my $ins_rt_plan_setup_device = $db->prepare(
          "insert into rt_plan_setup_device(\n" .
          "  plan_id,\n" .
          "  patient_setup_num,\n" .
          "  setup_device_type,\n" .
          "  setup_device_label,\n" .
          "  setup_device_description,\n" .
          "  setup_device_parameter,\n" .
          "  setup_reference_description\n" .
          ") values (\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?\n" .
          ")"
        );
        my $psd_parms = {
          setup_device_type => "(300a,0180)[$i](300a,01b4)[$j](300a,01b6)",
          setup_device_label => "(300a,0180)[$i](300a,01b4)[$j](300a,01b8)",
          setup_device_description =>
            "(300a,0180)[$i](300a,1b4)[$j](300a,01ba)",
          setup_device_parameter => "(300a,0180)[$i](300a,01b4)[$j](300a,01bc)",
          setup_reference_description =>
            "(300a,0180)[$i](300a,01b4)[$j](300a,01d0)"
        };
        my $parms = GetAttrs($ds, $psd_parms, {}, $errors);
        $ins_rt_plan_setup_device->execute(
          $hist->{plan_id},
          $patient_setup_num,
          $parms->{setup_device_type},
          $parms->{setup_device_label},
          $parms->{setup_device_description},
          $parms->{setup_device_parameter},
          $parms->{setup_reference_description}
        );
      }
      #    rt_plan_respiratory_motion_comp
      my $s5 = $ds->Substitutions("(300a,0180)[$i](300a,0410)[<0>](0018,9170)");
      for my $m5 (@{$s5->{list}}){
        my $j = $m5->[0];
        my $ins_prmc = $db->prepare(
          "insert into rt_plan_respiratory_motion_comp(\n" .
          "  plan_id,\n" .
          "  patient_setup_num,\n" .
          "  sequence_index,\n" .
          "  respiratory_motion_comp_technique,\n" .
          "  respiratory_signal_source,\n" .
          "  respiratory_motion_com_tech_desc,\n" .
          "  respiratory_signal_source_id\n" .
          ") values (\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?\n" .
          ")"
        );
        my $prmc_parms = {
          respiratory_motion_comp_technique =>
            "(300a,0180)[$i](300a,0410)[$j](0018,9170)",
          respiratory_signal_source =>
            "(300a,0180)[$i](300a,0410)[$j](0018,9171)",
          respiratory_motion_com_tech_desc =>
            "(300a,0180)[$i](300a,0410)[$j](0018,9185)",
          respiratory_signal_source_id =>
            "(300a,0180)[$i](300a,0410)[$j](0018,9186)",
        };
        my $parms = GetAttrs($ds, $prmc_parms, {}, $errors);
        $ins_prmc->execute(
          $hist->{plan_id},
          $patient_setup_num,
          $j,
          $parms->{respiratory_motion_comp_technique},
          $parms->{respiratory_signal_source},
          $parms->{respiratory_motion_com_tech_desc},
          $parms->{respiratory_signal_source_id}
        );
      }
    }
  }
  #print "RtPatientSetup Module not yet implemented\n";
}
sub RtFractionScheme{
  my($db, $ds, $id, $hist, $errors) = @_;
  #  Set up following tables:
  #    rt_plan_fraction_group
  #    fraction_related_dose
  #    fraction_reference_dose
  #    fraction_reference_beam
  #    fraction_reference_brachy

  #    rt_plan_fraction_group
  my $ins_rtpfg = $db->prepare(
    "insert into rt_plan_fraction_group(\n" .
    "  plan_id,\n" .
    "  fraction_group_number,\n" .
    "  fraction_group_descripton,\n" .
    "  number_of_fractions_planned,\n" .
    "  number_of_fraction_digits_per_day,\n" .
    "  repeat_fraction_cycle_length,\n" .
    "  fraction_pattern,\n" .
    "  number_of_beams,\n" .
    "  number_of_brachy_application_setups\n" .
    ") values (\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?,\n" .
    "  ?\n" .
    ")"
  );
  my $s = $ds->Substitutions("(300a,0070)[<0>](300a,0071)");
  fraction_group:
  for my $m (@{$s->{list}}){
    my $i = $m->[0];
    my $rfpfg_parms = {
      fraction_group_number => "(300a,0070)[$i](300a,0071)",
      fraction_group_descripton => "(300a,0070)[$i](300a,0072)",
      number_of_fractions_planned => "(300a,0070)[$i](300a,0078)",
      number_of_fraction_digits_per_day => "(300a,0070)[$i](300a,0079)",
      repeat_fraction_cycle_length => "(300a,0070)[$i](300a,007a)",
      fraction_pattern => "(300a,0070)[$i](300a,007b)",
      number_of_beams => "(300a,0070)[$i](300a,0080)",
      number_of_brachy_application_setups => "(300a,0070)[$i](300a,00a0)",
    };
    my $ModList = {
      number_of_fractions_planned => "Integer",
    };
    my $parms = GetAttrs($ds, $rfpfg_parms, $ModList, $errors);
    unless(defined $parms->{fraction_group_number}){
      push(@$errors,
        "Undefined fraction group number (300a,0070)[$i](300a,0071)");
      next fraction_group;
    }
    my $fraction_group_number = $parms->{fraction_group_number};
    $ins_rtpfg->execute(
      $hist->{plan_id},
      $fraction_group_number,
      $parms->{fraction_group_descripton},
      $parms->{number_of_fractions_planned},
      $parms->{number_of_fraction_digits_per_day},
      $parms->{repeat_fraction_cycle_length},
      $parms->{fraction_pattern},
      $parms->{number_of_beams},
      $parms->{number_of_brachy_application_setups}
    );
    #    fraction_related_dose
    my $s1 = $ds->Substitutions("(300a,0070)[$i](300c,0080)[<0>](0008,1155)");
    dose_reference:
    for my $m1 (@{$s1->{list}}){
      my $j = $m1->[0];
      my $ins_frd = $db->prepare(
        "insert into fraction_related_dose(\n" .
        "  plan_id,\n" .
        "  fraction_group_number,\n" .
        "  sop_class_uid,\n" .
        "  sop_instance_uid\n" .
        ") values (\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $frd_parms = {
        sop_class_uid => "(300a,0070)[$i](300c,0080)[$j](0008,1150)",
        sop_instance_uid => "(300a,0070)[$i](300c,0080)[$j](0008,1155)",
      };
      my $ModList = {
      };
      my $parms = GetAttrs($ds, $rfpfg_parms, $ModList, $errors);
      unless(defined($parms->{sop_instance_uid})){
         push(@$errors, "undefined sop_instance_uid: " .
           "(300a,0070)[$i](300c,0080)[$j](0008,1155)");
         next dose_reference;
      }
      unless(defined($parms->{sop_class_uid})){
         push(@$errors, "undefined sop_class_uid: " .
           "(300a,0070)[$i](300c,0080)[$j](0008,1150)");
         next dose_reference;
      }
      $ins_frd->execute(
        $hist->{plan_id},
        $fraction_group_number,
        $parms->{sop_class_uid},
        $parms->{sop_instance_uid}
      );
    }
    #    fraction_reference_dose
    my $s2 = $ds->Substitutions("(300a,0070)[$i](300c,0050)[<0>](300c,0051)");
    reference_dose:
    for my $m2 (@{$s2->{list}}){
      my $j = $m2->[0];
      my $ins_fdr = $db->prepare(
        "insert into fraction_reference_dose(\n" .
        "  plan_id," .
        "  fraction_group_number," .
        "  dose_reference_number," .
        "  constraint_weight," .
        "  delivery_warning_dose," .
        "  delivery_maximum_dose," .
        "  target_minimum_dose," .
        "  target_prescription_dose," .
        "  target_maximum_dose," .
        "  target_underdose_volume_fraction," .
        "  organ_at_risk_full_volume_dose," .
        "  organ_at_risk_limit_dose," .
        "  organ_at_risk_maximum_dose," .
        "  organ_at_risk_overdose_volume_fraction" .
        ") values (\n" .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?" .
        ")"
      );
      my $fdr_parms = {
        dose_reference_number =>
          "(300a,0070)[$i](300c,0050)[$j](300c,0051)",
        constraint_weight =>
          "(300a,0070)[$i](300c,0050)[$j](300a,0021)",
        delivery_warning_dose =>
          "(300a,0070)[$i](300c,0050)[$j](300a,0022)",
        delivery_maximum_dose =>
          "(300a,0070)[$i](300c,0050)[$j](300a,0023)",
        target_minimum_dose =>
          "(300a,0070)[$i](300c,0050)[$j](300a,0025)",
        target_prescription_dose =>
          "(300a,0070)[$i](300c,0050)[$j](300a,0026)",
        target_maximum_dose =>
          "(300a,0070)[$i](300c,0050)[$j](300a,0027)",
        target_underdose_volume_fraction =>
          "(300a,0070)[$i](300c,0050)[$j](300a,0028)",
        organ_at_risk_full_volume_dose =>
          "(300a,0070)[$i](300c,0050)[$j](300a,002a)",
        organ_at_risk_limit_dose =>
          "(300a,0070)[$i](300c,0050)[$j](300a,002b)",
        organ_at_risk_maximum_dose =>
          "(300a,0070)[$i](300c,0050)[$j](300a,002c)",
        organ_at_risk_overdose_volume_fraction =>
          "(300a,0070)[$i](300c,0050)[$j](300a,002d)",
      };
      my $ModList = {
      };
      my $parms = GetAttrs($ds, $fdr_parms, $ModList, $errors);
      unless(defined($parms->{dose_reference_number})){
         push(@$errors, "undefined dose_reference_number: " .
           $fdr_parms->{dose_reference_number});
         next reference_dose;
      }
      $ins_fdr->execute(
        $hist->{plan_id},
        $fraction_group_number,
        $parms->{dose_reference_number},
        $parms->{constraint_weight},
        $parms->{delivery_warning_dose},
        $parms->{delivery_maximum_dose},
        $parms->{target_minimum_dose},
        $parms->{target_prescription_dose},
        $parms->{target_maximum_dose},
        $parms->{target_underdose_volume_fraction},
        $parms->{organ_at_risk_full_volume_dose},
        $parms->{organ_at_risk_limit_dose},
        $parms->{organ_at_risk_maximum_dose},
        $parms->{organ_at_risk_overdose_volume_fraction}
      );
    }
    #    fraction_referenced_beams
    my $s3 = $ds->Substitutions("(300a,0070)[$i](300c,0004)[<0>](300c,0006)");
    reference_beam:
    for my $m3 (@{$s3->{list}}){
      my $j = $m3->[0];
      my $ins_frb = $db->prepare(
        "insert into fraction_reference_beam(\n" .
        "  plan_id,\n" .
        "  fraction_group_number,\n" .
        "  beam_number,\n" .
        "  beam_dose_specification_point,\n" .
        "  beam_dose,\n" .
        "  beam_dose_point_depth,\n" .
        "  beam_dose_point_equivalent_depth,\n" .
        "  beam_dose_point_ssd,\n" .
        "  beam_meterset\n" .
        ") values(\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $frb_parms = {
        beam_number =>
          "(300a,0070)[$i](300c,0004)[$j](300c,0006)",
        beam_dose_specification_point =>
          "(300a,0070)[$i](300c,0004)[$j](300a,0082)",
        beam_dose =>
          "(300a,0070)[$i](300c,0004)[$j](300a,0084)",
        beam_dose_point_depth =>
          "(300a,0070)[$i](300c,0004)[$j](300a,0088)",
        beam_dose_point_equivalent_depth =>
          "(300a,0070)[$i](300c,0004)[$j](300a,0089)",
        beam_dose_point_ssd =>
          "(300a,0070)[$i](300c,0004)[$j](300a,008a)",
        beam_meterset =>
          "(300a,0070)[$i](300c,0004)[$j](300a,0086)",
      };
      my $ModList = {
         beam_dose_specification_point => "MultiText",
      };
      my $parms = GetAttrs($ds, $frb_parms, $ModList, $errors);
      unless(defined($parms->{beam_number})){
        push(@$errors, "Undefined beam number: " . $frb_parms->{beam_number});
        next reference_beam;
      }
      $ins_frb->execute(
        $hist->{plan_id},
        $fraction_group_number,
        $parms->{beam_number},
        $parms->{beam_dose_specification_point},
        $parms->{beam_dose},
        $parms->{beam_dose_point_depth},
        $parms->{beam_dose_point_equivalent_depth},
        $parms->{beam_dose_point_ssd},
        $parms->{beam_meterset}
      );
    }
    #    fraction_reference_brachy
    my $s4 = $ds->Substitutions("(300a,0070)[$i](300c,000a)[<0>](300c,000c)");
    reference_brachy:
    for my $m4 (@{$s4->{list}}){
      my $j = $m4->[0];
      push(@$errors, "yikes - brachy references not yet implemented");
    }
  }
}
sub RtBeams{
  my($db, $ds, $id, $hist, $errors) = @_;
  #  Set up following tables:
  #    rt_beam
  #    beam_limiting_device
  #    image_referenced_from_beam
  #    planned_verification_images
  #    dose_referenced_from_beam
  #    beam_wedge
  #    beam_compensator
  #    beam_bolus
  #    beam_block
  #    beam_applicator
  #    beam_general_accessory
  #    beam_control_point
  #    control_point_referenced_dose
  #    control_point_dose_reference
  #    control_point_wedge_position
  #    control_point_bld_position

  #    rt_beam
  my $s = $ds->Substitutions("(300a,00b0)[<0>](300a,00c0)");
  beam:
  for my $m (@{$s->{list}}){
    my $i = $m->[0];
    my $ins_beam = $db->prepare(
      "insert into rt_beam(\n" .
      "  plan_id,\n" .
      "  beam_number,\n" .
      "  beam_name,\n" .
      "  beam_description,\n" .
      "  beam_type,\n" .
      "  radiation_type,\n" .
      "  high_dose_technique,\n" .
      "  treatement_machine_name,\n" .
      "  manufacturer,\n" .
      "  institution_name,\n" .
      "  institution_address,\n" .
      "  institution_department_name,\n" .
      "  manufacturers_model_name,\n" .
      "  device_serial_number,\n" .
      "  primary_dosimeter_unit,\n" .
      "  tolerance_table_number,\n" .
      "  source_axis_distance,\n" .
      "  patient_setup_number,\n" .
      "  treatment_delivery_type,\n" .
      "  number_of_wedges,\n" .
      "  number_of_compensators,\n" .
      "  total_compensator_tray_factor,\n" .
      "  number_of_boli,\n" .
      "  number_of_blocks,\n" .
      "  total_block_tray_factor,\n" .
      "  final_cumulative_meterset_weight,\n" .
      "  number_of_control_points\n" .
      ") values(\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?\n" .
      ")"
    );
    my $bm_parms = {
      beam_number =>
        "(300a,00b0)[$i](300a,00c0)",
      beam_name =>
        "(300a,00b0)[$i](300a,00c2)",
      beam_description =>
        "(300a,00b0)[$i](300a,00c3)",
      beam_type =>
        "(300a,00b0)[$i](300a,00c4)",
      radiation_type =>
        "(300a,00b0)[$i](300a,00c6)",
      high_dose_technique =>
        "(300a,00b0)[$i](300a,00c7)",
      treatement_machine_name =>
        "(300a,00b0)[$i](300a,00b2)",
      manufacturer =>
        "(300a,00b0)[$i](0008,0070)",
      institution_name =>
        "(300a,00b0)[$i](0008,0080)",
      institution_address =>
        "(300a,00b0)[$i](0008,0081)",
      institution_department_name =>
        "(300a,00b0)[$i](0008,1040)",
      manufacturers_model_name =>
        "(300a,00b0)[$i](0008,1090)",
      device_serial_number =>
        "(300a,00b0)[$i](0018,1000)",
      primary_dosimeter_unit =>
        "(300a,00b0)[$i](300a,00b3)",
      tolerance_table_number =>
        "(300a,00b0)[$i](300c,00a0)",
      source_axis_distance =>
        "(300a,00b0)[$i](300a,00b4)",
      patient_setup_number =>
        "(300a,00b0)[$i](300c,00ba)",
      treatment_delivery_type =>
        "(300a,00b0)[$i](300a,00ce)",
      number_of_wedges =>
        "(300a,00b0)[$i](300a,00d0)",
      number_of_compensators =>
        "(300a,00b0)[$i](300a,00e0)",
      total_compensator_tray_factor =>
        "(300a,00b0)[$i](300a,00e2)",
      number_of_boli =>
        "(300a,00b0)[$i](300a,00ed)",
      number_of_blocks =>
        "(300a,00b0)[$i](300a,00f0)",
      total_block_tray_factor =>
        "(300a,00b0)[$i](300a,00f2)",
      final_cumulative_meterset_weight =>
        "(300a,00b0)[$i](300a,010e)",
      number_of_control_points =>
        "(300a,00b0)[$i](300a,0110)",
    };
    my $ModList = {
    };
    my $parms = GetAttrs($ds, $bm_parms, $ModList, $errors);
    unless(defined $parms->{beam_number}){
      push(@$errors, "no beam_number $bm_parms->{beam_number}");
      next beam;
    }
    my $beam_number = $parms->{beam_number};
    $ins_beam->execute(
      $hist->{plan_id},
      $parms->{beam_number},
      $parms->{beam_name},
      $parms->{beam_description},
      $parms->{beam_type},
      $parms->{radiation_type},
      $parms->{high_dose_technique},
      $parms->{treatement_machine_name},
      $parms->{manufacturer},
      $parms->{institution_name},
      $parms->{institution_address},
      $parms->{institution_department_name},
      $parms->{manufacturers_model_name},
      $parms->{device_serial_number},
      $parms->{primary_dosimeter_unit},
      $parms->{tolerance_table_number},
      $parms->{source_axis_distance},
      $parms->{patient_setup_number},
      $parms->{treatment_delivery_type},
      $parms->{number_of_wedges},
      $parms->{number_of_compensators},
      $parms->{total_compensator_tray_factor},
      $parms->{number_of_boli},
      $parms->{number_of_blocks},
      $parms->{total_block_tray_factor},
      $parms->{final_cumulative_meterset_weight},
      $parms->{number_of_control_points}
    );
    #    beam_limiting_device
    beam_limiting_device:
    my $s1 = $ds->Substitutions("(300a,00b0)[$i](300a,00b6)[<0>](300a,00b8)");
    for my $m1 (@{$s1->{list}}){
      my $j = $m1->[0];
      my $ins_bld = $db->prepare(
        "insert into beam_limiting_device(\n" .
        "  plan_id,\n" .
        "  beam_number,\n" .
        "  bld_type,\n" .
        "  source_to_bld_distance,\n" .
        "  number_of_leaf_jaw_pairs,\n" .
        "  leaf_position_boundries\n" .
        ") values(\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $bld_parms = {
        bld_type => "(300a,00b0)[$i](300a,00b6)[$j](300a,00b8)",
        source_to_bld_distance => "(300a,00b0)[$i](300a,00b6)[$j](300a,00ba)",
        number_of_leaf_jaw_pairs =>
          "(300a,00b0)[$i](300a,00b6)[$j](300a,00bc)",
        leaf_position_boundries => "(300a,00b0)[$i](300a,00b6)[$j](300a,00be)",
      };
      my $ModList = {
        leaf_position_boundries => "MultiText",
      };
      my $parms = GetAttrs($ds, $bld_parms, $ModList, $errors);
      unless(defined $parms->{bld_type}){
        push(@$errors, "no bld_type $bld_parms->{bld_type}");
        next beam_limiting_device;
      }
      unless(defined $parms->{number_of_leaf_jaw_pairs}){
        if(
          $parms->{bld_type} eq "X" or
          $parms->{bld_type} eq "ASYMX" or
          $parms->{bld_type} eq "Y" or
          $parms->{bld_type} eq "ASYMY"
        ){ $parms->{number_of_leaf_jaw_pairs} = 1 }
      }
      $ins_bld->execute(
        $hist->{plan_id},
        $beam_number,
        $parms->{bld_type},
        $parms->{source_to_bld_distance},
        $parms->{number_of_leaf_jaw_pairs},
        $parms->{leaf_position_boundries}
      );
    }
    #    image_referenced_from_beam
    my $s2 = $ds->Substitutions("(300a,00b0)[$i](300c,0042)[<0>](0008,1155)");
    image_referenced_from_beam:
    for my $m2 (@{$s2->{list}}){
      my $j = $m2->[0];
      my $ins_irfb = $db->prepare(
        "insert into image_referenced_from_beam(\n" .
        "  plan_id,\n" .
        "  beam_number,\n" .
        "  sop_class_uid,\n" .
        "  sop_instance_uid,\n" .
        "  reference_image_number,\n" .
        "  start_cum_meterset_weight,\n" .
        "  end_cum_meterset_weight\n" .
        ") values (\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $irfb_parms = {
        sop_class_uid => "(300a,00b0)[$i](300c,0042)[$j](0008,1150)",
        sop_instance_uid => "(300a,00b0)[$i](300c,0042)[$j](0008,1155)",
        reference_image_number => "(300a,00b0)[$i](300c,0042)[$j](300a,00c8)",
        start_cum_meterset_weight =>
          "(300a,00b0)[$i](300c,0042)[$j](300c,0008)",
        end_cum_meterset_weight => "(300a,00b0)[$i](300c,0042)[$j](300c,0009)",
      };
      my $ModList = {
      };
      my $parms = GetAttrs($ds, $irfb_parms, $ModList, $errors);
      unless(defined $parms->{sop_instance_uid}){
        push(@$errors, "no sop_instance_uid $irfb_parms->{sop_instance_uid}");
        next image_referenced_from_beam;
      }
      unless(defined $parms->{sop_class_uid}){
        push(@$errors, "no sop_class_uid $irfb_parms->{sop_class_uid}");
        next image_referenced_from_beam;
      }
      unless(defined $parms->{reference_image_number}){
        push(@$errors,
          "no reference_image_number $irfb_parms->{reference_image_number}");
        next image_referenced_from_beam;
      }
      $ins_irfb->execute(
        $hist->{plan_id},
        $beam_number,
        $parms->{sop_class_uid},
        $parms->{sop_instance_uid},
        $parms->{reference_image_number},
        $parms->{start_cum_meterset_weight},
        $parms->{end_cum_meterset_weight}
      );
    }
    #    planned_verification_images
    my $s3 = $ds->Substitutions("(300a,00b0)[$i](300a,00ca)[<0>]");
    for my $m3 (@{$s3->{list}}){
      my $j = $m3->[0];
      my $ins_pvi = $db->prepare(
        "insert into planned_verification_images(\n" .
        "  plan_id,\n" .
        "  beam_number,\n" .
        "  start_cum_meterset_weight,\n" .
        "  meterset_exposure,\n" .
        "  end_cum_meterset_weight,\n" .
        "  rt_image_plane,\n" .
        "  xray_image_receptor_angle,\n" .
        "  rt_image_orientation,\n" .
        "  rt_image_position,\n" .
        "  rt_image_sid,\n" .
        "  image_device_specific_acquisition_params,\n" .
        "  referenced_reference_image_number\n" .
        ") values (\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $pvi_parms = {
        start_cum_meterset_weight =>
          "(300a,00b0)[$i](300a,00ca)[$j](300c,0008)",
        meterset_exposure =>
          "(300a,00b0)[$i](300a,00ca)[$j](3002,0032)",
        end_cum_meterset_weight =>
          "(300a,00b0)[$i](300a,00ca)[$j](300c,0009)",
        rt_image_plane =>
          "(300a,00b0)[$i](300a,00ca)[$j](3002,000c)",
        xray_image_receptor_angle =>
          "(300a,00b0)[$i](300a,00ca)[$j](3002,000e)",
        rt_image_orientation =>
          "(300a,00b0)[$i](300a,00ca)[$j](3002,0010)",
        rt_image_position =>
          "(300a,00b0)[$i](300a,00ca)[$j](3002,0012)",
        rt_image_sid =>
          "(300a,00b0)[$i](300a,00ca)[$j](3002,0026)",
        image_device_specific_acquisition_params =>
          "(300a,00b0)[$i](300a,00ca)[$j](300a,00cc)",
        referenced_reference_image_number =>
          "(300a,00b0)[$i](300a,00ca)[$j](300c,0007)"
      };
      my $ModList = {
         rt_image_orientation => "MultiText",
         rt_image_position => "MultiText",
      };
      my $parms = GetAttrs($ds, $pvi_parms, $ModList, $errors);
      $ins_pvi->execute(
        $hist->{plan_id},
        $beam_number,
        $parms->{start_cum_meterset_weight},
        $parms->{meterset_exposure},
        $parms->{end_cum_meterset_weight},
        $parms->{rt_image_plane},
        $parms->{xray_image_receptor_angle},
        $parms->{rt_image_orientation},
        $parms->{rt_image_position},
        $parms->{rt_image_sid},
        $parms->{image_device_specific_acquisition_params},
        $parms->{referenced_reference_image_number},
      );
    }
    #    dose_referenced_from_beam
    my $s4 = $ds->Substitutions("(300a,00b0)[$i](300c,0080)[<0>](0008,1155)");
    for my $m4 (@{$s4->{list}}){
      my $j = $m4->[0];
      my $ins_drfb = $db->prepare(
        "insert into dose_referenced_from_beam(\n" .
        "  plan_id,\n" .
        "  beam_number,\n" .
        "  sop_class_uid,\n" .
        "  sop_instance_uid\n" .
        ") values (\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $drfb_parms = {
        sop_class_uid => "(300a,00b0)[$i](300c,0080)[$j](0008,1155)",
        sop_instance_uid => "(300a,00b0)[$i](300c,0080)[$j](0008,1150)"
      };
      my $ModList = {
      };
      my $parms = GetAttrs($ds, $drfb_parms, $ModList, $errors);
      $ins_drfb->execute(
        $hist->{plan_id},
        $beam_number,
        $parms->{sop_class_uid},
        $parms->{sop_instance_uid}
      );
    }
    #    beam_wedge
    my $s5 = $ds->Substitutions("(300a,00b0)[$i](300a,00d1)[<0>](300a,00d2)");
    for my $m5 (@{$s5->{list}}){
      my $j = $m5->[0];
      my $ins_bw = $db->prepare(
        "insert into beam_wedge(\n" .
        "  plan_id,\n" .
        "  beam_number,\n" .
        "  wedge_number,\n" .
        "  wedge_type,\n" .
        "  wedge_id,\n" .
        "  wedge_accessory_code,\n" .
        "  wedge_angle,\n" .
        "  wedge_factor,\n" .
        "  wedge_orientation,\n" .
        "  source_to_wedge_tray_distance\n" .
        ") values (\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $bw_parms = {
        wedge_number =>
          "(300a,00b0)[$i](300a,00d1)[$j](300a,00d2)",
        wedge_type =>
          "(300a,00b0)[$i](300a,00d1)[$j](300a,00d3)",
        wedge_id =>
          "(300a,00b0)[$i](300a,00d1)[$j](300a,00d4)",
        wedge_accessory_code =>
          "(300a,00b0)[$i](300a,00d1)[$j](300a,00f9)",
        wedge_angle =>
          "(300a,00b0)[$i](300a,00d1)[$j](300a,00d5)",
        wedge_factor =>
          "(300a,00b0)[$i](300a,00d1)[$j](300a,00d6)",
        wedge_orientation =>
          "(300a,00b0)[$i](300a,00d1)[$j](300a,00d8)",
        source_to_wedge_tray_distance =>
          "(300a,00b0)[$i](300a,00d1)[$j](300a,00da)",
      };
      my $ModList = {
      };
      my $parms = GetAttrs($ds, $bw_parms, $ModList, $errors);
      $ins_bw->execute(
        $hist->{plan_id},
        $beam_number,
        $parms->{wedge_number},
        $parms->{wedge_type},
        $parms->{wedge_id},
        $parms->{wedge_accessory_code},
        $parms->{wedge_angle},
        $parms->{wedge_factor},
        $parms->{wedge_orientation},
        $parms->{source_to_wedge_tray_distance}
      );
    }
    #    beam_compensator
    my $s6 = $ds->Substitutions("(300a,00b0)[$i](300a,00e3)[<0>](300a,00e4)");
    for my $m6 (@{$s6->{list}}){
      my $j = $m6->[0];
      my $ins_bc = $db->prepare(
        "insert into beam_compensator(\n" .
        "  plan_id,\n" .
        "  beam_number,\n" .
        "  compensator_number,\n" .
        "  compensator_type,\n" .
        "  compensator_description,\n" .
        "  material_id,\n" .
        "  compensator_id,\n" .
        "  compensator_accessory_code,\n" .
        "  source_to_compensator_tray_distance,\n" .
        "  compensator_divergence,\n" .
        "  compensator_mounting_position,\n" .
        "  compensator_rows,\n" .
        "  compensator_cols,\n" .
        "  compensator_pixel_spacing,\n" .
        "  compensator_position,\n" .
        "  compensator_transmission_data,\n" .
        "  compensator_thickness_data,\n" .
        "  source_to_compensator_distance\n" .
        ") values (\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $bc_parms = {
        compensator_number =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,00e4)",
        compensator_type =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,00ee)",
        compensator_description =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,02eb)",
        material_id =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,00e1)",
        compensator_id =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,00e5)",
        compensator_accessory_code =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,00f9)",
        source_to_compensator_tray_distance =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,00e6)",
        compensator_divergence =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,02e0)",
        compensator_mounting_position =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,02e1)",
        compensator_rows =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,00e7)",
        compensator_cols =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,00e8)",
        compensator_pixel_spacing =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,00e9)",
        compensator_position =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,00ea)",
        compensator_transmission_data =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,00eb)",
        compensator_thickness_data =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,00ec)",
        source_to_compensator_distance =>
          "(300a,00b0)[$i](300a,00e3)[$j](300a,02e2)",
      };
      my $ModList = {
        compensator_pixel_spacing => "MultiText",
        compensator_position => "MultiText",
        compensator_transmission_data => "MultiText",
        compensator_thickness_data => "MultiText",
        source_to_compensator_distance => "MultiText",
      };
      my $parms = GetAttrs($ds, $bc_parms, $ModList, $errors);
      $ins_bc->execute(
        $hist->{plan_id},
        $beam_number,
        $parms->{compensator_number},
        $parms->{compensator_type},
        $parms->{compensator_description},
        $parms->{material_id},
        $parms->{compensator_id},
        $parms->{compensator_accessory_code},
        $parms->{source_to_compensator_tray_distance},
        $parms->{compensator_divergence},
        $parms->{compensator_mounting_position},
        $parms->{compensator_rows},
        $parms->{compensator_cols},
        $parms->{compensator_pixel_spacing},
        $parms->{compensator_position},
        $parms->{compensator_transmission_data},
        $parms->{compensator_thickness_data},
        $parms->{source_to_compensator_distance}
      );
    }
    #    beam_bolus
    my $s7 = $ds->Substitutions("(300a,00b0)[$i](300c,00b0)[<0>](3006,0084)");
    for my $m7 (@{$s7->{list}}){
      my $j = $m7->[0];
      my $ins_bb = $db->prepare(
        "insert into beam_bolus(\n" .
        "  plan_id,\n" .
        "  beam_number,\n" .
        "  referenced_roi_number,\n" .
        "  bolus_id,\n" .
        "  bolus_accessory_code,\n" .
        "  bolus_description\n" .
        ") values (\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $bb_parms = {
        referenced_roi_number =>
          "(300a,00b0)[$i](300c,00b0)[$j](3006,0084)",
        bolus_id =>
          "(300a,00b0)[$i](300c,00b0)[$j](300a,00dc)",
        bolus_accessory_code =>
          "(300a,00b0)[$i](300c,00b0)[$j](300a,00f9)",
        bolus_description =>
          "(300a,00b0)[$i](300c,00b0)[$j](300a,00dd)"
      };
      my $ModList = {
      };
      my $parms = GetAttrs($ds, $bb_parms, $ModList, $errors);
      $ins_bb->execute(
        $hist->{plan_id},
        $beam_number,
        $parms->{referenced_roi_number},
        $parms->{bolus_id},
        $parms->{bolus_accessory_code},
        $parms->{bolus_description}
      );
    }
    #    beam_block
    my $s8 = $ds->Substitutions("(300a,00b0)[$i](300a,00f4)[<0>](300a,00fc)");
    for my $m8 (@{$s8->{list}}){
      my $j = $m8->[0];
      my $ins_bbl = $db->prepare(
        "insert into beam_block(\n" .
        "  plan_id,\n" .
        "  beam_number,\n" .
        "  block_number,\n" .
        "  block_tray_id,\n" .
        "  block_accessory_code,\n" .
        "  source_to_block_tray_distance,\n" .
        "  block_type,\n" .
        "  block_divergence,\n" .
        "  block_mounting_position,\n" .
        "  block_name,\n" .
        "  material_id,\n" .
        "  block_thickness,\n" .
        "  block_transmission,\n" .
        "  block_number_of_points,\n" .
        "  block_data\n" .
        ") values (\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $bbl_parms = {
        block_number =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,00fc)",
        block_tray_id =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,00f5)",
        block_accessory_code =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,00f9)",
        source_to_block_tray_distance =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,00f6)",
        block_type =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,00f8)",
        block_divergence =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,00fa)",
        block_mounting_position =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,00fb)",
        block_name =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,00fe)",
        material_id =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,00e1)",
        block_thickness =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,0100)",
        block_transmission =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,0102)",
        block_number_of_points =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,0104)",
        block_data =>
          "(300a,00b0)[$i](300a,00f4)[$j](300a,0106)",
      };
      my $ModList = {
        block_data => "MultiText",
      };
      my $parms = GetAttrs($ds, $bbl_parms, $ModList, $errors);
      $ins_bbl->execute(
        $hist->{plan_id},
        $beam_number,
        $parms->{block_number},
        $parms->{block_tray_id},
        $parms->{block_accessory_code},
        $parms->{source_to_block_tray_distance},
        $parms->{block_type},
        $parms->{block_divergence},
        $parms->{block_mounting_position},
        $parms->{block_name},
        $parms->{material_id},
        $parms->{block_thickness},
        $parms->{block_transmission},
        $parms->{block_number_of_points},
        $parms->{block_data}
      );
    };
    #    beam_applicator
    my $s9 = $ds->Substitutions("(300a,00b0)[$i](300a,0107)[<0>](300a,0108)");
    for my $m9 (@{$s9->{list}}){
      my $j = $m9->[0];
      my $ins_bi = $db->prepare(
        "insert into beam_applicator(\n" .
        "  plan_id,\n" .
        "  beam_number,\n" .
        "  applicator_id,\n" .
        "  applicator_accessory_code,\n" .
        "  applicator_type,\n" .
        "  applicator_description\n" .
        ") values(\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $bi_parms = {
        applicator_id =>
          "(300a,00b0)[$i](300a,0107)[$j](300a,0108)",
        applicator_accessory_code =>
          "(300a,00b0)[$i](300a,0107)[$j](300a,00f9)",
        applicator_type =>
          "(300a,00b0)[$i](300a,0107)[$j](300a,0109)",
        applicator_description =>
          "(300a,00b0)[$i](300a,0107)[$j](300a,010a)",
      };
      my $ModList = {
      };
      my $parms = GetAttrs($ds, $bi_parms, $ModList, $errors);
      $ins_bi->execute(
        $hist->{plan_id},
        $beam_number,
        $parms->{applicator_id},
        $parms->{applicator_accessory_code},
        $parms->{applicator_type},
        $parms->{applicator_description}
      );
    }
    #    beam_general_accessory
    my $s10 = $ds->Substitutions("(300a,00b0)[$i](300a,0420)[<0>](300a,0424)");
    beam_general_accessory:
    for my $m10 (@{$s10->{list}}){
      my $j = $m10->[0];
      my $ins_bga = $db->prepare(
        "insert into beam_general_accessory(\n" .
        "  plan_id," .
        "  beam_number," .
        "  general_accessory_number," .
        "  general_accessory_id text," .
        "  general_accessory_description," .
        "  general_accessory_type," .
        "  general_accessory_code" .
        ") values (\n" .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?," .
        "  ?" .
        ")"
      );
      my $bga_parms = {
        general_accessory_number =>
          "(300a,00b0)[$i](300a,0420)[$j](300a,0424)",
        general_accessory_id=>
          "(300a,00b0)[$i](300a,0420)[$j](300a,0421)",
        general_accessory_description =>
          "(300a,00b0)[$i](300a,0420)[$j](300a,0422)",
        general_accessory_type =>
          "(300a,00b0)[$i](300a,0420)[$j](300a,0423)",
        general_accessory_code =>
          "(300a,00b0)[$i](300a,0420)[$j](300a,00f9)",
      };
      my $ModList = {
      };
      my $parms = GetAttrs($ds, $bga_parms, $ModList, $errors);
      unless(defined $parms->{general_accessory_code}){
        push(@$errors, "general accessory_code (beam $i) undefined\n");
        next beam_general_accessory;
      }
      $ins_bga->execute(
        $hist->{plan_id},
        $beam_number,
        $parms->{general_accessory_number},
        $parms->{general_accessory_id},
        $parms->{general_accessory_description},
        $parms->{general_accessory_type},
        $parms->{general_accessory_code}
      );
    }
    #    beam_control_point
    my $s11 = $ds->Substitutions("(300a,00b0)[$i](300a,0111)[<0>](300a,0112)");
    for my $m11 (@{$s11->{list}}){
      my $j = $m11->[0];
      my $ins_bcp = $db->prepare(
        "insert into beam_control_point(\n" .
        "  plan_id,\n" .
        "  beam_number,\n" .
        "  control_point_index,\n" .
        "  cumulative_meterset_weight,\n" .
        "  nominal_beam_energy,\n" .
        "  dose_rate_set,\n" .
        "  gantry_angle,\n" .
        "  gantry_rotation_direction,\n" .
        "  gantry_pitch_angle,\n" .
        "  gantry_pitch_rotation_direction,\n" .
        "  beam_limiting_device_angle,\n" .
        "  beam_limiting_device_rotation_direction,\n" .
        "  patient_support_angle,\n" .
        "  patient_support_rotation_direction,\n" .
        "  table_top_eccentric_axis_distance,\n" .
        "  table_top_eccentric_angle,\n" .
        "  table_top_eccentric_rotation_direction,\n" .
        "  table_top_pitch_angle,\n" .
        "  table_top_pitch_rotation_direction,\n" .
        "  table_top_roll_angle,\n" .
        "  table_top_roll_rotation_direction,\n" .
        "  table_top_vertical_position,\n" .
        "  table_top_longitudinal_position,\n" .
        "  table_top_lateral_position,\n" .
        "  isocenter_position,\n" .
        "  surface_entry_point,\n" .
        "  source_to_surface_distance\n" .
        ") values (\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?,\n" .
        "  ?\n" .
        ")"
      );
      my $bcp_parms = {
        control_point_index =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0112)",
        cumulative_meterset_weight =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0134)",
        nominal_beam_energy =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0114)",
        dose_rate_set =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0115)",
        gantry_angle =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,011e)",
        gantry_rotation_direction =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,011f)",
        gantry_pitch_angle =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,014a)",
        gantry_pitch_rotation_direction =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,014c)",
        beam_limiting_device_angle =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0120)",
        beam_limiting_device_rotation_direction =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0121)",
        patient_support_angle =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0122)",
        patient_support_rotation_direction =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0123)",
        table_top_eccentric_axis_distance =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0124)",
        table_top_eccentric_angle =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0125)",
        table_top_eccentric_rotation_direction =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0126)",
        table_top_pitch_angle =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0140)",
        table_top_pitch_rotation_direction =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0142)",
        table_top_roll_angle =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0144)",
        table_top_roll_rotation_direction =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0146)",
        table_top_vertical_position =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0128)",
        table_top_longitudinal_position =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0129)",
        table_top_lateral_position =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,012a)",
        isocenter_position =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,012c)",
        surface_entry_point =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,012e)",
        source_to_surface_distance =>
          "(300a,00b0)[$i](300a,0111)[$j](300a,0130)",
      };
      my $ModList = {
        isocenter_position => "MultiText",
        surface_entry_point => "MultiText",
      };
      my $parms = GetAttrs($ds, $bcp_parms, $ModList, $errors);
      my $control_point_index = $parms->{control_point_index};
      $ins_bcp->execute(
        $hist->{plan_id},
        $beam_number,
        $parms->{control_point_index},
        $parms->{cumulative_meterset_weight},
        $parms->{nominal_beam_energy},
        $parms->{dose_rate_set},
        $parms->{gantry_angle},
        $parms->{gantry_rotation_direction},
        $parms->{gantry_pitch_angle},
        $parms->{gantry_pitch_rotation_direction},
        $parms->{beam_limiting_device_angle},
        $parms->{beam_limiting_device_rotation_direction},
        $parms->{patient_support_angle},
        $parms->{patient_support_rotation_direction},
        $parms->{table_top_eccentric_axis_distance},
        $parms->{table_top_eccentric_angle},
        $parms->{table_top_eccentric_rotation_direction},
        $parms->{table_top_pitch_angle},
        $parms->{table_top_pitch_rotation_direction},
        $parms->{table_top_roll_angle},
        $parms->{table_top_roll_rotation_direction},
        $parms->{table_top_vertical_position},
        $parms->{table_top_longitudinal_position},
        $parms->{table_top_lateral_position},
        $parms->{isocenter_position},
        $parms->{surface_entry_point},
        $parms->{source_to_surface_distance},
      );
      #    control_point_reference_dose
      my $s12 = $ds->Substitutions(
        "(300a,00b0)[$i](300a,0111)[$j](300c,0050)[<0>](300c,0051)");
      for my $m12 (@{$s12->{list}}){
        my $k = $m12->[0];
        my $ins_cprd = $db->prepare(
          "insert into control_point_reference_dose(\n" .
          "  plan_id,\n" .
          "  beam_number,\n" .
          "  control_point_index,\n" .
          "  referenced_dose_reference_number,\n" .
          "  cumulative_dose_ref_coefficent\n" .
          ") values (\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?\n" .
          ")"
        );
        my $cprd_parms = {
          referenced_dose_reference_number =>
            "(300a,00b0)[$i](300a,0111)[$j](300c,0050)[$k](300c,0051)",
          cumulative_dose_ref_coefficent =>
            "(300a,00b0)[$i](300a,0111)[$j](300c,0050)[$k](300a,010c)",
        };
        my $ModList = {
        };
        my $parms = GetAttrs($ds, $cprd_parms, $ModList, $errors);
        $ins_cprd->execute(
          $hist->{plan_id},
          $beam_number,
          $control_point_index,
          $parms->{referenced_dose_reference_number},
          $parms->{cumulative_dose_ref_coefficent}
        );
      }
      #    control_point_dose_reference
      my $s13 = $ds->Substitutions(
        "(300a,00b0)[$i](300a,0111)[$j](300a,0080)[<0>](0008,1155)");
      for my $m13 (@{$s13->{list}}){
        my $k = $m13->[0];
        my $ins_cpdr = $db->prepare(
          "insert into control_point_dose_reference(\n" .
          "  plan_id,\n" .
          "  beam_number,\n" .
          "  control_point_index,\n" .
          "  sop_class_uid,\n" .
          "  sop_instance_uid\n" .
          ") values (\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?\n" .
          ")"
        );
        my $cpdr_parms = {
          sop_class_uid =>
            "(300a,00b0)[$i](300a,0111)[$j](300a,0080)[$k](0008,1150)",
          sop_instance_uid =>
            "(300a,00b0)[$i](300a,0111)[$j](300a,0080)[$k](0008,1155)"
        };
        my $ModList = {
        };
        my $parms = GetAttrs($ds, $cpdr_parms, $ModList, $errors);
        $ins_cpdr->execute(
          $hist->{plan_id},
          $beam_number,
          $control_point_index,
          $parms->{sop_class_uid text},
          $parms->{sop_instance_uid text}
        );
      }
      #    control_point_wedge_position
      my $s14 = $ds->Substitutions(
        "(300a,00b0)[$i](300a,0111)[$j](300a,0116)[<0>](300c,00c0)");
      for my $m14 (@{$s14->{list}}){
        my $k = $m14->[0];
        my $ins_cpwp = $db->prepare(
          "insert into control_point_wedge_position(\n" .
          "  plan_id,\n" .
          "  beam_number,\n" .
          "  control_point_index,\n" .
          "  wedge_number,\n" .
          "  wedge_position\n" .
          ") values (\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?\n" .
          ")"
        );
        my $cpwp_parms = {
          wedge_number =>
            "(300a,00b0)[$i](300a,0111)[$j](300a,0116)[$k](300c,00c0)",
          wedge_position =>
            "(300a,00b0)[$i](300a,0111)[$j](300a,0116)[$k](300a,0118)",
        };
        my $ModList = {
        };
        my $parms = GetAttrs($ds, $cpwp_parms, $ModList, $errors);
        $ins_cpwp->execute(
          $hist->{plan_id},
          $beam_number,
          $control_point_index,
          $parms->{wedge_number},
          $parms->{wedge_position}
        );
      }
      #    control_point_bld_position
      my $s15 = $ds->Substitutions(
        "(300a,00b0)[$i](300a,0111)[$j](300a,011a)[<0>](300a,00b8)");
      for my $m15 (@{$s15->{list}}){
        my $k = $m15->[0];
        my $ins_cpbp = $db->prepare(
          "insert into control_point_bld_position(\n" .
          "  plan_id,\n" .
          "  beam_number,\n" .
          "  control_point_index,\n" .
          "  bld_type,\n" .
          "  leaf_jaw_positions\n" .
          ") values (\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?,\n" .
          "  ?\n" .
          ")"
        );
        my $cpbp_parms = {
          bld_type =>
            "(300a,00b0)[$i](300a,0111)[$j](300a,011a)[$k](300a,00b8)",
          leaf_jaw_positions =>
            "(300a,00b0)[$i](300a,0111)[$j](300a,011a)[$k](300a,011c)",
        };
        my $ModList = {
          leaf_jaw_positions => "MultiText",
        };
        my $parms = GetAttrs($ds, $cpbp_parms, $ModList, $errors);
        $ins_cpbp->execute(
          $hist->{plan_id},
          $beam_number,
          $control_point_index,
          $parms->{bld_type},
          $parms->{leaf_jaw_positions}
        );
      }
    }
  }
  #print "RtBeams Module not yet implemented\n";
}
sub SpatialRegistration{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "Spatial Registration Module not yet implemented\n";
}
sub SpatialFiducials{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "Spatial Fiducials Module not yet implemented\n";
}
sub DeformableSpatialRegistration{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "Deformable Spatial Registration Module not yet implemented\n";
}
sub Segmentation{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "Segmentation Module not yet implemented\n";
}
sub SurfaceSegmentation{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "Surface Segmentation Module not yet implemented\n";
}
sub RtBrachy{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "Message: RtBrachy Module not yet implemented\n";
}
sub CRImage{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "CRImage Module not yet implemented\n";
}
sub DXImage{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "DXImage Module not yet implemented\n";
}
sub CTImage{
  my($db, $ds, $id, $hist, $errors) = @_;
  my $ct_parms = {
   kvp => "(0018,0060)",
   instance_number => "(0020,0013)",
   scan_options => "(0018,0022)",
   data_collection_diameter => "(0018,0090)",
   reconstruction_diameter => "(0018,1100)",
   dist_source_to_pat => "(0018,1111)",
   dist_source_to_detect => "(0018,1110)",
   gantry_tilt => "(0018,1120)",
   rotation_dir => "(0018,1140)",
   exposure_time  => "(0018,1150)",
   exposure  => "(0018,1155)",
   xray_tube_current  => "(0018,1151)",
   filter_type  => "(0018,1160)",
   generator_power  => "(0018,1170)",
   convolution_kernal  => "(0018,1210)",
   table_feed_per_rot  => "(0018,9310)",
  };
  my $ModList = {
    scan_options => "MultiText",
    convolution_kernal => "MultiText",
  };
  my $parms = GetAttrs($ds, $ct_parms, $ModList, $errors);
  my $ins_ct_img = $db->prepare(
    "insert into file_ct_image(\n" .
    "  file_id, kvp, instance_number,\n" .
    "  scan_options, data_collection_diameter, reconstruction_diameter,\n" .
    "  dist_source_to_pat, dist_source_to_detect,\n" .
    "  gantry_tilt, rotation_dir, exposure_time, exposure,\n" .
    "  xray_tube_current, filter_type, generator_power,\n" .
    "  convolution_kernal, table_feed_per_rot\n" .
    ") values (\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?,\n" .
    "  ?, ?, ?, ?,\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?\n" .
    ");"
  );
  $ins_ct_img->execute(
    $id, $parms->{kvp}, $parms->{instance_number},
    $parms->{scan_options}, $parms->{data_collection_diameter},
      $parms->{reconstruction_diameter},
    $parms->{dist_source_to_pat}, $parms->{dist_source_to_detect},
    $parms->{gantry_tilt}, $parms->{rotation_dir},
      $parms->{exposure_time}, $parms->{exposure},
    $parms->{xray_tube_current}, $parms->{filter_type},
      $parms->{generator_power},
    $parms->{convolution_kernal}, $parms->{table_feed_per_rot}
  );
}
sub RTDose{
  my($db, $ds, $id, $hist, $errors) = @_;
  my $image_id = $hist->{image_id};
  my $rt_dose_parms = {
    dose_units => "(3004,0002)",
    dose_type => "(3004,0004)",
    dose_instance_number => "(0020,0013)",
    dose_comment => "(3004,0006)",
    normalization_point => "(3004,0008)",
    dose_summation_type => "(3004,000a)",
    referenced_plan_class => "(300c,0002)[0](0008,1150)",
    referenced_plan_uid => "(300c,0002)[0](0008,1155)",
    tissue_heterogeneity => "(3004,0014)",
  };
  my $ModList = {
    tissue_heterogeneity => "MultiText",
    normalization_point => "MultiText",
  };
  my $parms = GetAttrs($ds, $rt_dose_parms, $ModList, $errors);
  my $ins_rt_dose = $db->prepare(
    "insert into rt_dose\n" .
    "  (rt_dose_units, rt_dose_type, rt_dose_instance_number,\n" .
    "   rt_dose_comment, rt_dose_normalization_point,\n" .
    "   rt_dose_summation_type, rt_dose_referenced_plan_class,\n" .
    "   rt_dose_referenced_plan_uid, rt_dose_tissue_heterogeneity)\n" .
    "values\n" .
    "  (?, ?, ?,\n" .
    "   ?, ?,\n" .
    "   ?, ?,\n" .
    "   ?, ?)"
  );
  $ins_rt_dose->execute(
    $parms->{dose_units},
    $parms->{dose_type},
    $parms->{dose_instance_number},
    $parms->{dose_comment},
    $parms->{normalizaton_point},
    $parms->{dose_summation_type},
    $parms->{referenced_plan_class},
    $parms->{referenced_plan_uid},
    $parms->{tissue_heterogeneity}
  );
  my $get_dose_id = $db->prepare(
    "select currval('rt_dose_rt_dose_id_seq') as\n" .
    "  rt_dose_id");
  $get_dose_id->execute();
  my $h = $get_dose_id->fetchrow_hashref();
  $get_dose_id->finish();
  my $dose_id = $h->{rt_dose_id};
  $hist->{rt_dose_id} = $dose_id;
  my $ins_dose_file = $db->prepare(
    "insert into file_dose(rt_dose_id, file_id) values (?, ?)");
  $ins_dose_file->execute($dose_id, $id);
  my $dose_img_parms = {
    gfov => "(3004,000c)",
    scaling => "(3004,000e)",
  };
  $ModList = {
    gfov => "MultiText",
  };
  my $pix = $ds->Get("(7fe0,0010)");
  if(defined $pix){
    $parms = GetAttrs($ds, $dose_img_parms, $ModList, $errors);
    my $ins_dose_img = $db->prepare(
      "insert into rt_dose_image(\n" .
      " rt_dose_id, image_id,\n" .
      " rt_dose_grid_frame_offset_vector, rt_dose_grid_scaling\n" .
      ") values (\n" .
      " ?, ?,\n" .
      " ?, ?\n" .
      ")"
    );
    $ins_dose_img->execute(
      $dose_id, $image_id,
      $parms->{gfov}, $parms->{scaling});
  }
}
sub RTDvh{
  my($db, $ds, $id, $hist, $errors) = @_;
  my $rt_dvh_list = $ds->Search("(3004,0050)[<0>](3004,0002)");
  unless(
    defined($rt_dvh_list) && ref($rt_dvh_list) eq "ARRAY" &&
    $#{$rt_dvh_list} >= 0
  ){ return }
  my $dvh_image_parms = {
    dvh_normalization_point => "(3004,0040)",
    dvh_normalization_value => "(3004,0042)",
    referenced_struct_class => "(300c,0060)[0](0008,1150)",
    referenced_struct_uid => "(300c,0060)[0](0008,1155)",
  };
  my $ModList = {
    dvh_normalization_point => "MultiText",
  };
  my $parms = GetAttrs($ds, $dvh_image_parms, $ModList, $errors);
  my $dvh_s = $ds->Get("(3005,\"ITC_DVH_Computation\",50)");
  unless(defined($dvh_s)){
    $dvh_s = "Unknown";
    my $series_desc = $ds->Get("(0008,103e)");
    if(defined $series_desc){
      $dvh_s = $series_desc;
    }
  }
  my $ins_dvh = $db->prepare(
    "insert into rt_dvh(\n" .
    "  rt_dvh_referenced_ss_class, rt_dvh_source,\n" .
    "  rt_dvh_referenced_ss_uid, rt_dvh_normalization_point,\n" .
    "  rt_dvh_normalization_value)\n" .
    "values (\n" .
    "  ?, ?, ?, ?, ?)"
  );
  $ins_dvh->execute(
     $parms->{referenced_struct_class},
     $dvh_s,
     $parms->{referenced_struct_uid},
     $parms->{dvh_normalization_point},
     $parms->{dvh_normalization_value}
  );
  my $get_dvh_id = $db->prepare(
    "select currval('rt_dvh_rt_dvh_id_seq') as\n" .
    "  rt_dvh_id");
  $get_dvh_id->execute();
  my $h = $get_dvh_id->fetchrow_hashref();
  my $rt_dvh_id = $h->{rt_dvh_id};
  $get_dvh_id->finish();
  my $ins_rt_dvh_rt_dose = $db->prepare(
    "insert into rt_dvh_rt_dose(rt_dose_id, rt_dvh_id) values (?, ?)");
  $ins_rt_dvh_rt_dose->execute($hist->{rt_dose_id}, $rt_dvh_id);
#  my $rt_dvh_list = $ds->Search("(3004,0050)[<0>](3004,0002)");
  if(defined($rt_dvh_list) && ref($rt_dvh_list) eq "ARRAY"){
    for my $i (@{$rt_dvh_list}){
      my $dvh_i = $i->[0];
      my $dvh_dvh_parms = {
        dvh_type => "(3004,0050)[$dvh_i](3004,0001)",
        dose_units => "(3004,0050)[$dvh_i](3004,0002)",
        dose_type => "(3004,0050)[$dvh_i](3004,0004)",
        dose_scaling => "(3004,0050)[$dvh_i](3004,0052)",
        dose_volume_units => "(3004,0050)[$dvh_i](3004,0054)",
        number_of_bins => "(3004,0050)[$dvh_i](3004,0056)",
        dvh_data => "(3004,0050)[$dvh_i](3004,0058)",
        minimum_dose => "(3004,0050)[$dvh_i](3004,0070)",
        maximum_dose => "(3004,0050)[$dvh_i](3004,0072)",
        mean_dose => "(3004,0050)[$dvh_i](3004,0074)",
      };
      $ModList = {
        dvh_data => "MultiText",
      };
      $parms = GetAttrs($ds, $dvh_dvh_parms, $ModList, $errors);
      my $sni = "(3004,0050)[$dvh_i](3005,\"ITC_for_RTOG_Conversion\",26)";
      my $mni = "(3004,0050)[$dvh_i](3005,\"ITC_for_RTOG_Conversion\",28)";
      my $pni = "(3004,0050)[$dvh_i](3005,\"ITC_for_RTOG_Conversion\",2a)";
      my $pdi = "(3004,0050)[$dvh_i](3005,\"ITC_for_RTOG_Conversion\",2c)";
      my $ari = "(3004,0050)[$dvh_i](3005,\"ITC_for_RTOG_Conversion\",2e)";
      my $pri = "(3004,0050)[$dvh_i](3005,\"ITC_for_RTOG_Conversion\",30)";
      my $simple_name = $ds->Get($sni);
      my $match_name = $ds->Get($mni);
      my $plan_name = $ds->Get($pni);
      my $plan_desc = $ds->Get($pdi);
      my $arm = $ds->Get($ari);
      my $prescription = $ds->Get($pri);
      my $shet = $ds->Get(
        "(3004,0050)[$dvh_i](3005,\"ITC_DVH_Computation\",01)");
      my $dsi = $ds->Get(
        "(3004,0050)[$dvh_i](3005,\"ITC_DVH_Computation\",02)");
      my $dsm = $ds->Get(
        "(3004,0050)[$dvh_i](3005,\"ITC_DVH_Computation\",03)");
      my $dsmn = $ds->Get(
        "(3004,0050)[$dvh_i](3005,\"ITC_DVH_Computation\",04)");
      my $ref_dose_grid_class = $ds->Get("(3004,0050)[$dvh_i]" .
        "(3005,\"ITC_DVH_Computation\",05)[0](0008,1150)");
      my $ref_dose_grid_id = $ds->Get("(3004,0050)[$dvh_i]" .
        "(3005,\"ITC_DVH_Computation\",05)[0](0008,1155)");
#      if(defined $prescription){
#        unless($prescription == int $prescription){
#          print STDERR "prescription ($prescription) isn't int\n";
#          $prescription = int $prescription;
#        }
#      }
      if(defined $arm){
        unless($arm == int $arm){
          print STDERR "arm ($arm) isn't int\n";
          $arm = int $arm;
        }
      }
      my $ins_rt_dvh_dvh = $db->prepare(
        "insert into rt_dvh_dvh(\n" .
        "  rt_dvh_id,\n" .
        "  rt_dvh_dvh_type,\n" .
        "  rt_dvh_dvh_dose_units,\n" .
        "  rt_dvh_dvh_dose_type,\n" .
        "  rt_dvh_dvh_roi_alt_name,\n" .
        "  rt_dvh_dvh_roi_alt_desc,\n" .
        "  rt_dvh_dvh_plan_id,\n" .
        "  rt_dvh_dvh_plan_desc,\n" .
        "  rt_dvh_dvh_arm,\n" .
        "  rt_dvh_dvh_prescription,\n" .
        "  rt_dvh_dvh_dose_scaling,\n" .
        "  rt_dvh_dvh_dose_volume_units,\n" .
        "  rt_dvh_dvh_dose_number_of_bins,\n" .
        "  rt_dvh_dvh_minimum_dose,\n" .
        "  rt_dvh_dvh_maximum_dose,\n" .
        "  rt_dvh_dvh_mean_dose,\n" .
        "  rt_dvh_dvh_text_data,\n" .
        "  rt_dvh_dvh_specified_heterogeneity,\n" .
        "  rt_dvh_dvh_dose_summation_id,\n" .
        "  rt_dvh_dvh_dose_manufacturer,\n" .
        "  rt_dvh_dvh_dose_model_name,\n" .
        "  rt_dvh_dvh_referenced_dose_grid_class,\n" .
        "  rt_dvh_dvh_referenced_dose_grid_uid\n" .
        ") values (\n" .
        "  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?," .
        "  ?, ?, ?, ?, ?, ?\n" .
        ")"
      );
      $ins_rt_dvh_dvh->execute(
        $rt_dvh_id,
        $parms->{dvh_type},
        $parms->{dose_units},
        $parms->{dose_type},
        $simple_name,
        $match_name,
        $plan_name,
        $plan_desc,
        $arm,
        $prescription,
        $parms->{dose_scaling},
        $parms->{dose_volume_units},
        $parms->{number_of_bins},
        $parms->{minimum_dose},
        $parms->{maximum_dose},
        $parms->{mean_dose},
        $parms->{dvh_data},
        $shet,
        $dsi,
        $dsm,
        $dsmn,
        $ref_dose_grid_class,
        $ref_dose_grid_id,
      );
      my $get_rt_dvh_dvh_id = $db->prepare(
        "select currval('rt_dvh_dvh_rt_dvh_dvh_id_seq') as\n" .
        "  rt_dvh_dvh_id");
      $get_rt_dvh_dvh_id->execute();
      my $h = $get_rt_dvh_dvh_id->fetchrow_hashref();
      my $rt_dvh_dvh_id = $h->{rt_dvh_dvh_id};
      $get_rt_dvh_dvh_id->finish();
      my $rt_dvh_dvh_list = $ds->Search(
        "(3004,0050)[$dvh_i](3004,0060)[<0>](3006,0084)");
      if(defined($rt_dvh_dvh_list) && ref($rt_dvh_dvh_list) eq "ARRAY"){
        for my $i (@{$rt_dvh_dvh_list}){
          my $dvh_dvh_i = $i->[0];
          my $dvh_dvh_roi_parms = {
            referenced_roi =>
              "(3004,0050)[$dvh_i](3004,0060)[$dvh_dvh_i](3006,0084)",
            roi_contribution_type  =>
              "(3004,0050)[$dvh_i](3004,0060)[$dvh_dvh_i](3004,0062)",
          };
          $ModList = {};
          $parms = GetAttrs($ds, $dvh_dvh_roi_parms, $ModList, $errors);
          my $ins_rt_dvh_dvh_roi = $db->prepare(
            "insert into rt_dvh_dvh_roi(\n" .
            "  rt_dvh_dvh_id, rt_dvh_dvh_ref_roi_number,\n" .
            "  rt_dvh_dvh_roi_cont_type\n" .
            ") values (\n" .
            "  ?, ?, ?)"
          );
          $ins_rt_dvh_dvh_roi->execute(
            $rt_dvh_dvh_id,
            $parms->{referenced_roi},
            $parms->{roi_contribution_type}
          );
        }
      }
    }
  }
#  print "RTDvh Module only partially implemented\n";
}
sub MRImage{
  my($db, $ds, $id, $hist, $errors) = @_;
#  print "MRImage Module not yet implemented\n";
}
sub USImage{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "USImage Module not yet implemented\n";
}
sub PetImage{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "PetImage Module not yet implemented\n";
}
sub WaveformIdentification{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "WaveformIdentification Module not yet implemented\n";
}
sub Waveform{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "Waveform Module not yet implemented\n";
}
sub AcquisitionContext{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "AcquistionContext Module not yet implemented\n";
}
sub ContrastBolus{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "Message: ContrastBolus Module not yet implemented\n";
}
sub PresentationState{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "PresentationState Module not yet implemented\n";
}
sub Document{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "Document Module not yet implemented\n";
}
sub KeyObjectDocument{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "KeyObjectDocument Module not yet implemented\n";
}
sub KeySeries{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "KeySeries Module not yet implemented\n";
}
sub SRSeries{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "SrSeries Module not yet implemented\n";
}
sub Retired{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "Retired Module not yet implemented\n";
}
sub RealWorldMapping{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "RealWorldMapping Module not yet implemented\n";
}
sub UnImplemented{
  my($db, $ds, $id, $hist, $errors) = @_;
  print "UnImplemented Module not yet implemented\n";
}
1;
