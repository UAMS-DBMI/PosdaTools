#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::Find;
use Posda::Try;
use Posda::UUID;
use strict;
sub MakeUidChanger{
  my($uid_map) = @_;
  my $sub = sub {
    my($element, $root, $sig, $keys, $depth) = @_;
    unless(exists($element->{VR}) && $element->{VR} eq 'UI') {return}
    my $value = $element->{value};
    unless(defined($value)){ return }
    if(exists $Posda::Dataset::DD->{SopCl}->{$value}){return}
    if(exists $uid_map->{translation}->{$value}){
      $element->{value} = $uid_map->{translation}->{$value};
      return;
    }
    my $new_uid = "$uid_map->{uid_root}.$uid_map->{uid_seq}";
    $uid_map->{uid_seq} += 1;
    $uid_map->{translation}->{$value} = $new_uid;
    $element->{value} = $uid_map->{translation}->{$value};
  };
  return $sub;
}
sub MakeFinder{
  my($from_dir, $to_dir, $substitutions, $uid_mappings) = @_;
  my $finder = sub {
    my($try) = @_;
    unless(exists $try->{dataset}){ return }
    my $ds = $try->{dataset};
    my $sop_class = $ds->Get("(0008,0016)");
    unless($sop_class) { return }
    for my $i (keys %$substitutions){
      $ds->Insert($i, $substitutions->{$i});
    }
    if($uid_mappings && ref($uid_mappings) eq "HASH"){
      $ds->Map(MakeUidChanger($uid_mappings));
    }
    my $sop_inst = $ds->Get("(0008,0018)");
    my $modality = $ds->Get("(0008,0060)");
    my $from_file = $try->{filename};
    my $s_pre = Posda::DataDict::GetSopClassPrefix($sop_class);
    my $to_file = "$to_dir/$s_pre" . "_$sop_inst.dcm";
    $ds->WritePart10($to_file, $try->{xfr_stx}, "POSDA", undef, undef);
    print "############\nfrom: $from_file\nto:   $to_file\n";
  };
  return $finder;
}
my $usage =  "usage: IheRoAnonmizer.pl  <source zip> <target name> " .
  "<patient_id> <patient_name> <patient_dob>";
unless($#ARGV == 4) { die $usage }
my $cwd = getcwd;
my $source_archive = $ARGV[0];
my $target_name = $ARGV[1];
my $patient_id = $ARGV[2];
my $patient_name = $ARGV[3];
my $patient_dob = $ARGV[4];
unless($source_archive =~ /^\//) { $source_archive = "$cwd/$source_archive" }
unless($target_name =~ /^\//) { $target_name = "$cwd/$target_name" }
unless($source_archive =~ /\.zip$/) { die "$source_archive is not a zip file" }
unless(-f $source_archive) { die "$source_archive is not a file" }
my($target_dir, $target_file) = $target_name =~ /(^.+)\/([^\/]+)$/;
unless(-d $target_dir) { die "$target_dir is not a directory" }
if(-e $target_name) { die "$target_name already exists" }
my($target_type, $target_sub_dir);
my($zip_file_root, my $ext) = $target_file =~ /^(.*)\.([^\.]+)$/;
if(
  defined($zip_file_root) &&
  defined($ext) &&
  $ext eq "zip"
){
  $target_type = "zip";
  $target_sub_dir = "$target_dir/$zip_file_root";
} else {
  $target_type = "dir";
  $target_sub_dir = "$target_dir/$target_file";
}
my($source_dir, $source_file) = $source_archive =~ /^(.+)\/([^\/]+)$/;
if(-d $target_sub_dir) { die "$target_sub_dir already exists" }
unless(-d $target_dir) { die "$target_dir doesn't exist" }
my $count = mkdir($target_sub_dir);
unless($count == 1) { die "couldn't make $target_sub_dir ($!)" }
$count = mkdir("$target_sub_dir/from");
unless($count == 1) { die "couldn't make $target_sub_dir/from ($!)" }
$count = mkdir("$target_sub_dir/to");
unless($count == 1) { die "couldn't make $target_sub_dir/from ($!)" }
my $cmd = "cp \"$source_archive\" \"$target_sub_dir/from\"";
print "command: $cmd\n";
`$cmd`;
$cmd = "cd \"$target_sub_dir/from\";unzip \"$source_file\";rm \"$source_file\"";
print "command: $cmd\n";
`$cmd`;
my $uid_mapper = {
    uid_root => Posda::UUID::GetUUID,
    uid_seq => 1,
    translation => {},
  };
my $subs = {
  "(0010,0010)" => $patient_name,
  "(0010,0020)" => $patient_id,
  "(0010,0030)" => $patient_dob,
};
Posda::Find::DicomOnly("$target_sub_dir/from", 
  MakeFinder("$target_sub_dir/from", "$target_sub_dir/to", $subs, $uid_mapper));
$cmd = "rm -rf \"$target_sub_dir/from\"";
print "command: $cmd\n";
`$cmd`;
$cmd = "mv \"$target_sub_dir\" \"$target_sub_dir" . "_foo\"";
print "command: $cmd\n";
`$cmd`;
$cmd = "mv \"$target_sub_dir" . "_foo/to\" \"$target_sub_dir\"";
print "command: $cmd\n";
`$cmd`;
$cmd = "rm -rf \"$target_sub_dir" . "_foo\"";
print "command: $cmd\n";
`$cmd`;
print "Target_type: $target_type\n";
if($target_type eq "zip"){
  my $cmd = "cd \"$target_dir\"; zip \"$zip_file_root.zip\" -r \"$zip_file_root\"; rm -rf \"$zip_file_root\"";
  print "command: $cmd\n";
  `$cmd`;
}
