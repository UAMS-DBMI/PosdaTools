package Posda::NBIASubmit;

use REST::Client;
use JSON;
use Data::Dumper;
use Redis;
use Digest::MD5;

use constant REDIS_HOST => 'redis:6379';

my $redis = undef;


sub GenerateFilename {
  my ($sop_instance_uid) = @_;

  my $ctx = Digest::MD5->new;
  $ctx->add($sop_instance_uid);
  my $dig = $ctx->hexdigest;

  $dig =~ /(..)(..)(..).*/;

  return "$1/$2/$3/$dig.dcm";
}


sub AddToSubmitAndThumbQs {
  my ($subprocess_invocation_id, $file_id, $project_name,
      $site_name, $site_id, $batch, $filename) = @_;

  AddToSubmissionQueue($subprocess_invocation_id, $file_id,
                       $project_name, $site_name, $site_id, $batch, $filename);
  AddToThumbnailQueue($filename);
}

sub AddToSubmissionQueue {
  my ($subprocess_invocation_id, $file_id, $project_name, $site_name,
      $site_id, $batch, $filename) = @_;

  ConnectToRedis();
  $redis->lpush('submission_required',
    to_json([$subprocess_invocation_id, $file_id, $project_name, $site_name,
             $site_id, $batch, $filename]));
}

sub AddToThumbnailQueue {
  my ($filename) = @_;

  ConnectToRedis();
  $redis->lpush('thumbnails_required', $filename);
}

sub ConnectToRedis {
  if (not defined $redis) {
    $redis = Redis->new(server => REDIS_HOST);
  }
}

sub QuitRedis {
  if ($redis != undef) {
    $redis->quit;
  }
}

sub Client {
  my $client = REST::Client->new();
  $client->setHost('https://public-dev.cancerimagingarchive.net');
  return $client;
}

sub Login {
  my ($username, $password, $client_id, $client_secret) = @_;


  my $client = Client;
  my $form_data = substr($client->buildQuery({
        username => $username,
        password => $password,
        client_id => $client_id,
        client_secret => $client_secret,
        grant_type => 'password',
  }), 1);

  $client->POST(
    '/nbia-api/oauth/token',
    $form_data,
    {'Content-type' => 'application/x-www-form-urlencoded'}
  );

  my $resp_code = $client->responseCode();
  if ($resp_code != 200) {
    die $resp_code, $client->responseContent(), "\n";
  }

  my $response = from_json($client->responseContent());
  print Dumper($response);

  my $bearer_token = $response->{access_token};
  return $bearer_token;
}

sub _submitFile {
  my ($bearer_token, $project_name, $site_name, $site_id, $batch, $filename) = @_;

  my $client = Client;
  my $form_data = substr($client->buildQuery({
      project => $project_name,
      siteName => $site_name,
      siteID => $site_id,
      batch => $batch,
      uri => $filename,
  }), 1);

  # Now submit a file
  $client->POST(
    'nbia-api/services/submitDICOM',
    $form_data,
    {
      'Content-type' => 'application/x-www-form-urlencoded',
      'Authorization' => "Bearer $bearer_token",
    }
  );

  my $resp_code = $client->responseCode();
  if ($resp_code != 200) {
    return [$resp_code, $client->responseContent(), $filename];
  } else {
    return [$resp_code];
  }
}

sub SubmitFile {
  my ($bearer_token, $project_name, $site_name, $site_id, $batch, $filename) = @_;

  # Sometimes the API failes for no reason. Try it a few times before giving up
  my $i = 5;
  my $ret;
  while ($i) {
    $ret = _submitFile($bearer_token, $project_name, $site_name, $site_id, $batch, $filename);
    if ($ret->[0] == 200) {
      print ".\n";
      return;
    }
    sleep(1);
    $i--;
  }

  my ($resp_code, $response, $none) = @{$ret};
  die "NBIA Submission failed: $resp_code $response $filename\n";

}

1;
