use 5.10.0;
use File::Path 'make_path';
use lib 'Posda/include/';

my $fatal_msg = "Fatal error encountered, setup cannot continue :(";

sub create_cache_dirs {
  make_path("$ENV{POSDA_CACHE_ROOT}/Data");
  make_path("$ENV{POSDA_CACHE_ROOT}/Data/TempDirectory");
  make_path("$ENV{POSDA_CACHE_ROOT}/Data/HierarchicalExtractions");
  make_path("$ENV{POSDA_CACHE_ROOT}/Data/HierarchicalExtractions/data");
  make_path("$ENV{POSDA_CACHE_ROOT}/Data/DicomReceiver");
  make_path("$ENV{POSDA_CACHE_ROOT}/Data/PhiAnalysis");
  make_path("$ENV{POSDA_CACHE_ROOT}/Data/PhiAnalysis/data");
  make_path("$ENV{POSDA_CACHE_ROOT}/Data/TestData");
  make_path("$ENV{POSDA_CACHE_ROOT}/DicomFiles");
  make_path("$ENV{POSDA_CACHE_ROOT}/ProxyData");
  make_path("$ENV{POSDA_CACHE_ROOT}/ProxyData/Analysis");
  make_path("$ENV{POSDA_CACHE_ROOT}/NewItcToolsData");
  make_path("$ENV{POSDA_CACHE_ROOT}/NewItcToolsData/submission");
  make_path("$ENV{POSDA_CACHE_ROOT}/NewItcToolsData/submission/dicom");
  make_path("$ENV{POSDA_CACHE_ROOT}/NewItcToolsData/submission/dicom/incoming");
  make_path("$ENV{POSDA_CACHE_ROOT}/NewItcToolsData/persistent");
  make_path("$ENV{POSDA_CACHE_ROOT}/NewItcToolsData/working");
  make_path("$ENV{POSDA_CACHE_ROOT}/NewItcToolsData/db_defs");
  make_path("$ENV{POSDA_CACHE_ROOT}/NewItcToolsData/global_persistent");
  make_path("$ENV{POSDA_CACHE_ROOT}/NewItcToolsData/temp");
  make_path("$ENV{POSDA_CACHE_ROOT}/NewItcToolsData/archive");
  make_path("$ENV{POSDA_CACHE_ROOT}/NewItcToolsData/finalize");
  make_path("$ENV{POSDA_CACHE_ROOT}/UserData");
  make_path("$ENV{POSDA_CACHE_ROOT}/DicomReceiver");
  make_path("$ENV{POSDA_CACHE_ROOT}/dicom_info");
  make_path("$ENV{POSDA_CACHE_ROOT}/Data/dicom_info");
}

say "Welcome to the Posda Setup Tool!\n";

if (not defined $ENV{POSDA_ROOT}) {
  say "setup.pl cannot be executed directly. Pleasea use setup.sh instead!";
  die $fatal_msg;
}

say "Testing for all required Perl modules...";
eval {
  require Modern::Perl;
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
require JSON; JSON->import;
require DBD::Pg; DBD::Pg->import;
require Term::ReadKey; Term::ReadKey->import;

require Posda::Config; Posda::Config->import('Config');

say "\nCreating cache directory structure... " .
    "(if it already exists, nothing is done)";
create_cache_dirs();



say "\nCreating databases...";

my $db_list = Config('databases');

# loop over each entry, pull out the ones with an init
for my $db (keys %$db_list) {
  if (defined $db_list->{$db}->{init}) {
    my @files = @{$db_list->{$db}->{init}};
    my $db_name = $db_list->{$db}->{database};
    my $driver = $db_list->{$db}->{driver};

    `createdb $db_name`;
    if ($? == 0) {
      for my $file (@files) {
        say `psql $db_name < $file`;
      }
    } else {
      say "Skipped init files for already-existing database $name";
    }
  }
}

say "\nTesting database connections...";

map {
  my $name = $_;
  my $dbname = $db_list->{$name}->{database};
  my $driver = $db_list->{$name}->{driver};

  if ($driver eq 'postgres') {
    my $dbh = DBI->connect("DBI:Pg:database=$dbname");

    if (not defined $dbh) {
      say "Failed to connect to $name database! See previous errors for details.";
      die $fatal_msg;
    } else {
      say "Connection successful: $dbname ($name)";
    }
  } else {
    say "Skipped testing non-postgres database $name.";
  }
} keys %$db_list;

say "\nSetup completed successfully.";
