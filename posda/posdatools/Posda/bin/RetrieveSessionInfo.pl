#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett and Erik Strom
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Storable qw( store_fd );
my $results = {};
my $file = $ARGV[0];
if(-f $file) { 
  open my $fh, "<$file";
  while(my $line = <$fh>){
    chomp $line;
    my @fields = split(/\|/, $line);
    if($fields[0] eq "elapsed_time") { $results->{duration} = $fields[1] }
    if($fields[0] eq "status") { $results->{termination_status} = $fields[1] }
    if($fields[0] eq "file"){
      my @path = split(/\//, $fields[$#fields]);
      my $prefix = "UN";
      if($path[$#path] =~ /^([^_]+)_/){
        $prefix = $1;
      }
      $results->{file_counts}->{$prefix} += 1;
      my $xfr_stx = $fields[3];
      $results->{xfr_stx_counts}->{$xfr_stx} += 1;
    }
  }
  my $info = "";
  for my $i (keys %{$results->{file_counts}}){
    $info .= "$i: $results->{file_counts}->{$i} ";
  }
  if($info) {
    $results->{info} = $info;
  } else {
    $results->{info} = "no files sent";
  }
} else {
  $results->{error} = "\"$file\" is not a file";
}
store_fd($results, \*STDOUT);
