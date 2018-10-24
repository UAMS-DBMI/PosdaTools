#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use DBI;
my  $db = DBI->connect("dbi:Pg:dbname=$ARGV[0]", "", "");
my $q = $db->prepare(
  "select rt_dose_id, rt_dose_grid_frame_offset_vector\n" .
  "from rt_dose_image\n" .
  "where rt_dose_grid_frame_offset_vector is not null" .
  "  and rt_dose_max_slice_spacing is null"
);
$q->execute();
while(my $h = $q->fetchrow_hashref()){
  unless(defined $h->{rt_dose_grid_frame_offset_vector}){
    print "gfov undefined\n";
    next;
  }
  my @gfov = split(/\\/, $h->{rt_dose_grid_frame_offset_vector});
  my $count = @gfov;
  my %SliceSpacings;
  my $q1 = $db->prepare("insert into rt_dose_gfov(\n" .
    "rt_dose_id, rt_gfov_index, gfov_offset) values (?, ?, ?)");
  
  for my $i (0 .. $#gfov - 1){
    $q1->execute($h->{rt_dose_id}, $i, $gfov[$i]);
    my $Spacing = $gfov[$i+1] - $gfov[$i];
    $SliceSpacings{$Spacing} = 1;
  }
  my $sp_count = scalar keys %SliceSpacings;
  my($min_sp, $max_sp);
  for my $sp (keys %SliceSpacings){
    unless(defined($min_sp)) { $min_sp = $sp}
    unless(defined($max_sp)) { $max_sp = $sp}
    if($sp > $max_sp) { $max_sp = $sp }
    if($sp < $min_sp) { $min_sp = $sp }
  }
  my $q3 = $db->prepare("update rt_dose_image set\n" .
    "  rt_dose_max_slice_spacing = ?,\n" .
    "  rt_dose_min_slice_spacing = ?\n" .
    "where rt_dose_id = ?");
  $q3->execute($max_sp, $min_sp, $h->{rt_dose_id});
}
