#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
ProduceInitialAnonymizerCommands.pl <bkgrnd_id> <notify>
or
ProduceInitialAnonymizerCommands.pl -h

Expects lines of the format:
<series_instance_uid>&<patient_id>&<patient_name>
on STDIN

Use the following tables:
  patient_mapping
  collection_codes
  site_codes
to produce a spreadsheet with edits appropriate to do
first round anonymization.

If the data needed is not currently in the tables, then
the script will not enter the background or send an email, but
will inform in its status printout of the data which needs to 
be added to these tables in order for it to do its job.

If the data in the tables is ambiguous (i.e. there is more than
one row for a given patient_id), then all rows for the patient_id 
will be produced, and a warning will be included in the email stating
that the user must choose which are correct, and delete the others.

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 1) {
  print "Error: wrong number of args\n$usage\n";
  exit;
}
my($invoc_id, $notify) = @ARGV;

my %patients; 
# $patients{<from_patient_id>} = {
#   from_patient_id => <from_patient_id>,
#   from_patient_name => <from_patient_name>,
#   series => {
#     <series_instance_uid> => 1,
#     ...
#   },
# };
while (my $line = <STDIN>){
  chomp $line;
  my($series_instance_uid, $patient_id, $patient_name) = split /&/, $line;
  if(
    exists($patients{$patient_id}->{from_patient_name}) &&
    $patients{$patient_id}->{from_patient_name} ne $patient_name
  ){
    print "Error: patient_id \"$patient_id\" has two different " .
      "names:\n\t$patients{$patient_id}->{$patient_name}\n\t" .
      "$patient_name\n";
    exit;
  }
  $patients{$patient_id}->{from_patient_name} = $patient_name;
  $patients{$patient_id}->{from_patient_id} = $patient_id;
  $patients{$patient_id}->{series}->{$series_instance_uid} = 1;
}
my $get_site_codes = Query("GetSiteCodes");
my $get_collection_codes = Query("GetCollectionCodes");
my $get_patient_mapping = Query("GetPatientMapping");
my %PatientMapping;
# $PatientMapping{$from_patient_id} = [
#   {
#     from_patient_id => <from_patient_id>,
#     to_patient_name => <to_patient_name>,
#     collection_name => <collection_name>,
#     site_name => <site_name>,
#     [batch_number => <batch_number>,]   # if batch present
#     date_shift => <date_shift>,         # or computed, depending
#   },
#   ...  [if ambiguous entries]
# ];
my %SiteNameToCode;
# $SiteName{$site_name} = $site_code
my %CollectionNameToCode;
# $CollectionName{$site_name} = $collection_code
$get_site_codes->RunQuery(sub {
  my($row) = @_;
  my($site_name, $site_code) = @$row;
  $SiteNameToCode{$site_name} = $site_code;
}, sub {});
$get_collection_codes->RunQuery(sub {
  my($row) = @_;
  my($collection_name, $collection_code) = @$row;
  $CollectionNameToCode{$collection_name} = $collection_code;
}, sub {});
$get_patient_mapping->RunQuery(sub{
  my($row) = @_;
  my($from_patient_id, $to_patient_id, $to_patient_name,
    $collection_name, $site_name, $batch_number, $diagnosis_date,
    $baseline_date, $date_shift, $computed_date_shift) = @$row;
  my $site_code = $SiteNameToCode{$site_name};
  my $collection_code = $CollectionNameToCode{$collection_name};
  unless(defined($site_code) &&
    defined($site_code) &&
    $collection_code ne "" &&
    $site_code ne ""
  ){
    print "collection_codes and site_code not defined for\n" .
      "Collection: $collection_name\n" .
      "Site: $site_name\n";
    exit;
  }
  my $hash = {
    from_patient_id => $from_patient_id,
    to_patient_id => $to_patient_id,
    to_patient_name => $to_patient_name,
    collection_name => $collection_name,
    site_name => $site_name,
    site_code => $site_code,
    collection_code => $collection_code,
    site_id => $site_code . $collection_code,
    uid_root => "1.3.6.1.4.1.14519.5.2.1." . $site_code . 
      "." . $collection_code,
  };
  if(defined $diagnosis_date) { $hash->{diagnosis_date} = $diagnosis_date }
  if(defined $baseline_date) { $hash->{baseline_date} = $baseline_date }
  if(defined $batch_number) { $hash->{batch_number} = $batch_number }
  if(
    defined($date_shift) && 
    defined($computed_date_shift) &&
    $date_shift ne $computed_date_shift
  ){
    print "Error: both date_shift ($date_shift) and computed_date_shift " .
      "($computed_date_shift) are defined for  $from_patient_id\n";
    exit;
  }
  if(defined $date_shift) { $hash->{date_shift} = $date_shift }
  elsif (defined($computed_date_shift)){ 
    $hash->{date_shift} = $computed_date_shift;
  }
  if(defined $hash->{date_shift}){
    if($hash->{date_shift} =~ /^(.*) days$/){
       $hash->{date_shift} = $1;
    } else {
      print "Error: $date_shift for $from_patient_id is bad format: " .
      "\"$hash->{date_shift}\"\n";
    }
  }
  if(exists $PatientMapping{$hash}){
    $PatientMapping{$from_patient_id} = [ $PatientMapping{$from_patient_id} ];
    push @{$PatientMapping{$from_patient_id}}, $hash;
  } else {
    $PatientMapping{$from_patient_id} = $hash;
  }
}, sub{});
my $num_patients = keys %patients;
my @mapped_patients;
for my $i (keys %patients){
  if(exists $PatientMapping{$i}){
    push @mapped_patients, $i;
  }
}
my $num_mapped_patients = @mapped_patients;
unless($num_mapped_patients > 0){
  print "No mapped patients found in input\n";
  print "Not entering background\n";
  exit;
}
print "Entering background to produce spreadsheet for " .
  "$num_mapped_patients mapped patients\n";
