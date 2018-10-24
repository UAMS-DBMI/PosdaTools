#!/usr/bin/perl -w
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::DataDict;
my $dd = Posda::DataDict->new;
for my $i (keys $dd->{SopCl}){
  unless($dd->{SopCl}->{$i}->{type} eq "Transfer Syntax"){ next }
  if(exists $dd->{XferSyntax}->{$i}){ next }
  print "No Transfer syntax definition for $i:\n";
  print "\t$dd->{SopCl}->{$i}->{sopcl_desc}\n";
}
