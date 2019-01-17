#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';

my @Rows;
Query("PossiblyRunningSubprocesses")->RunQuery( sub {
  my($row) = @_;
  my($subprocess_invocation_id, $command_line,
    $invoking_user, $when_invoked,
    $duration) = @$row;
  push @Rows, $row;
}, sub {});
print "invoc_id,command,started,running_for\n";
for my $row (@Rows){
  my($subprocess_invocation_id, $command_line,
    $invoking_user, $when_invoked,
    $duration) = @$row;
    my $command;
    $command_line =~ /^(.*)\./;
    $command = $1;
  open SUB, "ps -fu posda|grep '$command'|";
  my $found_cmd = 0;
  while (my $line = <SUB>){
#print "line: $line\n";
    $command_line =~ s/"/""/g;
    print("$subprocess_invocation_id," .
      "\"$command_line\",$when_invoked,\"$duration\"\n");
    $found_cmd = 1;
  }
  unless($found_cmd) {
    print "$subprocess_invocation_id|" .
      "$duration|Stale\n";
  }
}
