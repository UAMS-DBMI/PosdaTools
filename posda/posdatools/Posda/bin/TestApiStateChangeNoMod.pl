#!/usr/bin/perl -w
use strict;
use REST::Client;
use JSON;
use Posda::Config 'Config';
my $API_URL = Config('internal_api_url');
my $STATE_URL = "$API_URL/v1/edits/state";

use Debug;
my $dbg = sub {print @_};

my $usage = <<EOF;
TestApiStateChange.pl <edit_id> <expected_state> <new_state>

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $num_args = @ARGV;
  die "wrong number of args $num_args vs 3\n$usage";
}
my($edit_id, $expected_state, $new_state) = @ARGV;
my $payload = {
  edit_id => $edit_id,
  expected_state => $expected_state,
  new_state => $new_state
};

print "Payload: ";
Debug::GenPrint($dbg, $payload, 1);
print "\n";

my $encoded_payload = encode_json($payload);
print "Encoded payload: $encoded_payload\n";

print "STATE_URL: $STATE_URL\n";
my $client = REST::Client->new();
$client->POST($STATE_URL, $encoded_payload);

my $code = $client->responseCode();
print "Code:$code\n";
my $content = $client->responseContent();
if($content eq ""){
  print "No JSON content\n";
} else {
  print "Json:";
  Debug::GenPrint($dbg, decode_json($content), 1);
  print "\n";
}
