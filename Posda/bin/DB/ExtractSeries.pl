#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/ExtractSeries.pl,v $
#$Date: 2010/01/18 20:50:47 $
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
my $series_uid = $ARGV[1];
my $dir = $ARGV[2];
unless(-d $dir) { die "usage: $0 <db_name> <series_uid> <directory>" }
my $q = $db->prepare(
  "select root_path || '/' || rel_path as path, sop_instance_uid, modality\n" .
  "from file_location natural join file_storage_root natural join\n" .
  "file_sop_common natural join file_series\n" .
  "where series_instance_uid = ?"
);
$q->execute($series_uid);
while (my $h = $q->fetchrow_hashref){
  print "cp $h->{path} $dir/$h->{modality}_$h->{sop_instance_uid}.dcm\n";
}
