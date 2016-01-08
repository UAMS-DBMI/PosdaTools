#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/LogPixOp.pl,v $
#$Date: 2011/11/15 19:33:45 $
#$Revision: 1.6 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Streamed Compressed Bitmap operations
#
# This program accepts (presumably) compressed bitmaps on multiple
# fds, performs bitwise logical operations on the streams, and
# outputs the results to another stream.
# The fd's have been opened by the parent process...
#
# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# The operands are a reverse polish specification of the operations
# to perform.
#
#
# Here are the possible parameters which make up the rp specification:
#  in[<n>]=<number of an input fd>
#  op=<AND,<n>|OR,<n>|NOT|XOR|MINUS>
#     AND,<n> means logical AND of <n> of args (aka intersection)
#     OR,<n> means logical OR of <n> of args (aka union)
#     XOR means logical XOR of two args (aka exclusive or)
#     NOT means logical negation of single arg (aka complement)
#     MINUS takes two args (a,b) and means "a intersect (not b)"
#
#  Any number of these operations are allowed, but the order is important, and
#  nothing can be "left on the stack" at the end of these operations. e.g.
#  The following specification:
#  "LogPixOp.pl in=1 in=2 in=3 op=XOR"
#  is illegal because it leaves the first operand (n=1) on the stack.
#
#  The following args follow the reverse polish spec and can appear in either
#  order:
#  out=<number of output fd>
#  status=<number of status fd> app will write status to this fd when finished
#
# Examples:
#  "LogPixOp.pl in=3 in=4 in=5 op=OR,3 in=6 in=7 op=OR,2 op=AND,2 out=8" means:
#     "Take the union of the bits streaming in on fds 3, 4, and 5, 
#      and intersect it with the union of the bits streaming in on
#      fds 6 and 7; write the results on fd 8"
#      (3 or 4 or 5) and (6 or 7)
#  "LogPixOp.pl in=3 in=4 op=OR,2 in=5 op=MINUS out=6" means:
#     "Take the union of 3 and 4 and exclude 5; write results on 6"
#     (3 or 4) minus 5
#
#  Warning:  Each fd can only be used once in an expression.  For example,
#  the following command is not allowed:
#
#LogPixOp.pl in=3 op=NOT in=4 op=AND,2 in=3 in=4 op=NOT op=AND,2 op=OR,2 out=5
#
#  If this were legal it would define "((not a) and b) or (a and (not b))"
#  but ITS NOT LEGAL (and will cause a crash).
#
use strict;
my @stack;
my %input_streams;
my $expression;
my $out;
my $status;
my $mode = "inPolish";
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if($key =~ /^in/) {
    unless($mode eq "inPolish"){
      die "$0: in encountered too late";
    }
    my $in = $value;
    if(exists $input_streams{$in}){
      die "$0: reusing stream $in";
    } else {
      open(my $fh, "<&", $value) or die "$0: can't open fd: $value";
      $input_streams{$in} = {
        op => "input_stream",
        fh => $fh,
        open => 1,
      };
    }
    push(@stack, $input_streams{$in});
  } elsif ($key eq "op") {
    my $op = $value;
    my $op_block;
    if($op =~ /(AND),(\d+)/ || $op =~ /(OR),(\d+)/){
      my $opr = $1;
      my $count = $2;
      $op_block = {
        op => $opr,
        operands => [],
      };
      for my $i (0 .. $count - 1){
        my $opr = pop @stack;
        push @{$op_block->{operands}}, $opr;
      }
    } elsif ($op eq "XOR" || $op eq "MINUS"){
      $op_block = {
        op => $op,
        a => pop @stack,
        b => pop @stack,
      };
    } elsif ($op eq "NOT"){
      $op_block = {
        op => $op,
        a => pop @stack,
      };
    } else { die "$0: unknown op $op" }
    push @stack, $op_block;
  } elsif ($key =~ /^out/ || $key eq "status") {
    if($mode eq "inPolish"){
      unless($#stack == 0){
        my $stk_sz = $#stack;
        die "$0: end of Polish with stacksize != 1 ($stk_sz)";
      }
      $expression = pop @stack;
    }
    $mode = "pastPolish";
    if($key =~ /out/){
      $out = $value;
    } else {
      $status = $value;
    }
  } else { die "$0: unknown parameter: $key" }
}
open(OUTPUT, ">&", $out) or die "$0: can't open out = $out ($!)";

