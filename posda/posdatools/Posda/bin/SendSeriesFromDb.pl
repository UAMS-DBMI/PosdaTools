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
  DicomSendSeriesFromDb.pl <host> <port> <called> <calling> <series> <num_simul>
or
  DicomSendSeriesFromDb.pl -h
EOF

if($#ARGV < 5 || ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
my $q_inst = PosdaDB::Queries->GetQueryInstance("FilesInSeriesForSend");
my $db_name = $q_inst->GetSchema;
my $dbh = DBI->connect("dbi:Pg:dbname=$db_name");
unless($dbh) { die "Can't connect to $db_name" }
my %Hash;
$Hash{host} = shift @ARGV;
$Hash{port} = shift @ARGV;
$Hash{called} = shift @ARGV;
$Hash{calling} = shift @ARGV;
my $series_instance_uid = shift @ARGV;
$Hash{num_simul} = shift @ARGV;
$Hash{FilesToSend} = [];
$Hash{FilesByDigest} = {};
$Hash{FilesToDigest} = {};
my $add_file = sub {
  my($row) = @_;
  $Hash{FilesToDigest}->{$row->[1]} = $row->[7];
  push @{$Hash{FilesToSend}}, $row->[1];
  my $file_desc = {
    dataset_start_offset => $row->[5],
    dataset_size => $row->[4],
    xfr_stx => $row->[2],
    file => $row->[1],
    sop_class_uid => $row->[3],
    sop_inst_uid => $row->[6],
  };
  $Hash{FilesFromDigest}->{$row->[7]} = $file_desc;
};
$q_inst->RunQuery($add_file, sub {}, $series_instance_uid);
#print STDERR "Specification: ";
#Debug::GenPrint($dbg, \%Hash, 1);
#print STDERR "\n";
my $cmd = "SendFileListOneFilePerAssoc.pl \"$Hash{host}\" " .
  "\"$Hash{port}\" \"$Hash{called}\" \"$Hash{calling}\" " .
  "\"$Hash{num_simul}\"";
open FILE, "|$cmd" or die "can't open pipe to $cmd";
for my $file (@{$Hash{FilesToSend}}){
  print FILE "$file\n";
#  print "$file\n";
}
