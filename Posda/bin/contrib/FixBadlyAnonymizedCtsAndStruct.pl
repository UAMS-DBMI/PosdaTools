#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/FixBadlyAnonymizedCtsAndStruct.pl,v $
#$Date: 2010/08/11 14:36:16 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Find;
use Posda::UUID;
use Posda::Try;
use Cwd;
use File::Path;
my $cwd = getcwd;

unless($#ARGV == 1){
  die "usage: $0 <from_dir> <to_dir>\n";
}
my $from = $ARGV[0];
my $to = $ARGV[1];
unless($from =~ /^\//){
  $from = "$cwd/$from";
print "from = $from\n";
}
unless($to =~ /^\//){
  $to = "$cwd/$to";
print "to = $to\n";
}
unless(-d $from) { die "$from is not a directory" }
unless(-d $to) { die "$to is not a directory" }

my %OrigCTsByZ;
my %OrigCTsByFile;
my %OrigCTsByUid;
my $OrigStruct;
my $NewStruct;

Posda::Dataset::InitDD();
my $finder = sub {
  my($file_name, $df, $ds, $size, $xfr_stx, $errors) = @_;
  my($vol, $dir, $file) = File::Spec->splitpath($file_name);
  my $modality = $ds->ExtractElementBySig("(0008,0060)");
  if($modality eq "CT"){
    my $z = $ds->ExtractElementBySig("(0020,0032)[2]");
    if(defined $OrigCTsByZ{$z}){
      print STDERR "two CTs at $z: $OrigCTsByZ{$z} and $file_name\n";
    }
    $OrigCTsByZ{$z} = $file_name;
    my $UID = $ds->ExtractElementBySig("(0008,0018)");
    my $Study_UID = $ds->ExtractElementBySig("(0020,000d)");
    my $Series_UID = $ds->ExtractElementBySig("(0020,000e)");
    $OrigCTsByFile{$file_name} = $UID;
    if(defined $OrigCTsByUid{$UID}){
      print STDERR "Two CT's with same UID ($UID):\n" .
        "\t$file_name\n\t$OrigCTsByUid{$UID}->{file}\n";
    }
print "Data collected for CT: $UID\n";
    $OrigCTsByUid{$UID} = {
      file => $file_name,
      to_file => "$to/$file",
      z => $z,
      study_uid => $Study_UID,
      series_uid => $Series_UID,
      sop_uid => $UID,
      xfr_stx => $xfr_stx,
    };
  } elsif($modality eq "RTSTRUCT"){
    if(defined $OrigStruct){
      print STDERR "two structs $OrigStruct and $file_name\n";
    }
    $OrigStruct = $file_name;
    $NewStruct = "$to/$file";
  }
};
print "Searching $from\n";
Posda::Find::SearchDir($from, $finder);

#
# Now we need to make a new study, series, and frame of reference for
# all the CTs - and rebuild the data structures we just built
#
my $NewUidRoot = Posda::UUID::GetUUID();
my $NewStudyInstanceUID = "$NewUidRoot.1";
my $NewCtSeriesInstanceUID = "$NewStudyInstanceUID.1";
my $NewStructSeriesInstanceUID = "$NewStudyInstanceUID.2";
my $NewForUID = "$NewStudyInstanceUID.3";

my %CTsByZ;
my %CTsByFile;
my %CTsByUid;

my $uid_seq = 0;
for my $old_uid (
  sort 
  { $OrigCTsByUid{$a}->{z} <=> $OrigCTsByUid{$b}->{z} }
  keys %OrigCTsByUid
){
  print "processing file :$old_uid\n";
  $uid_seq += 1;
  my $new_uid = "$NewCtSeriesInstanceUID.$uid_seq";
  my $old_ct_descrip = $OrigCTsByUid{$old_uid};
  $CTsByUid{$new_uid} = {
    file => $old_ct_descrip->{to_file},
    z => $old_ct_descrip->{z},
    study_uid => $NewStudyInstanceUID,
    series_uid => $NewCtSeriesInstanceUID,
    for_uid => $NewForUID,
  };
  $CTsByFile{$old_ct_descrip->{to_file}} = $new_uid;
  $CTsByZ{$old_ct_descrip->{z}} = $old_ct_descrip->{file_name};
  my $try = Posda::Try->new($old_ct_descrip->{file});
  unless(defined $try->{dataset}){
    die "$old_ct_descrip->{file} didn't parse second time";
  }
  $try->{dataset}->Insert("(0008,0018)", $new_uid);
  $try->{dataset}->Insert("(0020,000d)", $NewStudyInstanceUID);
  $try->{dataset}->Insert("(0020,000e)", $NewStudyInstanceUID);
  $try->{dataset}->Insert("(0020,0052)", $NewForUID);
  $try->{dataset}->WritePart10($old_ct_descrip->{to_file}, $try->{xfr_stx},
    "POSDA_SCRIPT", undef, undef);
}

exit;  #  The structure sets are currently meaningless

#
# Now its time to process the Structure Set
# 
my %CtMap;

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
my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($OrigStruct);
unless($ds) { die "can't parse $OrigStruct" }
#
# Add all the Contour References
#  (uses BuildCtMap above to build %CtMap as it goes)
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
    "1.2.840.10008.5.1.4.1.1.2");
  $ds->Insert("(3006,0039)[$r_i](3006,0040)[$rc_i](3006,0016)[0](0008,1155)",
    $Uid);
}
print "Maximum Mapping Distance: $max_mapping_dist\n";


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

#
# Now Write out the new Structure Set
#

$ds->WritePart10($NewStruct, $xfr_stx, "POSDA_SCRIPT", undef, undef);
