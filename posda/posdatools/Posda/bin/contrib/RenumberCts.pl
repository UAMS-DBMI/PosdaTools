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
use Posda::Find;
my %ImagesByZ;        #  Map a z-value to an Image file_name
my %ImagesByFile;     #  Map a file-name to a UID
my %ImagesByUid;     #  Look up values in Image by UID
my %SS;               #  Structure Set by UID;
my %Plan;             #  Plan or Ion Plan by UID;
my %Dose;             #  Dose by UID
my $usage = "usage: $0 <file>";
unless($#ARGV == 0) {die $usage}
my $dir = $ARGV[0];
unless($dir =~ /^\//) {$dir = getcwd."/$dir"}
Posda::Dataset::InitDD();

#
# Callback to populate Data structures
#
my $file_count = 0;
my $total_file_count = 0;
my $finder = sub {
  my($file_name, $df, $ds, $size, $xfr_stx, $errors) = @_;
  print ".";
  $file_count += 1;
  $total_file_count += 1;
  if($file_count >= 80){
    print "\n";
    $file_count = 0;
  }
  my $modality = $ds->ExtractElementBySig("(0008,0060)");
  my $sop_class = $ds->ExtractElementBySig("(0008,0016)");
  my $UID = $ds->ExtractElementBySig("(0008,0018)");
  my $Study_UID = $ds->ExtractElementBySig("(0020,000d)");
  my $Series_UID = $ds->ExtractElementBySig("(0020,000e)");
  my $z = $ds->ExtractElementBySig("(0020,0032)[2]");
  my $for_uid = $ds->ExtractElementBySig("(0020,0052)");
  my $image_num = $ds->ExtractElementBySig("(0020,0013)");
  unless($modality eq "CT") { return };
  if(exists $ImagesByZ{$z}){
    die "Two different CT Images with z of $z";
  }
  $ImagesByZ{$z} = $file_name;
  $ImagesByFile{$file_name} = $UID;
  $ImagesByUid{$UID} = {
    file => $file_name,
    modality => $modality,
    sop_class => $sop_class,
    z => $z,
    study_uid => $Study_UID,
    series_uid => $Series_UID,
    for_uid => $for_uid,
    image_num => $image_num,
  };
};

#
# Build Populate Data structures by finding files and Calling Callback
#
print "Processing Files and building data\n";
Posda::Find::SearchDir($dir, $finder);
if($file_count != 0){
  print "\n";
}
print "Processed $total_file_count files\n";

my $seq = 0;
for my $z (sort {$a <=> $b} keys %ImagesByZ){
  $seq += 1;
  my $file_name = $ImagesByZ{$z};
  my $UID = $ImagesByFile{$file_name};
  my $image_num = $ImagesByUid{$UID}->{image_num};
  print "Change $image_num to $seq in $file_name\n";
  my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file_name);
  $ds->Insert("(0020,0013)", $seq);
  $ds->WritePart10($file_name . ".new", $xfr_stx, "DICOM_TEST", undef, undef);
}
