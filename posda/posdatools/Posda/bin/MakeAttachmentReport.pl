#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::MakeAttachmentReport;
use Posda::Dataset;
use Posda::PrivateDispositions;
use Data::UUID;
use File::Path 'rmtree';
our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}
my $usage = <<EOF;
MakeAttachmentReport.pl <patient_id>
or
MakeAttachmentReport.pl -h

This script creates two files for a given patient and uploads
them to Posda.  These two files must be created concurrently
because they reference one another.  The two files are the
following:
  - zip file of all of the non-dicom files related to the 
    patient with a manifest at the top level which 
    associates this zip with a particular DICOM series.
  - A DICOM Basic Text SR object which is in this study.
    As content, this contains a description of the contents
    of the zip file.

The current data is needed to create a DICOM 
basic Text SR object:
	accession number - null
	collection - obtain from patient_mapping
	patient_id - supplied
	patient_name - same as patient_id
	patient_sex - set to null
	series_instance_uid - generate random new one
	site_id - obtain from patient_mapping
	site_name - obtain from patient_mapping
	sop_inst - generate random new one
	study_date - get max(study_date) for other
                     studies for patient
	study_instance_uid - generate random new one
        series_date - use study_date
	study_time - noon
	series_time - noon
        study_description - "Description of zip attachment"
        series_description - "Description of zip attachment"
	text_goes_here - generate a description of what
                         in the attached zip file

The following information is needed to create the manifest of
the zipfile.
  - the "manifest uid" of the manifest. Generate a random new one.
  - the study uid of the manifest.  Should be same as study uid of 
    report.
  - the series uid of the manifest.  Should be the same as the series
    uid of the report.
  - the pt-id of the manifest.  Same as all the other patient_ids
  - the date of the manifest.  Use study_date.
  - verison of the manifest.  = 1.

Here's what the program does:
  1) It uses the supplied patient id to do the following:
     a) Gather a list on non-dicom files for the specified patient_id
        use the Query: "GetNonDicomFilesByPatientId"
     b) Get the collection and site for the patient (if not unique,
        then this is an error) from patient mapping.
        If it doesn't match collection, site for any file, then
        its an error.
     c) Get UID root from patient_mapping. 
        Use the Query: PatientIdMappingByToPatientId
        If no rows found, its an error.
     d) Get max(study_date) for the patients DICOM files. Use the
        Query: GetMaxStudyDate
        If no rows returned, its an error.
        If result is null, its an error.
     e) Set Study and Series Description = "Description of zip attachment"
  2) Generates new uids using the UID root:
     a) New study instance UID
     b) New series instance UID
     c) New SOP instance UID for SR Basic Text DICOM object
     d) New Manifest UID for the attachment
  2.5) Create a text report about the intended contents of the 
     zip file for inclusion in the DICOM SR Object.  
  3) Create a temp directory under \$POSDA_CACHE_ROOT/edits from
     a UUID.  In this directory, create another directory
     (manifest directory), using the Manifest UID as the name.
  4) Link all of the non-dicom files into the manifest directory.
  5) Create a manifest file in manifest  directory.
  6) Create a zip file of the manifest directory in the temp
     directory.
  7) Import this file into Posda and retrieve its file_id.
  8) Delete the zip file (its already in Posda) and the 
     manifest directory.
  9) Create a row in non_dicom_file for this file.
  10) Create a DICOM SR Object using the module Posda::MakeAttachmentReport
     Create the file in the temp directory, call it 
     SR_<sop_instance_uid>.dcm.  Then import this object into Posda, and
     retrieve its file_id. Then delete the temp directory.
  11) Create a row in non_dicom_attachments.
EOF

