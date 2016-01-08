#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/BitMapToContour.pl,v $
#$Date: 2012/01/25 16:08:23 $
#$Revision: 1.7 $
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Convert Bitmap to Contours
#
# This program accepts a bitmap on an fd and writes a contours
# to a set of files as defined in the parameters

# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in=<number of input fd>
#  base_file=<base name of output files>
#  status=<number of status fd>
#  rows=<number of rows in bitmap input>
#  cols=<number of cols in bitmap input>
#  ulx=<x coordinate of upper left point>
#  uly=<y coordinate of upper left point>
#  ulz=<z coordinate of upper left point>
#  rowdcosx=<x of row direction cosine>
#  rowdcosy=<y of row direction cosine>
#  rowdcosy=<z of row direction cosine>
#  coldcosx=<x of col direction cosine>
#  coldcosy=<y of col direction cosine>
#  coldcosz=<z of col direction cosine>
#  rowspc=<spacing between columns>
#  colspc=<spacing between rows>
#
#  Contours will be written to files with names based
#  0n base_file (base_file_0, base_file_1, ...)
#  Each file will look like what might occur in a 
#  DICOM contour_data element...
#  When a contour is written to a file, a line of the
#  form "ContourFile: <file_name>\n" is written to status
#
#  At the end (before exiting) a line of the form "Finished: OK\n" is
#  written to status.
use strict;
use Posda::FlipRotate;

my($in, $base_file, $status, $rows, $cols, $ulx, $uly, $ulz,
  $rowdcosx, $rowdcosy, $rowdcosz,
  $coldcosx, $coldcosy, $coldcosz,
  $rowspc, $colspc
);
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if($key eq "in") { $in = $value }
  elsif ($key eq "base_file") { $base_file = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "rows") { $rows = $value }
  elsif ($key eq "cols") { $cols = $value }
  elsif ($key eq "ulx") { $ulx = $value }
  elsif ($key eq "uly") { $uly = $value }
  elsif ($key eq "ulz") { $ulz = $value }
  elsif ($key eq "rowdcosx") { $rowdcosx = $value }
  elsif ($key eq "rowdcosy") { $rowdcosy = $value }
  elsif ($key eq "rowdcosz") { $rowdcosz = $value }
  elsif ($key eq "coldcosx") { $coldcosx = $value }
  elsif ($key eq "coldcosy") { $coldcosy = $value }
  elsif ($key eq "coldcosz") { $coldcosz = $value }
  elsif ($key eq "rowspc") { $rowspc = $value }
  elsif ($key eq "colspc") { $colspc = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined $in) { die "$0: in is not defined" }
unless(defined $base_file) { die "$0: base_file is not defined" }
unless(defined $rows) { die "$0: cols is not defined" }
unless(defined $ulx) { die "$0: ulx is not defined" }
unless(defined $uly) { die "$0: uly is not defined" }
unless(defined $ulz) { die "$0: ulz is not defined" }
unless(defined $rowdcosx) { die "$0: rowdcosx is not defined" }
unless(defined $rowdcosy) { die "$0: rowdcosy is not defined" }
unless(defined $rowdcosz) { die "$0: rowdcosz is not defined" }
unless(defined $coldcosx) { die "$0: coldcosx is not defined" }
unless(defined $coldcosy) { die "$0: coldcosy is not defined" }
unless(defined $coldcosz) { die "$0: coldcosz is not defined" }
unless(defined $rowspc) { die "$0: rowspc is not defined" }
unless(defined $colspc) { die "$0: colspc is not defined" }
open(INPUT, "<&", $in) or die "$0: Can't open in = $in ($!)";
open(STATUS, ">&", $status) or die "$0: Can't open status = $status ($!)";

my $Contours;
## read bitmap two rows at a time and construct contours using
## marching squares
my $bytes_in_row = int(($cols + 7) / 8);
my $first_row = "\0" x ($bytes_in_row + 2);
for my $i (0 .. $rows){
  my $next_row;
  if($i < $rows){
    my $buff;
    my $count = sysread(INPUT, $buff, $bytes_in_row);
    unless($count == $bytes_in_row) {
      die "$0: premature end of read ($count) row: $i"
    }
    $next_row = "\0" . $buff . "\0";
  } else {
    $next_row = "\0" x ($bytes_in_row + 2);
  }
  for my $j (0 .. $cols){
    my @segs;
    my $l_b_x = 6 + $j;
    my $r_b_x = 7 + $j;
    my $ul = vec($first_row, $l_b_x, 1);
    my $ur = vec($first_row, $r_b_x, 1);
    my $ll = vec($next_row, $l_b_x, 1);
    my $lr = vec($next_row, $r_b_x, 1);
    my $f_r_i = $i - 1;
    my $l_r_i = $i;
    my $f_c_i = $j - 1;
    my $l_c_i = $j;
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
      my $num_pts = @$c - 2;
      print "\t... $num_pts pts\n";
    }
    print "\tend: ($c->[$#{$c}]->[0], $c->[$#{$c}]->[1])\n";
  }
}


# Write contours to files based on base_file
# And tell parent list of files written;
my $index = 0;
my $iop = [$rowdcosx, $rowdcosy, $rowdcosz, $coldcosx, $coldcosy, $coldcosz];
my $ipp = [$ulx, $uly, $ulz];
my $pix_sp = [$rowspc, $colspc];
for my $contour (@$Contours){
  $index += 1;
  my $file = "${base_file}_$index";
  open FILE, ">$file" or die "$0: Can't open $file for writing";
  for my $i (0 .. $#{$contour}){
    my $p = $contour->[$i];
    my $tp = Posda::FlipRotate::FromPixCoords(
      $iop, $ipp, $rows, $cols, $pix_sp, $p
    );
    print FILE "$tp->[0]\\$tp->[1]\\$tp->[2]";
    unless($i == $#{$contour}){ print FILE "\\"; }
  }
  close FILE;
  print STATUS "ContourFile: $file\n";
}
print STATUS "Finished: OK\n";
