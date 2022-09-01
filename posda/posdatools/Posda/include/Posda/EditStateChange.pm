#!/usr/bin/perl -w
use strict;
package Posda::EditStateChange;
use REST::Client;
use JSON;
use Posda::Config 'Config';
my $API_URL = Config('internal_api_url');
my $STATE_URL = "$API_URL/v1/edits/state";

use Debug;
my $dbg = sub {print @_};

sub Trans{
  my ($id, $old_state, $new_state) = @_;
  my $payload = {
    edit_id => $id,
    expected_state => $old_state,
    new_state => $new_state
  };

  my $encoded_payload = encode_json($payload);

  my $client = REST::Client->new();
  $client->POST($STATE_URL, $encoded_payload);

  my $code = $client->responseCode();
  my $content = $client->responseContent();
  return $code, $content;
}
