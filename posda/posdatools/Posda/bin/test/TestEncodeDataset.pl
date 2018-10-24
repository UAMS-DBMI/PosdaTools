#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Storable qw( store_fd fd_retrieve store );
my $test_elements = {
  "(0008,0005)" => "ISO_IR 100",
  "(0008,0020)" => undef,
  "(0008,0030)" => undef,
  "(0008,0050)"  => undef,
  "(0008,0052)"  => "STUDY",
  "(0008,0061)"  => undef,
  "(0008,1030)"  => undef,
  "(0010,0010)"  => undef,
  "(0010,0020)"  => undef,
  "(0010,0030)"  => undef,
  "(0020,000d)"  => undef,
  "(0020,0010)"  => undef,
  "(0020,1208)"  => undef,
};
my $spec = {
  xfer_syntax => "1.2.840.10008.1.2",
  elements => $test_elements,
};
open my $fh, "|EncodeDataset.pl";
store_fd($spec, $fh);
