use Modern::Perl '2010';
use Method::Signatures::Simple;

use queries;
use DBI;

my $dbh = DBI->connect("dbi:Pg:database=posda_queries");

$dbh->do("truncate table queries");

my $qh = $dbh->prepare(qq{
  insert into queries values (?, ?, ?, ?, ?, ?, ?)

});

func insert_query($name, $query) {
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
