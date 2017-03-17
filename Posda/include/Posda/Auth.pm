package Posda::Auth;

use Modern::Perl '2010';
use Method::Signatures::Simple;

use Posda::LDAPAuth;

func is_authorized($username, $password) {
  # use LDAP, or fall back to DB?
  # TODO: Actually make this an option!
  
  # # login
  # my $dbh = DBI->connect(Database('posda_auth'));
  # my $stmt = $dbh->prepare(qq{
  #   select password
  #   from users
  #   where user_name = ?
  # });

  # $stmt->execute(($user));
  # my $row = $stmt->fetchrow_arrayref();
  # my $correct_pass = $row->[0];

  # $stmt->finish;
  # $dbh->disconnect;

  # if ($this->CheckPassword($correct_pass, $passwd)) {
  #   print STDERR "Login succeeded.\n";
  #   $this->SetUserPrivs($user);
  #   $this->AutoRefresh;
  # } else {
  #   print STDERR "Login failed!\n";
  #   $this->QueueJsCmd("alert('Incorrect login!')");
  # }

  return Posda::LDAPAuth::ldap_auth($username, $password);
}

1;
