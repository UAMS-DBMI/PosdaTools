#!/usr/bin/perl -w

# Take a bitmap on STDIN and turn it into a PBM on STDOUT
# This program accepts (presumably) pixel data on STDIN
# It produces a "PBM" format stream STDOUT
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  rows=<number of rows>
#  cols=<number of cols>
#
use strict;

my $usage = <<EOF;
usage:
MakeTestPbm.pl <rows> <cols> [<pattern>]
EOF

{
  package BitEmitter;
  sub open {
    my($class) = @_;
    my $this = {
      mask => 0x80,
      byte => 0,
      count => 8,
    };
    return bless $this, $class;
  }
  sub close{
    my($this) = @_;
    if($this->{mask} != 0x8){
      die sprintf("incomplete byte (mask = %2x, byte = %2x)",
        $this->{mask}, $this->{byte});
    }
  }
  sub emit{
    my($this, $bit) = @_;

    if($bit){ $this->{byte} |= $this->{mask} }
    $this->{mask} = int($this->{mask} / 2);
    $this->{count} -= 1;
    if($this->{count} <= 0){
      my $char = pack("C", $this->{byte});
      print $char;
      $this->{byte} = 0;
      $this->{mask} = 0x80;
      $this->{count} = 8;
    }
  }
}
my($rows, $cols, $pattern);
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 1 || $#ARGV == 2){
  my $num_args = @ARGV;
  die "Wrong number of args ($num_args vs 2 or 3))\n$usage";
}
if($#ARGV == 2){
  ($rows, $cols, $pattern) = @ARGV;
} else {
  ($rows, $cols) = @ARGV;
  $pattern = "checkerboard";
}
unless(defined($rows)){ die "$0: rows undefined" }
unless(defined($cols)){ die "$0: cols undefined" }
print "P4 $cols $rows\n";
my $emitter = BitEmitter->open;
for my $i (0 .. $rows - 1){
  for my $j (0 .. $cols - 1){
    my $bit = (($i ^ $j) & 1);
    $emitter->emit(($i ^ $j) & 1)
  }
}
