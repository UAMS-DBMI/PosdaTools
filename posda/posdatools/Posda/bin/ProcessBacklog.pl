#!/usr/bin/perl -w 
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = <<EOF;
 ProcessBacklog.pl
   Enter loop processing backlog controlled by posda_backlog db
 ProcessBacklog.pl -h
   Print this message 
EOF
if($#ARGV >= 0){ print $usage; exit }
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
my $abort_round = PosdaDB::Queries->GetQueryInstance("AbortRound");
my $add_wait_count = PosdaDB::Queries->GetQueryInstance("AddWaitCount");
my $add_process_count = PosdaDB::Queries->GetQueryInstance("AddProcessCount");
####

####
# Run the loop
sub Loop{
  my($status, $processor_pid, $idle_poll_interval, $last_service,
     $pending_change_request, $source_pending_change_request,
     $request_time, $num_files_per_round, $target_queue_size, $time_pending);
  main:
  while(1) {
    $get_control->RunQuery(
      sub {
        my($row) = @_;
        ($status, $processor_pid, $idle_poll_interval, $last_service,
         $pending_change_request, $source_pending_change_request,
         $request_time, $num_files_per_round, $target_queue_size,
         $time_pending) = @$row;
        },
      sub {}
    );
    if($status eq "waiting to go inservice"){
      $go_in_service->RunQuery(sub {}, sub {}, $$);
      print STDERR "Took control of backlog\n";
      next main;
    } elsif ($status eq "service process running"){
      unless($processor_pid == $$){
        print STDERR
          "Some other process ($processor_pid) has claimed control\n";
        exit;
      }
      if(
        $pending_change_request && $pending_change_request eq "shutdown" &&
        $processor_pid == $$
      ){
        $relinquish_control->RunQuery(sub {}, sub {});
        print STDERR "Relinquished control of backlog after $time_pending\n";
        exit;
      }
      InitUndefinedCounts();
      my($round_id, $round_desc) = CalcRound($num_files_per_round);
      unless(defined $round_desc){
        print STDERR "No requests to process (wait a minute)\n";
        sleep 10;
        next main;
      }
      my $tot_files = 0;
      print STDERR "Round: $round_id\n";
      for my $coll (keys %$round_desc){
        my $num_files = @{$round_desc->{$coll}};
        $tot_files += $num_files;
        print STDERR "\t$num_files\t $coll\n"
      }
      print STDERR "\t$tot_files total\n";
      my $count = GetPosdaQueueSize();
      while($count > $target_queue_size){
print STDERR "idle_poll_interval: $idle_poll_interval\n";
print STDERR "sleeping for 10 sec\n";
        $add_wait_count->RunQuery(sub{}, sub{}, $count, $round_id);
        sleep 10;
        $get_control->RunQuery(
          sub {
            my($row) = @_;
            ($status, $processor_pid, $idle_poll_interval, $last_service,
             $pending_change_request, $source_pending_change_request,
             $request_time, $num_files_per_round, $target_queue_size,
             $time_pending) = @$row;
          },
          sub {}
        );
        if(
          $pending_change_request && $pending_change_request eq "shutdown" &&
          $processor_pid == $$
        ){
          $relinquish_control->RunQuery(sub {}, sub {});
          print STDERR "Relinquished control of backlog after $time_pending\n";
          $abort_round->RunQuery(sub{}, sub{}, $round_id);
          exit;
        }
        unless($status eq "service process running" && $processor_pid == $$){
          print STDERR "Yikes - Bad control structure " .
            "for Backlog processor ($$):\n" .
            "\tstatus: $status\n" .
            "\tprocessor_pid: $processor_pid\n" .
            "\tidle_poll_interval: $idle_poll_interval\n" .
            "\tlast_service: $last_service\n" .
            "\tpending_change_request: $pending_change_request\n" .
            "\tsource_pending_change_request: " .
            "$source_pending_change_request\n" .
            "\trequest_time: $request_time\n" .
            "\tnum_files_per_round: $num_files_per_round\n" .
            "\ttarget_queue_size: $target_queue_size\n";
          die "Bailing out";
        }
        $count = GetPosdaQueueSize();
      }
      $add_process_count->RunQuery(sub{}, sub{}, $count, $round_id);
      ProcessRound($round_id, $round_desc);
      next main;
    } else {
      print STDERR "Yikes - Bad control structure " .
        "for Backlog processor ($$):\n" .
        "\tstatus: $status\n" .
        "\tprocessor_pid: $processor_pid\n" .
        "\tidle_poll_interval: $idle_poll_interval\n" .
        "\tlast_service: $last_service\n" .
        "\tpending_change_request: $pending_change_request\n" .
        "\tsource_pending_change_request: " .
        "$source_pending_change_request\n" .
        "\trequest_time: $request_time\n" .
        "\tnum_files_per_round: $num_files_per_round\n" .
        "\ttarget_queue_size: $target_queue_size\n";
      die "Bailing out";
    }
  }
}
####

####
# Initialize Undefined Counts
sub InitUndefinedCounts{
  $g_coll_no_dcounts->RunQuery(
    sub {
      my($row) = @_;
      my $collection = $row->[0];
      $ins_coll_count->RunQuery(sub{}, sub {}, $collection, 1);
    }, sub {}
  );
}
####

####
# Calculate a round
my $get_backlog_summary = PosdaDB::Queries->GetQueryInstance(
  "GetBacklogCountAndPrioritySummary"
);
my $get_files = PosdaDB::Queries->GetQueryInstance(
  "GetNRequestsForCollection"
);
my $create_round = PosdaDB::Queries->GetQueryInstance(
 "CreateRound"
);
my $get_round_id = PosdaDB::Queries->GetQueryInstance(
 "GetRoundId"
);
my $insert_round_count = PosdaDB::Queries->GetQueryInstance(
 "InsertRoundCounts"
);
sub CalcRound{
  my($num_files) = @_;
  $create_round->RunQuery(sub {}, sub {});
  my $id;
  $get_round_id->RunQuery(
    sub {
      my($row) = @_;
      $id = $row->[0];
    },
    sub { });
  my($tot_files, $scale_factor, %CollectionFiles);
  $tot_files = 0;
  $get_backlog_summary->RunQuery(
  sub {
    my($row) = @_;
    my($collection, $priority, $num_requests) = @$row;
    $insert_round_count->RunQuery(sub{}, sub{},
      $id, $collection, $num_requests, $priority);
    if($num_requests == 0 || $priority == 0) { return }
    $tot_files += $priority;
    $CollectionFiles{$collection} = $priority;
  }, sub {});
  if($tot_files == 0){
    return ($id, undef);
  }
  $scale_factor = $num_files / $tot_files;
  my $new_tot = 0;
  for my $k (keys %CollectionFiles){
    $CollectionFiles{$k} = int(($CollectionFiles{$k} * $scale_factor) + .5);
    $new_tot += $CollectionFiles{$k};
  }
  my %Round;
  collection:
  for my $coll(keys %CollectionFiles){
    if($CollectionFiles{$coll} == 0) {
      $Round{$coll} = [];
      next collection;
    }
    $get_files->RunQuery(sub {
      my($row) = @_;
      my($id, $coll, $file_path, $file_dig, $time_rcv, $size) = @$row;
      unless(exists $Round{$coll}) { $Round{$coll} = [] }
      push(@{$Round{$coll}}, {
        id => $id,
        coll => $coll,
        file => $file_path,
        dig => $file_dig,
        time_rcv => $time_rcv,
        size => $size
      });
    }, sub {}, $coll, $CollectionFiles{$coll});
  }
  return ($id, \%Round);
}
####
# Process a round
my $mark_file_as_in_posda = PosdaDB::Queries->GetQueryInstance(
 "MarkFileAsInPosda"
);
my $insert_round_collection = PosdaDB::Queries->GetQueryInstance(
 "InsertRoundCollection"
);
my $start_round = PosdaDB::Queries->GetQueryInstance("StartRound");
my $close_round = PosdaDB::Queries->GetQueryInstance("CloseRound");
sub ProcessRound{
  my($round_id, $round_desc) = @_;
  $start_round->RunQuery(sub{}, sub{}, $round_id);
  for my $collection (keys %$round_desc){
print STDERR "Processing Collecton $collection\n";
    my $files_inserted = 0;
    my $files_already_present = 0;
    my $files_failed_to_enter = 0;
    for my $f_desc (@{$round_desc->{$collection}}){
print STDERR "Inserting file $f_desc->{file}\n";
      my($file_id, $new_file) = EnterFileInPosda($f_desc);
      if(defined $file_id){
        if($new_file) {
          $files_inserted += 1;
        } else {
          $files_already_present += 1;
        }
print STDERR "Marking file in Posda\n";
        $mark_file_as_in_posda->RunQuery(sub {}, sub {},
          $file_id, $f_desc->{id});
      } else {
        $files_failed_to_enter += 1;
      }
    }
    $insert_round_collection->RunQuery(sub {}, sub {}, $round_id, $collection, 
      $files_inserted, $files_failed_to_enter, $files_already_present);
  }
  $close_round->RunQuery(sub {}, sub {}, $round_id);
}
####
# Enter File In Posda
#      my($file_id, $is_new_file) = EnterFileInPosda($f_desc);
#      $f_desc = {
#        id => $id,
#        coll => $coll,
#        file => $file_path,
#        dig => $file_dig,
#        time_rcv => $time_rcv,
#        size => $size
#      };
my $get_file_storage_roots = PosdaDB::Queries->GetQueryInstance(
  "GetPosdaFileStorageRoots"
);
my $get_file_id_by_digest = PosdaDB::Queries->GetQueryInstance(
  "GetPosdaFileIdByDigest"
);
my $start_t = PosdaDB::Queries->GetQueryInstance("StartTransactionPosda");
my $lock_file = PosdaDB::Queries->GetQueryInstance("LockFilePosda");
my $ins_file = PosdaDB::Queries->GetQueryInstance("InsertFilePosda");
my $end_t = PosdaDB::Queries->GetQueryInstance("EndTransactionPosda");
my $rollback = PosdaDB::Queries->GetQueryInstance("RollbackPosda");
my $get_current_posda_file_id = PosdaDB::Queries->GetQueryInstance(
  "GetCurrentPosdaFileId"
);
my $insert_file_location = PosdaDB::Queries->GetQueryInstance(
  "InsertFileLocation"
);
my $insert_import_event = PosdaDB::Queries->GetQueryInstance(
  "InsertImportEvent"
);
my $insert_file_import = PosdaDB::Queries->GetQueryInstance(
  "InsertFileImport"
);
my $make_file_ready_to_process = PosdaDB::Queries->GetQueryInstance(
  "MakePosdaFileReadyToProcess"
);
my %FileStorageRoots;
$get_file_storage_roots->RunQuery(
  sub {
    my($row) = @_;
    my($id, $root, $current, $class) = @$row;
    $FileStorageRoots{$root} = {
      id => $id, current => $current, class => $class
    };
  },
  sub {}
);
sub EnterFileInPosda{
  my($f_desc, $files_inserted, $files_already_present) = @_;
  my @posda_file_ids;
#print STDERR "Starting transaction\n";
#  $start_t->RunQuery(sub{}, sub{});
  $get_file_id_by_digest->RunQuery(
    sub {
      my($row) = @_;
      push(@posda_file_ids, $row->[0]);
    }, sub {},
    $f_desc->{dig}
  );
  my $posda_file_id;
  if(@posda_file_ids > 1){
    print STDERR "Multiple Posda File Ids for $f_desc->{dig}\n";
    for my $id (@posda_file_ids){
      print STDERR "\t$id\n";
    }
  }
  if(@posda_file_ids > 0){
    $posda_file_id = $posda_file_ids[0];
print STDERR "Found existing file\n";
  }
  my $is_new_file = 0;
  unless(defined $posda_file_id){
print STDERR "Creating new file\n";
    $ins_file->RunQuery(sub {}, sub {},
     $f_desc->{dig}, $f_desc->{size});
    $get_current_posda_file_id->RunQuery(
      sub {
        my($row) = @_;
        $posda_file_id = $row->[0];
      }, sub {});
    $is_new_file = 1;
  }
  if($is_new_file){
    my($fsr_id, $rel_path);
    fsr:
    for my $i (keys %FileStorageRoots){
      if($f_desc->{file} =~ /^$i\/(.*)/){
        $fsr_id = $FileStorageRoots{$i}->{id};
        $rel_path = $1;
        last fsr;
      } else {
        print STDERR "Couldn't find $i in $f_desc->{file}\n";
      }
    }
    if(defined($fsr_id) && defined($rel_path)){
      $insert_file_location->RunQuery(sub{}, sub{},
        $posda_file_id, $fsr_id, $rel_path);
    } else {
#print STDERR "Rollback\n";
#      $rollback->RunQuery(sub {}, sub {});
      return(undef, undef);
    }
  }
#print STDERR "Transaction complete\n";
#  $end_t->RunQuery(sub {}, sub{});
  $make_file_ready_to_process->RunQuery(sub {}, sub {}, $posda_file_id);
  $insert_import_event->RunQuery(sub {}, sub {},
    $f_desc->{time_rcv});
  $insert_file_import->RunQuery(sub {}, sub {},
    $posda_file_id, $f_desc->{file});
  return($posda_file_id, $is_new_file);
}
####
# Get PosdaQueueSize
my $get_posda_queue_size = PosdaDB::Queries->GetQueryInstance(
  "GetPosdaQueueSize"
);
sub GetPosdaQueueSize{
  my $count;
  $get_posda_queue_size->RunQuery(sub{
    my($row) = @_;
    $count = $row->[0];
  }, sub {});
  return $count;
}
###
Loop();
