#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';

my $usage = <<EOF;
CopyNonDicomPropertiesFromNonDicomEditCompareBySubprocessInvocationId.pl <subprocess_invoc_id>
or
CopyNonDicomPropertiesFromNonDicomEditCompareBySubprocessInvocationId.pl -h

This script will use the query "GeFromToFilesFromNonDicomEditCompare" to get
from and to file_ids for a non_dicom edit.

Then it will copy the following columns from the from non_dicom_file row to
the to non_dicom_file row:

  file_type, file_sub_type, collection, site, subject

If no non_dicom_file row exists (the normal case), it will create one

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 0){
  die "$usage\n";
}

my @Copies;
my ($sub_process_invoc_id) = @ARGV;
my $q = Query('GeFromToFilesFromNonDicomEditCompare');
my $get_fields = Query('GetNonDicomFileTypeSubTypeCollectionSiteSubjectById');
my $put_fields = Query('UpdateNonDicomFileTypeSubTypeCollectionSiteSubjectById');
my $create_non_dicom = Query('CreateNonDicomFileById');
$q->RunQuery(sub {
  my($row) = @_;
  push(@Copies, $row);
}, sub {}, $sub_process_invoc_id);
my $num_copies = @Copies;
print "$num_copies files edited for $sub_process_invoc_id\n";
copy:
for my $copy(@Copies){
  my($from_id) = $copy->[0];
  my($to_id) = $copy->[1];
  my $fields;
  $get_fields->RunQuery(sub{
    my($row) = @_;
    $fields = $row;
  }, sub {}, $from_id);
  unless(defined $fields and ref($fields) eq "ARRAY"){
    print "Didn't find non_dicom_row for from file: $from_id\n";
    next copy;
  }
  my $new_fields;
  $get_fields->RunQuery(sub{
    my($row) = @_;
    $new_fields = $row;
  }, sub {}, $to_id);
  if(defined $new_fields and ref($new_fields) eq "ARRAY"){
    print "found non_dicom_row for to file: $to_id\n";
    print "update here\n";
  } else {
    print "didn't find non_dicom_row for to file: $to_id\n";
    $create_non_dicom->RunQuery(sub {}, sub {},
      $to_id,
      $fields->[0], $fields->[1], $fields->[2],
      $fields->[3], $fields->[4])
  }
}
