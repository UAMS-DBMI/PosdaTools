#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
$| = 1;
use Debug;
my $dbg = sub { print STDERR @_ };
use DBI;
use Storable qw( store_fd fd_retrieve );
my $help = <<EOF;
Inputs (on STDIN - as a serialized perl datastructure)
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
Outputs (on STDOUT one line per row, or error, as available):
(if error)
ERROR: <message>

(if select, for each row selected)
ROW:<col_1>|<col_2>|...|<last_col>

(if select, at end)
RESULTS: <n> rows selected

(if not select)
RESULTS: query affected <n> rows

column values are url_encoded to escape vertical bars and newlines

EOF
my $results;
if($#ARGV == 0 && ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
sub Error{
  my($message) = @_;
  print "ERROR: $message\n";
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
if($query_spec->{query} =~ /^\s*select/){
  my $num_rows = 0;
  while(my $h = $q->fetchrow_hashref){
    $num_rows += 1;
    print "ROW:";
    for my $i (0 .. $#{$query_spec->{columns}}){
      my $k = $query_spec->{columns}->[$i];
      my $v = $h->{$k};
      unless(defined $v) { $v = "" }
      $v =~ s/([\n\|])/"%" . unpack("H2", $1)/eg;
      print $v;
      unless($i == $#{$query_spec->{columns}}){ print "|" }
    }
    print "\n";
  }
  print "RESULT: query returned $num_rows lines\n";
} else {
  print "RESULT: query affected $q_result lines\n";
}
