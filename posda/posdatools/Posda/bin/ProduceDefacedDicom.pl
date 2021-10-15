#!/usr/bin/perl -w
use strict;
use Posda::Try;
use Posda::UUID;
use Nifti::Parser;
use Posda::DB qw(Query);
use Digest::MD5;

my $usage = <<EOF;
ProduceDefacedDicom.pl <original_nifti_file_id> <nifti_slice_number> <temp_dir> [<unzipped_path>]

Queries Used:
  GetFilePath
  GetDicomFileForDefacingFromNiftiSlice
  GetDefacedNiftiFileIdFromOriginal
  GetFileType

EOF
my($from_nifti, $nifti_sn, $temp_dir, $unzipped_path) = @ARGV;
unless(-d $temp_dir) { die "$temp_dir is not a directory" }
my $from_nifti_path = Query('GetFilePath')
  ->FetchOneHash($from_nifti)->{path};
my $to_nifti = Query('GetDefacedNiftiFileIdFromOriginal')
  ->FetchOneHash($from_nifti)->{file_id};
my $to_nifti_path = Query('GetFilePath')
  ->FetchOneHash($to_nifti)->{path};
my $from_dicom = Query('GetDicomFileForDefacingFromNiftiSlice')
  ->FetchOneHash($from_nifti, $nifti_sn)->{dicom_file_id};
my $from_dicom_path = Query('GetFilePath')
  ->FetchOneHash($from_dicom)->{path};
my $try = Posda::Try->new($from_dicom_path);
unless(exists $try->{dataset}){
  die "Posda file $from_dicom ($from_dicom_path) failed to parse";
}
my $ds = $try->{dataset};
my $to_nifti_type = Query('GetFileType')
  ->FetchOneHash($to_nifti)->{file_type};
my $f_nifti = Nifti::Parser->new($from_nifti_path, $from_nifti);
my $nifti;
if(defined $unzipped_path){
  $nifti = Nifti::Parser->new($unzipped_path, $to_nifti);
  unless(defined $nifti) {
    die "Passed unzipped path ($unzipped_path) didn't parse";
  }
} else {
  if($to_nifti_type eq "Nifti Image (gzipped)"){
    $nifti = Nifti::Parser->new_from_zip($to_nifti_path, $to_nifti, $temp_dir);
  } elsif($to_nifti_type eq "Nifti Image"){
    $nifti = Nifti::Parser->new($to_nifti_path, $to_nifti);
  } else {
    die "Unrecognized file type for nifti: $to_nifti_type";
  }
}
my $series_instance_uid = $ds->Get("(0020,000e)");
my $ctx = Digest::MD5->new;
$ctx->add($series_instance_uid);
my $dig = $ctx->digest;
my $new_series = "2.25." . Posda::UUID::FromDigest($dig);

my $series_desc = $ds->Get("(0008,103e)");
my $new_series_desc = "Defaced: $series_desc";

my $sop_instance_uid = $ds->Get("(0008,0018)");
$ctx = Digest::MD5->new;
$ctx->add($sop_instance_uid);
$dig = $ctx->digest;
my $new_sop = "2.25." . Posda::UUID::FromDigest($dig);

my $old_pix = $ds->Get("(7fe0,0010)");
my $new_pix = $nifti->GetSliceFlipped(0, $nifti_sn);
my $o_nif_pix = $nifti->GetSliceFlipped(0, $nifti_sn);

my $dicom_inter = $ds->Get("(0028,1052)");
my $dicom_slope = $ds->Get("(0028,1053)");
my $nifti_inter = $nifti->{parsed}->{scl_inter};
my $nifti_slope = $nifti->{parsed}->{scl_slope};
unless($dicom_inter == $nifti_inter){
  unless($dicom_inter == -1024 && $nifti_inter == 0){
    die "Defacing changed slope/intercept and not from -1024 to 0 - not yet supported";
  }
  ## Apply inverse slope/intercept to pixels
  my($offset, $length, $row_size) = $nifti->GetSliceOffsetLengthAndRowLength(0, $nifti_sn);
  my @image = unpack('S*', $new_pix);
  for my $i (0 .. $#image){
    $image[$i] += 1024;
  }
  $new_pix = pack('S*', @image);
}
## Now calculate a difference slice
my $d_pix;
{
  my @o_img = unpack('S*', $old_pix);
  my @n_img = unpack('S*', $new_pix);
  my @d_img;
  for my $i (0 .. $#o_img){
    $d_img[$i] = sqrt(($o_img[$i] - $n_img[$i])*($o_img[$i] - $n_img[$i]));
  }
  $d_pix = pack('S*', @d_img);
}
#open OIMG, ">$temp_dir" . "/$from_nifti" . "-$nifti_sn.from";
#print OIMG $old_pix;
#close OIMG;
#open NIMG, ">$temp_dir" . "/$from_nifti" . "-$nifti_sn.to";
#print NIMG $new_pix;
#close NIMG;
my $d_slice = $temp_dir . "/$from_nifti" . "_$nifti_sn.diff";
open DIFF, ">$d_slice";
print DIFF $d_pix;
close DIFF;

my $n_slice_dig = $nifti->FlippedSliceDigest(0, $nifti_sn);
my $o_slice_dig = $f_nifti->FlippedSliceDigest(0, $nifti_sn);

$ctx = Digest::MD5->new;
$ctx->add($old_pix);
my $old_d_dig = $ctx->hexdigest;

$ctx = Digest::MD5->new;
$ctx->add($new_pix);
my $n_dig = $ctx->hexdigest;

$ctx = Digest::MD5->new;
$ctx->add($d_pix);
my $d_dig = $ctx->hexdigest;

my $new_file = "$temp_dir/$new_sop.dcm";

## Do the edits
$ds->Insert("(0008,0018)", $new_sop);
$ds->Insert("(0020,000e)", $new_series);
$ds->Insert("(0008,103e)", $new_series_desc);
$ds->Insert("(7fe0,0010)", $new_pix);
$ds->WritePart10($new_file, $try->{xfr_stx}, "POSDA", undef, undef);
############################

print "original_nifti: $from_nifti ($from_nifti_path)\n";
print "defaced_nifti: $to_nifti ($to_nifti_path)\n";
print "original_dicom: $from_dicom ($from_dicom_path)\n";
print "old_series_desc: \"$series_desc\"\n";
print "new_series_desc: \"$new_series_desc\"\n";
print "old_series_instance_uid: $series_instance_uid\n";
print "new_series_instance_uid: $new_series\n";
print "old_sop_instance_uid: $sop_instance_uid\n";
print "new_sop_instance_uid: $new_sop\n";
print "Dicom_s_i: $dicom_slope/$dicom_inter\n";
print "Nifti_s_i: $nifti_slope/$nifti_inter\n";
print "old_pix_digest_dicom: $old_d_dig\n";
print "old_pix_digest_nifti: $o_slice_dig\n";
print "new_pix_digest_dicom: $n_dig\n";
print "new_pix_digest_nifti: $n_slice_dig\n";
print "new_dicom_file: $new_file\n";
print "difference_slice: $d_slice\n";
print "diff_pix_digest: $d_dig\n";
