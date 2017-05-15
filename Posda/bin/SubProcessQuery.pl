#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Debug;
my $dbg = sub { print STDERR @_ };
use DBI;
use Storable qw( store_fd fd_retrieve );
my $help = <<EOF;
Inputs (on STDIN)
QuerySpec = {
  name => <query_name>,
  args => [ <arg1_name>, ... ],
  columns => [ <col_1>, ... ],    # if select
  schema => <schema_name>,
  db_name => <db_name>,
  db_type => postgres | mysql,
  [db_host => <host_addr>,]
  [db_user => <db_user>,]
  [db_pass => <db_passwd>,]
  query => <query>,
  bindings => [<bind_1>, ... ]
};
Outputs (on STDOUT):
Results = {
  Status => "OK" | "Error",
  Message => <msg>,          # if error
  AdditionalInfo => <info>, # also if error (optional)
  Rows => [                  # otherwise if select
    <col_1>,
    ...,
  ],
  NumRows => <n>,            # otherwise if not select (update or insert)
};
EOF
my $results;
if($#ARGV == 0 && ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
sub Error{
  my($message, $addl) = @_;
  $results->{Status} = "Error";
  $results->{Message} = $message;
  if($addl){ $results->{AdditionalInfo} = $addl }
  store_fd($results, \*STDOUT);
  exit;
}
my $query_spec = fd_retrieve(\*STDIN);
#print STDERR "query_spec = ";
#Debug::GenPrint($dbg, $query_spec, 1);
#print STDERR "\n";
my $dbh = DBI->connect($query_spec->{connect});
unless($#{$query_spec->{args}} == $#{$query_spec->{bindings}}){
  my $required = @{$query_spec->{args}};
  my $supplied = @{$query_spec->{bindings}};
  Error("Binding error: $required required, $supplied supplied");
}
my $q = $dbh->prepare($query_spec->{query});
unless($q){
  Error("Can't prepare query ($!) : $query_spec->{query}");
}
my $q_result = $q->execute(@{$query_spec->{bindings}});
unless($q_result){
  my $err = $q->errstr;
  Error("Can't execute query\n\t$err\nquery:\n$query_spec->{query}");
}
if($query_spec->{query} =~ /^select/){
  my @rows;
  while(my $h = $q->fetchrow_hashref){
    my @r;
    for my $k (@{$query_spec->{columns}}){
      push @r, $h->{$k};
    }
    push @rows, \@r;
  }
  $results->{Status} = "OK";
  $results->{Rows} = \@rows;
  store_fd($results, \*STDOUT);
} else {
  $results->{Status} = "OK";
  $results->{NumRows} = $q_result;
  store_fd($results, \*STDOUT);
}
