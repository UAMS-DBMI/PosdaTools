#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
use Posda::DB 'Query';
use Posda::QueryLog;
my $usage = <<EOF;
RunQueryInBackground.pl <?invoc_id?> <activity_id> <query_name> <notify>
or
RunQueryInBackground.pl -h

Expects input lines in following format:
<arg>

The number of args must match the number of args in the specified query
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 3) {
  print "Wrong number of args: $#ARGV vs 2\n";
  exit;
}
my($invoc_id, $activity_id, $query_name, $notify) = @ARGV;
my @Args;
while(my $line = <STDIN>){
  chomp $line;
  push @Args, $line;
}
my $num_args = @Args;
print "Going to background after reading $num_args args\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
#print STDERR "***************\nQuery_name: $query_name\n";
my $Query = PosdaDB::Queries->GetQueryInstance($query_name);
#print STDERR "****\n";
my $qh = Query($query_name);
#print STDERR "****\n";
$back->WriteToEmail("subprocess_invocation_id: $invoc_id\nquery_name: $query_name\nnotify:$notify\nArgs:\n");
for my $a(@Args){
  $back->WriteToEmail("\t$a\n");
}
my $QueryInvokedId = Posda::QueryLog::query_invoked($Query, $notify);
my $start = time;
my @Rows;
$qh->RunQuery(sub {
  my($row) = @_;
  push @Rows, $row;
},sub{
}, @Args);
my $end = time;
my $elapsed = $end - $start;
Posda::QueryLog::query_finished($QueryInvokedId, $#Rows + 1);
my $num_rows = @Rows;
$back->WriteToEmail("Query $query_name returned $num_rows in $elapsed seconds\n");
my $pipe = $back->CreateReport("Query Results");
my $when = `date`;
$pipe->print("Background Query\n");
$pipe->print("query_name:,$query_name\n");
$pipe->print("run_by:,$notify\n");
$pipe->print("seconds:,$elapsed\n");
$pipe->print("when:,$when\n");
$pipe->print("\nargs:\n");
for my $i (0 .. $#{$Query->{args}}){
  $pipe->print("$Query->{args}->[$i],$Args[$i]\n");
}
$pipe->print("\nRows:\n");
for my $i (0 .. $#{$Query->{columns}}){
  $pipe->print($Query->{columns}->[$i]);
  unless($i == $#{$Query->{columns}}){ $pipe->print(",")}
}
$pipe->print("\n");
for my $row (@Rows){
  for my $col (0 .. $#{$row}){
    my $val = $row->[$col];
    $val =~ s/""/"/g;
    $pipe->print("\"$val\"");
    unless($col == $#{$row}) {$pipe->print(",")};
  }
  $pipe->print("\n");
}
$back->Finish;
