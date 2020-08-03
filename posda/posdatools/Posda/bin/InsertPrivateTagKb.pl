#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
InsertPrivateTagKb.pl <?bkgrnd_id?> <activity_id> <is_dry_run> <notify>
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
unless($#ARGV == 3){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 3). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $is_dry_run, $notify) = @ARGV;

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
my $ck = Query("FetchRowFromPrivateTagKbBySig");
my $upd = Query("UpdateRowInPrivateTagKbBySig");
my $q = Query("InsertIntoPrivateTagKb");
my $num_created = 0;
my $num_errors = 0;
my $num_same = 0;
my $num_diff = 0;
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
  if($pt_signature =~ /^<(.*)>$/) { $pt_signature = $1 }
  $i += 1;
  #$back->SetActivityStatus("processing $i, errors: $num_errors of $num_rows");
  $back->SetActivityStatus("same $num_same, different: $num_diff, new: $num_created, errors: $num_errors");
  if($pt_signature =~ /^\((....),\"([^\"]+)\",(..)\)$/){
    $pt_group = $1;
    $pt_owner = $2;
    $pt_element = $3;
    $pt_group = sprintf("%d", hex($pt_group));
    $pt_element = sprintf("%d", hex($pt_element));
    $pt_short_signature = $pt_signature;
    my($ex_owner, $ex_group, $ex_element, $ex_vr, $ex_vm, $ex_name);
    $ck->RunQuery(sub{
      my($row) = @_;
      ($ex_owner, $ex_group, $ex_element, $ex_vr, $ex_vm, $ex_name) = @{$row};
    }, sub{}, $pt_signature);
    if(defined $ex_owner){
      my @diffs;
      unless($ex_owner eq $pt_owner){ push @diffs, "owner: $ex_owner => $ex_owner" }
      unless($ex_group eq $pt_group){ push @diffs, "group: $ex_group => $pt_group" }
      unless($ex_element eq $pt_element){ push @diffs, "element: $ex_element => $pt_element" }
      unless($ex_vr eq $pt_consensus_vr) { push @diffs, "vr: \"$ex_vr\" => \"$pt_consensus_vr\"" }
      unless($ex_vm eq $pt_consensus_vm){ push @diffs, "vm: $ex_vm => $pt_consensus_vm" }
      unless($ex_name eq $pt_consensus_name){ push @diffs, "name: \"$ex_name\" => \"$pt_consensus_name\"" }
      if($#diffs < 0){
        #$back->WriteToEmail("No changes in $pt_signature\n");
        $num_same += 1;
      } else {
         my $changes = "";
         for my $i (0 .. $#diffs){
           $changes .= $diffs[$i];
           unless($i == $#diffs){ $changes .= ", " }
         }
        #### to do - update row in pt  ####
        if($is_dry_run){
          $back->WriteToEmail("Changes in $pt_signature: $changes (dry run only)\n");
        } else {
          $upd->RunQuery(sub{}, sub{},
            $pt_owner, $pt_group, $pt_element, $pt_consensus_vr, $pt_consensus_vm, $pt_consensus_name,
            $pt_signature);
          $back->WriteToEmail("Changed $pt_signature: $changes\n");
        }
        $num_diff += 1;
      }
    } else {
      if($is_dry_run){
        $back->WriteToEmail("New tag: $pt_signature (dry run only)\n");
      } else {
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
      }
      $num_created += 1;
    }
  } else {
    $back->WriteToEmail("Signature \"$pt_signature\" didn't match\n");
    $num_errors += 1;
  }
  $back->SetActivityStatus("same $num_same, different: $num_diff, new: $num_created, errors: $num_errors");
}
my $elapsed = time - $start;
$back->WriteToEmail("Processed $num_rows rows with $num_errors errors in $elapsed seconds\n  new: $num_created,\n  same: $num_same,\n  diff:: $num_diff\n");
$back->Finish("Processed $num_rows rows with $num_errors errors in $elapsed seconds new: $num_created, same: $num_same, diff:: $num_diff");;
