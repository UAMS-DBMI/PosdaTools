#!/usr/bin/perl -w
use strict;
my $root = "/mnt/public-nfs/posda/import/ACRIN-FLT-Breast-DeIdFiles";
opendir(DIR, $root) or
  die "Can't open dir";
my @dirs;
dir:
while (my $dir = readdir(DIR)){
  if($dir =~ /^\./) { next dir }
  my $path = "$root/$dir";
  unless(-d $path) { next dir }
  push @dirs, $dir;
}
@dirs = sort @dirs;
for my $i (@dirs) {
  my $path = "$root/$i";
  my $wc = `ls $path|wc`;
  print "$i: $wc"
}
