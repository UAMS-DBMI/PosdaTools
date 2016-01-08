#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/dcmtk/ParseDcmtk.pl,v $
#$Date: 2009/03/25 14:31:48 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dcmtk;
my $file = $ARGV[0];
open FILE, "<$file" or die "can't open $file";
Posda::Dcmtk::parse(\*FILE);
