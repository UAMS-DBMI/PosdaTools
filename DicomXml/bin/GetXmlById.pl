#!/usr/bin/perl
#$Source: /home/bbennett/pass/archive/DicomXml/bin/GetXmlById.pl,v $
#$Date: 2014/05/08 19:27:32 $
#$Revision: 1.1 $
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use XML::Parser;
use Storable qw( retrieve store_fd);
use Cwd;
use Debug;
my $dbg = sub { print STDERR @_ };
unless($#ARGV == 1) {
  die "usage: GetXmlById.pl <parsed_xml_file> <id>";
}
my $struct = retrieve($ARGV[0]);
store_fd ($struct->{index}->{$ARGV[1]}, \*STDOUT);
