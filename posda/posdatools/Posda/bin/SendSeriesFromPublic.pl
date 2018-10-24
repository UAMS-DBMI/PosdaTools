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
use Posda::DB::PosdaFilesQueries;
use Socket;
use Storable qw( store retrieve retrieve fd_retrieve store_fd );
use Debug;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
Usage: 
  SendSeriesFromPublic.pl <host> <port> <called> <calling> <series>
or
  SendSeriesFromPublic.pl -h
EOF
if($#ARGV < 4 || ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
my $q_inst = PosdaDB::Queries->GetQueryInstance("PublicFilesInSeries");
my %Hash;
$Hash{host} = shift @ARGV;
$Hash{port} = shift @ARGV;
$Hash{called} = shift @ARGV;
$Hash{calling} = shift @ARGV;
my $series_instance_uid = shift @ARGV;
$Hash{FilesToSend} = [];
$q_inst->RunQuery(sub {
  my($row) = @_;
  my $path = $row->[0];
  if($path =~ /^.*storage(\/.*)$/){
    push @{$Hash{FilesToSend}}, "/nas/public/storage$1";
  }
}, sub {} , $series_instance_uid);
my $number_of_files = @{$Hash{FilesToSend}};
print STDERR "Series_instance_uid: $series_instance_uid\n";
print STDERR "Number of files to send: $number_of_files\n";
for my $file (@{$Hash{FilesToSend}}){
  my $cmd = "SendOneFile.pl \"$Hash{host}\" " .
    "$Hash{port} $Hash{called} $Hash{calling} " .
    "\"$file\"";
print STDERR "Command: $cmd\n";
  open FILE, "$cmd|" or die "Can't open pipe to $cmd";
  my $results = "";
  while(my $line = <FILE>){
    chomp $line;
    $results .= "$line;";
  }
print STDERR "Results $results\n";
}
