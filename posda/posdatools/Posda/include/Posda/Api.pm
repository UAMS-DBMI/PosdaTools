package Posda::Api;
use Modern::Perl '2010';

use REST::Client;
use Posda::Config ('Config', 'Database');

my $TOKEN = Config('api_system_token');

# Return a new REST::Client instance that has been pre-configured
# with the required authorization headers for the API.
sub new_rest_client {
  my $client = REST::Client->new();
  $client->addHeader('Authorization', "Bearer $TOKEN");

  return $client;
}
