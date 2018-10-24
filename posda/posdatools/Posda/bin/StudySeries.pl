#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dataset;
use Posda::Find;
my $Results;
my $usage = "usage: $0 <dir>";
unless($#ARGV == 0) {die $usage}
sub handle {
  my($path, $df, $ds, $size, $xfr_stx, $errors) = @_;
  if($path =~ /^(.*)\/[^\/]*$/){
    my $dir = $1;
    my $StudyInstanceUid = $ds->ExtractElementBySig("(0020,000d)");
    my $SeriesInstanceUid = $ds->ExtractElementBySig("(0020,000e)");
    my $SopClassUid = $ds->ExtractElementBySig("(0008,0016)");
    my $SopInstanceUid = $ds->ExtractElementBySig("(0008,0018)");
    my $Modality = $ds->ExtractElementBySig("(0008,0060)");
    my $SeriesDescription = $ds->ExtractElementBySig("(0008,103e)");
    my $SeriesNumber = $ds->ExtractElementBySig("(0020,0011)");
    my $PatientId = $ds->ExtractElementBySig("(0010,0020)");
#1    my $ImageOrientation;
#1    my $img_orien = $ds->ExtractElementBySig("(0020,0037)");
#1    if($img_orien && ref($img_orien) eq "ARRAY"){
#1      $ImageOrientation = join("\\", @$img_orien);
#1    }
    my $z = $ds->ExtractElementBySig("(0020,0032)[2]");
    unless(
      defined($StudyInstanceUid) &&
      defined($SeriesInstanceUid)
    ){
      print "File $path is missing study or series\n";
      return;
    }
    unless(
      defined $Results->{$dir}->{$StudyInstanceUid}->{$SeriesInstanceUid}
    ){
      $Results->{$dir}->{$StudyInstanceUid}->{$SeriesInstanceUid} = {};
    }
    my $infop = $Results->{$dir}->{$StudyInstanceUid}->{$SeriesInstanceUid};
  
    $infop->{modalities}->{$Modality} = 1;
    $infop->{SopClassUid}->{$SopClassUid} = 1;
#1    $infop->{ImageOrientation}->{$ImageOrientation} = $SopInstanceUid;
    $infop->{SopInstances}->{$SopInstanceUid} = $z;
    $infop->{PatientId}->{$PatientId} = $z;
    $infop->{SeriesDescription}->{$SeriesDescription} = $z;
  } else {
    die "bad path: $path\n";
  }
}
Posda::Find::SearchDir($ARGV[0], \&handle);
for my $dir (sort keys %$Results){
  print "Directory: $dir\n";
  for my $study (sort keys %{$Results->{$dir}}){
    print "  Study: $study\n";
    for my $series (sort keys %{$Results->{$dir}->{$study}}){
      print "    Series: $series\n";
      my $item = $Results->{$dir}->{$study}->{$series};
      print "      Modalities:";
      for my $mod (keys %{$item->{modalities}}){
        print " $mod\n";
      }
      print "      PatientId's:";
      for my $pi (keys %{$item->{PatientId}}){
        print " $pi\n";
      }
      print "      SeriesDescriptions's:";
      for my $sd (keys %{$item->{SeriesDescription}}){
        print " $sd\n";
      }
      my $num_files = scalar keys %{$item->{SopInstances}};
      print "      Sop Instances: $num_files\n";
#1      my @orientations = keys %{$item->{ImageOrientation}};
#1      my $orien_cnt = scalar @orientations;
#1      if($orien_cnt != 1){
#1        print "error: $orien_cnt orientations\n";
#1        for my $i (0 .. $#orientations){
#1           print "$i: $orientations[$i]\n";
#1        }
#1      } else {
#1        print "orientation: $orientations[0]\n";
#1      }
#2      for my $si (
#2        sort {
#2          $item->{SopInstances}->{$a} <=> $item->{SopInstances}->{$b}
#2        }
#2        keys %{$item->{SopInstances}}
#2      ){
#2        if(defined $item->{SopInstances}->{$si}){
#2          print "        $item->{SopInstances}->{$si}: $si\n";
#2        } else {
#2          print "        $si\n";
#2        }
#2      }
    }
  }
}
