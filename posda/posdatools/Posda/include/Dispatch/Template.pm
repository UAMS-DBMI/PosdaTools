# $RCSfile: Template.pm,v $
package Dispatch::Template;
sub Dispatch {
  my($d, $name, $queue, $sess, $env) = @_;
  if(ref($d) eq "ARRAY"){
    for my $h (@$d){
      return Dispatch($h, $name, $queue, $sess, $env);
    }
  } elsif (ref($d) eq "HASH"){
    if(ref($d->{$name}) eq "CODE"){
      return(&{$d->{$name}}($d, $queue, $sess, $env));
    } else {
      unless(defined $d->{$name}){
        print STDERR "null dispatch $name\n";
      }
      ExpandText($queue, $d->{$name}, $d, $sess, $env);
      return 0;
    }
  } else {
    die "can't dispatch without hash or array";
  }
}
sub ExpandWord{
  my($word, $queue,  $Dispatch, $sess, $env) = @_;
  Dispatch($Dispatch, $word, $queue, $sess, $env);
}
sub ExpandCommand {
  my($command, $queue,  $Dispatch, $sess, $env) = @_;
  if(
    ($command =~ /^dynamic\s+name=(\w+)\s*$/) ||
    ($command =~ /^dynamic\s+name=\"([^\"]*)\"\s*$/)
  ){
    my $name = $1;
    return Dispatch($Dispatch, $name, $queue, $sess, $env);
  } elsif (
    ($command =~ /^dynamic\s+name=(\w+)\s+(.*)$/) ||
    ($command =~ /^dynamic\s+name=\"([^\"]*)\"\s+(.*)$/)
  ){
    my $name = $1;
    my $envstr = $2;
#    my $env = {};
    my $new_env = {};
    for my $i (keys %$env){
      $new_env->{$i} = $env->{$i};
    }
    env:
    while($envstr){
      if(
        ($envstr =~ /^(\w+)=(\w+)\s*$/) ||
        ($envstr =~ /^(\w+)=\"([^\"]*)\"\s*$/)
      ){
        my $key = $1;
        my $value = $2;
        $new_env->{$key} = $value;
        last env;
      } elsif (
        ($envstr =~ /^(\w+)=(\w+)\s+(.*)$/) ||
        ($envstr =~ /^(\w+)=\"([^\"]*)\"\s+(.*)$/)
      ){
        my $key = $1;
        my $value = $2;
        my $rem = $3;
        $new_env->{$key} = $value;
        $envstr = $rem;
        next env;
      }
      print STDERR "In Exp command, environment error: $envstr\n";
      last env;
    }
    return Dispatch($Dispatch, $name, $queue, $sess, $new_env);
  } elsif ($command =~ /^dynamic\s+inline=(.*)$/s){
    my $prog = $1;
    my $result = eval($prog);
    if($@){
      $queue->queue("error: $@ in expanding inline dynamic");
    }
    return 0;
  }
  $queue->queue("Error (there) in expanding command: \"$command\"\n");
}
sub ExpandText {
  my($queue, $text,  $Dispatch, $sess, $env) = @_;
  my $line;
  my $InSym = 0;
  my $remaining = $text;
  my $command;
  outer:
  while($remaining){
    unless($InSym){
      if($remaining =~ /^([^<]+)(\<.*)/s){
        my $seen = $1;
        $remaining = $2;
        $queue->queue($seen);
        redo outer;
      } elsif($remaining =~ /^(\<[^\?])(.*)/s){
        my $seen = $1;
        $remaining = $2;
        $queue->queue($seen);
        redo outer;
      } elsif($remaining =~ /^\<\?(.*)/s){
        $remaining = $1;
        $InSym = 1;
        redo outer;
      } else {
        $queue->queue($remaining);
        $remaining = "";
        next outer;
      }
    }
    if($remaining =~ /^(.*?)\?\>(.*)/s){
      my $first = $1;
      my $second = $2;
      $command .= $first;
      $remaining = $second;
      ExpandCommand($command,
        $queue,  $Dispatch, $sess, $env);
      $command = "";
      $InSym = 0;
      redo outer;
    } else {
      $command .= $remaining;
      $queue->queue("Error (here) in expanding command: \"$command\"\n");
      $remaining = "";
    }
  }
  return 1;
};
1;
