package Posda::LDAPAuth;

use Modern::Perl '2010';
use Method::Signatures::Simple;

use Net::LDAP;

# TODO: This needs to be moved to a configuration file
my $LDAP_URL = 'tcia-ldap-2-red:1389';
my $LDAP_BASE = 'dc=cancerimagingarchive,dc=net';
my $LDAP_FILTER = '(cn=$username)';

# Test if the given username/password is valid, using LDAP
# Returns 0 if either value is incorrect, 1 if correct.
func ldap_auth($username, $password) {
  my $ldap = Net::LDAP->new($LDAP_URL);

  # Double-interpolate from the filter var
  # This is ugly and probably shoudln't be here
  my $filter;
  eval "\$filter = qq/$LDAP_FILTER/";

  my $search = $ldap->search(
    base => $LDAP_BASE,
    filter => $filter,
    attrs => ['dn']
  );

  # If the username was incorrect, or otherwise could not be found
  # with the configured base and filter, entry will be undefined.
  if (not defined $search->entry) {
    $ldap->unbind;
    return 0;
  }

  my $user_dn = $search->entry->dn;
  my $resp = $ldap->bind($user_dn, password => $password);

  $ldap->unbind;
  if ($resp->is_error) {
    return 0;
  } else {
    return 1;
  }
}

1;
