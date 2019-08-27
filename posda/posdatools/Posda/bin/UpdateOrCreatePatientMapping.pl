#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print STDERR @_ };

my $usage = <<EOF;
UpdateOrCreatePatientMapping.pl <?bkgrnd_id?> <activity_id> "<comment>" <overwrite> <notify>
or
UpdateOrCreatePatientMapping.pl -h

where:
  bkgrnd_id is the usual
  activity_id is the usual
  comment is just a comment
  overwrite = 1 means overwrite existing lines, 0 means error if date with 1 in in_patient_map doesn't match or data with 0 in in_patient_mapping exists

It expects line of the following form on STDIN:
<in_patient_mapping>&<from_patient_id>&<collection>&<site>&<to_patient_id>&<to_patient_name>&<diagnosis_date>&<min_study_date>&<uid_root>&<batch_number>&<site_code>&<baseline_date>&<date_shift>

where:
  in_patient_mapping is 0 or 1, depending on whether the row is already in the patient mapping table
  from_patient_id is the id of the patient to be mapped
  collection is the name of the collection for which the mapping is defined (and will be placed into appropriate group 13 tags)
  site is the name of the site for which the mapping is defined (and will be placed into appropriate group 13 tags)
  to_patient_id is the patient_id to which from patient_id will be mapped
  to_patient_name is the patient_name to be mapped
  diagnosis_date defines the "diagnosis_date" for baseling date mapping.  It needs to be in a form acceptable as a date to postgres (e.g 'yyyy-mm-dd')
  min_study_date is the minimum study date in the DICOM data.  It may be used as a proxy for diagnosis date and is coming along for the ride. 
  uid_root is the root for hashing UID's
  baseline_date is the date around which dates will be baselined (if present)
  date_shift is an interval (in postgres "interval" format, e.g. "-4200 days") by which dates (if not baselined) will be shifted.
  
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
my $num_args = @ARGV;
unless($#ARGV == 4){
  print "Error: wrong number of args ($num_args vs 5)\n$usage\n";
  exit;
}

my($invoc_id, $activity_id, $comment, $overwrite, $notify) = @ARGV;
my @Input;
my @LineParams = ("in_patient_mapping", "from_patient_id",
  "collection", "site", "to_patient_id", "to_patient_name",
  "diagnosis_date", "min_study_date", "uid_root", "batch_number",
  "site_code", "baseline_date", "date_shift"
);
while (my $line = <STDIN>){
  chomp $line;
  my($in_patient_mapping, $from_patient_id, $collection, $site, 
    $to_patient_id, $to_patient_name, $diagnosis_date, $min_study_date,
    $uid_root, $batch_number, $site_code, $baseline_date, $date_shift) =
    split(/&/, $line);
    my $h = {
    in_patient_mapping => $in_patient_mapping,
    from_patient_id => $from_patient_id,
    collection_name => $collection,
    site_name => $site,
    to_patient_id => $to_patient_id,
    to_patient_name => $to_patient_name,
    diagnosis_date => $diagnosis_date,
    min_study_date => $min_study_date,
    uid_root => $uid_root,
    batch_number => $batch_number,
    site_code => $site_code,
    baseline_date => $baseline_date,
    date_shift => $date_shift,
  };
  for my $k (@LineParams){
    if($h->{$k} eq "<undef>") { $h->{$k} = undef }
    elsif($h->{$k} =~ /<>/){ $h->{$k} = undef }
    elsif($h->{$k} =~ /<(.*)>/) {$h->{$k} = $1 }
  }
  push @Input, $h;
}
my $num_lines= 0;
my $num_already_in = 0;
my $num_to_add = 0;
for my $line(@Input){
  $num_lines += 1;
  if($line->{in_patient_mapping}){
    $num_already_in += 1;
  } else {
    $num_to_add += 1;
  }
}
print "$num_lines total input lines\n";
print "specifying $num_already_in in patient_mapping and\n";
print "$num_to_add to add\n";
print "Going to background to process\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my %sc;
for my $i (@Input){
  $sc{$i->{site_code}} = 1;
}
my @site_codes = keys %sc;
my $num_sc = @site_codes;
$back->WriteToEmail(
  "Starting: $0\n" .
  "$num_lines total input lines\n" .
  "specifying $num_already_in in patient_mapping and\n" .
  "$num_to_add to add\n\n" .
  "$num_sc distinct site_codes in input"
);
$back->SetActivityStatus("Checking existing mappings");
my $q = Query('GetPatientMappingForSiteCode');
my %PatientMappingsForSiteCode;
my $tot_mappings = 0;
for my $sc (@site_codes){
  my $n = 0;
  $q->RunQuery(sub{
    my($row) = @_;
    my($from_patient_id, $to_patient_id, $to_patient_name, $collection_name,
        $site_name, $batch_number, $diagnosis_date, $baseline_date, $date_shift,
        $uid_root, $site_code) = @$row;
    $PatientMappingsForSiteCode{$sc}->{$from_patient_id} = {
      from_patient_id => $from_patient_id,
      to_patient_id => $to_patient_id,
      to_patient_name => $to_patient_name,
      collection_name => $collection_name,
      site_name => $site_name,
      batch_number => $batch_number,
      diagnosis_date => $diagnosis_date,
      baseline_date => $baseline_date,
      date_shift => $date_shift,
      uid_root => $uid_root,
      site_code => $site_code,
      in_patient_mapping => 1,
    };
    $n += 1;
    $tot_mappings += 1;
  }, sub {}, $sc);
  $back->WriteToEmail("Found $n mappings for site_code $sc\n");
}
$back->WriteToEmail("Found $tot_mappings mappings total\n");
my @good_in_mappings;
my @conflicting_in_mappings;
my @good_to_add;
my @conflicting_to_add;
my @existing_to_add_no_conflict;
input:
for my $inp (@Input){
  my $sc = $inp->{site_code};
  my $fp = $inp->{from_patient_id};
  if($inp->{in_patient_mapping}){
    if(
      exists($PatientMappingsForSiteCode{$sc}->{$fp}) &&
      RowMatches($inp, $PatientMappingsForSiteCode{$sc}->{$fp})
    ){
        push @good_in_mappings, $inp;
    } else {
      push @conflicting_in_mappings, $inp;
    }
  } else {
    if(exists($PatientMappingsForSiteCode{$sc}->{$fp})){
      if(RowMatches($inp, $PatientMappingsForSiteCode{$sc}->{$fp})){
        push(@existing_to_add_no_conflict, $inp);
      } else {
        push(@conflicting_to_add, $inp);
      }
    } else {
      push(@good_to_add, $inp);
    }
  }
}
my $num_good_existing = @good_in_mappings;
my $num_conflicting_existing = @conflicting_in_mappings;
my $num_good_to_add = @good_to_add;
my $num_conflicting_to_add = @conflicting_to_add;
my $num_already_added_to_add = @existing_to_add_no_conflict;

