#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Nifti::Parser;
use Debug;
my $dbg = sub { print STDERR @_ };

my $usage = <<EOF;
Usage:
PopulateFileNiftiTp.pl <?bkgrnd_id?> <activity_id> <update_existing> <notify>
  or
PopulateFileNiftiTp.pl -h

Expects no lines on STDIN:

EOF


if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 3) { print $usage; exit }


my($invoc_id, $activity_id, $update_existing, $notify) = @ARGV;

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my $start = time;

my $cache_dir = $ENV{POSDA_CACHE_ROOT};
unless(-d $cache_dir){
  print "Error: Cache dir ($cache_dir) isn't a directory\n";
  exit;
}
unless(-d "$cache_dir/WorkerTemp"){
  mkdir "$cache_dir/WorkerTemp";
}
unless(-d "$cache_dir/WorkerTemp"){
  print "Error: Cache dir ($cache_dir) isn't a directory\n";
  exit;
}

my $dir = "$cache_dir/WorkerTemp/$invoc_id";
if(-d $dir) {
  print "Error: $dir already exists\n";
  exit;
}
unless(mkdir($dir) == 1) {
  print "Error ($!): couldn't mkdir $dir\n";
  exit;
}
my %Files;
Query('FileIdTypePathFromActivity')->RunQuery(sub {
  my($row) = @_;
  my($file_id, $file_type, $path) = @$row;
  $Files{$file_id} = {
    new_file => "$dir/$file_id",
    to_path => $path,
    type => $file_type
  };
}, sub{}, $activity_id);
my $get_file_nifti = Query('GetFileNifti');
my $create_file_nifti = Query('CreateFileNifti');
my $update_file_nifti = Query('UpdateFileNifti');
my $change_file_type = Query('ChangeFileType');
my $num_files = keys %Files;
my $current = 0;
my $num_skipped = 0;
my $num_not_parsed = 0;
my $num_inserted = 0;
my $num_updated = 0;
file:
for my $f (keys %Files){
  my $file_id = $f;
  my $file_type = $Files{$f}->{type};
  my $file_path = $Files{$f}->{to_path};
  my $existing_row;
  $get_file_nifti->RunQuery(sub{
    my($row) = @_;
    $existing_row = $row;
  }, sub{}, $file_id);
  $current += 1;
  $back->SetActivityStatus("processing $current of $num_files; ".
    "skipped: $num_skipped; inserted: $num_inserted; " .
    "not_parsed: $num_not_parsed; updated: $num_updated");
  if(defined $existing_row){
    unless($update_existing) { $num_skipped += 1; next file }
  }
  my $nifti;
  my $is_zip_file;
  if($file_type eq "Nifti Image"){
    $nifti = Nifti::Parser->new($file_path);
  } elsif($file_type eq "Nifti Image (gzipped)"){
    $nifti = Nifti::Parser->new_from_zip($file_path, $file_id, $dir);
  } elsif($file_type =~ /^gzip/){
    $nifti = Nifti::Parser->new_from_zip($file_path, $file_id, $dir);
  } elsif($file_type eq "parsed dicom file"){
    $nifti = Nifti::Parser->new($file_path);
  }
  unless(defined $nifti) { $num_not_parsed += 1; next file }

  # fix file_type if necessary
  my $nifti_file_type = "Nifti Image";
  if(exists $nifti->{is_from_zip}){
    $nifti_file_type = "Nifti Image (gzipped)";
  }
  if($nifti_file_type ne $file_type){
    $change_file_type->RunQuery(sub{}, sub{}, $nifti_file_type, $file_id);
  }
  # fix file_type if necessary

  my @parms;
  if(defined $existing_row){
    @parms = SetUpdateParms($nifti, $file_id);
    $update_file_nifti->RunQuery(sub{}, sub{}, @parms);
    $num_updated += 1;
  } else {
    @parms = SetInsertParms($nifti, $file_id);
    $create_file_nifti->RunQuery(sub{}, sub{}, @parms);
    $num_inserted += 1;
  }
}
my $elapsed = time - $start;
$back->WriteToEmail("Processed $num_files files in $elapsed seconds.\n");
$back->Finish("processed $current of $num_files; ".
    "skipped: $num_skipped; inserted: $num_inserted; " .
    "not_parsed: $num_not_parsed; updated: $num_updated");
sub SetInsertParms{
  my($nifti, $file_id) = @_;
  my @parms;
  push @parms, $file_id;
  SetRemainingParms(\@parms, $nifti);
  return @parms;
}
sub SetUpdateParms{
  my($nifti, $file_id) = @_;
  my @parms;
  SetRemainingParms(\@parms, $nifti);
  push @parms, $file_id;
  return @parms;
};
sub SetRemainingParms{
  my($parms, $nifti) = @_;
  my $p = $nifti->{parsed};
  push @$parms, $p->{magic};
  my $is_from_zip;
  if(exists $nifti->{is_from_zip}){
    $is_from_zip = 1;
  } else {
    $is_from_zip = 0;
  }
  push @$parms, $is_from_zip;
  push @$parms, $p->{descrip};
  push @$parms, $p->{aux_file};
  push @$parms, $p->{bitpix};
  push @$parms, $p->{datatype};
  push @$parms, $p->{dim}->[0];
  push @$parms, $p->{dim}->[1];
  push @$parms, $p->{dim}->[2];
  push @$parms, $p->{dim}->[3];
  push @$parms, $p->{dim}->[4];
  push @$parms, $p->{dim}->[5];
  push @$parms, $p->{dim}->[6];
  push @$parms, $p->{dim}->[7];
  push @$parms, $p->{pixdim}->[0];
  push @$parms, $p->{pixdim}->[1];
  push @$parms, $p->{pixdim}->[2];
  push @$parms, $p->{pixdim}->[3];
  push @$parms, $p->{pixdim}->[4];
  push @$parms, $p->{pixdim}->[5];
  push @$parms, $p->{pixdim}->[6];
  push @$parms, $p->{pixdim}->[7];
  push @$parms, $p->{intent_code};
  push @$parms, $p->{intent_name};
  push @$parms, $p->{intent_p1};
  push @$parms, $p->{intent_p2};
  push @$parms, $p->{intent_p3};
  push @$parms, $p->{cal_max};
  push @$parms, $p->{cal_min};
  push @$parms, $p->{scl_slope};
  push @$parms, $p->{scl_inter};
  push @$parms, $p->{slice_start};
  push @$parms, $p->{slice_end};
  push @$parms, $p->{slice_code};
  push @$parms, $p->{sform_code};
  push @$parms, $p->{srow_x}->[0];
  push @$parms, $p->{srow_x}->[1];
  push @$parms, $p->{srow_x}->[2];
  push @$parms, $p->{srow_x}->[3];
  push @$parms, $p->{srow_y}->[0];
  push @$parms, $p->{srow_y}->[1];
  push @$parms, $p->{srow_y}->[2];
  push @$parms, $p->{srow_y}->[3];
  push @$parms, $p->{srow_z}->[0];
  push @$parms, $p->{srow_z}->[1];
  push @$parms, $p->{srow_z}->[2];
  push @$parms, $p->{srow_z}->[3];
  push @$parms, $p->{xyzt_units};
  push @$parms, $p->{qform_code};
  push @$parms, $p->{quatern_b};
  push @$parms, $p->{quatern_c};
  push @$parms, $p->{quatern_d};
  push @$parms, $p->{q_offset_x};
  push @$parms, $p->{q_offset_y};
  push @$parms, $p->{q_offset_z};
  push @$parms, $p->{vox_offset};
};