if($num_mapped_patients < $num_patients){
  my $num_unmapped_patients = $num_patients - $num_mapped_patients;
  print "$num_unmapped_patients in spreadsheet not mapped\n";
}
print "Constructing Backgrounder($invoc_id, $notify)\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
$background->WriteToEmail("Enter background\n". 
  "Preparing spreadsheet for editing $num_patients patients\n");
if($num_mapped_patients < $num_patients){
  my $num_unmapped_patients = $num_patients - $num_mapped_patients;
  $background->WriteToEmail(
    "$num_unmapped_patients in spreadsheet not mapped\n");
}
my $rpt = $background->CreateReport("EditsForInitialAnonymization");
$rpt->print(
  "series_instance_uid,op,tag,val1,val2,Operation,description,notify\n");
my $sent_commands = 0;
for my $p (@mapped_patients){
  my $patient_map = $PatientMapping{$p};
  my $patient_info = $patients{$p};
  for my $i (keys %{$patient_info->{series}}){
    $rpt->print("$i");
    unless($sent_commands){
      $rpt->print(",,,,,BackgroundEdit,\"Initial Anonymzer Edits\"," .
        "\"$notify\"");
      $sent_commands = 1;
    }
    $rpt->print("\n");
  }
  if(ref($patient_map) eq "HASH") {
    ProduceLinesForPatientEdits($rpt, $patient_info, $patient_map);
  } elsif(ref($patient_map) eq "ARRAY") {
    my $num_edits = @$patient_map;
    $rpt->print(
      "There are $num_edits possible edit sets for this patient ($p)\n");
    $rpt->print(
      "You must choose one\n");
    for my $i (0 .. $#{$patient_map}){
      my $num = $i + 1;
      $rpt->print("Starting set $num for patient ($p)\n");
      ProduceLinesForPatientEdits($rpt, $patient_info, $patient_map->[$i]);
    }
  } else {
    $background->WriteToEmail("unidentified type for patient_map ($p)\n");
    $background->Finish;
    exit;
  }
}
$background->Finish;
exit;
sub ProduceLinesForPatientEdits{
  my($rpt, $info, $map) = @_;
  # $info = {
  #   from_patient_id => <from_patient_id>,
  #   from_patient_name => <from_patient_name>,
  #   series => {
  #     <series_instance_uid> => 1,
  #     ...
  #   },
  # };
  # $map = {
  #   from_patient_id => <from_patient_id>,
  #   to_patient_name => <to_patient_name>,
  #   collection_name => <collection_name>,
  #   site_name => <site_name>,
  #   [batch_number => <batch_number>,]   # if batch present
  #   date_shift => <date_shift>,         # or computed, depending
  #   site_code => <site_code>,
  #   collection_code => <collection_code>,
  #   site_id => $site_code . $collection_code,
  # };
  $rpt->print(",set_tag,\"<(0013,\"\"CTP\"\",10)>\",<$map->{collection_name}>,<>\n");
  $rpt->print(",set_tag,\"<(0013,\"\"CTP\"\",11)>\",<$map->{collection_name}>,<>\n");
  $rpt->print(",set_tag,\"<(0013,\"\"CTP\"\",12)>\",<$map->{site_name}>,<>\n");
  $rpt->print(",set_tag,\"<(0013,\"\"CTP\"\",13)>\",<$map->{site_id}>,<>\n");
  if(defined $map->{batch_number}){
    $rpt->print(",set_tag,\"<(0013,\"\"CTP\"\",15)>\",<$map->{batch_number}>,<>\n");
  }
  $rpt->print(",set_tag,<PatientID>,<$map->{to_patient_id}>,<>\n");
  $rpt->print(",set_tag,<PatientName>,<$map->{to_patient_name}>,<>\n");
  my @uid_elements = (
   "(0008,0014)", "(0008,0018)", "(0008,0058)", "(0008,1155)", "(0008,1167)",
   "(0008,1195)", "(0008,3010)", "(0008,3012)", "(0008,9123)", "(0018,1002)",
   "(0018,2042)", "(0020,000d)", "(0020,000e)", "(0020,0052)", "(0020,0200)",
   "(0020,0242)", "(0020,9161)", "(0020,9164)", "(0020,9312)", "(0020,9313)",
   "(0028,0304)", "(0040,0554)", "(0040,4023)", "(0040,a171)", "(0040,a172)",
   "(0040,a402)", "(0040,db0c)", "(0040,db0d)", "(0040,e011)", "(0062,0021)",
   "(0064,0003)", "(0070,031a)", "(0070,1101)", "(0070,1102)", "(0088,0140)",
   "(3006,0024)", "(3006,00c2)", "(300a,0013)");
  for my $i (@uid_elements){
    $rpt->print(",hash_unhashed_uid,\"<..$i>\",<$map->{uid_root}>,<>\n");
  }
  my @date_elements = (
   "(0008,0012)", "(0008,0015)", "(0008,0020)", "(0008,0021)", "(0008,0022)",
   "(0008,0023)", "(0008,0024)", "(0008,0025)", "(0008,002a)", "(0010,0030)",
   "(0010,0033)", "(0010,0034)", "(0010,21d0)", "(0018,1012)", "(0018,1078)",
   "(0018,1079)", "(0018,1200)", "(0018,1202)", "(0018,700c)", "(0018,9074)",
   "(0018,9151)", "(0018,9516)", "(0018,9517)", "(0018,9701)", "(0018,9804)",
   "(0018,a002)", "(0020,3403)", "(0032,0032)", "(0032,0034)", "(0032,1000)",
   "(0032,1010)", "(0032,1040)", "(0032,1050)", "(0038,001a)", "(0038,001c)",
   "(0038,0020)", "(0038,0030)", "(0040,0002)", "(0040,0004)", "(0040,0244)",
   "(0040,0250)", "(0040,2004)", "(0040,4005)", "(0040,4010)", "(0040,4011)",
   "(0040,4050)", "(0040,4051)", "(0040,4052)", "(0040,a023)", "(0040,a030)",
   "(0040,a032)", "(0040,a082)", "(0040,a110)", "(0040,a13a)", "(0040,a192)",
   "(0044,0004)", "(0044,000b)", "(0044,0010)", "(0068,6226)", "(0068,6270)",
   "(0070,0082)", "(0072,000a)", "(2100,0040)", "(3006,0008)", "(3008,0024)",
   "(3008,0054)", "(3008,0056)", "(3008,0162)", "(3008,0166)", "(3008,0250)",
   "(300a,0006)", "(300a,022c)", "(300e,0004)", "(4008,0100)", "(4008,0108)",
   "(4008,0112)",
  );
  if(defined $map->{date_shift}){
    for my $i (@date_elements){
      $rpt->print(",shift_date,\"<..$i>\",<$map->{date_shift}>,<>\n");
    }
  }
}
