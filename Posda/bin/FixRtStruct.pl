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

my $usage = "usage: $0 <file>";
unless($#ARGV == 0) {die $usage}
my $infile = $ARGV[0];
unless($infile =~ /^\//) {$infile = getcwd."/$infile"}

my %CTsByZ;
my %CTsByFile;
my %CTsByUid;
my %CtMap;
my $struct;
my %ContourRefByZ;
my %ContourRefByUid;
my $UidMap;
Posda::Dataset::InitDD();
my $finder = sub {
  my($file_name, $df, $ds, $size, $xfr_stx, $errors) = @_;
  my $modality = $ds->ExtractElementBySig("(0008,0060)");
  if($modality eq "CT"){
    my $z = $ds->ExtractElementBySig("(0020,0032)[2]");
    if(defined $CTsByZ{$z}){
      print STDERR "two CTs at $z: $CTsByZ{$z} and $file_name\n";
    }
    $CTsByZ{$z} = $file_name;
    my $UID = $ds->ExtractElementBySig("(0008,0018)");
    my $Study_UID = $ds->ExtractElementBySig("(0020,000d)");
    my $Series_UID = $ds->ExtractElementBySig("(0020,000e)");
    $CTsByFile{$file_name} = $UID;
    if(defined $CTsByUid{$UID}){
      print STDERR "Two CT's with same UID ($UID):\n" .
        "\t$file_name\n\t$CTsByUid{$UID}->{file}\n";
    }
    $CTsByUid{$UID} = {
      file => $file_name,
      z => $z,
      study_uid => $Study_UID,
      series_uid => $Series_UID,
    };
  } elsif($modality eq "RTSTRUCT"){
    if(defined $struct){
      print STDERR "two structs $struct and $file_name\n";
    }
    $struct = $file_name;
  }
};
Posda::Find::SearchDir($infile, $finder);
my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($struct);
unless($ds) { die "can't parse $struct" }
my $ct_cont_ref = $ds->Substitutions(
  "(3006,0039)[<0>](3006,0040)[<1>](3006,0016)[<2>](0008,1155)"
);
for my $inst (@{$ct_cont_ref->{list}}){
  my $r_i = $inst->[$ct_cont_ref->{index_list}->{"<0>"}];
  my $rc_i = $inst->[$ct_cont_ref->{index_list}->{"<1>"}];
  my $rc_i_i = $inst->[$ct_cont_ref->{index_list}->{"<2>"}];
  my $z = $ds->ExtractElementBySig(
    "(3006,0039)[$r_i](3006,0040)[$rc_i](3006,0050)[2]"
  );
  my $UID = $ds->ExtractElementBySig(
    "(3006,0039)[$r_i](3006,0040)[$rc_i](3006,0016)[$rc_i_i](0008,1155)"
  );
  unless(defined $CTsByZ{$z}){
    BuildCtMap($z);
  }
  if(exists $ContourRefByZ{$z} && $ContourRefByZ{$z} ne $UID){
    print STDERR "Two different UID's are referenced for " .
     "Contours with z = $z:\n\t$UID\n\t$ContourRefByZ{$z}\n";
  }
  $ContourRefByZ{$z} = $UID;
  if(exists $ContourRefByUid{$UID} && $ContourRefByUid{$UID} ne $z){
    print STDERR "Two different z's are referenced for " .
     "Contours with UID = $UID:\n\t$z\n\t$ContourRefByUid{$UID}\n";
  }
  $ContourRefByUid{$UID} = $z;
}
my %OldUidToNew;
my $maximum_map_dist = 0;
for my $z (sort {$a <=> $b} keys %ContourRefByZ){
  if(exists $CTsByZ{$z}){
    my $OldUid = $ContourRefByZ{$z};
    my $NewUid = $CTsByFile{$CTsByZ{$z}};
    $OldUidToNew{$OldUid} = $NewUid;
  } elsif (exists $CtMap{$z}){
    unless(exists $CTsByZ{$CtMap{$z}}){ die "something wrong here" }
    my $map_dist = abs($z - $CtMap{$z});
    if($map_dist > $maximum_map_dist){
      $maximum_map_dist = $map_dist;
    }
  } else {
    print "\tUndefined $z\n";
  }
}
print "Maximum Mapping Distance: $maximum_map_dist\n";
for my $i (keys %OldUidToNew){
  print "Map $i\nTo $OldUidToNew{$i}\n\n";
}
#
# Delete RT Referenced Study Sequence
#
$ds->DeleteElementBySig("(3006,0010)[0](3006,0012)");

#
# Map all the Contour References
#
$ds->Map(
  sub {
    my($element, $root, $sig, $list, $depth) = @_;
    unless(defined $element->{VR}){
       print "VR undefined for $sig\n";
       return;
    }
    if($element->{VR} eq 'UI'){
      if(defined $OldUidToNew{$element->{value}}){
        print  "Translating $element->{value}\n" .
               "         to $OldUidToNew{$element->{value}}\n";
        $element->{value} = $OldUidToNew{$element->{value}};
      }
    }
  }
);

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
      { $Studies{$st}->{$ser}->{$a} <=> $Studies{$st}->{$ser}->{$b} }
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
my $new_file_name = "$struct.new";
$ds->WritePart10($new_file_name, $xfr_stx, "POSDA_SCRIPT", undef, undef);

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
