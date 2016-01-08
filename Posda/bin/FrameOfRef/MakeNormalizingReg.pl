#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/FrameOfRef/MakeNormalizingReg.pl,v $
#$Date: 2015/05/31 23:31:40 $
#$Revision: 1.4 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::Dataset;
use Posda::Transforms;
use Posda::UID;

my $usage = "usage: $0 <file> <outdir> <x> <y> <z> <uid>";
unless($#ARGV >= 4) {die $usage}

my $dir = getcwd;
my $file_name = $ARGV[0]; my $out_dir = $ARGV[1];
unless($file_name=~/^\//){$file_name="$dir/$file_name"}
unless($out_dir=~/^\//){$out_dir="$dir/$out_dir"}
my $x = $ARGV[2];
my $y = $ARGV[3];
my $z = $ARGV[4];
my $new_uid = $ARGV[5];
my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file_name);
unless($ds) { die "$file_name didn't parse" };
unless(-d $out_dir) { die "$out_dir is not a directory" }
unless (defined $new_uid){
  my $user = `whoami`;
  my $host = `hostname`;
  chomp $user;
  chomp $host;
  $new_uid = Posda::UID::GetPosdaRoot({
    program => "Posda/bin/FrameOfRef/MakeOrthoNormalReg.pl",
    user => $user,
    host => $host,
    purpose => "Get new Frame of Reference UID",
  });
}

my $copy_elements = [
  "(0008,0020)",
  "(0008,0030)",
  "(0008,0050)",
  "(0008,0090)",
  "(0008,1030)",
  "(0008,103e)",
  "(0008,1048)",
  "(0010,0010)",
  "(0010,0020)",
  "(0010,0030)",
  "(0010,0040)",
  "(0010,1010)",
  "(0010,1030)",
  "(0018,1030)",
  "(0020,000d)",
  "(0020,0010)",
];

my $new_for_uid = "$new_uid.1";
my $new_series_uid = "$new_uid.2";
my $new_sop_inst_uid = "$new_uid.3";
my $old_for_uid = $ds->Get("(0020,0052)");
my $iop = $ds->Get("(0020,0037)");
print "Iop: [$iop->[0], $iop->[1], $iop->[2],\n" .
      "      $iop->[3], $iop->[4], $iop->[5]]\n";
printf "Iop: [%.14f, %.14f, %.14f,\n" .
       "      %.14f, %.14f, %.14f]\n",
  $iop->[0], $iop->[1], $iop->[2], $iop->[3], $iop->[4], $iop->[5];
my $xfm = Posda::Transforms::NormalizingImageOrientation($iop);
print "Rotation:\n";
Posda::Transforms::PrintTransform($xfm);
my $n_center = Posda::Transforms::ApplyTransform($xfm, [-$x, -$y, -$z]);
print "Center: [$n_center->[0], $n_center->[1], $n_center->[2]]\n";
my $xfp = [
  [$xfm->[0]->[0], $xfm->[0]->[1], $xfm->[0]->[2], $n_center->[0]],
  [$xfm->[1]->[0], $xfm->[1]->[1], $xfm->[1]->[2], $n_center->[1]],
  [$xfm->[2]->[0], $xfm->[2]->[1], $xfm->[2]->[2], $n_center->[2]],
  [$xfm->[3]->[0], $xfm->[3]->[1], $xfm->[3]->[2], $xfm->[3]->[3]],
];
print "Transform:\n";
Posda::Transforms::PrintTransform($xfp);
my $trans = [
  $xfp->[0]->[0], $xfp->[0]->[1], $xfp->[0]->[2], $xfp->[0]->[3],
  $xfp->[1]->[0], $xfp->[1]->[1], $xfp->[1]->[2], $xfp->[1]->[3],
  $xfp->[2]->[0], $xfp->[2]->[1], $xfp->[2]->[2], $xfp->[2]->[3],
  $xfp->[3]->[0], $xfp->[3]->[1], $xfp->[3]->[2], $xfp->[3]->[3],
];
my($sec, $min, $hr, $mday, $mon, $year, $wday, $yday, $isdst) = 
  localtime(time);
my $date = sprintf("%4d%02d%02d", $year + 1900, $mon + 1, $mday);
my $time = sprintf("%02d%02d%02d", $hr, $min, $sec);

my $new_ds = Posda::Dataset->new_blank();
for my $sig (@$copy_elements){
  $new_ds->Insert($sig, $ds->Get($sig));
}
$new_ds->Insert("(0008,0016)", "1.2.840.10008.5.1.4.1.1.66.1");
$new_ds->Insert("(0008,0060)", "REG");
$new_ds->Insert("(0008,0070)", "Posda.com");
$new_ds->Insert("(0020,0011)", "");
$new_ds->Insert("(0020,0013)", 1);
$new_ds->Insert("(0008,0018)", $new_sop_inst_uid);
$new_ds->Insert("(0020,0052)", $new_for_uid);
$new_ds->Insert("(0020,000e)", $new_series_uid);
$new_ds->Insert("(0070,0080)", "NORM_IMG");
$new_ds->Insert("(0070,0081)", "Normalize Image Orientation");
$new_ds->Insert("(0070,0084)", "Bennett^Bill");
$new_ds->Insert("(0008,0012)", $date);
$new_ds->Insert("(0008,0013)", $time);
$new_ds->Insert("(0008,0021)", $date);
$new_ds->Insert("(0008,0031)", $time);

$new_ds->Insert("(0070,0308)[0](0020,0052)", $new_for_uid);
$new_ds->Insert("(0070,0308)[0](0070,0309)[0](0070,030a)[0](0070,030c)",
  "RIGID");
$new_ds->Insert("(0070,0308)[0](0070,0309)[0](0070,030a)[0](3006,00c6)",
  [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
$new_ds->Insert("(0070,0308)[0](0070,0309)[0](0070,030d)[0](0008,0100)",
  125024);
$new_ds->Insert("(0070,0308)[0](0070,0309)[0](0070,030d)[0](0008,0102)",
  "DCM");
$new_ds->Insert("(0070,0308)[0](0070,0309)[0](0070,030d)[0](0008,0103)",
  "20040115");
$new_ds->Insert("(0070,0308)[0](0070,0309)[0](0070,030d)[0](0008,0104)",
  "Image Content-based Alignment");

$new_ds->Insert("(0070,0308)[1](0020,0052)", $old_for_uid);
$new_ds->Insert("(0070,0308)[1](0070,0309)[0](0070,030a)[0](0070,030c)",
  "RIGID");
$new_ds->Insert("(0070,0308)[1](0070,0309)[0](0070,030a)[0](3006,00c6)",
  $trans);
$new_ds->Insert("(0070,0308)[1](0070,0309)[0](0070,030d)[0](0008,0100)",
  125024);
$new_ds->Insert("(0070,0308)[1](0070,0309)[0](0070,030d)[0](0008,0102)",
  "DCM");
$new_ds->Insert("(0070,0308)[1](0070,0309)[0](0070,030d)[0](0008,0103)",
  "20040115");
$new_ds->Insert("(0070,0308)[1](0070,0309)[0](0070,030d)[0](0008,0104)",
  "Image Content-based Alignment");

my $out_file = "$out_dir/REG_$new_sop_inst_uid.dcm";
print "Writing File: $out_file\n";
$new_ds->WritePart10($out_file, $xfr_stx, "POSDA_CONSTRUCT", undef, undef);
