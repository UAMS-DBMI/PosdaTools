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
use Posda::Dataset;
use Posda::Transforms;
use Posda::Find;
use Posda::UID;

my $usage = "usage: $0 <source dir> <target dir> <reg_obj> [ <uid_root> ]\n";
unless($#ARGV == 3 || $#ARGV == 2) {die $usage}
my $dir = getcwd;
my $from_dir = $ARGV[0];
my $to_dir = $ARGV[1];
my $reg_obj = $ARGV[2];
my $uid_root = $ARGV[3];
my $uid_seq = 1;
unless($from_dir =~ /^\//) {$from_dir = "$dir/$from_dir"}
unless($to_dir =~ /^\//) {$to_dir = "$dir/$to_dir"}
unless($reg_obj =~ /^\//) {$reg_obj = "$dir/$reg_obj"}

unless(-d $from_dir) { die "$from_dir is not a directory" }
unless(-d $to_dir) { die "$to_dir is not a directory" }
my($rdf, $rds, $rsize, $rxfr_stx, $rerrors) = Posda::Dataset::Try($reg_obj);
unless($rds) { die "$reg_obj didn't parse" };
unless($rds->Get("(0008,0016)") eq "1.2.840.10008.5.1.4.1.1.66.1"){
  die "$reg_obj is not a Spatial Registration Object"
}
my $dest_for = $rds->Get("(0020,0052)");
my %XformsFrom;
my $for_xlates = $rds->Search("(0070,0308)[<0>](0020,0052)");
if(ref($for_xlates) eq "ARRAY"){
  for my $for_x (@$for_xlates){
    my $indx = $for_x->[0];
    my $from_for = $rds->Get("(0070,0308)[$indx](0020,0052)");
    $XformsFrom{$from_for} = $dest_for;
  }
}

unless (defined $uid_root){
  my $user = `whoami`;
  my $host = `hostname`;
  chomp $user;
  chomp $host;
  $uid_root = Posda::UID::GetPosdaRoot({
    program => "Posda/bin/FrameOfRef/ApplyTransformImage.pl",
    user => $user,
    host => $host,
    purpose => "Get new UID base for Apply Transform to Images",
  });
}

my %UID_xlate;

my $handle = sub {
  my($path, $df, $ds, $size, $xfr_stx, $errors) = @_;
  if($path =~ /\/\.[^\/]+$/) {return}
  if($path =~ /^$to_dir/){ return }
  if($path eq $reg_obj) {return}
  my $sop_class = $ds->Get("(0008,0016)");

  my $source_for = $ds->Get("(0020,0052)");
  my $match = $rds->Search("(0070,0308)[<0>](0020,0052)", $source_for);
  my($xform, $xform_type, $rot, $xlate);
  if($#{$match} == 0){
    my $indx = $match->[0]->[0];
    $xform_type = $rds->Get(
      "(0070,0308)[$indx](0070,0309)[0](0070,030a)[0](0070,030c)");
    $xform = Posda::Transforms::MakeFromDicomXform(
    $rds->Get(
      "(0070,0308)[$indx](0070,0309)[0](0070,030a)[0](3006,00c6)"));
    ($rot, $xlate) = Posda::Transforms::SeparateRotationXlation($xform);
    $ds->Insert("(0020,0052)", $dest_for);
  }
  if($sop_class eq "1.2.840.10008.5.1.4.1.1.66.1"){
    my $rds_reg_rcs = $dest_for;
    my %RdsTransforms;
    my %DsTransforms;
    my $match = $rds->Search("(0070,0308)[<0>](0020,0052)");
    unless(ref($match) eq "ARRAY") {die "didn't find any transforms" }
    for my $m (@$match){
      my $indx = $m->[0];
      my $rds_src_rcs = $rds->Get("(0070,0308)[$indx](0020,0052)");
      if($rds_src_rcs eq $rds_reg_rcs){ next }
      $RdsTransforms{$rds_src_rcs} = {
        indx => $indx,
      };
    }
    my $ds_reg_rcs = $source_for;
    $match = $ds->Search("(0070,0308)[<0>](0020,0052)", $rds_reg_rcs);
    unless(ref($match) eq "ARRAY"){
      print STDERR "Can't apply REG:\n\t$reg_obj\nto REG:\n\t$path\n";
      return;
    }
    print STDERR "Could apply REG:\n\t$reg_obj\nto REG:\n\t$path\n" .
     "(but not implemented yet)\n";
    return;
  }

  # change UID's
  $ds->Map(sub {
    my($element, $root, $sig, $keys, $depth) = @_;
    unless(exists($element->{VR}) && $element->{VR} eq 'UI') {return}
    if($sig =~ /\(0020,0052\)$/){ return }
    if($sig =~ /\(3006,0024\)$/){ return }
    my $value = $element->{value};
    if(exists $Posda::Dataset::DD->{SopCl}->{$value}){return}
    if(exists $UID_xlate{$value}){
      $element->{value} = $UID_xlate{$value};
      return;
    }
    my $new_uid = "$uid_root.$uid_seq";
    $uid_seq += 1;
    $UID_xlate{$value} = $new_uid;
    $element->{value} = $new_uid;
  });

  if(
    $sop_class eq "1.2.840.10008.5.1.4.1.1.128"     || # PET
    $sop_class eq "1.2.840.10008.5.1.4.1.1.2"       || # CT
    $sop_class eq "1.2.840.10008.5.1.4.1.1.4"       || # MR
    $sop_class eq "1.2.840.10008.5.1.4.1.1.481.2"      # RT DOSE
  ){ 
    unless(defined $xform){
      print STDERR "Warning: REG doesn't transform $path\n";
      return;
    }
    my $source_ipp = $ds->Get("(0020,0032)");
    my $source_iop = $ds->Get("(0020,0037)");

    my $x_ipp = Posda::Transforms::ApplyTransform($xform, $source_ipp);
    my $x_iopr = Posda::Transforms::ApplyTransform($rot,
      [$source_iop->[0], $source_iop->[1], $source_iop->[2]]);
    my $x_iopc = Posda::Transforms::ApplyTransform($rot,
      [$source_iop->[3], $source_iop->[4], $source_iop->[5]]);
    my $x_iop = [$x_iopr->[0], $x_iopr->[1], $x_iopr->[2],
                $x_iopc->[0], $x_iopc->[1], $x_iopc->[2]];

    $ds->Insert("(0020,0032)", $x_ipp);
    $ds->Insert("(0020,0037)", $x_iop);
  } elsif (
    $sop_class eq "1.2.840.10008.5.1.4.1.1.481.5"      # RT PLAN
  ){
    if(defined $xform){
      print STDERR "Warning - not transforming RTPLAN - not implemented\n";
    } else {
      print STDERR "Warning RTPLAN has no or wrong FOR - no points mapped\n";
    }
  } elsif (
    $sop_class eq "1.2.840.10008.5.1.4.1.1.481.3"      # RT STRUCT
  ){
    my $xf_match = $ds->Search("(3006,0010)[<0>](0020,0052)");
    if(ref($xf_match) eq "ARRAY"){
      for my $xf (@$xf_match){
        my $indx = $xf->[0];
        my $xf_for = $ds->Get("(3006,0010)[$indx](0020,0052)");
        if(exists($XformsFrom{$xf_for})){
          $ds->Insert("(3006,0010)[$indx](0020,0052)", $XformsFrom{$xf_for});
        }
      }
    }
    my $match = $ds->Search("(3006,0020)[<0>](3006,0024)");
    if(ref($match) eq "ARRAY"){
      for my $m (@$match){
        my $i = $m->[0];
        my $name = $ds->Get("(3006,0020)[$i](3006,0026)");
        my $num = $ds->Get("(3006,0020)[$i](3006,0022)");
        my $for = $ds->Get("(3006,0020)[$i](3006,0024)");
        my $x_match = $rds->Search("(0070,0308)[<0>](0020,0052)", $for);
        if(ref($x_match) eq "ARRAY" && $#{$x_match} == 0){
          $ds->Insert("(3006,0020)[$i](3006,0024)", $dest_for);
          my $s_idx = $x_match->[0]->[0];
          my $s_xform = Posda::Transforms::MakeFromDicomXform(
            $rds->Get(
              "(0070,0308)[$s_idx](0070,0309)[0](0070,030a)[0](3006,00c6)"));
          my $c_match = $ds->Search(
            "(3006,0039)[<0>](3006,0084)", $num);
          if(ref($c_match) eq "ARRAY" && $#{$c_match} == 0){
            my $c_i = $c_match->[0]->[0];
            my $d_match = $ds->Search(
              "(3006,0039)[$c_i](3006,0040)[<0>](3006,0050)");
            if(ref($d_match) eq "ARRAY"){
              for my $dm (@$d_match){
                my $d_i = $dm->[0];
                my $c_data = $ds->Get(
                  "(3006,0039)[$c_i](3006,0040)[$d_i](3006,0050)");
                ####
                # xform data points here
                if(ref($c_data) eq "ARRAY"){
                  my $n_fs = scalar @$c_data;
                  if($n_fs % 3 == 0){
                    for my $ii (0 .. (($n_fs / 3) - 1)){
                      my $x = $c_data->[($ii * 3)];
                      my $y = $c_data->[($ii * 3) + 1];
                      my $z = $c_data->[($ii * 3) + 2];
                      my $new_pt = Posda::Transforms::ApplyTransform(
                        $s_xform, [$x, $y, $z]);
                      $c_data->[($ii * 3)] = $new_pt->[0];
                      $c_data->[($ii * 3) + 1] = $new_pt->[1];
                      $c_data->[($ii * 3) + 2] = $new_pt->[2];
                    }
                  } else {
                    print STDERR 
                     "Warning: ROI $name ($num) has contour data" .
                     " which is not a set of points - skipped\n";
                  }
                } else {
                  print STDERR 
                   "Warning: ROI $name ($num) has empty contour data\n";
                }
                ####
              }
            } else {
              print STDERR 
                "Warning: ROI $name ($num) has no contour data - no mapping\n";
            }
          } elsif(ref($c_match) ne "ARRAY"){
            print STDERR 
              "Warning: ROI $name ($num) has no contours - no mapping\n";
          } else {
            print STDERR 
              "Warning: ROI $name ($num) has multipe ROI contours matches -" .
              " no mapping\n";
          }
        } else {
          print STDERR 
            "Warning: no transform from FOR $for for ROI $name ($num)\n";
        }
      }
    } else {
      print STDERR "Warning: no ROI's in RTSTRUCT (no translation)\n";
    }
  } else {
     print STDERR "Don't try to map $path\n";
     return;
  }

  my $sop_inst = $ds->Get("(0008,0018)");
  my $modality = $ds->Get("(0008,0060)");
  my $dest_file = "$to_dir/$modality$sop_inst.dcm";
  print STDERR "Translated:\n\t$path\nTo:\n\t$dest_file\n";
  $ds->WritePart10($dest_file, $xfr_stx, "POSDA_XFORM", undef, undef);
};
Posda::Find::SearchDir($from_dir, $handle);
