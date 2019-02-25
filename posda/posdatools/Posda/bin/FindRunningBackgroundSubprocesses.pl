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
print "invoc_id,bkgrnd_id,pid,command,started,running_for\n";
my($cmd_line, $wsS);
for my $row (@Rows){
#print STDERR "+++++++++++++++++++++++\n";
  my($subprocess_invocation_id, $background_subprocess_id,
    $when_script_started,
    $when_background_entered, $command_line, $time_in_background,
    $background_pid) = @$row;
#print STDERR "Background pid: $background_pid\n";
  open SUB, "ps -fu posda|awk '(\$2 == \"$background_pid\")'|";
  my $found_cmd = 0;
  while (my $line = <SUB>){
    chomp $line;
#print STDERR "line: $line\n";
    my $command;
#print STDERR "command_line: \"$command_line\"\n";
    $command_line =~ /^([^\.]*)\./;
    $command = $1;
#print STDERR "Command: $command\n";
    if($line =~ /$command/){
      $command_line =~ s/"/""/g;
      print("$subprocess_invocation_id,$background_subprocess_id," .
        "\"$background_pid\"," .
        "\"$command_line\",\"$when_script_started\",\"$time_in_background\"\n");
      $found_cmd = 1;
    } else {
#print STDERR "Command not found\n";
    }
  }
  unless($found_cmd) {
    print "$subprocess_invocation_id|$background_subprocess_id|" .
      "\"$background_pid\"," . 
      "$command_line|$when_script_started|Stale\n";
  }
}
