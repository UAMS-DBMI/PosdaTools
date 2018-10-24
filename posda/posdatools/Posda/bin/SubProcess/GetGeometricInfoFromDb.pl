#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
my $dbg = sub { print STDERR @_ };
use Storable qw( store_fd fd_retrieve );
my $help = <<EOF;
 Receives parameters via fd_retrive from STDIN.
 Writes results to STDOUT via store_fd
 incoming data structure:
 \$in = {
    db_host => <host name of nbia database>,
    sops => [
      <sop 1>,
      <sop 2>,
      ...
    ],
 };

 returned data structure (OK):
 \$out = {
   status => "OK",
   files => [
     {
       sop_inst => <sop_inst>,
       sop_class => <sop_class>,
       ipp => [<x>, <y>, <z>],
       iop => [<dxdr>, <dydr>, <dzdr>, <dxdc>, <dydc>, <dzdc>],
       rows => <rows>,
       cols => <cols>,
       pix_sp => [<dx>, <dy>],
     },
     ...
   ],
 };
 returned data structure (### Error condition ###):
 \$out = {
   status => "Error",
   message => <short text description>,
   additional_info => <desc>,
 };
EOF
if($#ARGV == 0 && ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
my $results = {};
sub Error{
  my($message, $addl) = @_;
  $results->{Status} = "Error";
  $results->{message} = $message;
  if($addl){ $results->{additional_info} = $addl }
  store_fd($results, \*STDOUT);
  exit;
}
my $edits = fd_retrieve(\*STDIN);
#unless(){ Error("Generic", { optional => "stuff", and => ["even", "more"]}) }
### 
# Process stuff here and populate results
###
my $dbhost = $edits->{db_host};
my $db = DBI->connect("DBI:mysql:database=ncia;host=$dbhost",
  "nciauser", "nciA#112");
unless($db){
  Error("Couldn't connect to db_host");
}
my $query = <<EOF;
select
  sop_class_uid, image_orientation_patient, image_position_patient,
  pixel_spacing, i_rows, i_columns
from
  general_image
where
  sop_instance_uid = ?
EOF
my $qh = $db->prepare($query);
my @files;
for my $sop (@{$edits->{sop_list}}){
  $qh->execute($sop);
  while(my $h = $qh->fetchrow_hashref){
    my $f = {
      sop_inst => $sop,
      sop_class => $h->{sop_class_uid},
      iop => [ split /\\/, $h->{image_orientation_patient} ],
      ipp => [ split /\\/, $h->{image_position_patient} ],
      rows => $h->{i_rows},
      cols => $h->{i_columns},
      pix_sp => [ $h->{pixel_spacing}, $h->{pixel_spacing} ],
    };
    push @files, $f;
  }
}
if(@files > 0){
  $results->{Status} = "OK";
  $results->{files} = \@files;
  store_fd($results, \*STDOUT);
} else {
  Error("No linked files found");
}
