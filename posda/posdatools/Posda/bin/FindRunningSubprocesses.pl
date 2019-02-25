#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';

my $mypid = $$;
my @Rows;
Query("PossiblyRunningSubprocesses")->RunQuery( sub {
  my($row) = @_;
  my($subprocess_invocation_id, $command_line,
    $invoking_user, $when_invoked,
    $duration) = @$row;
  push @Rows, $row;
}, sub {});
print "invoc_id,pid,command,started,running_for\n";
for my $row (@Rows){
  my($subprocess_invocation_id, $command_line,
    $invoking_user, $when_invoked,
    $duration) = @$row;
    my $command;
    $command_line =~ /^([^\.].*)\./;
    $command = $1;
  open SUB, "ps -fu posda|grep '$command'|";
  my $found_cmd = 0;
  line:
  while (my $line = <SUB>){
    chomp $line;
    my($user, $pid, $ppid, $one, $two, $three, $time, $command) =
      split(/\s+/, $line, 8);
    if($ppid == $mypid) {
      #print "Reject my child: $command\n";
      next line;
    }
    unless($command =~ /$subprocess_invocation_id/){
      #print "Reject no id: $command\n";
      next line;
    }
    $command =~ s/"/""/g;
    print("$subprocess_invocation_id,$pid," .
      "\"$command\",$when_invoked,\"$duration\"\n");
    $found_cmd = 1;
  }
  unless($found_cmd) {
    $command_line =~ s/"/""/g;
    print "$subprocess_invocation_id,<undef>,\"$command_line\"," .
      "$when_invoked|Stale\n";
  }
}
