#!/usr/bin/perl -w
use strict;
use Posda::DB qw(Query GetHandle);
use Posda::DB::Modules;
use Posda::Try;

my $usage = <<EOF;
ProcessModules.pl <file_id>
Processes Modules for IOD for file if modules don't exist.
EOF
my $file_id = $ARGV[0];
my $get_fp = Query('FilePathByFileId');
my $get_pi = Query('GetPatientInfoById');
my $get_sti = Query('GetStudyInfoById');
my $get_sri = Query('GetSeriesInfoById');
my $get_equ = Query('GetEquipmentInfoById');
my $handle = GetHandle('posda_files');
my $file_path;
$get_fp->RunQuery(sub {
  my($row) = @_;
  $file_path = $row->[0];
},sub{}, $file_id);
my $pat_exists = 0;
$get_pi->RunQuery(sub {
  my($row) = @_;
  $pat_exists = 1;
},sub{}, $file_id);
my $study_exists = 0;
$get_sti->RunQuery(sub {
  my($row) = @_;
  $study_exists = 1;
},sub{}, $file_id);
my $series_exists = 0;
$get_sri->RunQuery(sub {
  my($row) = @_;
  $series_exists = 1;
},sub{}, $file_id);
my $equip_exists = 0;
$get_equ->RunQuery(sub {
  my($row) = @_;
  $equip_exists = 1;
},sub{}, $file_id);
print "File: $file_path\n";
if($pat_exists){
  print "has file_patient\n";
} else {
  print "has no file_patient\n";
}
if($study_exists){
  print "has file_study\n";
} else {
  print "has no file_study\n";
}
if($series_exists){
  print "has file_series\n";
} else {
  print "has no file_series\n";
}
if($equip_exists){
  print "has file_equipment\n";
} else {
  print "has no file_equipment\n";
}
my $try = Posda::Try->new($file_path);
unless(exists $try->{dataset}){
  die "Not a DICOM IOD";
}
unless($pat_exists){
  Posda::DB::Modules::Patient($handle, $try->{dataset}, $file_id, {}, []);
}
unless($study_exists){
  Posda::DB::Modules::Study($handle, $try->{dataset}, $file_id, {}, []);
}
unless($series_exists){
  Posda::DB::Modules::Series($handle, $try->{dataset}, $file_id, {}, []);
}
unless($equip_exists){
  Posda::DB::Modules::Equipment($handle, $try->{dataset}, $file_id, {}, []);
}
