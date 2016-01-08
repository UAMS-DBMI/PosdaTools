#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/GenerateDoseBins.pl,v $
#$Date: 2012/09/18 19:45:52 $
#$Revision: 1.3 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
unless($#ARGV == 3) { die "usage: $0 <db> <host> <user> <id>" }
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0];host=$ARGV[1];user=$ARGV[2]",
  "", "");
my $id = $ARGV[3];
my $get_dvh_data = $db->prepare(
  "select * from rt_dvh_dvh where rt_dvh_dvh_id = ?");
$get_dvh_data->execute($id);
my $data = $get_dvh_data->fetchrow_hashref;
$get_dvh_data->finish;
for my $i (keys %$data){
#  print "$i: $data->{$i}\n";
}
my $get_count_existing_bins = $db->prepare(
  "select count(*) from rt_dvh_dvh_dose_bins where rt_dvh_dvh_id = ?"
);
$get_count_existing_bins->execute($id);
my $h = $get_count_existing_bins->fetchrow_hashref;
$get_count_existing_bins->finish;
my $existing_count = $h->{count};
if($existing_count > 0) {
#  print STDERR 
#    "Message: This dvh already has $h->{count} bins - not inserting more\n";
  $db->disconnect;
  exit;
#} else {
#  print STDERR "Message: Generating new dose_bins\n";
}
my @dvh_data = split /\\/, $data->{rt_dvh_dvh_text_data};
my $num_points = @dvh_data;
my $num_bins = $data->{rt_dvh_dvh_dose_number_of_bins};
# debug - ok
#print "num_bins = $data->{rt_dvh_dvh_dose_number_of_bins}\n";
#print "num_points = $num_points\n";
my $act_num_bins = int($num_points/2);
# debug - ok
#if(
#  $act_num_bins != $num_bins ||
#  $act_num_bins != $num_points/2
#) {
#  print "for $id, non matching num_bins($num_bins) and data($num_points)\n";
#} else {
#  print "OK $id\n";
#}
my @bins;
for my $i (0 .. $act_num_bins - 1){
  my $entry = [$dvh_data[$i * 2], $dvh_data[($i * 2) + 1]];
  push @bins, $entry;
}
for my $i (0 .. $#bins){
  my $entry = $bins[$i];
  unless(defined $entry) {
    print "No entry $i\n";
    next;
  }
  unless(defined $entry->[0]) {
    $entry->[0] = "<undef>";
  }
  unless(defined $entry->[1]) {
    $entry->[1] = "<undef>";
  }
#  print "$entry->[0]\t$entry->[1]\n";
}
my $in_dbd = $db->prepare(
  "insert into rt_dvh_dvh_dose_bins\n" .
  "  (rt_dvh_dvh_id, bin_dose_cgy, cum_percent_vol, cum_cm3_vol)\n" .
  "values\n" .
  "  (?, ?, ?, ?)"
);
my $tot_vol = $bins[0]->[1];
if ($tot_vol <= 0){
  print "Message: no volume for dvh: $id\n";
  exit;
}
my $cum_dose = 0;
my $bin_count = 0;
for my $i (0 .. $#bins){
  my $bsz = $bins[$i]->[0] * 100;
  my $vol_inc = $bins[$i]->[1];
  $cum_dose += $bsz;
  my $pct_vol = ($vol_inc/$tot_vol) * 100;
  if($vol_inc <= 0){
    $vol_inc = 0;
  }
  $in_dbd->execute($id, $cum_dose, $pct_vol, $vol_inc);
  $bin_count += 1;
}
print "Message: inserted $bin_count bins for $id\n";
