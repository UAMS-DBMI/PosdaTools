#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/TestCCodeGen.pl,v $
#$Date: 2008/06/20 20:52:08 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use Posda::PseudoPhantom;
use Posda::Dataset;
use Posda::CCgen;

Posda::Dataset::InitDD();

unless($#ARGV == 1){ die "usage: $0 <config> <dest_dir>" }

my $config = $ARGV[0];
my $dest_dir = $ARGV[1];
my $PPC = Posda::PseudoPhantom->new($config, $dest_dir);
$PPC->GenerateSeriesCCode();
