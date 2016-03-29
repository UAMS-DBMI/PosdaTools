#!/usr/bin/perl -w
#
package PhiFixer::DicomRootInfo;
# 
# Retrieve info from the Dicom Roots Database
#
# WARNING: If more than one row is found in the database, only
# the first row is returned!
#

use strict;
use DBI;

# TODO: These need to be moved into a config file!
my $db_name = 'dicom_roots';
my $db_host = 'tcia-utilities';
my $db_user = 'postgres';
my $db_pass = '';

my $cache = {};

sub get_info {
  my($collection, $site) = @_;

  # return cached copy if we already have it
  if (defined $cache->{$site}->{$collection}) {
    print "cache hit!\n";
    return $cache->{$site}->{$collection};
  }

  my $dbh = DBI->connect("DBI:Pg:database=$db_name;host=$db_host", 
                         "$db_user", "$db_pass");

  my $query = qq{
    select
      collection_code,
      site_code,
      date_inc
    from 
      collection
      natural join site
      natural join submission
    where 
      collection_name = ?
      and site_name = ?;
  };

  my $p = $dbh->prepare($query) or die "$!";
  $p->execute($collection, $site) or die $!;

  # fetch as an array of hashes
  # my $ret = $p->fetchall_arrayref({});
  my $ret = $p->fetchrow_hashref();

  $p->finish;
  $dbh->disconnect;

  $cache->{$site}->{$collection} = $ret;
  return $ret;
}

1;
