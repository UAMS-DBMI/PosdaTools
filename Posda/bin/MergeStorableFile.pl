#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/MergeStorableFile.pl,v $
#$Date: 2011/10/05 15:35:01 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Storable qw( lock_store store retrieve store_fd fd_retrieve );
use Fcntl qw(:flock);

my $file = $ARGV[0];

my $pgm_data = fd_retrieve(\*STDIN);
my $file_data;

unless (-f $file) {
  Storable::lock_store($pgm_data, $file);
  exit 0;
}
open (FILE, "+<",  $file) || 
  die "MergeStorableFile.pl: Error $! opening file: $file\n";
flock FILE, LOCK_EX;
eval { $file_data = fd_retrieve(\*FILE); };
if ($@) { 
  print STDERR "MergeStorableFile.pl: Error $@, " .
    "can't retreive hash data from file: $file\n";
  $file_data = {}; 
}
foreach my $key_lev1 ( keys %{$pgm_data} ) {
  foreach my $key_lev2 ( keys %{$pgm_data->{$key_lev1}}) {
    $file_data->{$key_lev1}->{$key_lev2} = 
      $pgm_data->{$key_lev1}->{$key_lev2};
  }
}
seek(FILE, 0, 0);
truncate(FILE, 0);
eval { store_fd($file_data, \*FILE); };
if ($@) {
  print STDERR "MergeStorableFile.pl: Error $@, " .
    "can't store hash data to file: $file\n";
}
close (FILE);
chmod 0664, $file;
store_fd($file_data, \*STDOUT);
exit 0;
