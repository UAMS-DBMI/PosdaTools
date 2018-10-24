#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Try;

my $usage = "usage: $0 <source file>";
unless($#ARGV == 0) {die $usage}
my $dir = getcwd;
my $file = $ARGV[0];
unless(-f $file) { die "$file doesn't exist" }
my $try = Posda::Try->new($file);
unless($try->{dataset}) { die "$file didn't parse" }
my $ds = $try->{dataset};
my $ml = $ds->Search("(3006,0039)[<0>](3006,0040)[<1>](3006,0042)");
my %zs;
if(defined($ml) && ref($ml) eq "ARRAY"){
  for my $m (@$ml){
    my $cde = "(3006,0039)[$m->[0]](3006,0040)[$m->[1]](3006,0050)";
    my $d = $ds->Get($cde);
    if(
      defined $d &&
      ref($d) eq "ARRAY" &&
      (scalar @$d) % 3 == 0
    ){
      for my $i (0 .. ((scalar @$d)/3) - 1){
        $zs{$d->[($i * 3) + 2]} = 1;
      }
    } else {
      die "bad number of floats in contour";
    }
  }
}
for my $j (sort {$a <=> $b} keys %zs){
  print "Z: $j\n";
}
