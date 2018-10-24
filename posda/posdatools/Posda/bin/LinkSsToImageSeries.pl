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
my %CTsByZ;
my %CTsByFile;
my %CTsByUid;
my %CtMap;
my %ContourRefByZ;
my %ContourRefByUid;
my $UidMap;
my $modality;
my $sop_class_uid;
Posda::Dataset::InitDD();
my $usage = sub {
	print "Error: usage: $0 <base dir> <StructSetFile> <ImageSeriesUid>";
	exit -1;
};
# print STDERR "$0: dir: $ARGV[0], StructSetFile: $ARGV[1], " .
#   "Image Series UID: $ARGV[2].\n";
unless($#ARGV==2){&$usage()}
my $RootDir = $ARGV[0];
my $StructSetFile = $ARGV[1];
my $ImageSeriesUID = $ARGV[2];
print "Comment: Controlled dir: $ARGV[0]\n";
print "Comment: StructSetFile: $ARGV[1]\n";
print "Comment: Image Series UID: $ARGV[2]\n";
unless($StructSetFile =~ /^\//) 
  { $StructSetFile = $RootDir."/".$StructSetFile }
my $finder = sub {
  my($file_name, $df, $ds, $size, $xfr_stx, $errors) = @_;
  my $SeriesUID = $ds->ExtractElementBySig("(0020,000e)");
  if ($SeriesUID ne $ImageSeriesUID) { return }
  my $this_modality = $ds->ExtractElementBySig("(0008,0060)");
  my $this_sop_class_uid = $ds->ExtractElementBySig("(0008,0016)");
  if(defined $modality && $this_modality ne $modality){
    print STDERR "series has two modalities: $modality and $this_modality\n";
  }
 $modality = $this_modality;
  if(defined $sop_class_uid && $this_sop_class_uid ne $sop_class_uid){
    print STDERR "series has two sop_class_uids: $sop_class_uid " .
      "and $this_sop_class_uid\n";
  }
 $sop_class_uid = $this_sop_class_uid;
  my $iop = $ds->ExtractElementBySig("(0020,0031)");
  my $z = $ds->ExtractElementBySig("(0020,0032)[2]");
  if(defined $CTsByZ{$z}){
    print "Warning: Two CTs at $z: $CTsByZ{$z} and $file_name\n";
  }
  $CTsByZ{$z} = $file_name;
  my $UID = $ds->ExtractElementBySig("(0008,0018)");
  my $Study_UID = $ds->ExtractElementBySig("(0020,000d)");
  $CTsByFile{$file_name} = $UID;
  if(defined $CTsByUid{$UID}){
    print "Error: Two CT's with same UID ($UID):" .
      "\t$file_name\t$CTsByUid{$UID}->{file}\n";
  }
  $CTsByUid{$UID} = {
    file => $file_name,
    z => $z,
    study_uid => $Study_UID,
    series_uid => $SeriesUID,
  };
};
Posda::Find::SearchDir($RootDir, $finder);
my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($StructSetFile);
unless($ds) { 
  print "Error: can't parse Structure Set File: $StructSetFile";
  exit -1;
}
#
# Add all the Contour References
#
my $max_mapping_dist = 0;
my $ct_cont_ref = $ds->Substitutions(
  "(3006,0039)[<0>](3006,0040)[<1>](3006,0042)", "CLOSED_PLANAR"
);
for my $inst (@{$ct_cont_ref->{list}}){
  my $r_i = $inst->[$ct_cont_ref->{index_list}->{"<0>"}];
  my $rc_i = $inst->[$ct_cont_ref->{index_list}->{"<1>"}];
  my $z = $ds->ExtractElementBySig(
    "(3006,0039)[$r_i](3006,0040)[$rc_i](3006,0050)[2]"
  );
  my $closest_z = $z;
  unless(defined $CTsByZ{$z}){
    BuildCtMap($z);
    $closest_z = $CtMap{$z};
  }
  my $dist = abs($closest_z - $z);
  if($dist> $max_mapping_dist) { $max_mapping_dist = $dist }
  my $Uid = $CTsByFile{$CTsByZ{$closest_z}};
  $ds->Insert("(3006,0039)[$r_i](3006,0040)[$rc_i](3006,0016)[0](0008,1150)",
    $sop_class_uid);
  $ds->Insert("(3006,0039)[$r_i](3006,0040)[$rc_i](3006,0016)[0](0008,1155)",
    $Uid);
}
# print "Maximum Mapping Distance: $max_mapping_dist\n";
#
# Delete RT Referenced Study Sequence
#
$ds->DeleteElementBySig("(3006,0010)[0](3006,0012)");


#
# Rebuild the RT Study Reference Sequence
#
my %Studies;
for my $uid (keys %CTsByUid){
  my $item = $CTsByUid{$uid};
  $Studies{$item->{study_uid}}->{$item->{series_uid}}->{$uid} = $item->{z};
}
my $study_index = 0;
for my $st (keys %Studies){
  $ds->InsertElementBySig("(3006,0010)[0](3006,0012)[$study_index](0008,1150)", 
    "1.2.840.10008.3.1.2.3.1");
  $ds->InsertElementBySig("(3006,0010)[0](3006,0012)[$study_index](0008,1155)", 
    $st);
  my $series_index = 0;
  for my $ser (keys %{$Studies{$st}}){
    $ds->InsertElementBySig(
      "(3006,0010)[0](3006,0012)[$study_index]" . 
      "(3006,0014)[$series_index](0020,000e)", 
      $ser);
    my $image_index = 0;
    for my $i (
      sort
      { $Studies{$st}->{$ser}->{$b} <=> $Studies{$st}->{$ser}->{$a} }
      keys %{$Studies{$st}->{$ser}}
    ){
      $ds->InsertElementBySig(
        "(3006,0010)[0](3006,0012)[$study_index]" .
        "(3006,0014)[$series_index](3006,0016)[$image_index](0008,1150)", 
        "1.2.840.10008.5.1.4.1.1.2");
      $ds->InsertElementBySig(
        "(3006,0010)[0](3006,0012)[$study_index]" .
        "(3006,0014)[$series_index](3006,0016)[$image_index](0008,1155)", 
        $i);
      $image_index += 1;
    }
    $series_index += 1;
  }
  $study_index += 1;
}
my $new_file_name = "$StructSetFile.new";
$ds->WritePart10($new_file_name, $xfr_stx, "POSDA", undef, undef);
print "Convert: \"$StructSetFile\", \"$new_file_name\"\n";
# print "Add: \"$new_file_name\"\n";

sub BuildCtMap{
  my($z) = @_;
  if(exists $CtMap{$z}){ return };
  my $closest_z;
  my $dist;
  for my $i (keys %CTsByZ){
    unless(defined($closest_z)){ $closest_z = $i }
    unless(defined($dist)){ $dist = abs($z - $i) }
    if(abs($z - $i) < $dist){
      $closest_z = $i;
      $dist = abs ($z - $i);
    }
  }
  $CtMap{$z} = $closest_z;
}
