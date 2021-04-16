#!/usr/bin/perl -w
use strict;
package ActivityBasedCuration::PosdaTransferAgent;
use ActivityBasedCuration::TransferAgent;
use REST::Client;
use Redis;
use JSON;
use Posda::Config 'Config';
use vars qw( @ISA );
@ISA = ("ActivityBasedCuration::TransferAgent");
use Posda::DB qw(Query);

use constant REDIS_HOST => Config('redis_host') . ':6379';

sub new {
  my($class, $export_event_id, $base_url, $num_files, $configuration, $protocol_specific_params) = @_;
  my $self = $class->SUPER::new($export_event_id, $base_url, $num_files, $configuration, $protocol_specific_params);

  # see if there is an api key
  if (defined $self->{config}->{apikey}) {
    $self->{apikey} = $self->{config}->{apikey};
  }

  if (defined $self->{config}->{origin}) {
    $self->{origin} = $self->{config}->{origin};
  } else {
    $self->{origin} = "undefined posda_to_posda_transfer";
  }

  if(exists $protocol_specific_params->{destination_import_event_id}){
    $self->{import_event_id} = $protocol_specific_params->{destination_import_event_id};
  } else {
    CreateImportEvent($self);
  }

  $self->{redis} = Redis->new(server => REDIS_HOST);

  return bless $self, $class;
}

sub CreateImportEvent{
  my($this) = @_;

  my $client = REST::Client->new();
  $client->setHost($this->{base_url});

  my $form_data = $client->buildQuery({
      origin => $this->{origin},
      source => $this->{params}->{import_comment},
      expected_count => $this->{num_files},
  });

  $client->PUT("/v1/import/event$form_data", undef, {apikey => $this->{apikey}});

  my $resp_code = $client->responseCode();
  if ($resp_code != 200) {
    die $resp_code, $client->responseContent(), "\n";
  }

  my $response = from_json($client->responseContent());
  print STDERR "Created import event $response->{import_event_id}";
  $this->{import_event_id} = $response->{import_event_id};
  Query("SetDestinationImportEventId")->RunQuery(sub{}, sub{},
    $response->{import_event_id}, $this->{export_event_id});
}

sub CloseImportEvent{
  my($this) = @_;

  my $client = REST::Client->new();
  $client->setHost($this->{base_url});

  $client->POST("/v1/import/event/$this->{import_event_id}/close",
                undef,
                {apikey => $this->{apikey}});

  my $resp_code = $client->responseCode();
  if ($resp_code != 200) {
    my $content = $client->responseContent();
    return "ERROR: $resp_code: $content";
  }
  Query("CloseImportEvent")->RunQuery(sub{}, sub{}, $this->{export_event_id});

  return "SUCCESS: Closed import event $this->{import_event_id} ($this->{export_event_id})";
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
                                 $this->{apikey},
                                 $delete_after_transfer]));
};
1;
