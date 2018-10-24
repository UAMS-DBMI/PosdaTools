#!/usr/bin/perl -w
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Convert Bitmap to Contours
#
# This program accepts a compressed bitmap on an fd and writes contours
# to an fd as defined in the parameters

# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in=<number of input fd>
#  out=<number of output fd>
#  x=<x offset of 1st pixel>
#  y=<y offset of 1st pixel>
#  x_spc=<pix_sp_x>
#  y_spc=<pix_sp_y>
#  status=<number of status fd>
#  rows=<number of rows in bitmap input>
#  cols=<number of cols in bitmap input>
#
#  Contours will be written to output fd in following format:
#  BEGIN     # start of first contour
#  x1, y1    # first point (all points in pixel coordinates)
#  x2, y2    # second point
#  ...
#  x1, y2    # contours are closed
#  END
#  ...       # repeat if multiple contours
#
#  At the end (before exiting) a line of the form "OK\n" is
#  written to status.
use strict;
use Posda::FlipRotate;

my($in, $out, $status, $rows, $cols, $x, $y, $x_spc, $y_spc, $slice_index);
my $debug = 0;
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if ($key eq "in") { $in = $value }
  elsif ($key eq "out") { $out = $value }
  elsif ($key eq "x") { $x = $value }
  elsif ($key eq "y") { $y = $value }
  elsif ($key eq "x_spc") { $x_spc = $value }
  elsif ($key eq "y_spc") { $y_spc = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "rows") { $rows = $value }
  elsif ($key eq "cols") { $cols = $value }
  elsif ($key eq "debug") { $debug = $value }
  elsif ($key eq "slice_index") { $slice_index = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined $in) { die "$0: in is not defined" }
