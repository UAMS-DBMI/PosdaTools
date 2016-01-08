#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/PopCtSeries.pl,v $
#$Date: 2013/09/06 19:25:25 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0]", "", "");
my $real_start = time();
my $q0 = $db->prepare(
  "select count(*) from\n" .
  "(\n" .
  "  select distinct series_instance_uid, import_event_id\n" .
  "  from file_import natural join file_series\n" .
  "    natural left join import_ct_series\n" .
  "  where import_ct_series.import_event_id is null and modality = 'CT'\n" .
  ") as foo");
$q0->execute();
my $h0 = $q0->fetchrow_hashref();
$q0->finish();
my $to_do = $h0->{count};
my $done = 0;
my $chunk = 10;
my $count_query_time = time() - $real_start;
print "$count_query_time doing count query\n";
my $query_time = time();
my $start_time;
my $q = $db->prepare(
  "select\n" .
  "  distinct series_instance_uid, import_event_id, count(*) as num_files\n" .
  "from file_import natural join file_series\n" .
  "  left join import_ct_series\n" .
  "    using (import_event_id, series_instance_uid)\n" .
  "where import_ct_series.import_event_id is null and modality = 'CT'\n" .
  "group by series_instance_uid, import_event_id"
);
$q->execute();
series:
while(my $h = $q->fetchrow_hashref()){
  unless(defined $start_time) {
    $start_time = time();
    my $time_to_first_row = $query_time - $start_time;
    print "$time_to_first_row seconds to first row returned\n";
  }
  my $series_instance_uid = $h->{series_instance_uid};
  my $import_event_id = $h->{import_event_id};
  my $num_files = $h->{num_files};
  if($num_files == 0) {
    print "no files in series: $h->{series_instance_uid}\n";
    next series;
  }
  my $q1 = $db->prepare("select\n" .
    "  i.image_type, ig.normalized_iop, ig.for_uid, ig.row_x,\n" .
    "  ig.row_y, ig.row_z,\n" .
    "  i.pixel_rows, i.pixel_columns, i.pixel_spacing,\n" .
    "  ig.col_x, ig.col_y, ig.col_z, ig.pos_x, ig.pos_y, ig.pos_z,\n" .
    "  f.size, fs.patient_position\n" .
    "from\n" .
    "  file f,        file_image_geometry fig,\n" .
    "  image i,       image_geometry ig,\n" .
    "   file_image fi, file_series fs\n" .
    "where\n" .
    "  f.file_id = fi.file_id and\n" .
    "  fi.image_id = i.image_id and\n" .
    "  f.file_id = fig.file_id and\n" .
    "  ig.image_geometry_id = fig.image_geometry_id and\n" .
    "  i.image_id = ig.image_id and\n" .
    "  fs.file_id = f.file_id and\n" .
    "  fs.file_id in (\n" .
    "  select distinct file_id\n" .
    "  from file_import natural join file_series\n" .
    "    left join import_ct_series\n" .
    "      using(import_event_id, series_instance_uid)\n" .
    "  where import_event_id = ? and series_instance_uid = ? and\n" .
    "    modality = 'CT' and import_ct_series.import_event_id is null\n" .
    "  )");
  $q1->execute($import_event_id, $series_instance_uid);
  my @list;
  while(my $h1 = $q1->fetchrow_hashref()){
    push(@list, $h1);
  }
  my $num_rows = @list;
if ($num_rows > $num_files) {
   die "$num_rows vs $num_files for $import_event_id $series_instance_uid"
}

  my $series_type;
  my $is_axial;
  my $consistent_series_geometry = 1;
  my $total_file_size = 0;
  my($max_file_size, $min_file_size);
  my($maximum_z, $minimum_z);
  my $normalized_iop;
  my $processing_errors;
  my $number_of_slices = 0;
  my $patient_position;

  for my $i (@list){
    my $this_type = [split /\\/, $i->{image_type}]->[2];
    unless(defined $this_type){
      $this_type = "<undefined>";
    }
    my $file_size = $i->{size};
    $total_file_size += $file_size;
    unless(defined($max_file_size)){ $max_file_size = $file_size }
    unless(defined($min_file_size)){ $min_file_size = $file_size }
    if($file_size > $max_file_size){ $max_file_size = $file_size }
    if($file_size < $min_file_size){ $min_file_size = $file_size }
    unless(defined $series_type) { $series_type = $this_type }
    unless($series_type eq $this_type){
      $consistent_series_geometry = 0;
      my $error = "two different series_types $series_type and $this_type";
      if(defined $processing_errors){
        $processing_errors = $error;
      } else {
        $processing_errors .= "\$error";
      }
    }
    my $iop = $i->{normalized_iop};
    unless(defined $iop) { $iop = "<undefined>" }
    unless(defined($normalized_iop)){ $normalized_iop = $iop }
    if($normalized_iop ne $iop){
      $consistent_series_geometry = 0;
      my $error = "two different normalized iop's $normalized_iop and $iop";
      if(defined $processing_errors){
        $processing_errors = $error;
      } else {
        $processing_errors .= "\$error";
      }
    }
    my $pat_pos = $i->{patient_position};
    unless(defined $pat_pos) { $pat_pos = "<undefined>" }
    unless(defined($patient_position)){ $patient_position = $pat_pos }
    if($patient_position ne $pat_pos){
      $consistent_series_geometry = 0;
      my $error = "two different patient_positions " .
        "$patient_position and $pat_pos";
      if(defined $processing_errors){
        $processing_errors = $error;
      } else {
        $processing_errors .= "\$error";
      }
    }
    my $cur_z = $i->{pos_z};
    if(defined $cur_z){
      unless(defined($maximum_z)){ $maximum_z = $cur_z }
      unless(defined($minimum_z)){ $minimum_z = $cur_z }
      if($cur_z > $maximum_z){ $maximum_z = $cur_z }
      if($cur_z < $minimum_z){ $minimum_z = $cur_z }
    }
    $number_of_slices += 1;
  }
  if($number_of_slices == 0) { next series }
  my $avg_file_size = $total_file_size / $number_of_slices;

  my @z_pos;
  for my $i (sort {$a->{pos_z} <=> $b->{pos_z}} @list){
    push(@z_pos, $i->{pos_z});
  }
  my($max_slice_spacing, $min_slice_spacing);
  for my $i (0 .. $#z_pos - 1){
    my $slice_sp = $z_pos[$i + 1] - $z_pos[$i];
    unless(defined $max_slice_spacing){ $max_slice_spacing = $slice_sp }
    unless(defined $min_slice_spacing){ $min_slice_spacing = $slice_sp }
    if($slice_sp > $max_slice_spacing){ $max_slice_spacing = $slice_sp }
    if($slice_sp < $min_slice_spacing){ $min_slice_spacing = $slice_sp }
  }
  my $avg_slice_spacing;
  if(
    $number_of_slices > 1 &&
    defined($maximum_z) &&
    defined($minimum_z)
  ) {
   $avg_slice_spacing = ($maximum_z - $minimum_z) / ($number_of_slices - 1);
  }
  if($series_type eq "AXIAL"){
    $is_axial = 1;
  } else {
    $is_axial = 0;
  }
 
  my $q2 = $db->prepare(
    "insert into import_ct_series(import_event_id,\n" .
    "  series_instance_uid, series_type, patient_position,\n" .
    "  is_axial, consistent_series_geometry, normalized_iop,\n" .
    "  number_of_slices, avg_slice_spacing, max_slice_spacing,\n" .
    "  minimum_z, maximum_z, total_file_size,\n" .
    "  max_file_size, min_file_size, avg_file_size,\n" .
    "  processing_errors, min_slice_spacing\n" .
    ") values (?,\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?\n" .
    ")"
  );
  $q2->execute($import_event_id,
    $series_instance_uid, $series_type, $patient_position,
    $is_axial, $consistent_series_geometry, $normalized_iop,
    $number_of_slices, $avg_slice_spacing, $max_slice_spacing,
    $minimum_z, $maximum_z, $total_file_size,
    $max_file_size, $min_file_size, $avg_file_size,
    $processing_errors, $min_slice_spacing
  );
  $done += 1;
  $chunk -= 1;
  if($chunk <= 0){
    $chunk = 10;
    my $now = time();
    my $elapsed = $now - $start_time;
    my $remaining = $to_do - $done;
    my $avg = $elapsed / $done;
    my $projected = $remaining * $avg;
    printf "processed $done in $elapsed seconds (%3.2f / sec)\n", $avg;
    if($projected > 3600){
      my $hours = $projected / 3600;
      printf "estimated %3.2f hours remaining to process $remaining series\n",
        $hours;
    } elsif ($projected > 60) {
      my $minutes = $projected / 60;
      printf "estimated %3.2f minutes remaining to process $remaining series\n",
        $minutes;
    } else {
      printf "estimated $projected seconds remaining\n";
    }
  }
}
$db->disconnect();