$back->WriteToEmail(
  "Scan of inputs relative to existing table complete:\n" .
  "$num_good_existing existing entries found in table consistent with input\n" .
  "$num_conflicting_existing found in table inconsistent with input\n" .
  "$num_good_to_add found in input to add (no corresponding entry in table)\n" .
  "$num_already_added_to_add found in input to add matching existing rows\n" .
  "$num_conflicting_to_add found in input to add inconsistent with existing rows\n"

);
if($num_conflicting_existing > 0 || $num_conflicting_to_add > 0){
  $back->WriteToEmail(
    "Conflicting entries detected.  Override not implented.  Doing nothing.\n"
  );
  $back->Finish("Done");
  exit;
}
$back->SetActivityStatus("Adding $num_good_to_add rows to patient_mapping");
$q = Query("InsertIntoPatientMapping");
for my $inp (@good_to_add){
  $q->RunQuery(sub{}, sub {},
    $inp->{from_patient_id},
    $inp->{to_patient_id},
    $inp->{to_patient_name},
    $inp->{collection_name},
    $inp->{site_name},
    $inp->{batch_number},
    $inp->{diagnosis_date},
    $inp->{baseline_date},
    $inp->{date_shift},
    $inp->{uid_root},
    $inp->{site_code},
  );
}
$back->Finish("Done: added $num_good_to_add rows");
sub RowMatches{
  my($inp, $db) = @_;
print STDERR "inp: ";
Debug::GenPrint($dbg, $inp, 1);
print STDERR "\ndb: ";
Debug::GenPrint($dbg, $db, 1);
print STDERR "\n";
  my @ToCheck = ("from_patient_id",
    "collection_name", "site_name", "to_patient_id", "to_patient_name",
    "diagnosis_date", "uid_root", "batch_number",
    "site_code", "baseline_date", "date_shift"
  );
  my %trunc_date = (
    diagnosis_date => 1,
    baseline_date => 1,
  );
  for my $k (@ToCheck){
    my $in_inp = $inp->{$k};
    my $in_db = $db->{$k};
    if($trunc_date{$k}){ $in_db =~ s/ 00:00:00$// }
    if($in_inp ne $in_db){
      $back->WriteToEmail("k = $k; in_db = $in_db; in_inp = $inp\n");
      print STDERR "k = $k; in_db = $in_db; in_inp = $inp\n";
      return 0;
    }
  }
  print STDERR "RowMatches returning 1\n";
  return 1;
}
