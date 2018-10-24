#!/usr/bin/perl -w
use Posda::Dataset;
use Posda::ElementNames;
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);
unless($ds){ die "$ARGV[0] didn't parse" }
$ds->MapEle(sub{
  my($ele, $sig) = @_;
  if(
    $ele->{type} eq "text" &&
    exists $ele->{value} &&
    ref($ele->{value}) eq ""
  ){
    my $name = Posda::ElementNames::FromSig($sig);
    if (defined $ele->{value}){
      print "$name: $ele->{value}\n";
    } else {
      print "$name: <undef>\n";
    }
  }
});
