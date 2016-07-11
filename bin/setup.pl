use 5.10.0;
use lib 'Posda/include/';

my $fatal_msg = "Fatal error encountered, setup cannot continue :(";

say "Welcome to the Posda Setup Tool!\n";

if (not defined $ENV{POSDA_ROOT}) {
  say "setup.pl cannot be executed directly. Pleasea use setup.sh instead!";
  die $fatal_msg;
}

say "Testing for all required Perl modules...";
eval {
  require Modern::Perl;
  require Method::Signatures::Simple;
  require JSON;
  require Data::UUID;
  require DBD::Pg;
  require Switch;
  require Text::Diff;
  require Term::ReadKey;
};

if ($@) {
  say $@;
  say "One or more required Perl modules is missing! " .
      "See the previous errors for details.";
  die $fatal_msg;
} else {
  say "All modules are installed!";
}

# mimic 'use'
require Modern::Perl; Modern::Perl->import('2010');
require Method::Signatures::Simple; Method::Signatures::Simple->import;
require JSON; JSON->import;
require DBD::Pg; DBD::Pg->import;
require Term::ReadKey; Term::ReadKey->import;

require Posda::Config; Posda::Config->import('Config');

say "Creating cache directory structure...";
say `cd install_files;./create_cache_dirs.sh`;

say "Creating databases...";
`cd install_files;./create_databases.sh`;


say "Testing database connection...";
my $dbs = [
  ['authentication', Config('auth_db_name')],
  ['files', Config('files_db_name')],
  ['nicknames', Config('nicknames_db_name')],
  ['app status', Config('appstats_db_name')],
  # TODO: This DB is currently missing!
  # ['DICOM roots', Config('dicom_roots_db_name')],
];

map {
  my ($name, $dbname) = @$_;

  my $dbh = DBI->connect("DBI:Pg:database=$dbname");

  if (not defined $dbh) {
    say "Failed to connect to $name database! See previous errors for details.";
    die $fatal_msg;
  } else {
    say "Connection successful: $dbname ($name)";
  }
} @$dbs;


say "End";
