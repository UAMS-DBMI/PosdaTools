#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
my $usage = "usage: HideNonDicomFile.pl <file_id>  <user> <reason>\n";
unless($#ARGV == 2) { die $usage }
my $file_id = $ARGV[0];
my $user = $ARGV[1];
my $reason = $ARGV[2];
my $get_info = Query("GetNonDicomConversionInfoById");
my $insert_change_row = Query('CreateNonDicomFileChangeRow');
my $update = Query('UpdateNonDicomFileById');
my($path, $file_type, $file_sub_type, $collection, $site, $subject,
  $visibility, $size, $date_last_categorized);
$get_info->RunQuery(sub {
  my($row) = @_;
  ($path, $file_type, $file_sub_type, $collection, $site, $subject,
  $visibility, $size, $date_last_categorized) = @$row;
}, sub {}, $file_id);
unless(defined $visibility) { $visibility = "<undef>" }
$insert_change_row->RunQuery(sub {}, sub{},
  $file_id, $file_type, $file_sub_type,
  $collection, $site, $subject,
  $visibility, $date_last_categorized,
  $user, $reason);
$update->RunQuery(sub{}, sub {},
  $file_type, $file_sub_type,
  $collection, $site, $subject,
  "manually hidden", $file_id);
