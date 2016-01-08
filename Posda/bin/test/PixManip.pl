#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/PixManip.pl,v $
#$Date: 2011/09/17 19:12:47 $
#$Revision: 1.3 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Streamed Pixel operations
# This program accepts (presumably) pixel data on one or two
# fd's, manipulates the data and writes it to another fd
# The fd's have been opened by the parent process...
# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in1=<number of first input fd>
#  in2=<number of second input fd> (only for op = AND, OR, ADD, SUB, CMP
#                                   AVG, MINP, or MAXP
#  out=<number of output fd>
#  status=<number of status fd> app will write status to this fd when finished
#  num=<number of pixel units>
#  depth=<number of bytes in a pixel unit> (1, 2 or 4)
#  op=<AND|OR|NOT|CMP|ADD|SUB|AVG|SCALE|MINP|MAXP|MASK>
#  factor=<scale factor> (only for op = scale)
#  level=<level> (only for op = mask)
#
use strict;
my($in1, $in2, $out, $status, $num, $depth, $op, $factor, $signed, $level);
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if($key eq "in1") { $in1 = $value }
  elsif ($key eq "in2") { $in2 = $value }
  elsif ($key eq "out") { $out = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "num") { $num = $value }
  elsif ($key eq "depth") { $depth = $value }
  elsif ($key eq "op") { $op = $value }
  elsif ($key eq "factor") { $factor = $value }
  elsif ($key eq "signed") { $signed = $value }
  elsif ($key eq "level") { $level = $value }
  else { die "$0: unknown parameter: $key" }
}
if(defined $depth){
  unless(($depth == 1) || ($depth == 2) || ($depth == 4)) {
    die "$0: invalid depth $depth";
  }
}
unless(defined $op) { die "$0: no operation in params" }
if($op eq "AND"){
  unless(
    defined($in1) && defined($in2) && defined($out) && defined($num) &&
    defined($depth) && !defined($factor) && !defined($level)
  ){ die "wrong args for AND" }
  open(INPUT1, "<&=", $in1) or die "$0: Can't open in1 = $in1";
  open(INPUT2, "<&=", $in2) or die "$0: Can't open in2 = $in2";
  open(OUTPUT, ">&=", $out) or die "$0: Can't open out = $out";
  my $num_processed = 0;
  while($num_processed < $num){
    my($a1, $a2, $n1, $n2, $out);
    my $len1 = sysread(INPUT1, $a1, $depth);
    my $len2 = sysread(INPUT2, $a2, $depth);
    if(($len1 != $depth) || ($len2 != $depth)){ die "$0: error reading inputs" }
    if($depth == 1){
      $n1 = unpack("c", $a1);
      $n2 = unpack("c", $a2);
      $out = pack("c", $n1 & $n2);
    } elsif ($depth == 2){
      $n1 = unpack("s", $a1);
      $n2 = unpack("s", $a2);
      $out = pack("s", $n1 & $n2);
    } elsif ($depth == 4){
      $n1 = unpack("l", $a1);
      $n2 = unpack("l", $a2);
      $out = pack("l", $n1 & $n2);
    }
    print OUTPUT $out;
    $num_processed += $depth;
  }
  close INPUT1;
  close INPUT2;
  close OUTPUT;
} elsif($op eq "OR"){
  unless(
    defined($in1) && defined($in2) && defined($out) && defined($num) &&
    defined($depth) && !defined($factor) && !defined($level)
  ){ die "wrong args for OR" }
  open(INPUT1, "<&=", $in1) or die "$0: Can't open in1 = $in1";
  open(INPUT2, "<&=", $in2) or die "$0: Can't open in2 = $in2";
  open(OUTPUT, ">&=", $out) or die "$0: Can't open out = $out";
  my $num_processed = 0;
  while($num_processed < $num){
    my($a1, $a2, $n1, $n2, $out);
    my $len1 = sysread(INPUT1, $a1, $depth);
    my $len2 = sysread(INPUT2, $a2, $depth);
    if(($len1 != $depth) || ($len2 != $depth)){ die "$0: error reading inputs" }
    if($depth == 1){
      ($n1) = unpack("c", $a1);
      ($n2) = unpack("c", $a2);
      $out = pack("c", $n1 | $n2);
    } elsif ($depth == 2){
      ($n1) = unpack("s", $a1);
      ($n2) = unpack("s", $a2);
      $out = pack("s", $n1 | $n2);
    } elsif ($depth == 4){
      ($n1) = unpack("l", $a1);
      ($n2) = unpack("l", $a2);
      $out = pack("l", $n1 | $n2);
    }
    print OUTPUT $out;
    $num_processed += $depth;
  }
  close INPUT1;
  close INPUT2;
  close OUTPUT;
} elsif($op eq "CMP"){
  unless(
    defined($in1) && defined($in2) && defined($out) && defined($num) &&
    defined($depth) && !defined($factor) && !defined($level)
  ){ die "wrong args for OR" }
  open(INPUT1, "<&=", $in1) or die "$0: Can't open in1 = $in1";
  open(INPUT2, "<&=", $in2) or die "$0: Can't open in2 = $in2";
  open(OUTPUT, ">&=", $out) or die "$0: Can't open out = $out";
  my $num_processed = 0;
  while($num_processed < $num){
    my($a1, $a2, $n1, $n2, $out);
    my $len1 = sysread(INPUT1, $a1, $depth);
    my $len2 = sysread(INPUT2, $a2, $depth);
    if(($len1 != $depth) || ($len2 != $depth)){ die "$0: error reading inputs" }
    if($depth == 1){
      ($n1) = unpack("c", $a1);
      ($n2) = unpack("c", $a2);
      $out = pack("c", $n1 & (~$n2));
    } elsif ($depth == 2){
      ($n1) = unpack("s", $a1);
      ($n2) = unpack("s", $a2);
      $out = pack("s", $n1 & (~$n2));
    } elsif ($depth == 4){
      ($n1) = unpack("l", $a1);
      ($n2) = unpack("l", $a2);
      $out = pack("l", $n1 & (~$n2));
    }
    print OUTPUT $out;
    $num_processed += $depth;
  }
  close INPUT1;
  close INPUT2;
  close OUTPUT;
} elsif($op eq "NOT"){
  unless(
    defined($in1) && !defined($in2) && defined($out) && defined($num) &&
    defined($depth) && !defined($factor) && !defined($level)
  ){ die "$0: wrong args for NOT" }
  open(INPUT1, "<&=", $in1) or die "$0: Can't open in1 = $in1";
  open(OUTPUT, ">&=", $out) or die "$0: Can't open out = $out";
  my $num_processed = 0;
  while($num_processed < $num){
    my($a1, $n1, $out);
    my $len1 = sysread(INPUT1, $a1, $depth);
    if(($len1 != $depth)){ die "$0: error reading inputs" }
    if($depth == 1){
      ($n1) = unpack("c", $a1);
      $out = pack("c", $n1 ^ 0xFF);
    } elsif ($depth == 2){
      ($n1) = unpack("s", $a1);
      $out = pack("s", $n1 ^ 0xFFFF);
    } elsif ($depth == 4){
      ($n1) = unpack("l", $a1);
      $out = pack("l", $n1 ^ 0xFFFFFFFF);
    }
    print OUTPUT $out;
    $num_processed += $depth;
  }
  close INPUT1;
  close OUTPUT;
} elsif($op eq "AVG"){
  unless(
    defined($in1) && defined($in2) && defined($out) && defined($num) &&
    defined($depth) && !defined($factor) && defined($signed) && !defined($level)
  ){ die "$0: wrong args for AVG" }
  open(INPUT1, "<&=", $in1) or die "$0: Can't open in1 = $in1";
  open(INPUT2, "<&=", $in2) or die "$0: Can't open in1 = $in2";
  open(OUTPUT, ">&=", $out) or die "$0: Can't open out = $out";
  my $num_processed = 0;
  while($num_processed < $num){
    my($a1, $a2, $n1, $n2, $out);
    my $len1 = sysread(INPUT1, $a1, $depth);
    my $len2 = sysread(INPUT2, $a2, $depth);
    if(($len1 != $depth) || ($len2 != $depth)){ die "$0: error reading inputs" }
    if($depth == 1){
      if($signed){
        ($n1) = unpack("c", $a1);
        ($n2) = unpack("c", $a1);
        $out = pack("c", ($n1 + $n2) / 2);
      } else {
        ($n1) = unpack("C", $a1);
        ($n2) = unpack("C", $a1);
        $out = pack("C", ($n1 + $n2) / 2);
      }
    } elsif ($depth == 2){
      if($signed){
        ($n1) = unpack("s", $a1);
        ($n2) = unpack("s", $a1);
        $out = pack("s", ($n1 + $n2) / 2);
      } else {
        ($n1) = unpack("S", $a1);
        ($n2) = unpack("S", $a1);
        $out = pack("S", ($n1 + $n2) / 2);
      }
    } elsif ($depth == 4){
      if($signed){
        ($n1) = unpack("l", $a1);
        ($n2) = unpack("l", $a1);
        $out = pack("l", ($n1 + $n2) / 2);
      } else {
        ($n1) = unpack("L", $a1);
        ($n2) = unpack("L", $a1);
        $out = pack("L", ($n1 + $n2) / 2);
      }
    }
    print OUTPUT $out;
    $num_processed += $depth;
  }
  close INPUT1;
  close INPUT2;
  close OUTPUT;
} elsif($op eq "ADD"){
  unless(
    defined($in1) && defined($in2) && defined($out) && defined($num) &&
    defined($depth) && !defined($factor) && defined($signed) && !defined($level)
  ){ die "$0: wrong args for ADD" }
  open(INPUT1, "<&=", $in1) or die "$0: Can't open in1 = $in1";
  open(INPUT2, "<&=", $in2) or die "$0: Can't open in2 = $in2";
  open(OUTPUT, ">&=", $out) or die "$0: Can't open out = $out";
  my $num_processed = 0;
  while($num_processed < $num){
    my($a1, $a2, $n1, $n2, $out);
    my $len1 = sysread(INPUT1, $a1, $depth);
    my $len2 = sysread(INPUT2, $a2, $depth);
    if(($len1 != $depth) || ($len2 != $depth)){ die "$0: error reading inputs" }
    if($depth == 1){
      if($signed){
        ($n1) = unpack("c", $a1);
        ($n2) = unpack("c", $a1);
        $out = pack("c", $n1 + $n2);
      } else {
        ($n1) = unpack("C", $a1);
        ($n2) = unpack("C", $a1);
        $out = pack("C", $n1 + $n2);
      }
    } elsif ($depth == 2){
      if($signed){
        ($n1) = unpack("s", $a1);
        ($n2) = unpack("s", $a1);
        $out = pack("s", $n1 + $n2);
      } else {
        ($n1) = unpack("S", $a1);
        ($n2) = unpack("S", $a1);
        $out = pack("S", $n1 + $n2);
      }
    } elsif ($depth == 4){
      if($signed){
        ($n1) = unpack("l", $a1);
        ($n2) = unpack("l", $a1);
        $out = pack("l", $n1 + $n2);
      } else {
        ($n1) = unpack("L", $a1);
        ($n2) = unpack("L", $a1);
        $out = pack("L", $n1 + $n2);
      }
    }
    print OUTPUT $out;
    $num_processed += $depth;
  }
  close INPUT1;
  close INPUT2;
  close OUTPUT;
} elsif($op eq "SUB"){
  unless(
    defined($in1) && defined($in2) && defined($out) && defined($num) &&
    defined($depth) && !defined($factor) && defined($signed) && !defined($level)
  ){ die "$0: wrong args for SUB" }
  open(INPUT1, "<&=", $in1) or die "$0: Can't open in1 = $in1";
  open(INPUT2, "<&=", $in2) or die "$0: Can't open in2 = $in2";
  open(OUTPUT, ">&=", $out) or die "$0: Can't open out = $out";
  my $num_processed = 0;
  while($num_processed < $num){
    my($a1, $a2, $n1, $n2, $out);
    my $len1 = sysread(INPUT1, $a1, $depth);
    my $len2 = sysread(INPUT2, $a2, $depth);
    if(($len1 != $depth) || ($len2 != $depth)){ die "$0: error reading inputs" }
    if($depth == 1){
      if($signed){
        ($n1) = unpack("c", $a1);
        ($n2) = unpack("c", $a2);
        $out = pack("c", $n1 - $n2);
      } else {
        ($n1) = unpack("C", $a1);
        ($n2) = unpack("C", $a2);
        $out = pack("C", $n1 - $n2);
      }
    } elsif ($depth == 2){
      if($signed){
        ($n1) = unpack("s", $a1);
        ($n2) = unpack("s", $a2);
        $out = pack("s", $n1 - $n2);
      } else {
        ($n1) = unpack("S", $a1);
        ($n2) = unpack("S", $a2);
        $out = pack("S", $n1 - $n2);
      }
    } elsif ($depth == 4){
      if($signed){
        ($n1) = unpack("l", $a1);
        ($n2) = unpack("l", $a2);
        $out = pack("l", $n1 - $n2);
      } else {
        ($n1) = unpack("L", $a1);
        ($n2) = unpack("L", $a2);
        $out = pack("L", $n1 - $n2);
      }
    }
    print OUTPUT $out;
    $num_processed += $depth;
  }
  close INPUT1;
  close INPUT2;
  close OUTPUT;
} elsif($op eq "SCALE"){
  unless(
    defined($in1) && !defined($in2) && defined($out) && defined($num) &&
    defined($depth) && defined($factor) && defined($signed) && !defined($level)
  ){ die "$0: wrong args for SCALE" }
  open(INPUT1, "<&=", $in1) or die "$0: Can't open in1 = $in1";
  open(OUTPUT, ">&=", $out) or die "$0: Can't open out = $out";
  my $num_processed = 0;
  while($num_processed < $num){
    my($a1, $a2, $n1, $n2, $out);
    my $len1 = sysread(INPUT1, $a1, $depth);
    my $len2 = sysread(INPUT2, $a2, $depth);
    if(($len1 != $depth) || ($len2 != $depth)){ die "$0: error reading inputs" }
    if($depth == 1){
      ($n1) = unpack("c", $a1);
      $out = pack("c", $n1 * $factor);
    } elsif ($depth == 2){
      ($n1) = unpack("s", $a1);
      $out = pack("s", $n1 * $factor);
    } elsif ($depth == 4){
      ($n1) = unpack("l", $a1);
      $out = pack("l", $n1 * $factor);
    }
    print OUTPUT $out;
    $num_processed += $depth;
  }
  close INPUT1;
  close OUTPUT;
} elsif($op eq "MINP"){
  unless(
    defined($in1) && defined($in2) && defined($out) && defined($num) &&
    defined($depth) && !defined($factor) && defined($signed) && !defined($level)
  ){ die "$0: wrong args for MINP" }
  open(INPUT1, "<&=", $in1) or die "$0: Can't open in1 = $in1";
  open(INPUT2, "<&=", $in2) or die "$0: Can't open in2 = $in2";
  open(OUTPUT, ">&=", $out) or die "$0: Can't open out = $out";
  my $num_processed = 0;
  while($num_processed < $num){
    my($a1, $a2, $n1, $n2, $out);
    my $len1 = sysread(INPUT1, $a1, $depth);
    my $len2 = sysread(INPUT2, $a2, $depth);
    if(($len1 != $depth) || ($len2 != $depth)){ die "$0: error reading inputs" }
    if($depth == 1){
      if($signed){
        ($n1) = unpack("c", $a1);
        ($n2) = unpack("c", $a1);
        $out = pack("c", (($n1 > $n2) ? $n2 : $n1));
      } else {
        ($n1) = unpack("C", $a1);
        ($n2) = unpack("C", $a1);
        $out = pack("c", (($n1 > $n2) ? $n2 : $n1));
      }
    } elsif ($depth == 2){
      if($signed){
        ($n1) = unpack("s", $a1);
        ($n2) = unpack("s", $a1);
        $out = pack("c", (($n1 > $n2) ? $n2 : $n1));
      } else {
        ($n1) = unpack("S", $a1);
        ($n2) = unpack("S", $a1);
        $out = pack("c", (($n1 > $n2) ? $n2 : $n1));
      }
    } elsif ($depth == 4){
      if($signed){
        ($n1) = unpack("l", $a1);
        ($n2) = unpack("l", $a1);
        $out = pack("c", (($n1 > $n2) ? $n2 : $n1));
      } else {
        ($n1) = unpack("L", $a1);
        ($n2) = unpack("L", $a1);
        $out = pack("c", (($n1 > $n2) ? $n2 : $n1));
      }
    }
    print OUTPUT $out;
    $num_processed += $depth;
  }
  close INPUT1;
  close INPUT2;
  close OUTPUT;
} elsif($op eq "MAXP"){
  unless(
    defined($in1) && defined($in2) && defined($out) && defined($num) &&
    defined($depth) && !defined($factor) && defined($signed) && !defined($level)
  ){ die "$0: wrong args for MAXP" }
  open(INPUT1, "<&=", $in1) or die "$0: Can't open in1 = $in1";
  open(INPUT2, "<&=", $in2) or die "$0: Can't open in2 = $in2";
  open(OUTPUT, ">&=", $out) or die "$0: Can't open out = $out";
  my $num_processed = 0;
  while($num_processed < $num){
    my($a1, $a2, $n1, $n2, $out);
    my $len1 = sysread(INPUT1, $a1, $depth);
    my $len2 = sysread(INPUT2, $a2, $depth);
    if(($len1 != $depth) || ($len2 != $depth)){ die "$0: error reading inputs" }
    if($depth == 1){
      if($signed){
        ($n1) = unpack("c", $a1);
        ($n2) = unpack("c", $a1);
        $out = pack("c", (($n1 > $n2) ? $n1 : $n2));
      } else {
        ($n1) = unpack("C", $a1);
        ($n2) = unpack("C", $a1);
        $out = pack("c", (($n1 > $n2) ? $n1 : $n2));
      }
    } elsif ($depth == 2){
      if($signed){
        ($n1) = unpack("s", $a1);
        ($n2) = unpack("s", $a1);
        $out = pack("c", (($n1 > $n2) ? $n1 : $n2));
      } else {
        ($n1) = unpack("S", $a1);
        ($n2) = unpack("S", $a1);
        $out = pack("c", (($n1 > $n2) ? $n1 : $n2));
      }
    } elsif ($depth == 4){
      if($signed){
        ($n1) = unpack("l", $a1);
        ($n2) = unpack("l", $a1);
        $out = pack("c", (($n1 > $n2) ? $n1 : $n2));
      } else {
        ($n1) = unpack("L", $a1);
        ($n2) = unpack("L", $a1);
        $out = pack("c", (($n1 > $n2) ? $n1 : $n2));
      }
    }
    print OUTPUT $out;
    $num_processed += $depth;
  }
  close INPUT1;
  close INPUT2;
  close OUTPUT;
} elsif($op eq "MASK"){
  unless(
    defined($in1) && !defined($in2) && defined($out) && defined($num) &&
    defined($depth) && !defined($factor) && defined($signed) && defined($level)
  ){ die "$0: wrong args for MASK" }
  open(INPUT1, "<&=", $in1) or die "$0: Can't open in1 = $in1";
  open(OUTPUT, ">&=", $out) or die "$0: Can't open out = $out";
  my $num_processed = 0;
  my $bits = [];
  while($num_processed < $num){
    my($a1, $n1);
    my $len1 = sysread(INPUT1, $a1, $depth);
    if(($len1 != $depth)){ die "$0: error reading inputs" }
    if($depth == 1){
      if($signed){
        ($n1) = unpack("c", $a1);
        push(@$bits, (($n1 > $level) ? 1 : 0));
      } else {
        ($n1) = unpack("C", $a1);
        push(@$bits, (($n1 > $level) ? 1 : 0));
      }
    } elsif ($depth == 2){
      if($signed){
        ($n1) = unpack("s", $a1);
        push(@$bits, (($n1 > $level) ? 1 : 0));
      } else {
        ($n1) = unpack("S", $a1);
        push(@$bits, (($n1 > $level) ? 1 : 0));
      }
    } elsif ($depth == 4){
      if($signed){
        ($n1) = unpack("l", $a1);
        push(@$bits, (($n1 > $level) ? 1 : 0));
      } else {
        ($n1) = unpack("L", $a1);
        push(@$bits, (($n1 > $level) ? 1 : 0));
      }
    }
    if($#{$bits} == 7){
      my $out = pack "8b", @$bits;
      $bits = [];
      print OUTPUT $out;
    }
    $num_processed += $depth;
  }
  if($#{$bits} >= 0){
    while($#{$bits} < 7){
      push(@{$bits}, 0);
      $bits = [];
      my $out = pack "8b", @$bits;
      print OUTPUT $out;
    }
  }
  close INPUT1;
  close INPUT2;
  close OUTPUT;
} else { die "$0: unimplemented op: $op" }
if(defined $status){
  open(STATUS, ">&=", $status) or die "$0: Can't open status = $status";
  print STATUS "OK\n";
  close STATUS;
}
