#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
#use Debug;
#my $dbg = sub {print STDERR @_};

my $usage = <<EOF;
SuggestPatientMapping.pl <?bkgrnd_id?> <activity_id> "<col_name>" "<crc>" "<site_name>" "<src>" "<date_spec>" "<pat_map_pat>" "<num_dig>" <notify>
  activity_id - Id of the currently selected activity
  col_name - Name of the collection.  If blank, then <crc>, <site_name>, and <src> must also be blank
  crc - Collection root code. Four decimal digits no leading zero. If blank, then <col_name>, <site_name>, and <src> must also be blank
  site_name - Name of the site. If blank, then <col_name>, <crc>, and <src> must also be blank
  src - Site root code. Four decimal digits no leading zero.  If blank, then <col_name>, <site_name>, and <crc> must also be blank
  date_spec - Either a baseline date or a date shift.
    baseline_date has format: "yyyy-mm-dd"
    date shift has format: "[-]<num_days>"
  pat_map_pat - If supplied, this script will suggest patient mappings based on this pattern.  Pattern is text with embedded "<seq>" or "<map_mrn>"
    "<map_mrn>" is not to be embedded and represents a mapping obtained from data warehouse.
    If a <seq> pattern is used, the first character of the pattern must be alphabetic.
    "Collection_patient_<seq>" will generate distinct <seq> values to map patient_id uniquely. The length of the rendering of the <seq> is controlled
    by the <num_dig> parameter.  If no <num_dig> is specified, it will be rendered with no leading zeros.  This will result in mapped patient_ids
    which don't "line up" (and, more importantly, don't sort well).
          WARNING: Using the <num_dig> parameter inconsistently can result in two distinct patients 
          (e.g "ColPat_0001" and "ColPat_001") who appear to represent the intended to be the patient.
          (and have even worse sorting characteristics)  Choose a num_dig wisely for a collection and
          stick to it.
    "<map_mrn>" specifies that the patient_id is an mrn and is to be replaced by a mapping obained from the data warehouse.
    The <map_mrn> feature is only for internal use at UAMS on the ARIES system.
  num_dig is the number of decimal digits that will be rendered in the <seq>.  It shall have a value between 3 and 9 inclusive, or be blank,
    specifying no leading zeros.  Only meaningful if a pat_map_pat with and embedded <seq> is present. See comments above.
  notify - posda user to be notified of results

Expects lines on STDIN:
<patient_id>
...

Note:  The user is required to fill out the patient_mapping table.  This script merely suggest possible values.  If
  not <collection>, <site> is provided by the user this script produces the following reports:
  1) Current Patient mapping - The script looks up all of the mappings for the patients specified and produces a spreadsheet of these.
  2) Current Patients and sites - The script looks up all of the current patients and sites in the patient mapping, collection_code, and site_code
     tables and produces a report.
  If the collection, site, and associated codes are supplied, the script creates appropriate rows in collection_code and site_code tables (if
  necessary), finds all matching rows in the current patient_mapping table (by patient_id and site_code), and produces a spreadsheet, which if
  properly edited, uploaded, and executed, will produce appropriate rows in the patient_mapping table to perform an initial anonymization.
  You may have to edit this spreadsheet if:
    You did not specify a pst_map_pat value
      you will have to supply mapping values for each patient
    You did not specify date_spec
      you will have to specify either a baseline_date and date_of_diagnosis or a date_shift for each patient (date_shift must be consistent
      across a collection).
    Either of these values you specified would have generated mappings inconsistent with mapping values already in the patient_mapping table
    You specified baseline_date.  The script supplies earliest_study_date which is often a good proxy for this.  If it is an acceptable proxy,
      you can copy the whole column.
  
EOF
sub can_map_mrn{
  return 0;
}
sub map_mrn {
  my($mrn) = @_;
  my $mapped;
  # make api call to map mrn into mapped
  return $mapped;
}
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 9){
  my $num_args = @ARGV;
  print "Wrong number of args ($num_args vs 10)\n$usage\n";
  die "$usage\n";
}
my($invoc_id, $activity_id, $col_name, $crc, $site_name, $src, $date_spec, $pat_map_pat, $num_dig, $notify) = @ARGV;

