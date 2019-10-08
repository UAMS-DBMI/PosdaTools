package Posda::Auth;

use Modern::Perl '2010';

use Posda::Config ('Config', 'Database');
use Posda::LDAPAuth;
use Posda::Passwords;

use DBI;

sub is_authorized {
  my ($username, $password) = @_;
  my $auth_type = Config('auth_type');

  # Use LDAP or Database, based on POSDA_AUTH_TYPE env var
  if ($auth_type eq 'ldap') {
    return Posda::LDAPAuth::ldap_auth($username, $password);
  } elsif ($auth_type eq 'database') {
    return db_auth($username, $password);
  } else {
    die "POSDA_AUTH_TYPE missing or not valid: $auth_type";
  }
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

1;
