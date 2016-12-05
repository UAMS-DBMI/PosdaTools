#!/usr/bin/perl -w 
use strict;
use Posda::DB::PosdaFilesQueries;
####
# Create Query Handles
my $g_coll_no_dcounts = PosdaDB::Queries->GetQueryInstance(
  "GetListCollectionsWithNoDefinedCounts");
my $ins_coll_count = PosdaDB::Queries->GetQueryInstance(
  "InsertCollectionCountPerRound");
my $get_control = PosdaDB::Queries->GetQueryInstance(
  "GetBacklogControl");
my $go_in_service = PosdaDB::Queries->GetQueryInstance(
  "GoInService");
my $relinquish_control = PosdaDB::Queries->GetQueryInstance(
  "RelinquishBacklogControl");
####

####
# Run the loop
my($status, $processor_pid, $idle_poll_interval, $last_service,
   $pending_change_request, $source_pending_change_request, $request_time,
   $num_files_per_round, $target_queue_size, $time_pending);
main:
while(1) {
  $get_control->RunQuery(
    sub {
      my($row) = @_;
      ($status, $processor_pid, $idle_poll_interval, $last_service,
       $pending_change_request, $source_pending_change_request, $request_time,
       $num_files_per_round, $target_queue_size, $time_pending) = @$row;
      },
    sub {}
  );
  if($status eq "waiting to go inservice"){
    $go_in_service->RunQuery(sub {}, sub {}, $$);
    print STDERR "Took control of backlog\n";
    next main;
  } elsif ($status eq "service process running"){
    unless($processor_pid == $$){
      print STDERR "Some other process ($processor_pid) has claimed control\n";
    }
  }
  if($pending_change_request && $pending_change_request eq "shutdown"){
    $relinquish_control->RunQuery(sub {}, sub {});
    print STDERR "Relinquished control of backlog after $time_pending\n";
    exit;
  }
  InitUndefinedCounts();
  my $round_desc = CalcRound();
print STDERR "idle_poll_interval: $idle_poll_interval\n";
print STDERR "sleeping for 10 sec\n";
  sleep 10;
}
####

####
# Initialize Undefined Counts
sub InitUndefinedCounts{
  $g_coll_no_dcounts->RunQuery(
    sub {
      my($row) = @_;
      my $collection = $row->[0];
print STDERR "Inserting count of 0 for $collection\n";
      $ins_coll_count->RunQuery(sub{}, sub {}, $collection, 0);
    }, sub {}
  );
}
####

####
# Calculate a round
sub CalcRound{
  
}
####
