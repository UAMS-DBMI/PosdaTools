use strict;
package ActivityBasedCuration::SendToAnotherPosda;
use ActivityBasedCuration::WorkflowDefinition;
use ActivityBasedCuration::ElementDescriptions;
use Redis;
use JSON;
use Debug;
use Posda::Config 'Config';
my $dbg = sub {print STDERR @_};

use constant REDIS_HOST => Config('redis_host') . ':6379';

sub new {
  my($class, $export_event_id, $waiting_files,
     $pending_files, $transferred_files,
     $failed_temporary_files, $failed_permanent_files) = @_;

  # TODO: create import event on other posda system here and store in hash

  my $this = {
    redis => Redis->new(server => REDIS_HOST)
  };
  return bless $this, $class;
}

sub TransferAnImage {
  my($self, $export_event_id, $file_id, $temp_file) = @_;
  print STDERR "Adding to redis $file_id -> $export_event_id ($temp_file)\n";
  # TODO: pull the file out of the hash here
  $self->{redis}->lpush('posda_to_posda_transfer',
                to_json([$export_event_id, $file_id, $temp_file]));
}
