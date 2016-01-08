#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/TestEleNames.pl,v $
#$Date: 2009/07/17 16:38:01 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use Posda::Dataset;
use Posda::ElementNames;
my @FromSigTest = (
  "(0008,0008)",
  "(300a,00b0)[4](300a,0111)[318](300a,011a)[1](300a,00b8)",
  "(300a,00b0)[4](300a,0111)[318](300a,011a)",
  "(300a,00b0)[4](300a,0111)[143](300a,011a)[0](300a,00b8)",
  "(300a,0003)",
  "(300a,0040)[2](300a,0042)",
);
for my $i (@FromSigTest){
  my $name = Posda::ElementNames::FromSig($i);
  print "$i = $name\n";
  my $sig = Posda::ElementNames::ToSig($name);
  print "$sig\n";
}