### Process Args
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  die $usage;
}
unless($#ARGV == 0){
  die $usage;
}
my $PatId = $ARGV[0];
### 1.a Gather List
my %NonDicomFiles;
my $q = Query('GetNonDicomFilesByPatientId');
$q->RunQuery(sub {
  my($row) = @_;
  my($file_id, $file_type, $file_sub_type, 
     $collection, $site, $subject, $visibility,
     $date_last_categorized, $size, $digest, $path) = @$row;
  $NonDicomFiles{$file_id} = {
     file_type => $file_type,
     file_sub_type => $file_sub_type,
     size => $size,
     digest => $digest,
     path => $path,
  };
}, sub {}, $PatId);
### 1.b,c
my $Collection;
my $Site;
my $SiteCode;
my $UidRoot;
$q = Query('PatientIdMappingByToPatientId');
$q->RunQuery(sub {
  my($row) = @_;
  my($from_patient_id, $to_patient_id, $to_patient_name, 
    $collection_name, $site_name, $batch_number, $diagnosis_date,
    $baseline_date, $date_shift, $uid_root, $computed_shift,
    $site_code) = @$row;
  $Collection = $collection_name;
  $Site = $site_name;
  $SiteCode = $site_code;
  $UidRoot = $uid_root;
},sub{}, $PatId);
### 1.d
my $StudyDate;
$q = Query('GetMaxStudyDate');
$q->RunQuery(sub {
  my($row) = @_;
  $StudyDate = $row->[0];
}, sub {}, $PatId);
my $SeriesDate = $StudyDate;
### 1.e
my $StudyDescription = "Description of zip attachment";
my $SeriesDescription = $StudyDescription;
### 2
my $pd = Posda::PrivateDispositions->new($UidRoot);
my $SrSopInstanceUid = $pd->NewRandomUid;
my $AttachmentInstanceUid = $pd->NewRandomUid;
my $StudyInstanceUid = $pd->NewRandomUid;
my $SeriesInstanceUid = $pd->NewRandomUid;
### 2.5
my $ZipReport = "Files in zip file:\n" .
  "    file            |  size  |" .
  "        digest                  | type\n";

for my $file_id (keys %NonDicomFiles){
  my $info = $NonDicomFiles{$file_id};
  my $file_name = "$file_id.$info->{file_type}";
  if(length($file_name) < 20){
    $file_name .= " " x (20 - length($file_name));
  }
  my $size = $info->{size};
  if(length($size) < 8){
    $size = " " x (8 - length($size)) . $size;
  }
  $ZipReport.= "$file_name|" .
    "$size|$info->{digest}|$info->{file_sub_type}\n";
}


####### for debug
#print "#####################################\n" .
#  "         Collection: $Collection\n" .
#  "               Site: $Site\n" .
#  "           SiteCode: $SiteCode\n" .
#  "         Study Date: $StudyDate\n" .
#  "    Sr Sop Instance: $SrSopInstanceUid\n" .
#  "Attachment Instance: $AttachmentInstanceUid\n" .
#  "     Study Instance: $StudyInstanceUid\n" .
#  "  Study Description: $StudyDescription\n" .
#  "    Series Instance: $SeriesInstanceUid\n" .
#  " Series Description: $StudyDescription\n" .
#  "        Text Report:\n" .
#  "-----------------\n$ZipReport" .
#  "-----------------\n" .
#  "#####################################\n";
#exit;
###### end debug
my $mar = Posda::MakeAttachmentReport->new();
   
####  3) Create a temp directory under \$POSDA_CACHE_ROOT/edits from
####     a UUID.  In this directory, create another directory
####     (manifest directory), using the Manifest UID as the name.
my $edit_dir = "$ENV{POSDA_CACHE_ROOT}/edits";
unless(-d $edit_dir){
  unless(mkdir($edit_dir) == 1){
    die "Can't make edit_dir";
  }
}
my $sub_dir = get_uuid();
my $TempDir = "$edit_dir/$sub_dir";
if(-e $TempDir) { die "$TempDir already exists" }
unless(mkdir($TempDir) == 1){
  die "Can't mkdir $TempDir";
}
my $ManifestDir = "$TempDir/$SeriesInstanceUid";
if(-e $ManifestDir) { die "$ManifestDir already exists" }
unless(mkdir($ManifestDir) == 1){
  die "Can't mkdir $ManifestDir";
}
####  4) Link all of the non-dicom files into the manifest directory.
for my $id (keys %NonDicomFiles){
  if($NonDicomFiles{$id}->{file_type} ne "zip"){
    symlink "$NonDicomFiles{$id}->{path}", "$ManifestDir/ZZ_$id.$NonDicomFiles{$id}->{file_type}";
  }
}
####  5) Create a manifest file in manifest  directory.
open FILE, ">$ManifestDir/manifest.xml" 
  or die "Can't open $ManifestDir/manifest.xml";
