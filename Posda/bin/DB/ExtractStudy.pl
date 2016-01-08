#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/ExtractStudy.pl,v $
#$Date: 2010/04/09 20:45:16 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0]", "", "");
my $study_uid = $ARGV[1];
my $dir = $ARGV[2];
unless(-d $dir) { die "usage: $0 <db_name> <study_uid> <directory> [<import_event_id>]" }
my $import_event_id;
if(defined $ARGV[3]){ $import_event_id = $ARGV[3] }

my $q1 = <<EOF;
select root_path || '/' || rel_path as path, sop_instance_uid, modality
from file_location natural join file_storage_root natural join
    file_series natural join file_study natural join file_sop_common
where file_id in (
  select distinct file_id 
  from file_study natural join file_import
  where study_instance_uid = ? and import_event_id = ?
)
EOF

my $q2 = <<EOF;
select root_path || '/' || rel_path as path, sop_instance_uid, modality
from file_location natural join file_storage_root natural join
  file_sop_common natural join file_series natural join file_study
where study_instance_uid = ?
EOF
my $q;
if(defined $import_event_id){
  $q = $db->prepare($q1);
  $q->execute($study_uid, $import_event_id);
} else {
  $q = $db->prepare($q2);
  $q->execute($study_uid);
}
while (my $h = $q->fetchrow_hashref){
  print "cp $h->{path} $dir/$h->{modality}_$h->{sop_instance_uid}.dcm\n";
}
