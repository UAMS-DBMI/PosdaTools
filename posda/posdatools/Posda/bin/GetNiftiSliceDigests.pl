#!/usr/bin/perl -w
use strict;
use Cwd;
use Nifti::Parser;
use Debug;
my $dbg = sub { print @_ };
my $dir = getcwd;
my $file = $ARGV[0];
unless ($file =~ /^\//){
  $file = "$dir/$file";
}
my $nifti = Nifti::Parser->new($file);
my($num_slices, $num_vols) = $nifti->NumSlicesAndVols;
print "vol,slice,max,min,slice_digest,flipped_slice_digest\n";
for my $v (0 .. $num_vols - 1){
  for my $s (0 .. $num_slices - 1){
    my($dig, $max, $min) = $nifti->SliceDigest($v, $s);
    my $f_dig = $nifti->FlippedSliceDigest($v, $s);
    print "$v,$s,$max,$min,$dig,$f_dig\n";
  }
}
