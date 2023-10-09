#!/usr/bin/perl -w
use strict;
use Modern::Perl;

package Posda::EditStateChange;
use JSON;
use Posda::Config 'Config';
use Posda::Api;

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

  my $client = Posda::Api->new_rest_client();
  $client->POST($STATE_URL, $encoded_payload);

  my $code = $client->responseCode();
  my $content = $client->responseContent();
  return $code, $content;
}
