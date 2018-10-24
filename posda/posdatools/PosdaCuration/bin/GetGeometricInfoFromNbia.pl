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
   db_host => <host_name_or_ip>,
   db_name => <db_name>,
   db_user => <db_user>,
   db_passwd => <db_password>,
   sops => [
     <sop_inst_1>,
     ...,
     <sop_inst_n>
   ],
 };

 returned data structure (OK):
 \$out = {
   status => "OK",
   sops => {
     <sop_inst_1> => {
       frame_of_ref_uid => <frame_of_reference_uid>,
       study_uid => <study_instance_uid>,
       series_uid => <series_instance_uid>,
       iop => <iop>,
       ipp => <ipp>,
       rows => <rows>,
       cols => <cols>,
     },
   },
   processing_errors => [
     <line 1>,
     ...,
     <line n>
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
unless(){ Error("Generic", { optional => "stuff", and => ["even", "more"]}) }
### 
# Process stuff here and populate results
###
$results->{Status} = "OK";
store_fd($results, \*STDOUT);
