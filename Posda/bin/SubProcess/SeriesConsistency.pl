#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/SubProcess/SeriesConsistency.pl,v $
#$Date: 2014/11/14 21:23:14 $
#$Revision: 1.2 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Debug;
my $dbg = sub { print STDERR @_ };
use Storable qw( store_fd fd_retrieve );
my $help = <<EOF;
 Receives parameters via fd_retrive from STDIN.
 Writes results to STDOUT via store_fd
 incoming data structure:
 \$in = {
   file_list => [
     <file_1>,
     ...,
   ],
   element_consistency_required => [
     <ele_1>,
     ...,
   ],
 };
 outgoing data structure:
 \$out = {
    Status => "Error" | "Ok",
    message => <msg>, ## If Status eq "Error"
    files_processed => [
      <file>,
      ...,
    ],
    files_not_processed => {
      <file> => <reason not processed>,
      ...
    },
    inconsitent_elements => {
      <ele> => {
        <value> => {
          <file> => 1,
          ...
        },
        ...
      },
      ...
    },
  }
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
my $spec = fd_retrieve(\*STDIN);
my %ele_data;
file:
for my $f ($spec->{file_list}){
  my $try = Posda::Try($f);
  unless(exists $try->{dataset}){
    $results->{files_not_processed}->{$f} = $try->{parse_errors};
    next file;
  }
  unless(exists $results->{files_processed}) {
    $results->{files_processed} = []
  }
  push @{$results->{files_processed}}, $f;
  my $ds = $try->{dataset};
  for my $e (@{$spec->{element_consistency_required}}){
    my $value = $ds->Get($e->{ele});
    if(ref($value) eq "ARRAY") { $value = join('\\', @$value) }
    $ele_data{$e->{ele}}->{$value}->{$f} = 1;
  }
}
for my $k (keys %ele_data){
  if(keys %{$ele_data{$k}} > 1){
    $results->{inconsistent_elements}->{$k} = $ele_data{$k};
  }
}
$results->{Status} = "Ok";
store_fd($results, \*STDOUT);
