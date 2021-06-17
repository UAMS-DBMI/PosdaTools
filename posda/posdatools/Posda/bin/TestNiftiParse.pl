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
print "nifti = ";
Debug::GenPrint($dbg, $nifti, 1);
print "\n";
