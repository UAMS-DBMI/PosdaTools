#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::Try;
use Posda::Dataset;

my $usage = <<EOF;
GetEditedFilesWithQuestionableStudyDescription.pl <sub_invoc_id>
or
GetEditedFilesWithQuestionableStudyDescription.pl -h

Goes into dicom_edit_compare table, gets file_ids of to files

Finds those with no file_study row.

Does a detailed comparison of "before" and "after" study description.

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 0){
  die "$usage\n";
}
my $sub_process_invoc_id = $ARGV[0];

my $get_dicom_edit_compare_from_to = Query("GetFromToDigestsEditCompare");
my $get_file_id = Query("GetFileIdAndVisibilityByDigest");
my $get_study = Query("GetStudyByFileId");
my $get_path = Query("GetFilePath");
my @DigestPairs;
$get_dicom_edit_compare_from_to->RunQuery(sub {
  my($row) = @_;
  my($from_digest, $to_digest) = @$row;
  push @DigestPairs, [$from_digest, $to_digest];
}, sub {}, $sub_process_invoc_id);
my @FilesWithMissingStudyInstanceUid;
for my $pair (@DigestPairs){
  my $from_file_id;
  my $to_file_id;
  print "##########\n";
  $get_file_id->RunQuery(sub {
    my($row) = @_;
    my($file_id, $ctp_file_id, $visibility) = @$row;
    unless(defined $visibility) { $visibility = '<undef>' }
    print "From file: $file_id, visibility: $visibility\n";
    $from_file_id = $file_id;
  }, sub {}, $pair->[0]);
  $get_file_id->RunQuery(sub {
    my($row) = @_;
    my($file_id, $ctp_file_id, $visibility) = @$row;
    unless(defined $visibility) { $visibility = '<undef>' }
    print "To file: $file_id, visibility: $visibility\n";
    $to_file_id = $file_id;
  }, sub {}, $pair->[1]);
  my $from_study;
  $get_study->RunQuery(sub {
    my($row) = @_;
    $from_study = $row->[0];
  }, sub {}, $from_file_id);
  unless(defined $from_study){
    print ">>>>>>>>>>>>>>>>From file has not study\n";
  }
  my $to_study;
  $get_study->RunQuery(sub {
    my($row) = @_;
    $to_study = $row->[0];
  }, sub {}, $to_file_id);
  unless(defined $to_study){
    print ">>>>>>>>>>>>>>>>To file has not study\n";
  }
}
