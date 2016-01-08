#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/PseudoMap.pl,v $
#$Date: 2008/04/30 19:17:34 $
#$Revision: 1.3 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Pseudonymizer;
Posda::Pseudonymizer::FileReader($ARGV[0], $ARGV[1]);