unless(defined $out) { die "$0: out is not defined" }
unless(defined $rows) { die "$0: rows is not defined" }
unless(defined $cols) { die "$0: cols is not defined" }
open(INPUT, "<&", $in) or die "$0: Can't open in = $in ($!)";
open(OUTPUT, ">&", $out) or die "$0: Can't open out = $out ($!)";
open(STATUS, ">&", $status) or die "$0: Can't open status = $status ($!)";
my $Contours;
## read bitmap two rows at a time and construct contours using
## marching squares
#######
if ($debug) {
  print STDERR "$0: Finished reading args.\n";
  print STDERR "\t: in = $in, out = $out, status = $status.\n";
  print STDERR "\t: x = $x, y = $y, x_spc = $x_spc, y_spc = $y_spc.\n";
  print STDERR "\t: rows = $rows, cols = $cols, slice: $slice_index.\n";
}
my $bytes_in_row = int(($cols + 7) / 8);
my $first_row = "\0" x ($bytes_in_row + 2);
my @row_in_constr;
my $cur_count = 0;
my $cur_polarity;
my $constr_byte = 0;
my $partial_bits = 0;
my $total_read = 0;
for my $i (0 .. $rows + 1){
  my $next_row;
  if($i < $rows){
    read_input:
    while($#row_in_constr < $bytes_in_row - 1){
      my $byte_buff;
      if($cur_count <= 0){
        my $count = sysread(INPUT, $byte_buff, 1);
        if($count != 1){
          die "$0: premature end of read ($count vs 1)\n" .
           " row: $i\n" .
           " rows: $rows, cols: $cols after $total_read" .
           " slice_index: $slice_index";
        }
        $total_read += 1;
        my $byte;
        {
          no warnings;
          $byte = unpack("c", $byte_buff);
        }
        $cur_polarity = ($byte & 0x80) >> 7;
        $cur_count = ($byte & 0x7f);
      }
      if($partial_bits == 0){
        my $bytes_in_cur = int($cur_count / 8);
        while(
          ($#row_in_constr < $bytes_in_row - 1) &&
          ($bytes_in_cur > 0)
        ){
          $bytes_in_cur -= 1;
          $cur_count -= 8;
          if($cur_polarity == 0){
            push(@row_in_constr, 0x0);
          } else {
            push(@row_in_constr, 0xff);
          }
        }
        if($cur_count > 0 && $cur_count <= 7){
          $constr_byte = 0;
          my $mask = 0;
          if($cur_polarity) { $mask = 0x01 }
          while($cur_count > 0){
            $cur_count -= 1;
            $constr_byte |= $mask;
            $mask <<= 1;
            $partial_bits += 1;
          } 
        }
      } else {
        my $remain_bits = 8 - $partial_bits;
        if($cur_count >= $remain_bits){
          # can finish this byte
          my $mask = 0;
          if($cur_polarity) { $mask = 0x01 }
          $mask <<= $partial_bits;
          for my $i (1 .. $remain_bits){
            $constr_byte |= $mask;
            $mask <<= 1;
            $partial_bits += 1;
            if($partial_bits > 7) { $partial_bits = 0 }
            $cur_count -= 1;
          }
          unless($partial_bits == 0) {
             die "logic error: partial bits = $partial_bits"
          }
          { 
            no warnings;
            push(@row_in_constr, $constr_byte);
          }
          $constr_byte = 0;
        } else {
          # can't finish this byte
          my $mask = 0;
          if($cur_polarity) { $mask = 0x01 }
          $mask <<= $partial_bits;
          while($cur_count > 0){
            $cur_count -= 1;
            $partial_bits += 1;
            if($partial_bits > 7) { $partial_bits = 0 }
            $constr_byte |= $mask;
            $mask <<= 1;
          }
        }
      }
    }
    my $buff;
    {
      no warnings;
      $buff = pack("c*", @row_in_constr);
    }
    $next_row = "\0" . $buff . "\0";
    @row_in_constr = ();
  } else {
    $next_row = "\0" x ($bytes_in_row + 2);
  }
  for my $j (0 .. $cols + 1){
    my @segs;
    my $l_b_x = 6 + $j;
    my $r_b_x = 7 + $j;
    my $ul = vec($first_row, $l_b_x, 1);
    my $ur = vec($first_row, $r_b_x, 1);
    my $ll = vec($next_row, $l_b_x, 1);
    my $lr = vec($next_row, $r_b_x, 1);
    my $f_r_i = $i - 1;
    my $l_r_i = $i;
    my $f_c_i = $j - 2;
    my $l_c_i = $j - 1;
    my $case = ($ul * 8) + ($ur * 4) +($ll * 2) + $lr;
    # [$l_c_i, ($f_r_i + $l_r_i)/2];   # right
    # [($f_c_i +$l_c_i) / 2, $l_r_i];  # bottom
    # [($f_c_i +$l_c_i) / 2, $f_r_i];  # top
    # [$f_c_i, ($f_r_i + $l_r_i)/2];   # left
    if($case == 0){
      # 0 0
      #
      # 0 0
      # nothing here
    } elsif($case == 1){
      # 0 0
      #   f
      # 0t1
      # one seg: f -> t (begins new)
      my $f = [$l_c_i, ($f_r_i + $l_r_i)/2];   # right
      my $t = [($f_c_i +$l_c_i) / 2, $l_r_i];  # bottom
      my $s = [$f, $t];
      $Contours = begin_new($s, $Contours);
    } elsif($case == 2){
      # 0 0
      # t
      # 1f0
      # one seg: f -> t (adds at beginning)
      my $t = [$f_c_i, ($f_r_i + $l_r_i)/2];   # left
      my $f = [($f_c_i +$l_c_i) / 2, $l_r_i];  # bottom
      my $s = [$f, $t];
      $Contours = add_beginning($s, $Contours);
    } elsif($case == 3){
      # 0 0
      # t f
      # 1 1
      # one seg: f -> t (adds at begining)
      my $t = [$f_c_i, ($f_r_i + $l_r_i)/2];   # left
      my $f = [$l_c_i, ($f_r_i + $l_r_i)/2];   # right
      my $s = [$f, $t];
      $Contours = add_beginning($s, $Contours);
    } elsif($case == 4){
      # 0f1
      #   t
      # 0 0
      # one seg: f -> t (adds at end)
      my $f = [($f_c_i +$l_c_i) / 2, $f_r_i];  # top
      my $t = [$l_c_i, ($f_r_i + $l_r_i)/2];   # right
      my $s = [$f, $t];
      $Contours = add_end($s, $Contours);
    } elsif($case == 5){
      # 0f1
      # 
      # 0t1
      # one seg: f -> t (adds at end)
      my $f = [($f_c_i +$l_c_i) / 2, $f_r_i];  # top
      my $t = [($f_c_i +$l_c_i) / 2, $l_r_i];  # bottom
      my $s = [$f, $t];
      $Contours = add_end($s, $Contours);
    } elsif($case == 6){
      # 0f1
      # t b
      # 1a0
      # two segs:
      #   f->t (adds at end and beginning)
      #        (close or connect)
      #   a->b (begins new)
      my $f = [($f_c_i +$l_c_i) / 2, $f_r_i];  # top
      my $b = [$l_c_i, ($f_r_i + $l_r_i)/2];   # right
      my $a = [($f_c_i +$l_c_i) / 2, $l_r_i];  # bottom
      my $t = [$f_c_i, ($f_r_i + $l_r_i)/2];   # left
      my $s = [$f, $t];
      $Contours = close_or_connect($s, $Contours);
      my $s1 = [$a, $b];
      $Contours = begin_new($s1, $Contours);
    } elsif($case == 7){
      # 0f1
      # t
      # 1 1
      # one seg: f -> t (adds at end and beginning)
      #        (close or connect)
      my $f = [($f_c_i +$l_c_i) / 2, $f_r_i];  # top
      my $t = [$f_c_i, ($f_r_i + $l_r_i)/2];   # left
      my $s = [$f, $t];
      $Contours = close_or_connect($s, $Contours);
    } elsif($case == 8){
      # 1t0
      # f
      # 0 0
      # one seg: f -> t (adds at beginning and end)
      #                 (close or connect)
      my $t = [($f_c_i +$l_c_i) / 2, $f_r_i];  # top
      my $f = [$f_c_i, ($f_r_i + $l_r_i)/2];   # left
      my $s = [$f, $t];
      $Contours = close_or_connect($s, $Contours);
    } elsif($case == 9){
      # 1b0
      # f a
      # 0t1
      # two segs:
      #   f->t (adds at end)
      #   a->b (adds at beginning)
      my $b = [($f_c_i +$l_c_i) / 2, $f_r_i];  # top
      my $a = [$l_c_i, ($f_r_i + $l_r_i)/2];   # right
      my $t = [($f_c_i +$l_c_i) / 2, $l_r_i];  # bottom
      my $f = [$f_c_i, ($f_r_i + $l_r_i)/2];   # left
      my $s = [$f, $t];
      $Contours = add_end($s, $Contours);
      my $s1 = [$a, $b];
      $Contours = add_beginning($s1, $Contours);
    } elsif($case == 10){
      # 1t0
      # 
      # 1f0
      # one seg: f -> t (adds at beginning)
      my $t = [($f_c_i +$l_c_i) / 2, $f_r_i];  # top
      my $f = [($f_c_i +$l_c_i) / 2, $l_r_i];  # bottom
      my $s = [$f, $t];
      $Contours = add_beginning($s, $Contours);
    } elsif($case == 11){
      # 1t0
      #   f
      # 1 1
      # one seg: f -> t (adds at beginning)
      my $t = [($f_c_i +$l_c_i) / 2, $f_r_i];  # top
      my $f = [$l_c_i, ($f_r_i + $l_r_i)/2];   # right
      my $s = [$f, $t];
      $Contours = add_beginning($s, $Contours);
    } elsif($case == 12){
      # 1 1
      # f t
      # 0 0
      # one seg: f -> t (adds at end)
      my $f = [$f_c_i, ($f_r_i + $l_r_i)/2];   # left
      my $t = [$l_c_i, ($f_r_i + $l_r_i)/2, $l_c_i];   # right
      my $s = [$f, $t];
      $Contours = add_end($s, $Contours);
    } elsif($case == 13){
      # 1 1
      # f
      # 0t1
      # one seg: f -> t (adds at end)
      my $f = [$f_c_i, ($f_r_i + $l_r_i)/2];   # left
      my $t = [($f_c_i +$l_c_i) / 2, $l_r_i];  # bottom
      my $s = [$f, $t];
      $Contours = add_end($s, $Contours);
    } elsif($case == 14){
      # 1 1
      #   t
      # 1f0
      # one seg: f -> t (begins new)
      my $t = [$l_c_i, ($f_r_i + $l_r_i)/2];   # right
      my $f = [($f_c_i +$l_c_i) / 2, $l_r_i];  # bottom
      my $s = [$f, $t];
      $Contours = begin_new($s, $Contours);
    } elsif($case == 15){
      # 1 1
      #    
      # 1 1
      # nothing here
    } else {
      die "$0: bad case";
    }
  }
  $first_row = $next_row;
}
if ($debug) {
  print STDERR "$0: Finished reading slice.\n";
}
sub add_beginning{
  my($seg, $contours) = @_;
  for my $c (@$contours){
    if(
      $c->[0]->[0] == $seg->[1]->[0] &&
      $c->[0]->[1] == $seg->[1]->[1]
    ){
      unshift(@{$c}, $seg->[0]);
      return $contours;
    }
  }
  die "add_beginning failed";
}
sub add_end{
  my($seg, $contours) = @_;
  for my $c (@$contours){
    if(
      $c->[$#{$c}]->[0] == $seg->[0]->[0] &&
      $c->[$#{$c}]->[1] == $seg->[0]->[1]
    ){
      push(@{$c}, $seg->[1]);
      return $contours;
    }
  }
  die "add_end failed";
}
sub close_or_connect{
  my($seg, $contours) = @_;
  my @re_cont;
  my @cl_cont;
  my $aug_end;
  my $aug_beg;
  contour:
  for my $c (@$contours){
    if(
      $c->[0]->[0] == $seg->[1]->[0] &&
      $c->[0]->[1] == $seg->[1]->[1]
    ){
      if(     
        $c->[$#{$c}]->[0] == $seg->[0]->[0] &&
        $c->[$#{$c}]->[1] == $seg->[0]->[1]
      ){ # closing a contour
        push(@$c, $seg->[1]);
        push(@re_cont, $c);
        next contour;
      } else { # adding to end of $c
        $aug_end = $c;
        next contour;
      }
    } elsif (
      $c->[$#{$c}]->[0] == $seg->[0]->[0] &&
      $c->[$#{$c}]->[1] == $seg->[0]->[1]
    ){ # adding to beginning of $c
      $aug_beg = $c;
      next contour;
    } else { # $c unaffected
      push(@re_cont, $c);
      next contour;
    }
  }
  if(defined($aug_end) && defined($aug_beg)){
    my @new_cont;
    for my $p (@$aug_beg) { push @new_cont, $p }
    for my $p (@$aug_end) { push @new_cont, $p }
    push(@re_cont, \@new_cont);
    return \@re_cont;
  } elsif (defined($aug_end) || defined($aug_beg)){
    die "close or connect didn't";
  } else {
    return \@re_cont;
  }
}
sub begin_new{
  my($seg, $contours) = @_;
  push(@$contours, $seg);
  return $contours;
}
sub dump_contours{
  my($contours) = @_;
  for my $c (@$contours){
    my $tot_pts = @$c;
    print "contour:\n";
    print "\tstart: ($c->[0]->[0], $c->[0]->[1])\n";
    if(@$c > 2){
      for my $i (1 .. $#{$c} - 1){
        print "\t$i: ($c->[$i]->[0], $c->[$i]->[1])\n";
      }
#      my $num_pts = @$c - 2;
#      print "\t... $num_pts pts\n";
    }
    print "\tend: ($c->[$#{$c}]->[0], $c->[$#{$c}]->[1])\n";
  }
}

# Write contours to files based on base_file
# And tell parent list of files written;
for my $contour (@$Contours){
  print OUTPUT "BEGIN\n";
  for my $i (0 .. $#{$contour}){
    my $p = $contour->[$i];
    my $xi = ($p->[0] * $x_spc) + $x;
    my $yi = ($p->[1] * $y_spc) + $y;
    print OUTPUT "$xi, $yi\n";
  }
  print OUTPUT "END\n";
}
if ($debug) {
  print STDERR "$0: Finished writing contoure file.\n";
}
close OUTPUT;
print STATUS "OK\n";
close STATUS;
