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
unless($#ARGV == 3) { die "usage: $0 <db> <host> <user> <id>" }
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0];host=$ARGV[1];user=$ARGV[2]",
  "", "");
my $id = $ARGV[3];
my $get_dvh_data = $db->prepare("
select 
  file_id as ss_file_id, dose_file_id, rt_dvh_dvh_id as dvh_id
from
  file_sop_common, 
  (select
    rt_dvh_dvh_id, 
    rt_dvh_referenced_ss_uid as ss_uid,
    file_id as dose_file_id
  from
    rt_dvh_dvh natural join rt_dvh natural join rt_dvh_rt_dose
    natural join file_dose
  ) as foo
  where
    sop_instance_uid = ss_uid and rt_dvh_dvh_id = ?
");
$get_dvh_data->execute($id);
my @list;
while(my $data = $get_dvh_data->fetchrow_hashref){
  my $get_roi = $db->prepare("
select
  roi_name, rt_dvh_dvh_roi_cont_type
from
  file_structure_set natural join roi natural join
  ( select
      rt_dvh_dvh_ref_roi_number as roi_num, 
      rt_dvh_dvh_roi_cont_type
    from
      rt_dvh_dvh_roi
    where
      rt_dvh_dvh_id = ?
  ) as foo
  where file_id = ?
  ");
  my @included;
  my @excluded;
  $get_roi->execute($data->{dvh_id}, $data->{ss_file_id});
  while(my $r = $get_roi->fetchrow_hashref){
    if($r->{rt_dvh_dvh_roi_cont_type} eq "INCLUDED"){
      push(@included, $r->{roi_name});
    } elsif ($r->{rt_dvh_dvh_roi_cont_type} eq "EXCLUDED"){
      push(@excluded, $r->{roi_name});
    }
  }
  my $name = "";
  if($#included > 0){
    $name .= "{";
    for my $i ( 0 .. $#included){
      $name .= $included[$i];
      unless($i == $#included){
        $name .= "+";
      }
    }
    $name .= "}";
  } elsif($#included == 0){
    $name = $included[0];
  } else {
#    print STDERR "Error: no ROIs included\n";
  }
  if($#excluded >= 0){
    $name .= "-";
    if($#excluded > 0){
      $name .= "{";
      for my $i ( 0 .. $#excluded){
        $name .= $excluded[$i];
        unless($i == $#excluded){
          $name .= "+";
        }
      }
      $name .= "}";
    } else {
        $name .= $excluded[0];
    }
  }
  my $get_import_event = $db->prepare("
select distinct import_event_id, remote_file
from file_import natural join import_event where file_id = ? or file_id = ?
  ");
  $get_import_event->execute($data->{dose_file_id}, $data->{ss_file_id});
  my @results;
  while (my $q = $get_import_event->fetchrow_hashref){
    push @results, $q;
  }
  if($#results > 0){
    print STDERR "More than one import\n";
  }
  my $import_event_id = $results[0]->{import_event_id};
  my $remote_file = $results[0]->{remote_file};
  unless(
    $remote_file =~ /\/([^\/\.]+)\.tgz$/ ||
    $remote_file =~ /\/([^\/\.]+)\.tar$/ ||
    $remote_file =~ /\/([^\/\.]+)\.tar.gz$/
  ){
    print STDERR "Non matching file: $remote_file\n";
  }
  my $foo = $1;
print "FOO: $foo\n";
  unless($foo =~ /^(\d+)c(.*)$/){
    print STDERR "Non matching file_name: $foo\n";
  }
  my $protocol = $1;
  my $case_no = $2;
  
  print "dose_file_id: $data->{dose_file_id}, ss_file_id: " .
   "$data->{ss_file_id}, " .
   " dvh_id: $data->{dvh_id} name $name\n" .
   " import_event: $import_event_id file: $remote_file\n" .
   " protocol: $protocol case: $case_no\n";
  my $insert = $db->prepare("
  insert into rt_dvh_protocol_case_roi(
    rt_dvh_dvh_id, roi_construct_name,
    protocol, case_no,
    ss_file_id, dose_file_id
  ) values(
    ?, ?,
    ?, ?,
    ?, ?
  )
  ");
  $insert->execute($data->{dvh_id}, $name,
    $protocol, $case_no,
    $data->{ss_file_id}, $data->{dose_file_id});
}
