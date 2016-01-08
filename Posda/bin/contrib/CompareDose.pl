#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/CompareDose.pl,v $
#$Date: 2011/06/23 15:31:26 $
#$Revision: 1.5 $

use Cwd;
use strict;
use Posda::Dataset;

Posda::Dataset::InitDD();

my $usage = "usage: $0 <file1> <file2>";
unless(
	$#ARGV >= 1
) {
	die $usage;
}

my $file1 = $ARGV[0];  # First Dose
unless($file1 =~ /^\//) { $file1 = getcwd."/$file1" }
unless(-r $file1 && -f $file1){ die "Can't read $file1" }
my ($df1, $ds1, $size1, $xfr_stx1, $errors1) = Posda::Dataset::Try($file1);
unless($ds1) { 
  print "First file is not a DICOM file\n";
  die "Can't continue";
}
unless($ds1->ExtractElementBySig("(0008,0060)") eq "RTDOSE"){
  print "first file is not a DOSE\n";
  die "Can't continue";
}

my $file2 = $ARGV[1];  # RT Dose
unless($file2 =~ /^\//) { $file2 = getcwd."/$file2" }
unless(-r $file2 && -f $file2){ die "Can't read $file2" }
my ($df2, $ds2, $size2, $xfr_stx2, $errors2) = Posda::Dataset::Try($file2);
unless($ds2) { 
  print "Second file is not a DICOM file\n";
  die "Can't continue";
}

unless($ds2->ExtractElementBySig("(0008,0060)") eq "RTDOSE"){
  print "Second file is not an RT DOSE\n";
  die "Can't continue";
}

unless($ds1 && $ds2){
  print "Must have two RTDOSE's to continue\n";
  die "Can't continue";
}
my $rows1 = $ds1->ExtractElementBySig("(0028,0010)");
my $rows2 = $ds2->ExtractElementBySig("(0028,0010)");
my $cols1 = $ds1->ExtractElementBySig("(0028,0011)");
my $cols2 = $ds2->ExtractElementBySig("(0028,0011)");
my $bits1 = $ds1->ExtractElementBySig("(0028,0100)");
my $bits2 = $ds2->ExtractElementBySig("(0028,0100)");
my $gs1 = $ds1->ExtractElementBySig("(3004,000e)");
my $gs2 = $ds2->ExtractElementBySig("(3004,000e)");
my $gfov1 = join("\\", @{$ds1->ExtractElementBySig("(3004,000c)")});
my $gfov2 = join("\\", @{$ds2->ExtractElementBySig("(3004,000c)")});
my $dose1 = $ds1->ExtractElementBySig("(7fe0,0010)");
my $dose2 = $ds2->ExtractElementBySig("(7fe0,0010)");
unless(
  $rows1 eq $rows2 &&
  $cols1 eq $cols2 &&
  $bits1 eq $bits2 &&
  $gs1 eq $gs2 &&
  $gfov1 eq $gfov2 &&
  $dose1 eq $dose2
){
  print "The doses don't match\n";
}
