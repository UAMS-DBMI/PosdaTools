package Posda::Nicknames2Factory;
use Modern::Perl '2010';
use Method::Signatures::Simple;

use Posda::Nicknames2;
use DBI;

use constant DBNAME => 'posda_nicknames';

my $cache = {};
my $connection;


func __get_db_connection() {
  if (not defined $connection) {
    $connection = DBI->connect("dbi:Pg:dbname=" . DBNAME);
  }

  return $connection;
}

func get($project_name, $site_name, $subj_id) {
  my $key = "$project_name||$site_name||$subj_id";
  if (not defined $cache->{$key}) {
    $cache->{$key} = Posda::Nicknames2->new(
      __get_db_connection(),
      $project_name, $site_name, $subj_id);
  }

  return $cache->{$key};
}

func clear() {
  undef $cache;
}

1;
