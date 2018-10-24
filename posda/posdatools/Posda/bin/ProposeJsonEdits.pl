#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::PrivateDispositions;

my $usage = <<EOF;
ProposeJsonEdits.pl <?bkgrnd_id?> <scan_id> <description> <notify>
  scan_id - id of scan to query
  description - well, description
  notify - email address for completion notification

Expects lines on STDIN:
<type>&<<path>>&<<q_value>>&<num_files>&<p_op>&<<q_arg1>>&<<q_arg2>>&<<q_arg3>>

Note:
  The double metaquotes in the line specification are not errors.
  Those fields are to be metaquoted themselves.

Uses the following query:
  NonDicomFileInPosdaByScanPathValue
EOF
my $edit_sort_order = {
  insert_and_map_id => 1,
  fix_and_map_id => 1,
  map_id => 2,
  fix_and_map_date => 3,
  map_date => 4,
  "map_date_m/dd/yyyy" => 4,
  "map_date_m/d/yy" => 4,
  "map_date_m/d/yyyy" => 4,
  delete_path =>5,
  delete_value =>5,
  hash_unhashed_uid => 6,
  map_id => 7,
  set_and_map_id => 8,
  shift_date_time => 9,
  "shift_date_yyyy-mm-dd" => 10,
  delete_value => 11,
  "shift_date_mm-dd-yy" => 12,
  set_value => 13,
};
my $requires_map = {
  insert_and_map_id => 1,
  fix_and_map_id => 1,
  map_id => 1,
  fix_and_map_date => 1,
  map_date => 1,
  "map_date_m/dd/yyyy" => 1,
  "map_date_m/d/yy" => 1,
  "map_date_m/d/yyyy" => 1,
  hash_unhashed_uid => 1,
  set_and_map_id => 1,
  shift_date_time => 1,
  "shift_date_yyyy-mm-dd" => 1,
  "shift_date_mm-dd-yy" => 1,
};
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  print $usage;
  die "$usage\n";
}
my($invoc_id, $scan_id, $description, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my @FileQueries;
while(my $line = <STDIN>){
  chomp $line;
  my($type, $path, $q_value, $num_files, $p_op, $q_arg1, $q_arg2, $q_arg3) = 
    split(/&/, $line);
#print STDERR "$type - $path - $num_files - $q_value, $p_op\n";
  if($path =~ /^<(.*)>$/){ $path = $1 } elsif($path){
#    print "Warning - element: \"$path\" not metaquoted\n";
  }
  if($q_value =~ /^<(.*)>$/){ $q_value = $1 } elsif($q_value) {
    print "Warning - q_value: \"$q_value\" not metaquoted\n";
  }
  if($q_arg1 =~ /^<(.*)>$/){ $q_arg1 = $1 } elsif($q_arg1) {
#    print "Warning - q_arg1: \"$q_arg1\" not metaquoted\n";
  }
  if($q_arg2 =~ /^<(.*)>$/){ $q_arg2 = $1 } elsif($q_arg2) {
    print "Warning - q_arg2: \"$q_arg2\" not metaquoted\n";
  }
  if($q_arg3 =~ /^<(.*)>$/){ $q_arg3 = $1 } elsif($q_arg3) {
    print "Warning - q_arg3: \"$q_arg3\" not metaquoted\n";
  }
  my $q = {
   type => $type,
   path => $path,
   value => $q_value,
   num_files => $num_files,
   op => $p_op,
   arg1 => $q_arg1,
   arg2 => $q_arg2,
   arg3 => $q_arg3,
#   bucket => "$p_op|$type|$path|$q_arg1|$q_arg2|$q_arg3",
  };
  push @FileQueries, $q;
}
my $num_file_queries = @FileQueries;
print "Found list of $num_file_queries queries to make\n";

$background->Daemonize;

my $get_files = Query("NonDicomFileInPosdaByScanPathValue");
my $get_subj_and_mapping = Query("PatientIdAndMappingByNonDicomFileId");

my %PatientMappingByFileId;
my $start_time = time;
$background->WriteToEmail("Starting simple look up of Json/Csv with PHI\n" .
  "Scan_id: $scan_id\n");
my %EditsByFile;
my %FileToSubj;
for my $i (@FileQueries){
  my $type = $i->{type}; 
  my $path = $i->{path}; 
  my $value = $i->{value}; 
  my $num_files = $i->{num_files};
  my $op = $i->{op};
  my $arg1= $i->{arg1};
  my $arg2= $i->{arg2};
  my $arg3= $i->{arg3};
  my $bucket;
  my @files;
  $get_files->RunQuery(sub{
      my($row) = @_;
      my $file_id = $row->[0];
      unless(exists $PatientMappingByFileId{$file_id}){
        $get_subj_and_mapping->RunQuery(sub{
          my($row) = @_;
          $PatientMappingByFileId{$file_id} = $row;
        }, sub {}, $file_id);
      }
      push @files, $file_id;
    },
    sub{},
    $scan_id, $type, $path, $value
  );
  my $n_files = @files;
#  $background->WriteToEmail("Retrieved $n_files for:\n\ttype: $type path: $path\n\tvalue: $value\n");
  for my $file_id (@files){
    #  expand bucket by mapping id's here
    if(exists $requires_map->{$op}){
      unless(exists $PatientMappingByFileId{$file_id}){
        $background->WriteToEmail("Error: no mapping exists for " .
          "file: $file_id\n");
        $background->Finish;
        exit;
      }
#      $background->WriteToEmail("Remapping $op\n");
      my($from_patient_id, $to_patient_id, $to_patient_name, $collection_name, $site_name,
        $batch_number, $diagnosis_date, $baseline_date, $date_shift, $uid_root, $computed_shift) =
        @{$PatientMappingByFileId{$file_id}};
      if($op eq "map_id"){
        $op = "set_value";
        $arg1 = $to_patient_id;
      }elsif (
        $op eq "shift_date_time" ||
        $op eq "shift_date_yyyy-mm-dd" ||
        $op eq "map_date" ||
        $op eq "map_date_d/mm/yyyy" ||
        $op eq "map_date_d/m/yy" ||
        $op eq "map_date_d/m/yyyy"
      ) {
        if(defined $computed_shift){
          $arg1 = $computed_shift;
        } elsif(defined $date_shift){
          $arg1 = $date_shift;
        } else {
          $background->WriteToEmail("Error: no date shift exists for " .
            "file: $file_id\n");
          $background->Finish;
          exit;
        }
      }elsif ($op eq "set_and_map_id") {
        $op = "set_value";
        $arg1 = $to_patient_id;
      }
    }
    $bucket = "$op|$type|$path|$arg1|$arg2|$arg3",
#$background->WriteToEmail("Bucket: $bucket\n");
    $EditsByFile{$file_id}->{$bucket} = 1;
  }
}
my %FilesByEditGroups;
for my $f (keys %EditsByFile){
  my $EditGroupSummary;
  my @edit_keys = sort keys %{$EditsByFile{$f}};
  for my $k (0 .. $#edit_keys){
    $EditGroupSummary .= $edit_keys[$k];
    unless($k == $#edit_keys){ $EditGroupSummary .= "&" }
  }
  $FilesByEditGroups{$EditGroupSummary}->{$f} = 1;
}
my $rpt = $background->CreateReport("EditSpreadsheet");
my $num_edit_groups = keys %FilesByEditGroups;
$background->WriteToEmail("$num_edit_groups distinct edit groups found\n");
$rpt->print("file_id,subj," .
  "op,path,val1,val2,val3,Operation,description,notify\n");
my $first_line = 1;
for my $c (sort keys %FilesByEditGroups){
  for my $f (keys %{$FilesByEditGroups{$c}}){
    $rpt->print("$f,$FileToSubj{$f}");
    if($first_line){
      $rpt->print(",,,,,,BackgroundJsonEdit," .
        "\"From non-dicom PHI scan ($scan_id)\",\"$notify\"\n");
      $first_line = 0;
    } else {
      $rpt->print("\n");
    }
  }
#  $background->WriteToEmail("Command group: $c\n");
  my @edits = split /&/, $c;
  my @edit_h;
  for my $edit (@edits){
#  $background->WriteToEmail("Edit: $edit\n");
#   bucket => "$p_op|$type|$path|$q_arg1|$q_arg2|$q_arg3",
    my($op, $type, $path, $arg1, $arg2, $arg3) = split(/\|/, $edit);
    $op =~ s/"/""/g;
    $type =~ s/"/""/g;
    $path =~ s/"/""/g;
    $arg1 =~ s/"/""/g;
    $arg2 =~ s/"/""/g;
    $arg3 =~ s/"/""/g;
print STDERR "Op: $op\n";
    push @edit_h, {
      op => $op, type => $type, path => $path,
      arg1 => $arg1, arg2 => $arg2, arg3 => $arg3
    };
  }
  for my $e (
    sort 
    {$edit_sort_order->{$a->{op}} cmp $edit_sort_order->{$b->{op}}}
    @edit_h
  ){
    $rpt->print(",,\"$e->{op}\",\"<$e->{path}>\",\"<$e->{arg1}>\"," .
      "\"<$e->{arg2}>\",<$e->{arg3}>\n");
  }
}
my $end = time;
my $duration = $end - $start_time;
$background->WriteToEmail("finished scan\nduration $duration seconds\n");
$background->Finish;
