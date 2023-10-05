#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::UUID;
use Posda::DownloadableFile; use Dispatch::Select;
use Dispatch::EventHandler;
use Dispatch::LineReader;
use Digest::MD5;
use FileHandle;
use Storable qw( store retrieve fd_retrieve store_fd );
use Data::UUID;
our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}

use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
CategorizeRadcompFiles.pl <bkgrnd_id> <collection> <site> <notify>
or
CategorizeRadcompFiles.pl -h
Expects lines of the form:
<import_event_id>

This program will use the query named "GetLoadPathByImportEventId" to
obtain the file_id and rel_path for each file loaded in that import_event.

The purpose of this script is to categorize each file by collection, site,
file_type, file_subtype, and patient_id.

It parses the rel_path to obtain the file_type, file_subtype and patient_id.

Then it populates the table "non_dicom_file"  with:
  file_id, file_type, file_sub_type, collection, site, subject (patient_id).

collection is specified as parameter
site is specified as parameter

Types, and subtypes:

docx, radcomp_data_submital_form:
  path: "<date>/<random>/DataSubmittalForms/<file_name>
  formats for <file_name>:
    <foo>-3510-<patient_num> Data Submittal Form.docx
    Data Submittal Form_<ddMonyyyy>_Case <patient_num>.docx
    Data Submital Form_Case <patient_num>_<Monddyyyy>.docx
    <foo>3510-<patient_num>_Data Submittal Sheet.docx
    Data Submital Form for Case #<patient_num>.docx   
    Data Submital Form for case 3510-<patient_num>_.docx
    Data Submital Form for case #<patient_num>.docx
    Data Submital Form_Patient<patient_num>.docx
    <foo>_3510-<patient_num>_Data Submittal Form.docx
    <foo>_RTOG-Case <patient_num>_Data Submittal Sheet.docx
    Data Submital Form_Patient<patient_num>.docx
    Data Submital Form for case <patient_num> 3510.docx
    Data Submital Form Case<patient_num> - revised.docx
    Data Submital Form for case 3510-<patient_num>- revised.docx
    <foo>_3510-<patient_num>_Data Submittal Sheet.docx
    RTOG-3510_Case <patient_num>_Data Submital Sheet.docx
    Data Submital Form_<ddMonyyyy>_Patient<patient_num>.docx 
    Data Submital Form_case <patient_num>_SMP.docx
    RADCOMP_CASE<patient_num>_sub<num>.docx
    Data Submital Form for 3510-<patient_num>.docx

pdf, radcomp_data_submital_form:
  path: "<date>/<random>/DataSubmittalForms/<file_name>
  formats for <file_name>:
    Case <patient_num> CNS Data Submission form_<ddMonyyyy>.pdf

docx, radcomp_plan_review_form:
  path: "<date>/<random>/DataSubmittalForms/<file_name>
  formats for <file_name>:
    Plan Review Form_3510-<patient_num>b_<foo>.docx

csv, radcomp_dose_volume_analysis
  path: <date>/<random>/DVA_CSV/<file_name>
  formats for <file_name>:
    3510-<patient_num>.csv
    3510-<patient_num>b.csv
    3510-<patient_num>composite.csv
    
csv, radcomp_heart_dvh
  path: <date>/<random>/DVH_Heart/<file_name>
  formats for <file_name>:
    3510c<patient_num>_DVH_heart.csv
    3510c<patient_num>b_DVH_heart.csv

csv, radcomp_plan_dvh
  path: <date>/<random>/DVH_Plan/<file_name>
  formats for <file_name>:
    3510c<patient_num>_DVH.csv
    3510c<patient_num>b_DVH.csv

xls, radcomp_plan_review_form:
  path: <date>/<random>/DVH_Plan/<file_name>
  formats for <file_name>:
    RADCOMP Case <patient_num> PlanReviewForm_<yyddmm>_reviewed.xls
    RADCOMP Case <patient_num>b PlanReviewForm_<yyddmm>_reviewed.xls
    RADCOMP case <patient_num> PlanReviewForm_<yyddmm>_reviewed.xls
    RADCOMP case <patient_num>b PlanReviewForm_<yyddmm>_reviewed.xls

