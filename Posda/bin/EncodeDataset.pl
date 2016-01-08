#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/EncodeDataset.pl,v $
#$Date: 2013/11/07 19:36:23 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dataset;
use Debug;
my $dbg = sub { print STDERR @_ };
use Storable qw( store_fd fd_retrieve );
my $help = <<EOF;
 EncodeDataset  meant to run as a sub-process
 Receives parameters via fd_retrive from STDIN.
 Writes a DICOM dataset STDOUT
 incoming data structure:
 \$in = {
   xfer_syntax => <xfr_syntax>,
   elements => {
     <sig> => <value>,
     ...
   },
 };

EOF
if($#ARGV == 0 && ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
my $spec = fd_retrieve(\*STDIN);
my $xfer_syntax = $spec->{xfer_syntax};
my $elements = $spec->{elements};
my $ds = Posda::Dataset->new_blank;
for my $ele (keys %$elements){
  $ds->Insert($ele, $elements->{$ele});
}
$ds->WriteDataset(\*STDOUT, $xfer_syntax);
