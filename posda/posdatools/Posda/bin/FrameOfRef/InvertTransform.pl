#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Posda::Dataset;
use Posda::Transforms;
use Posda::UID;
use Debug;
my $dbg = sub {print @_};

my $reg_name = $ARGV[0];

my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($reg_name);
unless($ds) { die "$reg_name didn't parse" };
my $dir;
if($reg_name =~ /(.*)\/[^\/]+$/){
  $dir = $1;
}
my $user = `whoami`;
my $host = `hostname`;
chomp $user;
chomp $host;
$uid_root = Posda::UID::GetPosdaRoot({
  program => "Posda/bin/FrameOfRef/InvertTransform.pl",
  user => $user,
  host => $host,
  purpose => "Get new UID Root",
});
my $index = 1;

my $reg_rcs = $ds->Get("(0020,0052)");

my $match = $ds->Search("(0070,0308)[<0>](0020,0052)");
unless(ref($match) eq "ARRAY") { die "didn't find transforms" }
for my $m (@$match){
  my $indx = $m->[0];
  my $old_sop_inst = $ds->Get("(0008,0018)");
  my $src_rcs = $ds->Get("(0070,0308)[$indx](0020,0052)");
  if($src_rcs eq $reg_rcs){ next }
  my $xform_type = $ds->Get(
    "(0070,0308)[$indx](0070,0309)[0](0070,030a)[0](0070,030c)");
  unless($xform_type eq "RIGID") {
    print STDERR "I only invert RIGID transforms (not $xform_type)\n";
    next;
  }
  my $xform = Posda::Transforms::MakeFromDicomXform(
    $ds->Get(
      "(0070,0308)[$indx](0070,0309)[0](0070,030a)[0](3006,00c6)")
  );
  my $inv_x = Posda::Transforms::InvertTransform($xform);
  my $trans = [
    $inv_x->[0]->[0], $inv_x->[0]->[1], $inv_x->[0]->[2], $inv_x->[0]->[3],
    $inv_x->[1]->[0], $inv_x->[1]->[1], $inv_x->[1]->[2], $inv_x->[1]->[3],
    $inv_x->[2]->[0], $inv_x->[2]->[1], $inv_x->[2]->[2], $inv_x->[2]->[3],
    $inv_x->[3]->[0], $inv_x->[3]->[1], $inv_x->[3]->[2], $inv_x->[3]->[3],
  ];

  my $new_sop_instance = "$uid_root.$index";
  $index++;
  my $new_series_uid = "$uid_root.$index";
  $index++;
  my $new_ds = Posda::Dataset->new_blank();
  $ds->MapTop(sub{
    my($nds, $el, $sig, $grp, $ele) = @_;
    if($el->{VR} ne "SQ"){
      $new_ds->Insert($sig, $el->{value});
    }
  });
  my($sec, $min, $hr, $mday, $mon, $year, $wday, $yday, $isdst) =
    localtime(time);
  my $date = sprintf("%4d%02d%02d", $year + 1900, $mon + 1, $mday);
  my $time = sprintf("%02d%02d%02d", $hr, $min, $sec);

  $new_ds->Insert("(0008,0070)", "Posda.com");
  $new_ds->Insert("(0020,0011)", "");
  $new_ds->Insert("(0020,0013)", 1);
  $new_ds->Insert("(0008,0018)", $new_sop_instance);
  $new_ds->Insert("(0020,0052)", $src_rcs);
  $new_ds->Insert("(0020,000e)", $new_series_uid);
  $new_ds->Insert("(0070,0080)", "INV_REG");
  $new_ds->Insert("(0070,0081)", "Invert $old_sop_inst");
  $new_ds->Insert("(0070,0084)", "Bennett^Bill");
  $new_ds->Insert("(0008,0012)", $date);
  $new_ds->Insert("(0008,0013)", $time);
  $new_ds->Insert("(0008,0021)", $date);
  $new_ds->Insert("(0008,0031)", $time);
  $new_ds->Insert("(0070,0308)[0](0020,0052)", $src_rcs);
  $new_ds->Insert("(0070,0308)[0](0070,0309)[0](0070,030a)[0](0070,030c)",
    "RIGID");
  $new_ds->Insert("(0070,0308)[0](0070,0309)[0](0070,030a)[0](3006,00c6)",
  [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
  $new_ds->Insert("(0070,0308)[0](0070,0309)[0](0070,030d)[0](0008,0100)",
    125021);
  $new_ds->Insert("(0070,0308)[0](0070,0309)[0](0070,030d)[0](0008,0102)",
    "DCM");
  $new_ds->Insert("(0070,0308)[0](0070,0309)[0](0070,030d)[0](0008,0103)",
    "20040115");
  $new_ds->Insert("(0070,0308)[0](0070,0309)[0](0070,030d)[0](0008,0104)",
    "Frame of Reference Identity");
  
  $new_ds->Insert("(0070,0308)[1](0020,0052)", $reg_rcs);
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
  my $file_name = "REG_$new_sop_instance.dcm";
  if($dir){
    $file_name = "$dir/$file_name";
  }
  $new_ds->WritePart10($file_name, $xfr_stx, "POSDA_CONSTRUCT", undef, undef);
}
