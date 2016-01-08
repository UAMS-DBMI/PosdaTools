#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/MakeSingleStudy.pl,v $
#$Date: 2011/06/23 15:31:25 $
#$Revision: 1.3 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use Cwd;
use strict;
use Posda::Dataset;
use Posda::Find;
use Posda::UID;
use Debug;
my $dbg = sub { print @_ };
unless($#ARGV == 1){
  die "usage: $0 <from_dir> <to_dir>\n";
}
my $from_dir = $ARGV[0]; unless($from_dir=~/^\//){$from_dir=getcwd."/$from_dir"}
my $to_dir = $ARGV[1]; unless($to_dir=~/^\//){$to_dir=getcwd."/$to_dir"}
unless(-d $from_dir) { die "$from_dir is not a directory\n"; }
unless(-d $to_dir) { die "$from_dir is not a directory\n"; }
opendir DIR, $to_dir;
dir:
while(my $file = readdir(DIR)){
  if($file eq ".") { next dir }
  if($file eq "..") { next dir }
  die "$to_dir is not empty (and I'm afraid to 'rm -rf $to_dir/*'";
}
closedir DIR;
my $user = `whoami`;
my $host = `hostname`;
chomp $user;
chomp $host;
my $new_root = Posda::UID::GetPosdaRoot( {
  program => $0,
  user => $user,
  system => $host,
  purpose => "Reconstituting Study",
}
);

my $study_uid = $new_root;
my $ct_series_uid = "$study_uid.1";
my $for_uid = "$study_uid.2";
my $mr_series_uid = "$study_uid.3";
my $pt_series_uid = "$study_uid.4";
my $ss_series_uid = "$study_uid.5";
my $rtp_series_uid = "$study_uid.6";
my $rtd_series_uid = "$study_uid.6";
my($ct_seq, $mr_seq, $pt_seq, $rtp_seq, $rtd_seq);
$ct_seq = $mr_seq = $pt_seq = $rtp_seq = $rtd_seq = 1;
my $rt_dose;
my $rt_dose_xfr;
my $rt_plan;
my $rt_plan_xfr;
my $rt_ss;
my $rt_ss_xfr;
my %CtByZ;
my %CtMap;
my $wanted = sub {
  my($file_name, $df, $ds, $size, $xfr_stx, $errors) = @_;
  my $modality = $ds->Get("(0008,0060)");
  if($modality eq 'CT') {
    my $z = $ds->Get("(0020,0032)[2]");
    my $inst_num = $ds->Get("(0020,0013)");
    my $sop_instance_uid;
    if(defined($inst_num)){
      $sop_instance_uid = "$mr_series_uid.$inst_num";
    } else {
      $sop_instance_uid = "$mr_series_uid.$ct_seq";
      $ct_seq += 1;
    }
    $CtByZ{$z} = {
      sop_instance_uid => $sop_instance_uid,
      study_instance_uid => $study_uid,
      series_instance_uid => $ct_series_uid,
    };
    $ds->Insert("(0008,0018)", $sop_instance_uid);
    $ds->Insert("(0020,000d)", $study_uid);
    $ds->Insert("(0020,000e)", $ct_series_uid);
    $ds->Insert("(0020,0052)", $for_uid);
    my $new_file_name = "$to_dir/CT_$sop_instance_uid.dcm";
    $ds->WritePart10($new_file_name, $xfr_stx, "POSDA_FIX", undef, undef);
  } elsif($modality eq 'MR'){
    die "not handling MR";
  } elsif($modality eq 'PT'){
    die "not handling PT";
  } elsif($modality eq 'RTSTRUCT'){
    if(defined $rt_ss) { die "more than one structure set" }
    $rt_ss = $ds;
    $rt_ss_xfr = $xfr_stx;
  } elsif($modality eq 'RTPLAN'){
    if(defined $rt_plan) { die "more than one plan" }
    $rt_plan = $ds;
    $rt_plan_xfr = $xfr_stx;
  } elsif($modality eq 'RTDOSE'){
    if(defined $rt_dose) { die "more than one dose" }
    $rt_dose = $ds;
    $rt_dose_xfr = $xfr_stx;
  } else {
    return;
  }
};
Posda::Find::SearchDir($ARGV[0], $wanted);
if(defined $rt_ss){
  my $sop_instance_uid = "$ss_series_uid.1";
  $rt_ss->Insert("(0008,0018)", $sop_instance_uid);
  $rt_ss->Insert("(0020,000d)", $study_uid);
  $rt_ss->Insert("(0020,000e)", $ss_series_uid);
  InsertReferencedForInRoi($rt_ss, $for_uid);
  MapContourReferences($rt_ss);
  RebuildRefForSeq($rt_ss, $for_uid);
  my $new_file_name = "$to_dir/RS_$sop_instance_uid.dcm";
  $rt_ss->WritePart10($new_file_name, $rt_ss_xfr, "POSDA_FIX", undef, undef);
}
if(defined $rt_plan){
  my $sop_instance_uid = "$rtp_series_uid.1";
  $rt_plan->Insert("(0008,0018)", $sop_instance_uid);
  $rt_plan->Insert("(0020,000d)", $study_uid);
  $rt_plan->Insert("(0020,000e)", $rtp_series_uid);
  $rt_plan->Insert("(300c,0060)[0](0008,1155)", "$ss_series_uid.1");
  my $new_file_name = "$to_dir/RP_$sop_instance_uid.dcm";
  $rt_plan->WritePart10(
    $new_file_name, $rt_plan_xfr, "POSDA_FIX", undef, undef);
}
if(defined $rt_dose){
  my $sop_instance_uid = "$rtd_series_uid.1";
  $rt_dose->Insert("(0008,0018)", $sop_instance_uid);
  $rt_dose->Insert("(0020,000d)", $study_uid);
  $rt_dose->Insert("(0020,000e)", $rtd_series_uid);
  $rt_dose->Insert("(300c,0002)[0](0008,1155)", "$rtp_series_uid.1");
  my $new_file_name = "$to_dir/Rd_$sop_instance_uid.dcm";
  $rt_dose->WritePart10(
    $new_file_name, $rt_plan_xfr, "POSDA_FIX", undef, undef);
}
sub InsertReferencedForInRoi{
  my($ds, $for) = @_;
  my $ref_for_list = $ds->Search("(3006,0020)[<0>](3006,0026)");
  if(ref($ref_for_list) eq "HASH"){
    my $list = $ref_for_list->{list};
print "ref_for_list: ";
Debug::GenPrint($dbg, $ref_for_list, 1);
print "\n";
    for my $i (@$list){
      my $index = $i->[0];
      $ds->Insert("(3006,0020)[$index](3006,0024)", $for);
    }
  }
}
sub MapContourReferences{
  my($ds) = @_;
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
    unless(defined $CtByZ{$z}){
      BuildCtMap($z);
      $closest_z = $CtMap{$z};
    }
    my $dist = abs($closest_z - $z);
    if($dist> $max_mapping_dist) { $max_mapping_dist = $dist }
    my $Uid = $CtByZ{$closest_z}->{sop_instance_uid};
    $ds->Insert("(3006,0039)[$r_i](3006,0040)[$rc_i](3006,0016)[0](0008,1150)",
      "1.2.840.10008.5.1.4.1.1.2");
    $ds->Insert("(3006,0039)[$r_i](3006,0040)[$rc_i](3006,0016)[0](0008,1155)",
      $Uid);
  }
  print "Maximum Mapping Distance: $max_mapping_dist\n";
}
sub RebuildRefForSeq{
  my($ds, $for) = @_;
  $ds->DeleteElementBySig("(3006,0010)[0](3006,0012)");
  $ds->Insert("(3006,0010)[0](0020,0052)", $for);
  my %Studies;
  for my $z (keys %CtByZ){
    my $item = $CtByZ{$z};
    $Studies{$item->{study_instance_uid}}->
      {$item->{series_instance_uid}}->{uid} = $z;
  }
  my $study_index = 0;
  for my $st (keys %Studies){
    $ds->InsertElementBySig(
      "(3006,0010)[0](3006,0012)[$study_index](0008,1150)",
      "1.2.840.10008.3.1.2.3.1"
    );
    $ds->InsertElementBySig(
      "(3006,0010)[0](3006,0012)[$study_index](0008,1155)",
      $st
    );
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
}
sub BuildCtMap{
  my($z) = @_;
  if(exists $CtMap{$z}){ return };
  my $closest_z;
  my $dist;
  for my $i (keys %CtByZ){
    unless(defined($closest_z)){ $closest_z = $i }
    unless(defined($dist)){ $dist = abs($z - $i) }
    if(abs($z - $i) < $dist){
      $closest_z = $i;
      $dist = abs ($z - $i);
    }
  }
  $CtMap{$z} = $closest_z;
}