xlsx, radcomp_plan_review_form:
  path: <date>/<random>/DVH_Plan/<file_name>
  formats for <file_name>:
    RADCOMP Case <patient_num> PlanReviewForm_<yyddmm>_reviewed.xlsx
    RADCOMP Case <patient_num>b PlanReviewForm_<yyddmm>_reviewed.xlsx
    RADCOMP case <patient_num> PlanReviewForm_<yyddmm>_reviewed.xlsx
    RADCOMP case <patient_num>b PlanReviewForm_<yyddmm>_reviewed.xlsx
    RADCOMP case <patient_num>b PlanReviewForm_<yyddmm>_Updated_Reviewed (nnn).xlsx

EOF
my %ImportEvents;
# ImportEvents{$import_event_id} = 1;
my %Files;
# Files{$file_id} = {
#   type => <file_type>,
#   sub_type => <file_sub_type>,
#   subject => <subject>
# };
my $processing_errors;
#############################
## This code process parameters
#

if($#ARGV == 0) { die "$usage\n\n" }
if($#ARGV != 3){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $collection, $site, $notify) = @ARGV;

#############################
## This code parses the input and populates the hash
## %ImportEvents 
#
line:
while(my $line = <STDIN>){
  chomp $line;
  $ImportEvents{$line} = 1;
}

#############################
## Get the file uploads
## Parse All Filenames and Build
## Results structure here
#
my $get_uploads = Query("GetLoadPathByImportEventId");
file:
for my $i (keys %ImportEvents){
  my($file_id, $rel_path);
  $get_uploads->RunQuery(sub{
    my($row) = @_;
    my($file_id, $rel_path) = @$row;
    my @comp = split(/\//, $rel_path);
    my $dir = $comp[$#comp - 1];
    my $f_name = $comp[$#comp];
    my $file_type;
    if($f_name =~ /\.([^\.]+)$/){
      $file_type = $1;
    } else {
      print "Warning: can't get extension from $f_name\n" . 
        "ignoring file $f_name\n";
      next file;
    }
    if($file_type =~ /\./) {
      print "Warning: extension from $f_name has dot\n" . 
        "ignoring file $f_name\n";
      next file;
    }
    if( $dir eq "DataSubmittalForms"){
      ProcessDataSubmittalDir($file_id, $file_type, $f_name, \%Files, \$processing_errors);
    }elsif($dir eq "DVA_CSV"){
      Process_DVA_CSV_Dir($file_id, $file_type, $f_name, \%Files, \$processing_errors);
    }elsif($dir eq "DVH_Heart"){
      Process_DVH_Heart_Dir($file_id, $file_type, $f_name, \%Files, \$processing_errors);
    }elsif($dir eq "DVH_Plan"){
      Process_DVH_Plan_Dir($file_id, $file_type, $f_name, \%Files, \$processing_errors);
    }elsif($dir eq "PlanReviewForm"){
      ProcessPlanReviewFormDir($file_id, $file_type, $f_name, \%Files, \$processing_errors);
    }else{
    }
  }, sub {}, $i);
}


#############################
#
sub ProcessDataSubmittalDir{
  my($file_id, $file_type, $fname, $file_hash, $errs) = @_;
  my $file_sub_type;
  my $patient_num;
  if($fname =~ /case([\d]+)b.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
                   #Plan Review Form_3510-0001b_160418 rev2.docx
  }elsif($fname =~ /Data Submital Form_\d\d...\d\d\d\d_Case([\d]+).docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  }elsif($fname =~ /RadComp_Data Submital Form_MD\d\d\d Case ([\d]+)_\d\d...\d\d\d\d.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  }elsif($fname =~ /3510\-([\d]+) Data Submittal Form.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Data Submittal Form_\d\d..\d\d\d\d ([\d]+).docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Data Submital Form_\d\d...\d\d\d\d_Case ([\d]+).docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Data Submital Form_Case ([\d]+)_...\d\d\d\d\d\d.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /3510\-([\d]+)_Data Submittal Sheet.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Data Submital Form for Case #([\d]+).docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~/Data Submital Form for case 3510\-([\d]+)_.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Data Submital Form for case #([\d]+).docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Data Submital Form_Patient([\d]+).docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /_3510\-([\d]+)_Data Submittal Form.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /\_RTOG-Case ([\d]+)_Data Submittal Sheet.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~/Data Submital Form_Patient([\d]+).docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Data Submital Form for case ([\d]+) 3510.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Data Submital Form Case([\d]+) - revised.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Data Submital Form for case 3510\-([\d]+)\- revised.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ / 3510-([\d]+)_Data Submittal Sheet.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /RTOG\-3510_Case ([\d+])_Data Submital Sheet.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Data Submital Form_\d\d...\d\d\d\d_Patient([\d]+).docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Data Submital Form_case ([\d]+)_SMP.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /RADCOMP_CASE([\d]+)_sub\d+.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Data Submital Form for 3510\-([\d]+).docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /^Case ([\d]+) Data Submital Form_\d\d....\d\d\d\d.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~ /Case ([\d]+) CNS Data Submittal Form_\d\d....\d\d\d\d.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp data submittal form';
  } elsif($fname =~/Plan Review Form_3510\-([\d]+)b_.*.docx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp plan review form';
  } else {
     print "######## Error:\n" .
       "Couldn't parse file name: \"$fname\" in PlanReviewForm directory\n".
       "#######\n";
    $$errs += 1;
  }
  $file_hash->{$file_id} = {
    file_id => $file_id,
    file_type => $file_type,
    file_sub_type => $file_sub_type,
    subject => sprintf("%04d",$patient_num),
  };
}
sub Process_DVA_CSV_Dir{
  my($file_id, $file_type, $fname, $file_hash, $errs) = @_;
  my $file_sub_type;
  my $patient_num;
  if($fname =~ /3510-([\d]+).csv/){
     $patient_num = $1;
     $file_sub_type = 'radcomp dva';
  }elsif($fname =~ /3510-([\d]+)b.csv/){
     $patient_num = $1;
     $file_sub_type = 'radcomp dva';
  }elsif($fname =~ /3510-([\d]+)composite.csv/){
     $patient_num = $1;
     $file_sub_type = 'radcomp dva';
  }else {
     print "######## Error:\n" .
       "Couldn't parse file name: \"$fname\" in DVA_CSV directory\n".
       "#######\n";
    $$errs += 1;
  }
  $file_hash->{$file_id} = {
    file_id => $file_id,
    file_type => $file_type,
    file_sub_type => $file_sub_type,
    subject => sprintf("%04d",$patient_num),
  };
}
sub Process_DVH_Heart_Dir{
  my($file_id, $file_type, $fname, $file_hash, $errs) = @_;
  my $file_sub_type;
  my $patient_num;
  if($fname =~ /3510c([\d]+)_DVH_heart.csv/){
     $patient_num = $1;
     $file_sub_type = 'radcomp heart dvh';
  }elsif($fname =~ /3510c([\d]+)b_DVH_heart.csv/){
     $patient_num = $1;
     $file_sub_type = 'radcomp heart dvh';
  }else {
     print "######## Error:\n" .
       "Couldn't parse file name: \"$fname\" in DVH_Heart directory\n".
       "#######\n";
    $$errs += 1;
  }
  $file_hash->{$file_id} = {
    file_id => $file_id,
    file_type => $file_type,
    file_sub_type => $file_sub_type,
    subject => sprintf("%04d",$patient_num),
  };
}
sub Process_DVH_Plan_Dir{
  my($file_id, $file_type, $fname, $file_hash, $errs) = @_;
  my $file_sub_type;
  my $patient_num;
  if($fname =~ /3510c([\d]+)_DVH.csv/){
     $patient_num = $1;
     $file_sub_type = 'radcomp plan dvh';
  }elsif($fname =~ /3510c([\d]+)b_DVH.csv/){
     $patient_num = $1;
     $file_sub_type = 'radcomp plan dvh';
  }else {
     print "######## Error:\n" .
       "Couldn't parse file name: \"$fname\" in DVH_Plan directory\n".
       "#######\n";
    $$errs += 1;
  }
  $file_hash->{$file_id} = {
    file_id => $file_id,
    file_type => $file_type,
    file_sub_type => $file_sub_type,
    subject => sprintf("%04d",$patient_num),
  };
}
sub ProcessPlanReviewFormDir{
  my($file_id, $file_type, $fname, $file_hash, $errs) = @_;
  my $file_sub_type;
  my $patient_num;
  if($fname =~ /RADCOMP Case ([\d]+) PlanReviewForm_\d\d\d\d\d\d_reviewed.xls/){
     $patient_num = $1;
     $file_sub_type = 'radcomp plan review form';
  }elsif($fname =~ /^Plan Review Form_3510-([\d]+)b.xls/){ 
     $patient_num = $1;
     $file_sub_type = 'radcomp plan review form';
  }elsif($fname =~ /^Plan Review Form_3510-([\d]+)b_\d\d\d\d\d\d rev\d.docx/){ 
     $patient_num = $1;
     $file_sub_type = 'radcomp plan review form';
  }elsif($fname =~ /RADCOMP [Cc]ase ([\d]+) PlanReviewForm_\d\d\d\d\d\d.xls/){ 
     $patient_num = $1;
     $file_sub_type = 'radcomp plan review form';
  }elsif($fname =~ /RADCOMP [Cc]ase ([\d]+) PlanReviewForm_\d\d\d\d\d\d.xlsx/){ 
     $patient_num = $1;
     $file_sub_type = 'radcomp plan review form';
  }elsif($fname =~ /RADCOMP [Cc]ase ([\d]+)PlanReviewForm_\d\d\d\d\d\d.xls/){ 
     $patient_num = $1;
     $file_sub_type = 'radcomp plan review form';
  }elsif($fname =~ /RADCOMP [Cc]ase ([\d]+) PlanReviewForm_\d\d\d\d\d\d\d_reviewed.xls/){ # accomodate typo
     $patient_num = $1;
     $file_sub_type = 'radcomp plan review form';
  }elsif($fname =~ /RADCOMP [Cc]ase ([\d]+) PlanReviewForm\s*_\d\d\d\d\d\d[_\.]reviewed.xls/){
     $patient_num = $1;
     $file_sub_type = 'radcomp plan review form';
  }elsif($fname =~ /RADCOMP [Cc]ase ([\d]+)b PlanReviewForm_\d\d\d\d\d\d_reviewed.xls/){
     $patient_num = $1;
     $file_sub_type = 'radcomp plan review form';
  }elsif($fname =~ /RADCOMP [Cc]ase ([\d]+)b PlanReviewForm_\d\d\d\d\d\d_reviewed.xlsx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp plan review form';
  }elsif($fname =~ /RADCOMP [Cc]ase ([\d]+) PlanReviewForm_\d\d\d\d\d\d_Updated_Reviewed.*.xlsx/){
     $patient_num = $1;
     $file_sub_type = 'radcomp plan review form';
  }else{
     print "######## Error:\n" .
       "Couldn't parse file name: \"$fname\" in PlanReviewForm directory\n".
       "#######\n";
    $$errs += 1;
  }
  $file_hash->{$file_id} = {
    file_id => $file_id,
    file_type => $file_type,
    file_sub_type => $file_sub_type,
    subject => sprintf("%04d",$patient_num),
    fname => $fname,
  };
}

my $num_files = keys %Files;
print "$num_files files to process\n";
print "Subprocess_invocation_id: $invoc_id\n";
print "Forking background process\n";
#print "Structure: ";
#Debug::GenPrint($dbg, \%Files, 1);
#print "\n";
#print "Not Forking for test\n";
#exit;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $BackgroundPid = $$;

# now in the background...
$background->WriteToEmail(
  "Starting CategorizeRadcompFiles.pl($collection, $site, $notify)\n");
my $get_ndf = Query("GetNonDicomFileById");
my $create_ndf_change = Query("CreateNonDicomFileChangeRow");
my $update_ndf = Query("UpdateNonDicomFileById");
my $create_ndf = Query("CreateNonDicomFileById");

my $num_rows_created = 0;
my $num_rows_updated = 0;
for my $file_id (keys %Files){
  my $file_type = $Files{$file_id}->{file_type};
  my $file_sub_type = $Files{$file_id}->{file_sub_type};
  my $subject = $Files{$file_id}->{subject};
  my $row;
  $get_ndf->RunQuery(sub{
    ($row) = @_;
  }, sub{}, $file_id);
  if(defined $row){
    my $old_file_type = $row->[1];
    my $old_file_sub_type = $row->[2];
    my $old_collection = $row->[3];
    my $old_site = $row->[4];
    my $old_subject = $row->[5];
    my $current_visibility = $row->[6];
    my $date_last_categorized = $row->[7];

    $create_ndf_change->RunQuery(sub {}, sub {},
      $file_id, $old_file_type, $old_file_sub_type,
      $old_collection, $old_site, $old_subject, $current_visibility, 
      $date_last_categorized, $notify,
      "CategorizeRadcompFiles($collection, $site, $notify)"
    );

    $update_ndf->RunQuery(sub {}, sub {},
      $file_type, $file_sub_type, $collection, $site,
      $subject, undef, $file_id
    );

    $num_rows_updated += 1;
  } else {
    $create_ndf->RunQuery(sub {}, sub {},
      $file_id, $file_type, $file_sub_type, $collection,
      $site, $subject);
    $num_rows_created += 1;
  }
}
$background->WriteToEmail("Inserted: $num_rows_created\n");
$background->WriteToEmail("Updated: $num_rows_updated\n");
$background->Finish;
