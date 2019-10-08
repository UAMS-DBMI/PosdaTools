use Modern::Perl '2010';

use queries;
use DBI;

my $dbh = DBI->connect("dbi:Pg:database=posda_queries");

$dbh->do("truncate table queries");

my $qh = $dbh->prepare(qq{
  insert into queries values (?, ?, ?, ?, ?, ?, ?)

});

sub insert_query {
  my ($name, $query) = @_;
  # say $name;
  # say Dumper($query);
  $qh->execute($name, 
               $query->{query},
               $query->{args},
               $query->{columns},
               [sort keys(%{$query->{tags}})],
               $query->{schema},
               $query->{description},
  );
}

my $queries = $PosdaDB::Queries::Queries;

my $count = 0;
for my $name (sort keys(%$queries)) {
  insert_query($name, $queries->{$name});
  $count++;
}

say "Query count: $count";
