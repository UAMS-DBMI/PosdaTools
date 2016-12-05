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
  SendSeriesFromDbAndRecord.pl <host> <port> <called> <calling> <series> <who> <why>
or
  SendSeriesFromDbAndRecord.pl -h
EOF
if($#ARGV < 6 || ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
my $q_inst = PosdaDB::Queries->GetQueryInstance("FilesInSeriesForSend");
my $ins_send_event = PosdaDB::Queries->GetQueryInstance("InsertSendEvent");
my $gseid = PosdaDB::Queries->GetQueryInstance("GetInsertedSendId");
my $upd_seid = PosdaDB::Queries->GetQueryInstance("UpdateSendEvent");
my $cr_dicom_file_send = PosdaDB::Queries->GetQueryInstance("CreateFileSend");
my %Hash;
$Hash{host} = shift @ARGV;
$Hash{port} = shift @ARGV;
$Hash{called} = shift @ARGV;
$Hash{calling} = shift @ARGV;
my $series_instance_uid = shift @ARGV;
$Hash{who} = shift @ARGV;
$Hash{why} = shift @ARGV;
$Hash{FilesToSend} = [];
$Hash{FilesFromDigest} = {};
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
    file_id => $row->[0],
    sop_class_uid => $row->[3],
    sop_inst_uid => $row->[6],
    digest => $row->[7],
  };
  $Hash{FilesFromDigest}->{$row->[7]} = $file_desc;
};
my $nop = sub { };
print STDERR "qinst->RunQuery($add_file, $nop, $series_instance_uid)\n";
$q_inst->RunQuery($add_file, $nop, $series_instance_uid);
#print STDERR "Specification: ";
#Debug::GenPrint($dbg, \%Hash, 1);
#print STDERR "\n";
#exit;
my $number_of_files = @{$Hash{FilesToSend}};
print STDERR "insert($Hash{host}, $Hash{port}, $Hash{called}," .
  " $Hash{calling}, $Hash{who}, $Hash{why}, $number_of_files)\n";
$ins_send_event->RunQuery($nop, $nop,
  $Hash{host}, $Hash{port},
  $Hash{called}, $Hash{calling},
  $Hash{who},
  $Hash{why}, $number_of_files,
  $series_instance_uid
);
my $send_event_id;
$gseid->RunQuery(sub {
  my($row) = @_;
    $send_event_id = $row->[0];
  },
  $nop,
);
unless(defined $send_event_id){
  die "Couldn't get dicom_send_event_id";
}
for my $file (@{$Hash{FilesToSend}}){
  my $dig = $Hash{FilesToDigest}->{$file};
  my $f_desc = $Hash{FilesFromDigest}->{$dig};
  my $file_id = $f_desc->{file_id};
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
  $cr_dicom_file_send->RunQuery($nop, $nop, 
    $send_event_id, $file, $results, $file_id);
}
$upd_seid->RunQuery($nop, $nop, $send_event_id);
