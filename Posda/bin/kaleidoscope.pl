#!/usr/bin/env perl

use JSON;
use REST::Client;

$|++;

my $host = $ARGV[0];
my $port = $ARGV[1];
my $dir = $ARGV[2];
my $color = $ARGV[3];
my $user = $ARGV[4];


my $client = REST::Client->new();
$client->GET("http://tcia-utilities/api/new_token/$user");
my $resp = decode_json($client->responseContent());
my $token = $resp->{token};


print "Redirect to http://tcia-utilities/?token=$token\n";

sleep 20;
