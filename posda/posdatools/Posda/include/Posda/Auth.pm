package Posda::Auth;

use Modern::Perl '2010';

use REST::Client;
use JSON;
use Data::Dumper;

use Posda::Config ('Config', 'Database');
use Posda::LDAPAuth;
use Posda::Passwords;

use DBI;

sub is_authorized {
  my ($username, $password) = @_;
  my $auth_type = Config('auth_type');

  return api_auth($username, $password);


  # # Use LDAP or Database, based on POSDA_AUTH_TYPE env var
  # if ($auth_type eq 'ldap') {
  #   return Posda::LDAPAuth::ldap_auth($username, $password);
  # } elsif ($auth_type eq 'database') {
  #   return db_auth($username, $password);
  # } else {
  #   die "POSDA_AUTH_TYPE missing or not valid: $auth_type";
  # }
}

sub db_auth {
  my ($username, $password) = @_;
  my $dbh = DBI->connect(Database('posda_auth'));

  my $stmt = $dbh->prepare(qq{
    select password
    from users
    where user_name = ?
  });

  $stmt->execute(($username));
  my $row = $stmt->fetchrow_arrayref();
  my $correct_pass = $row->[0];

  $stmt->finish;
  $dbh->disconnect;

  return Posda::Passwords::is_valid($correct_pass, $password);
}

# submit login request to api, return token if successful
sub api_auth {
  my ($username, $password) = @_;

  my $client = REST::Client->new();
  $client->setHost(Config('internal_api_url'));

  my $form_data = substr($client->buildQuery({
        username => $username,
        password => $password,
        # client_id => $client_id,
        # client_secret => $client_secret,
        # grant_type => 'password',
  }), 1);

  $client->POST(
    '/auth/token',
    $form_data,
    {'Content-type' => 'application/x-www-form-urlencoded'}
  );

  my $resp_code = $client->responseCode();
  if ($resp_code != 200) {
    print STDERR $resp_code, $client->responseContent(), "\n";
    return 0;
  }

  my $response = from_json($client->responseContent());

  my $bearer_token = $response->{access_token};
  return $bearer_token;
}

1;
