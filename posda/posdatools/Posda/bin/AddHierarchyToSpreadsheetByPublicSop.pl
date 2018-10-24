#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = <<EOF;
AddHierarchyToSpreadsheetByPublicSop.pl <new_root> 
AddHierarchyToSpreadsheetByPublicSop.pl [-h]
with -h prints help:
This script reads STDIN and expects lines in the following format:
<file>&<element>&<old_value>&<new_value>
...

No field is allowed to contain either an '&' or a \n

element may have a leading and trailing "-" (an attempt to defeat Excel's 
brain dead text conversion)

This script assumes that the file_name matches the regular expression:
/[\\/_]([\\d\\.]+)\\.dcm$/

It then assumes that \$1 is the sop_instance_uid and gets the public
database Patient, Study, Series, MR, Sop Hierarchy (using the query
named "GetPublicHierarchyBySopInstance")

The results are written as a csv on output with the following columns:
<file><patient_id><study_instance_uid><series_instance_uid><modality>
<sop_instance_uid><element_signature><old_value><new_value><new_file>
EOF
my $get_hierarchy = PosdaDB::Queries->GetQueryInstance(
"GetPublicHierarchyBySopInstance"
);
unless($#ARGV == 0) { print STDERR $usage; exit -1 }
if($ARGV[0] eq '-h') { print STDERR $usage; exit -1 }
my $new_root = $ARGV[0];
print "\"file\",\"patient_id\",\"study_instance_uid\"," .
    "\"series_instance_uid\",\"modality\",\"sop_instance_uid\"," .
    "\"element\",\"old_value\",\"new_value\",\"new_file\"\n";
while(my $line = <STDIN>){
  chomp $line;
  my($file, $element, $old_value, $new_value) = split(/&/, $line);
  if($element =~ /^\-(.*)\-$/) { $element = "'$1" }
  elsif($element =~ /^'\-(.*)\-$/) { $element = "'$1" }
  elsif($element =~ /^(\([\d,]+\))$/) { $element = "'$1" }
  my($patient_id, $study_instance_uid, $series_instance_uid, $modality,
    $sop_instance_uid, $new_file);
  if($file =~ /[\/_]([\d\.]+)\.dcm$/){
    $sop_instance_uid = $1;
print STDERR "sop_instance_uid: $sop_instance_uid\n";
    $get_hierarchy->RunQuery(
      sub {
        my($row) = @_;
        ($patient_id, $study_instance_uid, $series_instance_uid, $modality,
          $sop_instance_uid) = @$row;
        $new_file = "$new_root/$patient_id/$study_instance_uid/" .
          "$series_instance_uid/${modality}_$sop_instance_uid.dcm";
      },
      sub {
      },
      $sop_instance_uid
    );
  } else {
    print STDERR "Couldn't extract sop_instance_uid from $file\n";
    next;
  }
  print "\"$file\",\"$patient_id\",\"$study_instance_uid\"," .
    "\"$series_instance_uid\",\"$modality\",\"$sop_instance_uid\"," .
    "\"$element\",\"$old_value\",\"$new_value\",\"$new_file\"\n";
}
