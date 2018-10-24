#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

package HexDump;
sub PrintVax{
  my($handle, $data, $offset) = @_;
  my @hex = unpack("v*", $data);
  my @ascii = unpack("C*", $data);
  my $len = @ascii;
  unless(defined($offset)){ $offset = 0 }
#  print $handle ("        ");
  $handle->print("        ");
#  print $handle ("   e    c    a    8    6    4    2    0" .
  $handle->print("   e    c    a    8    6    4    2    0" .
    "              |0123456789abcdef|\n");
  my $i = 0;
  blk:
  while ($i < $len){
    my $j;
    line:
#    print $handle ("        ");
    $handle->print("        ");
    for $j (0 .. 0x7){
      my $k = (($i / 2) + 0x7) - $j;
      if($k > $#hex){
#        print $handle ("     ");
        $handle->print("     ");
      } else {
#        print $handle (sprintf("%04x ", $hex[$k] & 0xffff));
        $handle->print(sprintf("%04x ", $hex[$k] & 0xffff));
      }
    }
#    print $handle (sprintf(" <-%06x->  |", $i + $offset));
    $handle->print(sprintf(" <-%06x->  |", $i + $offset));
    asc:
    for $j (0 .. 0xf){
      my $k = $i + $j;
      if($k > $#ascii) { last asc;}
      my $char = chr($ascii[$k]);
      if($char =~ /^[[:graph:] ]$/){
#        print $handle ($char);
        $handle->print($char);
      } else {
#        print $handle (".");
        $handle->print(".");
      }
    }
#    print $handle ("|\n");
    $handle->print("|\n");
    $i += 0x10;
    if($i >= $len){ last blk;}
  }
}
sub PrintBigEndian{
  my($handle, $data, $offset) = @_;
  my @hex = unpack("n*", $data);
  my @ascii = unpack("C*", $data);
  my $len = @ascii;
  unless(defined($offset)){ $offset = 0 }
  print $handle ("        ");
  print $handle ("        ");
  print $handle ("0    2    4    6    8    a    c    e   " .
    " |0123456789abcdef|\n");
  my $i = 0;
  blk:
  while ($i < $len){
    my $j;
    line:
    print $handle ("        ");
    print $handle (sprintf("%06x: ", $i + $offset));
    for $j (0 .. 0x7){
      my $k = ($i / 2) + $j;
      if($k > $#hex){
        print $handle ("     ");
      } else {
        print $handle (sprintf("%04x ", $hex[$k] & 0xffff));
      }
    }
    print "|";
    asc:
    for $j (0 .. 0xf){
      my $k = $i + $j;
      if($k > $#ascii) { last asc;}
      my $char = chr($ascii[$k]);
      if($char =~ /^[[:graph:] ]$/){
        print $handle ($char);
      } else {
        print $handle (".");
      }
    }
    print $handle ("|\n");
    $i += 0x10;
    if($i >= $len){ last blk;}
  }
}
1;
