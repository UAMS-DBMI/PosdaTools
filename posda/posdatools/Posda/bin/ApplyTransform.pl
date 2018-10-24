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
use Posda::FlipRotate;
Posda::Dataset::InitDD();

my $usage = "usage: $0 <transform> <source> <target>\n\tsource and target are directories";
unless($#ARGV == 2) {die $usage}

my $dir = getcwd;
my $transform = $ARGV[0];
my $from_dir = $ARGV[1];
my $to_dir = $ARGV[2];
unless($from_dir =~ /^\//) { $from_dir = "$dir/$from_dir" }
unless($to_dir =~ /^\//) { $to_dir = "$dir/$to_dir" }

unless(-d $from_dir) { die "$from_dir is not a directory" }
unless(-d $to_dir) { die "$to_dir is not a directory" }
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
chomp $host;
chomp $user;
my $uid_root = Posda::UID::GetPosdaRoot({
  app => "ApplyTransform",
  user => $user,
  host => $host,
  purpose => "Initialize Anonymizer",
});
my $uid_seq = 1;

my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($transform);
unless($ds) { die "$transform is not a transform" };
my $modality = $ds->ExtractElementBySig("(0008,0060)");
unless($modality eq "REG") {
   die "transform is not a Spatial Registration Object"
}
my $raw_xform = $ds->ExtractElementBySig(
  "(0070,0308)[1](0070,0309)[0](0070,030a)[0](3006,00c6)"
);
unless($raw_xform && ref($raw_xform) eq "ARRAY" && $#{$raw_xform} == 15){
  die "$transform doesn't have a legal transform"
}
my $x_form = [
  [$raw_xform->[0], $raw_xform->[1], $raw_xform->[2], $raw_xform->[3]],
  [$raw_xform->[4], $raw_xform->[5], $raw_xform->[6], $raw_xform->[7]],
  [$raw_xform->[8], $raw_xform->[9], $raw_xform->[10], $raw_xform->[11]],
  [$raw_xform->[12], $raw_xform->[13], $raw_xform->[14], $raw_xform->[15]],
];
my $to_for = $ds->ExtractElementBySig("(0020,0052)");
my $from_for = $ds->ExtractElementBySig("(0070,0308)[1](0020,0052)");
print "Transform:\n";
Posda::Transforms::PrintTransform($x_form);
print "Transforms from for:\n";
print "$from_for\n";
print "to for:\n";
print "$to_for\n";
my $new_series = "$uid_root.$uid_seq";
$uid_seq += 1;
my $handle = sub {
  my($path, $df, $ds, $size, $xfr_stx, $errors) = @_;
  my $for = $ds->ExtractElementBySig("(0020,0052)");
  unless($for eq $from_for) { return }
  $ds->InsertElementBySig("(0020,0052)", $to_for);
  my $rows = $ds->ExtractElementBySig("(0028,0010)");
  my $cols = $ds->ExtractElementBySig("(0028,0011)");
  my $iop = $ds->ExtractElementBySig("(0020,0037)");
  my $ipp = $ds->ExtractElementBySig("(0020,0032)");
  my $pix_sp = $ds->ExtractElementBySig("(0028,0030)");
  my($tlhc, $trhc, $blhc, $brhc) = Posda::FlipRotate::ToCorners(
    $rows, $cols, $iop, $ipp, $pix_sp
  );
  my $t_tlhc = Posda::Transforms::ApplyTransform($x_form, $tlhc);
  my $t_trhc = Posda::Transforms::ApplyTransform($x_form, $trhc);
  my $t_blhc = Posda::Transforms::ApplyTransform($x_form, $blhc);
  my $t_brhc = Posda::Transforms::ApplyTransform($x_form, $brhc);
  my($n_iop, $n_ipp) = Posda::FlipRotate::FromCorners(
    $t_tlhc, $t_trhc, $t_blhc, $t_brhc
  );
  $ds->DeleteElementBySig("(0020,0037)");
  $ds->DeleteElementBySig("(0020,0032)");
  $ds->InsertElementBySig("(0020,0037)", $n_iop);
  $ds->InsertElementBySig("(0020,0032)", $n_ipp);
my $count = scalar @{$n_iop};
print "length of iop $count\n";
$count = scalar @{$n_ipp};
print "length of ipp $count\n";
  my $new_uid = "$new_series.$uid_seq";
  $uid_seq += 1;
  $ds->InsertElementBySig("(0008,0018)", $new_uid);
  $ds->InsertElementBySig("(0020,000e)", $new_series);
  my $sop_inst = $ds->ExtractElementBySig("(0008,0018)");
  my $modality = $ds->ExtractElementBySig("(0008,0060)");
  my $dest_file = "$to_dir/${modality}_$sop_inst.dcm";
  print "Applied transform to $path\n";
  print "yielding:\n";
  print "$dest_file\n";
  my $r_iop = $ds->ExtractElementBySig("(0020,0037)");
$count = scalar @{$r_iop};
print "round trip length: $count\n";
  $ds->WritePart10($dest_file, $xfr_stx, "POSDA_XFORM", undef, undef);
};
Posda::Find::SearchDir($from_dir, $handle);
