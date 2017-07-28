use lib 'Posda/include/';

use Modern::Perl;
use Method::Signatures::Simple;
use JSON;
use Term::ReadKey;
use DBD::Pg;

use Posda::Config 'Config';


my $fatal_msg = "Fatal error encountered, setup cannot continue :(";

if (not defined $ENV{POSDA_ROOT}) {
  say "reset.pl cannot be executed directly. Pleasea use reset.sh instead!";
  die $fatal_msg;
}

my $db_list = Config('databases');

# loop over each entry, pull out the ones with an init
for my $db (keys %$db_list) {
  if (defined $db_list->{$db}->{reset}) {
    my @files = @{$db_list->{$db}->{reset}};
    my $db_name = $db_list->{$db}->{database};
    my $driver = $db_list->{$db}->{driver};

    for my $file (@files) {
      say `psql $db_name < $file`;
    }
  }
}
