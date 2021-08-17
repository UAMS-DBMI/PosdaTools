package Posda::DefacingSubmit;

use JSON;
use Redis;
use Posda::Config 'Config';

use constant REDIS_HOST => Config('redis_host') . ':6379';
use constant QUEUE_NAME => 'defacing_queue';

my $redis = undef;

sub AddToDefacingQueue {
  my ($file_nifti_defacing_id, $nifti_file_id) = @_;

  ConnectToRedis();
  $redis->lpush(
    QUEUE_NAME,
    to_json([$file_nifti_defacing_id, $nifti_file_id])
  );
}

sub ConnectToRedis {
  if (not defined $redis) {
    $redis = Redis->new(server => REDIS_HOST);
  }
}

1;