print FILE "<manifest uid=\"$AttachmentInstanceUid\"\n" .
  "  study-uid=\"$StudyInstanceUid\"\n" .
  "  series-uid=\"$SeriesInstanceUid\"\n" .
  "  pt-id=\"$PatId\"\n" .
  "  description=\"$StudyDescription\"\n" .
  "  date=\"$StudyDate\"\n" .
  "  version=\"1\">\n" .
  "</manifest>\n";
close FILE;
####  6) Create a zip file of the manifest directory in the temp
###     directory.
my $cmd = "cd $ManifestDir;zip -r $SeriesInstanceUid.zip *";
my $result = `$cmd`;
####  7) Import this file into Posda and retrieve its file_id.
my $AttachmentFileId;
my $i_cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$ManifestDir/$SeriesInstanceUid.zip\" " .
    "\"Attachments for $PatId\"";
$result = `$i_cmd`;
if($result =~ /File id: (.*)/){
  $AttachmentFileId = $1;
} else {
  die "Attachments File: $TempDir/$SeriesInstanceUid.zip failed to import";
}
print "Imported Attachments File.  Id = $AttachmentFileId\n";
####  8) Delete the zip file (its already in Posda) and the 
####     manifest directory.
unlink("$TempDir/$SeriesInstanceUid.zip");
rmtree("$ManifestDir");
####  9) Create a row in non_dicom_file for this file.
my $cq = Query('CreateNonDicomFileById');
$cq->RunQuery(sub {}, sub {},
  $AttachmentFileId, "zip", "radcomp non dicom attachments",
  $Collection, $Site, $PatId);
####  10) Create a DICOM SR Object using the module Posda::MakeAttachmentReport
####     Create the file in the temp directory, call it 
####     SR_<sop_instance_uid>.dcm.  Then import this object into Posda, and
####     retrieve its file_id. Then delete the temp directory.
my $mksr = Posda::MakeAttachmentReport->new;
$mksr->substitute({
  accession_number => undef,
  collection => $Collection,
  patient_id => $PatId,
  patient_name => $PatId,
  patient_sex => undef,
  series_instance_uid => $SeriesInstanceUid,
  site_id => $SiteCode,
  site_name => $Site,
  sop_inst => $SrSopInstanceUid,
  study_date => $StudyDate,
  study_instance_uid => $StudyInstanceUid,
  series_date => $SeriesDate,
  series_instance_uid => $SeriesInstanceUid,
  study_time => "120000",
  series_time => "120000",
  study_description => $StudyDescription,
  series_description => $SeriesDescription,
  text_goes_here => $ZipReport,
});
my $list = $mksr->values_needed;
if($#{$list} >= 0){
  print "Not all substitutions made:\n";
  for my $dat (@$list){
    print("\t$dat\n");
  }
}
$mksr->WriteFile("$TempDir/SR_$SrSopInstanceUid.dcm");
my $SrFileId;
my $i_cmd1 = "ImportSingleFileIntoPosdaAndReturnId.pl \"$TempDir/SR_$SrSopInstanceUid.dcm\" " .
    "\"Attachments for $PatId\"";
$result = `$i_cmd1`;
if($result =~ /File id: (.*)/){
  $SrFileId = $1;
} else {
  die "SR File: $TempDir/SR_$SrSopInstanceUid.dcm failed to import";
}
print "Imported SR File.  Id = $SrFileId\n";
rmtree($TempDir);
####  11) Create a row in non_dicom_attachments.
my $inda = Query("InsertIntoNonDicomAttachments");
$inda->RunQuery(sub {}, sub{},
  $AttachmentFileId,
  $SrFileId,
  $PatId,
  $AttachmentInstanceUid,
  $StudyInstanceUid,
  $SeriesInstanceUid,
  $StudyDate,
  "1");

