#!/usr/bin/perl -w
#
package PhiFixer::PrivateTagInfo;
#
# Module to get detailed information about the given DICOM
# Private Tag. The tag should be given as a "short signature"
#
# If there is more than one match, all rows are returned.
#

use strict;
use DBI;

# TODO: These need to be moved into a config file!
my $db_name = 'private_tag_kb';
my $db_host = 'tcia-utilities';
my $db_user = 'postgres';
my $db_pass = '';

my $cache = {};

sub get_info {
  my($tag_sig) = @_;

  # return cached copy if we already have it
  if (defined $cache->{$tag_sig}) {
    return $cache->{$tag_sig};
  }

  my $dbh = DBI->connect("DBI:Pg:database=$db_name;host=$db_host", 
                         "$db_user", "$db_pass");

  my $query = qq{
    select *
    from pt
    where pt_short_signature = ?
  };

  my $p = $dbh->prepare($query) or die "$!";
  $p->execute($tag_sig) or die $!;

  # fetch as an array of hashes
  my $ret = $p->fetchall_arrayref({});

  $dbh->disconnect;

  $cache->{$tag_sig} = $ret;
  return $ret;
}

1;
