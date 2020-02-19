#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
InsertPrivateTagKb.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id>> - activity
  <notify> - user to notify

Expects the following list on <STDIN>
  <pt_signature>&<pt_consensus_vr>&<pt_consensus_name>&<pt_consensus_vm>&<pt_consensus_description>&<pt_consensus_disposition>

Inserts rows into the pt table in schema private_tag_kb

Uses named query "InsertIntoPrivateTagKb"
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 3). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $notify) = @ARGV;

my @Rows;
while(my $line = <STDIN>){
  chomp $line;
  my($pt_signature, $pt_consensus_vr, $pt_consensus_name,
    $pt_consensus_vm, $pt_consensus_description, $pt_consensus_disposition) = split(/&/, $line);
  push @Rows, [
    $pt_signature, $pt_consensus_vr, $pt_consensus_name,
    $pt_consensus_vm, $pt_consensus_description, $pt_consensus_disposition
  ];
}
my $num_rows = @Rows;
print "Going to background to process $num_rows rows\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my %Hierarchy;
my $q = Query("InsertIntoPrivateTagKb");
my $num_created = 0;
my $num_errors = 0;
my $i = 0;
$back->WriteToEmail("Inserting $num_rows rows into pt\n");
my $start = time;

row:
for my $row (@Rows){
  my(
    $pt_signature,
    $pt_short_signature,
    $pt_owner,
    $pt_group,
    $pt_element,
    $pt_consensus_vr,
    $pt_consensus_vm,
    $pt_consensus_name, 
    $pt_consensus_disposition,
    $pt_consensus_description
  );
  ($pt_signature, $pt_consensus_vr, $pt_consensus_name, 
    $pt_consensus_vm, $pt_consensus_description, $pt_consensus_disposition) = @$row;
  $i += 1;
  $back->SetActivityStatus("processing $i, errors: $num_errors of $num_rows");
  if($pt_signature =~ /^\((....),\"([^\"]+)\",(..)\)$/){
    $pt_group = $1;
    $pt_owner = $2;
    $pt_element = $3;
    $pt_short_signature = $pt_signature;
    $q->RunQuery(sub{}, sub {},
      $pt_signature,
      $pt_short_signature,
      $pt_owner,
      $pt_group,
      $pt_element,
      $pt_consensus_vr,
      $pt_consensus_vm,
      $pt_consensus_name, 
      $pt_consensus_disposition,
      $pt_consensus_description
    );
    $back->WriteToEmail("Inserted row for $pt_signature\n");
    $num_created += 1;
  } else {
    $back->WriteToEmail("Signature \"$pt_signature\" didn't match\n");
    $num_errors += 1;
  }
  $back->SetActivityStatus("created $num_created, errors: $num_errors of $num_rows");
}
my $elapsed = time - $start;
$back->Finish("Processed $num_rows rows with $num_errors errors in $elapsed seconds");;
