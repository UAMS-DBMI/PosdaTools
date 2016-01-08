#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/PipeChildren.pm,v $
#$Date: 2013/07/15 20:17:20 $
#$Revision: 1.9 $
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package PipeChildren;
use Socket;
use Fcntl;

sub Spawn{
  my($cmd, $fd_map, $other_args) = @_;
  my $child = fork();
  unless(defined($child)) { die "can't fork" }
  if($child != 0) {
    for my $i (keys %{$fd_map}){
      unless(defined $fd_map->{$i}) {
        die "PipeChildren::Spawn($cmd, ...): $i is undefined in fd_map";
      }
      close($fd_map->{$i});
    }
    return $child;
  }
  # In the child
  my @args;
  for my $name (keys %{$fd_map}){
    unless(
      ($name =~ /^in\d*$/) || ($name =~ /^out\d*$/) ||
      $name eq "status"
    ){ die "bad fd name: $name" }
    unless(defined $fd_map->{$name}) {
      die "0: PipeChildren::Spawn($cmd, ...): $name is undefined in fd_map";
    }
    my $fileno = fileno($fd_map->{$name});
    unless(defined $fileno) { die "fd name: $name has no file_no" }
    push(@args, "$name=$fileno");
    my $flags = fcntl($fd_map->{$name}, F_GETFD, 0)
      or die "Can't get flags for fd($name, $fileno): $!";
    $flags &= ~FD_CLOEXEC();
    $flags = fcntl($fd_map->{$name}, F_SETFD, $flags)
      or die "Can't set flags for fd($name, $fileno): $!";
  }
  for my $i (keys %{$other_args}){
    if(defined $other_args->{$i}){
      push(@args, "$i=$other_args->{$i}");
    } else {
      print STDERR "arg $i undefined in PipeChildren\n";
      ########### Additional Debug
      my $t = 1;
      my $traceback = "";
      while(caller($t)){
        my @foo = caller($t);
        $t++;
        my $file = $foo[1];
        my $line = $foo[2];
        $traceback .= "\n\tline $line of $file";
      }
      print STDERR "\n$traceback\n";
      ###########
    }
  }
#my $cmd_text = "$cmd";
#for my $i (@args) { $cmd_text .= " \"$i\"" }
#print "Command: $cmd_text\n";
  exec $cmd, @args;
  die "exec failed";
}
sub SpawnOrderedInputs{
  my($cmd, $input_args, $output, $status, $args) = @_;
  my $child = fork();
  unless(defined $child) { die "can't fork" }
  if($child != 0){
    for my $i (@$input_args){
      if($i->{key} =~  /^in/) { close $i->{value} }
    }
    close $output;
    return $child;
  }
  # In the child
  my @args;
  for my $i (@$input_args){
    if($i->{key} =~/^in/){
      my $fileno = fileno($i->{value});
      unless(defined $fileno) { die "$i->{key} has no file_no" }
      my $flags = fcntl($i->{value}, F_GETFD, 0)
        or die "Can't get flags for fd($i->{key}, $fileno): $!";
      $flags &= ~FD_CLOEXEC();
      $flags = fcntl($i->{value}, F_SETFD, $flags)
      or die "Can't set flags for fd($i->{key}, $fileno): $!";
      push(@args, "$i->{key}=$fileno");
    } else {
      push(@args, "$i->{key}=$i->{value}");
    }
  }
  my $fileno = fileno($output);
  unless(defined $fileno) { die "output has no file_no" }
  push(@args, "out=$fileno");
  my $flags = fcntl($output, F_GETFD, 0)
    or die "Can't get flags for fd(output, $fileno): $!";
  $flags &= ~FD_CLOEXEC();
  $flags = fcntl($output, F_SETFD, $flags)
    or die "Can't set flags for fd(output, $fileno): $!";
  $fileno = fileno($status);
  unless(defined $fileno) { die "status has no file_no" }
  push(@args, "status=$fileno");
  $flags = fcntl($status, F_GETFD, 0)
    or die "Can't get flags for fd(status, $fileno): $!";
  $flags &= ~FD_CLOEXEC();
  $flags = fcntl($status, F_SETFD, $flags)
    or die "Can't set flags for fd(status, $fileno): $!";
  for my $i (keys %$args){
    push(@args, "$i=$args->{$i}");
  }
  exec $cmd, @args;
  die "exec failed";
}
sub SpawnSockWithParms{
  my($cmd, $sock_args, $status, $args) = @_;
  my $child = fork();
  unless(defined $child) { die "can't fork" }
  if($child != 0){
    for my $i (@$sock_args){
      if($i->{key} =~  /^in/) { close $i->{fh} }
      if($i->{key} =~  /^out/) { close $i->{fh} }
    }
    close $status;
    return $child;
  }
  # In the child
  my @args;
  for my $i (@$sock_args){
    if($i->{key} =~/^in/ || $i->{key} =~ /^out/){
      my $fileno = fileno($i->{fh});
      unless(defined $fileno) { die "$i->{key} has no file_no" }
      my $flags = fcntl($i->{fh}, F_GETFD, 0)
        or die "Can't get flags for fd($i->{key}, $fileno): $!";
      $flags &= ~FD_CLOEXEC();
      $flags = fcntl($i->{fh}, F_SETFD, $flags)
      or die "Can't set flags for fd($i->{key}, $fileno): $!";
      my $value = "$i->{key}=$fileno";
      for my $arg (@{$i->{args}}){
        $value .= ",$arg";
      }
      push(@args, $value);
    }
  }
  my $fileno = fileno($status);
  unless(defined $fileno) { die "status has no file_no" }
  push(@args, "status=$fileno");
  my $flags = fcntl($status, F_GETFD, 0)
    or die "Can't get flags for fd(status, $fileno): $!";
  $flags &= ~FD_CLOEXEC();
  $flags = fcntl($status, F_SETFD, $flags)
    or die "Can't set flags for fd(status, $fileno): $!";
  for my $i (keys %$args){
    push(@args, "$i=$args->{$i}");
  }
#my $cmd_text = "$cmd";
#for my $i (@args) { $cmd_text .= " \"$i\"" }
#print "Command: $cmd_text\n";
  exec $cmd, @args;
  die "exec failed";
}
sub GetSocketPair{
  my($to_c, $from_p) = @_;
  socketpair $to_c, $from_p, AF_UNIX, SOCK_STREAM, PF_UNSPEC;
  shutdown $to_c, 0;   # write only
  shutdown $from_p, 1; # read only
  my $from_fn = fileno($from_p);
  my $to_fn = fileno($to_c);
  unless(defined($to_c) && defined($from_p) && defined($from_fn)){
    die "unable to create socket pair";
  }
  return {
    to => $to_c,
    from => $from_p,
    from_no => $from_fn,
    to_no => $to_fn,
  };
}
1;