## Validate inputs:

my $defined_col_site = 0;
if($col_name ne "" && $crc ne "" && $site_name ne "" && $src ne ""){
  $defined_col_site = 1;
} elsif($col_name ne "" || $crc ne "" || $site_name ne "" || $src ne ""){
  print "Bad params: one of col_name, site_name, crc, or src is not blank, but one is blank\n";
  exit;
}
if($defined_col_site){
  unless ($crc =~ /^[1-9]\d\d\d$/) {
    print "crc should be four digit decimal with leading non-zero\n";
    exit;
  }
  unless ($crc =~ /^[1-9]\d\d\d$/) {
    print "crc should be four digit decimal with leading non-zero\n";
    exit;
  }
}
my $baseline_specified = 0;
my $baseline_date;
my $shift_specified = 0;
my $date_shift;
if($date_spec =~ /^([-\d]\d*)$/){
  $date_shift = "$1 days";
  $shift_specified = 1;
} elsif ($date_spec =~ /^\d\d\d\d-\d\d-\d\d$/){
  $baseline_date = $date_spec;
  $baseline_specified = 1;
} elsif ($date_spec ne ""){
  print "date spec must be for format \"[-]n..\" or \"yyyy-mm-dd\"\n";
  exit;
}

my $pat_map_specified = 0;
my $pat_map_prefix;
my $pat_map_suffix;
my $map_mrn = 0;
if($pat_map_pat ne ""){
  if($pat_map_pat eq "<map_mrn>"){
    if(can_map_mrn()){
      $map_mrn = 1;
    }
    print "<map_mrn> is not supported (ignored)\n";
  } elsif($pat_map_pat =~ /^([a-zA-Z].*)<seq>(.*)$/){
    $pat_map_specified = 1;
    $pat_map_prefix = $1;
    $pat_map_suffix = $2;
  } else {
    print "Can't make sense of pat_map_pat: $pat_map_pat\n";
    exit;
  }
}
my $num_digits;
if($num_dig =~ /^(\d)$/){
  unless($num_dig >= 3 && $num_dig <= 9){
    print "num_dig must be 3-9\n";
    exit;
  }
  $num_digits = $num_dig;
} elsif ($num_dig ne ""){
  print "num_dig must be 3-9\n";
  exit;
}
print "Params verified - Going to background\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
$back->WriteToEmail("In $0\n");
$back->SetActivityStatus("Running");
my @PatientList;
my %PatientMinStudyDate;
Query("PatientsInCurrentActivityTimepointByActivityIdWithMinStudyDate")->RunQuery(sub{
  my($row) = @_;
  push @PatientList, $row->[0];
  $PatientMinStudyDate{$row->[0]} = $row->[1];
}, sub{}, $activity_id);
my $num_pats = @PatientList;
$back->WriteToEmail("Found $num_pats patients in timepoint\n");
my @Collections;
Query('GetCollectionCodes')->RunQuery(sub{
  my($row) = @_;
  my($collection_name, $collection_code) = @{$row};
  push @Collections, {
    collection_name => $collection_name,
    collection_code => $collection_code
  };
}, sub{});
my @Sites;
Query('GetSiteCodes')->RunQuery(sub{
  my($row) = @_;
  my($site_name, $site_code) = @{$row};
  push @Sites, {
    site_name => $site_name,
    site_code => $site_code
  };
}, sub{});
my @ExistingMappings;
Query('GetPatientMappingForPatientsInTimepoint')->RunQuery(sub{
  my($row) = @_;
  my($from_patient_id, $to_patient_id, $to_patient_name, $collection_name,
      $site_name, $batch_number, $diagnosis_date, $baseline_date, $date_shift,
      $uid_root, $site_code) = @$row;
  if(
    defined($diagnosis_date) &&
    $diagnosis_date =~ /^(\d\d\d\d-\d\d-\d\d)/
  ){
    $diagnosis_date = $1;
  }
  if(
    defined($baseline_date) &&
    $baseline_date =~ /^(\d\d\d\d-\d\d-\d\d)/
  ){ 
    $baseline_date = $1;
  }
  push @ExistingMappings, {
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
  };
}, sub {}, $activity_id);
if($col_name eq ""){
  $back->WriteToEmail("No collection mapping specified\n" .
    "Just get a list potential mappings\n");
  my $num_mappings = @ExistingMappings;
  my @headings = (
    "from_patient_id", "to_patient_id", "to_patient_name", 
    "collection_name", "site_name", "batch_number", "diagnosis_date",
    "baseline_date", "date_shift", "uid_root", "site_code"
  );
  if($num_mappings) {
    my $rpt = $back->CreateReport("ExistingMappings for Current Patients");
    for my $i (0 .. $#headings){
      $rpt->print($headings[$i]);
      unless($i == $#headings) { $rpt->print(",")}
    }
    $rpt->print("\r\n");
    for my $m (@ExistingMappings){
      for my $i (0 .. $#headings){
        my $v = $m->{$headings[$i]};
        $v =~ s/"/""/g;
        $rpt->print("\"$v\"");
        unless($i == $#headings){
          $rpt->print(",");
        }
      }
      $rpt->print("\r\n");
    }
  } else {
    $back->WriteToEmail("There are no existing mappings for patients in timepoint\n");  
  }
  my $num_collections = @Collections;
  @headings = (
    "collection_name", "collection_code",
  );
  if($num_collections) {
    my $rpt = $back->CreateReport("Existing Collections");
    for my $i (0 .. $#headings){
      $rpt->print("\"$headings[$i]\"");
      unless($i == $#headings) {print ","}
    }
    $rpt->print("\r\n");
    for my $m (@Collections){
      for my $i (0 .. $#headings){
        my $v = $m->{$headings[$i]};
        $v =~ s/"/""/g;
        $rpt->print("\"$v\"");
        unless($i == $#headings){
          $rpt->print(",");
        }
      }
      $rpt->print("\r\n");
    }
  } else {
    $back->WriteToEmail("There are no existing Collections in collection_codes table\n");  
  }
  my $num_sites = @Sites;
  @headings = (
    "site_name", "site_code",
  );
  if($num_sites) {
    my $rpt = $back->CreateReport("Existing Sites");
    for my $i (0 .. $#headings){
      $rpt->print($headings[$i]);
      unless($i == $#headings) {print ","}
    }
    $rpt->print("\r\n");
    for my $m (@Sites){
      for my $i (0 .. $#headings){
        my $v = $m->{$headings[$i]};
        $v =~ s/"/""/g;
        $rpt->print("\"$v\"");
        unless($i == $#headings){
          $rpt->print(",");
        }
      }
      $rpt->print("\r\n");
    }
  } else {
    $back->WriteToEmail("There are no existing Sites in site_codes table\n");  
  }
  $back ->Finish("Done - no collection, site specified");
  exit;
}
my $Error = 0;
my %SiteNameToSiteCode;
my %SiteCodeToSiteName;
my %CollectionCodeToCollectionName;
my %CollectionNameToCollectionCode;
my $CreateCollectionRow = 0;
my $CreateSiteRow = 0;
for my $row (@Sites){
  if(exists $SiteCodeToSiteName{$row->{site_code}}){
    $back->WriteToEmail("ERROR: site code $row->{site_code} has two rows in site table\n");
    $Error = 1;
  } else {
    $SiteCodeToSiteName{$row->{site_code}} = $row->{site_name};
  }
  $SiteNameToSiteCode{$row->{site_name}}->{$row->{site_code}} = 1;
}
for my $row (@Collections){
  if(exists $CollectionCodeToCollectionName{$row->{collection_code}}){
    $back->WriteToEmail("ERROR: collection code $row->{collection_code} has two rows in collection table\n");
    $Error = 1;
  } else {
    $CollectionCodeToCollectionName{$row->{collection_code}} = $row->{collection_name};
  }
  if(exists $CollectionNameToCollectionCode{$row->{collection_name}}){
    $back->WriteToEmail("ERROR: collection name $row->{collection_name} has two rows in collection table\n");
    $Error = 1;
  } else {
    $CollectionNameToCollectionCode{$row->{collection_name}} = $row->{collection_code};
  }
}
if(exists($CollectionCodeToCollectionName{$crc})){
  if($CollectionCodeToCollectionName{$crc} eq $col_name){
    $back->WriteToEmail("Found existing collection_codes row: $col_name = $crc\n");
    #print STDERR "Found existing collection_codes row: $col_name = $crc\n";
  } else {
    $back->WriteToEmail("ERROR: proposed collection code $crc has confliciting name " .
      "($CollectionCodeToCollectionName{$crc}) vs proposed ($col_name)\n");
    $Error = 1;
  }
} else {
  $back->WriteToEmail("No collection_code row for $crc\n");
  #print STDERR "No collection_code row for $crc\n";
  $CreateCollectionRow = 1;
}
if(exists $SiteCodeToSiteName{$src}){
  unless($SiteCodeToSiteName{$src} eq $site_name){
    $back->WriteToEmail("ERROR: proposed site code $src has conflicting site_name " .
      "($SiteCodeToSiteName{$src}) vs proposed ($site_name)\n");
    $Error = 1;
  }
} else {
  $CreateSiteRow = 1;
}
if($Error){
  $back ->Finish("Aborting - see errors in notification");
  exit;
}
if($CreateCollectionRow){
  eval {
    Query('InsertIntoCollectionCodes')->RunQuery(sub{
    }, sub {}, $col_name, $crc);
  };
  if($@){
    $back->WriteToEmail("Failed to create collection_code row: $@");
    $back->Finish("Error");
    exit;
  } else {
    $back->WriteToEmail("Created collection_codes row ($col_name, $crc)\n");
  }
} else {
  $back->WriteToEmail("Using existing collection_codes row ($col_name, $crc)\n");
}
if($CreateSiteRow){
  Query('InsertIntoSiteCodes')->RunQuery(sub{
  }, sub {}, $site_name, $src);
  $back->WriteToEmail("Created site_codes row ($site_name, $src)\n");
} else {
  $back->WriteToEmail("Using existing site_codes row ($site_name, $src)\n");
}
my $site_code = "$src$crc";
my $uid_root = "1.3.6.1.4.1.14519.5.2.1.$src" . ".$crc";
my %PatientMappingsForSiteCode;
my %MappedPatientIds;
Query('GetPatientMappingForSiteCode')->RunQuery(sub{
  my($row) = @_;
  my($from_patient_id, $to_patient_id, $to_patient_name, $collection_name,
      $site_name, $batch_number, $diagnosis_date, $baseline_date, $date_shift,
      $uid_root, $site_code) = @$row;
  $PatientMappingsForSiteCode{$from_patient_id} = {
    from_patient_id => $from_patient_id,
    to_patient_id => $to_patient_id,
    to_patient_name => $to_patient_name,
    collection => $collection_name,
    site => $site_name,
    batch_number => $batch_number,
    diagnosis_date => $diagnosis_date,
    baseline_date => $baseline_date,
    date_shift => $date_shift,
    uid_root => $uid_root,
    site_code => $site_code,
    in_patient_mapping => 1,
  };
  $MappedPatientIds{$to_patient_id} = 1;
  my @headings = (
    "from_patient_id", "to_patient_id", "to_patient_name", 
    "collection_name", "site_name", "batch_number", "diagnosis_date",
    "baseline_date", "date_shift", "uid_root", "site_code"
  );
  for my $i (@headings){
    unless(defined $PatientMappingsForSiteCode{$from_patient_id}->{$i}){
      $PatientMappingsForSiteCode{$from_patient_id}->{$i} = "<undef>";
    }
  }
}, sub {}, $site_code);
pat:
for my $pat (keys %PatientMinStudyDate){
  if(exists $PatientMappingsForSiteCode{$pat}){ next pat }
  $PatientMappingsForSiteCode{$pat} = {
    from_patient_id => $pat,
    in_patient_mapping => 0,
    min_study_date => $PatientMinStudyDate{$pat}
  };
  #$defined_col_site
  if($baseline_specified){
    $PatientMappingsForSiteCode{$pat}->{baseline_date} = $baseline_date;
    $PatientMappingsForSiteCode{$pat}->{date_shift} = "undef";
  } elsif($shift_specified){
    $PatientMappingsForSiteCode{$pat}->{baseline_date} = "undef";
    $PatientMappingsForSiteCode{$pat}->{date_shift} = $date_shift;
  }
  if($pat_map_specified){
    my $max = 1000;
    if($num_dig) { $max = 10^$num_dig; }
    my $r = 0; 
    while($r == 0){
      $r = int rand($max);
    }
    my $mapped;
    if($num_dig ne ""){
      $mapped = sprintf("$pat_map_prefix%0$num_dig" . "d$pat_map_suffix", $r);
    } else {
      $mapped = "$pat_map_prefix$r$pat_map_suffix";
    }
    random:
    while(exists $MappedPatientIds{$mapped}){
      $r = int rand($max);
      if($r == 0) { next random }
      if($num_dig != ""){
        $mapped = sprintf("$pat_map_prefix%0$num_dig" . "d$pat_map_suffix");
      } else {
        $mapped = "$pat_map_prefix$r$pat_map_suffix";
      }
    }
    $MappedPatientIds{$pat} = 1;
    $PatientMappingsForSiteCode{$pat}->{to_patient_id} = $mapped;
    $PatientMappingsForSiteCode{$pat}->{to_patient_name} = $mapped;
  } elsif($map_mrn){
    my $mapped = map_mrn($pat);
    $PatientMappingsForSiteCode{$pat}->{to_patient_id} = $mapped;
    $PatientMappingsForSiteCode{$pat}->{to_patient_name} = $mapped;
  }
  $PatientMappingsForSiteCode{$pat}->{collection} = $col_name;
  $PatientMappingsForSiteCode{$pat}->{site} = $site_name;
  $PatientMappingsForSiteCode{$pat}->{site_code} = $site_code;
  $PatientMappingsForSiteCode{$pat}->{uid_root} = $uid_root;
  $PatientMappingsForSiteCode{$pat}->{batch_number} = "undef";
}
my $rpt = $back->CreateReport("Mapping Suggestions");
my @headings = (
  "in_patient_mapping", "from_patient_id", "collection", "site", "to_patient_id",
  "to_patient_name", "diagnosis_date", "min_study_date", 
  "uid_root", "batch_number", "site_code", "baseline_date",
  "date_shift"
);
my $MetaQuote = {
  from_patient_id => 1,
  diagnosis_date => 1,
  min_study_date => 1,
  baseline_date => 1,
  date_shift => 1,
  batch_number => 1,
};
for my $head (@headings){
  $rpt->print("$head,");
}
$rpt->print("Operation,activity_id,comment,notify\r\n");
my @sorted_pats;
#print STDERR "sorted_pats: ";
#Debug::GenPrint($dbg, \%PatientMappingsForSiteCode, 1);
#print STDERR "\n";
if((keys %PatientMappingsForSiteCode) > 0){
  @sorted_pats = sort {
    if ($PatientMappingsForSiteCode{$a}->{in_patient_mapping} < $PatientMappingsForSiteCode{$b}->{in_patient_mapping}) {return -1}
    if ($PatientMappingsForSiteCode{$a}->{in_patient_mapping} > $PatientMappingsForSiteCode{$b}->{in_patient_mapping}) {return 1}
    if ($PatientMappingsForSiteCode{$a}->{from_patient_id} le $PatientMappingsForSiteCode{$b}->{from_patient_id}) {return -1}
    if ($PatientMappingsForSiteCode{$a}->{from_patient_id} ge $PatientMappingsForSiteCode{$b}->{from_patient_id}) {return 1}
    return 0;
  } keys %PatientMappingsForSiteCode;
} else {
  $back->WriteToEmail("No patients for mapping\n");
}
for my $i (0 .. $#sorted_pats){
  my $h = $PatientMappingsForSiteCode{$sorted_pats[$i]};
  for my $j (0 .. $#headings){
    my $v = $h->{$headings[$j]};
    if($MetaQuote->{$headings[$j]}) {
      unless($v =~ /^<.*>$/) {
        $v = "<$v>"
      }
    }
    $v =~ s/"/""/g;
    $rpt->print("\"$v\"");
    unless($j == $#headings){ $rpt->print(",") }
  }
  if($i == 0){
    $rpt->print(",UpdateOrCreatePatientMapping,$activity_id,<place_comment_here>,$notify");
  }
  $rpt->print("\r\n");
}
$back ->Finish("Done - collection, site specified");
