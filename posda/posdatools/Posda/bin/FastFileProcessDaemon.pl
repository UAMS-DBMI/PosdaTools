#!/usr/bin/perl -w 
# 
# FastFileProcessDaemon - A faster way to import into Posda
#
# This program manages the Redis-based import queue.
# Currently it is very simple, and just refills the queue from the
# database whenever it is empty.
#
# See FastFileProcessWorker.pl for the actual file import logic.
#

# These settings may need to be adjusted
use constant DBNAME => 'posda_files';
use constant WORKER_COUNT => 5;

###############################################################################

use Modern::Perl;

use Posda::Config ('Database', 'Config');
use DBD::Pg;

use JSON;
use Redis;


use constant REDIS_HOST => Config('redis_host') . ':6379';
$| = 1;

$SIG{INT}  = \&shut_down; # catch SIGINT

my $db = DBI->connect(Database(DBNAME));
unless($db) { die "couldn't connect to DB: DBNAME" }

my $redis = Redis->new(server => REDIS_HOST); #hostname from Docker-compose

say "FFPD: FastFileProcessDaemon starting up...";
$redis->del('quit'); # make sure we don't immediately quit

for my $i (1..WORKER_COUNT) {
  system("FastFileProcessWorker.pl &");
}

for my $i (1..WORKER_COUNT) {
  system("FastPixelInfoWorker.pl &");
}


while (1) {
  $db->ping or die "Lost connection to database";
  my $redis_queue_size = $redis->llen('files');

  if ($redis_queue_size == 0) {
    # say "FFPD: Queue is empty, checking to see if we can replenish it...";
    replenish_queue($db);
  }

  my $should_we_quit_now = $redis->get('quit');
  if (defined $should_we_quit_now) {
    say "FFPD: Shutdown signal received, exiting now. Goodbye!";
    shut_down();
  }

  sleep 1;

}


sub replenish_queue {
  my ($db) = @_;

  my $q = $db->prepare(qq{
    select file_id, root_path || '/' || rel_path as path
    from file
    natural join file_location
    natural join file_storage_root
    where is_dicom_file is null
      and ready_to_process
      and processing_priority is not null
    limit 1000
  });

  $q->execute();

  my $count = 0;
  while(my $h = $q->fetchrow_arrayref){
    my $json_string = encode_json($h);
    # say $json_string;
    $redis->lpush('files', $json_string);
    $count++;
  }

  if ($count == 0) {
    # say "FFPD: No files found, sleeping for 10 seconds...";
    sleep 10;
  } else {
    say "FFPD: Added $count files to the queue.";
  }

}

sub shut_down {

  $redis->set('quit', 1); # signal shutdown to workers

  $db->disconnect;
  $redis->quit;

  say "FFPD: Shut down completed.";
  exit;
}
