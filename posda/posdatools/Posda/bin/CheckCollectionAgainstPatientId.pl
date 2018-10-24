#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
/CheckCollectionAgainstPatientId.pl <id> <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  email sent to <notify>

Expects the following list on <STDIN>
  <collection>&<patient_id>
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 1){
  print "Invalid number of args\n$usage";
  exit;
}
my($invoc_id, $notify) = @ARGV;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
my %PatToCollection;
my $errors = 0;
while(my $line = <STDIN>){
  chomp $line;
  my($collection, $patient_id) = split(/&/, $line);
  if(exists $PatToCollection{$patient_id}){
    $background->WriteToEmail("Pat ($patient_id) is mapped more than once:\n" .
      "\tPatToCollection{$patient_id}\n" .
      "\tcollection\n");
  } else {
    $PatToCollection{$patient_id} = $collection;
  }
}
print "Finished Building Structure\nEntering Background\n";
$background->ForkAndExit;
my $q = Query("patient_id_and_collection_by_like_collection");
my %DbPatToCollection;
my $db_errors = 0;
$q->RunQuery(sub {
  my($row) = @_;
  my($collection, $pat_id) = @$row;
  if(exists $DbPatToCollection{$pat_id}){
    $background->WriteToEmail("Pat ($pat_id) in db for more than one collection:\n" .
      "\t$DbPatToCollection{$pat_id}\n" .
      "\t$collection\n");
  } else {
    $DbPatToCollection{$pat_id} = $collection;
  }
}, sub {}, "CPTAC%");
for my $pat_id (keys %DbPatToCollection){
  if($PatToCollection{$pat_id} ne $DbPatToCollection{$pat_id}){
    $background->WriteToEmail("Pat($pat_id) doesn't match spec:\n" .
      "\tDb: $DbPatToCollection{$pat_id}\n" .
      "\tSpec: $PatToCollection{$pat_id}\n");
  }
}
$background->Finish;
