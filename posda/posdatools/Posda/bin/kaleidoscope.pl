#!/usr/bin/env perl

use JSON;
use REST::Client;
use Try::Tiny;

my $external_url = $ENV{POSDA_EXTERNAL_HOSTNAME};

$|++;

my $host = $ARGV[0];
my $port = $ARGV[1];
my $dir = $ARGV[2];
my $color = $ARGV[3];
my $user = $ARGV[4];

my $prot = "http:";
if(exists($ENV{POSDA_SECURE_ONLY}) && $ENV{POSDA_SECURE_ONLY}){
  $prot = "https:";
}

try {
  my $client = REST::Client->new();
  # Currently, assume the webservice is running on localhost
  # TODO: this should probably be a configuration variable!
  $client->GET("http://kaleidoscope:8089/api/new_token/$user");
  my $resp = decode_json($client->responseContent());
  my $token = $resp->{token};


  print "Redirect to $prot//$external_url/k/?token=$token\n";
} catch {
  print "Login token error: $@\n";
  print "Redirect to $prot//$external_url/k/error.html\n";
};

sleep 20;
