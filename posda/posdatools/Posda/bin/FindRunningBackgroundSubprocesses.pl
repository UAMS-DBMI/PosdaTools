#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';

my @Rows;
Query("PossiblyRunningBackgroundSubprocesses")->RunQuery( sub {
  my($row) = @_;
  my($subprocess_invocation_id, $background_subprocess_id,
    $when_script_started,
    $when_background_entered, $command_line, $time_in_background,
    $background_pid) = @$row;
  push @Rows, $row;
}, sub {});
print "invoc_id,bkgrnd_id,command,started,running_for\n";
for my $row (@Rows){
  my($subprocess_invocation_id, $background_subprocess_id,
    $when_script_started,
    $when_background_entered, $command_line, $time_in_background,
    $background_pid) = @$row;
#print "Background pid: $background_pid\n";
  open SUB, "ps -fu posda|awk '(\$2 == \"$background_pid\")'|";
  my $found_cmd = 0;
  while (my $line = <SUB>){
    chomp $line;
#print "line: $line\n";
    my $command;
#print "command_line: $command_line\n";
    $command_line =~ /^(.*)\./;
    $command = $1;
#print "Command: $command\n";
    if($line =~ /$command/){
      $command_line =~ s/"/""/g;
      print("$subprocess_invocation_id,$background_subprocess_id," .
        "\"$command_line\",\"$when_script_started\",\"$time_in_background\"\n");
      $found_cmd = 1;
    }
  }
  unless($found_cmd) {
    print "$subprocess_invocation_id|$background_subprocess_id|" .
      "$time_in_background|Stale\n";
  }
}
