use lib 'Posda/include/';

use Modern::Perl '2010';

use Dispatch::LineReader;
use Dispatch::Select;
use Dispatch::EventHandler;

use Data::Dumper;
use File::Basename 'basename';

use Posda::ConfigRead;


$ENV{POSDA_DATABASE_CONFIG} = 'Config/databases.json';
use Posda::Config ('Config','Database');
use DBI;


# Read the current config
my $tag_groups = Posda::ConfigRead->ReadJsonFile("Config/DbIf/TagGroups.json");

# massage the json input into the database format
my @groups = map {
  my $g = $tag_groups->{$_};
  if ($g == 1) {
    $g = {}
  }
  [
    $_,
    [keys %{$g}]
  ]
} keys %$tag_groups;

say "Read $#groups tag groups from old json file.";

my $db_handle = DBI->connect(Database('posda_queries'));

my $qh = $db_handle->prepare(qq{
  insert into query_tag_filter
  values (?, ?)
});

for my $g (@groups) {
  say "Adding group to database: $g->[0]";
  $qh->execute(@$g);
}

$db_handle->disconnect;

