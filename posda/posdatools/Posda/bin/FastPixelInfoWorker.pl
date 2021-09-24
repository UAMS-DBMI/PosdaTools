#!/usr/bin/perl -w
#
# FastPixelInfoWorker
#
# This program reads from a simple Redis based queue and populates the
# pixel data table.
# If the key 'quit' is defined, it will exit.
#
# See FastFileProcessDaemon.pl for the queue details
#
#

# These settings may need to be adjusted
use constant DBNAME => 'posda_files';

###############################################################################

use Modern::Perl;

use DBD::Pg;

use Posda::Config ('Database', 'Config');
use Posda::DB 'Query';

use Posda::Try;
use Posda::DB::DicomDir;
use Posda::DB::DicomIod;

use JSON;
use Redis;

use constant REDIS_HOST => Config('redis_host') . ':6379';

$| = 1; # Set non-buffered output mode

say "FPIW: FastPixelInfoWorker Starting up...";

# Setup phase
#
my $db = DBI->connect(Database(DBNAME));
unless($db) { die "couldn't connect to DB: DBNAME" }


my $mark_no_pixels = Query('MarkDicomFileAsNotHavingPixelData');
my $insert_pixel_info = Query('PopulatePixelInfoInDicomFile');

my $redis = Redis->new(server => REDIS_HOST); #hostname from Docker-compose

while (1) {
  my ($key, $next_thing) = $redis->brpop('pixel_location', 5);
  # say $next_thing;

  if (defined $key) {
    my ($file_id, $file_path) = @{decode_json($next_thing)};
    say "FPIW: Processing $file_id, $file_path";
    eval {
      PopulateOneFile($file_id, $file_path);
      1; # worked okay, so don't execute the or block
    } or do {
      my $error = $@ || "unknown error";
      say "FPIW: ERROR failed to process $file_id: $error";
    };
  }

  my $should_we_quit_now = $redis->get('quit');
  if (defined $should_we_quit_now) {
    say "FPIW: Worker stopping.";
    $db->disconnect;
    $redis->quit;
    exit;
  }

}


sub PopulateOneFile {
  my ($file_id, $file_path) = @_;

    my $try = Posda::Try->new($file_path);
    unless(exists $try->{dataset}) {
      say "File ($file_id): $file_path didn't parse";
      return;
    }
    my $ds = $try->{dataset};
    if(exists $ds->{0x7fe0}->{0x10}){
      my $pix = $ds->{0x7fe0}->{0x10};
      my $pixel_data_offset = $pix->{file_pos};
      my $pixel_data_length = length $pix->{value};
      my $ctx = Digest::MD5->new;
      $ctx->add($pix->{value});
      my $pixel_data_digest = $ctx->hexdigest;
      $insert_pixel_info->RunQuery(sub {}, sub {},
        $pixel_data_digest, $pixel_data_offset, $pixel_data_length, $file_id);
    } else {
      $mark_no_pixels->RunQuery(sub{}, sub{}, $file_id);
    }

}
