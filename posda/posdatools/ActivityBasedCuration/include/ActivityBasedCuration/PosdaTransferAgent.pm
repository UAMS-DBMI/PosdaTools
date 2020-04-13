#!/usr/bin/perl -w
use strict;
package ActivityBasedCuration::PosdaTransferAgent;
use ActivityBasedCuration::TransferAgent;
use REST::Client;
use Redis;
use JSON;
use vars qw( @ISA );
@ISA = ("ActivityBasedCuration::TransferAgent");
use Posda::DB qw(Query);

use constant REDIS_HOST => 'redis:6379';

sub TransferAnImage{
  my($this, $file_id, $file_location, $protocol_specific_file_params) = @_;
  #check to see if an import_event_id exists and create if it doesn't
  my $client = REST::Client->new();
  $client->setHost($this->{config}->{base_url});

  #check to see if redis is configured

  print STDERR "Adding to redis $file_id -> $export_event_id ($temp_file)\n";
  # TODO: pull the file out of the hash here
  $this->{redis}->lpush('posda_to_posda_transfer',
                to_json([$export_event_id, $file_id, $temp_file]));
};
1;
