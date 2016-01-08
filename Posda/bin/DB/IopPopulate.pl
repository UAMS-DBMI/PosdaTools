#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/IopPopulate.pl,v $
#$Date: 2013/09/06 19:24:43 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use DBI;
use strict;
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0]", "", "");
my $q = $db->prepare(
  "select image_geometry_id, iop, ipp\n" .
  "from image_geometry\n" .
  "where pos_y is null\n"
);
$q->execute();
while(my $h = $q->fetchrow_hashref()){
  my @iop = split(/\\/, $h->{iop});
  my @ipp = split(/\\/, $h->{ipp});
  if($#iop == 5 &&  $#ipp == 2) {
    my @fine_iop;
    for my $i (0 .. 5){
      $fine_iop[$i] = sprintf("%0.5f", $iop[$i]);
      if($fine_iop[$i] == 1) { $fine_iop[$i] = "1"};
      if($fine_iop[$i] == -1) { $fine_iop[$i] = "-1"};
      if($fine_iop[$i] == 0) { $fine_iop[$i] = "0"};
    }
    my $normalized_iop = "$fine_iop[0]\\$fine_iop[1]\\$fine_iop[2]\\" .
      "$fine_iop[3]\\$fine_iop[4]\\$fine_iop[5]";
    my $q = $db->prepare(
      "update image_geometry\n" .
      "set normalized_iop = ?,\n" .
      "    row_x = ?,\n" .
      "    row_y = ?,\n" .
      "    row_z = ?,\n" .
      "    col_x = ?,\n" .
      "    col_y = ?,\n" .
      "    col_z = ?,\n" .
      "    pos_x = ?,\n" .
      "    pos_y = ?,\n" .
      "    pos_z = ?\n" .
      "where image_geometry_id = ?"
    );
      $q->execute($normalized_iop, $iop[0], $iop[1], $iop[2],
      $iop[3], $iop[4], $iop[5], $ipp[0], $ipp[1], $ipp[2],
      $h->{image_geometry_id});
  } else {
    print STDERR "Wrong number of iop or ipp\n";
  }
}
