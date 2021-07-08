#!/usr/bin/perl -w
use strict;
use Cwd;
use Nifti::Parser;
use Debug;
my $dbg = sub { print @_ };
my $dir = getcwd;
my $file = $ARGV[0];
my $file_id = $ARGV[1];
my $tmp_dir = $ARGV[2];
unless ($file =~ /^\//){
  $file = "$dir/$file";
}
my $nifti = Nifti::Parser->new_from_zip($file, $file_id, $tmp_dir);
$nifti->ProjectionAnalysis;
