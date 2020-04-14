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

sub new {
  my($class, $export_event_id, $base_url, $num_files, $configuration, $protocol_specific_params) = @_;
  my $self = $class->SUPER::new($export_event_id, $base_url, $num_files, $configuration, $protocol_specific_params);

  # TODO: add check
  #check to see if an import_event_id exists and create if it doesn't
  CreateImportEvent($self);

  $self->{redis} = Redis->new(server => REDIS_HOST);

  return bless $self, $class;
}

sub CreateImportEvent{
  my($this) = @_;

  my $client = REST::Client->new();
  $client->setHost($this->{base_url});

  my $form_data = $client->buildQuery({
      source => "posda_to_posda_transfer",
      comment => $this->{params}->{import_comment},
      expected_count => $this->{num_files},
  });

  $client->PUT("/papi/v1/import/event$form_data");

  my $resp_code = $client->responseCode();
  if ($resp_code != 200) {
    die $resp_code, $client->responseContent(), "\n";
  }

  my $response = from_json($client->responseContent());
  print "Created import event $response->{import_event_id}";
  $this->{import_event_id} = $response->{import_event_id};
}

sub TransferAnImage{
  my($this, $file_id, $file_location, $delete_after_transfer) = @_;

  #print STDERR "Adding to redis $file_id -> $this->{export_event_id} ($file_location)\n";
  $this->{redis}->lpush('posda_to_posda_transfer',
                        to_json([$this->{export_event_id},
                                 $this->{import_event_id},
                                 $file_id,
                                 $file_location,
                                 $this->{base_url},
                                 $delete_after_transfer]));
};
1;
