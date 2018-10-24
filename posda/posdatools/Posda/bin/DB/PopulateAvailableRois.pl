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
my $id = $ARGV[3];
my $get_dvh_data = $db->prepare("
select distinct ss_file_id, rt_dvh_dvh_id from rt_dvh_protocol_case_roi
");
$get_dvh_data->execute();
row:
while(my $data = $get_dvh_data->fetchrow_hashref){
  my $get_roi_names = $db->prepare(
  "select distinct roi_name 
  from roi natural join file_structure_set
  where file_id = ?"
  );
  $get_roi_names->execute($data->{ss_file_id});
  my $cur_list;
  while (my $h = $get_roi_names->fetchrow_hashref){
    if(defined $cur_list){
      $cur_list .= ", $h->{roi_name}";
    } else {
      $cur_list = $h->{roi_name};
    }
  }
  my $ins = $db->prepare (
  "insert into rt_dvh_available_rois (rt_dvh_dvh_id, available_rois)
   values (?, ?)"
  );
  $ins->execute($data->{rt_dvh_dvh_id}, $cur_list);
}