my($c, $p, $strip_count);
$strip_count = 0; 
while(1){
  ($p, $c) = EvalCount($expression, $strip_count);
  $strip_count = $c;
  if($c == 0) { last }
  while($c > 0){
    my $count;
    if($c > 127){
      $count = 127;
      $c -=127;
    } else {
      $count = $c;
      $c = 0;
    }
    {
      no warnings;
      if($p){
        print OUTPUT pack("c", 0x80 + $count);
      } else {
        print OUTPUT pack("c",  $count);
      }
    }
  }
}
if(defined $status){
  open(STATUS, ">&=", $status) or die "$0: Can't open status = $status";
  print STATUS "OK\n";
  close STATUS;
}
#
# Evaluates the expression and returns the count of bits available for 
# an operation
#
# Returns (polarity, count1)
#   polarity is either 1 or 0
#   string is <count> of <polarity> bits
#
# Some things about the datastructure:
#   $e->{fh} is file_handle
#   $e->{open} is 1 if the file_handle is open
#   $e->{initialized} is 1 when the stream has been initialized
#   $e->{polarity} is polarity
#   $e->{count} is count of bits; should always be nonzero when stream
#      is initialized and not exhausted.
#   $e->{next_byte} is the next byte from input.  It has different polarity
#      from e->{polarity} (or it's count would have been incorporated into
#      e->{count} and would be zero)
#   $e->{next_byte} has a non-zero count
#
sub EvalCount{
  my($e, $n) = @_;
  unless(ref($e) eq "HASH") { die "$0: EvalCount called with non_hash" }
  unless(exists $e->{op}) { die "$0: EvalCount called with non op" }
  if($e->{op} eq "input_stream"){
    unless($e->{initialized}){ InitStream($e) }
    if($n > 0){
      unless(defined $e->{count}) { $e->{count} = 0 }
      if($n > $e->{count} && !defined $e->{next_byte}){
        for my $i (keys %$e){
          print STDERR "e->{$i} = $e->{$i}\n";
        }
        die "$0: removing more bits than we have ($n)";
      } elsif($n < $e->{count}){
          $e->{count} -= $n;
      } elsif($n == $e->{count}){
        if($e->{next_byte}){
          $e->{polarity} = ($e->{next_byte} & 0x80) >> 7;
          $e->{count} = $e->{next_byte} & 0x7f;
          $e->{next_byte} = 0;
          if($e->{open}) { ReadStream($e) }
        } else {
          $e->{count} = 0;
        }
      } else {
        while($n > $e->{count}){
          $n -= $e->{count};
          $e->{polarity} = ($e->{next_byte} & 0x80) >> 7;
          $e->{count} = $e->{next_byte} & 0x7f;
          $e->{next_byte} = 0;
          if($e->{open}) { ReadStream($e) }
        }
        $e->{count} -= $n;
        if($e->{count} == 0){
          if($e->{next_byte}){
            $e->{polarity} = ($e->{next_byte} & 0x80) >> 7;
            $e->{count} = $e->{next_byte} & 0x7f;
            $e->{next_byte} = 0;
            if($e->{open}) { ReadStream($e) }
          } else {
            $e->{count} = 0;
          }
        }
      }
    }
    return $e->{polarity}, $e->{count};
  } elsif($e->{op} eq "AND"){
    my $max_zeros = 0;
    my $min_ones = 9999999999;
    for my $i (@{$e->{operands}}){
      my($pol, $count) = EvalCount($i, $n);
      if($pol){
        if($count < $min_ones){ $min_ones = $count }
      } else {
        if($count > $max_zeros){ $max_zeros = $count }
      }
    }
    if($max_zeros) { return 0, $max_zeros }
    if($min_ones && $min_ones < 9999999999) { return 1, $min_ones }
    return 0, 0;
  } elsif($e->{op} eq "OR"){
    my $max_ones = 0;
    my $min_zeros = 9999999999;
    for my $i (0 .. $#{$e->{operands}}){
      my $ex = $e->{operands}->[$i];
      my($pol, $count) = EvalCount($ex, $n);
      if($pol){
        if($count > $max_ones){ $max_ones = $count }
      } else {
        if($count < $min_zeros){ $min_zeros = $count }
      }
    }
    if($max_ones) { return 1, $max_ones }
    if($min_zeros && $min_zeros < 9999999999) { return 0, $min_zeros }
    return 0, 0;
  } elsif($e->{op} eq "XOR"){
    my($p1, $c1) = EvalCount($e->{a}, $n);
    my($p2, $c2) = EvalCount($e->{b}, $n);
    my $c;
    if($c1 < $c2){
      $c = $c1;
    } else {
      $c = $c2;
    }
    return $p1 ^ $p2, $c;
  } elsif($e->{op} eq "MINUS"){
    my($p1, $c1) = EvalCount($e->{a}, $n);
    my($p2, $c2) = EvalCount($e->{b}, $n);
    my $c;
    if($c1 < $c2){
      $c = $c1;
    } else {
      $c = $c2;
    }
    return !$p1 && $p2, $c;
  } elsif($e->{op} eq "NOT"){
    my($p, $c) = EvalCount($e->{a}, $n);
    return !$p, $c;
  } else { die "$0: EvalCount called with unknown op: $e->{op}" }
}
sub InitStream{
  my($e) = @_;
  $e->{polarity} = 0;
  $e->{count} = 0;
  $e->{next_byte} = 0;
  $e->{initialized} = 1;
  ReadStream($e);
}
sub ReadStream{
  my($e) = @_;
  while($e->{open} && $e->{next_byte} == 0){
    my $buff;
    my $count = read($e->{fh}, $buff, 1);
    unless($count == 1){
      $e->{open} = 0;
      next;
    }
    my $byte_read;
    { no warnings; $byte_read = unpack("C", $buff); }
    my $pol = ($byte_read & 0x80) >> 7;
    if($e->{count} && $e->{polarity} != $pol){
      $e->{next_byte} = $byte_read;
      return;
    }
    $e->{count} += $byte_read &= 0x7f;
  }
}
