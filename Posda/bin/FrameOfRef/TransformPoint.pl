#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Posda::Dataset;
use Posda::Transforms;
use Debug;
my $dbg = sub {print @_};

my $usage = "usage: $0 <register> <x> <y> <z>";
unless($#ARGV == 3) {die $usage}
my $reg_name = $ARGV[0];
my $x = $ARGV[1];
my $y = $ARGV[2];
my $z = $ARGV[3];

my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($reg_name);
unless($ds) { die "$reg_name didn't parse" };


my $match = $ds->Search("(0070,0308)[<0>](0020,0052)");
unless(ref($match) eq "ARRAY") { die "didn't find transforms" }
for my $m (@$match){
  my $indx = $m->[0];
  my $xform_type = $ds->Get(
    "(0070,0308)[$indx](0070,0309)[0](0070,030a)[0](0070,030c)");
  my $xform = Posda::Transforms::MakeFromDicomXform(
    $ds->Get(
      "(0070,0308)[$indx](0070,0309)[0](0070,030a)[0](3006,00c6)")
  );
  if(Posda::Transforms::IsIdentity($xform)) { next }
  my($npnt) = Posda::Transforms::ApplyTransform($xform, [$x, $y, $z]);
  printf "Transform[%d]: [%0.6f, %0.6f, %0.6f] => [%0.6f, %0.6f, %0.6f]\n",
    $indx, $x, $y, $z, $npnt->[0], $npnt->[1], $npnt->[2]; 
}
