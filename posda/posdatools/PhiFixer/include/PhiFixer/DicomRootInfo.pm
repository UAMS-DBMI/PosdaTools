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

use Posda::Config 'Config';

my $cache = {};

sub get_info {
  my($collection, $site) = @_;

  # return cached copy if we already have it
  if (defined $cache->{$site}->{$collection}) {
    print "cache hit!\n";
    return $cache->{$site}->{$collection};
  }

  my $dbh = DBI->connect("DBI:Pg:database=${\Config('dicom_roots_db_name')}");

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
