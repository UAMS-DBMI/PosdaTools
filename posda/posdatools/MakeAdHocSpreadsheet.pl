#!/usr/bin/perl -w
use strict;
use Posda::Try;
use Posda::Find;

#If I put the files in a directory, how hard would it be for you or 
#Quasar to write a script that would print the 
#PatientID, SeriesInstanceUID, StudyDate, StudyTime, and 
#Radiopharmaceutical Start Datetime (0018,1078) into a spreadsheet?
# 
#I need to identify which ones have a shift so that I can fix them. 
# 
#I also need to see if any study times are near midnight and that 
#perhaps the offset makes sense.

my %Info;
my $sub = sub {
  my($try) = @_;
  my $dataset = $try->{dataset};
  my $PatientId = $dataset->Get("(0010,0020)");
  my $SeriesInstanceUID = $dataset->Get("(0020,000e)");
  my $StudyDate = $dataset->Get("(0008,0020)");
  my $StudyTime = $dataset->Get("(0008,0030)");
  my $RadioEtc = $dataset->Get("(0054,0016)[0](0018,1078)");
  unless($RadioEtc) { $RadioEtc = "<undef>" }
  print "$PatientId|$SeriesInstanceUID|$StudyDate|$StudyTime|$RadioEtc\n";
};
Posda::Find::DicomOnly(
  "/mnt/public-nfs/posda/edited/NSCLC-Check/NSCLC_Public_Data_2Fix/NSCLCRadiogenomics",
  , $sub);
