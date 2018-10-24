#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
unless($#ARGV == 2) { die "usage: $0 <db> <host> <user>" }
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0];host=$ARGV[1];user=$ARGV[2]",
  "", "");
my $get_dvh_data = $db->prepare(
  "select rt_dvh_dvh_id from rt_dvh_dvh rtdd where " .
  "rt_dvh_dvh_dose_volume_units = 'CM3' and " .
  "rt_dvh_dvh_type = 'CUMULATIVE' and " .
  "rt_dvh_dvh_text_data is not null and " .
  "rt_dvh_dvh_dose_number_of_bins is not null and " .
  " not exists(select * from rt_dvh_dvh_dose_bins rtdb where " .
  " rtdd.rt_dvh_dvh_id = rtdb.rt_dvh_dvh_id) order by rt_dvh_dvh_id");
$get_dvh_data->execute();

while(my $data = $get_dvh_data->fetchrow_hashref){
  my $cmd = "GenerateDoseBins.pl $ARGV[0] $ARGV[1] $ARGV[2] " .
    "$data->{rt_dvh_dvh_id}";
  open FOO, "$cmd|" or die "can't open pipe from $cmd";
  while(my $line = <FOO>){
    print $line;
  }
}
